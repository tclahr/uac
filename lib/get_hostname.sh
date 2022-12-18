#!/bin/sh

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
# Get the current system hostname.
# Globals:
#   HOSTNAME
#   MOUNT_POINT
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write the hostname to stdout.
#   Write "unknown" to stdout if not able to get current hostname.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_hostname()
{

  if [ "${MOUNT_POINT}" = "/" ]; then
    # some systems do not have hostname tool installed
    if eval "hostname" 2>/dev/null; then
      true
    elif eval "uname -n"; then
      true
    elif [ -n "${HOSTNAME}" ]; then
      printf %b "${HOSTNAME}"
    elif [ -r "/etc/hostname" ]; then
      head -1 "/etc/hostname"
    else
      printf %b "unknown"
    fi
  else
    if [ -r "${MOUNT_POINT}/etc/hostname" ]; then
      head -1 "${MOUNT_POINT}/etc/hostname"
    else
      printf %b "unknown"
    fi
  fi

}