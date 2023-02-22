#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Get absolute directory path.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: path
# Outputs:
#   Write directory path to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_absolute_directory_path()
{
  ga_directory="${1:-}"

  # shellcheck disable=SC2005,SC2006
  echo "`cd "${ga_directory}" && pwd`"

}