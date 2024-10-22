#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file via HTTP PUT method.
# Arguments:
#   string source: source file
#   string url: url
#   string header_host: host header value
#   string header_date: date header value
#   string header_content_type: content type header value
#   string header_authorization: authorization header value
#   boolean test_connectivity_mode: transfer testing data if true (default: false)
# Returns:
#   boolean: true on success
#            false on fail
_http_transfer()
{
  __ht_source="${1:-}"
  __ht_url="${2:-}"
  __ht_header_host="${3:-}"
  __ht_header_date="${4:-}"
  __ht_header_content_type="${5:-}"
  __ht_header_authorization="${6:-}"
  __ht_test_connectivity_mode="${7:-false}"

  if command_exists "curl"; then
    __ht_data="--upload-file \"${__ht_source}\""
    ${__ht_test_connectivity_mode} && __ht_data="--data \"Transfer test from UAC\""
    __ht_verbose="--fail"
    ${__UAC_VERBOSE_MODE} && __ht_verbose="--verbose"
    
    __ht_command="curl \
${__ht_verbose} \
--insecure \
--request PUT"

  else
    __ht_data="--body-file \"${__ht_source}\""
    ${__ht_test_connectivity_mode} && __ht_data="--body-data \"Transfer test from UAC\""
    __ht_verbose="--quiet"
    ${__UAC_VERBOSE_MODE} && __ht_verbose="--verbose"
		
    __ht_command="wget \
--output-document - \
${__ht_verbose} \
--no-check-certificate \
--method PUT"
  fi

  if [ -n "${__ht_header_host}" ]; then
    __ht_command="${__ht_command} \
--header \"Host: ${__ht_header_host}\""
  fi

  __ht_command="${__ht_command} \
--header \"Date: ${__ht_header_date}\" \
--header \"Content-Type: ${__ht_header_content_type}\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"x-ms-blob-type: BlockBlob\""

  if [ -n "${__ht_header_authorization}" ]; then
    __ht_command="${__ht_command} \
--header \"Authorization: ${__ht_header_authorization}\""
  fi

  __ht_command="${__ht_command} \
${__ht_data} \
\"${__ht_url}\""

	_verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__ht_command}"
	eval "${__ht_command}"

}
