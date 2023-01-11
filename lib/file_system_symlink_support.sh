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
# Check if given directory's file system supports symlink creation.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: directory
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
file_system_symlink_support()
{
  fs_directory="${1:-}"
  
  rm "${fs_directory}/.uac-symlink.tmp"
  if ln -s "${UAC_DIR}" "${fs_directory}/.uac-symlink.tmp"; then
    rm "${fs_directory}/.uac-symlink.tmp"
    return 0
  fi
  return 1

}