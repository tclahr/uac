#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file via HTTP PUT method.
# Arguments:
#   string payload: payload (file or string)
#   string url: url
#   string headers: HTTP headers
# Returns:
#   boolean: true on success
#            false on fail
_http_transfer()
{
  __ht_payload="${1:-Testing S3 upload from shell script.}"
  __ht_url="${2:-}"
  __ht_headers="${3:-}"

  if command_exists "curl"; then
    __ht_verbose="--fail"
    ${__UAC_VERBOSE_MODE} && __ht_verbose="--verbose"
    if [ -f "${__ht_payload}" ]; then
      __ht_command="curl \
${__ht_verbose} \
--insecure \
--request PUT \"${__ht_url}\" \
${__ht_headers} \
--upload-file \"${__ht_payload}\""
    else
      __ht_command="curl \
${__ht_verbose} \
--insecure \
--request PUT \"${__ht_url}\" \
${__ht_headers} \
--data \"${__ht_payload}\""
    fi
  
  else
    __ht_verbose="--quiet"
    ${__UAC_VERBOSE_MODE} && __ht_verbose="--verbose"
    if [ -f "${__ht_payload}" ]; then
      __ht_command="wget \
${__ht_verbose} \
--output-document - \
--no-check-certificate \
--method PUT \"${__ht_url}\" \
${__ht_headers} \
--body-file \"${__ht_payload}\""
    else
      __ht_command="wget \
${__ht_verbose} \
--output-document - \
--no-check-certificate \
--method PUT \"${__ht_url}\" \
${__ht_headers} \
--body-data \"${__ht_payload}\""
    fi
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__ht_command}"
	eval "${__ht_command}"

}
