#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2003,SC2006

_usage() {
  printf "timeout.sh version 1.0.0
  
Usage: timeout.sh [OPTIONS] DURATION COMMAND [ARGS]...

Start COMMAND, and kill it if still running after DURATION.

OPTIONS:
  -s, --signal=SIGNAL   Signal to send to command (default: TERM)
  -k, --kill-after=DUR  Send KILL after DUR seconds if still running
  -h, --help            Display this help

DURATION is an integer number with an optional suffix:
's' for seconds (the default), 'm' for minutes, 'h' for hours or 'd' for days.

Upon timeout, send the TERM signal to COMMAND, if no other SIGNAL specified.
The TERM signal kills any process that does not block or catch that signal.
It may be necessary to use the KILL signal, since this signal can't be caught.

Exit codes:
  124  if COMMAND times out
  125  if the timeout command itself fails
  126  if COMMAND is found but cannot be invoked
  127  if COMMAND cannot be found
  -    the exit status of COMMAND otherwise

Examples:
  timeout.sh 10 sleep 5           # Success - sleep finishes in 5s
  timeout.sh 5 sleep 10           # Timeout - sleep terminated with SIGTERM in 5s
  timeout.sh 60 long_command      # 60 seconds timeout with SIGTERM
  timeout.sh -s KILL 10 cmd       # Use SIGKILL instead of SIGTERM
  timeout.sh -k 2 10 sleep 30     # SIGTERM after 10s, SIGKILL after 2s more
"
}

_command_exists()
{
  __co_command="${1:-}"

  if [ -z "${__co_command}" ]; then
    return 1
  fi

  if eval type type >/dev/null 2>/dev/null; then
    eval type "${__co_command}" >/dev/null 2>/dev/null
  elif command >/dev/null 2>/dev/null; then
    command -v "${__co_command}" >/dev/null 2>/dev/null
  else
    which "${__co_command}" >/dev/null 2>/dev/null
  fi
}

_parse_duration() {
  __pd_duration="${1}"
  
  if [ -z "${__pd_duration}" ]; then
    return 1
  fi

  __pd_number=`echo "${__pd_duration}" | sed -e 's|[smhd]$||'`

  case "${__pd_number}" in
    ''|*[!0-9]*) return 1 ;;
  esac
  
  # convert to seconds
  case "${__pd_duration}" in
    *"s"|*[0-9]) echo "${__pd_number}" ;;
    *"m") expr "${__pd_number}" \* 60 ;;
    *"h") expr "${__pd_number}" \* 3600 ;;
    *"d") expr "${__pd_number}" \* 86400 ;;
    *) return 1 ;;
  esac
}

_is_valid_signal() {
  __vs_signal="${1}"
  
  case "${__vs_signal}" in
    "HUP"|"INT"|"QUIT"|"ILL"|"TRAP"|"ABRT"|"BUS"|"FPE"|"KILL"|"USR1"|"SEGV"|"USR2"|"PIPE"|"ALRM"|"TERM"|"CHLD"|"CONT"|"STOP"|"TSTP"|"TTIN"|"TTOU")
      return 0
      ;;
    [1-9]|[12][0-9]|3[01])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

_run_command_timeout() {
  __rt_timeout_duration="${1}"
  __rt_kill_signal="${2}"
  __rt_kill_after="${3}"
  shift 3
  
  # start command in background
  "$@" &
  __rt_command_pid=$!
  
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
      return ${__EXIT_COMMAND_FOUND_CANNOT_EXECUTE}
  fi
  
  # start timer in background
  (
    sleep "${__rt_timeout_duration}"
    # check if process still exists
    if kill -0 "${__rt_command_pid}" 2>/dev/null; then
      # send the specified signal (TERM by default)
      printf "Command timeout reached, %s signal sent.\n" "${__rt_kill_signal}" >&2
      kill -"${__rt_kill_signal}" "${__rt_command_pid}" 2>/dev/null
      # if kill_after was specified, wait and send KILL signal
      if [ -n "${__rt_kill_after}" ] && [ "${__rt_kill_after}" -gt 0 ]; then
        sleep "${__rt_kill_after}"
        if kill -0 "${__rt_command_pid}" 2>/dev/null; then
          # force kill with SIGKILL
          printf "Command timeout reached, KILL signal sent.\n" >&2
          kill -KILL "${__rt_command_pid}" 2>/dev/null
        fi
      fi
    fi
  ) &
  __rt_timer_pid=$!
  
  wait "${__rt_command_pid}"
  __rt_command_exit_code=$?
  
  # kill timer if still running
  kill "${__rt_timer_pid}" 2>/dev/null
  wait "${__rt_timer_pid}" 2>/dev/null
  
  # check if command was terminated by signal
  if [ ${__rt_command_exit_code} -gt 128 ]; then
      return ${__EXIT_TIMEOUT}
  fi
  
  return ${__rt_command_exit_code}
}

