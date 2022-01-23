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