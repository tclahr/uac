#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2003,SC2006

# Get the system's architecture.
# Arguments:
#   string operating_system: operating system name
# Returns:
#   integer: memory size in megabytes
_get_memory_size()
{
  __gms_operating_system="${1:-}"

  case "${__gms_operating_system}" in
    "aix")
      prtconf | awk '/^Memory Size:/ {print $3}'
      ;;
    "esxi")
      esxcli hardware memory get | awk '/Physical Memory:/ {print int($3 / 1000 / 1000)}'
      ;;
    "freebsd"|"macos"|"netbsd"|"netscaler"|"openbsd")
      __gms_memory_size=`sysctl -n hw.physmem` # in bytes
      expr "${__gms_memory_size}" / 1000 / 1000
      ;;
    "linux")
      awk '/^MemTotal:/ {print int($2 / 1000)}' /proc/meminfo
      ;;
    "solaris")
      prtconf | awk '/^Memory size:/ {print $3}'
      ;;
  esac
}
