#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

###############################################################################
# Validate artifacts file.
# Globals:
#   UAC_DIR
# Requires:
#   array_to_list
#   is_integer
#   lrstrip
# Arguments:
#   $1: artifacts file
# Outputs:
#   None
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
validate_artifacts_file()
{
  va_artifacts_file="${1:-}"

  # return if artifacts file does not exist
  if [ ! -f "${va_artifacts_file}" ]; then
    printf %b "uac: no such file or directory: '${va_artifacts_file}'\n" >&2
    return 2
  fi

  _cleanup_local_vars() {
    va_version=""
    va_description=""
    va_collector=""
    va_supported_os=""
    va_loop_command=""
    va_command=""
    va_path=""
    va_path_pattern=""
    va_name_pattern=""
    va_exclude_path_pattern=""
    va_exclude_name_pattern=""
    va_max_depth=""
    va_file_type=""
    va_min_file_size=""
    va_max_file_size=""
    va_permissions=""
    va_ignore_date_range=false
    va_output_file=""
    va_output_directory=""
    va_is_file_list=false
    va_compress_output_file=false
    va_exclude_nologin_users=false
  }

  va_artifacts_prop=false
  _cleanup_local_vars

  # add '-' to the end of file
  # remove lines starting with # (comments)
  # remove inline comments
  # remove blank lines
  # shellcheck disable=SC2162
  printf %b "\n-" | cat "${va_artifacts_file}" - \
    | sed -e 's/#.*$//g' -e '/^ *$/d' -e '/^$/d' 2>/dev/null \
    | while IFS=":" read va_key va_value || [ -n "${va_key}" ]; do

        va_key=`lrstrip "${va_key}"`

        case "${va_key}" in
          "artifacts")
            if ${va_artifacts_prop}; then
              printf %b "uac: artifacts file: invalid duplicated \
'artifacts' mapping.\n" >&2
              return 151
            fi
            va_artifacts_prop=true
            # read the next line which must be a dash (-)
            read va_dash
            va_dash=`lrstrip "${va_dash}"`
            if [ "${va_dash}" != "-" ]; then
              printf %b "uac: artifacts file: invalid 'artifacts' \
sequence of mappings.\n" >&2
              return 150
            fi
            ;;
          "version")
            va_version=`lrstrip "${va_value}"`
            if [ -z "${va_version}" ]; then
              printf %b "uac: artifacts file: 'version' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "description")
            va_description=`lrstrip "${va_value}"`
            if [ -z "${va_description}" ]; then
              printf %b "uac: artifacts file: 'description' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "collector")
            va_collector=`lrstrip "${va_value}"`
            if [ "${va_collector}" != "command" ] \
              && [ "${va_collector}" != "file" ] \
              && [ "${va_collector}" != "find" ] \
              && [ "${va_collector}" != "hash" ] \
              && [ "${va_collector}" != "stat" ]; then
              printf %b "uac: artifacts file: invalid 'collector': \
'${va_collector}'\n" >&2
              return 152
            fi
            ;;
          "supported_os")
            va_supported_os=`lrstrip "${va_value}"`
            if [ -z "${va_supported_os}" ]; then
              printf %b "uac: artifacts file: 'supported_os' must not \
be empty.\n" >&2
              return 152
            elif echo "${va_supported_os}" | grep -q -v -E "^\[" \
              && echo "${va_supported_os}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'supported_os' must be an \
array/list.\n" >&2
              return 152
            fi
            va_so_list="all,aix,android,esxi,freebsd,linux,macos,netbsd,netscaler,openbsd,solaris"
            OIFS="${IFS}"
            IFS=","
            for va_os in `array_to_list "${va_supported_os}"`; do
              if is_element_in_list "${va_os}" "${va_so_list}"; then
                continue
              else
                printf %b "uac: artifacts file: invalid supported_os \
'${va_os}'\n" >&2
                return 152
              fi
            done
            IFS="${OIFS}"
            ;;
          "loop_command")
            va_loop_command=`lrstrip "${va_value}"`
            if [ -z "${va_loop_command}" ]; then
              printf %b "uac: artifacts file: 'loop_command' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "command")
            va_command=`lrstrip "${va_value}"`
            if [ -z "${va_command}" ]; then
              printf %b "uac: artifacts file: 'command' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "path")
            va_path=`lrstrip "${va_value}"`
            if [ -z "${va_path}" ]; then
              printf %b "uac: artifacts file: 'path' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "path_pattern")
            va_path_pattern=`lrstrip "${va_value}"`
            if [ -z "${va_path_pattern}" ]; then
              printf %b "uac: artifacts file: 'path_pattern' must not be \
empty.\n" >&2
              return 152
            elif echo "${va_path_pattern}" | grep -q -v -E "^\[" \
              && echo "${va_path_pattern}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'path_pattern' must be an \
array/list.\n" >&2
              return 152
            fi
            ;;
          "name_pattern")
            va_name_pattern=`lrstrip "${va_value}"`
            if [ -z "${va_name_pattern}" ]; then
              printf %b "uac: artifacts file: 'name_pattern' must not be \
empty.\n" >&2
              return 152
            elif echo "${va_name_pattern}" | grep -q -v -E "^\[" \
              && echo "${va_name_pattern}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'name_pattern' must be an \
array/list.\n" >&2
              return 152
            fi
            ;;
          "exclude_path_pattern")
            va_exclude_path_pattern=`lrstrip "${va_value}"`
            if [ -z "${va_exclude_path_pattern}" ]; then
              printf %b "uac: artifacts file: 'exclude_path_pattern' must \
not be empty.\n" >&2
              return 152
            elif echo "${va_exclude_path_pattern}" | grep -q -v -E "^\[" \
              && echo "${va_exclude_path_pattern}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'exclude_path_pattern' must \
be an array/list.\n" >&2
              return 152
            fi
            ;;
          "exclude_name_pattern")
            va_exclude_name_pattern=`lrstrip "${va_value}"`
            if [ -z "${va_exclude_name_pattern}" ]; then
              printf %b "uac: artifacts file: 'exclude_name_pattern' must \
not be empty.\n" >&2
              return 152
            elif echo "${va_exclude_name_pattern}" | grep -q -v -E "^\[" \
              && echo "${va_exclude_name_pattern}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'exclude_name_pattern' must \
be an array/list.\n" >&2
              return 152
            fi
            ;;
          "exclude_file_system")
            va_exclude_file_system=`lrstrip "${va_value}"`
            if [ -z "${va_exclude_file_system}" ]; then
              printf %b "uac: artifacts file: 'exclude_file_system' must \
not be empty.\n" >&2
              return 152
            elif echo "${va_exclude_file_system}" | grep -q -v -E "^\[" \
              && echo "${va_exclude_file_system}" | grep -q -v -E "\]$"; then
              printf %b "uac: artifacts file: 'exclude_file_system' must \
be an array/list.\n" >&2
              return 152
            fi
            ;;
          "max_depth")
            va_max_depth=`lrstrip "${va_value}"`
            if is_integer "${va_max_depth}" 2>/dev/null \
              && [ "${va_max_depth}" -gt 0 ]; then
              continue
            else
              printf %b "uac: artifacts file: 'max_depth' must be a \
positive integer, but got a '${va_max_depth}'\n" >&2
              return 152
            fi
            ;;
          "file_type")
            va_file_type=`lrstrip "${va_value}"`
            if [ "${va_file_type}" != "b" ] \
              && [ "${va_file_type}" != "c" ] \
              && [ "${va_file_type}" != "d" ] \
              && [ "${va_file_type}" != "p" ] \
              && [ "${va_file_type}" != "f" ] \
              && [ "${va_file_type}" != "l" ] \
              && [ "${va_file_type}" != "s" ]; then
              printf %b "uac: artifacts file: invalid file_type \
'${va_file_type}'\n" >&2
              return 152
            fi
            ;;
          "min_file_size")
            va_min_file_size=`lrstrip "${va_value}"`
            if is_integer "${va_min_file_size}" 2>/dev/null \
              && [ "${va_min_file_size}" -gt 0 ]; then
              continue
            else
              printf %b "uac: artifacts file: 'min_file_size' must be a \
positive integer, but got a '${va_min_file_size}'\n" >&2
              return 152
            fi
            ;;
          "max_file_size")
            va_max_file_size=`lrstrip "${va_value}"`
            if is_integer "${va_max_file_size}" 2>/dev/null \
              && [ "${va_max_file_size}" -gt 0 ]; then
              continue
            else
              printf %b "uac: artifacts file: 'max_file_size' must be a \
positive integer, but got a '${va_max_file_size}'\n" >&2
              return 152
            fi
            ;;
          "permissions")
            va_permissions=`lrstrip "${va_value}"`
            if is_integer "${va_permissions}" 2>/dev/null \
              && [ "${va_permissions}" -gt -7778 ] \
              && [ "${va_permissions}" -lt 7778 ]; then
              continue
            else
              printf %b "uac: artifacts file: 'permissions' must be a \
positive integer between 1 and 7777, but got a '${va_permissions}'\n" >&2
              return 152
            fi
            ;;
          "ignore_date_range")
            va_ignore_date_range=`lrstrip "${va_value}"`
            if [ "${va_ignore_date_range}" != true ] \
              && [ "${va_ignore_date_range}" != false ]; then
              printf %b "uac: artifacts file: 'ignore_date_range' must be \
'true' or 'false', but got a '${va_ignore_date_range}'\n" >&2
              return 152
            fi
            ;;
          "output_directory")
            va_output_directory=`lrstrip "${va_value}"`
            if [ -z "${va_output_directory}" ]; then
              printf %b "uac: artifacts file: 'output_directory' must not \
be empty.\n" >&2
              return 152
            fi
            ;;
          "output_file")
            va_output_file=`lrstrip "${va_value}"`
            if [ -z "${va_output_file}" ]; then
              printf %b "uac: artifacts file: 'output_file' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "stderr_output_file")
            va_stderr_output_file=`lrstrip "${va_value}"`
            if [ -z "${va_stderr_output_file}" ]; then
              printf %b "uac: artifacts file: 'stderr_output_file' must not be \
empty.\n" >&2
              return 152
            fi
            ;;
          "is_file_list")
            va_is_file_list=`lrstrip "${va_value}"`
            if [ "${va_is_file_list}" != true ] \
              && [ "${va_is_file_list}" != false ]; then
              printf %b "uac: artifacts file: 'is_file_list' must be \
'true' or 'false', but got a '${va_is_file_list}'\n" >&2
              return 152
            fi
            ;;
          "compress_output_file")
            va_compress_output_file=`lrstrip "${va_value}"`
            if [ "${va_compress_output_file}" != true ] \
              && [ "${va_compress_output_file}" != false ]; then
              printf %b "uac: artifacts file: 'compress_output_file' must \
be 'true' or 'false', but got a '${va_compress_output_file}'\n" >&2
              return 152
            fi
            ;;
          "exclude_nologin_users")
            va_exclude_nologin_users=`lrstrip "${va_value}"`
            if [ "${va_exclude_nologin_users}" != true ] \
              && [ "${va_exclude_nologin_users}" != false ]; then
              printf %b "uac: artifacts file: 'exclude_nologin_users' must \
be 'true' or 'false', but got a '${va_exclude_nologin_users}'\n" >&2
              return 152
            fi
            ;;
          "-")
            if [ ${va_artifacts_prop} = false ]; then
              printf %b "uac: artifacts file: missing 'artifacts' \
mapping.\n" >&2
              return 150
            fi
            if [ -z "${va_description}" ]; then
              printf %b "uac: artifacts file: missing 'description' \
property.\n" >&2
              return 153
            fi
            if [ -z "${va_collector}" ]; then
              printf %b "uac: artifacts file: missing 'collector' \
property.\n" >&2
              return 153
            fi
            if [ -z "${va_supported_os}" ]; then
              printf %b "uac: artifacts file: missing 'supported_os' \
property.\n" >&2
              return 153
            fi

            if [ "${va_collector}" = "command" ]; then
              if [ -z "${va_command}" ]; then
                printf %b "uac: artifacts file: missing 'command' property \
for 'command' collector.\n" >&2
                return 153
              elif [ -z "${va_output_file}" ]; then
                printf %b "uac: artifacts file: missing 'output_file' \
property for 'command' collector.\n" >&2
                return 153
              fi
            fi

            if [ "${va_collector}" = "find" ]; then
              if [ -z "${va_path}" ]; then
                printf %b "uac: artifacts file: missing 'path' property \
for 'find' collector.\n" >&2
                return 153
              elif [ -z "${va_output_file}" ]; then
                printf %b "uac: artifacts file: missing 'output_file' \
property for 'find' collector.\n" >&2
                return 153
              fi
            fi

            if [ "${va_collector}" = "hash" ]; then
              if [ -z "${va_path}" ]; then
                printf %b "uac: artifacts file: missing 'path' property \
for 'hash' collector.\n" >&2
                return 153
              elif [ -z "${va_output_file}" ]; then
                printf %b "uac: artifacts file: missing 'output_file' \
property for 'hash' collector.\n" >&2
                return 153
              fi
            fi

            if [ "${va_collector}" = "stat" ]; then
              if [ -z "${va_path}" ]; then
                printf %b "uac: artifacts file: missing 'path' property \
for 'stat' collector.\n" >&2
                return 153
              elif [ -z "${va_output_file}" ]; then
                printf %b "uac: artifacts file: missing 'output_file' \
property for 'stat' collector.\n" >&2
                return 153
              fi
            fi

            if [ "${va_collector}" = "file" ]; then
              if [ -z "${va_path}" ]; then
                printf %b "uac: artifacts file: missing 'path' property \
for 'file' collector.\n" >&2
                return 153
              fi
            fi

            _cleanup_local_vars
            ;;
          *)
            printf %b "uac: artifacts file: invalid property \
'${va_key}'\n" >&2
            return 153
        esac

      done

}