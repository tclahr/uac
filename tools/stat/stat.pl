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

my $filename = @ARGV[0];

if (defined $filename) {

    my ($dev,$inode,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat($filename);

    my @perms = qw(--- --x -w- -wx r-- r-x rw- rwx);
    my @ftype = qw(. p c ? d ? b ? - ? l ? s ? ? ?);

    $ftype[0] = '';

    my $setids = ($mode & 07000)>>9;
    my @permstrs = @perms[($mode&0700)>>6, ($mode&0070)>>3, $mode&0007];
    my $ftype = $ftype[($mode & 0170000)>>12];

    if ($setids) {
        if ($setids & 01) {         # Sticky bit
            $permstrs[2] =~ s/([-x])$/$1 eq 'x' ? 't' : 'T'/e;
        }
        if ($setids & 04) {         # Setuid bit
            $permstrs[0] =~ s/([-x])$/$1 eq 'x' ? 's' : 'S'/e;
        }
        if ($setids & 02) {         # Setgid bit
            $permstrs[1] =~ s/([-x])$/$1 eq 'x' ? 's' : 'S'/e;
        }
    }

    $mode_as_string = join '', $ftype, @permstrs;

    if (-l $filename) {
        $filename = "$filename -> " . readlink "$filename";
    }

    print("0|$filename|$inode|$mode_as_string|$uid|$gid|$size|$atime|$mtime|$ctime|0\n");
}
