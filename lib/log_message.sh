# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################
# Log message into uac log file.
# Globals:
#   UAC_LOG_FILE
# Requires:
#   None
# Arguments:
#   $1: level
#       COMMAND  Command
#       DEBUG    Debug
#       INFO     Info (default)
#       WARNING  Warning
#       ERROR    Error
#   $2: message
# Outputs:
#   Write message to UAC_LOG_FILE.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
log_message()
{
  lm_level="${1:-I}"
  lm_message="${2:-}"

  if [ "${lm_level}" != "COMMAND" ] && [ "${lm_level}" != "DEBUG" ] \
    && [ "${lm_level}" != "INFO" ] && [ "${lm_level}" != "WARNING" ] \
    && [ "${lm_level}" != "ERROR" ]; then
    lm_level="INFO"
  fi

  lm_timestamp=`date "+%Y-%m-%d %H:%M:%S %z"`
  printf %b "${lm_timestamp} ${lm_level} ${lm_message}\n" \
    >>"${UAC_LOG_FILE}" 2>/dev/null

}