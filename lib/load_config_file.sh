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
# Load config file (yaml) and set global variables values.
# Globals:
#   None
# Requires:
#   array_to_list
#   is_element_in_list
# Arguments:
#   $1: config file
# Outputs:
#   Set the value for the following global vars:
#     GLOBAL_EXCLUDE_PATH_PATTERN
#     GLOBAL_EXCLUDE_NAME_PATTERN
#     GLOBAL_EXCLUDE_FILE_SYSTEM
#     HASH_ALGORITHM
#     ENABLE_FIND_ATIME
#     ENABLE_FIND_MTIME
#     ENABLE_FIND_CTIME
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
load_config_file() {
  lc_config_file="${1:-}"

  # return if config file does not exist
  if [ ! -f "${lc_config_file}" ]; then
    printf %b "uac: config file: no such file or directory: \
'${lc_config_file}'\n" >&2
    return 2
  fi

  GLOBAL_EXCLUDE_PATH_PATTERN=""
  GLOBAL_EXCLUDE_NAME_PATTERN=""
  GLOBAL_EXCLUDE_FILE_SYSTEM=""
  HASH_ALGORITHM=""
  ENABLE_FIND_MTIME=true
  ENABLE_FIND_ATIME=false
  ENABLE_FIND_CTIME=true
  
  # exclude_path_pattern
  GLOBAL_EXCLUDE_PATH_PATTERN=`sed -n \
    "/exclude_path_pattern:/s/exclude_path_pattern://p" "${lc_config_file}"`
  GLOBAL_EXCLUDE_PATH_PATTERN=`array_to_list "${GLOBAL_EXCLUDE_PATH_PATTERN}"`
  
  # exclude_name_pattern
  GLOBAL_EXCLUDE_NAME_PATTERN=`sed -n \
    "/exclude_name_pattern:/s/exclude_name_pattern://p" "${lc_config_file}"`
  GLOBAL_EXCLUDE_NAME_PATTERN=`array_to_list "${GLOBAL_EXCLUDE_NAME_PATTERN}"`

  # exclude_file_system
  GLOBAL_EXCLUDE_FILE_SYSTEM=`sed -n \
    "/exclude_file_system:/s/exclude_file_system://p" "${lc_config_file}"`
  GLOBAL_EXCLUDE_FILE_SYSTEM=`array_to_list "${GLOBAL_EXCLUDE_FILE_SYSTEM}"`

  # hash_algorithm
  HASH_ALGORITHM=`sed -n \
    "/hash_algorithm:/s/hash_algorithm://p" "${lc_config_file}"`
  HASH_ALGORITHM=`array_to_list "${HASH_ALGORITHM}"`

  if [ -z "${HASH_ALGORITHM}" ]; then
    printf %b "uac: config file: 'hash_algorithm' must not be empty.\n" >&2
    return 22
  fi
  
  # check if hashes are valid
  # shellcheck disable=SC2001
  lc_hash_algorithm=`echo "${HASH_ALGORITHM}" | sed -e 's:,: :g'`
  for lc_hash in ${lc_hash_algorithm}; do
    if is_element_in_list "${lc_hash}" "md5,sha1,sha256"; then
      continue
    else
      printf %b "uac: config file: invalid hash algorithm '${lc_hash}'\n" >&2
      return 22
    fi
  done
  
  # enable_find_mtime
  ENABLE_FIND_MTIME=`sed -n \
    "/enable_find_mtime:/s/enable_find_mtime://p" "${lc_config_file}"`
  ENABLE_FIND_MTIME=`lrstrip "${ENABLE_FIND_MTIME}"`
  ${ENABLE_FIND_MTIME} || ENABLE_FIND_MTIME=false

  # enable_find_atime
  ENABLE_FIND_ATIME=`sed -n \
    "/enable_find_atime:/s/enable_find_atime://p" "${lc_config_file}"`
  ENABLE_FIND_ATIME=`lrstrip "${ENABLE_FIND_ATIME}"`
  ${ENABLE_FIND_ATIME} || ENABLE_FIND_ATIME=false

  # enable_find_ctime
  ENABLE_FIND_CTIME=`sed -n \
    "/enable_find_ctime:/s/enable_find_ctime://p" "${lc_config_file}"`
  ENABLE_FIND_CTIME=`lrstrip "${ENABLE_FIND_CTIME}"`
  ${ENABLE_FIND_CTIME} || ENABLE_FIND_CTIME=false
  
}