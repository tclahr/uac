#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

_usage() {
  printf "%s" "Usage: $0 MOUNT_POINT [EXCLUDE_PATHS]
  
Recursively scans a local directory tree and prints 'getcap' commands
without executing them, while allowing exclusion of specified paths
to avoid non-local mounts.

Arguments:
  MOUNT_POINT      Base directory to start scanning
  EXCLUDE_PATHS    Pipe-separated list of paths to exclude (e.g. /proc|/sys|/dev)

Example:
  $0 / \"/proc|/sys|/dev\"
"
}

_recurse_dir() {
  __rd_base_dir="${1:-}"
  __rd_exclude_paths="${2:-}"

  printf "getcap \"%s\"/*\n" "${__rd_base_dir}"

  for __rd_entry in "${__rd_base_dir}"/*; do
    if [ ! -d "${__rd_entry}" ]; then
      continue
    fi

    # Normalize leading slashes
    case "${__rd_entry}" in
      //*) __rd_entry="/`echo "${__rd_entry}" | sed 's|^//*||'`" ;;
    esac

    __rd_skip_dir=false

    __rd_OIFS=${IFS}
    IFS='|'
    for __rd_exclude in ${__rd_exclude_paths}; do
      if [ "${__rd_entry}" = "${__rd_exclude}" ]; then
        __rd_skip_dir=true
        break
      fi
      case "${__rd_exclude}" in
        "${__rd_entry}/"*)
          # recurse if exclude is under entry
          (
            _recurse_dir "${__rd_entry}" "${__rd_exclude_paths}"
          )
          __rd_skip_dir=true
          break
          ;;
      esac
    done
    IFS=${__rd_OIFS}

    if [ "${__rd_skip_dir}" = false ]; then
      printf "getcap -r \"%s\"/*\n" "${__rd_entry}"
    fi

  done

}

__gc_mount_point=""
__gc_exclude_paths=""

while [ ${#} -gt 0 ]; do
  case "${1}" in
    # optional arguments
    "-h"|"--help")
      _usage
      exit 0
      ;;
    *)
      if [ -z "${__gc_mount_point}" ]; then
        __gc_mount_point="${1}"
      elif [ -z "${__gc_exclude_paths}" ]; then
        __gc_exclude_paths="${1}"
      else
        printf "invalid option '%s'\nTry '%s --help' for more information.\n" "${1}" "$0" >&2
        return 1
      fi
      ;;
  esac
  shift
done

# do not allow using undefined variables
set -u

if [ -z "${__gc_mount_point}" ]; then
  _usage
  exit 1
fi

if [ ! -d "${__gc_mount_point}" ]; then
  printf "%s: cannot access '%s': No such file or directory\n" "$0" "${__gc_mount_point}" >&2
  exit 1
fi

_recurse_dir "${__gc_mount_point}" "${__gc_exclude_paths}"
