#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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