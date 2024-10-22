#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Sort and uniq files.
# Arguments:
#   string file: input file
# Returns:
#   none
_sort_uniq_file()
{
  __su_file="${1:-}"

  if [ ! -f "${__su_file}" ]; then
    _log_msg ERR "_sort_uniq_file: no such file or directory '${__su_file}'"
    return 1
  fi

  # sort, uniq and remove empty lines
  sort -u <"${__su_file}" 2>/dev/null | sed -e '/^$/d' 2>/dev/null >"${__UAC_TEMP_DATA_DIR}/sort_uniq_file.tmp"
  cp "${__UAC_TEMP_DATA_DIR}/sort_uniq_file.tmp" "${__su_file}" 2>/dev/null

}
