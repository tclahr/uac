#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2010,SC2012,SC2162,SC2181

# Get the system's timezone.
# Arguments:
#   string mount_point: mount 
#   string operating_system: operating system name
# Returns:
#   string: system's timezone or "unknown" if not able to get it
_get_timezone()
{
  __gtz_mount_point="${1:-/}"
  __gtz_operating_system="${2:-linux}"

  case "${__gtz_operating_system}" in
    "esxi")
      echo "UTC"
      return 0
      ;;
  esac

  if [ "${__gtz_mount_point}" = "/" ]; then
    if [ -n "${TZ:-}" ]; then
      echo "${TZ}"
      return 0
    fi
    if command_exists "timedatectl"; then
      __gtz_timedatectl=`timedatectl | grep -E "Time zone" | awk -F": " '{split($2,a," "); print a[1]}'`
      if [ -n "${__gtz_timedatectl}" ]; then
        echo "${__gtz_timedatectl}"
        return 0
      fi
    fi
  fi

  if ls -l "${__gtz_mount_point}/etc/localtime" 2>/dev/null | grep -q "zoneinfo"; then
    ls -l "${__gtz_mount_point}/etc/localtime" | sed -e 's|.*zoneinfo/||'
    return 0
  fi

  if [ -f "${__gtz_mount_point}/etc/localtime" ] \
    && [ -d "${__gtz_mount_point}/usr/share/zoneinfo" ]; then
    __gtz_command="${__UAC_TOOL_MD5_BIN} \"${__gtz_mount_point}/etc/localtime\""
    __gtz_localtime_hash=`eval "${__gtz_command}" | _grep_o "[0-9a-fA-F]\{32\}"`
    __gtz_find_output=`find "${__gtz_mount_point}/usr/share/zoneinfo/" -type f`
    printf "%s\n" "${__gtz_find_output}" \
      | while read __gtz_zoneinfo_file || [ -n "${__gtz_zoneinfo_file}" ]; do
          __gtz_command="${__UAC_TOOL_MD5_BIN} \"${__gtz_zoneinfo_file}\""
          __gtz_zone_hash=`eval "${__gtz_command}" | _grep_o "[0-9a-fA-F]\{32\}"`
          if [ "${__gtz_localtime_hash}" = "${__gtz_zone_hash}" ]; then
            echo "${__gtz_zoneinfo_file}" \
              | sed -e "s|${__gtz_mount_point}/usr/share/zoneinfo/||"
            return 0
          fi
        done
    if [ "$?" -eq 0 ]; then
      return 0
    fi
  fi

  # AIX
  if [ -f "${__gtz_mount_point}/etc/environment" ]; then
    __gtz_timezone=`grep -E "^TZ=" "${__gtz_mount_point}/etc/environment" \
      | cut -d= -f2 | sed -e 's|"||g'`
    if [ -n "${__gtz_timezone}" ]; then
      echo "${__gtz_timezone}"
      return 0
    fi
  fi

  # Solaris
  if [ -f "${__gtz_mount_point}/etc/TIMEZONE" ]; then
    __gtz_timezone=`grep -E "^TZ=" "${__gtz_mount_point}/etc/TIMEZONE" \
      | cut -d= -f2 | sed -e 's|"||g'`
    if [ -n "${__gtz_timezone}" ]; then
      echo "${__gtz_timezone}"
      return 0
    fi
  fi

  if [ -f "${__gtz_mount_point}/etc/timezone" ]; then
    __gtz_timezone=`cat "${__gtz_mount_point}/etc/timezone"`
    if [ -n "${__gtz_timezone}" ]; then
      echo "${__gtz_timezone}"
      return 0
    fi
  fi

  # openwrt
  if [ -f "${__gtz_mount_point}/etc/TZ" ]; then
    __gtz_timezone=`cat "${__gtz_mount_point}/etc/TZ"`
    if [ -n "${__gtz_timezone}" ]; then 
      echo "${__gtz_timezone}"
      return 0
    fi
  fi

  echo "unknown"
  return 1

}