#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Create a comma separated list of artifacts based on a profile file.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: profile file
# Outputs:
#   Comma separated list of artifacts.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
profile_file_to_artifact_list()
{
  pl_profile_file="${1:-}"

  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # grep lines starting with "  - "
  # remove "  - " from the beginning of the line
  # shellcheck disable=SC2162
  sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${pl_profile_file}" 2>/dev/null \
    | grep -E " +- +" \
    | sed -e 's: *- *::g' 2>/dev/null \
    | while read pl_line || [ -n "${pl_line}" ]; do
        printf %b "${pl_line},"
      done
      
}