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
# Test whether parameter is an integer or not.
# removed.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: number
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_integer()
{
  ii_number="${1:-}"

  # return if number is empty
  if [ -z "${ii_number}" ]; then
    printf %b "is_integer: missing required argument: 'number'\n" >&2
    return 22
  fi

  # shellcheck disable=SC2003
  expr 1 + "${ii_number}" >/dev/null

}