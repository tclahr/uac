#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Run command.
# Arguments:
#   string command: command (including arguments)
#   boolean log_stderr: send stderr to uac.log (optional) (default: true)
# Returns:
#   integer: command exit code
_run_command()
{
  __rc_command="${1:-}"
  __rc_log_stderr="${2:-true}"
  
  if [ -z "${__rc_command}" ]; then
    _log_msg ERR "_run_command: empty command parameter"
    return 1
  fi

  if [ ! -d "${__UAC_TEMP_DATA_DIR}" ]; then
    return 1
  fi

  __rc_stderr_file="/dev/null"
  if ${__rc_log_stderr}; then
    __rc_stderr_file="${__UAC_TEMP_DATA_DIR}/run_command.stderr.txt"
  fi

  eval "${__rc_command}" \
    2>"${__rc_stderr_file}"
  __rc_exit_code="$?"

  __rc_stderr=""
  if [ -s "${__UAC_TEMP_DATA_DIR}/run_command.stderr.txt" ] && ${__rc_log_stderr}; then
    __rc_stderr=`awk 'BEGIN {ORS="/n"} {print $0}' "${__UAC_TEMP_DATA_DIR}/run_command.stderr.txt" | sed -e 's|/n$||' 2>/dev/null`
    __rc_stderr=" 2> ${__rc_stderr}"
  fi

  __rc_command=`echo "${__rc_command}" | awk 'BEGIN {ORS="/n"} {print $0}' | sed -e 's|  *| |g' -e 's|/n$||' 2>/dev/null`
  _log_msg CMD "${__rc_command}${__rc_stderr}"

  return "${__rc_exit_code}"
 
}