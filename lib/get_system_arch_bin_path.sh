#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Get the proper bin directory name based on the system's architecture.
# Arguments:
#   string arch: system architecture
# Returns:
#   string: directory name
_get_system_arch_bin_path()
{
  __gy_arch="${1:-x86_64}"

  case "${__gy_arch}" in
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
