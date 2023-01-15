#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Sanitize artifact list.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: artifact list
# Outputs:
#   Write sanitized artifact list to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sanitize_artifact_list()
{
  sa_artifact_list="${1:-}"

  # remove ../
  # remove ./
  # replace !/ by !
  # remove 'artifacts/' directory
  # replace consecutive slashes by one slash
  # replace consecutive commas by one comma
  # remove leading and trailing comma
  echo "${sa_artifact_list}" \
    | sed -e 's:\.\./::g' \
          -e 's:\./::g' \
          -e 's:!/:!:g' \
          -e 's:artifacts/::g' \
          -e 's://*:/:g' \
          -e 's:,,*:,:g' \
          -e 's:^,::' \
          -e 's:,$::' \
      2>/dev/null

}