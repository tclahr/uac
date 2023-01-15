#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Get profile file based on the profile name.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   $1: profile name
# Outputs:
#   Write profile file to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_profile_file()
{
  gp_profile_name="${1:-}"
  
  for gp_file in "${UAC_DIR}"/profiles/*.yaml; do
    if grep -q -E "name: +${gp_profile_name} *$" <"${gp_file}" 2>/dev/null; then
      echo "${gp_file}" | sed 's:.*/::' # strip directory from path
      break
    fi
  done

}