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
#   boolean resume: resume the transfer if a partial file already exists on
#                   the server (requires OpenSSH 6.5 or later) (optional)
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
  __sr_resume="${6:-false}"

  # batch mode (-b -) makes sftp exit with non-zero status if any command
  # fails, otherwise the exit status is always 0 when commands are read from
  # stdin. -b also adds '-o BatchMode=yes' to ssh, which disables password
  # authentication, so '-o BatchMode=no' is passed before it (ssh uses the
  # first value given to an option)
  __sr_command="sftp -o BatchMode=no -b - -r -P ${__sr_port}"
  if [ -n "${__sr_identity_file}" ]; then
    __sr_command="${__sr_command} -i \"${__sr_identity_file}\""
  fi
  __sr_command="${__sr_command} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  
  if [ -n "${__sr_ssh_options}" ]; then
    __sr_command="${__sr_command}${__sr_ssh_options}"
  fi
  
  if [ -n "${__sr_source}" ]; then
    __sr_put="mput"
    # reput fails if the file does not exist on the server
    if ${__sr_resume} && eval "${__sr_command} \"${__sr_destination}\" >/dev/null 2>/dev/null << EOF
ls \"${__sr_source}\"
EOF"; then
      _verbose_msg "Resuming transfer of '${__sr_source}'..."
      __sr_put="reput"
    fi
    __sr_command="${__sr_command} \"${__sr_destination}\" >/dev/null << EOF
${__sr_put} \"${__sr_source}\"
EOF"
  else
    __sr_command="${__sr_command} \"${__sr_destination}\" >/dev/null << EOF
pwd
EOF"
  fi

  _verbose_msg "${__UAC_VERBOSE_CMD_PREFIX}${__sr_command}"
	eval "${__sr_command}" >/dev/null

}