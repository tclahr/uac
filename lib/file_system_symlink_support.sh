#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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