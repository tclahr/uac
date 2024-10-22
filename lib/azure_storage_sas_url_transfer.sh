#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Azure Storage SAS URL.
# Arguments:
#   string source: source file or empty for testing connection
#   string url: azure storage sas url
# Returns:
#   boolean: true on success
#            false on fail
_azure_storage_sas_url_transfer()
{
  __au_source="${1:-}"
  __au_url="${2:-}"
  __au_test_connectivity_mode=false

  if [ -z "${__au_source}" ]; then
    __au_test_connectivity_mode=true
  fi

  __au_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
	__au_content_type="application/octet-stream"

  _http_transfer \
    "${__au_source}" \
    "${__au_url}" \
    "" \
    "${__au_date}" \
    "${__au_content_type}" \
    "" \
    "${__au_test_connectivity_mode}"

}
