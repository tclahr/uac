#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Returns a copy of the string with leading and trailing white space characters
# removed.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: string
# Outputs:
#   Write new string to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
lrstrip()
{
  lr_string="${1:-}"

  echo "${lr_string}" | sed -e 's:^  *::' -e 's:  *$::'
}