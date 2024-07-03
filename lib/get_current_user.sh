#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the current user.
# Arguments:
#   None
# Returns:
#   string: current user name
_get_current_user()
{
  # who and whoami are not available on some systems
  if [ -n "${LOGNAME:-}" ]; then
    echo "${LOGNAME}"
  elif [ -n "${USER:-}" ]; then
    echo "${USER}"
  else
    id | sed -e 's|^uid=[0-9]*(\([^)]*\).*|\1|' 2>/dev/null
  fi
}