#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2162

# Check whether the provided artifact has any errors.
# Arguments:
#   string artifact: full path to the artifact file
# Returns:
#   boolean: true on success
#            false on fail
_validate_artifact()
{
  __va_artifact="${1:-}"

  if [ ! -f "${__va_artifact}" ]; then
    _error_msg "artifact: no such file or directory: '${__va_artifact}'"
    return 1
  fi

  _cleanup_local_vars()
  {
    __va_collector=""
    __va_command=""
    __va_compress_output_file=""
    __va_condition=""
    __va_description=""
    __va_exclude_file_system=""
    __va_exclude_name_pattern=""
    __va_exclude_nologin_users=""
    __va_exclude_path_pattern=""
    __va_file_type=""
    __va_foreach=""
    __va_ignore_date_range=""
    __va_is_file_list=""
    __va_max_depth=""
    __va_max_file_size=""
    __va_min_file_size=""
    __va_modifier=""
    __va_name_pattern=""
    __va_no_group=""
    __va_no_user=""
    __va_output_directory=""
    __va_output_file=""
    __va_path_pattern=""
    __va_path=""
    __va_permissions=""
    __va_redirect_stderr_to_stdout=""
    __va_supported_os=""
    __va_version=""
  }
  _cleanup_local_vars

  __va_global_output_directory=""
  __va_artifacts_prop_exists=false
  
  # remove lines starting with # (comments) and any inline comments
  # remove leading and trailing space characters
  # remove blank lines
  # add a new line and '-' to the end of file
  printf "\n%s\n" "-" \
    | cat "${__va_artifact}" - \
    | sed -e 's|#.*$||g' \
          -e 's|^  *||' \
          -e 's|  *$||' \
          -e '/^$/d' \
    | while read __va_key __va_value; do

        case "${__va_key}" in
          "artifacts:")
            ${__va_artifacts_prop_exists} \
              && { _error_msg "artifact: invalid duplicated 'artifacts' mapping."; return 1; }
            __va_artifacts_prop_exists=true
            # read the next line which must be a dash (-)
            read __va_dash
            if [ "${__va_dash}" != "-" ]; then
              _error_msg "artifact: invalid 'artifacts' sequence of mappings."
              return 1
            fi
            if [ -z "${__va_version}" ]; then
              _error_msg "artifact: 'version' must not be empty."
              return 1
            fi
            if [ -n "${__va_output_directory}" ]; then
              __va_global_output_directory="${__va_output_directory}"
            fi
            __va_modifier=""
            ;;
          "collector:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'collector' must not be empty."
              return 1
            elif _is_in_list "${__va_value}" "command|file|find|hash|stat"; then
              true
            else
              _error_msg "artifact: invalid collector '${__va_value}'"
              return 1
            fi
            __va_collector="${__va_value}"
            ;;
          "command:")
            if [ "${__va_value}" = "\"\"\"" ]; then
              __va_value=""
              while read __va_line && [ "${__va_line}" != "\"\"\"" ]; do
                if [ "${__va_line}" = "-" ]; then
                  _error_msg "artifact: missing closing \"\"\" for 'command' collector."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'command' must not be empty."
              return 1
            fi
            __va_command="${__va_value}"
            ;;
          "compress_output_file:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'compress_output_file' must be 'true' or 'false'."
              return 1
            fi
            __va_compress_output_file="${__va_value}"
            ;;
          "condition:")
            if [ "${__va_value}" = "\"\"\"" ]; then
              __va_value=""
              while read __va_line && [ "${__va_line}" != "\"\"\"" ]; do
                if [ "${__va_line}" = "-" ]; then
                  _error_msg "artifact: missing closing \"\"\" for 'condition' property."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'condition' must not be empty."
              return 1
            fi
            __va_condition="${__va_value}"
            ;;
          "description:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'description' must not be empty."
              return 1
            fi
            __va_description="${__va_value}"
            ;;
          "exclude_file_system:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'exclude_file_system' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'exclude_file_system' must not be empty."
              return 1
            fi
            __va_exclude_file_system="${__va_value}"
            ;;
          "exclude_name_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'exclude_name_pattern' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'exclude_name_pattern' must not be empty."
              return 1
            fi
            __va_exclude_name_pattern="${__va_value}"
            ;;
          "exclude_nologin_users:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'exclude_nologin_users' must be 'true' or 'false'."
              return 1
            fi
            __va_exclude_nologin_users="${__va_value}"
            ;;
          "exclude_path_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'exclude_path_pattern' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'exclude_path_pattern' must not be empty."
              return 1
            fi
            __va_exclude_path_pattern="${__va_value}"
            ;;
          "file_type:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'file_type' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'file_type' must not be empty."
              return 1
            fi
            __va_valid_values="b|c|d|p|f|l|s"
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_in_list "${__va_item}" "${__va_valid_values}"; then
                true
              else
                _error_msg "artifact: invalid file_type '${__va_item}'"
                return 1
              fi
            done
            __va_file_type="${__va_value}"
            ;;
          "foreach:")
            if [ "${__va_value}" = "\"\"\"" ]; then
              __va_value=""
              while read __va_line && [ "${__va_line}" != "\"\"\"" ]; do
                if [ "${__va_line}" = "-" ]; then
                  _error_msg "artifact: missing closing \"\"\" for 'foreach' property."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'foreach' must not be empty."
              return 1
            fi
            __va_foreach="${__va_value}"
            ;;
          "ignore_date_range:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'ignore_date_range' must be 'true' or 'false'."
              return 1
            fi
            __va_ignore_date_range="${__va_value}"
            ;;
          "is_file_list:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'is_file_list' must be 'true' or 'false'."
              return 1
            fi
            __va_is_file_list="${__va_value}"
            ;;
          "max_depth:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -ge 0 ]; then
              true
            else
              _error_msg "artifact: 'max_depth' must be zero or a positive integer."
              return 1
            fi
            __va_max_depth="${__va_value}"
            ;;
          "max_file_size:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -gt 0 ]; then
              true
            else
              _error_msg "artifact: 'max_file_size' must be a positive integer."
              return 1
            fi
            __va_max_file_size="${__va_value}"
            ;;
          "min_file_size:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -gt 0 ]; then
              true
            else
              _error_msg "artifact: 'min_file_size' must be a positive integer."
              return 1
            fi
            __va_min_file_size="${__va_value}"
            ;;
          "modifier:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'modifier' must be 'true' or 'false'."
              return 1
            fi
            __va_modifier="${__va_value}"
            ;;
          "name_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'name_pattern' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'name_pattern' must not be empty."
              return 1
            fi
            __va_name_pattern="${__va_value}"
            ;;
          "no_group:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'no_group' must be 'true' or 'false'."
              return 1
            fi
            __va_no_group="${__va_value}"
            ;;
          "no_user:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'no_user' must be 'true' or 'false'."
              return 1
            fi
            __va_no_user="${__va_value}"
            ;;
          "output_directory:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'output_directory' must not be empty."
              return 1
            fi
            __va_output_directory="${__va_value}"
            ;;
          "output_file:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'output_file' must not be empty."
              return 1
            fi
            __va_output_file="${__va_value}"
            ;;
          "path:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'path' must not be empty."
              return 1
            elif echo "${__va_value}" | grep -q -v -E "^/"; then
              _error_msg "artifact: 'output_directory' invalid path. Path must be absolute (starting with /)."
              return 1
            fi
            __va_path="${__va_value}"
            ;;
          "path_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'path_pattern' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'path_pattern' must not be empty."
              return 1
            fi
            __va_path_pattern="${__va_value}"
            ;;
          "permissions:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'permissions' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'permissions' must not be empty."
              return 1
            fi
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_digit "${__va_item}" \
                && [ "${__va_item}" -gt -7778 ] \
                && [ "${__va_item}" -lt 7778 ]; then
                true
              else
                _error_msg "artifact: 'permissions' must be an integer between -7777 and 7777."
                return 1
              fi
            done
            __va_permissions="${__va_value}"
            ;;
          "redirect_stderr_to_stdout:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "artifact: 'redirect_stderr_to_stdout' must be 'true' or 'false'."
              return 1
            fi
            __va_redirect_stderr_to_stdout="${__va_value}"
            ;;
          "supported_os:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "artifact: 'supported_os' must be an array/list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'supported_os' must not be empty."
              return 1
            fi
            __va_valid_values="all|aix|esxi|freebsd|linux|macos|netbsd|netscaler|openbsd|solaris"
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_in_list "${__va_item}" "${__va_valid_values}"; then
                true
              else
                _error_msg "artifact: invalid supported_os '${__va_item}'"
                return 1
              fi
            done
            __va_supported_os="${__va_value}"
            ;;
          "version:")
            if [ -z "${__va_value}" ]; then
              _error_msg "artifact: 'version' must not be empty."
              return 1
            fi
            __va_version="${__va_value}"
            ;;
          "-")
            ${__va_artifacts_prop_exists} \
              || { _error_msg "artifact: missing 'artifacts' mapping."; return 1; }
            
            if [ -z "${__va_description}" ]; then
              _error_msg "artifact: missing 'description' property."
              return 1
            fi
            if [ -z "${__va_supported_os}" ]; then
              _error_msg "artifact: missing 'supported_os' property."
              return 1
            fi
            if [ -z "${__va_collector}" ]; then
              _error_msg "artifact: missing 'collector' property."
              return 1
            fi
            if [ "${__va_collector}" = "command" ] \
              || [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
              if [ -z "${__va_output_directory}" ] && [ -z "${__va_global_output_directory}" ]; then
                _error_msg "artifact: missing 'output_directory' property."
                return 1
              fi
            fi
            if [ "${__va_collector}" = "command" ]; then
              if [ -z "${__va_command}" ]; then
                _error_msg "artifact: missing 'command' property."
                return 1
              fi
              if [ -n "${__va_exclude_file_system}" ]; then
                _error_msg "artifact: invalid 'exclude_file_system' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_exclude_name_pattern}" ]; then
                _error_msg "artifact: invalid 'exclude_name_pattern' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_exclude_path_pattern}" ]; then
                _error_msg "artifact: invalid 'exclude_path_pattern' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_file_type}" ]; then
                _error_msg "artifact: invalid 'file_type' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_ignore_date_range}" ]; then
                _error_msg "artifact: invalid 'ignore_date_range' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_is_file_list}" ]; then
                _error_msg "artifact: invalid 'is_file_list' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_max_depth}" ]; then
                _error_msg "artifact: invalid 'max_depth' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_max_file_size}" ]; then
                _error_msg "artifact: invalid 'max_file_size' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_min_file_size}" ]; then
                _error_msg "artifact: invalid 'min_file_size' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_modifier}" ]; then
                _error_msg "artifact: invalid 'modifier' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_name_pattern}" ]; then
                _error_msg "artifact: invalid 'name_pattern' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_no_group}" ]; then
                _error_msg "artifact: invalid 'no_group' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_no_user}" ]; then
                _error_msg "artifact: invalid 'no_user' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_path}" ]; then
                _error_msg "artifact: invalid 'path' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_path_pattern}" ]; then
                _error_msg "artifact: invalid 'path_pattern' property for 'command' collector."
                return 1
              fi
              if [ -n "${__va_permissions}" ]; then
                _error_msg "artifact: invalid 'permissions' property for 'command' collector."
                return 1
              fi
            elif [ "${__va_collector}" = "file" ] \
              || [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
              if [ -z "${__va_path}" ]; then
                _error_msg "artifact: missing 'path' property."
                return 1
              fi
              if [ -n "${__va_max_file_size}" ] || [ -n "${__va_min_file_size}" ]; then
                if [ "${__va_file_type}" != "f" ]; then
                  _error_msg "artifact: 'file_type' must be of type 'f' when using 'max_file_size' or 'min_file_size'."
                  return 1
                fi
              fi
              if [ -n "${__va_command}" ]; then
                _error_msg "artifact: invalid 'command' property for '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_compress_output_file}" ]; then
                _error_msg "artifact: invalid 'compress_output_file' property for '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_redirect_stderr_to_stdout}" ]; then
                _error_msg "artifact: invalid 'redirect_stderr_to_stdout' property for '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_foreach}" ]; then
                _error_msg "artifact: invalid 'foreach' property for '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_modifier}" ]; then
                _error_msg "artifact: invalid 'modifier' property for '${__va_collector}' collector."
                return 1
              fi
              if [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
                if [ -z "${__va_output_file}" ]; then
                  _error_msg "artifact: missing 'output_file' property."
                  return 1
                fi
              fi
            fi
            _cleanup_local_vars
            ;;
          *)
            __va_key=`echo "${__va_key}" | sed -e 's|\|$||'`
            _error_msg "artifact: invalid property '${__va_key}'."
            return 1
        esac

      done
}