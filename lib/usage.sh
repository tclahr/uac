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
# Print the command line usage for the program.
# Globals:
#   None
# Requires:
#   None
# Arguments:
#   None
# Outputs:
#   Write the command line usage for the program to stdout.
# Exit Status:
#   Exit with status 0 on success.
#   Exit with status greater than 0 if errors occur.
###############################################################################
usage()
{
  
  printf %b "Usage: $0 [OPTIONS] PROFILE DESTINATION
   or: $0 --validate-artifacts-file FILE

Positional Arguments:
  PROFILE           Specify the profile name.
  DESTINATION       Specify the directory the output file will be created in.

Collection Arguments:
  -m, --mount-point MOUNT_POINT
                    Specify the mount point (default: /).
  -o, --operating-system OPERATING_SYSTEM
                    Specify the operating system.
                    Options: android, aix, freebsd, linux, macos, netbsd
                             netscaler, openbsd, solaris
  -u, --run-as-non-root
                    Disable root user check.
                    Note that data collection may be limited.
      --temp-dir    Write all temporary data to this directory.

Filter Arguments:
      --date-range-start YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    after given date.
      --date-range-end YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    before given date.

Informational Arguments:
      --case-number CASE_NUMBER
                    Specify the case number.
      --description DESCRIPTION
                    Specify the description.
      --evidence-number EVIDENCE_NUMBER
                    Specify the evidence number.
      --examiner EXAMINER
                    Specify the examiner name.
      --notes NOTES
                    Specify the notes.
      --hostname HOSTNAME
                    Specify the target system hostname.

Remote Transfer Arguments:
      --sftp SERVER
                    Transfer output file to remote SFTP server.
                    SERVER must be specified in the form [user@]host:[path]
      --sftp-port PORT
                    Remote SFTP server port (default: 22).
      --sftp-identity-file FILE
                    File from which the identity (private key) for public key
                    authentication is read.
      --sftp-delete-local-on-success
                    Delete local output file on successful transfer.

Validation Arguments:
      --validate-artifacts-file FILE
                    Validate artifacts file.

Optional Arguments:
  -h, --help        Display this help and exit.
  -V, --version     Output version information and exit.
      --debug       Enable debug mode.

"

}