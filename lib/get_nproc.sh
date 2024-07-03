#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print the number of processing units available.
# Arguments:
#   none
# Returns:
#   integer: number of processing units available
_get_nproc()
{
  # esxi, linux, netbsd
  grep -c "^processor" /proc/cpuinfo 2>/dev/null && return 0
  # freebsd, linux, solaris
  if command_exists "nproc"; then
    nproc 2>/dev/null
    return 0
  fi
  # freebsd, linux, macos
  if command_exists "getconf" && getconf _NPROCESSORS_ONLN >/dev/null 2>/dev/null; then
    getconf _NPROCESSORS_ONLN 2>/dev/null
    return 0
  fi
  # freebsd, macos, netbsd, netscaler, openbsd
  if command_exists "sysctl" && sysctl -n hw.ncpu >/dev/null 2>/dev/null; then
    sysctl -n hw.ncpu 2>/dev/null
    return 0
  fi
  # solaris
  if command_exists "psrinfo"; then
    psrinfo 2>/dev/null | wc -l 2>/dev/null | awk '{print $1}' 2>/dev/null
    return 0
  fi
  # aix
  if command_exists "lsdev" && lsdev -Cc processor >/dev/null 2>/dev/null; then
    lsdev -Cc processor 2>/dev/null | grep -c Available 2>/dev/null
    return 0
  fi

  echo "unknown" && return 1

}