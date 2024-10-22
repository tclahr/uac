#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Sanitize output directory path.
# Arguments:
#   string path: path
# Returns:
#   string: sanitized path
_sanitize_output_directory()
{
  __sd_path="${1:-}"

  # remove leading and trailing spaces
  # replace consecutive slashes by one slash
  # replace .. by .
  # replace invalid characters (Windows only) \ * ? : " < > by underscore
  # remove trailing slash
  # add slash if empty path
  echo "${__sd_path}" \
    | sed -e 's|^  *||' \
          -e 's|  *$||' \
          -e 's|\.\.|\.|g' \
          -e 's|\\|_|g' \
          -e 's|*|_|g' \
          -e 's|?|_|g' \
          -e 's|:|_|g' \
          -e 's|"|_|g' \
          -e 's|<|_|g' \
          -e 's|>|_|g' \
          -e 's|//*|/|g' \
          -e 's|/$||' \
          -e 's|^$|/|'

}
