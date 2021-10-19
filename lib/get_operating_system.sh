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
    *)
      printf %b "${gs_kernel_name}"
      ;;
  esac

}