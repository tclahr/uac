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
    _error_msg "Artifact file '${__va_artifact}' does not exist."
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
              && { _error_msg "Invalid artifact: duplicate 'artifacts' mapping found."; return 1; }
            __va_artifacts_prop_exists=true
            # read the next line which must be a dash (-)
            read __va_dash
            if [ "${__va_dash}" != "-" ]; then
              _error_msg "Invalid artifact format: expected '-' after 'artifacts:' mapping."
              return 1
            fi
            if [ -z "${__va_version}" ]; then
              _error_msg "Missing field value: 'version' must not be empty."
              return 1
            fi
            if [ -n "${__va_output_directory}" ]; then
              __va_global_output_directory="${__va_output_directory}"
            fi
            __va_modifier=""
            ;;
          "collector:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'collector' must not be empty."
              return 1
            elif _is_in_list "${__va_value}" "command|file|find|hash|stat"; then
              true
            else
              _error_msg "Invalid collector '${__va_value}'."
              return 1
            fi
            __va_collector="${__va_value}"
            ;;
          "command:")
            if [ "${__va_value}" = "\"\"\"" ]; then
              __va_value=""
              while read __va_line && [ "${__va_line}" != "\"\"\"" ]; do
                if [ "${__va_line}" = "-" ]; then
                  _error_msg "Unterminated command block: missing closing tripple quotes (\"\"\") for 'command'."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'command' must not be empty."
              return 1
            fi
            __va_command="${__va_value}"
            ;;
          "compress_output_file:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'compress_output_file': expected 'true' or 'false'."
              return 1
            fi
            __va_compress_output_file="${__va_value}"
            ;;
          "condition:")
            if [ "${__va_value}" = "\"\"\"" ]; then
              __va_value=""
              while read __va_line && [ "${__va_line}" != "\"\"\"" ]; do
                if [ "${__va_line}" = "-" ]; then
                  _error_msg "Unterminated command block: missing closing tripple quotes (\"\"\") for 'condition'."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'condition' must not be empty."
              return 1
            fi
            __va_condition="${__va_value}"
            ;;
          "description:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'description' must not be empty."
              return 1
            fi
            __va_description="${__va_value}"
            ;;
          "exclude_file_system:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'exclude_file_system' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'exclude_file_system' must not be empty."
              return 1
            fi
            __va_exclude_file_system="${__va_value}"
            ;;
          "exclude_name_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'exclude_name_pattern' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'exclude_name_pattern' must not be empty."
              return 1
            fi
            __va_exclude_name_pattern="${__va_value}"
            ;;
          "exclude_nologin_users:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'exclude_nologin_users': expected 'true' or 'false'."
              return 1
            fi
            __va_exclude_nologin_users="${__va_value}"
            ;;
          "exclude_path_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'exclude_path_pattern' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'exclude_path_pattern' must not be empty."
              return 1
            fi
            __va_exclude_path_pattern="${__va_value}"
            ;;
          "file_type:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'file_type' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'file_type' must not be empty."
              return 1
            fi
            __va_valid_values="b|c|d|p|f|l|s"
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_in_list "${__va_item}" "${__va_valid_values}"; then
                true
              else
                _error_msg "Invalid file type: '${__va_item}' is not supported."
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
                  _error_msg "Unterminated command block: missing closing tripple quotes (\"\"\") for 'foreach'."
                  return 1
                fi
                __va_value="${__va_value}${__va_line}\n"
              done
            fi
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'foreach' must not be empty."
              return 1
            fi
            __va_foreach="${__va_value}"
            ;;
          "ignore_date_range:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'ignore_date_range': expected 'true' or 'false'."
              return 1
            fi
            __va_ignore_date_range="${__va_value}"
            ;;
          "is_file_list:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'is_file_list': expected 'true' or 'false'."
              return 1
            fi
            __va_is_file_list="${__va_value}"
            ;;
          "max_depth:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -ge 0 ]; then
              true
            else
              _error_msg "Invalid value for 'max_depth': expected integer greater than zero."
              return 1
            fi
            __va_max_depth="${__va_value}"
            ;;
          "max_file_size:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -gt 0 ]; then
              true
            else
              _error_msg "Invalid value for 'max_file_size': expected integer greater than zero."
              return 1
            fi
            __va_max_file_size="${__va_value}"
            ;;
          "min_file_size:")
            if _is_digit "${__va_value}" && [ "${__va_value}" -gt 0 ]; then
              true
            else
              _error_msg "Invalid value for 'min_file_size': expected integer greater than zero."
              return 1
            fi
            __va_min_file_size="${__va_value}"
            ;;
          "modifier:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'modifier': expected 'true' or 'false'."
              return 1
            fi
            __va_modifier="${__va_value}"
            ;;
          "name_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'name_pattern' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'name_pattern' must not be empty."
              return 1
            fi
            __va_name_pattern="${__va_value}"
            ;;
          "no_group:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'no_group': expected 'true' or 'false'."
              return 1
            fi
            __va_no_group="${__va_value}"
            ;;
          "no_user:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'no_user': expected 'true' or 'false'."
              return 1
            fi
            __va_no_user="${__va_value}"
            ;;
          "output_directory:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'output_directory' must not be empty."
              return 1
            fi
            __va_output_directory="${__va_value}"
            ;;
          "output_file:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'output_file' must not be empty."
              return 1
            fi
            __va_output_file="${__va_value}"
            ;;
          "path:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'path' must not be empty."
              return 1
            elif echo "${__va_value}" | grep -q -v -E "^/"; then
              _error_msg "Invalid value for 'output_directory': path must be absolute (start with '/')."
              return 1
            fi
            __va_path="${__va_value}"
            ;;
          "path_pattern:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'path_pattern' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'path_pattern' must not be empty."
              return 1
            fi
            __va_path_pattern="${__va_value}"
            ;;
          "permissions:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'permissions' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`

            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'permissions' must not be empty."
              return 1
            fi
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_digit "${__va_item}" \
                && [ "${__va_item}" -gt -7778 ] \
                && [ "${__va_item}" -lt 7778 ]; then
                true
              else
                _error_msg "Invalid value for 'permissions': must be a numeric value between -7777 and 7777."
                return 1
              fi
            done
            __va_permissions="${__va_value}"
            ;;
          "redirect_stderr_to_stdout:")
            if [ "${__va_value}" != true ] && [ "${__va_value}" != false ]; then
              _error_msg "Invalid value for 'redirect_stderr_to_stdout': expected 'true' or 'false'."
              return 1
            fi
            __va_redirect_stderr_to_stdout="${__va_value}"
            ;;
          "supported_os:")
            if echo "${__va_value}" | grep -q -v -E "^\[.*\]$"; then
              _error_msg "Invalid format: 'supported_os' must be a list."
              return 1
            fi
            __va_value=`echo "${__va_value}" | _array_to_psv`
            
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'supported_os' must not be empty."
              return 1
            fi
            __va_valid_values="all|aix|esxi|freebsd|haiku|linux|macos|netbsd|netscaler|openbsd|solaris"
            for __va_item in `echo "${__va_value}" | sed -e 's:|: :g'`; do
              if _is_in_list "${__va_item}" "${__va_valid_values}"; then
                true
              else
                _error_msg "Invalid operating system: '${__va_item}' is not supported."
                return 1
              fi
            done
            __va_supported_os="${__va_value}"
            ;;
          "version:")
            if [ -z "${__va_value}" ]; then
              _error_msg "Missing field value: 'version' must not be empty."
              return 1
            fi
            __va_version="${__va_value}"
            ;;
          "-")
            ${__va_artifacts_prop_exists} \
              || { _error_msg "Invalid artifact format: expected '-' after 'artifacts:' mapping."; return 1; }
            
            if [ -z "${__va_description}" ]; then
              _error_msg "Missing required field: 'description' is not set."
              return 1
            fi
            if [ -z "${__va_supported_os}" ]; then
              _error_msg "Missing required field: 'supported_os' is not set."
              return 1
            fi
            if [ -z "${__va_collector}" ]; then
              _error_msg "Missing required field: 'collector' is not set."
              return 1
            fi
            if [ "${__va_collector}" = "command" ] \
              || [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
              if [ -z "${__va_output_directory}" ] && [ -z "${__va_global_output_directory}" ]; then
                _error_msg "Missing required field: 'output_directory' is not set."
                return 1
              fi
            fi
            if [ "${__va_collector}" = "command" ]; then
              if [ -z "${__va_command}" ]; then
                _error_msg "Missing required field: 'command' is not set."
                return 1
              fi
              if [ -n "${__va_exclude_file_system}" ]; then
                _error_msg "Invalid field: 'exclude_file_system' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_exclude_name_pattern}" ]; then
                _error_msg "Invalid field: 'exclude_name_pattern' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_exclude_path_pattern}" ]; then
                _error_msg "Invalid field: 'exclude_path_pattern' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_file_type}" ]; then
                _error_msg "Invalid field: 'file_type' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_ignore_date_range}" ]; then
                _error_msg "Invalid field: 'ignore_date_range' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_is_file_list}" ]; then
                _error_msg "Invalid field: 'is_file_list' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_max_depth}" ]; then
                _error_msg "Invalid field: 'max_depth' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_max_file_size}" ]; then
                _error_msg "Invalid field: 'max_file_size' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_min_file_size}" ]; then
                _error_msg "Invalid field: 'min_file_size' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_modifier}" ]; then
                _error_msg "Invalid field: 'modifier' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_name_pattern}" ]; then
                _error_msg "Invalid field: 'name_pattern' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_no_group}" ]; then
                _error_msg "Invalid field: 'no_group' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_no_user}" ]; then
                _error_msg "Invalid field: 'no_user' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_path}" ]; then
                _error_msg "Invalid field: 'path' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_path_pattern}" ]; then
                _error_msg "Invalid field: 'path_pattern' is not applicable for the 'command' collector."
                return 1
              fi
              if [ -n "${__va_permissions}" ]; then
                _error_msg "Invalid field: 'permissions' is not applicable for the 'command' collector."
                return 1
              fi
            elif [ "${__va_collector}" = "file" ] \
              || [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
              if [ -z "${__va_path}" ]; then
                _error_msg "Missing required field: 'path' is not set for '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_command}" ]; then
                _error_msg "Invalid field: 'command' is not applicable for the '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_compress_output_file}" ]; then
                _error_msg "Invalid field: 'compress_output_file' is not applicable for the '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_redirect_stderr_to_stdout}" ]; then
                _error_msg "Invalid field: 'redirect_stderr_to_stdout' is not applicable for the '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_foreach}" ]; then
                _error_msg "Invalid field: 'foreach' is not applicable for the '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_modifier}" ]; then
                _error_msg "Invalid field: 'modifier' is not applicable for the '${__va_collector}' collector."
                return 1
              fi
              if [ -n "${__va_max_file_size}" ]; then
                if [ -z "${__va_file_type}" ]; then
                  _error_msg "Invalid value for 'file_type': must include 'f' when using 'max_file_size'."
                  return 1
                fi
                if _is_in_list "f" "${__va_file_type}"; then
                  true
                else
                  _error_msg "Invalid value for 'file_type': must include 'f' when using 'max_file_size'."
                  return 1
                fi
              fi
              if [ -n "${__va_min_file_size}" ]; then
                if [ -z "${__va_file_type}" ]; then
                  _error_msg "Invalid value for 'file_type': must include 'f' when using 'min_file_size'."
                  return 1
                fi
                if _is_in_list "f" "${__va_file_type}"; then
                  true
                else
                  _error_msg "Invalid value for 'file_type': must include 'f' when using 'min_file_size'."
                  return 1
                fi
              fi
              if [ "${__va_collector}" = "find" ] \
              || [ "${__va_collector}" = "hash" ] \
              || [ "${__va_collector}" = "stat" ]; then
                if [ -z "${__va_output_file}" ]; then
                  _error_msg "Missing required field: 'output_file' is not set for '${__va_collector}' collector."
                  return 1
                fi
              fi
            fi
            _cleanup_local_vars
            ;;
          *)
            __va_key=`echo "${__va_key}" | sed -e 's|\|$||'`

            _error_msg "Unknown field '${__va_key}' found in artifact."
            return 1
        esac

      done
}
