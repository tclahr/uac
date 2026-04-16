#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

usage() {
    cat <<EOM
Extract lists of different file and directory types from mactime bodyfile
during UAC collection.

Usage: $0 BODYFILE [MOUNT_POINT] [DESTINATION]

Positional Arguments:
  BODYFILE        Path to the bodyfile file.

Optional Arguments:
  MOUNT_POINT     Specify the mount point (default: /).
  DESTINATION     Specify the directory the output files should be written to.
                  Default is the current directory.
EOM
}

if [ ${#} -lt 1 ]; then
    usage
    exit 1;
fi

BODYFILE="${1}"
MOUNT_POINT="${2:-/}"
DESTINATION="${3:-.}"

if [ ! -f "${BODYFILE}" ]; then
    echo "'${BODYFILE}': No such file or directory." >&2
    exit 1
fi

if [ ! -d "${MOUNT_POINT}" ]; then
    echo "'${MOUNT_POINT}': No such file or directory." >&2
    exit 1
fi

if [ ! -d "${DESTINATION}" ]; then
    echo "'${DESTINATION}': No such file or directory." >&2
    exit 1
fi

PASSWD_FILE="${MOUNT_POINT}/etc/passwd"
GROUP_FILE="${MOUNT_POINT}/etc/group"

awk -F'|' -v passwd_file="${PASSWD_FILE}" -v group_file="${GROUP_FILE}" -v destination="${DESTINATION}" '

BEGIN {

    # Turn the UIDs and GIDs into arrays
    while ((getline < passwd_file) > 0) {
        split($0,a,":")
        uids[a[3]] = 1
    }
    close(passwd_file)

    while ((getline < group_file) > 0) {
        split($0,a,":")
        gids[a[3]] = 1
    }
    close(group_file)

    # Define output files
    # This is required as some awk versions do not support output redirection to variable and string concatenation
    # i.e. print "sample" > destination "/file.txt"
    socket_files = destination "/socket_files.txt"
    hidden_files = destination "/hidden_files.txt"
    hidden_directories = destination "/hidden_directories.txt"
    suid = destination "/suid.txt"
    sgid = destination "/sgid.txt"
    world_writable_files = destination "/world_writable_files.txt"
    world_writable_directories = destination "/world_writable_directories.txt"
    world_writable_not_sticky_directories = destination "/world_writable_not_sticky_directories.txt"
    group_writable_files = destination "/group_writable_files.txt"
    group_writable_directories = destination "/group_writable_directories.txt"
    user_name_unknown_files = destination "/user_name_unknown_files.txt"
    user_name_unknown_directories = destination "/user_name_unknown_directories.txt"
    group_name_unknown_files = destination "/group_name_unknown_files.txt"
    group_name_unknown_directories = destination "/group_name_unknown_directories.txt"

    # Create empty output files
    printf "" > socket_files
    printf "" > hidden_files
    printf "" > hidden_directories
    printf "" > suid
    printf "" > sgid
    printf "" > world_writable_files
    printf "" > world_writable_directories
    printf "" > world_writable_not_sticky_directories
    printf "" > group_writable_files
    printf "" > group_writable_directories
    printf "" > user_name_unknown_files
    printf "" > user_name_unknown_directories
    printf "" > group_name_unknown_files
    printf "" > group_name_unknown_directories
}

{
    path=$2
    mode=$4
    uid=$5
    gid=$6

    file_type=substr(mode,1,1)

    user_exec_mode=substr(mode,4,1)
    group_write_mode=substr(mode,6,1)
    group_exec_mode=substr(mode,7,1)
    others_write_mode=substr(mode,9,1)
    others_exec_mode=substr(mode,10,1)

    if (file_type == "s")
        print path >> socket_files

    if (path ~ /\/\.[^\/]*$/ && file_type == "-")
        print path >> hidden_files

    if (path ~ /\/\.[^\/]*$/ && file_type == "d")
        print path >> hidden_directories

    if ((user_exec_mode == "s" || user_exec_mode == "S") && file_type == "-")
        print path >> suid

    if ((group_exec_mode == "s" || group_exec_mode == "S") && file_type == "-")
        print path >> sgid

    if (others_write_mode == "w" && file_type == "-")
        print path >> world_writable_files

    if (others_write_mode == "w" && file_type == "d")
        print path >> world_writable_directories

    if (others_write_mode == "w" && file_type == "d" && others_exec_mode != "t" && others_exec_mode != "T")
        print path >> world_writable_not_sticky_directories

    if (group_write_mode == "w" && file_type == "-")
        print path >> group_writable_files

    if (group_write_mode == "w" && file_type == "d")
        print path >> group_writable_directories

    if (!(uid in uids) && file_type == "-")
        print path >> user_name_unknown_files

    if (!(uid in uids) && file_type == "d")
        print path >> user_name_unknown_directories

    if (!(gid in gids) && file_type == "-")
        print path >> group_name_unknown_files

    if (!(gid in gids) && file_type == "d")
        print path >> group_name_unknown_directories
}

' "${BODYFILE}"
