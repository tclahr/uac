#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Test the connectivity to SFTP server.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: remote destination
#   $2: remote port (default: 22)
#   $3: identity file
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sftp_transfer_test()
{
  sf_destination="${1:-}"
  sf_port="${2:-22}"
  sf_identity_file="${3:-}"

  if [ -n "${sf_identity_file}" ]; then
    sftp -P "${sf_port}" \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i "${sf_identity_file}" \
      "${sf_destination}" >/dev/null << EOF
pwd
EOF
  else
    sftp -P "${sf_port}" \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      "${sf_destination}" >/dev/null << EOF
pwd
EOF
  fi 

}