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
# Create a comma separated list of artifacts based on a profile file.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: profile file
# Outputs:
#   Comma separated list of artifacts.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
profile_file_to_artifact_list()
{
  pl_profile_file="${1:-}"

  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # grep lines starting with "  - "
  # remove "  - " from the beginning of the line
  # shellcheck disable=SC2162
  sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${pl_profile_file}" 2>/dev/null \
    | grep -E " +- +" \
    | sed -e 's: *- *::g' 2>/dev/null \
    | while read pl_line || [ -n "${pl_line}" ]; do
        printf %b "${pl_line},"
      done
      
}