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
# Copy files and directories.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: file containing the list of files to be copied
#   $2: destination directory
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
copy_data()
{
  cp_source_file="${1:-}"
  cp_destination="${2:-}"

  # exit if source file does not exist
  if [ ! -f "${cp_source_file}" ]; then
    printf %b "copy data: no such file or directory: '${cp_source_file}'\n" >&2
    return 2
  fi

  # shellcheck disable=SC2162
  while read cp_line || [ -n "${cp_line}" ]; do
    cp_dirname=`dirname "${cp_line}"`
    if [ -n "${cp_dirname}" ] && [ -d "${cp_dirname}" ]; then
      mkdir -p "${cp_destination}/${cp_dirname}"
      cp -r "${cp_line}" "${cp_destination}/${cp_dirname}"
    fi
  done <"${cp_source_file}"

}