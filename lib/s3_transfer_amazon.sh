#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Amazon S3.
# Arguments:
#   string source: source file or empty for testing connection
#   string region: region
#   string bucket: bucket name
#   string access_key: access key
#   string secret_key: secret key
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_amazon()
{
  __s3a_source="${1:-}"
  __s3a_region="${2:-us-east-1}"
  __s3a_bucket="${3:-}"
  __s3a_access_key="${4:-}"
  __s3a_secret_key="${5:-}"
  __s3a_test_connectivity_mode=false

  if [ -z "${__s3a_source}" ]; then
    __s3a_test_connectivity_mode=true
    __s3a_source="transfer_test_from_uac.txt"
  fi

  __s3a_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
	__s3a_content_type="application/octet-stream"
  __s3a_host="${__s3a_bucket}.s3.${__s3a_region}.amazonaws.com"
  __s3a_string_to_sign="PUT\n\n${__s3a_content_type}\n${__s3a_date}\n/${__s3a_bucket}/${__s3a_source}"
  __s3a_signature=`printf "%b" "${__s3a_string_to_sign}" | openssl sha1 -hmac "${__s3a_secret_key}" -binary | openssl base64`
  __s3a_authorization="AWS ${__s3a_access_key}:${__s3a_signature}"
  __s3a_url="https://${__s3a_host}/${__s3a_source}"

  _http_transfer \
    "${__s3a_source}" \
    "${__s3a_url}" \
    "${__s3a_host}" \
    "${__s3a_date}" \
    "${__s3a_content_type}" \
    "${__s3a_authorization}" \
    "${__s3a_test_connectivity_mode}"

}
