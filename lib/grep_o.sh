#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print only the matching part of a string. This function mimics 'grep -o'.
# Arguments:
#   string pattern: pattern matching
# Returns:
#   string: corresponding match
_grep_o()
{
  __go_pattern="${1:-}"
  sed -n -e 's|.*\('"${__go_pattern}"'\).*|\1|p'
}
