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
# Parse artifacts file.
# Globals:
#   END_DATE
#   END_DATE_EPOCH
#   MOUNT_POINT
#   START_DATE
#   START_DATE_EPOCH
#   TEMP_DATA_DIR
#   USER_HOME_LIST
# Requires:
#   array_to_list
#   lrstrip
#   regex_match
#   sanitize_path
# Arguments:
#   $1: artifacts file
#   $2: root output directory
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
parse_artifacts_file()
{
  pa_artifacts_file="${1:-}"
  pa_root_output_directory="${2:-}"

  # return if artifacts file does not exist
  if [ ! -f "${pa_artifacts_file}" ]; then
    printf %b "parse_artifacts_file: no such file or directory: \
'${pa_artifacts_file}'\n" >&2
    return 2
  fi

  _cleanup_local_vars() {
    pa_collector=""
    pa_supported_os=""
    pa_loop_command=""
    pa_command=""
    pa_path=""
    pa_path_pattern=""
    pa_name_pattern=""
    pa_exclude_path_pattern=""
    pa_exclude_name_pattern=""
    pa_exclude_file_system=""
    pa_max_depth=""
    pa_file_type=""
    pa_min_file_size=""
    pa_max_file_size=""
    pa_permissions=""
    pa_ignore_date_range=false
    pa_output_file=""
    pa_output_directory=""
    pa_is_file_list=false
    pa_compress_output_file=false
    pa_exclude_nologin_users=false
  }

  _cleanup_local_vars

  # save IFS value
  OIFS="${IFS}"
  
  # add '-' to the end of file
  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  printf %b "\n-" | cat "${pa_artifacts_file}" - \
    | sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' 2>/dev/null \
    | while IFS=":" read pa_key pa_value || [ -n "${pa_key}" ]; do

        pa_key=`lrstrip "${pa_key}"`
        pa_value=`lrstrip "${pa_value}"`

        if [ -n "${pa_value}" ]; then
          # replace %uac_directory% by ${UAC_DIR} value
          pa_value=`echo "${pa_value}" \
            | sed -e "s:%uac_directory%:${UAC_DIR}:g"`

          # replace %mount_point% by ${MOUNT_POINT} value
          pa_value=`echo "${pa_value}" \
            | sed -e "s:%mount_point%:${MOUNT_POINT}:g"`

          # replace %destination_directory% by ${TEMP_DATA_DIR}/${pa_root_output_directory} value
          pa_value=`echo "${pa_value}" \
            | sed -e "s:%destination_directory%:${TEMP_DATA_DIR}/${pa_root_output_directory}:g"`

          if [ -n "${START_DATE}" ]; then
            # replace %start_date% by ${START_DATE} value
            pa_value=`echo "${pa_value}" \
              | sed -e "s:%start_date%:${START_DATE}:g"`
            # replace %start_date_epoch% by ${START_DATE_EPOCH} value
            pa_value=`echo "${pa_value}" \
              | sed -e "s:%start_date_epoch%:${START_DATE_EPOCH}:g"`
          fi

          if [ -n "${END_DATE}" ]; then
            # replace %end_date% by ${END_DATE} value
            pa_value=`echo "${pa_value}" \
              | sed -e "s:%end_date%:${END_DATE}:g"`
            # replace %end_date_epoch% by ${END_DATE_EPOCH} value
            pa_value=`echo "${pa_value}" \
              | sed -e "s:%end_date_epoch%:${END_DATE_EPOCH}:g"`
          fi
        fi

        case "${pa_key}" in
          "artifacts")
             # read the next line which must be a dash (-)
            read pa_dash
            pa_dash=`lrstrip "${pa_dash}"`
            if [ "${pa_dash}" != "-" ]; then
              printf %b "validate_artifacts_file: invalid 'artifacts' \
sequence of mappings\n" >&2
              return 3
            fi
            ;;
          "collector")
            pa_collector="${pa_value}"
            ;;
          "supported_os")
            pa_supported_os=`array_to_list "${pa_value}"`
            ;;
          "loop_command")
            pa_loop_command="${pa_value}"
            ;;
          "command")
            pa_command="${pa_value}"
            ;;
          "path")
            pa_path="${pa_value}"
            ;;
          "path_pattern")
            pa_path_pattern=`array_to_list "${pa_value}"`
            ;;
          "name_pattern")
            pa_name_pattern=`array_to_list "${pa_value}"`
            ;;
          "exclude_path_pattern")
            pa_exclude_path_pattern=`array_to_list "${pa_value}"`
            ;;
          "exclude_name_pattern")
            pa_exclude_name_pattern=`array_to_list "${pa_value}"`
            ;;
          "exclude_file_system")
            pa_exclude_file_system=`array_to_list "${pa_value}"`
            ;;
          "max_depth")
            pa_max_depth="${pa_value}"
            ;;
          "file_type")
            pa_file_type="${pa_value}"
            ;;
          "min_file_size")
            pa_min_file_size="${pa_value}"
            ;;
          "max_file_size")
            pa_max_file_size="${pa_value}"
            ;;
          "permissions")
            pa_permissions="${pa_value}"
            ;;
          "ignore_date_range")
            pa_ignore_date_range="${pa_value}"
            ;;
          "output_directory")
            pa_output_directory="${pa_value}"
            ;;
          "output_file")
            pa_output_file="${pa_value}"
            ;;
          "is_file_list")
            pa_is_file_list="${pa_value}"
            ;;
          "compress_output_file")
            pa_compress_output_file="${pa_value}"
            ;;
          "exclude_nologin_users")
            pa_exclude_nologin_users="${pa_value}"
            ;;
          "-")

            # restore IFS value
            IFS="${OIFS}"

            # cannot use ! is_element_in_list because it is not accepted by solaris
            # skip if artifact does not apply to the current operating system
            if is_element_in_list "${OPERATING_SYSTEM}" "${pa_supported_os}" \
              || is_element_in_list "all" "${pa_supported_os}"; then
              pa_do_nothing=true
            else
              _cleanup_local_vars
              continue
            fi

            # skip if invalid collector
            if [ "${pa_collector}" != "command" ] \
              && [ "${pa_collector}" != "file" ] \
              && [ "${pa_collector}" != "find" ] \
              && [ "${pa_collector}" != "hash" ] \
              && [ "${pa_collector}" != "stat" ]; then
              _cleanup_local_vars
              continue
            fi

            # path, command or loop_command contains %user% and/or %user_home%
            # the same collector needs to be run for each %user% and/or %user_home%
            if regex_match "%user%" "${pa_path}" 2>/dev/null \
              || regex_match "%user%" "${pa_command}" 2>/dev/null \
              || regex_match "%user%" "${pa_loop_command}" 2>/dev/null \
              || regex_match "%user_home%" "${pa_path}" 2>/dev/null \
              || regex_match "%user_home%" "${pa_command}" 2>/dev/null \
              || regex_match "%user_home%" "${pa_loop_command}" 2>/dev/null; then

              # loop through users
              pa_user_home_list="${USER_HOME_LIST}"
              ${pa_exclude_nologin_users} && pa_user_home_list="${VALID_SHELL_ONLY_USER_HOME_LIST}"
              echo "${pa_user_home_list}" \
                | while read pa_line || [ -n "${pa_line}" ]; do
                    pa_user=`echo "${pa_line}" | awk -F":" '{ print $1 }'`
                    pa_home=`echo "${pa_line}" | awk -F":" '{ print $2 }'`

                    # replace %user% and %user_home% in path
                    pa_new_path=`echo "${pa_path}" \
                      | sed -e "s:%user%:${pa_user}:g" \
                      | sed -e "s:%user_home%:${pa_home}:g"`

                    # replace %user% and %user_home% in command
                    pa_new_command=`echo "${pa_command}" \
                      | sed -e "s:%user%:${pa_user}:g" \
                      | sed -e "s:%user_home%:${pa_home}:g"`

                    # replace %user% and %user_home% in loop_command
                    pa_new_loop_command=`echo "${pa_loop_command}" \
                      | sed -e "s:%user%:${pa_user}:g" \
                      | sed -e "s:%user_home%:${pa_home}:g"`

                    pa_new_max_depth="${pa_max_depth}"
                    # if home directory is / (root in some systems),
                    # maxdepth will be set to 2
                    if [ "${pa_new_path}" = "${MOUNT_POINT}" ]; then
                      pa_new_max_depth=2
                    fi

                    # replace %user% and %user_home% in output_directory
                    pa_new_output_directory=`echo "${pa_output_directory}" \
                      | sed -e "s:%user%:${pa_user}:g" \
                      | sed -e "s:%user_home%:${pa_home}:g"`

                    # replace %user% and %user_home% in output_file
                    pa_new_output_file=`echo "${pa_output_file}" \
                      | sed -e "s:%user%:${pa_user}:g" \
                      | sed -e "s:%user_home%:${pa_home}:g"`

                    if [ "${pa_collector}" = "command" ]; then
                      command_collector \
                        "${pa_new_loop_command}" \
                        "${pa_new_command}" \
                        "${pa_root_output_directory}" \
                        "${pa_new_output_directory}" \
                        "${pa_new_output_file}" \
                        "${pa_compress_output_file}"
                    elif [ "${pa_collector}" = "file" ]; then
                      file_collector \
                        "${pa_new_path}" \
                        "${pa_is_file_list}" \
                        "${pa_path_pattern}" \
                        "${pa_name_pattern}" \
                        "${pa_exclude_path_pattern}" \
                        "${pa_exclude_name_pattern}" \
                        "${pa_exclude_file_system}" \
                        "${pa_new_max_depth}" \
                        "${pa_file_type}" \
                        "${pa_min_file_size}" \
                        "${pa_max_file_size}" \
                        "${pa_permissions}" \
                        "${pa_ignore_date_range}" \
                        ".files.tmp"
                    elif [ "${pa_collector}" = "find" ]; then
                      find_collector \
                        "${pa_new_path}" \
                        "${pa_path_pattern}" \
                        "${pa_name_pattern}" \
                        "${pa_exclude_path_pattern}" \
                        "${pa_exclude_name_pattern}" \
                        "${pa_exclude_file_system}" \
                        "${pa_new_max_depth}" \
                        "${pa_file_type}" \
                        "${pa_min_file_size}" \
                        "${pa_max_file_size}" \
                        "${pa_permissions}" \
                        "${pa_ignore_date_range}" \
                        "${pa_root_output_directory}" \
                        "${pa_new_output_directory}" \
                        "${pa_new_output_file}"
                    elif [ "${pa_collector}" = "hash" ]; then
                      hash_collector \
                        "${pa_new_path}" \
                        "${pa_is_file_list}" \
                        "${pa_path_pattern}" \
                        "${pa_name_pattern}" \
                        "${pa_exclude_path_pattern}" \
                        "${pa_exclude_name_pattern}" \
                        "${pa_exclude_file_system}" \
                        "${pa_new_max_depth}" \
                        "${pa_file_type}" \
                        "${pa_min_file_size}" \
                        "${pa_max_file_size}" \
                        "${pa_permissions}" \
                        "${pa_ignore_date_range}" \
                        "${pa_root_output_directory}" \
                        "${pa_new_output_directory}" \
                        "${pa_new_output_file}"
                    elif [ "${pa_collector}" = "stat" ]; then
                      stat_collector \
                        "${pa_new_path}" \
                        "${pa_is_file_list}" \
                        "${pa_path_pattern}" \
                        "${pa_name_pattern}" \
                        "${pa_exclude_path_pattern}" \
                        "${pa_exclude_name_pattern}" \
                        "${pa_exclude_file_system}" \
                        "${pa_new_max_depth}" \
                        "${pa_file_type}" \
                        "${pa_min_file_size}" \
                        "${pa_max_file_size}" \
                        "${pa_permissions}" \
                        "${pa_ignore_date_range}" \
                        "${pa_root_output_directory}" \
                        "${pa_new_output_directory}" \
                        "${pa_new_output_file}"
                    fi
                  done

            else
              
              if [ "${pa_collector}" = "command" ]; then
                command_collector \
                  "${pa_loop_command}" \
                  "${pa_command}" \
                  "${pa_root_output_directory}" \
                  "${pa_output_directory}" \
                  "${pa_output_file}" \
                  "${pa_compress_output_file}"
              elif [ "${pa_collector}" = "file" ]; then
                file_collector \
                  "${pa_path}" \
                  "${pa_is_file_list}" \
                  "${pa_path_pattern}" \
                  "${pa_name_pattern}" \
                  "${pa_exclude_path_pattern}" \
                  "${pa_exclude_name_pattern}" \
                  "${pa_exclude_file_system}" \
                  "${pa_max_depth}" \
                  "${pa_file_type}" \
                  "${pa_min_file_size}" \
                  "${pa_max_file_size}" \
                  "${pa_permissions}" \
                  "${pa_ignore_date_range}" \
                  ".files.tmp"
              elif [ "${pa_collector}" = "find" ]; then
                find_collector \
                  "${pa_path}" \
                  "${pa_path_pattern}" \
                  "${pa_name_pattern}" \
                  "${pa_exclude_path_pattern}" \
                  "${pa_exclude_name_pattern}" \
                  "${pa_exclude_file_system}" \
                  "${pa_max_depth}" \
                  "${pa_file_type}" \
                  "${pa_min_file_size}" \
                  "${pa_max_file_size}" \
                  "${pa_permissions}" \
                  "${pa_ignore_date_range}" \
                  "${pa_root_output_directory}" \
                  "${pa_output_directory}" \
                  "${pa_output_file}"
              elif [ "${pa_collector}" = "hash" ]; then
                hash_collector \
                  "${pa_path}" \
                  "${pa_is_file_list}" \
                  "${pa_path_pattern}" \
                  "${pa_name_pattern}" \
                  "${pa_exclude_path_pattern}" \
                  "${pa_exclude_name_pattern}" \
                  "${pa_exclude_file_system}" \
                  "${pa_max_depth}" \
                  "${pa_file_type}" \
                  "${pa_min_file_size}" \
                  "${pa_max_file_size}" \
                  "${pa_permissions}" \
                  "${pa_ignore_date_range}" \
                  "${pa_root_output_directory}" \
                  "${pa_output_directory}" \
                  "${pa_output_file}"
              elif [ "${pa_collector}" = "stat" ]; then
                stat_collector \
                  "${pa_path}" \
                  "${pa_is_file_list}" \
                  "${pa_path_pattern}" \
                  "${pa_name_pattern}" \
                  "${pa_exclude_path_pattern}" \
                  "${pa_exclude_name_pattern}" \
                  "${pa_exclude_file_system}" \
                  "${pa_max_depth}" \
                  "${pa_file_type}" \
                  "${pa_min_file_size}" \
                  "${pa_max_file_size}" \
                  "${pa_permissions}" \
                  "${pa_ignore_date_range}" \
                  "${pa_root_output_directory}" \
                  "${pa_output_directory}" \
                  "${pa_output_file}"
              fi

            fi

            _cleanup_local_vars
            ;;
        esac

      done

}