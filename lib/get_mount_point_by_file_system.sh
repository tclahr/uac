#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the list of mount points by file system.
# Arguments:
#   string file_systems: pipe-separated list of file systems
#   string operating_system: operating system name
# Returns:
#   string: pipe-separated list of mount points
_get_mount_point_by_file_system()
{
  __gm_file_systems="${1:-}"
  __gm_operating_system="${2:-}"

  if [ -z "${__gm_file_systems}" ] || [ -z "${__gm_operating_system}" ]; then
    return 1
  fi

  case "${__gm_operating_system}" in
    "aix")
      mount \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if ($3 in __gm_file_system_dict) {
              printf "%s|", $2;
            }
          }' 2>/dev/null \
        | sed -e 's:|$::' 2>/dev/null
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
    "haiku")
      df -a \
        | awk -v __gm_file_systems="${__gm_file_systems}" \
          'BEGIN {
            gsub(/[ ]+/, "", __gm_file_systems);
            gsub("\"", "", __gm_file_systems);
            split(__gm_file_systems, __gm_file_system_array, "|");
            for (i in __gm_file_system_array) {
              __gm_file_system_dict[__gm_file_system_array[i]]="";
            }
          }
          {
            if ($1 in __gm_file_system_dict) {
              printf "%s|", $NF;
            }
          }' \
        | sed -e 's:|$::' 2>/dev/null
      ;;
  esac

}
