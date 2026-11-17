#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2003

# Transfer file to Azure Storage SAS URL.
# Files larger than the block size are uploaded in blocks (Put Block and
# Put Block List), as a single Put Blob request is limited to 5000 MiB.
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

  # block size in MiB (100 MiB * 50000 blocks = ~4.8 TiB max blob size)
  __au_block_size=100

  __au_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

  __au_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"x-ms-blob-type: BlockBlob\" \
--header \"Date: ${__au_date}\""

  __au_block_count=1
  if [ -f "${__au_payload}" ]; then
    __au_file_size=`wc -c <"${__au_payload}" | awk '{print $1}'`
    # awk is used as expr may overflow on files larger than 2 GiB
    __au_block_count=`awk "BEGIN { b = ${__au_block_size} * 1048576; printf \"%d\", (${__au_file_size} + b - 1) / b }"`
  fi

  # retries are done per request, so a failed block does not restart the
  # whole upload (uncommitted blocks are kept by Azure for 7 days)
  if [ "${__au_block_count}" -le 1 ]; then
    _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
      _http_transfer \
      "${__au_payload}" \
      "${__au_url}" \
      "${__au_headers}"
    return
  fi

  __au_block_file="${__au_payload}.block"
  __au_block_list_file="${__au_payload}.blocklist.xml"

  __au_headers="--header \"Content-Type: application/octet-stream\" \
--header \"Accept: */*\" \
--header \"Expect: 100-continue\" \
--header \"Date: ${__au_date}\""

  printf "%s\n" '<?xml version="1.0" encoding="utf-8"?><BlockList>' \
    >"${__au_block_list_file}"

  __au_i=0
  while [ "${__au_i}" -lt "${__au_block_count}" ]; do
    # block ids must be valid base64 strings of the same length
    # 8 digits are valid base64 characters, so no encoding is needed
    __au_block_id=`printf "%08d" "${__au_i}"`
    __au_skip=`expr "${__au_i}" \* "${__au_block_size}"`
    __au_i=`expr "${__au_i}" + 1`

    _verbose_msg "Uploading block ${__au_i} of ${__au_block_count}..."
    if dd \
        if="${__au_payload}" \
        of="${__au_block_file}" \
        bs=1048576 \
        skip="${__au_skip}" \
        count="${__au_block_size}" >/dev/null 2>/dev/null \
      && _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
        _http_transfer \
        "${__au_block_file}" \
        "${__au_url}&comp=block&blockid=${__au_block_id}" \
        "${__au_headers}"; then
      printf "<Latest>%s</Latest>\n" "${__au_block_id}" >>"${__au_block_list_file}"
    else
      rm -f "${__au_block_file}" "${__au_block_list_file}"
      return 1
    fi
  done

  printf "%s\n" '</BlockList>' >>"${__au_block_list_file}"
  rm -f "${__au_block_file}"

  __au_headers="--header \"Content-Type: application/xml\" \
--header \"Accept: */*\" \
--header \"x-ms-blob-content-type: application/octet-stream\" \
--header \"Date: ${__au_date}\""

  _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
    _http_transfer \
    "${__au_block_list_file}" \
    "${__au_url}&comp=blocklist" \
    "${__au_headers}"
  __au_return=$?

  rm -f "${__au_block_list_file}"
  return ${__au_return}

}
