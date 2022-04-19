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
# Collector that searches files and directories.
# Globals:
#   GLOBAL_EXCLUDE_MOUNT_POINT
#   GLOBAL_EXCLUDE_NAME_PATTERN
#   GLOBAL_EXCLUDE_PATH_PATTERN
#   MOUNT_POINT
#   START_DATE_DAYS
#   END_DATE_DAYS
# Requires:
#   find_wrapper
#   get_mount_point_by_file_system
#   sanitize_filename
#   sanitize_path
#   sort_uniq_file
# Arguments:
#   $1: path
#   $2: path pattern (optional)
#   $3: name pattern (optional)
#   $4: exclude path pattern (optional)
#   $5: exclude name pattern (optional)
#   $6: exclude file system (optional)
#   $7: max depth (optional)
#   $8: file type (optional)
#   $9: min file size (optional)
#   $10: max file size (optional)
#   $11: permissions (optional)
#   $12: ignore date range (optional) (default: false)
#   $13: root output directory
#   $14: output directory (optional)
#   $15: output file
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
find_collector()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  fc_path="${1:-}"
  shift
  fc_path_pattern="${1:-}"
  shift
  fc_name_pattern="${1:-}"
  shift
  fc_exclude_path_pattern="${1:-}"
  shift
  fc_exclude_name_pattern="${1:-}"
  shift
  fc_exclude_file_system="${1:-}"
  shift
  fc_max_depth="${1:-}"
  shift
  fc_file_type="${1:-}"
  shift
  fc_min_file_size="${1:-}"
  shift
  fc_max_file_size="${1:-}"
  shift
  fc_permissions="${1:-}"
  shift
  fc_ignore_date_range="${1:-false}"
  shift
  fc_root_output_directory="${1:-}"
  shift
  fc_output_directory="${1:-}"
  shift
  fc_output_file="${1:-}"
  
  # return if path is empty
  if [ -z "${fc_path}" ]; then
    printf %b "find_collector: missing required argument: 'path'\n" >&2
    return 2
  fi

  # return if root output directory is empty
  if [ -z "${fc_root_output_directory}" ]; then
    printf %b "find_collector: missing required argument: \
'root_output_directory'\n" >&2
    return 3
  fi

  # return if output file is empty
  if [ -z "${fc_output_file}" ]; then
    printf %b "find_collector: missing required argument: 'output_file'\n" >&2
    return 4
  fi

  # sanitize output file name
  fc_output_file=`sanitize_filename "${fc_output_file}"`

  # sanitize output directory
  fc_output_directory=`sanitize_path \
    "${fc_root_output_directory}/${fc_output_directory}"`

  # create output directory if it does not exist
  if [ ! -d  "${TEMP_DATA_DIR}/${fc_output_directory}" ]; then
    mkdir -p "${TEMP_DATA_DIR}/${fc_output_directory}" >/dev/null
  fi

  ${fc_ignore_date_range} && fc_date_range_start_days="" \
    || fc_date_range_start_days="${START_DATE_DAYS}"
  ${fc_ignore_date_range} && fc_date_range_end_days="" \
    || fc_date_range_end_days="${END_DATE_DAYS}"
  
  # local exclude mount points
  if [ -n "${fc_exclude_file_system}" ]; then
    fc_exclude_mount_point=`get_mount_point_by_file_system \
      "${fc_exclude_file_system}"`
    fc_exclude_path_pattern="${fc_exclude_path_pattern},\
${fc_exclude_mount_point}"
  fi
  
  # global exclude mount points
  if [ -n "${GLOBAL_EXCLUDE_MOUNT_POINT}" ]; then
    fc_exclude_path_pattern="${fc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_MOUNT_POINT}"
  fi

  # global exclude path pattern
  if [ -n "${GLOBAL_EXCLUDE_PATH_PATTERN}" ]; then
    fc_exclude_path_pattern="${fc_exclude_path_pattern},\
${GLOBAL_EXCLUDE_PATH_PATTERN}"
  fi

  # global exclude name pattern
  if [ -n "${GLOBAL_EXCLUDE_NAME_PATTERN}" ]; then
    fc_exclude_name_pattern="${fc_exclude_name_pattern},\
${GLOBAL_EXCLUDE_NAME_PATTERN}"
  fi

  # prepend mount point
  fc_path=`sanitize_path "${MOUNT_POINT}/${fc_path}"`

  find_wrapper \
    "${fc_path}" \
    "${fc_path_pattern}" \
    "${fc_name_pattern}" \
    "${fc_exclude_path_pattern}" \
    "${fc_exclude_name_pattern}" \
    "${fc_max_depth}" \
    "${fc_file_type}" \
    "${fc_min_file_size}" \
    "${fc_max_file_size}" \
    "${fc_permissions}" \
    "${fc_date_range_start_days}" \
    "${fc_date_range_end_days}" \
    >>"${TEMP_DATA_DIR}/${fc_output_directory}/${fc_output_file}" \
    2>>"${TEMP_DATA_DIR}/${fc_output_directory}/${fc_output_file}.stderr"
  
  # sort and uniq output file
  sort_uniq_file "${TEMP_DATA_DIR}/${fc_output_directory}/${fc_output_file}"

  # add output file to the list of files to be archived within the 
  # output file if it is not empty
  if [ -s "${TEMP_DATA_DIR}/${fc_output_directory}/${fc_output_file}" ]; then
    echo "${fc_output_directory}/${fc_output_file}" \
      >>"${TEMP_DATA_DIR}/.output_file.tmp"
  fi

  # add stderr file to the list of files to be archived within the 
  # output file if it is not empty
  if [ -s "${TEMP_DATA_DIR}/${fc_output_directory}/${fc_output_file}.stderr" ]; then
    echo "${fc_output_directory}/${fc_output_file}.stderr" \
      >>"${TEMP_DATA_DIR}/.output_file.tmp"
  fi

}