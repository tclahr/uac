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
# Check if an element exists in a comma separated list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: element
#   $2: comma separated list
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_element_in_list()
{
  ie_element="${1:-}"
  ie_list="${2:-}"

  # return if element is empty
  if [ -z "${ie_element}" ]; then
    printf %b "is_element_in_list: missing required argument: 'element'\n" >&2
    return 2
  fi

  # return if list is empty
  if [ -z "${ie_list}" ]; then
    printf %b "is_element_in_list: missing required argument: 'list'\n" >&2
    return 3
  fi

  # trim leading and trailing white space
  # remove double and single quotes
  ie_element=`echo "${ie_element}" \
    | sed -e 's:^  *::' \
          -e 's:  *$::' \
          -e 's:"::g' \
          -e "s:'::g"`

  # trim leading and trailing white space
  # remove any white spaces between comma and each item
  # trim leading and trailing comma
  # remove double and single quotes
  echo "${ie_list}" \
    | sed -e 's:^  *::' \
          -e 's:  *$::' \
          -e 's: *,:,:g' \
          -e 's:, *:,:g' \
          -e 's:^,*::' \
          -e 's:,*$::' \
          -e 's:"::g' \
          -e "s:'::g" \
    | awk -v ie_element="${ie_element}" 'BEGIN { FS=","; } {
        for(N = 1; N <= NF; N ++) {
          if (ie_element == $N) {
            exit 0; # true
          }
        }
        exit 1; # false
      }'

}