#!/bin/sh

# Copyright (C) 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the “License”);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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