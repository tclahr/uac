#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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