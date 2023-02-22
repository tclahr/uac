#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Get system architecture.
# Globals:
#   OPERATING_SYSTEM
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write system architecture to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_system_arch()
{
  
  case "${OPERATING_SYSTEM}" in
    "aix"|"solaris")
      uname -p
      ;;
    "android"|"esxi"|"freebsd"|"linux"|"macos"|"netbsd"|"netscaler"|"openbsd")
      uname -m
      ;;
  esac

}