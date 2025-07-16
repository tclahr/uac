#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Prepend a mount point to each path in a space-separated list.
# Arguments:
#   string path_list: space-separated list of paths (quoted paths with spaces supported)
#   string mount_point: base directory to prepend to each path
# Returns:
#   string: space-separated list of updated paths with mount point prepended
_prepend_mount_point() {
  __pm_path_list="${1:-}"
  __pm_mount_point="${2:-/}"
  __pm_result=""
  __pm_word=""
  __pm_inquote=0

  __pm_i=1
  while :; do
    __pm_char=`printf '%s' "${__pm_path_list}" | cut -c "${__pm_i}"`
    if [ -z "${__pm_char}" ]; then
      break
    fi

    if [ "${__pm_char}" = '"' ]; then
      if [ "${__pm_inquote}" -eq 0 ]; then
        __pm_inquote=1
      else
        __pm_inquote=0
      fi
      __pm_word=${__pm_word}${__pm_char}
    elif [ "${__pm_char}" = ' ' ] && [ "${__pm_inquote}" -eq 0 ]; then
      if [ -n "${__pm_word}" ]; then
        __pm_word=`_sanitize_path "${__pm_mount_point}/${__pm_word}"`
        __pm_result="${__pm_result}${__pm_result:+ }${__pm_word}"
        __pm_word=""
      fi
    else
      __pm_word=${__pm_word}${__pm_char}
    fi

    # shellcheck disable=SC2003
    __pm_i=`expr "${__pm_i}" + 1`
  done

  if [ -n "${__pm_word}" ]; then
    __pm_word=`_sanitize_path "${__pm_mount_point}/${__pm_word}"`
    __pm_result="${__pm_result}${__pm_result:+ }${__pm_word}"
  fi

  printf "%s" "${__pm_result}"

}
