#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Sanitize filename.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: filename
# Outputs:
#   Write sanitized filename to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sanitize_filename()
{
  sf_filename="${1:-}"

  # remove leading spaces
  # remove trailing spaces
  # replace consecutive slashes by one slash
  # remove leading /
  # replace consecutive slashes by one underscore (_)
  echo "${sf_filename}" \
    | sed -e 's:^  *::' \
          -e 's:  *$::' \
          -e 's://*:/:g' \
          -e 's:^/::' \
          -e 's://*:_:g' \
      2>/dev/null

}