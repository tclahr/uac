#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Send a request to a S3 compatible server (Google, IBM) using bearer token
# authentication.
# Arguments:
#   string method: HTTP method
#   string query: query string
#   string payload_file: file sent as request body (optional)
#   string response_file: file the response body is written to (optional)
#   string response_headers_file: file the response headers are written to
#                                 (optional)
#   string url: object url
#   string token: bearer token
# Returns:
#   boolean: true on success
#            false on fail
_s3_transfer_bearer_request()
{
  __s3br_method="${1:-PUT}"
  __s3br_query="${2:-}"
  __s3br_payload_file="${3:-}"
  __s3br_response_file="${4:-}"
  __s3br_response_headers_file="${5:-}"
  __s3br_url="${6:-}"
  __s3br_token="${7:-}"

  __s3br_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

  __s3br_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Date: ${__s3br_date}\" \
--header \"Authorization: Bearer ${__s3br_token}\""

  _http_request \
    "${__s3br_method}" \
    "${__s3br_url}${__s3br_query:+?}${__s3br_query}" \
    "${__s3br_headers}" \
    "${__s3br_payload_file}" \
    "${__s3br_response_file}" \
    "${__s3br_response_headers_file}"

}
