#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Convert yaml array to comma separated list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: array
# Outputs:
#   Write comma separated list to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
array_to_list()
{
  at_array="${1:-}"

  # remove starting [ and ending ]
  # replace escaped comma (\,) by #_COMMA_# string
  # replace escaped double quote (\") by #_DOUBLE_QUOTE_# string
  # remove double quotes
  # remove white spaces between elements
  # remove empty elements
  # replace #_COMMA_# string by comma
  # replace #_DOUBLE_QUOTE_# string by \"
  echo "${at_array}" \
    | sed -e 's:^ *\[::' \
          -e 's:\] *$::' \
          -e 's:\\,:#_COMMA_#:g' \
          -e 's:\\":#_DOUBLE_QUOTE_#:g' \
          -e 's:"::g'  \
          -e 's: *,:,:g' \
          -e 's:, *:,:g' \
          -e 's:,,*:,:g' \
          -e 's:^,::g' \
          -e 's:,$::g' \
          -e 's:#_COMMA_#:\\,:g' \
          -e 's:#_DOUBLE_QUOTE_#:\\":g'

}