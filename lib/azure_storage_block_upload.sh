#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Upload a file to Azure Storage as a block blob using Put Block and Put Block List.
# The file is read in ranges, so the local file is not split and the result is a
# single blob. Use this for files larger than the 5,000 MiB Put Blob limit.
# Arguments:
#   string payload: file to upload
#   string url: Azure Storage SAS URL (container or blob)
#   integer block_size: optional block size in bytes (default: 268435456)
# Returns:
#   boolean: true on success
#            false on fail
_azure_storage_block_upload()
{
  __azb_payload="${1:-}"
  __azb_url="${2:-}"
  __azb_block_size="${3:-268435456}"

  if [ -f "${__azb_payload}" ]; then
    : # regular file, continue
  else
    _error_msg "_azure_storage_block_upload: file not found: '${__azb_payload}'"
    return 1
  fi

  if command_exists "curl"; then
    : # curl is required to stream block ranges without temporary files
  else
    _error_msg "Cannot upload files larger than 5000 MiB to Azure Storage: 'curl' not found."
    return 1
  fi

  __azb_file_size=`wc -c < "${__azb_payload}" 2>/dev/null | awk '{ print $1 }'`
  if [ -n "${__azb_file_size}" ]; then
    : # file size is available
  else
    _error_msg "Cannot determine the size of '${__azb_payload}'."
    return 1
  fi

  # Round the block size up to a whole MiB so dd can seek with bs=1048576.
  __azb_block_size=`awk -v size="${__azb_file_size}" -v bs="${__azb_block_size}" 'BEGIN {
    if (bs < 1048576) bs = 1048576
    bs = int((bs + 1048575) / 1048576) * 1048576
    if (bs > 4194304000) bs = 4194304000
    print bs
  }'`

  __azb_block_count=`awk -v size="${__azb_file_size}" -v bs="${__azb_block_size}" 'BEGIN {
    count = int((size + bs - 1) / bs)
    if (count < 1) count = 1
    print count
  }'`

  # Keep the number of blocks within the 50,000 block limit.
  if [ "${__azb_block_count}" -gt 50000 ]; then
    __azb_block_size=`awk -v size="${__azb_file_size}" 'BEGIN {
      bs = int((size + 49999) / 50000)
      bs = int((bs + 1048575) / 1048576) * 1048576
      if (bs > 4194304000) bs = 4194304000
      print bs
    }'`

    __azb_block_count=`awk -v size="${__azb_file_size}" -v bs="${__azb_block_size}" 'BEGIN {
      count = int((size + bs - 1) / bs)
      if (count < 1) count = 1
      print count
    }'`
  fi

  if [ "${__azb_block_count}" -gt 50000 ]; then
    _error_msg "Cannot upload '${__azb_payload}' as an Azure block blob: file is too large."
    return 1
  fi

  if [ -n "${__UAC_TEMP_DATA_DIR}" ] && [ -d "${__UAC_TEMP_DATA_DIR}" ]; then
    __azb_block_list_file="${__UAC_TEMP_DATA_DIR}/azure_storage_block_list.$$"
  else
    __azb_block_list_file="${TMPDIR:-/tmp}/uac_azure_storage_block_list.$$"
  fi

  printf '<?xml version="1.0" encoding="utf-8"?>\n<BlockList>\n' > "${__azb_block_list_file}" 2>/dev/null
  if [ -s "${__azb_block_list_file}" ]; then
    : # block list file created
  else
    _error_msg "Cannot create temporary block list file: '${__azb_block_list_file}'."
    return 1
  fi

  __azb_curl_flags="--fail"
  ${__UAC_VERBOSE_MODE} && __azb_curl_flags="${__azb_curl_flags} --verbose"

  __azb_index=0
  __azb_offset=0
  while [ "${__azb_index}" -lt "${__azb_block_count}" ]; do
    __azb_length=`awk -v size="${__azb_file_size}" -v offset="${__azb_offset}" -v bs="${__azb_block_size}" 'BEGIN {
      chunk = size - offset
      if (chunk > bs) chunk = bs
      print chunk
    }'`

    __azb_skip=`awk -v offset="${__azb_offset}" 'BEGIN { print int(offset / 1048576) }'`
    __azb_count=`awk -v chunk="${__azb_length}" 'BEGIN { print int((chunk + 1048575) / 1048576) }'`

    # Generate an 8-character Base64-safe block ID. The characters are from the
    # standard Base64 alphabet and the length is a multiple of four, so the ID
    # does not need percent-encoding in the query string.
    __azb_block_id=`awk -v n="${__azb_index}" 'BEGIN {
      chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      id = ""
      if (n == 0) id = "0"
      while (n > 0) {
        r = n % 62
        id = substr(chars, r + 1, 1) id
        n = int(n / 62)
      }
      while (length(id) < 8) id = "A" id
      print id
    }'`

    case "${__azb_url}" in
      *\?*) __azb_block_url="${__azb_url}&comp=block&blockid=${__azb_block_id}" ;;
      *) __azb_block_url="${__azb_url}?comp=block&blockid=${__azb_block_id}" ;;
    esac

    __azb_block_number=`awk -v n="${__azb_index}" 'BEGIN { print n + 1 }'`
    __azb_attempt=1
    __azb_uploaded=false
    while [ "${__azb_attempt}" -le 3 ]; do
      __azb_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

      _verbose_msg "Uploading block ${__azb_block_number} of ${__azb_block_count} (${__azb_length} bytes)..."

      if dd if="${__azb_payload}" bs=1048576 skip="${__azb_skip}" count="${__azb_count}" 2>/dev/null \
        | curl ${__azb_curl_flags} --insecure --request PUT "${__azb_block_url}" \
            --header "Content-Type: application/octet-stream" \
            --header "Accept: */*" \
            --header "Expect: 100-continue" \
            --header "Date: ${__azb_date}" \
            --header "x-ms-version: 2019-12-12" \
            --header "Transfer-Encoding:" \
            --header "Content-Length: ${__azb_length}" \
            --upload-file -; then
        __azb_uploaded=true
        break
      else
        __azb_attempt=`expr "${__azb_attempt}" + 1`
        if [ "${__azb_attempt}" -le 3 ]; then
          printf "Retrying block %s of %s...\n" "${__azb_block_number}" "${__azb_block_count}" >&2
          sleep 5
        fi
      fi
    done

    if [ "${__azb_uploaded}" = "true" ]; then
      printf '  <Latest>%s</Latest>\n' "${__azb_block_id}" >> "${__azb_block_list_file}"
      __azb_offset=`awk -v offset="${__azb_offset}" -v chunk="${__azb_length}" 'BEGIN { print offset + chunk }'`
      __azb_index=`expr "${__azb_index}" + 1`
    else
      _error_msg "Failed to upload block ${__azb_block_number} of ${__azb_block_count} to Azure Storage."
      rm -f "${__azb_block_list_file}" >/dev/null 2>/dev/null
      return 1
    fi
  done

  printf '</BlockList>\n' >> "${__azb_block_list_file}"

  case "${__azb_url}" in
    *\?*) __azb_block_list_url="${__azb_url}&comp=blocklist" ;;
    *) __azb_block_list_url="${__azb_url}?comp=blocklist" ;;
  esac

  __azb_attempt=1
  __azb_committed=false
  while [ "${__azb_attempt}" -le 3 ]; do
    __azb_date=`date "+%a, %d %b %Y %H:%M:%S %z"`

    _verbose_msg "Committing ${__azb_block_count} block(s) to Azure Storage..."

    if curl ${__azb_curl_flags} --insecure --request PUT "${__azb_block_list_url}" \
        --header "Content-Type: application/xml" \
        --header "Accept: */*" \
        --header "Expect: 100-continue" \
        --header "Date: ${__azb_date}" \
        --header "x-ms-version: 2019-12-12" \
        --header "x-ms-blob-content-type: application/octet-stream" \
        --data-binary "@${__azb_block_list_file}"; then
      __azb_committed=true
      break
    else
      __azb_attempt=`expr "${__azb_attempt}" + 1`
      if [ "${__azb_attempt}" -le 3 ]; then
        printf "Retrying block list commit...\n" >&2
        sleep 5
      fi
    fi
  done

  rm -f "${__azb_block_list_file}" >/dev/null 2>/dev/null

  if [ "${__azb_committed}" = "true" ]; then
    return 0
  else
    _error_msg "Failed to commit the block list to Azure Storage."
    return 1
  fi

}
