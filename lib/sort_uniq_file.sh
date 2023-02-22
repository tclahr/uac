#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Sort and uniq files.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: file
# Outputs:
#   Sorted and unique file.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sort_uniq_file()
{
  su_file="${1:-}"

  # sort and uniq file, and store data into a temporary file
  if eval "sort -u \"${su_file}\"" >"${su_file}.sort_uniq_file.tmp"; then
    # remove original file
    if eval "rm -f \"${su_file}\""; then
      # rename temporary to original file
      mv "${su_file}.sort_uniq_file.tmp" "${su_file}"
    fi
  else
    printf %b "sort_uniq_file: no such file or directory: '${su_file}'\n" >&2
    return 2
  fi

}