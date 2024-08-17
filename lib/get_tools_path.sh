#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Get the proper tools directory path based on the system's operating system and architecture.
# Arguments:
#   string operating_system: operating system name
#   string arch: system architecture
# Returns:
#   string: path
_get_tools_path()
{
  __gt_os="${1:-linux}"
  __gt_arch="${2:-x86_64}"

  __gt_correct_arch=`_get_system_arch_bin_path "${__gt_arch}"`
  __gt_path=""

  # zip tool
  # test whether zip can run in the target system before adding it to PATH
  for __gt_dir in "${__UAC_DIR}"/tools/zip/*; do
    if echo "${__gt_dir}" | grep -q -E "${__gt_os}"; then
      if eval "${__gt_dir}/${__gt_correct_arch}/zip" - "${__UAC_DIR}/uac" >/dev/null 2>/dev/null; then
        __gt_path="${__gt_path}${__gt_path:+:}${__gt_dir}/${__gt_correct_arch}"
      fi
    fi
  done

  # statx tool
  for __gt_dir in "${__UAC_DIR}"/tools/statx/*; do
    if echo "${__gt_dir}" | grep -q -E "${__gt_os}"; then
      __gt_path="${__gt_path}${__gt_path:+:}${__gt_dir}/${__gt_correct_arch}"
    fi
  done

  echo "${__gt_path}"

}