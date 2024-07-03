#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Check whether an element exists in a pipe-separated values string.
# Arguments:
#   string element: element
#   string list: pipe-separated values
# Returns:
#   boolean: true on success
#            false on fail
_is_in_list()
{
  __il_element="${1:-}"
  __il_list="${2:-}"

  # shellcheck disable=SC2006
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