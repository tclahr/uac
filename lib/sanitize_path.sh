#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Sanitize path.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: path
# Outputs:
#   Write sanitized path to stdout.
#   Write / to stdout if path is empty.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sanitize_path()
{
  sp_path="${1:-}"

  # remove leading spaces
  # remove trailing spaces
  # replace consecutive slashes by one slash
  # remove trailing slash
  echo "${sp_path}" \
    | sed -e 's:^  *::' -e 's:  *$::' -e 's://*:/:g' -e 's:/$::' -e 's:^$:/:'
  
}