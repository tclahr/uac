#!/bin/sh

# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck disable=SC2006

###############################################################################
# Collector that searches and stat files.
# Globals:
#   GLOBAL_EXCLUDE_MOUNT_POINT
#   GLOBAL_EXCLUDE_NAME_PATTERN
#   GLOBAL_EXCLUDE_PATH_PATTERN
#   MOUNT_POINT
#   START_DATE_DAYS
#   END_DATE_DAYS
#   STATX_TOOL_AVAILABLE
#   STAT_BTIME_SUPPORT
#   STAT_TOOL_AVAILABLE
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
#   $9: file type (optional) (default: f)
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
stat_collector()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  sc_path="${1:-}"
  shift
  sc_is_file_list="${1:-false}"
  shift
  sc_path_pattern="${1:-}"
  shift
  sc_name_pattern="${1:-}"
  shift
  sc_exclude_path_pattern="${1:-}"
  shift
  sc_exclude_name_pattern="${1:-}"
  shift
  sc_exclude_file_system="${1:-}"
  shift
  sc_max_depth="${1:-}"
  shift
  sc_file_type="${1:-}"
  shift
  sc_min_file_size="${1:-}"
  shift
  sc_max_file_size="${1:-}"
  shift
  sc_permissions="${1:-}"
  shift
  sc_ignore_date_range="${1:-false}"
  shift
  sc_root_output_directory="${1:-}"
  shift
  sc_output_directory="${1:-}"
  shift
  sc_output_file="${1:-}"
  shift
  sc_stderr_output_file="${1:-}"

  # function that runs 'stat' tool
  _stat()
  {
    _sc_path="${1:-}"
    shift
    _sc_is_file_list="${1:-false}"
    shift
    _sc_path_pattern="${1:-}"
    shift
    _sc_name_pattern="${1:-}"
    shift
    _sc_exclude_path_pattern="${1:-}"
    shift
    _sc_exclude_name_pattern="${1:-}"
    shift
    _sc_max_depth="${1:-}"
    shift
    _sc_file_type="${1:-}"
    shift
    _sc_min_file_size="${1:-}"
    shift
    _sc_max_file_size="${1:-}"
    shift
    _sc_permissions="${1:-}"
    shift
    _sc_date_range_start_days="${1:-}"
    shift
    _sc_date_range_end_days="${1:-}"
    shift
    _sc_output_directory="${1:-}"
    shift
    _sc_output_file="${1:-}"

    # 'xargs' performance is much better than 'while' loop
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      case "${OPERATING_SYSTEM}" in
        "freebsd"|"macos"|"netbsd"|"netscaler"|"openbsd")
          if ${_sc_is_file_list}; then
            log_message COMMAND "sort -u \"${_sc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} stat -f \"0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B\" \"{}\""
            sort -u "${_sc_path}" \
              | sed -e "s:':\\\':g" -e 's:":\\\":g' \
              | xargs -I{} stat -f "0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B" "{}" \
                >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
          else
            find_wrapper \
              "${_sc_path}" \
              "${_sc_path_pattern}" \
              "${_sc_name_pattern}" \
              "${_sc_exclude_path_pattern}" \
              "${_sc_exclude_name_pattern}" \
              "${_sc_max_depth}" \
              "${_sc_file_type}" \
              "${_sc_min_file_size}" \
              "${_sc_max_file_size}" \
              "${_sc_permissions}" \
              "${_sc_date_range_start_days}" \
              "${_sc_date_range_end_days}" \
              | sort -u \
              | sed -e "s:':\\\':g" -e 's:":\\\":g' \
              | xargs -I{} stat -f "0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B" "{}" \
                >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
            log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} stat -f \"0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B\" \"{}\""
          fi
          ;;
        "android"|"esxi"|"linux"|"solaris")
          # %N returns quoted file names, so single and double quotes, and back
          # apostrophe needs to be removed using 'sed'

          # also, some old 'stat' versions return the question mark '?'
          # character if %W was not able to proper get the btime. In this case,
          # the question mark will be replaced by a zero character
          if ${_sc_is_file_list}; then
            log_message COMMAND "sort -u \"${_sc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} stat -c \"0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W\" \"{}\""
            sort -u "${_sc_path}" \
              | sed -e "s:':\\\':g" -e 's:":\\\":g' \
              | xargs -I{} stat -c "0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W" "{}" \
              | sed -e "s:|':|:g" \
                    -e "s:'|:|:g" \
                    -e "s:' -> ': -> :" \
                    -e 's:|":|:g' \
                    -e 's:"|:|:g' \
                    -e 's:" -> ": -> :' \
                    -e "s:\`::g" \
                    -e "s:|.$:|0:" \
                >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
          else
            find_wrapper \
              "${_sc_path}" \
              "${_sc_path_pattern}" \
              "${_sc_name_pattern}" \
              "${_sc_exclude_path_pattern}" \
              "${_sc_exclude_name_pattern}" \
              "${_sc_max_depth}" \
              "${_sc_file_type}" \
              "${_sc_min_file_size}" \
              "${_sc_max_file_size}" \
              "${_sc_permissions}" \
              "${_sc_date_range_start_days}" \
              "${_sc_date_range_end_days}" \
              | sort -u \
              | sed -e "s:':\\\':g" -e 's:":\\\":g' \
              | xargs -I{} stat -c "0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W" "{}" \
              | sed -e "s:|':|:g" \
                    -e "s:'|:|:g" \
                    -e "s:' -> ': -> :" \
                    -e 's:|":|:g' \
                    -e 's:"|:|:g' \
                    -e 's:" -> ": -> :' \
                    -e "s:\`::g" \
                    -e "s:|.$:|0:" \
                >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
            log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} stat -c \"0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W\" \"{}\""
          fi
          ;;
      esac
    
    # no 'xargs -I{}'
    else
      case "${OPERATING_SYSTEM}" in
        "freebsd"|"macos"|"netbsd"|"netscaler"|"openbsd")
          if ${_sc_is_file_list}; then
            log_message COMMAND "sort -u \"${_sc_path}\" | while read %line%; do stat -f \"0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B\" \"%line%\"; done"
            # shellcheck disable=SC2162
            sort -u "${_sc_path}" \
              | while read _sc_line || [ -n "${_sc_line}" ]; do
                  stat -f "0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B" "${_sc_line}"
                done \
                  >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
          else
            # shellcheck disable=SC2162
            find_wrapper \
              "${_sc_path}" \
              "${_sc_path_pattern}" \
              "${_sc_name_pattern}" \
              "${_sc_exclude_path_pattern}" \
              "${_sc_exclude_name_pattern}" \
              "${_sc_max_depth}" \
              "${_sc_file_type}" \
              "${_sc_min_file_size}" \
              "${_sc_max_file_size}" \
              "${_sc_permissions}" \
              "${_sc_date_range_start_days}" \
              "${_sc_date_range_end_days}" \
              | sort -u \
              | while read _sc_line || [ -n "${_sc_line}" ]; do
                  stat -f "0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B" "${_sc_line}"
                done \
                  >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
            log_message COMMAND "| sort -u | while read %line%; do stat -f \"0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B\" \"%line%\"; done"
          fi
          ;;
        "android"|"esxi"|"linux"|"solaris")
          # %N returns quoted file names, so single and double quotes, and back 
          # apostrophe needs to be removed using 'sed'

          # also, some old 'stat' versions return the question mark '?' 
          # character if %W was not able to proper get the btime. In this case,
          # the question mark will be replaced by a zero character
          if ${_sc_is_file_list}; then
            log_message COMMAND "sort -u \"${_sc_path}\" | while read %line%; do stat -c \"0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W\" \"%line%\"; done"
            # shellcheck disable=SC2162
            sort -u "${_sc_path}" \
              | while read _sc_line || [ -n "${_sc_line}" ]; do
                  stat -c "0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W" "${_sc_line}" \
                    | sed -e "s:|':|:g" \
                          -e "s:'|:|:g" \
                          -e "s:' -> ': -> :" \
                          -e 's:|":|:g' \
                          -e 's:"|:|:g' \
                          -e 's:" -> ": -> :' \
                          -e "s:\`::g" \
                          -e "s:|.$:|0:"
                done \
                  >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
          else
            # shellcheck disable=SC2162
            find_wrapper \
              "${_sc_path}" \
              "${_sc_path_pattern}" \
              "${_sc_name_pattern}" \
              "${_sc_exclude_path_pattern}" \
              "${_sc_exclude_name_pattern}" \
              "${_sc_max_depth}" \
              "${_sc_file_type}" \
              "${_sc_min_file_size}" \
              "${_sc_max_file_size}" \
              "${_sc_permissions}" \
              "${_sc_date_range_start_days}" \
              "${_sc_date_range_end_days}" \
              | sort -u \
              | while read _sc_line || [ -n "${_sc_line}" ]; do
                  stat -c "0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W" "${_sc_line}" \
                    | sed -e "s:|':|:g" \
                          -e "s:'|:|:g" \
                          -e "s:' -> ': -> :" \
                          -e 's:|":|:g' \
                          -e 's:"|:|:g' \
                          -e 's:" -> ": -> :' \
                          -e "s:\`::g" \
                          -e "s:|.$:|0:"
                done \
                  >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
            log_message COMMAND "| sort -u | while read %line%; do stat -c \"0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W\" \"%line%\"; done"
          fi
          ;;
      esac
    fi
  }

  # function that runs 'statx' tool
  _statx()
  {
    _sc_path="${1:-}"
    shift
    _sc_is_file_list="${1:-false}"
    shift
    _sc_path_pattern="${1:-}"
    shift
    _sc_name_pattern="${1:-}"
    shift
    _sc_exclude_path_pattern="${1:-}"
    shift
    _sc_exclude_name_pattern="${1:-}"
    shift
    _sc_max_depth="${1:-}"
    shift
    _sc_file_type="${1:-}"
    shift
    _sc_min_file_size="${1:-}"
    shift
    _sc_max_file_size="${1:-}"
    shift
    _sc_permissions="${1:-}"
    shift
    _sc_date_range_start_days="${1:-}"
    shift
    _sc_date_range_end_days="${1:-}"
    shift
    _sc_output_directory="${1:-}"
    shift
    _sc_output_file="${1:-}"

    # 'xargs' performance is much better than 'while' loop
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      if ${_sc_is_file_list}; then
        log_message COMMAND "sort -u \"${_sc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} statx \"{}\""
        sort -u "${_sc_path}" \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} statx "{}" \
            >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
      else
        find_wrapper \
          "${_sc_path}" \
          "${_sc_path_pattern}" \
          "${_sc_name_pattern}" \
          "${_sc_exclude_path_pattern}" \
          "${_sc_exclude_name_pattern}" \
          "${_sc_max_depth}" \
          "${_sc_file_type}" \
          "${_sc_min_file_size}" \
          "${_sc_max_file_size}" \
          "${_sc_permissions}" \
          "${_sc_date_range_start_days}" \
          "${_sc_date_range_end_days}" \
          | sort -u \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} statx "{}" \
            >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
        log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} statx \"{}\""
      fi

    # no 'xargs -I{}'
    else
      if ${_sc_is_file_list}; then
        log_message COMMAND "sort -u \"${_sc_path}\" | while read %line%; do statx \"%line%\"; done"
        # shellcheck disable=SC2162
        sort -u "${_sc_path}" \
          | while read _sc_line || [ -n "${_sc_line}" ]; do
              statx "${_sc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
      else
        # shellcheck disable=SC2162
        find_wrapper \
          "${_sc_path}" \
          "${_sc_path_pattern}" \
          "${_sc_name_pattern}" \
          "${_sc_exclude_path_pattern}" \
          "${_sc_exclude_name_pattern}" \
          "${_sc_max_depth}" \
          "${_sc_file_type}" \
          "${_sc_min_file_size}" \
          "${_sc_max_file_size}" \
          "${_sc_permissions}" \
          "${_sc_date_range_start_days}" \
          "${_sc_date_range_end_days}" \
          | sort -u \
          | while read _sc_line || [ -n "${_sc_line}" ]; do
              statx "${_sc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
        log_message COMMAND "| sort -u | while read %line%; do statx \"%line%\"; done"
      fi
    fi

  }

  # function that runs 'stat.pl' tool
  _stat_pl()
  {
    _sc_path="${1:-}"
    shift
    _sc_is_file_list="${1:-false}"
    shift
    _sc_path_pattern="${1:-}"
    shift
    _sc_name_pattern="${1:-}"
    shift
    _sc_exclude_path_pattern="${1:-}"
    shift
    _sc_exclude_name_pattern="${1:-}"
    shift
    _sc_max_depth="${1:-}"
    shift
    _sc_file_type="${1:-}"
    shift
    _sc_min_file_size="${1:-}"
    shift
    _sc_max_file_size="${1:-}"
    shift
    _sc_permissions="${1:-}"
    shift
    _sc_date_range_start_days="${1:-}"
    shift
    _sc_date_range_end_days="${1:-}"
    shift
    _sc_output_directory="${1:-}"
    shift
    _sc_output_file="${1:-}"

    # 'xargs' performance is much better than 'while' loop
    if ${XARGS_REPLACE_STRING_SUPPORT}; then
      if ${_sc_is_file_list}; then
        log_message COMMAND "sort -u \"${_sc_path}\" | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} perl \"${UAC_DIR}/tools/stat.pl/stat.pl\" \"{}\""
        sort -u "${_sc_path}" \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} perl "${UAC_DIR}/tools/stat.pl/stat.pl" "{}" \
            >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
      else
        find_wrapper \
          "${_sc_path}" \
          "${_sc_path_pattern}" \
          "${_sc_name_pattern}" \
          "${_sc_exclude_path_pattern}" \
          "${_sc_exclude_name_pattern}" \
          "${_sc_max_depth}" \
          "${_sc_file_type}" \
          "${_sc_min_file_size}" \
          "${_sc_max_file_size}" \
          "${_sc_permissions}" \
          "${_sc_date_range_start_days}" \
          "${_sc_date_range_end_days}" \
          | sort -u \
          | sed -e "s:':\\\':g" -e 's:":\\\":g' \
          | xargs -I{} perl "${UAC_DIR}/tools/stat.pl/stat.pl" "{}" \
            >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
        log_message COMMAND "| sort -u | sed -e \"s:':\\\':g\" -e 's:\":\\\\\":g' | xargs -I{} perl \"${UAC_DIR}/tools/stat.pl/stat.pl\" \"{}\""
      fi

    # no 'xargs -I{}'
    else
      if ${_sc_is_file_list}; then
        log_message COMMAND "sort -u \"${_sc_path}\" | while read %line%; do perl \"${UAC_DIR}/tools/stat.pl/stat.pl\" \"%line%\"; done"
        # shellcheck disable=SC2162
        sort -u "${_sc_path}" \
          | while read _sc_line || [ -n "${_sc_line}" ]; do
              perl "${UAC_DIR}/tools/stat.pl/stat.pl" "${_sc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
      else
        # shellcheck disable=SC2162
        find_wrapper \
          "${_sc_path}" \
          "${_sc_path_pattern}" \
          "${_sc_name_pattern}" \
          "${_sc_exclude_path_pattern}" \
          "${_sc_exclude_name_pattern}" \
          "${_sc_max_depth}" \
          "${_sc_file_type}" \
          "${_sc_min_file_size}" \
          "${_sc_max_file_size}" \
          "${_sc_permissions}" \
          "${_sc_date_range_start_days}" \
          "${_sc_date_range_end_days}" \
          | sort -u \
          | while read _sc_line || [ -n "${_sc_line}" ]; do
              perl "${UAC_DIR}/tools/stat.pl/stat.pl" "${_sc_line}"
            done \
              >>"${TEMP_DATA_DIR}/${_sc_output_directory}/${_sc_output_file}"
        log_message COMMAND "| sort -u | while read %line%; do perl \"${UAC_DIR}/tools/stat.pl/stat.pl\" \"%line%\"; done"
      fi
    fi

  }

  # return if path is empty
  if [ -z "${sc_path}" ]; then
    printf %b "stat_collector: missing required argument: 'path'\n" >&2
    return 22
  fi

  # return if root output directory is empty
  if [ -z "${sc_root_output_directory}" ]; then
    printf %b "stat_collector: missing required argument: \
'root_output_directory'\n" >&2
    return 22
  fi

  # return if output file is empty
  if [ -z "${sc_output_file}" ]; then
    printf %b "stat_collector: missing required argument: 'output_file'\n" >&2
    return 22
  fi

  # prepend root output directory to path if it does not start with /
  # (which means local file)
  if echo "${sc_path}" | grep -q -v -E "^/"; then
    sc_path=`sanitize_path "${TEMP_DATA_DIR}/${sc_root_output_directory}/${sc_path}"`
  fi

  # return if is file list and file list does not exist
  if ${sc_is_file_list} && [ ! -f "${sc_path}" ]; then
    printf %b "stat_collector: file list does not exist: '${sc_path}'\n" >&2
    return 5
  fi

  # sanitize output file name
  sc_output_file=`sanitize_filename "${sc_output_file}"`

  if [ -n "${sc_stderr_output_file}" ]; then
    # sanitize stderr output file name
    sc_stderr_output_file=`sanitize_filename "${sc_stderr_output_file}"`
  else
    sc_stderr_output_file="${sc_output_file}.stderr"
  fi

  # sanitize output directory
  sc_output_directory=`sanitize_path \
    "${sc_root_output_directory}/${sc_output_directory}"`

  # create output directory if it does not exist
  if [ ! -d  "${TEMP_DATA_DIR}/${sc_output_directory}" ]; then
    mkdir -p "${TEMP_DATA_DIR}/${sc_output_directory}" >/dev/null
  fi

  ${sc_ignore_date_range} && sc_date_range_start_days="" \
    || sc_date_range_start_days="${START_DATE_DAYS}"
  ${sc_ignore_date_range} && sc_date_range_end_days="" \
    || sc_date_range_end_days="${END_DATE_DAYS}"
  
  # local exclude mount points
  if [ -n "${sc_exclude_file_system}" ]; then
    sc_exclude_mount_point=`get_mount_point_by_file_system \
      "${sc_exclude_file_system}"`
    sc_exclude_path_pattern="${sc_exclude_path_pattern},\
${sc_exclude_mount_point}"
  fi

  # global exclude mount points
  if [ -n "${GLOBAL_EXCLUDE_MOUNT_POINT}" ]; then
    sc_exclude_path_pattern="${sc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_MOUNT_POINT}"
  fi

  # global exclude path pattern
  if [ -n "${GLOBAL_EXCLUDE_PATH_PATTERN}" ]; then
    sc_exclude_path_pattern="${sc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_PATH_PATTERN}"
  fi

  # global exclude name pattern
  if [ -n "${GLOBAL_EXCLUDE_NAME_PATTERN}" ]; then
    sc_exclude_name_pattern="${sc_exclude_name_pattern},\
${GLOBAL_EXCLUDE_NAME_PATTERN}"
  fi

  # prepend mount point if is not file list
  ${sc_is_file_list} || sc_path=`sanitize_path "${MOUNT_POINT}/${sc_path}"`

  # always run native 'stat' if it collects file's birth time
  if ${STAT_TOOL_AVAILABLE} && ${STAT_BTIME_SUPPORT}; then
    _stat \
      "${sc_path}" \
      "${sc_is_file_list}" \
      "${sc_path_pattern}" \
      "${sc_name_pattern}" \
      "${sc_exclude_path_pattern}" \
      "${sc_exclude_name_pattern}" \
      "${sc_max_depth}" \
      "${sc_file_type}" \
      "${sc_min_file_size}" \
      "${sc_max_file_size}" \
      "${sc_permissions}" \
      "${sc_date_range_start_days}" \
      "${sc_date_range_end_days}" \
      "${sc_output_directory}" \
      "${sc_output_file}" \
        2>>"${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}"
  
  # run 'statx' if native 'stat' does not collect file's birth time
  elif ${STATX_TOOL_AVAILABLE}; then
    _statx \
      "${sc_path}" \
      "${sc_is_file_list}" \
      "${sc_path_pattern}" \
      "${sc_name_pattern}" \
      "${sc_exclude_path_pattern}" \
      "${sc_exclude_name_pattern}" \
      "${sc_max_depth}" \
      "${sc_file_type}" \
      "${sc_min_file_size}" \
      "${sc_max_file_size}" \
      "${sc_permissions}" \
      "${sc_date_range_start_days}" \
      "${sc_date_range_end_days}" \
      "${sc_output_directory}" \
      "${sc_output_file}" \
        2>>"${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}"
  
  # run native 'stat' if 'statx' is not available
  elif ${STAT_TOOL_AVAILABLE}; then
    _stat \
      "${sc_path}" \
      "${sc_is_file_list}" \
      "${sc_path_pattern}" \
      "${sc_name_pattern}" \
      "${sc_exclude_path_pattern}" \
      "${sc_exclude_name_pattern}" \
      "${sc_max_depth}" \
      "${sc_file_type}" \
      "${sc_min_file_size}" \
      "${sc_max_file_size}" \
      "${sc_permissions}" \
      "${sc_date_range_start_days}" \
      "${sc_date_range_end_days}" \
      "${sc_output_directory}" \
      "${sc_output_file}" \
        2>>"${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}"

  # run 'stat.pl' if neither 'stat' nor 'statx' is available
  elif ${PERL_TOOL_AVAILABLE}; then
    _stat_pl \
      "${sc_path}" \
      "${sc_is_file_list}" \
      "${sc_path_pattern}" \
      "${sc_name_pattern}" \
      "${sc_exclude_path_pattern}" \
      "${sc_exclude_name_pattern}" \
      "${sc_max_depth}" \
      "${sc_file_type}" \
      "${sc_min_file_size}" \
      "${sc_max_file_size}" \
      "${sc_permissions}" \
      "${sc_date_range_start_days}" \
      "${sc_date_range_end_days}" \
      "${sc_output_directory}" \
      "${sc_output_file}" \
        2>>"${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}"

  else
    printf %b "stat_collector: target system has neither 'stat', 'statx' nor \
'perl' tool available\n" >&2
    return 127
  fi

  # sort and uniq output file
  sort_uniq_file "${TEMP_DATA_DIR}/${sc_output_directory}/${sc_output_file}"

  # remove output file if it is empty
  if [ ! -s "${TEMP_DATA_DIR}/${sc_output_directory}/${sc_output_file}" ]; then
    rm -f "${TEMP_DATA_DIR}/${sc_output_directory}/${sc_output_file}" \
      >/dev/null
  fi

  # remove stderr output file if it is empty
  if [ ! -s "${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}" ]; then
    rm -f "${TEMP_DATA_DIR}/${sc_output_directory}/${sc_stderr_output_file}" \
      >/dev/null
  fi

}