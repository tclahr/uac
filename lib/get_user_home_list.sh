#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Get current user list and their home directories.
# Arguments:
#   boolean skip_nologin_users: skip users with non-interactive shells (default: false)
#   string mount_point: mount point
#   string passwd_file_path: passwd file path (default: /etc/passwd)
# Returns:
#   string: user:home list
_get_user_home_list()
{
  __gu_skip_nologin_users="${1:-false}"
  __gu_mount_point="${2:-/}"
  __gu_passwd_file_path="${3:-/etc/passwd}"

  # skip users with non-interactive shells
  __gu_non_interactive_shells_grep="false$|halt$|nologin$|shutdown$|sync$|git-shell$|:$"

  __gu_user_home_from_passwd=""
  __gu_user_home_from_dir=""
  __gu_user_home_shadow=""
  __gu_user_home_current_user=""

  # extract user:home from passwd file
  if [ -f "${__gu_mount_point}/${__gu_passwd_file_path}" ]; then
    if ${__gu_skip_nologin_users}; then
      # remove lines starting with # (comments)
      # remove inline comments
      # remove blank lines
      __gu_user_home_from_passwd=`sed -e 's|#.*$||g' \
          -e '/^ *$/d' \
          -e '/^$/d' \
          <"${__gu_mount_point}/${__gu_passwd_file_path}" \
        | grep -v -E "${__gu_non_interactive_shells_grep}" \
        | awk 'BEGIN { FS=":"; } {
            printf "%s:%s\n",$1,$6;
          }'`
    else
      __gu_user_home_from_passwd=`sed -e 's|#.*$||g' \
          -e '/^ *$/d' \
          -e '/^$/d' \
          <"${__gu_mount_point}/${__gu_passwd_file_path}" \
        | awk 'BEGIN { FS=":"; } {
            printf "%s:%s\n",$1,$6;
          }'`
    fi
  fi

  # extract user:home from /home | /Users | /export/home | /u
  for __gu_parent_home_dir in /home /Users /export/home /u; do
    # let's skip home directories that are symlinks to avoid data dupplication
    if [ ! -h "${__gu_mount_point}${__gu_parent_home_dir}" ]; then
      for __gu_user_home_dir in "${__gu_mount_point}${__gu_parent_home_dir}"/*; do
        __gu_user_home_from_dir_temp=`echo "${__gu_user_home_dir}" \
        | sed -e "s|^${__gu_mount_point}||" \
        | awk  '{
                  split($1, parts, "/");
                  size = 0;
                  for (i in parts) size++;
                  printf "%s:%s\n",parts[size],$1;
                }'`
        __gu_user_home_from_dir="${__gu_user_home_from_dir}
${__gu_user_home_from_dir_temp}"
      done
    fi
  done

  # ChomeOS has '/home/.shadow' directory
  if [ -d "${__gu_mount_point}/home/.shadow" ]; then
    __gu_user_home_shadow="shadow:/home/.shadow"
  fi

  # extract user:home for current user only if running on a live system
  # useful for systems which do not have a /etc/passwd file
  if [ "${__gu_mount_point}" = "/" ] && [ -n "${HOME:-}" ]; then
    __gu_current_user=`_get_current_user`
    __gu_user_home_current_user="${__gu_current_user}:${HOME}"
  fi

  # remove blank lines
  # remove  :/home
  # remove *:/home
  # remove user:
  # sort unique
  printf "%s\n%s\n%s\n%s\n" \
    "${__gu_user_home_from_passwd}" \
    "${__gu_user_home_from_dir}" \
    "${__gu_user_home_shadow}" \
    "${__gu_user_home_current_user}" \
    | sed -e '/^$/d' \
          -e '/^*/d' \
          -e '/^:/d' \
          -e '/:$/d' \
    | sort -u

}
