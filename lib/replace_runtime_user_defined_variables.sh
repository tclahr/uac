#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Replace runtime and user-defined variables.
#   string input: string containing multiple %var% or %var=default_value% variables
# Returns:
#   string: input string with all runtime and user-defined variables expanded
#           Runtime and user-defined variables have the form:
#             %var%                 replaced by value of var (empty if unset)
#             %var=default_value%   replaced by value of var, or default if var is unset

_replace_runtime_user_defined_variables()
{
  __uv_input="${1:-}"
  __uv_output="${__uv_input}"
  __uv_counter=0 
  __uv_max_loop=30 # used as a safe guard to prevent infinite loop

  while true || [ "${__uv_counter}" -lt "${__uv_max_loop}" ]; do
    # shellcheck disable=SC2003
    __uv_counter=`expr "${__uv_counter}" + 1`

    # get user defined variable with or without default value
    __uv_user_defined_variable=`printf "%s\n" "${__uv_output}" \
      | sed -n 's|.*\(%[A-Za-z_][A-Za-z0-9_]*\(=[^%]*\)\{0,1\}%\).*|\1|p'`

    if [ -z "${__uv_user_defined_variable}" ]; then
      break
    fi
    
    __uv_var_name=`printf "%s\n" "${__uv_user_defined_variable}" \
      | awk '
          {
            gsub(/^%|%$/, "", $0)
            split($0, a, "=")
            print a[1]
          }
          '`
    __uv_var_default_value=`printf "%s\n" "${__uv_user_defined_variable}" \
      | awk '
          {
            gsub(/^%|%$/, "", $0)
            split($0, a, "=")
            print a[2]
          }
          '`

    if [ "${__uv_var_name}" = "hostname" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_HOSTNAME}|g"`
      continue
    elif [ "${__uv_var_name}" = "os" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_OPERATING_SYSTEM}|g"`
      continue
    elif [ "${__uv_var_name}" = "timestamp" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_TIMESTAMP}|g"`
      continue
    elif [ "${__uv_var_name}" = "uac_directory" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_DIR}|g"`
      continue
    elif [ "${__uv_var_name}" = "mount_point" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_MOUNT_POINT}|g"`
      continue
    elif [ "${__uv_var_name}" = "temp_directory" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_TEMP_DATA_DIR}/tmp|g"`
      continue
    elif [ "${__uv_var_name}" = "artifacts_output_directory" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|${__UAC_ARTIFACTS_OUTPUT_DIR}|g"`
      continue
    elif [ "${__uv_var_name}" = "non_local_mount_points" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s'${__uv_user_defined_variable}'${__UAC_EXCLUDE_MOUNT_POINTS}'g"`
      continue
    elif [ "${__uv_var_name}" = "start_date" ]; then
      if [ -n "${__UAC_START_DATE:-}" ]; then
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_START_DATE}|g"`
      else
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1970-01-01|g"`
      fi
      continue
    elif [ "${__uv_var_name}" = "start_date_epoch" ]; then
      if [ -n "${__UAC_START_DATE_EPOCH:-}" ]; then
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_START_DATE_EPOCH}|g"`
      else
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1|g"`
      fi
      continue
    elif [ "${__uv_var_name}" = "end_date" ]; then
      if [ -n "${__UAC_END_DATE:-}" ]; then
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_END_DATE:-}|g"`
      else
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|2031-12-31|g"`
      fi
      continue
    elif [ "${__uv_var_name}" = "end_date_epoch" ]; then
      if [ -n "${__UAC_END_DATE_EPOCH:-}" ]; then
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|${__UAC_END_DATE_EPOCH:-}|g"`
      else
        __uv_output=`printf "%s\n" "${__uv_output}" \
          | sed -e "s|${__uv_user_defined_variable}|1956527999|g"`
      fi
      continue
    elif [ "${__uv_var_name}" = "user_home" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_USER_HOME|g"`
      continue
    elif [ "${__uv_var_name}" = "user" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_USER|g"`
      continue
    elif [ "${__uv_var_name}" = "line" ]; then
      __uv_output=`printf "%s\n" "${__uv_output}" \
        | sed -e "s|${__uv_user_defined_variable}|UAC_RUNTIME_VARIABLE_LINE|g"`
      continue
    fi

    # map to real variable name
    __uv_var_name="__UAC_USER_DEFINED_VAR_${__uv_var_name}"

    if eval "[ \"\${$__uv_var_name+x}\" = x ]"; then
      # variable is set
      eval "__uv_var_value=\"\${$__uv_var_name}\""
    else
      # variable is uset
      eval "__uv_var_value=\"\${__uv_var_default_value:-}\""
    fi

    # shellcheck disable=SC2154
    __uv_output=`printf "%s\n" "${__uv_output}" \
      | sed -e "s|${__uv_user_defined_variable}|${__uv_var_value}|g"`
    
  done

  printf "%s\n" "${__uv_output}" \
    | sed -e 's|UAC_RUNTIME_VARIABLE_USER_HOME|%user_home%|g' \
          -e 's|UAC_RUNTIME_VARIABLE_USER|%user%|g' \
          -e 's|UAC_RUNTIME_VARIABLE_LINE|%line%|g'
}
