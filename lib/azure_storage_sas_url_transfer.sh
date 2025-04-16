#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Azure Storage SAS URL.
# Arguments:
#   string payload: payload (file or string)
#   string url: azure storage sas url
# Returns:
#   boolean: true on success
#            false on fail
_azure_storage_sas_url_transfer()
{
  __au_payload="${1:-Testing S3 upload from shell script.}"
  __au_url="${2:-}"

  __au_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

  __au_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"x-ms-blob-type: BlockBlob\" \
--header \"Date: ${__au_date}\""

  _http_transfer \
    "${__au_payload}" \
    "${__au_url}" \
    "${__au_headers}"

}
