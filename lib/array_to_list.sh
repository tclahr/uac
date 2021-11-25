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
# Convert yaml array to comma separated list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: array
# Outputs:
#   Write comma separated list to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
array_to_list()
{
  at_array="${1:-}"

  # remove starting [ and ending ]
  # replace escaped comma (\,) by #_COMMA_# string
  # replace escaped double quote (\") by #_DOUBLE_QUOTE_# string
  # remove double quotes
  # remove white spaces between elements
  # remove empty elements
  # replace #_COMMA_# string by comma
  # replace #_DOUBLE_QUOTE_# string by \"
  echo "${at_array}" \
    | sed -e 's:^ *\[::' \
          -e 's:\] *$::' \
          -e 's:\\,:#_COMMA_#:g' \
          -e 's:\\":#_DOUBLE_QUOTE_#:g' \
          -e 's:"::g'  \
          -e 's: *,:,:g' \
          -e 's:, *:,:g' \
          -e 's:,,*:,:g' \
          -e 's:^,::g' \
          -e 's:,$::g' \
          -e 's:#_COMMA_#:\\,:g' \
          -e 's:#_DOUBLE_QUOTE_#:\\":g'

}