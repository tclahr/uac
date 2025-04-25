#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Google S3.
# Arguments:
#   string payload: payload (file or string)
#   string bucket: bucket name
#   string token: bearer token
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_google()
{
  __s3g_payload="${1:-Testing S3 upload from shell script.}"
  __s3g_bucket="${2:-}"
  __s3g_token="${3:-}"

  __s3g_object_key=""

  if [ -f "${__s3g_payload}" ]; then
    __s3g_object_key="${__s3g_payload}"
  else
    __s3g_object_key="transfer_test_from_uac.txt"
  fi

  __s3g_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
  __s3g_host="storage.googleapis.com"
  __s3g_authorization="Bearer ${__s3g_token}"
  __s3g_url="https://${__s3g_host}/${__s3g_bucket}/${__s3g_object_key}"

  __s3g_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Date: ${__s3g_date}\" \
--header \"Authorization: ${__s3g_authorization}\""

  _http_transfer \
    "${__s3g_payload}" \
    "${__s3g_url}" \
    "${__s3g_headers}"

}
