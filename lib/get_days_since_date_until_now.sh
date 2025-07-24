#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2003,SC2006

# Count days since a specific date until now (today).
# Arguments:
#   string date: date in YYYY-MM-DD format
# Returns:
#   integer: number of days
_get_days_since_date_until_now()
{
  __gd_date="${1:-}"

  __gd_epoch_now=`_get_epoch_date`
  __gd_epoch_date=`_get_epoch_date "${__gd_date}"`

  if [ -z "${__gd_epoch_date}" ]; then
    return 1
  fi

  if [ "${__gd_epoch_now}" -gt "${__gd_epoch_date}" ]; then
    __gd_difference=`expr "${__gd_epoch_now}" - "${__gd_epoch_date}" 2>/dev/null`
    expr "${__gd_difference}" / 86400 2>/dev/null
  else
    _error_msg "Date '${__gd_date}' cannot be greater than today."
    return 1
  fi

}