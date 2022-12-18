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
# Parse artifact list.
# Globals:
#   TEMP_DATA_DIR
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: comma separated list of artifacts
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
parse_artifact_list()
{
  pr_artifact_list="${1:-}"

  OIFS="${IFS}"
  IFS=","
  for pr_artifact in ${pr_artifact_list}; do
    if eval "echo \"${pr_artifact}\" | grep -q -E \"^!\""; then
      pr_artifact=`echo "${pr_artifact}" | sed -e 's:^!::'`
      # shellcheck disable=SC2086
      find "${UAC_DIR}"/artifacts/${pr_artifact} -name "*.yaml" -print \
        | sed -e "s:${UAC_DIR}/artifacts/::g" \
          >>"${TEMP_DATA_DIR}/.artifacts.exclude.tmp"
      
      # remove common lines between include and exclude
      awk 'NR==FNR {a[$0]=1; next} !a[$0]' \
        "${TEMP_DATA_DIR}/.artifacts.exclude.tmp" \
        "${TEMP_DATA_DIR}/.artifacts.include.tmp" \
        >"${TEMP_DATA_DIR}/.artifacts.diff.tmp"
      cp "${TEMP_DATA_DIR}/.artifacts.diff.tmp" "${TEMP_DATA_DIR}/.artifacts.include.tmp"

    else
      # shellcheck disable=SC2086
      find "${UAC_DIR}"/artifacts/${pr_artifact} -name "*.yaml" -print \
        | sed -e "s:${UAC_DIR}/artifacts/::g" \
          >>"${TEMP_DATA_DIR}/.artifacts.include.tmp"
    fi
  done
  IFS="${OIFS}"

  # remove duplicates
  awk '!a[$0]++' <"${TEMP_DATA_DIR}/.artifacts.include.tmp"

}