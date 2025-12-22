#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Archive and compress files and directories.
# Arguments:
#   string from_file: file containing the list of files to be archived and compressed
#   string destination_file: output file
# Returns:
#   none
_tar_gz_data()
{
  __tg_from_file="${1:-}"
  __tg_destination_file="${2:-}"

  if [ ! -f "${__tg_from_file}" ]; then
    _error_msg "File containing the list of files to be archived '${__tg_from_file}' does not exist."
    return 1
  fi

  __tg_tar_command="tar -T \"${__tg_from_file}\" -cf - | gzip >\"${__tg_destination_file}\""
  case "${__UAC_OPERATING_SYSTEM}" in
    "aix")
      __tg_tar_command="tar -L \"${__tg_from_file}\" -cf - | gzip >\"${__tg_destination_file}\""
      ;;
    "freebsd"|"netbsd"|"netscaler"|"openbsd")
      __tg_tar_command="tar -I \"${__tg_from_file}\" -cf - | gzip >\"${__tg_destination_file}\""
      ;;
    "esxi"|"haiku"|"linux")
      if ${__UAC_TOOL_TAR_NO_FROM_FILE_SUPPORT}; then
        __tg_tar_command="tar -cf - * | gzip >\"${__tg_destination_file}\""
      fi
      ;;
    "macos")
      true
      ;;
    "solaris")
      __tg_tar_command="tar -cf - -I \"${__tg_from_file}\" | gzip >\"${__tg_destination_file}\""
      ;;
  esac

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__tg_tar_command}"
  eval "${__tg_tar_command}" \
    >>"${__UAC_TEMP_DATA_DIR}/tar_gz_data.stdout.txt" \
    2>>"${__UAC_TEMP_DATA_DIR}/tar_gz_data.stderr.txt"

}
