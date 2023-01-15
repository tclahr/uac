#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Check if the current user has root privileges.
# Globals:
#   None
# Requires:
#   get_current_user
# Arguments:
#   None
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_running_with_root_privileges()
{

  ir_current_user=`get_current_user`
  ir_uid=""

  if [ "${ir_current_user}" = "root" ]; then
    return 0
  else
    # id command is not available on VMWare ESXi
    if eval "id -u" >/dev/null 2>/dev/null; then
      ir_uid=`id -u`
    elif [ -f "/etc/passwd" ]; then
      ir_uid=`grep "^${ir_current_user}" /etc/passwd 2>/dev/null \
                | awk 'BEGIN { FS=":"; } { print $3; }' 2>/dev/null`
    fi
    if [ "${ir_uid}" = "0" ]; then
      return 0 
    fi
  fi
  return 2

}