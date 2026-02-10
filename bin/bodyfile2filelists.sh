#!/bin/sh
# shellcheck disable=SC2006

usage() {
    cat <<EOM
Extract lists of different file and directory types from mactime bodyfile
during UAC collection.

Usage: $0 <directory> [<mountpoint>]

<directory> should be a UAC output directory with "bodyfile/bodyfile.txt".
Output files will be written to the "system" directory.

Supply <mountpoint> if collecting from directory rather than live system.
EOM
    exit 1;
}

# Abort if we can't read bodyfile.txt
UACDir=$1
[ -r "$UACDir/bodyfile/bodyfile.txt" ] || usage
MountDir=$2

BodyFile="$UACDir/bodyfile/bodyfile.txt"
OutputDir="$UACDir/system"
mkdir -p "$OutputDir"

# Create lists of UIDs and GIDs which will be passed into awk later
uidlist=
if [ -r "$MountDir/etc/passwd" ]; then
    uidlist=`cut -f3 -d: "$MountDir/etc/passwd" | tr '\n' \| | sed 's/|$//'`
fi

gidlist=
if [ -r "$MountDir/etc/passwd" ]; then
    gidlist=`cut -f3 -d: "$MountDir/etc/group" | tr '\n' \| | sed 's/|$//'`
fi

# mactime style bodyfile fields are:
# MD5|name|inode|mode_as_string|UID|GID|size|atime|mtime|ctime|crtime

# Pattern matching in the bodyfile is done in an awk script. For each match,
# the awk code outputs a filename the match should be written to and the
# matching path. A shell "while read" loop consumes the awk output and
# handles actually writing the matches to the appropriate files.
lastoutfile=
awk -F\| -v uidlist="$uidlist" -v gidlist="$gidlist" '
    # Turn the UID and GID lists that were supplied into arrays
    # indexed by UID and GID for fast lookups
    BEGIN { split(uidlist, temp)
            for (i in temp) { uids[temp[i]]=1 }
	    split(gidlist, temp)
	    for (i in temp) { gids[temp[i]]=1 }
    }

    # file type "s", socket_files.txt
    $4 ~ /^s/ {print "socket_files.txt", $2}
    
    # name starts with "." && file type "d", hidden_directories.txt
    $4 ~ /^d/ && $2 ~ /\/\.[^\/]*$/ {print "hidden_directories.txt", $2}
    # name starts with "." && file type "-", hidden_files.txt
    $4 ~ /^-/ && $2 ~ /\/\.[^\/]*$/ {print "hidden_files.txt", $2}

    # file type "-" && perms match "^...[sS]", suid.txt
    $4 ~ /^-..[sS]/ {print "suid.txt", $2}
    # type "-" && matches "^......[sS]", sgid.txt
    $4 ~ /^-.....[sS]/ {print "sgid.txt", $2}

    # World writable files and directories
    $4 ~ /^-.......w/ {print "world_writable_files.txt", $2}
    $4 ~ /^d.......w/ {print "world_writable_directories.txt", $2}
    $4 ~ /^d.......w[^t]/ {print "world_writable_not_sticky_directories.txt", $2}

    # Group writable files and directories
    $4 ~ /^-....w/ {print "group_writable_files.txt", $2}
    $4 ~ /^d....w/ {print "group_writable_directories.txt", $2}

    # Unknown user/group files and directories
    length(uidlist) && !($5 in uids) && $4 ~ /^-/ {print "user_name_unknown_files.txt", $2}
    length(uidlist) && !($5 in uids) && $4 ~ /^d/ {print "user_name_unknown_directories.txt", $2}
    length(gidlist) && !($6 in gids) && $4 ~ /^-/ {print "group_name_unknown_files.txt", $2}
    length(gidlist) && !($6 in gids) && $4 ~ /^d/ {print "group_name_unknown_directories.txt", $2}' "$BodyFile" |
    sort | while read -r outfile filepath; do
               # Input lines are sorted by the output file, so just
               # switch the output destination when that file name changes
               if [ "$outfile" != "$lastoutfile" ]; then
		   exec >"$OutputDir/$outfile"
		   lastoutfile="$outfile"
	       fi
	       echo "$filepath"
           done
