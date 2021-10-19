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
# Return true if string does not match pattern.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: pattern
#   $2: string
#   $3: true   ignore case
#       false  case sensitive (default)
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
regex_not_match()
{
  rn_pattern="${1:-}"
  rn_string="${2:-}"
  rn_ignore_case="${3:-false}"

  # return if pattern is empty
  if [ -z "${rn_pattern}" ]; then
    printf %b "regex_not_match: missing required argument: 'pattern'\n" >&2
    return 2
  fi

  # return if string is empty
  if [ -z "${rn_string}" ]; then
    printf %b "regex_not_match: missing required argument: 'string'\n" >&2
    return 3
  fi

  if ${rn_ignore_case}; then
    echo "${rn_string}" | grep -v -q -E -i "${rn_pattern}"
  else
    echo "${rn_string}" | grep -v -q -E "${rn_pattern}"
  fi

}