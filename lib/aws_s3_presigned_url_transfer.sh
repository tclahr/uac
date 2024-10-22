#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Amazon S3 presigned URL.
# Arguments:
#   string source: source file or empty for testing connection
#   string url: presigned url
# Returns:
#   boolean: true on success
#            false on fail
_aws_s3_presigned_url_transfer()
{
  __aw_source="${1:-}"
  __aw_url="${2:-}"
  __aw_test_connectivity_mode=false

  if [ -z "${__aw_source}" ]; then
    __aw_test_connectivity_mode=true
  fi

  __aw_date=`date "+%a, %d %b %Y %H:%M:%S %z"`
	__aw_content_type="application/octet-stream"

  _http_transfer \
    "${__aw_source}" \
    "${__aw_url}" \
    "" \
    "${__aw_date}" \
    "${__aw_content_type}" \
    "" \
    "${__aw_test_connectivity_mode}"

}
