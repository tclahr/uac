#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print error message.
# Arguments:
#   string message: error message
# Returns:
#   none
_error_msg()
{
  __em_message="${1:-Unexpected error}"
  printf "%b" "${__em_message}\n" >&2
}