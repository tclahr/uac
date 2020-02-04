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
use Getopt::Long;

my $max_depth_option = 0;
my $regex_option = "";
my $size_option_value = 0;
my $size_option_prefix = ""; # less or greater than
my $size_option_unit = "c"; # for bytes

sub usage {
    print("Usage: find.pl [OPTIONS] starting-point\n");
    print("\n");
    print("OPTIONS\n");
    print("    -maxdepth LEVELS\n");
    print("       Descend at most levels (a non-negative integer) levels of directories below the starting-point.\n");
    print("\n");
    print("    -regex PATTERN\n");
    print("       File name matches regular expression pattern. This is a match on the whole path, not a search.\n");
    print("\n");
    print("    -size N[ckMG]\n");
    print("       File uses N units of space. The following suffixes can be used:\n");
    print("\n");
    print("       c   for bytes (this is the default if no suffix is used)\n");
    print("       k   for kilobytes (kB, units of 1024 bytes)\n");
    print("       M   for megabyte (MB, units of 1024 * 1024 bytes)\n");
    print("       G   for gigabyte (GB, units of 1024 * 1024 * 1024 bytes)\n");
    print("\n");
    print("       The + and - prefixes signify greater than and less than, as usual.\n");
    print("\n");
    exit 1;
}

sub size_option_handler {
    my ($opt_name, $opt_value) = @_;
    if ($opt_value =~ /([\+\-]?)(\d+)([ckMG]?)/) {
        $size_option_prefix = ($1 eq "+" or $1 eq "-") ? $1 : "";
        $size_option_value = $2;
        $size_option_unit = ($3 eq "c" or $3 eq "k" or $3 eq "M" or $3 eq "G") ? $3 : usage();
    } else {
        usage();
    }
}

GetOptions(
    "maxdepth=i"    => \$max_depth_option,
    "regex=s"       => \$regex_option,
    "size=s"        => \&size_option_handler
) or usage();

my $root = defined $ARGV[0] ? $ARGV[0] : ".";
if (-e $root) {
    my $depth = 0;
    $size_option_value = ($size_option_unit eq "k") ? $size_option_value * 1024 : $size_option_value;
    $size_option_value = ($size_option_unit eq "M") ? $size_option_value * 1024 * 1024 : $size_option_value;
    $size_option_value = ($size_option_unit eq "G") ? $size_option_value * 1024 * 1024 * 1024 : $size_option_value;
    find({
        preprocess => sub {
            $depth += 1;
            return if ($depth > $max_depth_option) and ($max_depth_option > 0);
            @_;
        },
        postprocess => sub {
            $depth -= 1;
            @_;
        },
        wanted => sub {
            my $regex_option_passed = 1;
            my $size_option_passed = 1;

            if ($regex_option) {
                if ($File::Find::name !~ /$regex_option/) {
                    $regex_option_passed = 0;
                }
            }

            if ($size_option_value) {
                my ($dev,$inode,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($File::Find::name);
                if ($size_option_prefix eq "+") {
                    if ($size <= $size_option_value) {
                        $size_option_passed = 0;
                    }
                } elsif ($size_option_prefix eq "-") {
                    if ($size >= $size_option_value) {
                        $size_option_passed = 0;
                    }
                } else {
                    if ($size != $size_option_value) {
                        $size_option_passed = 0;
                    }
                }
            }

            if ($regex_option_passed and $size_option_passed) {
                print("$File::Find::name\n");
            }
        },
        no_chdir => 1,
        follow_skip => 1
    }, $root);

} else {
    die("'$root': No such file or directory\n")
}
