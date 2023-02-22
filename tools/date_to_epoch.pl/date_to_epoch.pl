#!/usr/bin/perl
# SPDX-License-Identifier: Apache-2.0

use strict;
use Time::Local;

sub usage {
    print("Usage: date_to_epoch.pl YYYY-MM-DD\n");
    print("\n");
    exit 1;
}

my $date = $ARGV[0] || usage();
$date =~ /^((19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/ || die ("Invalid date: $date\n");
my $day = int($4);
my $month = int($3) - 1;
my $year = int($1) - 1900;
print(timelocal(0, 0, 0, $day, $month, $year));