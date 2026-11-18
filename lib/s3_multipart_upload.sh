#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2003

# Upload file to a S3 compatible server using multipart upload.
# Each request is retried on failure, so a failed part does not restart the
# whole upload. The multipart upload is aborted if the upload fails.
# Arguments:
#   string file: file to be uploaded
#   integer part_size: part size in MiB
#   string request_function: function that sends the requests. It is called
#                            with the following arguments: method, query,
#                            payload_file, response_file,
#                            response_headers_file, followed by the
#                            request_function_arguments
#   string request_function_arguments: arguments passed to request_function
# Returns:
#   boolean: true on success
#            false on fail
_s3_multipart_upload()
{
  __smu_file="${1:-}"
  __smu_part_size="${2:-100}"
  __smu_request_function="${3:-}"
  shift 3

  __smu_part_file="${__smu_file}.part"
  __smu_response_file="${__smu_file}.response"
  __smu_response_headers_file="${__smu_file}.headers"
  __smu_complete_file="${__smu_file}.complete.xml"

  __smu_file_size=`wc -c <"${__smu_file}" | awk '{print $1}'`
  # awk is used as expr may overflow on files larger than 2 GiB
  __smu_part_count=`awk "BEGIN { b = ${__smu_part_size} * 1048576; printf \"%d\", (${__smu_file_size} + b - 1) / b }"`

  _verbose_msg "Initiating multipart upload..."
  __smu_upload_id=""
  if _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
      "${__smu_request_function}" \
      "POST" \
      "uploads=" \
      "" \
      "${__smu_response_file}" \
      "" \
      "$@"; then
    __smu_upload_id=`sed -n -e 's|.*<UploadId>\(.*\)</UploadId>.*|\1|p' "${__smu_response_file}"`
  fi
  if [ -z "${__smu_upload_id}" ]; then
    _error_msg "Failed to initiate multipart upload."
    rm -f "${__smu_response_file}"
    return 1
  fi
  __smu_upload_id=`printf "%s" "${__smu_upload_id}" \
    | sed -e 's|%|%25|g' -e 's|+|%2B|g' -e 's|/|%2F|g' -e 's|=|%3D|g'`

  printf "%s" "<CompleteMultipartUpload>" >"${__smu_complete_file}"

  __smu_return=0
  __smu_i=0
  while [ "${__smu_i}" -lt "${__smu_part_count}" ]; do
    __smu_skip=`expr "${__smu_i}" \* "${__smu_part_size}"`
    __smu_i=`expr "${__smu_i}" + 1`

    _verbose_msg "Uploading part ${__smu_i} of ${__smu_part_count}..."
    __smu_etag=""
    if dd \
        if="${__smu_file}" \
        of="${__smu_part_file}" \
        bs=1048576 \
        skip="${__smu_skip}" \
        count="${__smu_part_size}" >/dev/null 2>/dev/null \
      && _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
        "${__smu_request_function}" \
        "PUT" \
        "partNumber=${__smu_i}&uploadId=${__smu_upload_id}" \
        "${__smu_part_file}" \
        "" \
        "${__smu_response_headers_file}" \
        "$@"; then
      __smu_etag=`grep -i "^etag:" "${__smu_response_headers_file}" \
        | tail -n 1 \
        | tr -d "\r" \
        | sed -e 's|^[^:]*:[ ]*||'`
    fi
    if [ -z "${__smu_etag}" ]; then
      _error_msg "Failed to upload part ${__smu_i} of ${__smu_part_count}."
      __smu_return=1
      break
    fi
    printf "<Part><PartNumber>%s</PartNumber><ETag>%s</ETag></Part>" \
      "${__smu_i}" "${__smu_etag}" >>"${__smu_complete_file}"
  done

  rm -f "${__smu_part_file}" "${__smu_response_headers_file}"

  if [ "${__smu_return}" -eq 0 ]; then
    printf "%s" "</CompleteMultipartUpload>" >>"${__smu_complete_file}"
    _verbose_msg "Completing multipart upload..."
    _http_transfer_retry "${__UAC_TRANSFER_MAX_ATTEMPTS}" "${__UAC_TRANSFER_RETRY_DELAY}" \
      "${__smu_request_function}" \
      "POST" \
      "uploadId=${__smu_upload_id}" \
      "${__smu_complete_file}" \
      "${__smu_response_file}" \
      "" \
      "$@" \
      || __smu_return=1
    # complete request may return 200 OK with an error in the response body
    grep -q "<Error>" "${__smu_response_file}" 2>/dev/null && __smu_return=1
    [ "${__smu_return}" -ne 0 ] && _error_msg "Failed to complete multipart upload."
  fi

  if [ "${__smu_return}" -ne 0 ]; then
    # remove uploaded parts from the server, otherwise they are stored
    # (and charged) until the multipart upload is aborted
    _verbose_msg "Aborting multipart upload..."
    "${__smu_request_function}" \
      "DELETE" \
      "uploadId=${__smu_upload_id}" \
      "" \
      "${__smu_response_file}" \
      "" \
      "$@"
  fi

  rm -f "${__smu_response_file}" "${__smu_complete_file}"
  return ${__smu_return}

}
