#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get current operating system.
# Arguments:
#   none
# Returns:
#   string: operating system
_get_operating_system()
{
  # shellcheck disable=SC2006
  __go_kernel_name=`uname -s`
  
  case "${__go_kernel_name}" in
    "AIX")
      echo "aix"
      ;;
    "FreeBSD")
      if uname -r | grep -q -E -i "netscaler"; then
        echo "netscaler"
      else
        echo "freebsd"
      fi
      ;; 
    "Linux")
      echo "linux"
      ;;
    "Darwin")
      echo "macos"
      ;;
    "NetBSD")
      echo "netbsd"
      ;;
    "OpenBSD")
      echo "openbsd"
      ;;
    "SunOS")
      echo "solaris"
      ;;
    "VMkernel")
      echo "esxi"
      ;;
    "Haiku")
      echo "haiku"
      ;;
    *)
      echo "${__go_kernel_name}"
      ;;
  esac
}
