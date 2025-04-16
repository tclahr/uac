#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to IBM S3.
# Arguments:
#   string payload: payload (file or string)
#   string region: region
#   string bucket: bucket name
#   string token: bearer token
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_ibm()
{
  __s3i_payload="${1:-Testing S3 upload from shell script.}"
  __s3i_region="${2:-us-south}"
  __s3i_bucket="${3:-}"
  __s3i_token="${4:-}"
  
  __s3i_object_key=""

  if [ -f "${__s3i_payload}" ]; then
    __s3i_object_key="${__s3i_payload}"
  else 
    __s3i_object_key="transfer_test_from_uac.txt"
  fi

  __s3i_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
  __s3i_host="s3.${__s3i_region}.cloud-object-storage.appdomain.cloud"
  __s3i_authorization="Bearer ${__s3i_token}"
  __s3i_url="https://${__s3i_host}/${__s3i_bucket}/${__s3i_object_key}"

  __s3i_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Date: ${__s3i_date}\" \
--header \"Authorization: ${__s3i_authorization}\""

  _http_transfer \
    "${__s3i_payload}" \
    "${__s3i_url}" \
    "${__s3i_headers}"

}
