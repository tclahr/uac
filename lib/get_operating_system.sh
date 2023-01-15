#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Get current operating system.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write operating system to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_operating_system()
{
  gs_kernel_name=`uname -s`
  
  case "${gs_kernel_name}" in
    "AIX")
      printf %b "aix"
      ;;
    "FreeBSD")
      if eval "uname -r | grep -q -E -i \"netscaler\""; then
        printf %b "netscaler"
      else
        printf %b "freebsd"
      fi
      ;; 
    "Linux")
      if eval "env | grep -q -E \"ANDROID_ROOT\"" \
        && eval "env | grep -q -E \"ANDROID_DATA\""; then
        printf %b "android"
      else
        printf %b "linux"
      fi
      ;;
    "Darwin")
      printf %b "macos"
      ;;
    "NetBSD")
      printf %b "netbsd"
      ;;
    "OpenBSD")
      printf %b "openbsd"
      ;;
    "SunOS")
      printf %b "solaris"
      ;;
    "VMkernel")
      printf %b "esxi"
      ;;
    *)
      printf %b "${gs_kernel_name}"
      ;;
  esac

}