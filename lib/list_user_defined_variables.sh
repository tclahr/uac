#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2162

# List user-defined variables.
# Arguments:
#   string artifacts_dir: full path to the artifacts directory
# Returns:
#   none
_list_user_defined_variables()
{
  __lv_artifacts_dir="${1:-}"
  
  if [ ! -d "${__lv_artifacts_dir}" ]; then
    _error_msg "Artifacts directory '${__lv_artifacts_dir}' does not exist."
    return 1
  fi

  find "${__lv_artifacts_dir}"/* -name "*.yaml" -print 2>/dev/null \
    | sort -u \
    | while read __lv_artifact || [ -n "${__lv_artifact}" ]; do
        __lv_print_artifact_name=true
        sed -e 's|#.*$||g' \
            -e 's|^  *||' \
            -e 's|  *$||' \
            -e '/^$/d' "${__lv_artifact}" 2>/dev/null \
          | grep -E "^command:|^condition:|^foreach:|^path:" \
          | while read __lv_field || [ -n "${__lv_field}" ]; do
              if printf "%s\n" "${__lv_field}" \
                | grep -E '%[A-Za-z_][A-Za-z0-9_]*(=[^%]*)?%' \
                | grep -q -v -E '%(hostname|os|timestamp|uac_directory|mount_point|temp_directory|artifacts_output_directory|non_local_mount_points|start_date|start_date_epoch|end_date|end_date_epoch|user|user_home|line)(:[^%]*)?%'; then
                if ${__lv_print_artifact_name}; then
                  printf "%s\n" "${__lv_artifact}" | sed -e "s|^${__lv_artifacts_dir}/||"
                  __lv_print_artifact_name=false
                fi
                printf " > %s\n" "${__lv_field}"
              fi
            done
      done
        
  return 0
}