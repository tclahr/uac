#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Check if an element exists in a comma separated list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: element
#   $2: comma separated list
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_element_in_list()
{
  ie_element="${1:-}"
  ie_list="${2:-}"

  # return if element is empty
  if [ -z "${ie_element}" ]; then
    printf %b "is_element_in_list: missing required argument: 'element'\n" >&2
    return 22
  fi

  # return if list is empty
  if [ -z "${ie_list}" ]; then
    printf %b "is_element_in_list: missing required argument: 'list'\n" >&2
    return 22
  fi

  # trim leading and trailing white space
  # remove double and single quotes
  ie_element=`echo "${ie_element}" \
    | sed -e 's:^  *::' \
          -e 's:  *$::' \
          -e 's:"::g' \
          -e "s:'::g"`

  # trim leading and trailing white space
  # remove any white spaces between comma and each item
  # trim leading and trailing comma
  # remove double and single quotes
  echo "${ie_list}" \
    | sed -e 's:^  *::' \
          -e 's:  *$::' \
          -e 's: *,:,:g' \
          -e 's:, *:,:g' \
          -e 's:^,*::' \
          -e 's:,*$::' \
          -e 's:"::g' \
          -e "s:'::g" \
    | awk -v ie_element="${ie_element}" 'BEGIN { FS=","; } {
        for(N = 1; N <= NF; N ++) {
          if (ie_element == $N) {
            exit 0; # true
          }
        }
        exit 1; # false
      }'

}