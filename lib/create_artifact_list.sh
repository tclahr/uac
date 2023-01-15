#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2001,SC2006

###############################################################################
# Create artifact list to be collected based on the artifact list provided in
# the command line.
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
create_artifact_list()
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
          >"${TEMP_DATA_DIR}/.artifacts.exclude.tmp"
      
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