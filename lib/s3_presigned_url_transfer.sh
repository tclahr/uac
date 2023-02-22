#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Transfer file to S3 presigned URL.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file
#   $2: S3 presigned URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
s3_presigned_url_transfer()
{
  pu_source="${1:-}"
  pu_s3_presigned_url="${2:-}"

  curl \
    --fail \
    --request PUT \
    --header "Content-Type: application/octet-stream" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --upload-file "${pu_source}" \
    "${pu_s3_presigned_url}"

}