#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Log message.
# Arguments:
#   string level: error level (default: INF)
#                 accepted values: DBG, INF, ERR, CMD
#   string message: error message
# Returns:
#   none
_log_msg()
{
  __lm_level="${1:-INF}"
  __lm_message="${2:-}"

  if [ ! -f "${__UAC_TEMP_DATA_DIR}/${__UAC_LOG_FILE}" ]; then
    return 1
  fi

  if [ "${__lm_level}" = "DBG" ]; then
    ${__UAC_DEBUG_MODE} || return 0
  fi

  # shellcheck disable=SC2006
  __lm_timestamp=`date "+%Y-%m-%d %H:%M:%S %z"`
  printf "%s %s %s\n" "${__lm_timestamp}" "${__lm_level}" "${__lm_message}" \
    >>"${__UAC_TEMP_DATA_DIR}/${__UAC_LOG_FILE}" 2>/dev/null
  
}