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

# shellcheck disable=SC1091

###############################################################################
# Load library files required by UAC.
# Globals:
#   UAC_DIR
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
  
. "${UAC_DIR}/lib/archive_compress_data.sh"
. "${UAC_DIR}/lib/archive_data.sh"
. "${UAC_DIR}/lib/array_to_list.sh"
. "${UAC_DIR}/lib/artifact_file_exist.sh"
. "${UAC_DIR}/lib/azure_storage_sas_url_transfer_test.sh"
. "${UAC_DIR}/lib/azure_storage_sas_url_transfer.sh"
. "${UAC_DIR}/lib/check_available_system_tools.sh"
. "${UAC_DIR}/lib/command_collector.sh"
. "${UAC_DIR}/lib/copy_data.sh"
. "${UAC_DIR}/lib/create_acquisition_log.sh"
. "${UAC_DIR}/lib/create_artifact_list.sh"
. "${UAC_DIR}/lib/file_collector.sh"
. "${UAC_DIR}/lib/file_system_symlink_support.sh"
. "${UAC_DIR}/lib/find_collector.sh"
. "${UAC_DIR}/lib/find_wrapper.sh"
. "${UAC_DIR}/lib/get_absolute_directory_path.sh"
. "${UAC_DIR}/lib/get_current_user.sh"
. "${UAC_DIR}/lib/get_days_since_date_until_now.sh"
. "${UAC_DIR}/lib/get_epoch_date.sh"
. "${UAC_DIR}/lib/get_hostname.sh"
. "${UAC_DIR}/lib/get_mount_point_by_file_system.sh"
. "${UAC_DIR}/lib/get_operating_system.sh"
. "${UAC_DIR}/lib/get_profile_file.sh"
. "${UAC_DIR}/lib/get_system_arch.sh"
. "${UAC_DIR}/lib/get_user_home_list.sh"
. "${UAC_DIR}/lib/hash_collector.sh"
. "${UAC_DIR}/lib/ibm_cos_transfer_test.sh"
. "${UAC_DIR}/lib/ibm_cos_transfer.sh"
. "${UAC_DIR}/lib/is_element_in_list.sh"
. "${UAC_DIR}/lib/is_integer.sh"
. "${UAC_DIR}/lib/is_running_with_root_privileges.sh"
. "${UAC_DIR}/lib/is_valid_operating_system.sh"
. "${UAC_DIR}/lib/list_artifacts.sh"
. "${UAC_DIR}/lib/list_profiles.sh"
. "${UAC_DIR}/lib/load_config_file.sh"
. "${UAC_DIR}/lib/log_message.sh"
. "${UAC_DIR}/lib/lrstrip.sh"
. "${UAC_DIR}/lib/parse_artifacts_file.sh"
. "${UAC_DIR}/lib/profile_file_to_artifact_list.sh"
. "${UAC_DIR}/lib/s3_presigned_url_transfer_test.sh"
. "${UAC_DIR}/lib/s3_presigned_url_transfer.sh"
. "${UAC_DIR}/lib/sanitize_artifact_list.sh"
. "${UAC_DIR}/lib/sanitize_filename.sh"
. "${UAC_DIR}/lib/sanitize_path.sh"
. "${UAC_DIR}/lib/sftp_transfer_test.sh"
. "${UAC_DIR}/lib/sftp_transfer.sh"
. "${UAC_DIR}/lib/sort_uniq_file.sh"
. "${UAC_DIR}/lib/stat_collector.sh"
. "${UAC_DIR}/lib/terminate.sh"
. "${UAC_DIR}/lib/usage.sh"
. "${UAC_DIR}/lib/validate_artifacts_file.sh"
. "${UAC_DIR}/lib/validate_profile_file.sh"