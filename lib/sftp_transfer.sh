#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

###############################################################################
# Transfer file to SFTP server.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   $1: source file or directory
#   $2: remote destination
#   $3: remote port (default: 22)
#   $4: identity file
# Outputs:
#   None.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
sftp_transfer()
{
  sr_source="${1:-}"
  sr_destination="${2:-}"
  sr_port="${3:-22}"
  sr_identity_file="${4:-}"

  if [ -n "${sr_identity_file}" ]; then
    sftp -r \
      -P "${sr_port}" \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i "${sr_identity_file}" \
      "${sr_destination}" >/dev/null << EOF
mput "${sr_source}"
EOF
  else
    sftp -r \
      -P "${sr_port}" \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      "${sr_destination}" >/dev/null << EOF
mput "${sr_source}"
EOF
  fi 

}