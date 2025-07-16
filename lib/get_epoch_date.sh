#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get Unix Epoch timestamp for the current or given date.
# Arguments:
#   string date: date in YYYY-MM-DD format (optional)
# Returns:
#   string: epoch timestamp
_get_epoch_date()
{
  __ge_date="${1:-}"
  
  # get epoch timestamp for the given date
  if [ -n "${__ge_date}" ]; then
    if echo "${__ge_date}" | grep -v -q -E "[1-9][0-9]{3}-[0-1][0-9]-[0-3][0-9]" 2>/dev/null; then  
      return 1
    fi
    date -d "${__ge_date} 00:00:00" "+%s" 2>/dev/null && return 0
    # bsd date
    date -j -f "%Y-%m-%d %H:%M:%S" "${__ge_date} 00:00:00" "+%s" 2>/dev/null && return 0
    # old busybox date (MMDDhhmmYYYY)
    # shellcheck disable=SC2006
    __ge_string=`echo "${__ge_date}" \
      | awk 'BEGIN { FS="-"; } { print $2$3"0000"$1; }' 2>/dev/null`
    date -d "${__ge_string}" "+%s" 2>/dev/null && return 0
    # any system with 'perl' tool
    date_to_epoch.pl "${__ge_date}" 2>/dev/null
  elif perl -e 'print time' >/dev/null 2>/dev/null; then
    # get current epoch timestamp
    perl -e 'print time' 2>/dev/null
  else
    # get current epoch timestamp
    date "+%s" 2>/dev/null
  fi
}