#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2006

# Sanitize and truncate output filename do not exceed 118 or 245 characters by 
# truncating the file name from the beginning and prefixing it with (trunc).
# Arguments:
#   string filename: filename
# Returns:
#   string: sanitized filename
_sanitize_output_file()
{
  __sf_filename="${1:-}"
  __sf_truncated_string="(trunc)"
  __sf_truncated_string_length=7

  __sanitize_filename()
  {
    # remove leading and trailing spaces
    # remove leading slashes
    # remove trailing slashes
    # replace slash by underscore
    # replace invalid characters (Windows only) \ * ? : " < > by underscore
    # remove double underscores
    # add underscore if empty filename
    sed -e 's|^  *||' \
        -e 's|  *$||' \
        -e 's|^//*||' \
        -e 's|//*$||' \
        -e 's|//*|_|g' \
        -e 's|\\|_|g' \
        -e 's|*|_|g' \
        -e 's|?|_|g' \
        -e 's|:|_|g' \
        -e 's|"|_|g' \
        -e 's|<|_|g' \
        -e 's|>|_|g' \
        -e 's|__*|_|g' \
        -e 's|^$|_|'
  }

  __sf_filename=`echo "${__sf_filename}" | __sanitize_filename`

  # Get the full length of the path including the file name
  __sf_filename_length=`printf "%s" "${__sf_filename}" | awk '{print length($0)}'`

  # Check if truncation is needed
  if [ "${__sf_filename_length}" -gt "${__UAC_MAX_FILENAME_SIZE:-118}" ]; then
    # shellcheck disable=SC2003
    __sf_truncate_length=`expr "${__UAC_MAX_FILENAME_SIZE:-118}" - "${__sf_truncated_string_length}"`
    printf "%s" "${__sf_filename}" | awk -v truncate_length="${__sf_truncate_length}" -v truncate_string="${__sf_truncated_string}" '{print truncate_string""substr($0, length($0)-truncate_length+1)}'
  else
    echo "${__sf_filename}"
  fi

}
