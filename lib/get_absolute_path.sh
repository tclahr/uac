#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the absolute path from relative path.
# Arguments:
#   string path: relative path
# Returns:
#   string: absolute path
_get_absolute_path()
{
  __ga_path="${1:-}"
  
  ( cd "${__ga_path}" && pwd )
}