#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Convert an array to a sanitized pipe-separated values string.
# Arguments:
#   string array: array of values
# Returns:
#   string: sanitized pipe-separated values string
_array_to_psv()
{
  # remove leading and trailing brackets [ ]
  # trim leading and trailing white space
  # replace escaped comma (\,) by #_COMMA_# string
  # remove white spaces between items
  # remove empty items
  # replace comma by pipe
  # replace #_COMMA_# string by comma
  # remove all single and double quotes
  sed -e 's|^ *\[||' \
      -e 's|\] *$||' \
      -e 's|^  *||' \
      -e 's|  *$||' \
      -e 's|\\,|#_COMMA_#|g' \
      -e 's| *,|,|g' \
      -e 's|, *|,|g' \
      -e 's|^,*||' \
      -e 's|,*$||' \
      -e 's|,,*|,|g' \
      -e 's:,:|:g' \
      -e 's|#_COMMA_#|,|g' \
      -e 's|"||g' \
      -e "s|'||g"

}