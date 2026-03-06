#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the list of mount points.
# Arguments:
#   string operating_system: operating system name
# Returns:
#   string: pipe-separated list of mount points, file systems, and size (in bytes)
_get_mount_points()
{
  __gmp_operating_system="${2:-}"

  if [ -z "${__gm_operating_system}" ]; then
    return 1
  fi

  case "${__gmp_operating_system}" in
    "aix")
      df -k -F %u %m | tail -n +2 | awk 'BEGIN { FS=" "; } { printf "%s|%d|%s\n", $1, int($3*1024), $4; }'
      ;;
    "esxi")
      df -u \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if (tolower($1) in __gm_file_system_dict) {
              printf "%s|", $6;
            }
          }' 2>/dev/null \
        | sed -e 's:|$::' 2>/dev/null
      ;;
    "freebsd"|"macos"|"netscaler")
      mount \
        | sed -e 's|(||g' -e 's|,| |g' -e 's|)||g' \
        | awk 'BEGIN { FS=" on "; } { print $2; }' \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if ($2 in __gm_file_system_dict) {
              printf "%s|", $1;
            }
          }' 2>/dev/null \
        | sed -e 's:|$::' 2>/dev/null
      ;;
    "linux"|"netbsd"|"openbsd")
      mount \
        | awk 'BEGIN { FS=" on "; } { print $2; }' \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in __gm_file_system_dict) {
              printf "%s|", $1;
            }
          }' 2>/dev/null \
        | sed -e 's:|$::' 2>/dev/null
      ;;
    "solaris")
      df -n \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in __gm_file_system_dict) {
              printf "%s|", $1;
            }
          }' 2>/dev/null \
        | sed -e 's:|$::' 2>/dev/null
      ;;
  esac

}