#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Amazon S3.
# Files larger than the part size are uploaded using multipart upload (curl
# only), as a single PUT request is limited to 5 GiB.
# Arguments:
#   string payload: payload (file or string)
#   string region: region
#   string bucket: bucket name
#   string access_key: access key
#   string secret_key: secret key
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_amazon()
{
  __s3a_payload="${1:-Testing upload from shell script.}"
  __s3a_region="${2:-us-east-1}"
  __s3a_bucket="${3:-}"
  __s3a_access_key="${4:-}"
  __s3a_secret_key="${5:-}"

  # part size in MiB (100 MiB * 10000 parts = ~0.95 TiB max object size)
  __s3a_part_size=100

  __s3a_object_key=""

  if [ -f "${__s3a_payload}" ]; then
    __s3a_object_key="${__s3a_payload}"
  else
    __s3a_object_key="transfer_test_from_uac.txt"
  fi

  __s3a_prefix=`echo "${__s3a_bucket}" | sed 's|^[^/]*/*||;s|/*$||'`

  if [ -n "${__s3a_prefix}" ]; then
    __s3a_object_key="${__s3a_prefix}/${__s3a_object_key}"
    __s3a_bucket=`echo "${__s3a_bucket}" | sed 's|/.*||'`
  fi

  __s3a_host="${__s3a_bucket}.s3.${__s3a_region}.amazonaws.com"

  if [ -f "${__s3a_payload}" ] && command_exists "curl"; then
    __s3a_file_size=`wc -c <"${__s3a_payload}" | awk '{print $1}'`
    # awk is used as expr may overflow on files larger than 2 GiB
    if awk "BEGIN { exit !(${__s3a_file_size} > ${__s3a_part_size} * 1048576) }"; then
      _s3_multipart_upload \
        "${__s3a_payload}" \
        "${__s3a_part_size}" \
        _s3_transfer_amazon_request \
        "${__s3a_host}" \
        "${__s3a_object_key}" \
        "${__s3a_region}" \
        "${__s3a_access_key}" \
        "${__s3a_secret_key}"
      return
    fi
  fi

  _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
    _s3_transfer_amazon_request \
    "PUT" \
    "" \
    "${__s3a_payload}" \
    "" \
    "" \
    "${__s3a_host}" \
    "${__s3a_object_key}" \
    "${__s3a_region}" \
    "${__s3a_access_key}" \
    "${__s3a_secret_key}"

}
