#!/bin/sh

# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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