#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Remove temporary files and directories used during execution.
# Arguments:
#   none
# Returns:
#   none
_remove_temp_data_dir()
{
  if ${__UAC_DEBUG_MODE}; then
    printf "Temporary data directory not removed: '%s'.\n" "${__UAC_TEMP_DATA_DIR}"
  else
    if [ -d "${__UAC_TEMP_DATA_DIR}" ] && printf "%s" "${__UAC_TEMP_DATA_DIR}" | grep -q "uac-data.tmp"; then
      rm -rf "${__UAC_TEMP_DATA_DIR}" >/dev/null 2>/dev/null \
        || printf "Cannot remove temporary data directory: '%s'.\n" "${__UAC_TEMP_DATA_DIR}"
    fi
  fi

}