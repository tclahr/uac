#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Load config file (yaml) to set global variables.
# Arguments:
#   string config_file: full path to the config file
# Returns:
#   none
_load_config_file()
{
  __lc_config_file="${1:-}"

  if [ ! -f "${__lc_config_file}" ]; then
    _error_msg "Configuration file '${__lc_config_file}' does not exist."
    return 1
  fi

  __UAC_CONF_EXCLUDE_PATH_PATTERN="${__UAC_CONF_EXCLUDE_PATH_PATTERN:-}"
  __UAC_CONF_EXCLUDE_NAME_PATTERN="${__UAC_CONF_EXCLUDE_NAME_PATTERN:-}"
  __UAC_CONF_EXCLUDE_FILE_SYSTEM="${__UAC_CONF_EXCLUDE_FILE_SYSTEM:-9p|afs|autofs|cifs|davfs|fuse|kernfs|nfs|nfs4|rpc_pipefs|smbfs|sysfs}"
  __UAC_CONF_HASH_ALGORITHM="${__UAC_CONF_HASH_ALGORITHM:-md5|sha1}"
  __UAC_CONF_MAX_DEPTH="${__UAC_CONF_MAX_DEPTH:-0}"
  __UAC_CONF_ENABLE_FIND_MTIME="${__UAC_CONF_ENABLE_FIND_MTIME:-true}"
  __UAC_CONF_ENABLE_FIND_ATIME="${__UAC_CONF_ENABLE_FIND_ATIME:-false}"
  __UAC_CONF_ENABLE_FIND_CTIME="${__UAC_CONF_ENABLE_FIND_CTIME:-true}"

  # remove lines starting with # (comments) and any inline comments
  # remove leading and trailing space characters
  # remove blank lines
  __lc_config_file_content=`sed -e 's|#.*$||g' \
                                -e 's|^  *||' \
                                -e 's|  *$||' \
                                -e '/^$/d' "${__lc_config_file}"`

  # load exclude_path_pattern option
  if echo "${__lc_config_file_content}" | grep -q "exclude_path_pattern:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|exclude_path_pattern\: *\(.*\)|\1|p'`
    if echo "${__lc_value}" | grep -q -v -E "^\[.*\]$"; then
      _error_msg "Configuration option 'exclude_path_pattern' must be a list."
      return 1
    fi
    __UAC_CONF_EXCLUDE_PATH_PATTERN=`echo "${__lc_value}" | _array_to_psv 2>/dev/null`
  fi

  # load exclude_name_pattern option
  if echo "${__lc_config_file_content}" | grep -q "exclude_name_pattern:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|exclude_name_pattern\: *\(.*\)|\1|p'`
    if echo "${__lc_value}" | grep -q -v -E "^\[.*\]$"; then
      _error_msg "Configuration option 'exclude_name_pattern' must be a list."
      return 1
    fi
    __UAC_CONF_EXCLUDE_NAME_PATTERN=`echo "${__lc_value}" | _array_to_psv 2>/dev/null`
  fi

  # load exclude_file_system option
  if echo "${__lc_config_file_content}" | grep -q "exclude_file_system:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|exclude_file_system\: *\(.*\)|\1|p'`
    if echo "${__lc_value}" | grep -q -v -E "^\[.*\]$"; then
      _error_msg "Configuration option 'exclude_file_system' must be a list."
      return 1
    fi
    __UAC_CONF_EXCLUDE_FILE_SYSTEM=`echo "${__lc_value}" | _array_to_psv 2>/dev/null`
  fi

  # load hash_algorithm option
  if echo "${__lc_config_file_content}" | grep -q "hash_algorithm:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|hash_algorithm\: *\(.*\)|\1|p'`
    if echo "${__lc_value}" | grep -q -v -E "^\[.*\]$"; then
      _error_msg "Configuration option 'hash_algorithm' must be a list."
      return 1
    fi
    __UAC_CONF_HASH_ALGORITHM=`echo "${__lc_value}" | _array_to_psv 2>/dev/null`
    __lc_valid_values="md5|sha1|sha256"
    for __lc_item in `echo "${__UAC_CONF_HASH_ALGORITHM}" | sed -e 's:|: :g'`; do
      _is_in_list "${__lc_item}" "${__lc_valid_values}" || { _error_msg "Configuration option Invalid hash algorithm '${__lc_item}'"; return 1; }
    done
  fi

  # load max_depth option
  if echo "${__lc_config_file_content}" | grep -q "max_depth:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|max_depth\: *\(.*\)|\1|p'`
    if _is_digit "${__lc_value}" && [ "${__lc_value}" -ge 0 ]; then
      true
    else
      _error_msg "Configuration option 'max_depth' must be an integer greater than or equal to zero."
      return 1
    fi
    __UAC_CONF_MAX_DEPTH="${__lc_value}"    
  fi

  # load enable_find_mtime option
  if echo "${__lc_config_file_content}" | grep -q "enable_find_mtime:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|enable_find_mtime\: *\(.*\)|\1|p'`
    if [ "${__lc_value}" != true ] && [ "${__lc_value}" != false ]; then
      _error_msg "Configuration option 'enable_find_mtime' must be 'true' or 'false'."
      return 1
    fi
    __UAC_CONF_ENABLE_FIND_MTIME="${__lc_value}"    
  fi

  # load enable_find_atime option
  if echo "${__lc_config_file_content}" | grep -q "enable_find_atime:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|enable_find_atime\: *\(.*\)|\1|p'`
    if [ "${__lc_value}" != true ] && [ "${__lc_value}" != false ]; then
      _error_msg "Configuration option 'enable_find_atime' must be 'true' or 'false'."
      return 1
    fi
    __UAC_CONF_ENABLE_FIND_ATIME="${__lc_value}"    
  fi

  # load enable_find_ctime option
  if echo "${__lc_config_file_content}" | grep -q "enable_find_ctime:"; then
    __lc_value=`echo "${__lc_config_file_content}" | sed -n -e 's|enable_find_ctime\: *\(.*\)|\1|p'`
    if [ "${__lc_value}" != true ] && [ "${__lc_value}" != false ]; then
      _error_msg "Configuration option 'enable_find_ctime' must be 'true' or 'false'."
      return 1
    fi
    __UAC_CONF_ENABLE_FIND_CTIME="${__lc_value}"    
  fi

}