#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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