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