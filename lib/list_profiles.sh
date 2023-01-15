#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# List available profiles.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write available profiles to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
list_profiles()
{
  printf %b "--------------------------------------------------------------------------------\n"
  printf %b "Profile Name : Description\n"
  printf %b "--------------------------------------------------------------------------------\n"
  for lp_file in "${UAC_DIR}"/profiles/*.yaml; do
    lp_name=`grep -E "name: " <"${lp_file}" | sed -e 's/name: //'`
    lp_description=`grep -E "description: " <"${lp_file}" | sed -e 's/description: //'`
    printf %b "${lp_name} : ${lp_description}\n"
  done

}