#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Parse a profile to create a comma separated list of artifacts.
# Arguments:
#   string profile: full path to the profile file
# Returns:
#   string: comma separated list of artifacts
_parse_profile()
{
  __pp_profile="${1:-}"

  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # remove leading and trailing space characters
  # remove lines that do not start with a dash (-)
  # remove leading dash (-)
  # remove trailing comma
  sed -e 's|#.*$||g' \
      -e '/^ *$/d' \
      -e '/^$/d' \
      -e 's|^  *||' \
      -e 's|  *$||' \
      -e '/^[^-]/d' \
      -e 's|^- *||' <"${__pp_profile}" \
    | awk 'BEGIN {ORS=","} {print $0}' \
    | sed -e 's|,$||'

}