#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2086,SC2162

# Check whether the provided profile file has any errors.
# Arguments:
#   string profile: full path to the profile file
#   string artifacts_dir: full path to the artifacts directory
# Returns:
#   boolean: true on success
#            false on fail
_validate_profile()
{
  __vp_profile="${1:-}"
  __vp_artifacts_dir="${2:-artifacts}"

  if [ ! -f "${__vp_profile}" ]; then
    _error_msg "profile file: no such file or directory: '${__vp_profile}'"
    return 1
  fi

  __vp_name_prop_exists=false
  __vp_description_prop_exists=false
  __vp_artifacts_prop_exists=false
  __vp_artifact_list_exists=false

  # remove lines starting with # (comments) and any inline comments
  # remove leading and trailing space characters
  # remove blank lines
  # add a new line and '__EOF__' to the end of file
  printf "%s\n" "__EOF__" \
    | cat "${__vp_profile}" - \
    | sed -e 's|#.*$||g' \
          -e 's|^  *||' \
          -e 's|  *$||' \
          -e '/^$/d' \
    | while read __vp_key __vp_value; do

        case "${__vp_key}" in

          "artifacts:")
            ${__vp_artifacts_prop_exists} \
              && { _error_msg "profile: invalid duplicated 'artifacts' mapping."; return 1; }
            __vp_artifacts_prop_exists=true
            ;;
          "description:")
            if [ -z "${__vp_value}" ]; then
              _error_msg "profile: 'description' must not be empty."
              return 1
            fi
            __vp_description_prop_exists=true
            ;;
          "name:")
            if [ -z "${__vp_value}" ]; then
              _error_msg "profile: 'name' must not be empty."
              return 1
            fi
            __vp_name_prop_exists=true
            ;;
          "-"*)
            ${__vp_artifacts_prop_exists} \
              || { _error_msg "profile: missing 'artifacts' mapping."; return 1; }

            __vp_artifact=`echo "${__vp_value}" | sed -e 's|^!||' 2>/dev/null`

            if [ -z "${__vp_artifact}" ]; then
              _error_msg "profile: invalid empty artifact entry."
              return 1
            fi

            if find ${__vp_artifact} -print \
              >/dev/null 2>/dev/null; then
              true
            elif find "${__vp_artifacts_dir}"/${__vp_artifact} -print \
              >/dev/null 2>/dev/null; then
              true
            else
              _error_msg "profile: artifact not found '${__vp_artifact}'"
              return 1
            fi
            __vp_artifact_list_exists=true
            ;;
          "__EOF__")
            ${__vp_name_prop_exists} \
              || { _error_msg "profile: missing 'name' property."; return 1; }
            ${__vp_description_prop_exists} \
              || { _error_msg "profile: missing 'description' property."; return 1; }
            ${__vp_artifacts_prop_exists} \
              || { _error_msg "profile: missing 'artifacts' mapping."; return 1; }
            ${__vp_artifact_list_exists} \
              || { _error_msg "profile: 'artifacts' must have at least one artifact."; return 1; }
            ;;
          *)
            __vp_key=`echo "${__vp_key}" | sed -e 's|\|$||'`
            _error_msg "profile: invalid property '${__vp_key}'."
            return 1
        esac
      done
}