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
# Sort and uniq files.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: file
# Outputs:
#   Sorted and unique file.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sort_uniq_file()
{
  su_file="${1:-}"

  # sort and uniq file, and store data into a temporary file
  if eval "sort -u \"${su_file}\"" >"${su_file}.sort_uniq_file.tmp"; then
    # remove original file
    if eval "rm -f \"${su_file}\""; then
      # rename temporary to original file
      mv "${su_file}.sort_uniq_file.tmp" "${su_file}"
    fi
  else
    printf %b "sort_uniq_file: no such file or directory: '${su_file}'\n" >&2
    return 2
  fi

}