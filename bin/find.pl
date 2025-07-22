#!/usr/bin/env perl
# SPDX-License-Identifier: Apache-2.0

use strict;
use File::Find;
use Cwd ();
use POSIX qw(getpwuid getgrgid);

sub usage {
    print <<"USAGE";
find.pl version 1.0.0

Usage: find.pl [-L] starting-point [expression]

Search for files in a directory hierarchy.

OPTIONS
    -L
        Follow symbolic links.

EXPRESSION
    The part of the command line after the list of starting points is the expression.
    This is a kind of query specification describing how we match files and what we do with the files that were matched. An expression is composed of a sequence of things:

    Tests  Tests return a true or false value, usually on the basis of some property of a file we are considering.  The -empty test for example is  true  only
        when the current file is empty.

    Actions
        Actions have side effects (such as printing something on the standard output) and return either true or false, usually based on whether or not they
        are successful.  The -print action for example prints the name of the current file on the standard output.

    Global options
        Global options affect the operation of tests and actions specified on any part of the command line.  Global options always return true.  The -depth
        option for example makes find traverse the file system in a depth-first order.

    Operators
        Operators join together the other items within the expression.  They include for example -o (meaning logical OR)  and  -a  (meaning  logical  AND).
        Where an operator is missing, -a is assumed.

GLOBAL OPTIONS
    -maxdepth LEVELS
        Descend at most levels (a non-negative integer) levels of directories below the starting-point.

TESTS
    Predicates which take a numeric argument N can come in three forms:
        N is prefixed with a +: match values greater than N
        N is prefixed with a -: match values less than N
        N is not prefixed with either + or -: match only values equal to N

    -atime N
        File was last accessed N*24 hours ago. When find figures out how many 24-hour periods ago the file was
        last accessed, any fractional part is ignored, so to match -atime +1, a file has to have been accessed
        at least two days ago.
    
    -ctime N
        File's status was last changed N*24 hours ago. See the comments for -atime to understand how rounding
        affects the interpretation of file status change times.

    -iname PATTERN
        Like -name, but the match is case insensitive.

    -ipath PATTERN
        Like -path, but the match is case insensitive.

    -mtime N
        File's data was last modified N*24 hours ago. See the comments for -atime to understand how rounding
        affects the interpretation of file status change times.

    -name PATTERN
        File name matches specified glob wildcard pattern (just as with using find).

    -nogroup
        No group corresponds to file's numeric group ID.

    -nouser
        No user corresponds to file's numeric user ID.

    -path PATTERN
        File path matches specified glob wildcard pattern (just as with using find).

    -perm MODE
        File's permission bits are exactly mode (octal). Symbolic mode is not supported.

    -perm -MODE
        All of the permission bits mode (octal) are set for the file. Symbolic mode is not supported.

    -perm /MODE
        Any of the permission bits mode are set for the file. Symbolic mode is not supported.

    -size N[ckMG]
        File uses N units of space. The following suffixes can be used:

        c   for bytes (this is the default if no suffix is used)
        k   for kilobytes (kB, units of 1024 bytes)
        M   for megabyte (MB, units of 1024 * 1024 bytes)
        G   for gigabyte (GB, units of 1024 * 1024 * 1024 bytes)

    -type X
        File is of type X:

        b   block special
        c   character special
        d   directory
        f   regular file
        l   symbolic link
        p   named pipe (FIFO)
        s   socket

ACTIONS    
    -exec COMMAND ;
        Execute COMMAND; Any occurrence of {} in COMMAND will be replaced by the the path of the current file.
        The ; must be passed as a distinct argument, so it may need to be surrounded by whitespace and/or quoted
        from interpretation by the shell using a backslash (just as with using find(1)).

    -print
        Always evaluates to the value True. Print the full file name on the standard output, followed by a newline.

    -print0
        Always evaluates to the value True. Print the full file name on the standard output, followed by a null character.

    -prune
        Always evaluates to the value True. If the file is a directory, do not descend into it.

OPERATORS
    \\( expression \\)
        Evaluates to the value True if the expression in parentheses is true.
        Since parentheses are special to the shell, you will need to use backslashes \\( \\).

    !   not
    -a  and
    -o  or
USAGE
}

sub fileglob_to_regex($) {
    my $retval = shift;
    $retval =~ s#([./^\$()+])#\\$1#g;
    $retval =~ s#\*#.*#g;
    $retval =~ s#\?#.#g;
    "^$retval\\z";
}

my $cwd = Cwd::cwd();
sub run_exec ($@) {
    my @command = @_;
    for my $word (@command)
        { $word =~ s#{}#$File::Find::name#g }
    chdir $cwd;
    system @command;
    chdir $File::Find::dir;
    return !$?;
}

# print file stats when "-exec stat_pl {}" is used
sub stat_pl {
    my $filename = shift;

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

    my $mode_as_string = join '', $ftype, @permstrs;

    if (-l $filename) {
        $filename = "$filename -> " . readlink "$filename";
    }

    print("0|$filename|$inode|$mode_as_string|$uid|$gid|$size|$atime|$mtime|$ctime|0\n");
}

my @starting_points = ();
my $wanted = "my (\$dev,\$inode,\$mode,\$nlink,\$uid,\$gid,\$rdev,\$size,\$atime,\$mtime,\$ctime,\$blksize,\$blocks); ((\$dev,\$inode,\$mode,\$nlink,\$uid,\$gid,\$rdev,\$size,\$atime,\$mtime,\$ctime,\$blksize,\$blocks) = lstat(\$File::Find::name)) && ";
my $depth = 0;
my $maxdepth = -1;
my $print_needed = 1;
my $follow_fast = 0;

# print usage if no arguments are provided
if (@ARGV < 1) {
    usage();
    exit 1;
}

# get starting-points only
while (@ARGV) {
    my $arg_option = shift;
    if ($arg_option eq "-L") {
        $follow_fast = 1;
    } elsif (($arg_option !~ /^-/) and ($arg_option ne "!") and ($arg_option ne "(") and ($arg_option ne ")")) {
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
    } elsif ($arg_option eq "-nogroup") {
        $wanted .= "(!getgrgid(\$gid))";
    } elsif ($arg_option eq "-nouser") {
        $wanted .= "(!getpwuid(\$uid))";
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
        $wanted .= "print(\"\$File::Find::name\0\");";
        $print_needed = 0;
    } elsif ($arg_option eq "-exec") {
        my @cmd = ();
        while (@ARGV && $ARGV[0] ne ';')
            { push(@cmd, shift) }
        shift;
        if ($cmd[0] eq "stat_pl" && $cmd[1] eq "{}") {
            $wanted .= "stat_pl(\"\$File::Find::name\")";
        } else {
            for (@cmd)
                { s/'/\\'/g }
            { local $" = "','"; $wanted .= "run_exec('@cmd')"; }
        }
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
    if ($wanted !~ /&&\s*$/) {
        $wanted .= "&& "
    }
    $wanted .= "print(\"\$File::Find::name\\n\");";
}

for my $starting_point (@starting_points) {
    if (-e $starting_point) {
        find({
            preprocess => sub {
                $depth += 1;
                return if ($depth > $maxdepth) and ($maxdepth >= 0);
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
            follow_fast => $follow_fast,
            follow_skip => 2
        }, $starting_point);
    } else {
        print STDERR "find.pl: no such file or directory '$starting_point'\n";
    }
}
