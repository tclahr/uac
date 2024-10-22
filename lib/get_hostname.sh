#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the system's hostname.
# Arguments:
#   string mount_point: mount point
# Returns:
#   string: system's hostname or "unknown" if not able to get it
_get_hostname()
{
  __gh_mount_point="${1:-/}"

  if [ "${__gh_mount_point}" = "/" ]; then
    # some systems do not have hostname tool installed
    if hostname 2>/dev/null; then
      true
    elif uname -n 2>/dev/null; then
      true
    elif [ -n "${HOSTNAME:-}" ]; then
      echo "${HOSTNAME}"
    elif [ -r "/etc/hostname" ]; then
      head -1 "/etc/hostname" 2>/dev/null
    elif [ -r "/etc/rc.conf" ]; then
      sed -n -e 's|^hostname="\(.*\)"|\1|p' <"/etc/rc.conf" 2>/dev/null
    elif [ -r "/etc/myname" ]; then
      head -1 "/etc/myname" 2>/dev/null
    elif [ -r "/etc/nodename" ]; then
      head -1 "/etc/nodename" 2>/dev/null
    else
      echo "unknown"
    fi
  else
    if [ -r "${__gh_mount_point}/etc/hostname" ]; then
      head -1 "${__gh_mount_point}/etc/hostname" 2>/dev/null
    elif [ -r "${__gh_mount_point}/etc/rc.conf" ]; then
      sed -n -e 's|^hostname="\(.*\)"|\1|p' <"${__gh_mount_point}/etc/rc.conf" 2>/dev/null
    elif [ -r "${__gh_mount_point}/etc/myname" ]; then
      head -1 "${__gh_mount_point}/etc/myname" 2>/dev/null
    elif [ -r "${__gh_mount_point}/etc/nodename" ]; then
      head -1 "${__gh_mount_point}/etc/nodename" 2>/dev/null
    else
      echo "unknown"
    fi
  fi
}