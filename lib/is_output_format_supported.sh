#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Check whether output format is support.
# Arguments:
#   string output_format: output format
# Returns:
#   string: output extension
_is_output_format_supported()
{
  __if_output_format="${1:-}"
  __if_output_password="${2:-}"
  __if_output_extension=""

  # check if output format is supported
  case "${__if_output_format}" in
    "none")
      __if_output_extension=""
      ;;
    "tar")
      if command_exists "tar"; then
        __if_output_extension="tar"
        if command_exists "gzip"; then
          __if_output_extension="tar.gz"
        fi
      else
        _error_msg "Failed to create output file: 'tar' tool not found. Please choose a different output format."
        return 1
      fi
      ;;
    "zip")
      if command_exists "zip" && zip --version >/dev/null 2>/dev/null; then
        __if_output_extension="zip"
        if [ -n "${__if_output_password}" ]; then
          if zip --password infected - "${__UAC_DIR}/uac" >/dev/null 2>/dev/null; then
            true
          else
            _error_msg "Failed to create password-protected zip file: 'zip' tool does not support such feature."
            return 1
          fi
        fi  
      else
        _error_msg "Failed to create output file: 'zip' tool not found. Please choose a different output format."
        return 1
      fi
      ;;
    *)
      _error_msg "Unsupported output format: '${__if_output_format}'."
      return 1
      ;;
  esac

  echo "${__if_output_extension}"

}
