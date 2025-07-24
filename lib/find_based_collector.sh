#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2153

# Find-based collectors.
# Arguments:
#   string collector: collector name
#   string path: path
#   string mount_point: mount point (default: /)
#   boolean is_file_list: path points to an existing file list (optional) (default: false)
#   string path_pattern: pipe-separated list of path patterns (optional)
#   string name_pattern: pipe-separated list of name patterns (optional)
#   string exclude_path_pattern: pipe-separated list of exclude path patterns (optional)
#   string exclude_name_pattern: pipe-separated list of exclude name patterns (optional)
#   string exclude_file_system: pipe-separated list of exclude file system name (optional)
#   integer max_depth: max depth (optional)
#   string file_type: file type (optional)
#   integer min_file_size: minimum file size (optional)
#   integer max_file_size: maximum file size (optional)
#   string permissions: permissions (optional)
#   boolean no_group: no group corresponds to file's numeric group ID (optional)
#   boolean no_user: No user corresponds to file's numeric user ID (optional)
#   boolean ignore_date_range: ignore date range (optional) (default: false)
#   string output_directory: full path to the output directory
#   string output_file: output file name
# Returns:
#   boolean: true on success
#            false on fail
_find_based_collector()
{
  __fc_collector="${1:-}"
  shift
  __fc_path="${1:-}"
  #shift
  #__fc_mount_point="${1:-/}"
  shift
  __fc_is_file_list="${1:-false}"
  shift
  __fc_path_pattern="${1:-}"
  shift
  __fc_name_pattern="${1:-}"
  shift
  __fc_exclude_path_pattern="${1:-}"
  shift
  __fc_exclude_name_pattern="${1:-}"
  shift
  __fc_exclude_file_system="${1:-}"
  shift
  __fc_max_depth="${1:-}"
  shift
  __fc_file_type="${1:-}"
  shift
  __fc_min_file_size="${1:-}"
  shift
  __fc_max_file_size="${1:-}"
  shift
  __fc_permissions="${1:-}"
  shift
  __fc_no_group="${1:-false}"
  shift
  __fc_no_user="${1:-false}"
  shift
  __fc_ignore_date_range="${1:-false}"
  shift
  __fc_output_directory="${1:-}"
  shift
  __fc_output_file="${1:-}"

  if [ "${__fc_collector}" != "file" ] \
    && [ "${__fc_collector}" != "find" ] \
    && [ "${__fc_collector}" != "hash" ] \
    && [ "${__fc_collector}" != "stat" ]; then
    _log_msg ERR "_find_based_collector: Invalid collector: '${__fc_collector}'"
    return 1
  fi

  if [ -z "${__fc_path}" ]; then
    _log_msg ERR "_find_based_collector: Empty path parameter"
    return 1
  fi

  if [ -z "${__fc_output_directory}" ]; then
    _log_msg ERR "_find_based_collector: Empty output_directory parameter"
    return 1
  fi

  if [ -z "${__fc_output_file}" ]; then
    _log_msg ERR "_find_based_collector: Empty output_file parameter"
    return 1
  fi

  if ${__fc_is_file_list}; then
    # prepend __UAC_TEMP_DATA_DIR/collected if path does not start with /
    if echo "${__fc_path}" | grep -q -v -E "^/"; then
      __fc_path="${__UAC_TEMP_DATA_DIR}/collected/${__fc_path}"
    fi
    __fc_path=`_sanitize_path "${__fc_path}"`
    if [ ! -f "${__fc_path}" ]; then
      _log_msg ERR "_find_based_collector: No such file or directory: '${__fc_path}'"
      return 1
    fi
  else
    # prepend mount point to path if mount point is not /
    if [ "${__UAC_MOUNT_POINT}" = "/" ]; then
      __fc_path=`_sanitize_path "${__fc_path}"`
    else
      __fc_path=`_prepend_mount_point "${__fc_path}" "${__UAC_MOUNT_POINT}"`
    fi

    # exclude path pattern (global)
    if [ -n "${__UAC_CONF_EXCLUDE_PATH_PATTERN}" ]; then
      __fc_exclude_path_pattern="${__fc_exclude_path_pattern}${__fc_exclude_path_pattern:+|}${__UAC_CONF_EXCLUDE_PATH_PATTERN}"
    fi

    # exclude file systems / mount points (local)
    if [ -n "${__fc_exclude_file_system}" ]; then
      __fc_exclude_mount_points=`_get_mount_point_by_file_system "${__fc_exclude_file_system}" "${__UAC_OPERATING_SYSTEM}"`
      __fc_exclude_path_pattern="${__fc_exclude_path_pattern}${__fc_exclude_path_pattern:+|}${__fc_exclude_mount_points}"
    fi

    # exclude file systems / mount points (global)
    if [ -n "${__UAC_EXCLUDE_MOUNT_POINTS}" ]; then
      __fc_exclude_path_pattern="${__fc_exclude_path_pattern}${__fc_exclude_path_pattern:+|}${__UAC_EXCLUDE_MOUNT_POINTS}"
    fi

    # add __UAC_DIR and __UAC_TEMP_DATA_DIR to exclude path pattern
    __fc_exclude_path_pattern="${__fc_exclude_path_pattern}${__fc_exclude_path_pattern:+|}${__UAC_DIR}|${__UAC_TEMP_DATA_DIR}"

    # exclude name pattern (global)
    if [ -n "${__UAC_CONF_EXCLUDE_NAME_PATTERN}" ]; then
      __fc_exclude_name_pattern="${__fc_exclude_name_pattern}${__fc_exclude_name_pattern:+|}${__UAC_CONF_EXCLUDE_NAME_PATTERN}"
    fi

    __fc_start_date_days="${__UAC_START_DATE_DAYS}"
    __fc_end_date_days="${__UAC_END_DATE_DAYS}"

    ${__fc_ignore_date_range} && { __fc_start_date_days="0"; __fc_end_date_days="0"; }
  fi

  __fc_output_directory=`_sanitize_output_directory "${__fc_output_directory}"`
  __fc_output_file=`_sanitize_output_file "${__fc_output_file}" "${__fc_output_directory}"`

  if [ ! -d  "${__fc_output_directory}" ]; then
    mkdir -p "${__fc_output_directory}" >/dev/null
  fi

  case "${__fc_collector}" in
    "file"|"find")
      if ${__fc_is_file_list}; then
        __fc_find_command="cat \"${__fc_path}\""
      else
        __fc_find_command=`_build_find_command \
          "${__fc_path}" \
          "${__fc_path_pattern}" \
          "${__fc_name_pattern}" \
          "${__fc_exclude_path_pattern}" \
          "${__fc_exclude_name_pattern}" \
          "${__fc_max_depth}" \
          "${__fc_file_type}" \
          "${__fc_min_file_size}" \
          "${__fc_max_file_size}" \
          "${__fc_permissions}" \
          "${__fc_no_group}" \
          "${__fc_no_user}" \
          "" \
          "${__fc_start_date_days}" \
          "${__fc_end_date_days}"`
      fi
      _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__fc_find_command}"
      _run_command "${__fc_find_command}" \
        >>"${__fc_output_directory}/${__fc_output_file}"
      ;;
    "hash")
      for __fc_algorithm in `echo "${__UAC_CONF_HASH_ALGORITHM}" | sed -e 's:|: :g'`; do
        
        __fc_hashing_tool=""
        if [ "${__fc_algorithm}" = "md5" ]; then
          __fc_hashing_tool="${__UAC_TOOL_MD5_BIN}"
        elif [ "${__fc_algorithm}" = "sha1" ]; then
          __fc_hashing_tool="${__UAC_TOOL_SHA1_BIN}"
        elif [ "${__fc_algorithm}" = "sha256" ]; then
          __fc_hashing_tool="${__UAC_TOOL_SHA256_BIN}"
        fi

        if [ -n "${__fc_hashing_tool}" ]; then
          if ${__fc_is_file_list}; then
            __fc_hash_command="sed 's|.|\\\\&|g' \"${__fc_path}\" | xargs ${__fc_hashing_tool}"
          elif ${__UAC_TOOL_FIND_PRINT0_SUPPORT} && ${__UAC_TOOL_XARGS_NULL_DELIMITER_SUPPORT}; then
            __fc_find_command=`_build_find_command \
              "${__fc_path}" \
              "${__fc_path_pattern}" \
              "${__fc_name_pattern}" \
              "${__fc_exclude_path_pattern}" \
              "${__fc_exclude_name_pattern}" \
              "${__fc_max_depth}" \
              "${__fc_file_type}" \
              "${__fc_min_file_size}" \
              "${__fc_max_file_size}" \
              "${__fc_permissions}" \
              "${__fc_no_group}" \
              "${__fc_no_user}" \
              "true" \
              "${__fc_start_date_days}" \
              "${__fc_end_date_days}"`
            if echo "${__fc_find_command}" | grep -q -E "; $"; then
              __fc_find_command="{ ${__fc_find_command} }"
            fi
            __fc_hash_command="${__fc_find_command} | xargs -0 ${__fc_hashing_tool}"
          else
            __fc_find_command=`_build_find_command \
              "${__fc_path}" \
              "${__fc_path_pattern}" \
              "${__fc_name_pattern}" \
              "${__fc_exclude_path_pattern}" \
              "${__fc_exclude_name_pattern}" \
              "${__fc_max_depth}" \
              "${__fc_file_type}" \
              "${__fc_min_file_size}" \
              "${__fc_max_file_size}" \
              "${__fc_permissions}" \
              "${__fc_no_group}" \
              "${__fc_no_user}" \
              "" \
              "${__fc_start_date_days}" \
              "${__fc_end_date_days}"`
            if echo "${__fc_find_command}" | grep -q -E "; $"; then
              __fc_find_command="{ ${__fc_find_command} }"
            fi
            __fc_hash_command="${__fc_find_command} | sed 's|.|\\\\&|g' | xargs ${__fc_hashing_tool}"
          fi
          _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__fc_hash_command}"
          _run_command "${__fc_hash_command}" \
            >>"${__fc_output_directory}/${__fc_output_file}.${__fc_algorithm}"
          if [ ! -s "${__fc_output_directory}/${__fc_output_file}.${__fc_algorithm}" ]; then
            rm -f "${__fc_output_directory}/${__fc_output_file}.${__fc_algorithm}" >/dev/null
            _log_msg DBG "Empty output file: '${__fc_output_file}.${__fc_algorithm}'"
          fi
        fi
      done
      ;;
    "stat")
      if [ -n "${__UAC_TOOL_STAT_BIN}" ]; then
        if ${__fc_is_file_list}; then
            __fc_stat_command="sed 's|.|\\\\&|g' \"${__fc_path}\" | xargs ${__UAC_TOOL_STAT_BIN}${__UAC_TOOL_STAT_PARAMS:+ }${__UAC_TOOL_STAT_PARAMS}"
        elif ${__UAC_TOOL_FIND_PRINT0_SUPPORT} && ${__UAC_TOOL_XARGS_NULL_DELIMITER_SUPPORT}; then
          __fc_find_command=`_build_find_command \
            "${__fc_path}" \
            "${__fc_path_pattern}" \
            "${__fc_name_pattern}" \
            "${__fc_exclude_path_pattern}" \
            "${__fc_exclude_name_pattern}" \
            "${__fc_max_depth}" \
            "${__fc_file_type}" \
            "${__fc_min_file_size}" \
            "${__fc_max_file_size}" \
            "${__fc_permissions}" \
            "${__fc_no_group}" \
            "${__fc_no_user}" \
            "true" \
            "${__fc_start_date_days}" \
            "${__fc_end_date_days}"`
          if echo "${__fc_find_command}" | grep -q -E "; $"; then
            __fc_find_command="{ ${__fc_find_command} }"
          fi
          __fc_stat_command="${__fc_find_command} | xargs -0 ${__UAC_TOOL_STAT_BIN}${__UAC_TOOL_STAT_PARAMS:+ }${__UAC_TOOL_STAT_PARAMS}"
        else
          __fc_find_command=`_build_find_command \
            "${__fc_path}" \
            "${__fc_path_pattern}" \
            "${__fc_name_pattern}" \
            "${__fc_exclude_path_pattern}" \
            "${__fc_exclude_name_pattern}" \
            "${__fc_max_depth}" \
            "${__fc_file_type}" \
            "${__fc_min_file_size}" \
            "${__fc_max_file_size}" \
            "${__fc_permissions}" \
            "${__fc_no_group}" \
            "${__fc_no_user}" \
            "" \
            "${__fc_start_date_days}" \
            "${__fc_end_date_days}"`
          if echo "${__fc_find_command}" | grep -q -E "; $"; then
            __fc_find_command="{ ${__fc_find_command} }"
          fi
          __fc_stat_command="${__fc_find_command} | sed 's|.|\\\\&|g' | xargs ${__UAC_TOOL_STAT_BIN}${__UAC_TOOL_STAT_PARAMS:+ }${__UAC_TOOL_STAT_PARAMS}"
        fi
        _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__fc_stat_command}"
        _run_command "${__fc_stat_command}" \
          | sed -e "s:|':|:g" \
                -e "s:'|:|:g" \
                -e "s:' -> ': -> :" \
                -e 's:|":|:g' \
                -e 's:"|:|:g' \
                -e 's:" -> ": -> :' \
                -e "s:\`::g" \
                -e "s:|.\{1,4\}$:|0:" \
          >>"${__fc_output_directory}/${__fc_output_file}"
        if [ ! -s "${__fc_output_directory}/${__fc_output_file}" ]; then
          rm -f "${__fc_output_directory}/${__fc_output_file}" >/dev/null
          _log_msg DBG "Empty output file: '${__fc_output_file}'"
        fi
      else
        _log_msg ERR "_find_based_collector: Cannot run stat collector. Target system has neither 'stat', 'statx' nor 'perl' tool available"
        return 1
      fi
      ;;
  esac

}
