#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Transfer file to IBM Cloud Object Storage.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file
#   $2: URL (https://[endpoint]/[bucket-name]/[object-key]).
#   $3: API key / token
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
ibm_cos_transfer()
{
  it_source="${1:-}"
  it_url="${2:-}"
  it_api_key="${3:-}"

  curl \
    --fail \
    --request PUT \
    --header "Authorization: Bearer ${it_api_key}" \
    --header "Content-Type: application/octet-stream" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --upload-file "${it_source}" \
    "${it_url}"

}