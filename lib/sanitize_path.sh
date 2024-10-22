#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Sanitize path.
# Arguments:
#   string path: path
# Returns:
#   string: sanitized path
_sanitize_path()
{
  __sp_path="${1:-}"

  # remove leading and trailing spaces
  # replace consecutive slashes by one slash
  # replace .. by .
  # remove trailing slash
  # add slash if empty path
  echo "${__sp_path}" \
    | sed -e 's|^  *||' \
          -e 's|  *$||' \
          -e 's|\.\.|\.|g' \
          -e 's|//*|/|g' \
          -e 's|/$||' \
          -e 's|^$|/|'

}
