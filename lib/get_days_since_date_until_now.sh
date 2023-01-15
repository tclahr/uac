#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Count days since a specific date until now (today).
# Globals:
#   None
# Requires:
#   get_epoch_date
# Arguments:
#   $1: date in YYYY-MM-DD format
# Outputs:
#   Write number of days to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_days_since_date_until_now()
{
  gd_date="${1:-}"
  
  gd_epoch_now=`get_epoch_date`
  gd_epoch_date=`get_epoch_date "${gd_date}"` || return 1
  if [ "${gd_epoch_now}" -gt "${gd_epoch_date}" ]; then
    # shellcheck disable=SC2003
    gd_difference=`expr "${gd_epoch_now}" - "${gd_epoch_date}" 2>/dev/null`
    # shellcheck disable=SC2003
    expr "${gd_difference}" / 86400 2>/dev/null
  else
    printf %b "uac: date '${gd_date}' cannot be greater than today.\n" >&2
    return 22
  fi

}