#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Build a working find command line based on the given parameters to search for files in a directory hierarchy.
# Arguments:
#   string path: path
#   string path_pattern: pipe-separated list of path patterns (optional)
#   string name_pattern: pipe-separated list of name patterns (optional)
#   string exclude_path_pattern: pipe-separated list of exclude path patterns (optional)
#   string exclude_name_pattern: pipe-separated list of exclude name patterns (optional)
#   integer max_depth: max depth (optional)
#   string file_type: file type (optional)
#   integer min_file_size: minimum file size (optional)
#   integer max_file_size: maximum file size (optional)
#   string permissions: permissions (optional)
#   boolean no_group: no group corresponds to file's numeric group ID (optional)
#   boolean no_user: No user corresponds to file's numeric user ID (optional)
#   string print0: uses -print0 instead of -print (optional)
#   integer start_date_days: days (optional)
#   integer end_date_days: days (optional)
#   boolean is_rescursive: add semicolon at the end of the find command (optional)
# Returns:
#   string: command line
_build_find_command()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  __bf_path="${1:-}"
  shift
  __bf_path_pattern="${1:-}"
  shift
  __bf_name_pattern="${1:-}"
  shift
  __bf_exclude_path_pattern="${1:-}"
  shift
  __bf_exclude_name_pattern="${1:-}"
  shift
  __bf_max_depth="${1:-0}"
  shift
  __bf_file_type="${1:-}"
  shift
  __bf_min_file_size="${1:-}"
  shift
  __bf_max_file_size="${1:-}"
  shift
  __bf_permissions="${1:-}"
  shift
  __bf_no_group="${1:-false}"
  shift
  __bf_no_user="${1:-false}"
  shift
  __bf_print0="${1:-false}"
  shift
  __bf_start_date_days="${1:-0}"
  shift
  __bf_end_date_days="${1:-0}"
  shift
  __bf_is_recursive="${1:-false}"

  if [ -z "${__bf_path}" ]; then
    _log_msg ERR "_build_find_command: empty path parameter"
    return 1
  fi

  # Build recursive parameters to be used with find.
  # Arguments:
  #   string parameter: parameter
  #   string items: pipe-separated value list of items
  #   boolean quote: add value between double-quotes
  # Returns:
  #   string: recursive parameter string
  _build_recursive_parameter()
  {
    __br_parameter="${1:-}"
    __br_items="${2:-}"
    __br_quote="${3:-false}"

    __br_quote_param=""
    ${__br_quote} && __br_quote_param="\""

    echo "${__br_items}" \
      | awk -v __br_param="${__br_parameter}" -v __br_quote_param="${__br_quote_param}" 'BEGIN { FS="|"; } {
          for(N = 1; N <= NF; N ++) {
            if ($N != "") {
              if (N == 1) {
                printf "%s %s%s%s", __br_param, __br_quote_param, $N, __br_quote_param;
              }
              else {
                printf " -o %s %s%s%s", __br_param, __br_quote_param, $N, __br_quote_param;
              }
            }
          }
        }'
  }

  __bf_perl_command_exists=false
  command_exists "perl" && __bf_perl_command_exists=true
  __bf_find_tool="find"
  __bf_find_params=""

  # global options such as -maxdepth must be specified before other arguments.
  # i.e., -maxdepth affects tests specified before it as well as those specified after it.
  # build -maxdepth parameter
  if [ "${__UAC_CONF_MAX_DEPTH}" -gt 0 ] && [ "${__bf_max_depth}" -eq 0 ]; then
    __bf_max_depth="${__UAC_CONF_MAX_DEPTH}"
  fi
  if [ "${__bf_max_depth}" -gt 0 ]; then
    if ${__UAC_TOOL_FIND_MAXDEPTH_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-maxdepth ${__bf_max_depth}"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-maxdepth ${__bf_max_depth}"
      __bf_find_tool="find.pl"
    fi
  fi

  # build -path prune parameter
  if [ -n "${__bf_exclude_path_pattern}" ]; then
    if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT} && ${__UAC_TOOL_FIND_PATH_SUPPORT} && ${__UAC_TOOL_FIND_PRUNE_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-path\" \"${__bf_exclude_path_pattern}\" true` \) -prune -o"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-path\" \"${__bf_exclude_path_pattern}\" true` \) -prune -o"
      __bf_find_tool="find.pl"
    fi
  fi

  # build -path parameter
  # -path parameter will be added even if find does not support it
  if [ -n "${__bf_path_pattern}" ]; then
    if _is_psv "${__bf_path_pattern}"; then
      if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT} && ${__UAC_TOOL_FIND_PATH_SUPPORT}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-path\" \"${__bf_path_pattern}\" true` \)"
      elif ${__bf_perl_command_exists}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-path\" \"${__bf_path_pattern}\" true` \)"
        __bf_find_tool="find.pl"
      else
        # shellcheck disable=SC2162,SC2030
        echo "${__bf_path_pattern}" \
          | awk 'BEGIN{RS="|"} {print $0}' \
          | while read __bf_path_pattern_line && [ -n "${__bf_path_pattern_line}" ]; do
              _build_find_command \
                "${__bf_path}" \
                "${__bf_path_pattern_line}" \
                "${__bf_name_pattern}" \
                "${__bf_exclude_path_pattern}" \
                "${__bf_exclude_name_pattern}" \
                "${__bf_max_depth}" \
                "${__bf_file_type}" \
                "${__bf_min_file_size}" \
                "${__bf_max_file_size}" \
                "${__bf_permissions}" \
                "${__bf_no_group}" \
                "${__bf_no_user}" \
                "${__bf_print0}" \
                "${__bf_start_date_days}" \
                "${__bf_end_date_days}" \
                true
            done
        return
      fi
    else
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-path \"${__bf_path_pattern}\""
      if ${__UAC_TOOL_FIND_PATH_SUPPORT}; then
        true
      elif ${__bf_perl_command_exists}; then
        __bf_find_tool="find.pl"
      fi
    fi
  fi

  # build -name prune parameter
  if [ -n "${__bf_exclude_name_pattern}" ]; then
    if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT} && ${__UAC_TOOL_FIND_PRUNE_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-name\" \"${__bf_exclude_name_pattern}\" true` \) -prune -o"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-name\" \"${__bf_exclude_name_pattern}\" true` \) -prune -o"
      __bf_find_tool="find.pl"
    fi
  fi

  # build -name parameter
  if [ -n "${__bf_name_pattern}" ]; then
    if _is_psv "${__bf_name_pattern}"; then
      if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-name\" \"${__bf_name_pattern}\" true` \)"
      elif ${__bf_perl_command_exists}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-name\" \"${__bf_name_pattern}\" true` \)"
        __bf_find_tool="find.pl"
      else
        # shellcheck disable=SC2162,SC2030
        echo "${__bf_name_pattern}" \
          | awk 'BEGIN{RS="|"} {print $0}' \
          | while read __bf_name_pattern_line && [ -n "${__bf_name_pattern_line}" ]; do
              _build_find_command \
                "${__bf_path}" \
                "${__bf_path_pattern}" \
                "${__bf_name_pattern_line}" \
                "${__bf_exclude_path_pattern}" \
                "${__bf_exclude_name_pattern}" \
                "${__bf_max_depth}" \
                "${__bf_file_type}" \
                "${__bf_min_file_size}" \
                "${__bf_max_file_size}" \
                "${__bf_permissions}" \
                "${__bf_no_group}" \
                "${__bf_no_user}" \
                "${__bf_print0}" \
                "${__bf_start_date_days}" \
                "${__bf_end_date_days}" \
                true
            done
        return
      fi
    else
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-name \"${__bf_name_pattern}\""
    fi
  fi

  # build -type parameter
  if [ -n "${__bf_file_type}" ]; then
    if _is_psv "${__bf_file_type}"; then
      if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT} && ${__UAC_TOOL_FIND_TYPE_SUPPORT}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-type\" \"${__bf_file_type}\"` \)"
      elif ${__bf_perl_command_exists}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-type\" \"${__bf_file_type}\"` \)"
        __bf_find_tool="find.pl"
      elif ${__UAC_TOOL_FIND_TYPE_SUPPORT}; then
        # shellcheck disable=SC2162,SC2030
        echo "${__bf_file_type}" \
          | awk 'BEGIN{RS="|"} {print $0}' \
          | while read __bf_file_type_line && [ -n "${__bf_file_type_line}" ]; do
              _build_find_command \
                "${__bf_path}" \
                "${__bf_path_pattern}" \
                "${__bf_name_pattern}" \
                "${__bf_exclude_path_pattern}" \
                "${__bf_exclude_name_pattern}" \
                "${__bf_max_depth}" \
                "${__bf_file_type_line}" \
                "${__bf_min_file_size}" \
                "${__bf_max_file_size}" \
                "${__bf_permissions}" \
                "${__bf_no_group}" \
                "${__bf_no_user}" \
                "${__bf_print0}" \
                "${__bf_start_date_days}" \
                "${__bf_end_date_days}" \
                true
            done
        return
      fi
    elif ${__UAC_TOOL_FIND_TYPE_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-type ${__bf_file_type}"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-type ${__bf_file_type}"
      __bf_find_tool="find.pl"
    fi
  fi

  # build -size parameter
  if [ -n "${__bf_min_file_size}" ]; then
    if ${__UAC_TOOL_FIND_SIZE_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-size +${__bf_min_file_size}c"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-size +${__bf_min_file_size}c"
      __bf_find_tool="find.pl"
    fi
  fi
  if [ -n "${__bf_max_file_size}" ]; then
    if ${__UAC_TOOL_FIND_SIZE_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-size -${__bf_max_file_size}c"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-size -${__bf_max_file_size}c"
      __bf_find_tool="find.pl"
    fi
  fi

  # build -perm parameter
  # -perm parameter will be added even if find does not support it
  if [ -n "${__bf_permissions}" ]; then
    if _is_psv "${__bf_permissions}"; then
      if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-perm\" \"${__bf_permissions}\"` \)"
      elif ${__bf_perl_command_exists}; then
        __bf_find_params="${__bf_find_params}${__bf_find_params:+ }\( `_build_recursive_parameter \"-perm\" \"${__bf_permissions}\"` \)"
        __bf_find_tool="find.pl"
      else
        # shellcheck disable=SC2162,SC2030
        echo "${__bf_permissions}" \
          | awk 'BEGIN{RS="|"} {print $0}' \
          | while read __bf_permissions_line && [ -n "${__bf_permissions_line}" ]; do
              _build_find_command \
                "${__bf_path}" \
                "${__bf_path_pattern}" \
                "${__bf_name_pattern}" \
                "${__bf_exclude_path_pattern}" \
                "${__bf_exclude_name_pattern}" \
                "${__bf_max_depth}" \
                "${__bf_file_type}" \
                "${__bf_min_file_size}" \
                "${__bf_max_file_size}" \
                "${__bf_permissions_line}" \
                "${__bf_no_group}" \
                "${__bf_no_user}" \
                "${__bf_print0}" \
                "${__bf_start_date_days}" \
                "${__bf_end_date_days}" \
                true
            done
        return
      fi
    else
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-perm ${__bf_permissions}"
    fi
  fi

  # build -nogroup parameter
  # -nogroup parameter will be added even if find does not support it
  if ${__bf_no_group}; then
    __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-nogroup"
    if ${__UAC_TOOL_FIND_NOGROUP_SUPPORT}; then
      true
    elif ${__bf_perl_command_exists}; then
      __bf_find_tool="find.pl"
    fi
  fi

  # build -nouser parameter
  # -nouser parameter will be added even if find does not support it
  if ${__bf_no_user}; then
    __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-nouser"
    if ${__UAC_TOOL_FIND_NOUSER_SUPPORT}; then
      true
    elif ${__bf_perl_command_exists}; then
      __bf_find_tool="find.pl"
    fi
  fi

  # build -mtime parameter
  __bf_find_mtime_param=""
  if ${__UAC_CONF_ENABLE_FIND_MTIME}; then
    if [ "${__bf_start_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_MTIME_SUPPORT}; then
        __bf_find_mtime_param="${__bf_find_mtime_param}${__bf_find_mtime_param:+ }-mtime -${__bf_start_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_mtime_param="${__bf_find_mtime_param}${__bf_find_mtime_param:+ }-mtime -${__bf_start_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
    if [ "${__bf_end_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_MTIME_SUPPORT}; then
        __bf_find_mtime_param="${__bf_find_mtime_param}${__bf_find_mtime_param:+ }-mtime +${__bf_end_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_mtime_param="${__bf_find_mtime_param}${__bf_find_mtime_param:+ }-mtime +${__bf_end_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
  fi

  # build -atime parameter
  __bf_find_atime_param=""
  if ${__UAC_CONF_ENABLE_FIND_ATIME}; then
    if [ "${__bf_start_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_ATIME_SUPPORT}; then
        __bf_find_atime_param="${__bf_find_atime_param}${__bf_find_atime_param:+ }-atime -${__bf_start_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_atime_param="${__bf_find_atime_param}${__bf_find_atime_param:+ }-atime -${__bf_start_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
    if [ "${__bf_end_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_ATIME_SUPPORT}; then
        __bf_find_atime_param="${__bf_find_atime_param}${__bf_find_atime_param:+ }-atime +${__bf_end_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_atime_param="${__bf_find_atime_param}${__bf_find_atime_param:+ }-atime +${__bf_end_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
  fi

  # build -ctime parameter
  __bf_find_ctime_param=""
  if ${__UAC_CONF_ENABLE_FIND_CTIME}; then
    if [ "${__bf_start_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_CTIME_SUPPORT}; then
        __bf_find_ctime_param="${__bf_find_ctime_param}${__bf_find_ctime_param:+ }-ctime -${__bf_start_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_ctime_param="${__bf_find_ctime_param}${__bf_find_ctime_param:+ }-ctime -${__bf_start_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
    if [ "${__bf_end_date_days}" -gt 0 ]; then
      if ${__UAC_TOOL_FIND_CTIME_SUPPORT}; then
        __bf_find_ctime_param="${__bf_find_ctime_param}${__bf_find_ctime_param:+ }-ctime +${__bf_end_date_days}"
      elif ${__bf_perl_command_exists}; then
        __bf_find_ctime_param="${__bf_find_ctime_param}${__bf_find_ctime_param:+ }-ctime +${__bf_end_date_days}"
        __bf_find_tool="find.pl"
      fi
    fi
  fi

  # build -mtime, -atime and -ctime together
  __bf_find_date_range_param=""
  if {
        { [ -n "${__bf_find_mtime_param}" ] && [ -n "${__bf_find_atime_param}" ]; } || \
        { [ -n "${__bf_find_mtime_param}" ] && [ -n "${__bf_find_ctime_param}" ]; } || \
        { [ -n "${__bf_find_atime_param}" ] && [ -n "${__bf_find_ctime_param}" ]; } 
      } && \
      { ${__UAC_TOOL_FIND_OPERATORS_SUPPORT} || ${__bf_perl_command_exists}; }; then
      # multiples date range parameters enabled
    if ${__UAC_TOOL_FIND_OPERATORS_SUPPORT}; then
      true
    else
      __bf_find_tool="find.pl"
    fi
    if [ -n "${__bf_find_mtime_param}" ]; then
      __bf_find_date_range_param="${__bf_find_date_range_param}${__bf_find_date_range_param:+ }\( ${__bf_find_mtime_param} \)"
    fi
    if [ -n "${__bf_find_ctime_param}" ]; then
      if [ -n "${__bf_find_date_range_param}" ]; then
        __bf_find_date_range_param="${__bf_find_date_range_param}${__bf_find_date_range_param:+ }-o"
      fi
      __bf_find_date_range_param="${__bf_find_date_range_param}${__bf_find_date_range_param:+ }\( ${__bf_find_ctime_param} \)"
    fi
    if [ -n "${__bf_find_atime_param}" ]; then
      if [ -n "${__bf_find_date_range_param}" ]; then
        __bf_find_date_range_param="${__bf_find_date_range_param}${__bf_find_date_range_param:+ }-o"
      fi
      __bf_find_date_range_param="${__bf_find_date_range_param}${__bf_find_date_range_param:+ }\( ${__bf_find_atime_param} \)"
    fi
    __bf_find_date_range_param="\( ${__bf_find_date_range_param} \)"
  else
    # only one date range parameter enabled
    if [ -n "${__bf_find_mtime_param}" ]; then
      __bf_find_date_range_param="${__bf_find_mtime_param}"
    elif [ -n "${__bf_find_ctime_param}" ]; then
      __bf_find_date_range_param="${__bf_find_ctime_param}"
    elif [ -n "${__bf_find_atime_param}" ]; then
      __bf_find_date_range_param="${__bf_find_atime_param}"
    fi
  fi

  if [ -n "${__bf_find_params}" ]; then
    __bf_find_params="${__bf_find_params}${__bf_find_date_range_param:+ }${__bf_find_date_range_param}"
  else
    __bf_find_params="${__bf_find_date_range_param}"
  fi
  
  # build -print0 parameter
  if ${__bf_print0}; then
    if ${__UAC_TOOL_FIND_PRINT0_SUPPORT}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-print0"
    elif ${__bf_perl_command_exists}; then
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-print0"
      __bf_find_tool="find.pl"
    else
      __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-print"
    fi
  else
    __bf_find_params="${__bf_find_params}${__bf_find_params:+ }-print"
  fi

  if ${__bf_is_recursive}; then
    printf "%s %s %s; " "${__bf_find_tool}" "${__bf_path}" "${__bf_find_params}"
  else
    printf "%s %s %s" "${__bf_find_tool}" "${__bf_path}" "${__bf_find_params}"
  fi

}
