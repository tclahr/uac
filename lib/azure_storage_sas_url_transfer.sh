#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Transfer file to Azure Storage SAS URL.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file
#   $2: Azure Storage SAS URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
azure_storage_sas_url_transfer()
{
  au_source="${1:-}"
  au_azure_storage_sas_url="${2:-}"

  curl \
    --fail \
    --request PUT \
    --header "x-ms-blob-type: BlockBlob" \
    --header "Content-Type: application/octet-stream" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --upload-file "${au_source}" \
    "${au_azure_storage_sas_url}"

}