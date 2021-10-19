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
# Clean up and exit.
# Globals:
#   TEMP_DATA_DIR
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write exit message to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
terminate()
{
  printf %b "\nCaught signal! Cleaning up and quitting...\n"
  if [ -d "${TEMP_DATA_DIR}" ]; then
    rm -rf "${TEMP_DATA_DIR}" >/dev/null 2>/dev/null
    if [ -d "${TEMP_DATA_DIR}" ]; then
        printf %b "Cannot remove temporary directory '${TEMP_DATA_DIR}'\n"
    fi
  fi
  exit 130

}