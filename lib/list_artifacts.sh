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
# List available artifacts.
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
list_artifacts()
{
  printf %b "--------------------------------------------------------------------------------\n"
  printf %b "Artifacts\n"
  printf %b "--------------------------------------------------------------------------------\n"

  find "${UAC_DIR}"/artifacts/* -name "*.yaml" -print \
    | sed -e "s:^${UAC_DIR}/artifacts/::g" 2>/dev/null

}