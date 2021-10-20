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
# Parse profile file.
# Globals:
#   TEMP_DATA_DIR
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: profile file
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
parse_profile_file()
{
  pp_profile_file="${1:-}"

  # return if profile file does not exist
  if [ ! -f "${pp_profile_file}" ]; then
    printf %b "parse_profile_file: no such file or directory: \
'${pp_profile_file}'\n" >&2
    return 2
  fi

  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # grep lines starting with "  - !"
  # remove "  - !" from the beginning of the line
  # remove duplicates
  sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${pp_profile_file}" 2>/dev/null \
    | grep -E " +- +!" \
    | sed -e 's: *- *!::g' 2>/dev/null \
    | while read pp_line || [ -n "${pp_line}" ]; do
        find "${UAC_DIR}"/artifacts/${pp_line} -type f -print \
          | sed -e "s:${UAC_DIR}/artifacts/::g" 2>/dev/null
      done \
      | awk '!a[$0]++' 2>/dev/null \
        >"${TEMP_DATA_DIR}/.artifacts.exclude.tmp"

  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # grep lines starting with "  - "
  # remove "  - " from the beginning of the line
  # remove duplicates
  sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${pp_profile_file}" 2>/dev/null \
    | grep -E " +- +[^!]" \
    | sed -e 's: *- *::g' 2>/dev/null \
    | while read pp_line || [ -n "${pp_line}" ]; do
        find "${UAC_DIR}"/artifacts/${pp_line} -type f -print \
          | sed -e "s:^${UAC_DIR}/artifacts/::g" 2>/dev/null
      done \
      | awk '!a[$0]++' 2>/dev/null \
        >"${TEMP_DATA_DIR}/.artifacts.include.tmp"

  # remove common lines between include and exclude
  if [ -s "${TEMP_DATA_DIR}/.artifacts.exclude.tmp" ]; then
    awk 'NR==FNR {a[$0]=1; next} !a[$0]' \
      "${TEMP_DATA_DIR}/.artifacts.exclude.tmp" \
      "${TEMP_DATA_DIR}/.artifacts.include.tmp" \
      >"${TEMP_DATA_DIR}/.artifacts.tmp"
  else
    mv "${TEMP_DATA_DIR}/.artifacts.include.tmp" "${TEMP_DATA_DIR}/.artifacts.tmp"
  fi

}