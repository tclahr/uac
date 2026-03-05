#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Take a string like "10T" and convert to the target unit.
# Valid units are:
# b|c               bytes
# k|K|kb|KB|Kb|kB   kilobytes
# m|M|mb|MB|Mb|mB   megabytes
# g|G|gb|GB|Gb|gB   gigabytes
# t|T|tb|TB|Tb|tB   terabytes
# Null unit specifier means bytes.
# Arguments:
#   string input: input string
#   string target: target unit
# Returns:
#   integer: converted value
#            returns zero on any errors

_convert_size() {
  __cs_input="${1:-0}"
  __cs_target="${2:-b}"

  # extract the numeric part and the suffix
  __cs_number=`echo "${__cs_input}" | sed -e 's|[^0-9]||g'`
  __cs_suffix=`echo "${__cs_input}" | sed -e 's|[0-9]*||g'`

  if [ -z "${__cs_number}" ]; then
    echo 0
    return 1
  fi

  case "${__cs_suffix}" in
    b|c)             __cs_multiplier=1 ;;
    k|K|kb|KB|Kb|kB) __cs_multiplier=1024 ;;
    m|M|mb|MB|Mb|mB) __cs_multiplier=1048576 ;;
    g|G|gb|GB|Gb|gB) __cs_multiplier=1073741824 ;;
    t|T|tb|TB|Tb|tB) __cs_multiplier=1099511627776 ;;
    "")              __cs_multiplier=1 ;;
    *)
      _error_msg "_convert_size: invalid suffix: '${__cs_suffix}'"
      echo 0
      return 1
      ;;
  esac

  case "${__cs_target}" in
    b|c)             __cs_divider=1 ;;
    k|K|kb|KB|Kb|kB) __cs_divider=1024 ;;
    m|M|mb|MB|Mb|mB) __cs_divider=1048576 ;;
    g|G|gb|GB|Gb|gB) __cs_divider=1073741824 ;;
    t|T|tb|TB|Tb|tB) __cs_divider=1099511627776 ;;
    "")              __cs_divider=1 ;;
    *)
      _error_msg "_convert_size: invalid target: '${__cs_target}'"
      echo 0
      return 1
      ;;
  esac

  awk "BEGIN { printf \"%.0f\", ((${__cs_number} * ${__cs_multiplier}) / ${__cs_divider}) }"

}
