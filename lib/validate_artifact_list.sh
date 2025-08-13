#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006,SC2086

# Build the artifact list to be used during execution based on the artifacts provided in the command line.
# Arguments:
#   string artifact_list: comma-separated list of artifacts
#   string artifacts_dir: full path to the artifacts directory (default: artifacts)
# Returns:
#   string: artifact list (line by line)
_validate_artifact_list()
{
  # valid relative path
  #   live_response/process/ps.yaml
  #   artifacts/live_response/process/ps.yaml
  #   ./artifacts/live_response/process/ps.yaml
  # valid full path (only if the artifact is outside uac/artifacts directory)
  #   /tmp/my_custom_artifact.yaml
  # invalid relative path (all ../ will be removed)
  # ../uac/artifacts/live_response/process/ps.yaml
  
  __vl_artifact_list="${1:-}"
  __vl_artifacts_dir="${2:-artifacts}"

  __vl_updated_artifact_list=""
  
  # remove any ../
  # replace consecutive slashes by one slash
  # replace consecutive commas by one comma
  # remove leading and trailing comma
  __vl_artifact_list=`echo "${__vl_artifact_list}" \
    | sed -e 's|\.\./||g' \
          -e 's|//*|/|g' \
          -e 's|,,*|,|g' \
          -e 's|^,||' \
          -e 's|,$||'`

  __vl_OIFS="${IFS}"; IFS=","
  for __vl_artifact in ${__vl_artifact_list}; do
    case "${__vl_artifact}" in
      \!/*)
        __vl_artifact=`echo "${__vl_artifact}" | sed -e 's|^!||' 2>/dev/null`

        __vl_exclude_list=`find ${__vl_artifact} -print 2>/dev/null`

        if [ -z "${__vl_exclude_list}" ]; then
          _error_msg "Artifact '${__vl_artifact}' does not exist.\nTry 'uac --artifact list' to list all available artifacts."
          IFS="${__vl_OIFS}"
          return 1
        fi
        __vl_updated_artifact_list=`_filter_list "${__vl_updated_artifact_list}" "${__vl_exclude_list}"`
        ;;
      \!*)
        # remove leading !
        # remove leading ./
        # remove leading artifacts/
        __vl_artifact=`echo "${__vl_artifact}" | sed -e 's|^!||' -e 's|^\./||' -e 's|^artifacts/||' 2>/dev/null`

        __vl_exclude_list=`find "${__UAC_DIR}/artifacts"/${__vl_artifact} -print 2>/dev/null`

        if [ -z "${__vl_exclude_list}" ]; then
          _error_msg "Artifact '${__vl_artifact}' does not exist.\nTry 'uac --artifact list' to list all available artifacts."
          IFS="${__vl_OIFS}"
          return 1
        fi
        __vl_updated_artifact_list=`_filter_list "${__vl_updated_artifact_list}" "${__vl_exclude_list}"`
        ;;
      /*)
        __vl_include_list=`find ${__vl_artifact} -print 2>/dev/null`

        if [ -z "${__vl_include_list}" ]; then
          _error_msg "Artifact '${__vl_artifact}' does not exist.\nTry 'uac --artifact list' to list all available artifacts."
          IFS="${__vl_OIFS}"
          return 1
        fi
        __vl_updated_artifact_list="${__vl_updated_artifact_list}${__vl_updated_artifact_list:+
}${__vl_include_list}"
        ;;
      *)
        # remove leading !
        # remove leading ./
        # remove leading artifacts/
        __vl_artifact=`echo "${__vl_artifact}" | sed -e 's|^!||' -e 's|^\./||' -e 's|^artifacts/||' 2>/dev/null`

        __vl_include_list=`find "${__UAC_DIR}/artifacts"/${__vl_artifact} -print 2>/dev/null`
        
        if [ -z "${__vl_include_list}" ]; then
          _error_msg "Artifact '${__vl_artifact}' does not exist.\nTry 'uac --artifact list' to list all available artifacts."
          IFS="${__vl_OIFS}"
          return 1
        fi
        __vl_updated_artifact_list="${__vl_updated_artifact_list}${__vl_updated_artifact_list:+
}${__vl_include_list}"
        ;;
    esac
  done
  IFS="${__vl_OIFS}"

  # remove duplicates
  echo "${__vl_updated_artifact_list}" | awk '!a[$0]++'

}
