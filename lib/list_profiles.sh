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

# shellcheck disable=SC2006

###############################################################################
# List available profiles.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write available profiles to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
list_profiles()
{
  printf %b "--------------------------------------------------------------------------------\n"
  printf %b "Profile Name : Description\n"
  printf %b "--------------------------------------------------------------------------------\n"
  for lp_file in "${UAC_DIR}"/profiles/*.yaml; do
    lp_name=`grep -E "name: " <"${lp_file}" | sed -e 's/name: //'`
    lp_description=`grep -E "description: " <"${lp_file}" | sed -e 's/description: //'`
    printf %b "${lp_name} : ${lp_description}\n"
  done

}