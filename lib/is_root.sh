#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Check if the current user has root privileges (UID = 0).
# Arguments:
#   none
# Returns:
#   boolean: true on success
#            false on fail
_is_root()
{
  __ir_uid=""
  if id -u >/dev/null 2>/dev/null; then
    __ir_uid=`id -u 2>/dev/null`
  elif [ -f "/etc/passwd" ]; then
    __ir_current_user=`_get_current_user`
    __ir_uid=`grep "^${__ir_current_user}" /etc/passwd 2>/dev/null \
      | awk 'BEGIN { FS=":"; } { print $3; }' 2>/dev/null`
  fi  
  if [ "${__ir_uid}" -eq 0 ]; then
    return 0
  fi
  return 1
}