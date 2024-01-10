#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Check whether output file exists.
# Arguments:
#   string output_file: full path to output file
# Returns:
#   boolean: true on success
#            false on fail
output_file_exists()
{
  __of_output_file="${1:-}"

  if [ -d "${__of_output_file}" ]; then
    printf %b "uac: can't create directory '${__of_output_file}': Directory exists" >&2
    return 0
  elif [ -f "${__of_output_file}.tar.gz" ]; then
    printf %b "uac: can't create output file '${__of_output_file}.tar.gz': File exists" >&2
    return 0
  elif [ -f "${__of_output_file}.tar" ]; then
    printf %b "uac: can't create output file '${__of_output_file}.tar': File exists" >&2
    return 0
  fi
  return 1

}
