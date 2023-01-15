#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test the connectivity to Azure Storage SAS URL.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: Azure Storage SAS URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
azure_storage_sas_url_transfer_test()
{
  ab_azure_storage_sas_url="${1:-}"

  curl \
    --fail \
    --request PUT \
    --header "x-ms-blob-type: BlockBlob" \
    --header "Content-Type: application/text" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --data "Transfer test from UAC" \
    "${ab_azure_storage_sas_url}"

}