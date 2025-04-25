#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Amazon S3 presigned URL.
# Arguments:
#   string payload: payload (file or string)
#   string url: presigned url
# Returns:
#   boolean: true on success
#            false on fail
_aws_s3_presigned_url_transfer()
{
  __aw_payload="${1:-Testing S3 upload from shell script.}"
  __aw_url="${2:-}"

  __aw_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

  __aw_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"Date: ${__aw_date}\""

  _http_transfer \
    "${__aw_payload}" \
    "${__aw_url}" \
    "${__aw_headers}"

}
