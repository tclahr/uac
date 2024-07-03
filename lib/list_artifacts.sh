#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# List available artifacts.
# Arguments:
#   string artifacts_dir: full path to the artifacts directory
#   string os: operating system (default: all)
# Returns:
#   none
_list_artifacts()
{
  __la_artifacts_dir="${1:-}"
  __la_os="${2:-all}"
  
  if [ ! -d "${__la_artifacts_dir}" ]; then
    _error_msg "list artifacts: no such file or directory: '${__la_artifacts_dir}'"
    return 1
  fi

  if [ "${__la_os}" = "all" ] || _is_in_list "${__la_os}" "aix|esxi|freebsd|linux|macos|netbsd|netscaler|openbsd|solaris"; then
    true
  else
    _error_msg "list artifacts: invalid operating system '${__la_os}'"
    return 1
  fi

  # Get artifacts for all or a specific operating system.
  # Arguments:
  #   string artifacts_dir: full path to the artifacts directory
  #   string os: operating system (default: all)
  # Returns:
  #   string: list of artifacts
  _get_operating_system_artifact_list()
  {
    __oa_artifacts_dir="${1:-}"
    __oa_os="${2:-all}"

    if [ "${__oa_os}" = "all" ]; then
      find "${__oa_artifacts_dir}"/* -name "*.yaml" -print 2>/dev/null \
        | sed -e "s|^${__oa_artifacts_dir}/||" 2>/dev/null
    else
      __oa_OIFS="${IFS}"
      IFS="
"
      __oa_artifacts_tmp=`find "${__oa_artifacts_dir}"/* -name "*.yaml" -print 2>/dev/null`
      for __oa_item in ${__oa_artifacts_tmp}; do
        if grep -q -E "supported_os:.*all|${__oa_os}" "${__oa_item}" 2>/dev/null; then
          echo "${__oa_item}" | sed -e "s|^${__oa_artifacts_dir}/||" 2>/dev/null
        fi
      done
      IFS="${__oa_OIFS}"
    fi
  }

  __la_selected_artifacts=`_get_operating_system_artifact_list "${__la_artifacts_dir}" "${__la_os}"`
  __la_artifact_count=`echo "${__la_selected_artifacts}" | wc -l`

  printf "%s\n%s\n%s\n%s\n%s\n%s\n" \
"--------------------------------------------------------------------------------" \
"${__la_os} artifacts" \
"--------------------------------------------------------------------------------" \
"${__la_selected_artifacts}" \
"--------------------------------------------------------------------------------" \
"Total: ${__la_artifact_count}"

  return 0
}