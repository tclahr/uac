#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Run command without reparsing a shell string.
# Arguments:
#   string command: executable name or path
#   boolean redirect_stderr_to_stdout: redirect stderr to stdout (optional) (default: false)
#   string args...: command arguments (optional)
# Returns:
#   integer: command exit code
_run_command()
{
  __rc_command="${1:-}"
  shift

  __rc_redirect_stderr_to_stdout=false
  if [ "${1:-}" = "true" ] || [ "${1:-}" = "false" ]; then
    __rc_redirect_stderr_to_stdout="${1}"
    shift
  fi

  _run_command_exec "${__rc_command}" "${__rc_redirect_stderr_to_stdout}" "$@"
}

# Run a shell fragment explicitly.
# Arguments:
#   string command: shell command (including arguments and shell syntax)
#   boolean redirect_stderr_to_stdout: redirect stderr to stdout (optional) (default: false)
# Returns:
#   integer: command exit code
_run_shell_command()
{
  __rc_command="${1:-}"
  __rc_redirect_stderr_to_stdout="${2:-false}"

  _run_command_eval "${__rc_command}" "${__rc_redirect_stderr_to_stdout}"
}

_run_command_exec()
{
  __rc_command="${1:-}"
  __rc_redirect_stderr_to_stdout="${2:-false}"
  shift 2
  __rc_stderr_file="${__UAC_TEMP_DATA_DIR}/run_command.stderr.txt"

  if [ -z "${__rc_command}" ]; then
    _log_msg ERR "_run_command: empty command parameter"
    return 1
  fi

  if [ ! -d "${__UAC_TEMP_DATA_DIR}" ]; then
    return 1
  fi

  if ${__rc_redirect_stderr_to_stdout}; then
    "${__rc_command}" "$@" 2>&1
    return $?
  fi

  "${__rc_command}" "$@" 2>"${__rc_stderr_file}"
  __rc_exit_code="$?"

  __rc_stderr=""
  if [ -s "${__rc_stderr_file}" ]; then
    __rc_stderr=`awk 'BEGIN {ORS="/n"} {print $0}' "${__rc_stderr_file}" | sed -e 's|/n$||' 2>/dev/null`
    __rc_stderr=" 2> ${__rc_stderr}"
  fi

  __rc_log_command="${__rc_command}"
  while [ "$#" -gt 0 ]; do
    __rc_log_command="${__rc_log_command} ${1}"
    shift
  done
  __rc_log_command=`printf "%s" "${__rc_log_command}" | awk 'BEGIN {ORS="/n"} {print $0}' | sed -e 's|  *| |g' -e 's|/n$||' 2>/dev/null`
  _log_msg CMD "${__rc_log_command}${__rc_stderr}"

  return "${__rc_exit_code}"
}

_run_command_eval()
{
  __rc_command="${1:-}"
  __rc_redirect_stderr_to_stdout="${2:-false}"
  __rc_stderr_file="${__UAC_TEMP_DATA_DIR}/run_command.stderr.txt"

  if [ -z "${__rc_command}" ]; then
    _log_msg ERR "_run_command: empty command parameter"
    return 1
  fi

  if [ ! -d "${__UAC_TEMP_DATA_DIR}" ]; then
    return 1
  fi

  if ${__rc_redirect_stderr_to_stdout}; then
    eval "${__rc_command}" 2>&1
    return $?
  fi

  eval "${__rc_command}" 2>"${__rc_stderr_file}"
  __rc_exit_code="$?"

  __rc_stderr=""
  if [ -s "${__rc_stderr_file}" ]; then
    __rc_stderr=`awk 'BEGIN {ORS="/n"} {print $0}' "${__rc_stderr_file}" | sed -e 's|/n$||' 2>/dev/null`
    __rc_stderr=" 2> ${__rc_stderr}"
  fi

  __rc_command=`printf "%s" "${__rc_command}" | awk 'BEGIN {ORS="/n"} {print $0}' | sed -e 's|  *| |g' -e 's|/n$||' 2>/dev/null`
  _log_msg CMD "${__rc_command}${__rc_stderr}"

  return "${__rc_exit_code}"
}
