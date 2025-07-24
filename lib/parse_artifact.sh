#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2162

# Parse an artifact file to collect data.
# Arguments:
#   string artifact: full path to the artifact file
# Returns:
#   none
_parse_artifact()
{
  __pa_artifact="${1:-}"

  if [ ! -f "${__pa_artifact}" ]; then
    _log_msg ERR "_parse_artifact: no such file or directory: '${__pa_artifact}'"
    return 1
  fi
  
  _cleanup_local_vars()
  {
    __pa_collector=""
    __pa_command=""
    __pa_compress_output_file=false
    __pa_condition=""
    __pa_description=""
    __pa_exclude_file_system=""
    __pa_exclude_name_pattern=""
    __pa_exclude_nologin_users=false
    __pa_exclude_path_pattern=""
    __pa_file_type=""
    __pa_foreach=""
    __pa_ignore_date_range=false
    __pa_is_file_list=false
    __pa_max_depth=""
    __pa_max_file_size=""
    __pa_min_file_size=""
    __pa_name_pattern=""
    __pa_no_group=false
    __pa_no_user=false
    __pa_output_directory=""
    __pa_output_file=""
    __pa_path_pattern=""
    __pa_path=""
    __pa_permissions=""
    __pa_redirect_stderr_to_stdout=false
    __pa_supported_os=""
  }
  _cleanup_local_vars

  __pa_global_output_directory=""

  _replace_exposed_variables()
  {
    __re_value="${1:-}"

    if [ -n "${__UAC_START_DATE}" ]; then
      __re_value=`printf "%s" "${__re_value}" \
        | sed -e "s|%start_date%|${__UAC_START_DATE}|g" \
              -e "s|%start_date_epoch%|${__UAC_START_DATE_EPOCH}|g" 2>/dev/null`
    fi
    if [ -n "${__UAC_END_DATE}" ]; then
      __re_value=`printf "%s" "${__re_value}" \
        | sed -e "s|%end_date%|${__UAC_END_DATE}|g" \
              -e "s|%end_date_epoch%|${__UAC_END_DATE_EPOCH}|g" 2>/dev/null`
    fi
    printf "%s" "${__re_value}" \
      | sed -e "s|%uac_directory%|${__UAC_DIR}|g" \
            -e "s|%mount_point%|${__UAC_MOUNT_POINT}|g" \
            -e "s:%non_local_mount_points%:${__UAC_EXCLUDE_MOUNT_POINTS}:g" \
            -e "s|%temp_directory%|${__UAC_TEMP_DATA_DIR}/tmp|g" 2>/dev/null
  }

  # remove lines starting with # (comments) and any inline comments
  # remove leading and trailing space characters
  # remove blank lines
  # add a new line and '-' to the end of file
  printf "\n%s\n" "-" \
    | cat "${__pa_artifact}" - \
    | sed -e 's|#.*$||g' \
          -e 's|^  *||' \
          -e 's|  *$||' \
          -e '/^$/d' 2>/dev/null \
    | while read __pa_key __pa_value; do

        case "${__pa_key}" in
          "artifacts:")
            # read the next line which must be a dash (-)
            read __pa_dash
            if [ "${__pa_dash}" != "-" ]; then
              _log_msg ERR "_parse_artifact: invalid 'artifacts' sequence of mappings."
              return 1
            fi
            if [ -n "${__pa_output_directory}" ]; then
              __pa_global_output_directory="${__pa_output_directory}"
            fi
            if [ -n "${__pa_condition}" ]; then
              # run global condition command and skip collection if exit code is greater than 0
              if echo "${__pa_condition}" | grep -q -E "^!"; then
                __pa_condition=`echo "${__pa_condition}" | sed -e 's|^! *||' 2>/dev/null`
                if _run_command "${__pa_condition}" true >/dev/null; then
                  _log_msg INF "Global condition '${__pa_condition}' not satisfied. Skipping..."
                  return 1
                else
                  _log_msg DBG "Global condition '${__pa_condition}' satisfied"
                fi
              else
                if _run_command "${__pa_condition}" true >/dev/null; then
                  _log_msg DBG "Global condition '${__pa_condition}' satisfied"
                else
                  _log_msg INF "Global condition '${__pa_condition}' not satisfied. Skipping..."
                  return 1
                fi
              fi
            fi
            _cleanup_local_vars
            ;;
          "collector:")
            __pa_collector="${__pa_value}"
            ;;
          "command:")
            if [ "${__pa_value}" = "\"\"\"" ]; then
              __pa_value=""
              while read __pa_line && [ "${__pa_line}" != "\"\"\"" ]; do
                __pa_value="${__pa_value}${__pa_line}
