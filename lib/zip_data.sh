#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2162

###############################################################################
# Zip files and directories.
# Globals:
#   OPERATING_SYSTEM
#   TEMP_DATA_DIR
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: file containing the list of files to be archived and compressed
#   $2: destination file
#   $3: password (default: infected)
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
zip_data()
{
  zd_source_file="${1:-}"
  zd_destination_file="${2:-}"
  zd_password="${3:-infected}"

  # exit if source file does not exist
  if [ ! -f "${zd_source_file}" ]; then
    printf %b "zip data: no such file or directory: \
'${zd_source_file}'\n" >&2
    return 2
  fi

  zip -6 -r --password "${zd_password}" "${zd_destination_file}" -@ <"${zd_source_file}"
  
}