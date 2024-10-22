#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Get the proper bin directory path based on the system's operating system and architecture.
# Arguments:
#   string operating_system: operating system name
#   string arch: system architecture
# Returns:
#   string: path
_get_bin_path()
{
  __gb_os="${1:-linux}"
  __gb_arch="${2:-x86_64}"

  __gb_correct_arch=`_get_system_arch_bin_path "${__gb_arch}"`
  __gb_path=""

  # bin directory
  for __gb_dir in "${__UAC_DIR}"/bin/*; do
    if echo "${__gb_dir}" | grep -q -E "${__gb_os}"; then
      __gb_path="${__gb_path}${__gb_path:+:}${__gb_dir}/${__gb_correct_arch}"
      __gb_path="${__gb_path}${__gb_path:+:}${__gb_dir}"
    fi
  done
  
  __gb_path="${__gb_path}${__gb_path:+:}${__UAC_DIR}/bin"
  echo "${__gb_path}"

}