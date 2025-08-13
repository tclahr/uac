#!/usr/bin/env perl
# SPDX-License-Identifier: Apache-2.0

sub usage {
    print <<"USAGE";
stat.pl version 1.0.0

Usage: stat.pl [OPTIONS] FILE...

Display file statistics in pipe-delimited format.

OPTIONS:
  -h, --help    Show this help message and exit

ARGUMENTS:
  FILE...       One or more files or directories to examine

OUTPUT FORMAT:
  Each line contains pipe-delimited fields:
  0|filename|inode|mode|uid|gid|size|atime|mtime|ctime|0

  Where:
    filename  - File path (with symlink target if applicable)
    inode     - Inode number
    mode      - File type and permissions (e.g., -rwxr-xr-x)
    uid       - User ID of owner
    gid       - Group ID of owner
    size      - File size in bytes
    atime     - Last access time (Unix timestamp)
    mtime     - Last modification time (Unix timestamp)
    ctime     - Last status change time (Unix timestamp)

EXAMPLES:
  stat.pl file.txt                 # Show stats for single file
  stat.pl /etc/passwd /bin/ls      # Show stats for multiple files
  stat.pl /usr/bin/*               # Show stats for all files in directory

NOTES:
  - Symbolic links show both the link path and target
  - Times are displayed as Unix timestamps
USAGE
}

sub get_file_stats {
    my $filename = shift;

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

        return $filename, $inode, $mode_as_string, $uid, $gid, $size, $atime, $mtime, $ctime;       
    }

}

# print usage if no arguments are provided
if (@ARGV < 1) {
    usage();
    exit 1;
}

if ($ARGV[0] eq '-h' || $ARGV[0] eq '--help') {
    usage();
    exit 0;
}

while (@ARGV) {
    my $file = shift;
    my ($filename, $inode, $mode_as_string, $uid, $gid, $size, $atime, $mtime, $ctime) = get_file_stats($file);
    print("0|$filename|$inode|$mode_as_string|$uid|$gid|$size|$atime|$mtime|$ctime|0\n");    
}
