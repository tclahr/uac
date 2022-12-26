#!/bin/sh

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
# Sanitize artifact list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: artifact list
# Outputs:
#   Write sanitized artifact list to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sanitize_artifact_list()
{
  sa_artifact_list="${1:-}"

  # remove ../
  # remove ./
  # replace !/ by !
  # remove 'artifacts/' directory
  # replace consecutive slashes by one slash
  # replace consecutive commas by one comma
  # remove leading and trailing comma
  echo "${sa_artifact_list}" \
    | sed -e 's:\.\./::g' \
          -e 's:\./::g' \
          -e 's:!/:!:g' \
          -e 's:artifacts/::g' \
          -e 's://*:/:g' \
          -e 's:,,*:,:g' \
          -e 's:^,::' \
          -e 's:,$::' \
      2>/dev/null

}