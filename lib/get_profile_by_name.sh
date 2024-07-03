#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the full path to the profile file based on the profile name.
# Arguments:
#   string profile_name: profile name
#   string profiles_dir: full path to the profiles directory
# Returns:
#   string: full path to the profile file
_get_profile_by_name()
{
  __gp_profile_name="${1:-}"
  __gp_profiles_dir="${2:-profiles}"

  for __gp_file in "${__gp_profiles_dir}"/*.yaml; do
    if grep -q -E "name: +${__gp_profile_name} *$" <"${__gp_file}" 2>/dev/null; then
      echo "${__gp_file}"
      break
    fi
  done 2>/dev/null

}