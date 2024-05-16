#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Transfer file to HTTP PUT receiver.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file
#   $2: HTTP PUT url
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
http_put_transfer()
{
  hp_source="${1:-}"
  hp_url="${2:-}"

  curl \
    --fail \
    --request PUT \
    --header "Content-Type: application/octet-stream" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --upload-file "${hp_source}" \
    "${hp_url}/${hp_source}"

}