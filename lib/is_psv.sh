#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Test whether string is a pipe separated value.
# Arguments:
#   string string: input to be tested
# Returns:
#   boolean: true on success
#            false on fail
_is_psv()
{
  __ip_string="${1:-}"

  if echo "${__ip_string}" | grep -q -E "\|"; then
    return 0
  fi
  return 1
}