#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the system's architecture.
# Arguments:
#   string os: operating system name
# Returns:
#   string: system's architecture
_get_system_arch()
{
  __sa_os="${1:-}"

  case "${__sa_os}" in
    "aix"|"solaris")
      uname -p
      ;;
    "esxi"|"freebsd"|"haiku"|"linux"|"macos"|"netbsd"|"netscaler"|"openbsd")
      uname -m
      ;;
  esac
}
