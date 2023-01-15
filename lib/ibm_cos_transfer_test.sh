#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test the connectivity to IBM Cloud Object Storage.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: URL (https://[endpoint]/[bucket-name]/[object-key]).
#   $2: API key / token
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
ibm_cos_transfer_test()
{
  ib_url="${1:-}"
  ib_api_key="${2:-}"

  curl \
    --fail \
    --request PUT \
    --header "Authorization: Bearer ${ib_api_key}" \
    --header "Content-Type: application/text" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --data "Transfer test from UAC" \
    "${ib_url}"

}