#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Amazon S3.
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
  __s3a_payload="${1:-Testing S3 upload from shell script.}"
  __s3a_region="${2:-us-east-1}"
  __s3a_bucket="${3:-}"
  __s3a_access_key="${4:-}"
  __s3a_secret_key="${5:-}"

  __s3a_service="s3"
  __s3a_object_key=""

  if [ -f "${__s3a_payload}" ]; then
    __s3a_object_key="${__s3a_payload}"
    __s3a_payload_hash=`openssl dgst -sha256 <"${__s3a_payload}" | sed 's/^.* //'`
  else
    __s3a_object_key="transfer_test_from_uac.txt"
    __s3a_payload_hash=`printf "%s" "${__s3a_payload}" | openssl dgst -sha256 | sed 's/^.* //'`
  fi

  __s3a_host="${__s3a_bucket}.s3.${__s3a_region}.amazonaws.com"
  __s3a_url="https://${__s3a_host}/${__s3a_object_key}"

  __s3a_date=`date -u +"%Y%m%dT%H%M%SZ"`
  __s3a_short_date=`date -u +"%Y%m%d"`
  __s3a_algorithm="AWS4-HMAC-SHA256"
  __s3a_credential_scope="${__s3a_short_date}/${__s3a_region}/${__s3a_service}/aws4_request"

  __s3a_canonical_request="PUT
/${__s3a_object_key}

host:${__s3a_host}
x-amz-content-sha256:${__s3a_payload_hash}
x-amz-date:${__s3a_date}

host;x-amz-content-sha256;x-amz-date
${__s3a_payload_hash}"

  __s3a_canonical_request_hash=`printf "%s" "${__s3a_canonical_request}" | openssl dgst -sha256 | sed 's/^.* //'`

  __s3a_string_to_sign="${__s3a_algorithm}
${__s3a_date}
${__s3a_credential_scope}
${__s3a_canonical_request_hash}"

  __s3a_date_key=`printf "%s" "${__s3a_short_date}" | openssl dgst -sha256 -hmac "AWS4${__s3a_secret_key}" | sed 's/^.* //'`
  __s3a_region_key=`printf "%s" "${__s3a_region}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__s3a_date_key}" | sed 's/^.* //'`
  __s3a_service_key=`printf "%s" "${__s3a_service}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__s3a_region_key}" | sed 's/^.* //'`
  __s3a_signing_key=`printf "%s" "aws4_request" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__s3a_service_key}" | sed 's/^.* //'`
  __s3a_signature=`printf "%s" "${__s3a_string_to_sign}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__s3a_signing_key}" | sed 's/^.* //'`

  __s3a_authorization="${__s3a_algorithm} Credential=${__s3a_access_key}/${__s3a_credential_scope}, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=${__s3a_signature}"

  __s3a_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"x-amz-date: ${__s3a_date}\" \
--header \"x-amz-content-sha256: ${__s3a_payload_hash}\" \
--header \"Authorization: ${__s3a_authorization}\""

  _http_transfer \
    "${__s3a_payload}" \
    "${__s3a_url}" \
    "${__s3a_headers}"

}
