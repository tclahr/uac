#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the system's architecture.
# Arguments:
#   string operating_system: operating system name
# Returns:
#   string: system's architecture
_get_system_arch()
{
  __sa_operating_system="${1:-}"

  case "${__sa_operating_system}" in
    "aix"|"solaris")
      uname -p
      ;;
    "esxi"|"freebsd"|"linux"|"macos"|"netbsd"|"netscaler"|"openbsd")
      uname -m
      ;;
  esac
}