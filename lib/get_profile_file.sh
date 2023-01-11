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
# Get profile file based on the profile name.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: profile name
# Outputs:
#   Write profile file to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_profile_file()
{
  gp_profile_name="${1:-}"
  
  for gp_file in "${UAC_DIR}"/profiles/*.yaml; do
    if grep -q -E "name: +${gp_profile_name} *$" <"${gp_file}" 2>/dev/null; then
      echo "${gp_file}" | sed 's:.*/::' # strip directory from path
      break
    fi
  done

}