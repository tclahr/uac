#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
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