#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Get the path to the bin directory based on the system's architecture.
# Arguments:
#   string operating_system: operating system name
#   string arch: system architecture
# Returns:
#   string: path
_get_bin_path()
{
  __gb_os="${1:-linux}"
  __gb_arch="${2:-x86_64}"

  _get_system_arch_bin_path()
  {   
    case "${1:-x86_64}" in
      armv[34567]*)
        echo "arm"
        ;;
      aarch64*|armv[89]*)
        echo "arm64"
        ;;
      athlon*|"i386"|"i486"|"i586"|"i686"|pentium*)
        echo "i686"
        ;;
      "mips"|"mipsel")
        echo "mips"
        ;;
      mips64*)
        echo "mips64"
        ;;
      "ppc")
        echo "ppc"
        ;;
      "ppcle")
        echo "ppcle"
        ;;
      "ppc64")
        echo "ppc64"
        ;;
      "ppc64le")
        echo "ppc64le"
        ;;
      s390*)
        echo "s390x"
        ;;
      "sparc")
        echo "sparc"
        ;;
      "sparc64")
        echo "sparc64"
        ;;
      *)
        echo "x86_64"
        ;;
    esac
  }

  __gb_correct_arch=`_get_system_arch_bin_path "${__gb_arch}"`
  __gb_path=""

  # zip tool
  # test whether zip can run in the target system before adding it to PATH
  for __gb_dir in "${__UAC_DIR}"/tools/zip/*; do
    if echo "${__gb_dir}" | grep -q -E "${__gb_os}"; then
      if eval "${__gb_dir}/${__gb_correct_arch}/zip" - "${__UAC_DIR}/uac" >/dev/null 2>/dev/null; then
        __gb_path="${__gb_path}${__gb_path:+:}${__gb_dir}/${__gb_correct_arch}"
      fi
    fi
  done

  # statx tool
  for __gb_dir in "${__UAC_DIR}"/tools/statx/*; do
    if echo "${__gb_dir}" | grep -q -E "${__gb_os}"; then
      __gb_path="${__gb_path}${__gb_path:+:}${__gb_dir}/${__gb_correct_arch}"
    fi
  done

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