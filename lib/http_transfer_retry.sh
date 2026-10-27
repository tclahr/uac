#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2003

# Run a command, retrying it on failure.
# The wait time between attempts increases linearly (delay * attempt).
# Arguments:
#   integer max_attempts: maximum number of attempts
#   integer delay: base wait time in seconds between attempts
#   string command: command to be run
#   string arguments: command arguments (optional)
# Returns:
#   boolean: true on success
#            false on fail
_http_transfer_retry()
{
  __htr_max_attempts="${1:-3}"
  __htr_delay="${2:-10}"
  shift 2

  __htr_attempt=1
  while true; do
    "$@" && return 0
    if [ "${__htr_attempt}" -ge "${__htr_max_attempts}" ]; then
      return 1
    fi
    __htr_wait=`expr "${__htr_delay}" \* "${__htr_attempt}"`
    __htr_attempt=`expr "${__htr_attempt}" + 1`
    _error_msg "Transfer failed. Retrying in ${__htr_wait} seconds (attempt ${__htr_attempt} of ${__htr_max_attempts})..."
    sleep "${__htr_wait}"
  done
}
