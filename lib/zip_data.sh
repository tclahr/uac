#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Zip files and directories.
# Arguments:
#   string from_file: file containing the list of files to be zipped
#   string destination_file: output file
#   string password: password (optional)
# Returns:
#   none
_zip_data()
{
  __zd_from_file="${1:-}"
  __zd_destination_file="${2:-}"
  __zd_password="${3:-}"

  if [ ! -f "${__zd_from_file}" ]; then
    _error_msg "File containing the list of files to be archived '${__zd_from_file}' does not exist."
    return 1
  fi

  __zd_zip_command="zip -6 -r \"${__zd_destination_file}\" -@ <\"${__zd_from_file}\""
  if [ -n "${__zd_password}" ]; then
    __zd_zip_command="zip -6 -r --password \"${__zd_password}\" \"${__zd_destination_file}\" -@ <\"${__zd_from_file}\""
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__zd_zip_command}"
  eval "${__zd_zip_command}" \
    >>"${__UAC_TEMP_DATA_DIR}/zip_data.stdout.txt" \
    2>>"${__UAC_TEMP_DATA_DIR}/zip_data.stderr.txt"

}