#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

_usage(){
  printf "dirwalk.sh version 1.0.0

Usage: dirwalk.sh [OPTIONS] MODE MOUNT_POINT [EXCLUDE_PATHS]

Directory traversal utility with exclusion support.

OPTIONS:
  -h, --help     Show this help message and exit

ARGUMENTS:
  MODE           Traversal mode: 'parents' or 'children'
                 - parents: Print directories before processing subdirectories
                 - children: Print directories after processing subdirectories
  
  MOUNT_POINT    Base directory to start traversal from
  
  EXCLUDE_PATHS  Optional pipe-separated list of paths to exclude
                 Example: '/path/to/skip|/another/path/to/skip'

Examples:
  dirwalk.sh parents /home/user
  dirwalk.sh children /var/log '/var/log/old|/var/log/archive'
  dirwalk.sh parents /opt '/opt/backup|/opt/temp'
"
}

_is_in_list() {
  __il_element="${1:-}"
  __il_list="${2:-}"

  __il_OIFS="${IFS}"; IFS="|"
  for __il_item in ${__il_list}; do
    if [ "${__il_element}" = "${__il_item}" ]; then
      IFS="${__il_OIFS}"
      return 0
    fi
  done
  
  IFS="${__il_OIFS}"
  return 1
}

_recurse_dir() {
  __rd_mode="${1:-}"
  __rd_base_dir="${2:-}"
  __rd_exclude_paths="${3:-}"

  if [ "${__rd_mode}" = "parents" ]; then
    printf "%s\n" "${__rd_base_dir}"
  fi

  for __rd_entry in "${__rd_base_dir}"/*; do
    if [ ! -d "${__rd_entry}" ]; then
      continue
    fi

    # Normalize leading slashes
    case "${__rd_entry}" in
      //*) __rd_entry="/`echo "${__rd_entry}" | sed 's|^//*||'`" ;;
    esac

    __rd_skip_dir=false

    if _is_in_list "${__rd_entry}" "${__rd_exclude_paths}"; then
      continue
    fi

    __rd_OIFS=${IFS}; IFS='|'
    for __rd_exclude in ${__rd_exclude_paths}; do
      case "${__rd_exclude}" in
        "${__rd_entry}/"*)
          # recurse if exclude is under entry
          (
            _recurse_dir "${__rd_mode}" "${__rd_entry}" "${__rd_exclude_paths}"
          )
          __rd_skip_dir=true
          break
          ;;
      esac
    done
    IFS=${__rd_OIFS}

    if [ "${__rd_skip_dir}" = false ] && [ "${__rd_mode}" = "children" ]; then
      printf "%s\n" "${__rd_entry}"
    fi

  done
}

# do not allow using undefined variables
set -u

__gc_mount_point=""
__gc_exclude_paths=""
__gc_mode=""

while [ ${#} -gt 0 ]; do
  case "${1}" in
    "-h"|"--help")
      _usage
      exit 0
      ;;
    *)
      if [ -z "${__gc_mode}" ]; then
        __gc_mode="${1}"
      elif [ -z "${__gc_mount_point}" ]; then
        __gc_mount_point="${1}"
      elif [ -z "${__gc_exclude_paths}" ]; then
        __gc_exclude_paths="${1}"
      else
        printf "dirwalk.sh: invalid option '%s'\nTry 'dirwalk.sh --help' for more information.\n" "${1}" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

if [ -z "${__gc_mode}" ]; then
  _usage
  exit 1
fi

if [ "${__gc_mode}" != "parents" ] && [ "${__gc_mode}" != "children" ]; then
  printf "dirwalk.sh: invalid mode '%s'\nTry 'dirwalk.sh --help' for more information.\n" "${__gc_mode}" >&2
  exit 1
fi

if [ -z "${__gc_mount_point}" ]; then
  _usage
  exit 1
fi

if [ ! -d "${__gc_mount_point}" ]; then
  printf "dirwalk.sh: cannot access '%s': No such file or directory\n" "${__gc_mount_point}" >&2
  exit 1
fi

_recurse_dir "${__gc_mode}" "${__gc_mount_point}" "${__gc_exclude_paths}"
