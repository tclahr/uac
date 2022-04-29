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
# Collector that searches and collects files. 
# Globals:
#   GLOBAL_EXCLUDE_MOUNT_POINT
#   GLOBAL_EXCLUDE_NAME_PATTERN
#   GLOBAL_EXCLUDE_PATH_PATTERN
#   MOUNT_POINT
#   START_DATE_DAYS
#   END_DATE_DAYS
#   TEMP_DATA_DIR
# Requires:
#   find_wrapper
#   get_mount_point_by_file_system
#   sanitize_filename
#   sanitize_path
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
#   $14: output file
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
file_collector()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  fl_path="${1:-}"
  shift
  fl_is_file_list="${1:-false}"
  shift
  fl_path_pattern="${1:-}"
  shift
  fl_name_pattern="${1:-}"
  shift
  fl_exclude_path_pattern="${1:-}"
  shift
  fl_exclude_name_pattern="${1:-}"
  shift
  fl_exclude_file_system="${1:-}"
  shift
  fl_max_depth="${1:-}"
  shift
  fl_file_type="${1:-f}"
  shift
  fl_min_file_size="${1:-}"
  shift
  fl_max_file_size="${1:-}"
  shift
  fl_permissions="${1:-}"
  shift
  fl_ignore_date_range="${1:-false}"
  shift
  fl_output_file="${1:-}"

  # return if path is empty
  if [ -z "${fl_path}" ]; then
    printf %b "file_collector: missing required argument: 'path'\n" >&2
    return 22
  fi

  # return if output file is empty
  if [ -z "${fl_output_file}" ]; then
    printf %b "file_collector: missing required argument: 'output_file'\n" >&2
    return 22
  fi

  # prepend TEMP_DATA_DIR to path if it does not start with /
  # (which means local file)
  if echo "${fl_path}" | grep -q -v -E "^/"; then
    fl_path=`sanitize_path "${TEMP_DATA_DIR}/${fl_path}"`
  fi

  # return if is file list and file list does not exist
  if ${fl_is_file_list} && [ ! -f "${fl_path}" ]; then
    printf %b "file_collector: file list does not exist: '${fl_path}'\n" >&2
    return 2
  fi

  # sanitize output file name
  fl_output_file=`sanitize_filename "${fl_output_file}"`

  ${fl_ignore_date_range} && fl_date_range_start_days="" \
    || fl_date_range_start_days="${START_DATE_DAYS}"
  ${fl_ignore_date_range} && fl_date_range_end_days="" \
    || fl_date_range_end_days="${END_DATE_DAYS}"
  
  # local exclude mount points
  if [ -n "${fl_exclude_file_system}" ]; then
    fl_exclude_mount_point=`get_mount_point_by_file_system \
      "${fl_exclude_file_system}"`
    fl_exclude_path_pattern="${fl_exclude_path_pattern},\
${fl_exclude_mount_point}"
  fi
  
  # global exclude mount points
  if [ -n "${GLOBAL_EXCLUDE_MOUNT_POINT}" ]; then
    fl_exclude_path_pattern="${fl_exclude_path_pattern},\
${GLOBAL_EXCLUDE_MOUNT_POINT}"
  fi

  # global exclude path pattern
  if [ -n "${GLOBAL_EXCLUDE_PATH_PATTERN}" ]; then
    fl_exclude_path_pattern="${fl_exclude_path_pattern},\
${GLOBAL_EXCLUDE_PATH_PATTERN}"
  fi

  # global exclude name pattern
  if [ -n "${GLOBAL_EXCLUDE_NAME_PATTERN}" ]; then
    fl_exclude_name_pattern="${fl_exclude_name_pattern},\
${GLOBAL_EXCLUDE_NAME_PATTERN}"
  fi

  if ${fl_is_file_list}; then
    cat "${fl_path}" \
      >>"${TEMP_DATA_DIR}/${fl_output_file}" \
      2>>"${TEMP_DATA_DIR}/${fl_output_file}.stderr"
  else 
    # prepend mount point if is not file list
    fl_path=`sanitize_path "${MOUNT_POINT}/${fl_path}"`

    find_wrapper \
      "${fl_path}" \
      "${fl_path_pattern}" \
      "${fl_name_pattern}" \
      "${fl_exclude_path_pattern}" \
      "${fl_exclude_name_pattern}" \
      "${fl_max_depth}" \
      "${fl_file_type}" \
      "${fl_min_file_size}" \
      "${fl_max_file_size}" \
      "${fl_permissions}" \
      "${fl_date_range_start_days}" \
      "${fl_date_range_end_days}" \
      >>"${TEMP_DATA_DIR}/${fl_output_file}" \
      2>>"${TEMP_DATA_DIR}/${fl_output_file}.stderr"

  fi

}