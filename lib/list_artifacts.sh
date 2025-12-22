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
    _error_msg "Artifacts directory '${__la_artifacts_dir}' does not exist."
    return 1
  fi

  case "${__la_os}" in
    all|aix|esxi|freebsd|haiku|linux|macos|netbsd|netscaler|openbsd|solaris)
      ;;
    *)
      _error_msg "Unsupported operating system: '${__la_os}'"
      return 1
      ;;
  esac

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

    # shellcheck disable=SC2162
    find "${__oa_artifacts_dir}"/* -name "*.yaml" -print 2>/dev/null \
      | sort -u \
      | while read __oa_item || [ -n "${__oa_item}" ]; do
          __oa_modifier=""

          if grep -q -E "modifier:.*true" "${__oa_item}" 2>/dev/null; then
            __oa_modifier=" (modifier)"
          fi

          if [ "${__oa_os}" = "all" ] || grep -q -E "supported_os:.*(all|${__oa_os})" "${__oa_item}"; then
            __oa_filename=`echo "${__oa_item}" | sed -e "s|^${__oa_artifacts_dir}/||" 2>/dev/null`
            echo "${__oa_filename}${__oa_modifier}"
          fi
        done

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
