#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Sanitize output filename.
# Arguments:
#   string filename: filename
# Returns:
#   string: sanitized filename
_sanitize_output_file()
{
  __sf_filename="${1:-}"

  # remove leading and trailing spaces
  # remove leading slashes
  # remove trailing slashes
  # replace slash by underscore
  # replace invalid characters (Windows only) \ * ? : " < > by underscore
  # add underscore if empty filename
  echo "${__sf_filename}" \
    | sed -e 's|^  *||' \
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
          -e 's|^$|_|'
}
