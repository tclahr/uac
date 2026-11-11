#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Google S3.
# Files larger than the part size are uploaded using XML API multipart
# upload (curl only), so a failed part does not restart the whole upload.
# Arguments:
#   string payload: payload (file or string)
#   string bucket: bucket name
#   string token: bearer token
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_google()
{
  __s3g_payload="${1:-Testing upload from shell script.}"
  __s3g_bucket="${2:-}"
  __s3g_token="${3:-}"

  # part size in MiB (100 MiB * 10000 parts = ~0.95 TiB max object size)
  __s3g_part_size=100

  __s3g_object_key=""

  if [ -f "${__s3g_payload}" ]; then
    __s3g_object_key="${__s3g_payload}"
  else
    __s3g_object_key="transfer_test_from_uac.txt"
  fi

  __s3g_host="storage.googleapis.com"
  __s3g_url="https://${__s3g_host}/${__s3g_bucket}/${__s3g_object_key}"

  if [ -f "${__s3g_payload}" ] && command_exists "curl"; then
    __s3g_file_size=`wc -c <"${__s3g_payload}" | awk '{print $1}'`
    # awk is used as expr may overflow on files larger than 2 GiB
    if awk "BEGIN { exit !(${__s3g_file_size} > ${__s3g_part_size} * 1048576) }"; then
      _s3_multipart_upload \
        "${__s3g_payload}" \
        "${__s3g_part_size}" \
        _s3_transfer_bearer_request \
        "${__s3g_url}" \
        "${__s3g_token}"
      return
    fi
  fi

  __s3g_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
  __s3g_authorization="Bearer ${__s3g_token}"

  __s3g_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Date: ${__s3g_date}\" \
--header \"Authorization: ${__s3g_authorization}\""

  _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
    _http_transfer \
    "${__s3g_payload}" \
    "${__s3g_url}" \
    "${__s3g_headers}"

}
