#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Setup required tools and parameters.
# Arguments:
#   none
# Returns:
#   none
_setup_tools()
{
  __UAC_TOOL_FIND_OPERATORS_SUPPORT=false
  __UAC_TOOL_FIND_PATH_SUPPORT=false
  __UAC_TOOL_FIND_PRUNE_SUPPORT=false
  __UAC_TOOL_FIND_SIZE_SUPPORT=false
  __UAC_TOOL_FIND_MAXDEPTH_SUPPORT=false
  __UAC_TOOL_FIND_PERM_SUPPORT=false
  __UAC_TOOL_FIND_NOGROUP_SUPPORT=false
  __UAC_TOOL_FIND_NOUSER_SUPPORT=false
  __UAC_TOOL_FIND_TYPE_SUPPORT=false
  __UAC_TOOL_FIND_MTIME_SUPPORT=false
  __UAC_TOOL_FIND_ATIME_SUPPORT=false
  __UAC_TOOL_FIND_CTIME_SUPPORT=false
  __UAC_TOOL_FIND_PRINT0_SUPPORT=false
  __UAC_TOOL_XARGS_NULL_DELIMITER_SUPPORT=false
  __UAC_TOOL_XARGS_BACKSLASH_ESCAPE_SUPPORT=false
  __UAC_TOOL_STAT_BIN=""
  __UAC_TOOL_STAT_PARAMS=""
  __UAC_TOOL_TAR_NO_FROM_FILE_SUPPORT=false
  __UAC_TOOL_TAR_FROM_FILE_OPTION=""
  __UAC_MAX_FILENAME_SIZE=118
  __UAC_TOOL_MD5_BIN=""
  __UAC_TOOL_SHA1_BIN=""
  __UAC_TOOL_SHA256_BIN=""
  
  # check which options are supported by 'find'
  if find "${__UAC_DIR}" \( -name "uac" -o -name "uac.conf" \) -print >/dev/null; then
    __UAC_TOOL_FIND_OPERATORS_SUPPORT=true
  fi
  if find "${__UAC_DIR}" -path "${__UAC_DIR}" -print >/dev/null; then
    __UAC_TOOL_FIND_PATH_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -name "uac" -prune -o -print >/dev/null; then
    __UAC_TOOL_FIND_PRUNE_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -size +1c -print >/dev/null; then
    __UAC_TOOL_FIND_SIZE_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -maxdepth 1 -print >/dev/null; then
    __UAC_TOOL_FIND_MAXDEPTH_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -perm 755 -print >/dev/null; then
    __UAC_TOOL_FIND_PERM_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -nogroup -print >/dev/null; then
    __UAC_TOOL_FIND_NOGROUP_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -nouser -print >/dev/null; then
    __UAC_TOOL_FIND_NOUSER_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -type f -print >/dev/null; then
    __UAC_TOOL_FIND_TYPE_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -mtime +1 -print >/dev/null; then
    __UAC_TOOL_FIND_MTIME_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -atime +1 -print >/dev/null; then
    __UAC_TOOL_FIND_ATIME_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -ctime +1 -print >/dev/null; then
    __UAC_TOOL_FIND_CTIME_SUPPORT=true
  fi
  if find "${__UAC_DIR}/uac" -print0 >/dev/null; then
    __UAC_TOOL_FIND_PRINT0_SUPPORT=true
  fi
  
  if echo "uac" | xargs -0 echo >/dev/null; then
    __UAC_TOOL_XARGS_NULL_DELIMITER_SUPPORT=true
  fi

  if echo '\/tmp' | xargs echo | grep -q -E "^/"; then
    __UAC_TOOL_XARGS_BACKSLASH_ESCAPE_SUPPORT=true
  fi
  
  # check which stat tool and options are available for the target system
  if statx "${__UAC_MOUNT_POINT}" | grep -q -E "\|[0-9]+\|[0-9]+\|[0-9]+$"; then
    __UAC_TOOL_STAT_BIN="statx"
  elif stat -c "0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W" "${__UAC_MOUNT_POINT}" | grep -q -E "\|[0-9]+\|[0-9]+\|[0-9]+\|"; then
    __UAC_TOOL_STAT_BIN="stat"
    __UAC_TOOL_STAT_PARAMS="-c \"0|%N|%i|%A|%u|%g|%s|%X|%Y|%Z|%W\""
  elif stat -f "0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B" "${__UAC_MOUNT_POINT}" | grep -q -E "\|[0-9]+\|[0-9]+\|[0-9]+\|"; then
    __UAC_TOOL_STAT_BIN="stat"
    __UAC_TOOL_STAT_PARAMS="-f \"0|%N%SY|%i|%Sp|%u|%g|%z|%a|%m|%c|%B\""
  elif stat.pl "${__UAC_MOUNT_POINT}" | grep -q -E "\|[0-9]+\|[0-9]+\|[0-9]+$"; then
    __UAC_TOOL_STAT_BIN="stat.pl"
  elif statf "${__UAC_MOUNT_POINT}" | grep -q -E "\|[0-9]+\|[0-9]+\|[0-9]+\|"; then
    __UAC_TOOL_STAT_BIN="statf"
  fi

  # the option used by 'tar' to read the list of files from a file differs
  # between implementations (GNU: -T, AIX: -L, BSD: -I, Solaris: -I after -cf),
  # and the same operating system may ship different tar versions, so each
  # variant is tested until one is able to create a package from a file list
  echo "${__UAC_DIR}/uac" >"${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" 2>/dev/null
  for __tf_option in "T" "I" "L" "I_AFTER"; do
    rm -f "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" 2>/dev/null
    case "${__tf_option}" in
      "T")
        tar -T "${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" -cf "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" >/dev/null 2>&1
        ;;
      "I")
        tar -I "${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" -cf "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" >/dev/null 2>&1
        ;;
      "L")
        tar -L "${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" -cf "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" >/dev/null 2>&1
        ;;
      "I_AFTER")
        tar -cf "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" -I "${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" >/dev/null 2>&1
        ;;
    esac
    # exit code is not enough (e.g. GNU tar -I is --use-compress-program),
    # so check that the package contains the expected file
    if tar -tf "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" 2>/dev/null | grep -q -E "(^|/)uac$"; then
      __UAC_TOOL_TAR_FROM_FILE_OPTION="${__tf_option}"
      break
    fi
  done
  rm -f "${__UAC_TEMP_DATA_DIR}/tar_from_file.tmp" "${__UAC_TEMP_DATA_DIR}/tar_from_file.tar" 2>/dev/null
  if [ -z "${__UAC_TOOL_TAR_FROM_FILE_OPTION}" ]; then
    __UAC_TOOL_TAR_NO_FROM_FILE_SUPPORT=true
  fi

  # check if the maximum filename size that can be created in the file system is 255 characters
  if touch "${__UAC_TEMP_DATA_DIR}/1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"; then
    __UAC_MAX_FILENAME_SIZE=245
  fi

  # check for available MD5 hashing tools
  if command_exists "md5sum"; then
    __UAC_TOOL_MD5_BIN="md5sum"
  elif command_exists "md5"; then
    __UAC_TOOL_MD5_BIN="md5"
  elif echo "uac" | digest -v -a md5 >/dev/null; then
    __UAC_TOOL_MD5_BIN="digest -v -a md5"
  elif csum -h MD5 "${__UAC_DIR}/uac" >/dev/null; then
    __UAC_TOOL_MD5_BIN="csum -h MD5"
  elif echo "uac" | openssl dgst -md5 >/dev/null; then
    __UAC_TOOL_MD5_BIN="openssl dgst -md5"
  fi

  # check for available SHA1 hashing tools
  if command_exists "sha1sum"; then
    __UAC_TOOL_SHA1_BIN="sha1sum"
  elif echo "uac" | shasum -a 1 >/dev/null; then
    __UAC_TOOL_SHA1_BIN="shasum -a 1"
  elif command_exists "sha1"; then
    __UAC_TOOL_SHA1_BIN="sha1"
  elif echo "uac" | digest -v -a sha1 >/dev/null; then
    __UAC_TOOL_SHA1_BIN="digest -v -a sha1"
  elif csum -h SHA1 "${__UAC_DIR}/uac" >/dev/null; then
    __UAC_TOOL_SHA1_BIN="csum -h SHA1"
  elif echo "uac" | openssl dgst -sha1 >/dev/null; then
    __UAC_TOOL_SHA1_BIN="openssl dgst -sha1"
  fi

  # check for available SHA256 hashing tools
  if command_exists "sha256sum"; then
    __UAC_TOOL_SHA256_BIN="sha256sum"
  elif echo "uac" | shasum -a 256 >/dev/null; then
    __UAC_TOOL_SHA256_BIN="shasum -a 256"
  elif command_exists "sha256"; then
    __UAC_TOOL_SHA256_BIN="sha256"
  elif echo "uac" | digest -v -a sha256 >/dev/null; then
    __UAC_TOOL_SHA256_BIN="digest -v -a sha256"
  elif csum -h SHA256 "${__UAC_DIR}/uac" >/dev/null; then
    __UAC_TOOL_SHA256_BIN="csum -h SHA256"
  elif echo "uac" | openssl dgst -sha256 >/dev/null; then
    __UAC_TOOL_SHA256_BIN="openssl dgst -sha256"
  fi
  
}
