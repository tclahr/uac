#!/bin/sh

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

###############################################################################
# Returns a copy of the string with leading and trailing white space characters
# removed.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: string
# Outputs:
#   Write new string to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
lrstrip()
{
  lr_string="${1:-}"

  echo "${lr_string}" | sed -e 's:^  *::' -e 's:  *$::'
}