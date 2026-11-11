#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to IBM S3.
# Files larger than the part size are uploaded using multipart upload (curl
# only), as a single PUT request is limited to 5 GiB.
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
  __s3i_payload="${1:-Testing upload from shell script.}"
  __s3i_region="${2:-us-south}"
  __s3i_bucket="${3:-}"
  __s3i_token="${4:-}"

  # part size in MiB (100 MiB * 10000 parts = ~0.95 TiB max object size)
  __s3i_part_size=100

  __s3i_object_key=""

  if [ -f "${__s3i_payload}" ]; then
    __s3i_object_key="${__s3i_payload}"
  else
    __s3i_object_key="transfer_test_from_uac.txt"
  fi

  __s3i_host="s3.${__s3i_region}.cloud-object-storage.appdomain.cloud"
  __s3i_url="https://${__s3i_host}/${__s3i_bucket}/${__s3i_object_key}"

  if [ -f "${__s3i_payload}" ] && command_exists "curl"; then
    __s3i_file_size=`wc -c <"${__s3i_payload}" | awk '{print $1}'`
    # awk is used as expr may overflow on files larger than 2 GiB
    if awk "BEGIN { exit !(${__s3i_file_size} > ${__s3i_part_size} * 1048576) }"; then
      _s3_multipart_upload \
        "${__s3i_payload}" \
        "${__s3i_part_size}" \
        _s3_transfer_bearer_request \
        "${__s3i_url}" \
        "${__s3i_token}"
      return
    fi
  fi

  __s3i_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
  __s3i_authorization="Bearer ${__s3i_token}"

  __s3i_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Date: ${__s3i_date}\" \
--header \"Authorization: ${__s3i_authorization}\""

  _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
    _http_transfer \
    "${__s3i_payload}" \
    "${__s3i_url}" \
    "${__s3i_headers}"

}
