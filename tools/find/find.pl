#!/usr/bin/env perl

# Copyright (C) 2019,2020 IBM Corporation
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
    print("Usage: find.pl starting-point [OPTIONS]\n");
    print("\n");
    print("OPTIONS\n");
    print("    -maxdepth LEVELS\n");
    print("        Descend at most levels (a non-negative integer) levels of directories below the starting-point.\n");
    print("\n");
    print("    -name PATTERN\n");
    print("        File name matches specified glob wildcard pattern (just as with using find).\n");
    print("\n");
    print("    -iname PATTERN\n");
    print("        Like -name, but the match is case insensitive.\n");
    print("\n");
    print("    -atime N\n");
    print("        File was last accessed N*24 hours ago. When find figures out how many 24-hour periods ago the file was\n");
    print("        last accessed, any fractional part is ignored, so to match -atime +1, a file has to have been accessed\n");
    print("        at least two days ago.\n");
    print("\n");
    print("    -mtime N\n");
    print("        File's data was last modified N*24 hours ago. See the comments for -atime to understand how rounding\n");
    print("        affects the interpretation of file status change times.\n");
    print("\n");
    print("    -ctime N\n");
    print("        File's status was last changed N*24 hours ago. See the comments for -atime to understand how rounding\n");
    print("        affects the interpretation of file status change times.\n");
    print("\n");
    print("    -type X\n");
    print("        File is of type X:\n");
    print("\n");
    print("        f   regular file\n");
    print("        d   directory\n");
    print("        l   symbolic link\n");
    print("        p   named pipe (FIFO)\n");
    print("        s   socket\n");
    print("        b   block special\n");
    print("        c   character special\n");
    print("\n");
    print("    -size N[ckMG]\n");
    print("        File uses N units of space. The following suffixes can be used:\n");
    print("\n");
    print("        c   for bytes (this is the default if no suffix is used)\n");
    print("        k   for kilobytes (kB, units of 1024 bytes)\n");
    print("        M   for megabyte (MB, units of 1024 * 1024 bytes)\n");
    print("        G   for gigabyte (GB, units of 1024 * 1024 * 1024 bytes)\n");
    print("\n");
    print("    Predicates which take a numeric argument N can come in three forms:\n");
    print("        N is prefixed with a +: match values greater than N\n");
    print("        N is prefixed with a -: match values less than N\n");
    print("        N is not prefixed with either + or -: match only values equal to N\n");
    print("\n");
    exit 1;
}

sub fileglob_to_regex($) {
    my $retval = shift;
    $retval =~ s#([./^\$()+])#\\$1#g;
    $retval =~ s#\*#.*#g;
    $retval =~ s#\?#.#g;
    "^$retval\\z";
}

my $root = $ARGV[0] || usage();
if (-e $root) {
    shift;
    my $wanted = "print(\"\$File::Find::name\\n\");";
    my $maxdepth = 0;
    my $depth = 0;
    my $lstat_needed = 0;
    while(@ARGV) {
        my $arg_option = shift;
        if ($arg_option =~ /^-maxdepth$/) {
            $maxdepth = shift;
            ($maxdepth =~ /^\d+$/) || die ("Expected a positive decimal integer argument to -maxdepth, but got $maxdepth\n");
        } elsif ($arg_option =~ /^-name$/) {
            $wanted = "/" . fileglob_to_regex(shift) . "/ && " . $wanted;
        } elsif ($arg_option =~ /^-iname$/) {
            $wanted = "/" . fileglob_to_regex(shift) . "/i && " . $wanted;
        } elsif ($arg_option =~ /^-atime$/) {
            my $atime = shift;
            ($atime =~ /^([\+\-]?)(\d+)$/) || die ("Invalid argument to -atime: $atime\n");
            $atime =~ s/^-/< / || $atime =~ s/^\+/> / || $atime =~ s/^/== /;
            $wanted = "int(-A _) $atime && " . $wanted;
            $lstat_needed = 1;
        } elsif ($arg_option =~ /^-mtime$/) {
            my $mtime = shift;
            ($mtime =~ /^([\+\-]?)(\d+)$/) || die ("Invalid argument to -mtime: $mtime\n");
            $mtime =~ s/^-/< / || $mtime =~ s/^\+/> / || $mtime =~ s/^/== /;
            $wanted = "int(-M _) $mtime && " . $wanted;
            $lstat_needed = 1;
        } elsif ($arg_option =~ /^-ctime$/) {
            my $ctime = shift;
            ($ctime =~ /^([\+\-]?)(\d+)$/) || die ("Invalid argument to -ctime: $ctime\n");
            $ctime =~ s/^-/< / || $ctime =~ s/^\+/> / || $ctime =~ s/^/== /;
            $wanted = "int(-C _) $ctime && " . $wanted;
            $lstat_needed = 1;
        } elsif ($arg_option =~ /^-type$/) {
            my $type = shift;
            $type =~ /^[fdlpsbc]$/ || die ("Unknown argument to -type: $type\n");
            $type =~ tr/s/S/;
            $wanted = "(-$type _) && " . $wanted;
            $lstat_needed = 1;
        } elsif ($arg_option =~ /^-size$/) {
            my $size = shift;
            ($size =~ /^([\+\-]?)(\d+)([ckMG]?)$/) || die ("Invalid argument to -size: $size\n");
            $size =~ s/^-/< / || $size =~ s/^\+/> / || $size =~ s/^/== /;
            $size =~ s/c$// || $size =~ s/k$/000/ || $size =~ s/M$/000000/ || $size =~ s/G$/000000000/;
            $wanted = "int(-s _) $size && " . $wanted;
            $lstat_needed = 1;
        } else {
            die("Unrecognized option: $arg_option\n");
        }
    }
    if ($lstat_needed) {
        $wanted = "lstat(\$File::Find::name) && " . $wanted;
    }
    find({
        preprocess => sub {
            $depth += 1;
            return if ($depth > $maxdepth) and ($maxdepth > 0);
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
    }, $root);
} else {
    die("$root: No such file or directory\n")
}