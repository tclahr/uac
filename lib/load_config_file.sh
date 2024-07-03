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
    _error_msg "config file: no such file or directory: '${__lc_config_file}'"
    return 1
  fi

  __UAC_CONF_EXCLUDE_PATH_PATTERN=""
  __UAC_CONF_EXCLUDE_NAME_PATTERN=""
  __UAC_CONF_EXCLUDE_FILE_SYSTEM=""
  __UAC_CONF_HASH_ALGORITHM="md5|sha1"
  __UAC_CONF_MAX_DEPTH=0
  __UAC_CONF_ENABLE_FIND_MTIME=true
  __UAC_CONF_ENABLE_FIND_ATIME=false
  __UAC_CONF_ENABLE_FIND_CTIME=true

  # load exclude_path_pattern option
  __lc_value=`sed -n -e 's|exclude_path_pattern\: *\(.*\)|\1|p' "${__lc_config_file}" | _array_to_psv`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_EXCLUDE_PATH_PATTERN="${__lc_value}"
  fi

  # load exclude_name_pattern option
  __lc_value=`sed -n -e 's|exclude_name_pattern\: *\(.*\)|\1|p' "${__lc_config_file}" | _array_to_psv`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_EXCLUDE_NAME_PATTERN="${__lc_value}"
  fi

  # load exclude_file_system option
  __lc_value=`sed -n -e 's|exclude_file_system\: *\(.*\)|\1|p' "${__lc_config_file}" | _array_to_psv`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_EXCLUDE_FILE_SYSTEM="${__lc_value}"
  fi

  # load hash_algorithm option
  __lc_value=`sed -n -e 's|hash_algorithm\: *\(.*\)|\1|p' "${__lc_config_file}" | _array_to_psv`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_HASH_ALGORITHM="${__lc_value}"
  fi
  __lc_valid_values="md5|sha1|sha256"
  for __lc_item in `echo "${__UAC_CONF_HASH_ALGORITHM}" | sed -e 's:|: :g'`; do
    _is_in_list "${__lc_item}" "${__lc_valid_values}" || { _error_msg "config file: invalid hash algorithm '${__lc_item}'"; return 1; }
  done

  # load max_depth option
  __lc_value=`sed -n -e 's|max_depth\: *\(.*\)|\1|p' "${__lc_config_file}" | sed -e 's|  *||'`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_MAX_DEPTH="${__lc_value}"
  fi
  if _is_digit "${__UAC_CONF_MAX_DEPTH}" && [ "${__UAC_CONF_MAX_DEPTH}" -ge 0 ]; then
    true
  else
    _error_msg "config file: 'max_depth' must be zero or a positive integer."
    return 1
  fi

  # load enable_find_mtime option
  __lc_value=`sed -n -e 's|  *$||' -e 's:enable_find_mtime\: *\(.*\):\1:p' "${__lc_config_file}"`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_ENABLE_FIND_MTIME="${__lc_value}"
  fi
  if [ "${__UAC_CONF_ENABLE_FIND_MTIME}" != true ]; then
    __UAC_CONF_ENABLE_FIND_MTIME=false
  fi

  # load enable_find_atime option
  __lc_value=`sed -n -e 's|  *$||' -e 's:enable_find_atime\: *\(.*\):\1:p' "${__lc_config_file}"`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_ENABLE_FIND_ATIME="${__lc_value}"
  fi
  if [ "${__UAC_CONF_ENABLE_FIND_ATIME}" != true ]; then
    __UAC_CONF_ENABLE_FIND_ATIME=false
  fi

  # load enable_find_ctime option
  __lc_value=`sed -n -e 's|  *$||' -e 's:enable_find_ctime\: *\(.*\):\1:p' "${__lc_config_file}"`
  if [ -n "${__lc_value}" ]; then
    __UAC_CONF_ENABLE_FIND_CTIME="${__lc_value}"
  fi
  if [ "${__UAC_CONF_ENABLE_FIND_CTIME}" != true ]; then
    __UAC_CONF_ENABLE_FIND_CTIME=false
  fi

}