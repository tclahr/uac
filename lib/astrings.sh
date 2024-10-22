#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print the sequences of printable characters in files.
# This is a shell implementation of the strings command.
# Arguments:
#   string file: input file path
# Returns:
#   string: printable characters
astrings()
{
  __as_file="${1:-}"

  if command_exists "tr"; then
    tr '\0' '\n' <"${__as_file}" | sed -n 's/\([[:print:]]\{4,\}\)/\n\1\n/gp' | sed -n '/[[:print:]]\{4,\}/p'
  elif command_exists "perl"; then
    perl -pe 's/\0/\n/g' "${__as_file}" | sed -n 's/\([[:print:]]\{4,\}\)/\n\1\n/gp' | sed -n '/[[:print:]]\{4,\}/p'
  else
    sed 's/\x00/\n/g' "${__as_file}" | sed -n 's/\([[:print:]]\{4,\}\)/\n\1\n/gp' | sed -n '/[[:print:]]\{4,\}/p'
  fi

}