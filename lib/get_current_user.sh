#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Get the current user.
# Globals:
#   LOGNAME
#   USER
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write the current user to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_current_user()
{
  # some systems like the docker version of Alpine Linux do not have 
  # neither LOGNAME nor USER set, and this can cause an error message if set -u
  set +u
  
  # who and whoami are not available on some systems
  if [ -n "${LOGNAME}" ]; then
    printf %b "${LOGNAME}"
  elif [ -n "${USER}" ]; then
    printf %b "${USER}"
  else
    id | sed -e 's:uid=[0-9]*(::' -e 's:).*::'
  fi
  
  set -u

}