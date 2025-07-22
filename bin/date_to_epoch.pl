#!/usr/bin/env perl
# SPDX-License-Identifier: Apache-2.0

use strict;
use Time::Local;

sub usage {
    print <<"USAGE";
date_to_epoch.pl version 1.0.0

Usage: date_to_epoch.pl YYYY-MM-DD

Convert a date to Unix epoch timestamp.

Arguments:
  YYYY-MM-DD    Date in ISO format (e.g., 2023-12-25)

Examples:
  date_to_epoch.pl 2023-01-01
  date_to_epoch.pl 2024-12-25
USAGE
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

my $date = $ARGV[0];
$date =~ /^((19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$/ || die ("date_to_epoch.pl: invalid date '$date'\n");
my $day = int($4);
my $month = int($3) - 1;
my $year = int($1) - 1900;
print(timelocal(0, 0, 0, $day, $month, $year));
