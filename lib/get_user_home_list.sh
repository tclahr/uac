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

###############################################################################
# Get current user list and their home directories.
# Globals:
#   MOUNT_POINT
#   OPERATING_SYSTEM
#   TEMP_DATA_DIR
# Requires:
#   get_current_user
#   sanitize_path
# Arguments:
#   $1: skip users with non-interactive shells (default: false)
#   $2: passwd file path (default: /etc/passwd)
# Outputs:
#   Write user:home list to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
get_user_home_list()
{
  gu_skip_nologin_users="${1:-false}"
  gu_passwd_file_path="${2:-/etc/passwd}"
  
  # skip users with non-interactive shells
  gu_non_interactive_shells_grep="false$|halt$|nologin$|shutdown$|sync$|:$"

  if [ -f "${TEMP_DATA_DIR}/.user_home_list.tmp" ]; then
    rm -f "${TEMP_DATA_DIR}/.user_home_list.tmp" >/dev/null
  fi

  # extract user:home from passwd file
  gu_etc_passwd=`sanitize_path "${MOUNT_POINT}/${gu_passwd_file_path}"`
  if [ -f "${gu_etc_passwd}" ]; then
    if ${gu_skip_nologin_users}; then
      sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${gu_etc_passwd}" \
        | grep -v -E "${gu_non_interactive_shells_grep}" \
        | awk 'BEGIN { FS=":"; } {
            printf "%s:%s\n",$1,$6;
          }' >>"${TEMP_DATA_DIR}/.user_home_list.tmp"
    else
      sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' <"${gu_etc_passwd}" \
        | awk 'BEGIN { FS=":"; } {
            printf "%s:%s\n",$1,$6;
          }' >>"${TEMP_DATA_DIR}/.user_home_list.tmp"
    fi
  fi

  # extract user:home from /home | /Users | /export/home
  gu_user_home_dir="/home"
  if [ "${OPERATING_SYSTEM}" = "macos" ]; then
    gu_user_home_dir="/Users"
  elif [ "${OPERATING_SYSTEM}" = "solaris" ]; then
    gu_user_home_dir="/export/home"
  fi

  if [ -d "${MOUNT_POINT}/${gu_user_home_dir}" ]; then
    for gu_home_dir in "${MOUNT_POINT}/${gu_user_home_dir}"/*; do
      echo "${gu_home_dir}" \
        | sed -e "s:${MOUNT_POINT}::" -e 's://*:/:g' \
        | awk '{
            split($1, parts, "/");
            size = 0;
            for (i in parts) size++;
            printf "%s:%s\n",parts[size],$1;
          }'
    done >>"${TEMP_DATA_DIR}/.user_home_list.tmp"
  fi

  # ChomeOS has '/home/.shadow' directory
  gu_user_home_dir="/home/.shadow"
  if [ -d "${MOUNT_POINT}/${gu_user_home_dir}" ]; then
    echo "shadow:${gu_user_home_dir}" >>"${TEMP_DATA_DIR}/.user_home_list.tmp"
  fi

  # extract user:home for current user only if running on a live system
  # useful for systems which do not have a /etc/passwd file
  if [ "${MOUNT_POINT}" = "/" ]; then
    gu_current_user=`get_current_user`
    echo "${gu_current_user}:${HOME}" >>"${TEMP_DATA_DIR}/.user_home_list.tmp"
  fi

  # remove empty user or home
  grep -v -E "^:|:$" "${TEMP_DATA_DIR}/.user_home_list.tmp" \
    | sort -u
  
}