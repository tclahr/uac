#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Transfer file to Azure Storage SAS URL.
# Files larger than the Azure Storage Put Blob limit (5,000 MiB) are uploaded
# as a single block blob using Put Block and Put Block List.
# Arguments:
#   string payload: payload (file or string)
#   string url: azure storage sas url
# Returns:
#   boolean: true on success
#            false on fail
_azure_storage_sas_url_transfer()
{
  __au_payload="${1:-Testing upload from shell script.}"
  __au_url="${2:-}"

  # Azure Storage accepts at most 5,000 MiB in a single Put Blob request.
  __au_max_single_put_size=5242880000

  if [ -f "${__au_payload}" ]; then
    __au_file_size=`wc -c < "${__au_payload}" 2>/dev/null | awk '{ print $1 }'`

    if [ -n "${__au_file_size}" ]; then
      if awk -v size="${__au_file_size}" -v limit="${__au_max_single_put_size}" \
          'BEGIN { exit (size > limit ? 0 : 1) }'; then
        _azure_storage_block_upload "${__au_payload}" "${__au_url}" || return 1
        return 0
      fi
    fi
  fi

  __au_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

  __au_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"x-ms-blob-type: BlockBlob\" \
--header \"Date: ${__au_date}\""

  _http_transfer \
    "${__au_payload}" \
    "${__au_url}" \
    "${__au_headers}"

}
