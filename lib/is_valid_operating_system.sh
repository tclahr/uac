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
# Check if given operating system is valid.
# removed.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: operating system
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
is_valid_operating_system()
{
  io_operating_system="${1:-}"

  if [ "${io_operating_system}" != "android" ] \
    && [ "${io_operating_system}" != "aix" ] \
    && [ "${io_operating_system}" != "esxi" ] \
    && [ "${io_operating_system}" != "freebsd" ] \
    && [ "${io_operating_system}" != "linux" ] \
    && [ "${io_operating_system}" != "macos" ] \
    && [ "${io_operating_system}" != "netbsd" ] \
    && [ "${io_operating_system}" != "netscaler" ] \
    && [ "${io_operating_system}" != "openbsd" ] \
    && [ "${io_operating_system}" != "solaris" ]; then
    return 2
  fi

}