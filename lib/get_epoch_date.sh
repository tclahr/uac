#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Get epoch timestamp for the current or given date.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: date in YYYY-MM-DD format (optional)
# Outputs:
#   Write given date epoch timestamp to stdout.
#   Write current epoch timestamp to stdout if $1 is empty.
#   Write empty string to stdout on error.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_epoch_date()
{
  ge_date="${1:-}"
  ge_date_regex="^((19|20)[0-9][0-9])-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$"

  if [ -n "${ge_date}" ] \
    && echo "${ge_date}" | grep -v -q -E "${ge_date_regex}"; then
    printf %b "uac: invalid date '${ge_date}'\n\
Try 'uac --help' for more information.\n" >&2
    return 22
  fi

  # get epoch timestamp for the given date
  if [ -n "${ge_date}" ]; then
    date -d "${ge_date} 00:00:00" "+%s" 2>/dev/null && return 0
    # bsd date
    date -j -f "%Y-%m-%d %H:%M:%S" "${ge_date} 00:00:00" "+%s" \
      2>/dev/null && return 0
    # old busybox date (MMDDhhmmYYYY)
    ge_string=`echo "${ge_date}" \
      | awk 'BEGIN { FS="-"; } { print $2$3"0000"$1; }' 2>/dev/null`
    date -d "${ge_string}" "+%s" 2>/dev/null && return 0
    # any system with 'perl' tool
    perl "${UAC_DIR}/tools/date_to_epoch.pl/date_to_epoch.pl" "${ge_date}" \
      2>/dev/null
  elif eval "perl -e 'print time'" >/dev/null 2>/dev/null; then
    # get current epoch timestamp
    perl -e 'print time' 2>/dev/null
  else
    # get current epoch timestamp
    date "+%s" 2>/dev/null
  fi
  
}