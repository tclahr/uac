#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test whether parameter is an integer or not.
# removed.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: number
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_integer()
{
  ii_number="${1:-}"

  # return if number is empty
  if [ -z "${ii_number}" ]; then
    printf %b "is_integer: missing required argument: 'number'\n" >&2
    return 22
  fi

  # shellcheck disable=SC2003
  expr 1 + "${ii_number}" >/dev/null

}