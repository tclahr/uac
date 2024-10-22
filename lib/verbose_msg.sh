#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print verbose message.
# Arguments:
#   string message: message
# Returns:
#   none
_verbose_msg()
{
  __vm_message="${1:-}"

  ${__UAC_VERBOSE_MODE} && printf "%s\n" "${__vm_message}"
}