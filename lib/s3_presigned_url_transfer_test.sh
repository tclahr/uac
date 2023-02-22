#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test the connectivity to S3 presigned URL.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: S3 presigned URL
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
s3_presigned_url_transfer_test()
{
  pr_s3_presigned_url="${1:-}"

  curl \
    --fail \
    --request PUT \
    --header "Content-Type: application/text" \
    --header "Accept: */*" \
    --header "Expect: 100-continue" \
    --data "Transfer test from UAC" \
    "${pr_s3_presigned_url}"

}