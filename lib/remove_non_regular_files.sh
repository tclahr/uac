#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Remove all entries that are non-regular files or symlinks.
# Arguments:
#   string file: input file
# Returns:
#   none
_remove_non_regular_files()
{
  __rn_file="${1:-}"

  if [ ! -f "${__rn_file}" ]; then
    _log_msg ERR "_remove_non_regular_files: no such file or directory '${__rn_file}'"
    return 1
  fi

  if [ ! -s "${__rn_file}" ]; then
    _log_msg DBG "_remove_non_regular_files: skipping empty file '${__rn_file}'"
    return 1
  fi

  __rn_command="sed 's|.|\\\\&|g' \"${__rn_file}\" | xargs find"

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__rn_command}"
  eval "${__rn_command}" \
    >"${__UAC_TEMP_DATA_DIR}/remove_non_regular_files_xargs.tmp" \
    2>>"${__UAC_TEMP_DATA_DIR}/remove_non_regular_files.stderr.txt"

  # shellcheck disable=SC2162
  while read __rn_line && [ -n "${__rn_line}" ]; do
    if [ -f "${__rn_line}" ] || [ -h "${__rn_line}" ]; then
      echo "${__rn_line}"
    fi
  done <"${__UAC_TEMP_DATA_DIR}/remove_non_regular_files_xargs.tmp" >"${__UAC_TEMP_DATA_DIR}/remove_non_regular_files.tmp" 

  sort -u <"${__UAC_TEMP_DATA_DIR}/remove_non_regular_files.tmp" 2>/dev/null | sed -e '/^$/d' 2>/dev/null >"${__rn_file}"

}
