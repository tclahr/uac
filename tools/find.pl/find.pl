#!/usr/bin/env perl

# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use File::Find;

sub usage {
    print <<"USAGE";
Usage: find.pl starting-point [OPTIONS]

OPERATORS
    \\( expression \\)
        Evaluates to the value True if the expression in parentheses is true.
        Since parentheses are special to the shell, you will need to use backslashes \\( \\).

    !   not
    -a  and
    -o  or

OPTIONS
    -maxdepth LEVELS
        Descend at most levels (a non-negative integer) levels of directories below the starting-point.

    -name PATTERN
        File name matches specified glob wildcard pattern (just as with using find).

    -iname PATTERN
        Like -name, but the match is case insensitive.

    -path PATTERN
        File path matches specified glob wildcard pattern (just as with using find).

    -ipath PATTERN
        Like -path, but the match is case insensitive.

    -atime N
        File was last accessed N*24 hours ago. When find figures out how many 24-hour periods ago the file was
        last accessed, any fractional part is ignored, so to match -atime +1, a file has to have been accessed
        at least two days ago.

    -mtime N
        File's data was last modified N*24 hours ago. See the comments for -atime to understand how rounding
        affects the interpretation of file status change times.

    -ctime N
        File's status was last changed N*24 hours ago. See the comments for -atime to understand how rounding
        affects the interpretation of file status change times.

    -type X
        File is of type X:

        f   regular file
        d   directory
        l   symbolic link
        p   named pipe (FIFO)
        s   socket
        b   block special
        c   character special

    -size N[ckMG]
        File uses N units of space. The following suffixes can be used:

        c   for bytes (this is the default if no suffix is used)
        k   for kilobytes (kB, units of 1024 bytes)
        M   for megabyte (MB, units of 1024 * 1024 bytes)
        G   for gigabyte (GB, units of 1024 * 1024 * 1024 bytes)

    -perm MODE
        File's permission bits are exactly mode (octal). Symbolic mode is not supported.

    -perm -MODE
        All of the permission bits mode (octal) are set for the file. Symbolic mode is not supported.

    -perm /MODE
        Any of the permission bits mode are set for the file. Symbolic mode is not supported.

    -prune
        Always evaluates to the value True. If the file is a directory, do not descend into it.

    -print
        Always evaluates to the value True. Print the full file name on the standard output, followed by a newline.

    -print0
        Always evaluates to the value True. Print the full file name on the standard output, followed by a null character.

    Predicates which take a numeric argument N can come in three forms:
        N is prefixed with a +: match values greater than N
        N is prefixed with a -: match values less than N
        N is not prefixed with either + or -: match only values equal to N

USAGE
}

sub fileglob_to_regex($) {
    my $retval = shift;
    $retval =~ s#([./^\$()+])#\\$1#g;
    $retval =~ s#\*#.*#g;
    $retval =~ s#\?#.#g;
    "^$retval\\z";
}

my @starting_points = ();
my $wanted = "my (\$dev,\$inode,\$mode,\$nlink,\$uid,\$gid,\$rdev,\$size,\$atime,\$mtime,\$ctime,\$blksize,\$blocks); ((\$dev,\$inode,\$mode,\$nlink,\$uid,\$gid,\$rdev,\$size,\$atime,\$mtime,\$ctime,\$blksize,\$blocks) = lstat(\$File::Find::name)) && ";
my $depth = 0;
my $maxdepth = 0;
my $print_needed = 1;

# print usage if no arguments are provided
if (@ARGV < 1) {
    usage();
    exit 1;
}

# get starting-points only
while (@ARGV) {
    my $arg_option = shift;
    if (($arg_option !~ /^-/) and ($arg_option ne "!") and ($arg_option ne "(") and ($arg_option ne ")")) {
        push(@starting_points, $arg_option);
    } else {
        unshift(@ARGV, $arg_option);
        last;
    }
}

# use current directory . as the starting-point if none was provided
if (@starting_points < 1) {
    push(@starting_points, ".");
}

