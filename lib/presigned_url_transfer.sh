#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Transfer file to a presigned URL.
# Arguments:
#   string source: source file path
#   string url: presigned URL
# Returns:
#   boolean: true on success
#            false on fail
presigned_url_transfer()
{
  __pu_source="${1:-}"
  __pu_url="${2:-}"
  
  if command_exists "curl"; then
    __pu_command="curl \
--fail \
--insecure \
--request PUT \
--header \"x-ms-blob-type: BlockBlob\" \
--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--upload-file \"${__pu_source}\" \
\"${__pu_url}\""
  else
    __pu_command="wget \
-O - \
--quiet \
--no-check-certificate \
--method PUT \
--header \"x-ms-blob-type: BlockBlob\" \
--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--body-file \"${__pu_source}\" \
\"${__pu_url}\""
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__pu_command}"
	_run_command "${__pu_command}"

}