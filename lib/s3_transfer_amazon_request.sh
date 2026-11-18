#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Send a request to Amazon S3 signed with AWS Signature Version 4.
# The request is signed on each call, so retried requests are not rejected
# because the signature date is too old.
# Requests without response files are sent using _http_transfer (curl or
# wget), as only PUT is supported. Otherwise, _http_request (curl) is used.
# Arguments:
#   string method: HTTP method
#   string query: canonical query string (sorted and encoded)
#   string payload: payload (file or string)
#   string response_file: file the response body is written to (optional)
#   string response_headers_file: file the response headers are written to
#                                 (optional)
#   string host: host
#   string object_key: object key
#   string region: region
#   string access_key: access key
#   string secret_key: secret key
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_amazon_request()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  __s3ar_method="${1:-PUT}"
  shift
  __s3ar_query="${1:-}"
  shift
  __s3ar_payload="${1:-}"
  shift
  __s3ar_response_file="${1:-}"
  shift
  __s3ar_response_headers_file="${1:-}"
  shift
  __s3ar_host="${1:-}"
  shift
  __s3ar_object_key="${1:-}"
  shift
  __s3ar_region="${1:-us-east-1}"
  shift
  __s3ar_access_key="${1:-}"
  shift
  __s3ar_secret_key="${1:-}"

  if [ -f "${__s3ar_payload}" ]; then
    __s3ar_payload_hash=`openssl dgst -sha256 <"${__s3ar_payload}" | sed 's/^.* //'`
  else
    __s3ar_payload_hash=`printf "%s" "${__s3ar_payload}" | openssl dgst -sha256 | sed 's/^.* //'`
  fi

  __s3ar_url="https://${__s3ar_host}/${__s3ar_object_key}${__s3ar_query:+?}${__s3ar_query}"

  __s3ar_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
`_aws_sigv4_headers \
  "${__s3ar_method}" \
  "${__s3ar_object_key}" \
  "${__s3ar_query}" \
  "${__s3ar_payload_hash}" \
  "${__s3ar_host}" \
  "${__s3ar_region}" \
  "${__s3ar_access_key}" \
  "${__s3ar_secret_key}"`"

  if [ -z "${__s3ar_response_file}" ] && [ -z "${__s3ar_response_headers_file}" ]; then
    _http_transfer \
      "${__s3ar_payload}" \
      "${__s3ar_url}" \
      "${__s3ar_headers}"
  else
    _http_request \
      "${__s3ar_method}" \
      "${__s3ar_url}" \
      "${__s3ar_headers}" \
      "${__s3ar_payload}" \
      "${__s3ar_response_file}" \
      "${__s3ar_response_headers_file}"
  fi

}
