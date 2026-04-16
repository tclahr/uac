#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Returns a pipe delimited list of mount points that are using more than
# __UAC_CONF_EXCLUDE_MOUNT_SIZE kilobytes. Root file system will always
# be ignored.
#
# Arguments:
#   string os: operating system name
#   integer size: size in kilobytes
# Returns:
#   pipe delimited string, may be empty
_get_large_mount_points()
{
  __gl_os="${1:-}"
  __gl_size="${2:-0}"

  _get_mount_point_used_size "${__gl_os}" \
    | awk -F'|' -v __gl_size="${__gl_size}" '$1 != "/" && $2 > __gl_size {printf "%s%s", __sep, $1; __sep="|"} END {print ""}'
  
}
