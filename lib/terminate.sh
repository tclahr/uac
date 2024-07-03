#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Clean up and exit.
# Arguments:
#   none
# Returns:
#   integer: exit code 130
_terminate()
{
  printf "\n%s\n" "Caught signal! Cleaning up and quitting..."
  _remove_temp_data_dir
  exit 130

}