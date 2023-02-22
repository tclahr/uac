#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Collector that searches and hashes files.
# Globals:
#   END_DATE_DAYS
#   GLOBAL_EXCLUDE_MOUNT_POINT
#   GLOBAL_EXCLUDE_NAME_PATTERN
#   GLOBAL_EXCLUDE_PATH_PATTERN
#   HASH_ALGORITHM
#   MD5_HASHING_TOOL
#   MOUNT_POINT
#   SHA1_HASHING_TOOL
#   SHA256_HASHING_TOOL
#   START_DATE_DAYS
#   TEMP_DATA_DIR
#   XARGS_REPLACE_STRING_SUPPORT
# Requires:
#   find_wrapper
#   get_mount_point_by_file_system
#   sanitize_filename
#   sanitize_path
#   sort_uniq_file
# Arguments:
#   $1: path
#   $2: is file list (optional) (default: false)
#   $3: path pattern (optional)
#   $4: name pattern (optional)
#   $5: exclude path pattern (optional)
#   $6: exclude name pattern (optional)
#   $7: exclude file system (optional)
#   $8: max depth (optional)
#   $9: file type (optional)
#   $10: min file size (optional)
#   $11: max file size (optional)
#   $12: permissions (optional)
#   $13: ignore date range (optional) (default: false)
#   $14: root output directory
#   $15: output directory (optional)
#   $16: output file
#   $17: stderr output file (optional)
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
hash_collector()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  hc_path="${1:-}"
  shift
  hc_is_file_list="${1:-false}"
  shift
  hc_path_pattern="${1:-}"
  shift
  hc_name_pattern="${1:-}"
  shift
  hc_exclude_path_pattern="${1:-}"
  shift
  hc_exclude_name_pattern="${1:-}"
  shift
  hc_exclude_file_system="${1:-}"
  shift
  hc_max_depth="${1:-}"
  shift
  hc_file_type="${1:-}"
  shift
  hc_min_file_size="${1:-}"
  shift
  hc_max_file_size="${1:-}"
  shift
  hc_permissions="${1:-}"
  shift
  hc_ignore_date_range="${1:-false}"
  shift
  hc_root_output_directory="${1:-}"
  shift
  hc_output_directory="${1:-}"
  shift
  hc_output_file="${1:-}"
  shift
  hc_stderr_output_file="${1:-}"
  
  # return if path is empty
  if [ -z "${hc_path}" ]; then
    printf %b "hash_collector: missing required argument: 'path'\n" >&2
    return 22
  fi

  # return if root output directory is empty
  if [ -z "${hc_root_output_directory}" ]; then
    printf %b "hash_collector: missing required argument: \
'root_output_directory'\n" >&2
    return 22
  fi

  # return if output file is empty
  if [ -z "${hc_output_file}" ]; then
    printf %b "hash_collector: missing required argument: 'output_file'\n" >&2
    return 22
  fi

  # prepend root output directory to path if it does not start with /
  # (which means local file)
  if echo "${hc_path}" | grep -q -v -E "^/"; then
    hc_path=`sanitize_path "${TEMP_DATA_DIR}/${hc_root_output_directory}/${hc_path}"`
  fi

  # return if is file list and file list does not exist
  if ${hc_is_file_list} && [ ! -f "${hc_path}" ]; then
    printf %b "hash_collector: file list does not exist: '${hc_path}'\n" >&2
    return 5
  fi

  # sanitize output file name
  hc_output_file=`sanitize_filename "${hc_output_file}"`

  if [ -n "${hc_stderr_output_file}" ]; then
    # sanitize stderr output file name
    hc_stderr_output_file=`sanitize_filename "${hc_stderr_output_file}"`
  else
    hc_stderr_output_file="${hc_output_file}.stderr"
  fi

  # sanitize output directory
  hc_output_directory=`sanitize_path \
    "${hc_root_output_directory}/${hc_output_directory}"`

  # create output directory if it does not exist
  if [ ! -d  "${TEMP_DATA_DIR}/${hc_output_directory}" ]; then
    mkdir -p "${TEMP_DATA_DIR}/${hc_output_directory}" >/dev/null
  fi

  ${hc_ignore_date_range} && hc_date_range_start_days="" \
    || hc_date_range_start_days="${START_DATE_DAYS}"
  ${hc_ignore_date_range} && hc_date_range_end_days="" \
    || hc_date_range_end_days="${END_DATE_DAYS}"
  
  # local exclude mount points
  if [ -n "${hc_exclude_file_system}" ]; then
    hc_exclude_mount_point=`get_mount_point_by_file_system \
      "${hc_exclude_file_system}"`
    hc_exclude_path_pattern="${hc_exclude_path_pattern},\
${hc_exclude_mount_point}"
  fi
  
  # global exclude mount points
  if [ -n "${GLOBAL_EXCLUDE_MOUNT_POINT}" ]; then
    hc_exclude_path_pattern="${hc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_MOUNT_POINT}"
  fi

  # global exclude path pattern
  if [ -n "${GLOBAL_EXCLUDE_PATH_PATTERN}" ]; then
    hc_exclude_path_pattern="${hc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_PATH_PATTERN}"
  fi

  # global exclude name pattern
  if [ -n "${GLOBAL_EXCLUDE_NAME_PATTERN}" ]; then
    hc_exclude_name_pattern="${hc_exclude_name_pattern},\
${GLOBAL_EXCLUDE_NAME_PATTERN}"
  fi

  # prepend mount point if is not file list
  ${hc_is_file_list} || hc_path=`sanitize_path "${MOUNT_POINT}/${hc_path}"`

  if is_element_in_list "md5" "${HASH_ALGORITHM}" \
    && [ -n "${MD5_HASHING_TOOL}" ]; then
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${MD5_HASHING_TOOL} \"{}\""
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        sort -u "${hc_path}" \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${MD5_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # find
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${MD5_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${MD5_HASHING_TOOL} \"{}\""
        
      fi
    else
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | while read %line%; do ${MD5_HASHING_TOOL} \"%line%\""
        # shellcheck disable=SC2162
        sort -u "${hc_path}" \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${MD5_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # shellcheck disable=SC2162
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${MD5_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | while read %line%; do ${MD5_HASHING_TOOL} \"%line%\""
      fi
    fi

    # sort and uniq output file
    sort_uniq_file "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5"

    # remove output file if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.md5" \
        >/dev/null
    fi

    # remove stderr output file if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
        >/dev/null
    fi

  fi

  if is_element_in_list "sha1" "${HASH_ALGORITHM}" \
    && [ -n "${SHA1_HASHING_TOOL}" ]; then
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${SHA1_HASHING_TOOL} \"{}\""
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        sort -u "${hc_path}" \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${SHA1_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # find
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${SHA1_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${SHA1_HASHING_TOOL} \"{}\""
      fi
    else
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | while read %line%; do ${SHA1_HASHING_TOOL} \"%line%\""
        # shellcheck disable=SC2162
        sort -u "${hc_path}" \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${SHA1_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # shellcheck disable=SC2162
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${SHA1_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | while read %line%; do ${SHA1_HASHING_TOOL} \"%line%\""
      fi
    fi

    # sort and uniq output file
    sort_uniq_file "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1"

    # remove output file if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha1" \
        >/dev/null
    fi

    # remove stderr output file if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
        >/dev/null
    fi

  fi

  if is_element_in_list "sha256" "${HASH_ALGORITHM}" \
    && [ -n "${SHA256_HASHING_TOOL}" ]; then
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${SHA256_HASHING_TOOL} \"{}\""
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        sort -u "${hc_path}" \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${SHA256_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # find
        # sort and uniq
        # escape single and double quotes
        # shellcheck disable=SC2086
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} ${SHA256_HASHING_TOOL} "{}" \
            >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} ${SHA256_HASHING_TOOL} \"{}\""
      fi
    else
      if ${hc_is_file_list}; then
        log_message COMMAND "sort -u \"${hc_path}\" | while read %line%; do ${SHA256_HASHING_TOOL} \"%line%\""
        # shellcheck disable=SC2162
        sort -u "${hc_path}" \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${SHA256_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
      else
        # shellcheck disable=SC2162
        find_wrapper \
          "${hc_path}" \
          "${hc_path_pattern}" \
          "${hc_name_pattern}" \
          "${hc_exclude_path_pattern}" \
          "${hc_exclude_name_pattern}" \
          "${hc_max_depth}" \
          "${hc_file_type}" \
          "${hc_min_file_size}" \
          "${hc_max_file_size}" \
          "${hc_permissions}" \
          "${hc_date_range_start_days}" \
          "${hc_date_range_end_days}" \
            2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
          | sort -u \
          | while read hc_line || [ -n "${hc_line}" ]; do
              ${SHA256_HASHING_TOOL} "${hc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" \
              2>>"${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}"
        log_message COMMAND "| sort -u | while read %line%; do ${SHA256_HASHING_TOOL} \"%line%\""
      fi
    fi

    # sort and uniq output file
    sort_uniq_file "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256"

    # remove output file if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_output_file}.sha256" \
        >/dev/null
    fi

    # remove stderr output file will be hidden if it is empty
    if [ ! -s "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" ]; then
      rm -f "${TEMP_DATA_DIR}/${hc_output_directory}/${hc_stderr_output_file}" \
        >/dev/null
    fi

  fi

}