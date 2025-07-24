#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# List available profiles.
# Arguments:
#   string profiles_dir: full path to the profiles directory
# Returns:
#   none
_list_profiles()
{
  __lp_profiles_dir="${1:-}"

  if [ ! -d "${__lp_profiles_dir}" ]; then
    _error_msg "Profiles directory '${__lp_profiles_dir}' does not exist."
    return 1
  fi

  printf "%s\n%s\n%s\n" \
"--------------------------------------------------------------------------------" \
"Profile Name : Description" \
"--------------------------------------------------------------------------------"
  for __lp_file in "${__lp_profiles_dir}"/*.yaml; do
    __lp_name=`sed -n 's|name\: *\(.*\)|\1|p' "${__lp_file}"`
    __lp_description=`sed -n 's|description\: *\(.*\)|\1|p' "${__lp_file}"`
    printf "%s : %s\n" "${__lp_name}" "${__lp_description}"
  done
  
  return 0
}