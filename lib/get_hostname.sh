#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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