#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck disable=SC2317

# Transfer file to SFTP server.
# Arguments:
#   string source: source file name
#                  leave it blank for connection test only
#   string destination: destination in the form [user@]host:[path]
#   integer port: port number
#   string identity_file: identity file path
#   string ssh_options: ssh options
# Returns:
#   boolean: true on success
#            false on fail
_sftp_transfer()
{
  __sr_source="${1:-}"
  __sr_destination="${2:-}"
  __sr_port="${3:-22}"
  __sr_identity_file="${4:-}"
  __sr_ssh_options="${5:-}"

  __sr_command="sftp -r -P ${__sr_port}"
  if [ -n "${__sr_identity_file}" ]; then
    __sr_command="${__sr_command} -i \"${__sr_identity_file}\""
  fi
  __sr_command="${__sr_command} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  
  if [ -n "${__sr_ssh_options}" ]; then
    __sr_command="${__sr_command}${__sr_ssh_options}"
  fi
  
  if [ -n "${__sr_source}" ]; then
    __sr_command="${__sr_command} \"${__sr_destination}\" >/dev/null << EOF
mput \"${__sr_source}\"
EOF"
  else
    __sr_command="${__sr_command} \"${__sr_destination}\" >/dev/null << EOF
pwd
EOF"
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__sr_command}"
	eval "${__sr_command}" >/dev/null

}