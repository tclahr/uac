#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test the connectivity to HTTP PUT server.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: HTTP PUT URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
http_put_transfer_test()
{
  ht_url="${1:-}"

  curl \
    --fail \
    --request PUT \
    --header "Content-Type: application/text" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --data "Transfer test from UAC" \
    "${ht_url}"

}