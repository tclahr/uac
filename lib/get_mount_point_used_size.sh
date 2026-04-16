#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the list of mount points and their used size in Kilobytes.
# Arguments:
#   string operating_system: operating system name
# Returns:
#   string: pipe-separated list of mount points, and used size (in Kilobytes)
_get_mount_point_used_size()
{
  __gmp_operating_system="${1:-}"

  if [ -z "${__gmp_operating_system}" ]; then
    return 1
  fi

  case "${__gmp_operating_system}" in
    "aix")
      df -k \
        | awk '
            NR>1 && $3 != "-" {
              used=$2-$3
              mnt=$7
              printf "%s|%s\n", mnt, used
            }'
      ;;
    "esxi")
      df -k \
        | awk '
            NR>1 {
              used=$3
              mnt=$6
              printf "%s|%s\n", mnt, used
            }'
      ;;
    "freebsd"|"linux"|"macos"|"netbsd"|"netscaler"|"openbsd"|"solaris")
      df -k \
        | awk '
            NR>1 {
              used=$3
              mnt=$NF
              printf "%s|%s\n", mnt, used
            }'
      ;;
  esac

}