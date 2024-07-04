#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Filter a list of items (line by line) based on an exclusion list.
# Arguments:
#   string list: list of items
#   string exclude_list: exclusion list
# Returns:
#   string: filtered list
_filter_list()
{
  __fl_list="${1:-}"
  __fl_exclude_list="${2:-}"

  __fl_OIFS="${IFS}"
  IFS="
"
  for __fl_i in ${__fl_list}; do
    __fl_found=false
    for __fl_e in ${__fl_exclude_list}; do
      if [ "${__fl_i}" = "${__fl_e}" ]; then
        __fl_found=true
        break
      fi
    done
    $__fl_found || printf "%s\n" "${__fl_i}"
  done

  IFS="${__fl_OIFS}"
}
