#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Test whether all characters in the parameter are digits and there is 
# at least one character.
# Arguments:
#   integer number: input to be tested
# Returns:
#   boolean: true on success
#            false on fail
_is_digit()
{
  __id_number="${1:-empty}"

  if echo "${__id_number}" | grep -q -E "^-?[0-9]*$"; then
    return 0
  fi
  return 1
}