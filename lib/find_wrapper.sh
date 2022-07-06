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

# shellcheck disable=SC2006

###############################################################################
# Use internal 'find' tool or 'find.pl' script to search for files in a 
# directory hierarchy.
# Globals:
#   ENABLE_FIND_ATIME
#   ENABLE_FIND_CTIME
#   ENABLE_FIND_MTIME
#   FIND_ATIME_SUPPORT
#   FIND_CTIME_SUPPORT
#   FIND_MAXDEPTH_SUPPORT
#   FIND_MTIME_SUPPORT
#   FIND_OPERATORS_SUPPORT
#   FIND_PATH_SUPPORT
#   FIND_PERM_SUPPORT
#   FIND_SIZE_SUPPORT
#   PERL_TOOL_AVAILABLE
#   UAC_DIR
# Requires:
#   get_mount_point_by_file_system
#   log_message
# Arguments:
#   $1: path
#   $2: path pattern (optional)
#   $3: name pattern (optional)
#   $4: exclude path pattern (optional)
#   $5: exclude name pattern (optional)
#   $6: max depth (optional)
#   $7: file type (optional)
#   $8: min file size (optional)
#   $9: max file size (optional)
#   $10: permissions (optional)
#   $11: date range start in days (optional) (default: 0)
#   $12: date range end in days (optional) (default: 0)
# Output:
#   Write search results to stdout.
#   Write any errors to stderr.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
find_wrapper()
{
  # some systems such as Solaris 10 do not support more than 9 parameters
  # on functions, not even using curly braces {} e.g. ${10}
  # so the solution was to use shift
  fw_path="${1:-}"
  shift
  fw_path_pattern="${1:-}"
  shift
  fw_name_pattern="${1:-}"
  shift
  fw_exclude_path_pattern="${1:-}"
  shift
  fw_exclude_name_pattern="${1:-}"
  shift
  fw_max_depth="${1:-}"
  shift
  fw_file_type="${1:-}"
  shift
  fw_min_file_size="${1:-}"
  shift
  fw_max_file_size="${1:-}"
  shift
  fw_permissions="${1:-}"
  shift
  fw_date_range_start_days="${1:-0}"
  shift
  fw_date_range_end_days="${1:-0}"

  #############################################################################
  # Build recursive parameter if a list of items is provided
  # Globals:
  #   None
  # Arguments:
  #   $1: parameter (-path or -name)
  #   $2: list of items
  # Output:
  #   Write the output to stdout
  # Return:
  #   None
  #############################################################################
  _build_recursive_param()
  {
    _br_param="${1:--name}"
    _br_items="${2:-}"

    if [ -n "${_br_items}" ]; then
      # remove white spaces between items and commas
      # remove empty items
      # replace escaped comma (\,) by #_COMMA_# string
      # replace escaped double quote (\") by #_DOUBLE_QUOTE_# string
      # replace #_COMMA_# string by comma (,)
      # replace #_DOUBLE_QUOTE_# string by escaped double quote (\")
      echo "${_br_items}" \
        | sed -e 's: *,:,:g' \
              -e 's:, *:,:g' \
              -e 's:^,*::' \
              -e 's:,*$::' \
              -e 's:\\,:#_COMMA_#:g' \
              -e 's:\\":#_DOUBLE_QUOTE_#:g' \
        | awk -v _br_param="${_br_param}" 'BEGIN { FS=","; } {
            for(N = 1; N <= NF; N ++) {
              if ($N != "") {
                gsub("#_COMMA_#", ",", $N);
                gsub("#_DOUBLE_QUOTE_#", "\\\"", $N);
                if (N == 1) {
                  printf "%s \"%s\"", _br_param, $N;
                } 
                else {
                  printf " -o %s \"%s\"", _br_param, $N;
                }
              }
            }
          }'
    fi
  }

  # return if starting point is empty
  if [ -z "${fw_path}" ]; then
    printf %b "find_wrapper: missing required argument: 'path'\n" >&2
    return 22
  fi

  fw_find_tool="find"
  fw_find_path_param=""
  fw_find_name_param=""
  fw_find_path_prune_param=""
  fw_find_name_prune_param=""
  fw_find_max_depth_param=""
  fw_find_type_param=""
  fw_find_min_file_size_param=""
  fw_find_max_file_size_param=""
  fw_find_perm_param=""
  fw_find_atime_param=""
  fw_find_mtime_param=""
  fw_find_ctime_param=""
  fw_find_date_range_param=""

  if ${FIND_OPERATORS_SUPPORT} || ${PERL_TOOL_AVAILABLE}; then
    # build -path -prune parameter
    if [ -n "${fw_exclude_path_pattern}" ]; then
      if ${FIND_PATH_SUPPORT}; then
        fw_find_path_prune_param="\( `_build_recursive_param \
          \"-path\" \"${fw_exclude_path_pattern}\"` \) -prune -o"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_path_prune_param="\( `_build_recursive_param \
          \"-path\" \"${fw_exclude_path_pattern}\"` \) -prune -o"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
    # build -name -prune parameter
    if [ -n "${fw_exclude_name_pattern}" ]; then
      fw_find_name_prune_param="\( `_build_recursive_param \
        \"-name\" \"${fw_exclude_name_pattern}\"` \) -prune -o"
    fi
    # build -path parameter
    if [ -n "${fw_path_pattern}" ]; then
      if ${FIND_PATH_SUPPORT}; then
        fw_find_path_param="\( `_build_recursive_param \
          \"-path\" \"${fw_path_pattern}\"` \)"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_path_param="\( `_build_recursive_param \
          \"-path\" \"${fw_path_pattern}\"` \)"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
  fi

  # build -maxdepth parameter
  if [ -n "${fw_max_depth}" ] && [ "${fw_max_depth}" -gt 0 ]; then
    if ${FIND_MAXDEPTH_SUPPORT}; then
      fw_find_max_depth_param="-maxdepth ${fw_max_depth}"
    elif ${PERL_TOOL_AVAILABLE}; then
      fw_find_max_depth_param="-maxdepth ${fw_max_depth}"
      fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
    fi
  fi

  # build -type parameter
  if [ -n "${fw_file_type}" ]; then
    if ${FIND_TYPE_SUPPORT}; then
      fw_find_type_param="-type ${fw_file_type}"
    elif ${PERL_TOOL_AVAILABLE}; then
      fw_find_type_param="-type ${fw_file_type}"
      fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
    fi
  fi

  # build -size parameter
  if [ -n "${fw_min_file_size}" ]; then
    if ${FIND_SIZE_SUPPORT}; then
      fw_find_min_file_size_param="-size +${fw_min_file_size}c"
    elif ${PERL_TOOL_AVAILABLE}; then
      fw_find_min_file_size_param="-size +${fw_min_file_size}c"
      fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
    fi
  fi
  if [ -n "${fw_max_file_size}" ]; then
    if ${FIND_SIZE_SUPPORT}; then
      fw_find_max_file_size_param="-size -${fw_max_file_size}c"
    elif ${PERL_TOOL_AVAILABLE}; then
      fw_find_max_file_size_param="-size -${fw_max_file_size}c"
      fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
    fi
  fi

  # build -perm parameter
  if [ -n "${fw_permissions}" ]; then
    if ${FIND_PERM_SUPPORT}; then
      fw_find_perm_param="-perm ${fw_permissions}"
    elif ${PERL_TOOL_AVAILABLE}; then
      fw_find_perm_param="-perm ${fw_permissions}"
      fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
    fi
  fi

  # build -atime parameter
  if ${ENABLE_FIND_ATIME}; then
    if [ "${fw_date_range_start_days}" -gt 0 ]; then
      if ${FIND_ATIME_SUPPORT}; then
        fw_find_atime_param="-atime -${fw_date_range_start_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_atime_param="-atime -${fw_date_range_start_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
    if [ "${fw_date_range_end_days}" -gt 0 ]; then
      if ${FIND_ATIME_SUPPORT}; then
        fw_find_atime_param="${fw_find_atime_param} \
-atime +${fw_date_range_end_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_atime_param="${fw_find_atime_param} \
-atime +${fw_date_range_end_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
  fi

  # build -mtime parameter
  if ${ENABLE_FIND_MTIME}; then
    if [ "${fw_date_range_start_days}" -gt 0 ]; then
      if ${FIND_MTIME_SUPPORT}; then
        fw_find_mtime_param="-mtime -${fw_date_range_start_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_mtime_param="-mtime -${fw_date_range_start_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
    if [ "${fw_date_range_end_days}" -gt 0 ]; then
      if ${FIND_MTIME_SUPPORT}; then
        fw_find_mtime_param="${fw_find_mtime_param} \
-mtime +${fw_date_range_end_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_mtime_param="${fw_find_mtime_param} \
-mtime +${fw_date_range_end_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
  fi

  # build -ctime parameter
  if ${ENABLE_FIND_CTIME}; then
    if [ "${fw_date_range_start_days}" -gt 0 ]; then
      if ${FIND_CTIME_SUPPORT}; then
        fw_find_ctime_param="-ctime -${fw_date_range_start_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_ctime_param="-ctime -${fw_date_range_start_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
    if [ "${fw_date_range_end_days}" -gt 0 ]; then
      if ${FIND_CTIME_SUPPORT}; then
        fw_find_ctime_param="${fw_find_ctime_param} \
-ctime +${fw_date_range_end_days}"
      elif ${PERL_TOOL_AVAILABLE}; then
        fw_find_ctime_param="${fw_find_ctime_param} \
-ctime +${fw_date_range_end_days}"
        fw_find_tool="perl \"${UAC_DIR}/tools/find.pl/find.pl\""
      fi
    fi
  fi

  if [ -n "${fw_find_atime_param}" ] || [ -n "${fw_find_mtime_param}" ] \
    || [ -n "${fw_find_ctime_param}" ]; then

    if ${FIND_OPERATORS_SUPPORT}; then
      # multiples date range parameters enabled
      if [ -n "${fw_find_atime_param}" ]; then
        fw_find_date_range_param="\( ${fw_find_atime_param} \)"
      fi
      if [ -n "${fw_find_mtime_param}" ]; then
        if [ -n "${fw_find_date_range_param}" ]; then
          fw_find_date_range_param=" ${fw_find_date_range_param} -o "
        fi
        fw_find_date_range_param=" ${fw_find_date_range_param} \
\( ${fw_find_mtime_param} \)"
      fi
      if [ -n "${fw_find_ctime_param}" ]; then
        if [ -n "${fw_find_date_range_param}" ]; then
          fw_find_date_range_param=" ${fw_find_date_range_param} -o "
        fi
        fw_find_date_range_param=" ${fw_find_date_range_param} \
\( ${fw_find_ctime_param} \)"
      fi
      fw_find_date_range_param="\( ${fw_find_date_range_param} \)"
    else
      # only one date range parameter enabled
      if [ -n "${fw_find_atime_param}" ]; then
        fw_find_date_range_param="${fw_find_atime_param}"
      elif [ -n "${fw_find_mtime_param}" ]; then
        fw_find_date_range_param="${fw_find_mtime_param}"
      elif [ -n "${fw_find_ctime_param}" ]; then
        fw_find_date_range_param="${fw_find_ctime_param}"
      fi
    fi

  fi

  # build -name parameter
  if [ -n "${fw_name_pattern}" ]; then
    if ${FIND_OPERATORS_SUPPORT} || ${PERL_TOOL_AVAILABLE}; then
      fw_find_name_param="\( `_build_recursive_param \"-name\" \
\"${fw_name_pattern}\"` \)"
      log_message COMMAND "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_prune_param} \
${fw_find_name_prune_param} \
${fw_find_path_param} \
${fw_find_name_param} \
${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
      eval "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_prune_param} \
${fw_find_name_prune_param} \
${fw_find_path_param} \
${fw_find_name_param} \
${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
    else
      # if operators are not supported, 'find' will be run for each -name value
      # shellcheck disable=SC2162
      echo "${fw_name_pattern}" \
        | sed -e 's:\\,:#_COMMA_#:g' -e 's: *,:,:g' -e 's:, *:,:g' \
          -e 's:, *:,:g' -e 's:^,*::' \
        | awk 'BEGIN { FS=","; } {
            for(N = 1; N <= NF; N ++) {
              printf "%s\n", $N;
            }
          }' \
        | sed -e 's:#_COMMA_#:,:g' \
        | while read fw_name || [ -n "${fw_name}" ]; do 
            log_message COMMAND "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_param} \
-name ${fw_name} ${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
            eval "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_param} \
-name ${fw_name} ${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
          done
    fi
  else
    log_message COMMAND "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_prune_param} \
${fw_find_name_prune_param} \
${fw_find_path_param} \
${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
    eval "${fw_find_tool} \
${fw_path} \
${fw_find_max_depth_param} \
${fw_find_path_prune_param} \
${fw_find_name_prune_param} \
${fw_find_path_param} \
${fw_find_type_param} \
${fw_find_min_file_size_param} \
${fw_find_max_file_size_param} \
${fw_find_perm_param} \
${fw_find_date_range_param} -print"
  fi

}