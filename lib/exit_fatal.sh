#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Perform exit of the program (with exit code 1).
# Arguments:
#   string message: error message
# Returns:
#   none
_exit_fatal()
{
  __ef_message="${1:-}"
  if [ -n "${__ef_message}" ]; then
    printf "%b" "${__ef_message}\n" >&2
  fi
  exit 1
}