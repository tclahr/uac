#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Check whether output file or directory exists.
# Arguments:
#   string output_base_name: full path to the output file
# Returns:
#   boolean: true on success
#            false on fail
_output_exists()
{
  __of_output_file="${1:-}"

  if [ -d "${__of_output_file}" ]; then
    _error_msg "Failed to create output directory '${__of_output_file}': Directory exists."
    return 0
  elif [ -f "${__of_output_file}" ]; then
    _error_msg "Failed to create output file '${__of_output_file}': File exists."
    return 0
  fi

  return 1

}