"
              done
            fi
            __pa_command=`_replace_exposed_variables "${__pa_value}"`
            ;;
          "compress_output_file:")
            __pa_compress_output_file="${__pa_value}"
            ;;
          "condition:")
            if [ "${__pa_value}" = "\"\"\"" ]; then
              __pa_value=""
              while read __pa_line && [ "${__pa_line}" != "\"\"\"" ]; do
                __pa_value="${__pa_value}${__pa_line}
"
              done
            fi
            __pa_condition=`_replace_exposed_variables "${__pa_value}"`
            ;;
          "description:")
            __pa_description="${__pa_value}"
            ;;
          "exclude_file_system:")
            __pa_exclude_file_system=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "exclude_name_pattern:")
            __pa_exclude_name_pattern=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "exclude_nologin_users:")
            __pa_exclude_nologin_users="${__pa_value}"
            ;;
          "exclude_path_pattern:")
            __pa_exclude_path_pattern=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "file_type:")
            __pa_file_type=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "foreach:")
            if [ "${__pa_value}" = "\"\"\"" ]; then
              __pa_value=""
              while read __pa_line && [ "${__pa_line}" != "\"\"\"" ]; do
                __pa_value="${__pa_value}${__pa_line}
"
              done
            fi
            __pa_foreach=`_replace_exposed_variables "${__pa_value}"`
            ;;
          "ignore_date_range:")
            __pa_ignore_date_range="${__pa_value}"
            ;;
          "is_file_list:")
            __pa_is_file_list="${__pa_value}"
            ;;
          "max_depth:")
            __pa_max_depth="${__pa_value}"
            ;;
          "max_file_size:")
            __pa_max_file_size="${__pa_value}"
            ;;
          "min_file_size:")
            __pa_min_file_size="${__pa_value}"
            ;;
          "name_pattern:")
            __pa_name_pattern=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "no_group:")
            __pa_no_group="${__pa_value}"
            ;;
          "no_user:")
            __pa_no_user="${__pa_value}"
            ;;
          "output_directory:")
            if echo "${__pa_value}" | grep -q -E "%temp_directory%"; then
              __pa_output_directory=`echo "${__pa_value}" | sed -e "s|%temp_directory%|${__UAC_TEMP_DATA_DIR}/tmp|g" 2>/dev/null`
            else
              __pa_output_directory="${__UAC_TEMP_DATA_DIR}/collected/${__pa_value}"
            fi
            ;;
          "output_file:")
            __pa_output_file="${__pa_value}"
            ;;
          "path:")
              __pa_path=`_replace_exposed_variables "${__pa_value}"`
            ;;
          "path_pattern:")
            __pa_path_pattern=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "permissions:")
            __pa_permissions=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "redirect_stderr_to_stdout:")
            __pa_redirect_stderr_to_stdout="${__pa_value}"
            ;;
          "supported_os:")
            __pa_supported_os=`echo "${__pa_value}" | _array_to_psv 2>/dev/null`
            ;;
          "-")

            # skip if artifact does not apply to the current operating system or all
            # try to collect all artifacts regardless of the operating system if the debugging mode is enabled (--debug).
            if _is_in_list "${__UAC_OPERATING_SYSTEM}" "${__pa_supported_os}" \
              || _is_in_list "all" "${__pa_supported_os}" \
              || ${__UAC_IGNORE_OPERATING_SYSTEM:-false}; then
              true
            else
              _cleanup_local_vars
              continue
            fi

            # skip if invalid collector
            if [ "${__pa_collector}" != "command" ] \
              && [ "${__pa_collector}" != "file" ] \
              && [ "${__pa_collector}" != "find" ] \
              && [ "${__pa_collector}" != "hash" ] \
              && [ "${__pa_collector}" != "stat" ]; then
              _log_msg ERR "_parse_artifact: invalid collector '${__pa_collector}'"
              _cleanup_local_vars
              continue
            fi

            if [ -n "${__pa_condition}" ]; then
              # run local condition command and skip collection if exit code greater than 0
              if echo "${__pa_condition}" | grep -q -E "^!"; then
                __pa_condition=`echo "${__pa_condition}" | sed -e 's|^! *||' 2>/dev/null`
                if _run_command "${__pa_condition}" true >/dev/null; then
                  _log_msg INF "Condition '${__pa_condition}' not satisfied. Skipping..."
                  _cleanup_local_vars
                  continue
                else
                  _log_msg DBG "Condition '${__pa_condition}' satisfied"
                fi
              else
                if _run_command "${__pa_condition}" true >/dev/null; then
                  _log_msg DBG "Condition '${__pa_condition}' satisfied"
                else
                  _log_msg INF "Condition '${__pa_condition}' not satisfied. Skipping..."
                  _cleanup_local_vars
                  continue
                fi
              fi
            fi

            if [ -z "${__pa_output_directory}" ]; then
              __pa_output_directory="${__pa_global_output_directory}"
            fi

            # path, command and foreach contains %user% and/or %user_home%
            # the same collector needs to be run for each %user% and/or %user_home%
            if echo "${__pa_path}" | grep -q -E "%user%" 2>/dev/null \
              || echo "${__pa_command}" | grep -q -E "%user%" 2>/dev/null \
              || echo "${__pa_foreach}" | grep -q -E "%user%" 2>/dev/null \
              || echo "${__pa_path}" | grep -q -E "%user_home%" 2>/dev/null \
              || echo "${__pa_command}" | grep -q -E "%user_home%" 2>/dev/null \
              || echo "${__pa_foreach}" | grep -q -E "%user_home%" 2>/dev/null; then
              
              # loop through users
              __pa_user_home_list="${__UAC_USER_HOME_LIST}"
              ${__pa_exclude_nologin_users} && __pa_user_home_list="${__UAC_VALID_SHELL_ONLY_USER_HOME_LIST}"
              __pa_processed_home=""
              echo "${__pa_user_home_list}" \
                | while read __pa_line && [ -n "${__pa_line}" ]; do
                    __pa_user=`echo "${__pa_line}" | cut -d ":" -f 1`

                    __pa_home=`echo "${__pa_line}" | cut -d ":" -f 2`

                    __pa_no_slash_home=`echo "${__pa_line}" | cut -d ":" -f 2 | sed -e 's|^/||' 2>/dev/null`
                    
                    _log_msg INF "Collecting data for user ${__pa_user}"

                    # replace %user% and %user_home% in path
                    __pa_new_path=`echo "${__pa_path}" \
                      | sed -e "s|%user%|${__pa_user}|g" \
                            -e "s|/%user_home%|${__pa_home}|g" \
                            -e "s|%user_home%|${__pa_no_slash_home}|g" 2>/dev/null`

                    if [ "${__pa_collector}" = "file" ]; then
                      if echo "${__pa_processed_home}" | grep -q -E "\|${__pa_new_path}\|"; then
                        _log_msg INF "Skipping as home directory ${__pa_new_path} has been collected already"
                        continue
                      else
                        __pa_processed_home="${__pa_processed_home}|${__pa_new_path}|"
                      fi
                    fi

                    # replace %user% and %user_home% in command
                    __pa_new_command=`echo "${__pa_command}" \
                      | sed -e "s|%user%|${__pa_user}|g" \
                            -e "s|/%user_home%|${__pa_home}|g" \
                            -e "s|%user_home%|${__pa_no_slash_home}|g" 2>/dev/null`

                    # replace %user% and %user_home% in foreach
                    __pa_new_foreach=`echo "${__pa_foreach}" \
                      | sed -e "s|%user%|${__pa_user}|g" \
                            -e "s|/%user_home%|${__pa_home}|g" \
                            -e "s|%user_home%|${__pa_no_slash_home}|g" 2>/dev/null`

                    # replace %user% and %user_home% in output_directory
                    __pa_new_output_directory=`echo "${__pa_output_directory}" \
                      | sed -e "s|%user%|${__pa_user}|g" \
                            -e "s|/%user_home%|${__pa_home}|g" \
                            -e "s|%user_home%|${__pa_no_slash_home}|g" 2>/dev/null`

                    # replace %user% and %user_home% in output_file
                    __pa_new_output_file=`echo "${__pa_output_file}" \
                      | sed -e "s|%user%|${__pa_user}|g" \
                            -e "s|/%user_home%|${__pa_home}|g" \
                            -e "s|%user_home%|${__pa_no_slash_home}|g" 2>/dev/null`

                    __pa_new_max_depth="${__pa_max_depth}"
                    # if home directory is / (root in some systems),
                    # maxdepth will be set to 2
                    if [ "${__pa_new_path}" = "${__UAC_MOUNT_POINT}" ]; then
                      __pa_new_max_depth=2
                    fi

                    if [ "${__pa_collector}" = "command" ]; then
                      _command_collector \
                        "${__pa_new_foreach}" \
                        "${__pa_new_command}" \
                        "${__pa_new_output_directory}" \
                        "${__pa_new_output_file}" \
                        "${__pa_compress_output_file}" \
                        "${__pa_redirect_stderr_to_stdout}"
                    elif [ "${__pa_collector}" = "file" ]; then
                      _find_based_collector \
                        "file" \
                        "${__pa_new_path}" \
                        "${__pa_is_file_list}" \
                        "${__pa_path_pattern}" \
                        "${__pa_name_pattern}" \
                        "${__pa_exclude_path_pattern}" \
                        "${__pa_exclude_name_pattern}" \
                        "${__pa_exclude_file_system}" \
                        "${__pa_new_max_depth}" \
                        "${__pa_file_type}" \
                        "${__pa_min_file_size}" \
                        "${__pa_max_file_size}" \
                        "${__pa_permissions}" \
                        "${__pa_no_group}" \
                        "${__pa_no_user}" \
                        "${__pa_ignore_date_range}" \
                        "${__UAC_TEMP_DATA_DIR}" \
                        "file_collector.tmp"
                    elif [ "${__pa_collector}" = "find" ]; then
                      _find_based_collector \
                        "find" \
                        "${__pa_new_path}" \
                        false \
                        "${__pa_path_pattern}" \
                        "${__pa_name_pattern}" \
                        "${__pa_exclude_path_pattern}" \
                        "${__pa_exclude_name_pattern}" \
                        "${__pa_exclude_file_system}" \
                        "${__pa_new_max_depth}" \
                        "${__pa_file_type}" \
                        "${__pa_min_file_size}" \
                        "${__pa_max_file_size}" \
                        "${__pa_permissions}" \
                        "${__pa_no_group}" \
                        "${__pa_no_user}" \
                        "${__pa_ignore_date_range}" \
                        "${__pa_new_output_directory}" \
                        "${__pa_new_output_file}"
                    elif [ "${__pa_collector}" = "hash" ]; then
                      _find_based_collector \
                        "hash" \
                        "${__pa_new_path}" \
                        "${__pa_is_file_list}" \
                        "${__pa_path_pattern}" \
                        "${__pa_name_pattern}" \
                        "${__pa_exclude_path_pattern}" \
                        "${__pa_exclude_name_pattern}" \
                        "${__pa_exclude_file_system}" \
                        "${__pa_new_max_depth}" \
                        "${__pa_file_type}" \
                        "${__pa_min_file_size}" \
                        "${__pa_max_file_size}" \
                        "${__pa_permissions}" \
                        "${__pa_no_group}" \
                        "${__pa_no_user}" \
                        "${__pa_ignore_date_range}" \
                        "${__pa_new_output_directory}" \
                        "${__pa_new_output_file}"
                    elif [ "${__pa_collector}" = "stat" ]; then
                      _find_based_collector \
                        "stat" \
                        "${__pa_new_path}" \
                        "${__pa_is_file_list}" \
                        "${__pa_path_pattern}" \
                        "${__pa_name_pattern}" \
                        "${__pa_exclude_path_pattern}" \
                        "${__pa_exclude_name_pattern}" \
                        "${__pa_exclude_file_system}" \
                        "${__pa_new_max_depth}" \
                        "${__pa_file_type}" \
                        "${__pa_min_file_size}" \
                        "${__pa_max_file_size}" \
                        "${__pa_permissions}" \
                        "${__pa_no_group}" \
                        "${__pa_no_user}" \
                        "${__pa_ignore_date_range}" \
                        "${__pa_new_output_directory}" \
                        "${__pa_new_output_file}"
                    fi
                  done
            else
              if [ "${__pa_collector}" = "command" ]; then
                _command_collector \
                  "${__pa_foreach}" \
                  "${__pa_command}" \
                  "${__pa_output_directory}" \
                  "${__pa_output_file}" \
                  "${__pa_compress_output_file}" \
                  "${__pa_redirect_stderr_to_stdout}"
              elif [ "${__pa_collector}" = "file" ]; then
                _find_based_collector \
                  "file" \
                  "${__pa_path}" \
                  "${__pa_is_file_list}" \
                  "${__pa_path_pattern}" \
                  "${__pa_name_pattern}" \
                  "${__pa_exclude_path_pattern}" \
                  "${__pa_exclude_name_pattern}" \
                  "${__pa_exclude_file_system}" \
                  "${__pa_max_depth}" \
                  "${__pa_file_type}" \
                  "${__pa_min_file_size}" \
                  "${__pa_max_file_size}" \
                  "${__pa_permissions}" \
                  "${__pa_no_group}" \
                  "${__pa_no_user}" \
                  "${__pa_ignore_date_range}" \
                  "${__UAC_TEMP_DATA_DIR}" \
                  "file_collector.tmp"
              elif [ "${__pa_collector}" = "find" ]; then
                _find_based_collector \
                  "find" \
                  "${__pa_path}" \
                  "${__pa_is_file_list}" \
                  "${__pa_path_pattern}" \
                  "${__pa_name_pattern}" \
                  "${__pa_exclude_path_pattern}" \
                  "${__pa_exclude_name_pattern}" \
                  "${__pa_exclude_file_system}" \
                  "${__pa_max_depth}" \
                  "${__pa_file_type}" \
                  "${__pa_min_file_size}" \
                  "${__pa_max_file_size}" \
                  "${__pa_permissions}" \
                  "${__pa_no_group}" \
                  "${__pa_no_user}" \
                  "${__pa_ignore_date_range}" \
                  "${__pa_output_directory}" \
                  "${__pa_output_file}"
              elif [ "${__pa_collector}" = "hash" ]; then
                _find_based_collector \
                  "hash" \
                  "${__pa_path}" \
                  "${__pa_is_file_list}" \
                  "${__pa_path_pattern}" \
                  "${__pa_name_pattern}" \
                  "${__pa_exclude_path_pattern}" \
                  "${__pa_exclude_name_pattern}" \
                  "${__pa_exclude_file_system}" \
                  "${__pa_max_depth}" \
                  "${__pa_file_type}" \
                  "${__pa_min_file_size}" \
                  "${__pa_max_file_size}" \
                  "${__pa_permissions}" \
                  "${__pa_no_group}" \
                  "${__pa_no_user}" \
                  "${__pa_ignore_date_range}" \
                  "${__pa_output_directory}" \
                  "${__pa_output_file}"
              elif [ "${__pa_collector}" = "stat" ]; then
                _find_based_collector \
                  "stat" \
                  "${__pa_path}" \
                  "${__pa_is_file_list}" \
                  "${__pa_path_pattern}" \
                  "${__pa_name_pattern}" \
                  "${__pa_exclude_path_pattern}" \
                  "${__pa_exclude_name_pattern}" \
                  "${__pa_exclude_file_system}" \
                  "${__pa_max_depth}" \
                  "${__pa_file_type}" \
                  "${__pa_min_file_size}" \
                  "${__pa_max_file_size}" \
                  "${__pa_permissions}" \
                  "${__pa_no_group}" \
                  "${__pa_no_user}" \
                  "${__pa_ignore_date_range}" \
                  "${__pa_output_directory}" \
                  "${__pa_output_file}"
              fi
            fi           

            _cleanup_local_vars
            ;;
        esac
      done

}