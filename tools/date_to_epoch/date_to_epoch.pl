#!/usr/bin/perl

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
