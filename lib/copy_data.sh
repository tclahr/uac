#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Copy files and directories.
# Arguments:
#   string from_file: file containing the list of files to be copied
#   string destination_file: destination directory
# Returns:
#   none
_copy_data()
{
  __cd_from_file="${1:-}"
  __cd_destination_directory="${2:-}"
  
  if [ ! -f "${__cd_from_file}" ]; then
    _error_msg "_copy_data: no such file or directory: '${__cd_from_file}'"
    return 1
  fi

  # shellcheck disable=SC2162  
  while read __cd_line && [ -n "${__cd_line}" ]; do
    # shellcheck disable=SC2006
    __cd_dirname=`dirname "${__cd_line}" | sed -e "s|^${__UAC_MOUNT_POINT}|/|" -e "s|^${__UAC_TEMP_DATA_DIR}/collected|/|"`
    mkdir -p "${__cd_destination_directory}/${__cd_dirname}"
    cp -r "${__cd_line}" "${__cd_destination_directory}/${__cd_dirname}"
  done <"${__cd_from_file}"

}