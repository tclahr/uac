#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Archive files and directories.
# Arguments:
#   string from_file: file containing the list of files to be archived
#   string destination_file: output file
# Returns:
#   none
_tar_data()
{
  __td_from_file="${1:-}"
  __td_destination_file="${2:-}"

  if [ ! -f "${__td_from_file}" ]; then
    _error_msg "File containing the list of files to be archived '${__td_from_file}' does not exist."
    return 1
  fi

  __td_tar_command="tar -T \"${__td_from_file}\" -cf \"${__td_destination_file}\""
  case "${__UAC_OPERATING_SYSTEM}" in
    "aix")
      __td_tar_command="tar -L \"${__td_from_file}\" -cf \"${__td_destination_file}\""
      ;;
    "freebsd"|"netbsd"|"netscaler"|"openbsd")
      __td_tar_command="tar -I \"${__td_from_file}\" -cf \"${__td_destination_file}\""
      ;;
    "esxi"|"haiku"|"linux")
      if ${__UAC_TOOL_TAR_NO_FROM_FILE_SUPPORT}; then
        __tg_tar_command="tar -cf \"${__td_destination_file}\" *"
      fi
      ;;
    "macos")
      true
      ;;
    "solaris")
      __td_tar_command="tar -cf \"${__td_destination_file}\" -I \"${__td_from_file}\""
      ;;
  esac

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__td_tar_command}"
  eval "${__td_tar_command}" \
    >>"${__UAC_TEMP_DATA_DIR}/tar_data.stdout.txt" \
    2>>"${__UAC_TEMP_DATA_DIR}/tar_data.stderr.txt"

}