# do not allow using undefined variables
set -u

# exit codes
__EXIT_SUCCESS=0
__EXIT_TIMEOUT=124
__EXIT_INVALID_ARGS=125
__EXIT_COMMAND_FOUND_CANNOT_EXECUTE=126
__EXIT_COMMAND_NOT_FOUND=127

# signal handling for cleanup
trap 'exit 130' INT
trap 'exit 143' TERM

__to_kill_signal="TERM"
__to_kill_after=""

while [ $# -gt 0 ]; do
  case "${1}" in
    "-h"|"--help")
      _usage
      exit ${__EXIT_SUCCESS}
      ;;
    "-s"|"--signal")
      if [ -z "${2}" ]; then
        printf "timeout.sh: option '%s' requires an argument\n" "${1}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      # remove SIG prefix if present
      __to_kill_signal=`echo "${2}" | sed -e 's|^SIG||'`

      if _is_valid_signal "${__to_kill_signal}"; then
        true
      else
        printf "timeout.sh: invalid signal '%s'\n" "${__to_kill_signal}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      shift 2
      ;;
    "--signal="*)
      __to_kill_signal=`echo "${1}" | sed -e 's|^--signal=||' -e 's|^SIG||'`

      if _is_valid_signal "${__to_kill_signal}"; then
        true
      else
        printf "timeout.sh: invalid signal '%s'\n" "${__to_kill_signal}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      shift
      ;;
    "-k"|"--kill-after")
      if [ -z "${2}" ]; then
        printf "timeout.sh: option '%s' requires an argument\n" "${1}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      __to_kill_after=`_parse_duration "${2}"`
      #shellcheck disable=SC2181
      if [ $? -ne 0 ]; then
        printf "timeout.sh: invalid duration '%s'\n" "${2}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      shift 2
      ;;
    "--kill-after="*)
      __to_kill_after=`echo "${1}" | sed -e 's|^--kill-after=||'`

      __to_kill_after=`_parse_duration "${__to_kill_after}"`
      # shellcheck disable=SC2181
      if [ $? -ne 0 ]; then
        printf "timeout.sh: invalid duration '%s'\n" "${__to_kill_after}" >&2
        exit ${__EXIT_INVALID_ARGS}
      fi
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf "timeout.sh: invalid option '%s'\nTry 'timeout.sh --help' for more information.\n" "${1}" >&2
      exit ${__EXIT_INVALID_ARGS}
      ;;
    *)
        break
        ;;
  esac
done

if [ $# -lt 2 ]; then
  printf "timeout.sh: insufficient arguments\nTry 'timeout.sh --help' for more information.\n" >&2
  exit ${__EXIT_INVALID_ARGS}
fi

__to_duration=`_parse_duration "${1}"`
#shellcheck disable=SC2181
if [ $? -ne 0 ]; then
  printf "timeout.sh: invalid duration '%s'\n"  "${1}" >&2
  exit ${__EXIT_INVALID_ARGS}
fi
shift

if _command_exists "${1}"; then
  true
else
  printf "timeout.sh: command not found '%s'\n" "${1}" >&2
  exit ${__EXIT_COMMAND_NOT_FOUND}
fi

_run_command_timeout "${__to_duration}" "${__to_kill_signal}" "${__to_kill_after}" "$@"
