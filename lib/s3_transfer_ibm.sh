#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to IBM S3.
# Arguments:
#   string source: source file or empty for testing connection
#   string region: region
#   string bucket: bucket name
#   string token: bearer token
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_ibm()
{
  __s3i_source="${1:-}"
  __s3i_region="${2:-us-south}"
  __s3i_bucket="${3:-}"
  __s3i_token="${4:-}"
  __s3i_test_connectivity_mode=false

  if [ -z "${__s3i_source}" ]; then
    __s3i_test_connectivity_mode=true
    __s3i_source="transfer_test_from_uac.txt"
  fi

  __s3i_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
	__s3i_content_type="application/octet-stream"
  __s3i_host="s3.${__s3i_region}.cloud-object-storage.appdomain.cloud"
  __s3i_authorization="Bearer ${__s3i_token}"
  __s3i_url="https://${__s3i_host}/${__s3i_bucket}/${__s3i_source}"

  _http_transfer \
    "${__s3i_source}" \
    "${__s3i_url}" \
    "${__s3i_host}" \
    "${__s3i_date}" \
    "${__s3i_content_type}" \
    "${__s3i_authorization}" \
    "${__s3i_test_connectivity_mode}"

}
