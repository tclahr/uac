#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Perform a normal exit of the program (with exit code 0).
# Arguments:
#   string message: message
# Returns:
#   none
_exit_success()
{
  __es_message="${1:-}"
  if [ -n "${__es_message}" ]; then 
    printf "%b" "${__es_message}\n"
  fi
  exit 0
}