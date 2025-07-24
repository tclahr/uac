#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Create temporary files and directories used during execution.
# Arguments:
#   none
# Returns:
#   none
_init_temp_data_dir()
{
  # remove any existing (old) collected data
  # grep is just a protection measure to make sure UAC is removing the proper directory
  if [ -d "${__UAC_TEMP_DATA_DIR}" ] && printf "%s" "${__UAC_TEMP_DATA_DIR}" | grep -q "uac-data.tmp"; then
    rm -rf "${__UAC_TEMP_DATA_DIR}" >/dev/null 2>/dev/null \
      || { _error_msg "Cannot remove old temporary directory from previous collection: '${__UAC_TEMP_DATA_DIR}'"; return 1; }
  fi

  # create temporary directory
  mkdir -p "${__UAC_TEMP_DATA_DIR}" >/dev/null 2>/dev/null \
    || { _error_msg "Cannot create temporary directory: '${__UAC_TEMP_DATA_DIR}'"; return 1; }
  # directory where collected data that goes to the output file will be temporarily stored
  mkdir -p "${__UAC_TEMP_DATA_DIR}/collected" >/dev/null 2>/dev/null
  # directory where collected data using %temp_directory% will be temporarily stored
  mkdir -p "${__UAC_TEMP_DATA_DIR}/tmp" >/dev/null 2>/dev/null

  touch "${__UAC_TEMP_DATA_DIR}/file_collector.tmp"
  touch "${__UAC_TEMP_DATA_DIR}/${__UAC_LOG_FILE}"
  
}