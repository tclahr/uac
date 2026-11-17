#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Print the HTTP headers of a request signed with AWS Signature Version 4.
# Arguments:
#   string method: HTTP method
#   string object_key: object key
#   string query: canonical query string (sorted and encoded)
#   string payload_hash: SHA256 hash of the payload
#   string host: host
#   string region: region
#   string access_key: access key
#   string secret_key: secret key
# Returns:
#   string: HTTP headers
_aws_sigv4_headers()
{
  __as_method="${1:-PUT}"
  __as_object_key="${2:-}"
  __as_query="${3:-}"
  __as_payload_hash="${4:-}"
  __as_host="${5:-}"
  __as_region="${6:-us-east-1}"
  __as_access_key="${7:-}"
  __as_secret_key="${8:-}"

  __as_service="s3"
  __as_date=`date -u +"%Y%m%dT%H%M%SZ"`
  __as_short_date=`date -u +"%Y%m%d"`
  __as_algorithm="AWS4-HMAC-SHA256"
  __as_credential_scope="${__as_short_date}/${__as_region}/${__as_service}/aws4_request"

  __as_canonical_request="${__as_method}
/${__as_object_key}
${__as_query}
host:${__as_host}
x-amz-content-sha256:${__as_payload_hash}
x-amz-date:${__as_date}

host;x-amz-content-sha256;x-amz-date
${__as_payload_hash}"

  __as_canonical_request_hash=`printf "%s" "${__as_canonical_request}" | openssl dgst -sha256 | sed 's/^.* //'`

  __as_string_to_sign="${__as_algorithm}
${__as_date}
${__as_credential_scope}
${__as_canonical_request_hash}"

  __as_date_key=`printf "%s" "${__as_short_date}" | openssl dgst -sha256 -hmac "AWS4${__as_secret_key}" | sed 's/^.* //'`
  __as_region_key=`printf "%s" "${__as_region}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__as_date_key}" | sed 's/^.* //'`
  __as_service_key=`printf "%s" "${__as_service}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__as_region_key}" | sed 's/^.* //'`
  __as_signing_key=`printf "%s" "aws4_request" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__as_service_key}" | sed 's/^.* //'`
  __as_signature=`printf "%s" "${__as_string_to_sign}" | openssl dgst -sha256 -mac hmac -macopt hexkey:"${__as_signing_key}" | sed 's/^.* //'`

  __as_authorization="${__as_algorithm} Credential=${__as_access_key}/${__as_credential_scope}, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=${__as_signature}"

  printf "%s" "--header \"x-amz-date: ${__as_date}\" \
--header \"x-amz-content-sha256: ${__as_payload_hash}\" \
--header \"Authorization: ${__as_authorization}\""

}
