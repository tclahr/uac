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

# shellcheck disable=SC2001,SC2006

###############################################################################
# Check if artifact file exists.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: artifact file
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
artifact_file_exist()
{
  ae_artifact="${1:-}"

  # shellcheck disable=SC2086
  find "${UAC_DIR}"/artifacts/${ae_artifact} -name "*.yaml" \
    -print >/dev/null 2>/dev/null

}