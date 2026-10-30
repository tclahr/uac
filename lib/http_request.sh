#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Send HTTP request using curl, optionally saving the response body and
# headers.
# Arguments:
#   string method: HTTP method
#   string url: url
#   string headers: HTTP headers
#   string payload_file: file sent as request body (optional)
#   string response_file: file the response body is written to (optional)
#   string response_headers_file: file the response headers are written to
#                                 (optional)
# Returns:
#   boolean: true on success
#            false on fail
_http_request()
{
  __hr_method="${1:-GET}"
  __hr_url="${2:-}"
  __hr_headers="${3:-}"
  __hr_payload_file="${4:-}"
  __hr_response_file="${5:-/dev/null}"
  __hr_response_headers_file="${6:-/dev/null}"

  # --fail is used when supported (see _setup_tools), otherwise HTTP errors
  # are reported as success
  __hr_verbose="${__UAC_TOOL_CURL_FAIL_OPTION}"
  ${__UAC_VERBOSE_MODE} && __hr_verbose="${__UAC_TOOL_CURL_FAIL_OPTION} --verbose"

  __hr_command="curl \
${__hr_verbose} \
--insecure \
--request ${__hr_method} \"${__hr_url}\" \
${__hr_headers} \
--output \"${__hr_response_file}\" \
--dump-header \"${__hr_response_headers_file}\""

  if [ -n "${__hr_payload_file}" ]; then
    __hr_command="${__hr_command} --upload-file \"${__hr_payload_file}\""
  else
    __hr_command="${__hr_command} --data \"\""
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__hr_command}"
  eval "${__hr_command}"

}
