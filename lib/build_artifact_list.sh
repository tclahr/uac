#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Build the artifact list to be used during execution based on the 
# artifacts provided in the command line.
# Arguments:
#   string artifact_list: comma-separated list of artifacts
#   string operating_system: operating system (default: all)
# Returns:
#   string: artifact list (line by line)
_build_artifact_list()
{ 
  __ba_artifact_list="${1:-}"
  __ba_operating_system="${2:-all}"

  # some systems use busybox's find that not always support '-type f'
  # skip artifacts that are not applicable to the target operating system
  __ba_OIFS="${IFS}"; IFS="
";
  for __ba_item in ${__ba_artifact_list}; do
    if [ -f "${__ba_item}" ]; then
      if grep -q -E "supported_os:.*all|${__ba_operating_system}" "${__ba_item}" 2>/dev/null || ${__UAC_IGNORE_OPERATING_SYSTEM:-false}; then
        echo "${__ba_item}"
      fi
    fi
  done
  IFS="${__ba_OIFS}"

}