# parse remaining parameters
while (@ARGV) {
    my $arg_option = shift;
    if ($arg_option eq "!") {
        $wanted .= "!";
        next;
    } elsif ($arg_option eq "(") {
        $wanted .= "(";
        next;
    } elsif ($arg_option eq ")") {
        $wanted .= ")";
    } elsif ($arg_option eq "-maxdepth") {
        $maxdepth = shift;
        ($maxdepth =~ /^\d+$/) || die ("find.pl: expected a non-negative integer argument to -maxdepth, but got $maxdepth\n");
        next;
    } elsif ($arg_option eq "-name") {
        $wanted .= "/" . fileglob_to_regex(shift) . "/s";
    } elsif ($arg_option eq "-iname") {
        $wanted .= "/" . fileglob_to_regex(shift) . "/si";
    } elsif ($arg_option eq "-path") {
        $wanted .= "\$File::Find::name =~ /" . fileglob_to_regex(shift) . "/s";
    } elsif ($arg_option eq "-ipath") {
        $wanted .= "\$File::Find::name =~ /" . fileglob_to_regex(shift) . "/si";
    } elsif ($arg_option eq "-atime") {
        my $atime = shift;
        ($atime =~ /^([\+\-]?)(\d+)$/) || die ("find.pl: invalid argument to -atime: $atime\n");
        $atime =~ s/^-/< / || $atime =~ s/^\+/> / || $atime =~ s/^/== /;
        $wanted .= "int(-A _) $atime";
    } elsif ($arg_option eq "-mtime") {
        my $mtime = shift;
        ($mtime =~ /^([\+\-]?)(\d+)$/) || die ("find.pl: invalid argument to -mtime: $mtime\n");
        $mtime =~ s/^-/< / || $mtime =~ s/^\+/> / || $mtime =~ s/^/== /;
        $wanted .= "int(-M _) $mtime";
    } elsif ($arg_option eq "-ctime") {
        my $ctime = shift;
        ($ctime =~ /^([\+\-]?)(\d+)$/) || die ("find.pl: invalid argument to -ctime: $ctime\n");
        $ctime =~ s/^-/< / || $ctime =~ s/^\+/> / || $ctime =~ s/^/== /;
        $wanted .= "int(-C _) $ctime";
    } elsif ($arg_option eq "-perm") {
        my $perm = shift;
        ($perm =~ /^[-\/]?[0-7]{1,4}$/) || die ("find.pl: invalid argument to -perm: $perm\n");
        if ($perm =~ s/^-//) {
            $perm = sprintf("0%s", $perm & 07777);
            $wanted .= "((\$mode & $perm) == $perm)";
        } elsif ($perm =~ s/^\///) {
            my $o_perm = sprintf("000%s", substr($perm, -1, 1));
            $o_perm = sprintf("0%s", $o_perm & 07777);
            $wanted .= "( ((\$mode & $o_perm) == $o_perm)";
            if (substr($perm, -2, 1)) {
                my $g_perm = sprintf("00%s0", substr($perm, -2, 1));
                $g_perm = sprintf("0%s", $g_perm & 07777);
                $wanted .= " || ((\$mode & $g_perm) == $g_perm)";
            }
            if (substr($perm, -3, 1)) {
                my $u_perm = sprintf("0%s00", substr($perm, -3, 1));
                $u_perm = sprintf("0%s", $u_perm & 07777);
                $wanted .= " || ((\$mode & $u_perm) == $u_perm)";
            }
            if (substr($perm, -4, 1)) {
                my $s_perm = sprintf("%s000", substr($perm, -4, 1));
                $s_perm = sprintf("0%s", $s_perm & 07777);
                $wanted .= " || ((\$mode & $s_perm) == $s_perm)";
            }
            $wanted .= ")"
        } else {
            $perm =~ s/^0*/0/;
            $wanted .= "((\$mode & 07777) == $perm)";
        }
    } elsif ($arg_option eq "-type") {
        my $type = shift;
        $type =~ /^[fdlpsbc]$/ || die ("find.pl: unknown argument to -type: $type\n");
        $type =~ tr/s/S/;
        $wanted .= "(-$type _)";
    } elsif ($arg_option eq "-size") {
        my $size = shift;
        ($size =~ /^([\+\-]?)(\d+)([ckMG]?)$/) || die ("find.pl:  invalid argument to -size: $size\n");
        $size =~ s/^-/< / || $size =~ s/^\+/> / || $size =~ s/^/== /;
        $size =~ s/c$// || $size =~ s/k$/000/ || $size =~ s/M$/000000/ || $size =~ s/G$/000000000/;
        $wanted .= "int(-s _) $size";
    } elsif ($arg_option eq "-prune") {
        $wanted .= "(\$File::Find::prune = 1)";
    } elsif ($arg_option eq "-print") {
        $wanted .= "print(\"\$File::Find::name\\n\");";
        $print_needed = 0;
    } elsif ($arg_option eq "-print0") {
        $wanted .= "print(\"\$File::Find::name\");";
        $print_needed = 0;
    } else {
        die("find.pl: unrecognized option: $arg_option\n");
    }

    if (@ARGV) {
        if ($ARGV[0] eq "-o") {
            $wanted .= " || ";
            shift;
        } else {
            $wanted .= " && " unless $ARGV[0] eq ")";
            shift if $ARGV[0] eq "-a";
        }
    }

}

if ($print_needed) {
    if ($wanted =~ /&&\s*$/) {
        $wanted .= " print(\"\$File::Find::name\\n\");";
    } else {
        $wanted .= " && print(\"\$File::Find::name\\n\");";
    }
}

for my $starting_point (@starting_points) {
    if (-e $starting_point) {
        find({
            preprocess => sub {
                $depth += 1;
                return if ($depth > $maxdepth);
                @_;
            },
            postprocess => sub {
                $depth -= 1;
                @_;
            },
            wanted => sub {
                eval $wanted;
            },
            no_chdir => 0,
            follow_skip => 1
        }, $starting_point);
    } else {
        print STDERR "find.pl: no such file or directory '$starting_point'\n";
    }
}
