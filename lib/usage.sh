#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

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
  
  printf %b "Usage: $0 {-p PROFILE | -a ARTIFACTS} DESTINATION [OPTIONS]
   or: $0 --validate-artifacts-file FILE

Optional Arguments:
  -h, --help        Display this help and exit.
  -V, --version     Output version information and exit.
      --debug       Enable debug mode.

Profiling Arguments:
  -p, --profile PROFILE
                    Specify the collection profile name. Use '--profile list'
                    to list available profiles.
  -a, --artifacts ARTIFACTS
                    Specify the artifacts to be collected during the collection.
                    The expression is a comma separated string where each element
                    is an artifact file. Each element can be prepended with an 
                    exclamation mark to exclude the artifact.
                    Special characters such as ! and * must be escaped with a
                    backslash.
                    Examples: --artifacts files/logs/\*,\!files/logs/var_log.yaml
                    Use '--artifacts list' to list available artifacts.

Positional Arguments:
  DESTINATION       Specify the directory the output file should be copied to.

Collection Arguments:
  -m, --mount-point MOUNT_POINT
                    Specify the mount point (default: /).
  -s, --operating-system OPERATING_SYSTEM
                    Specify the operating system.
                    Options: aix, android, esxi, freebsd, linux, macos, netbsd
                             netscaler, openbsd, solaris
  -u, --run-as-non-root
                    Disable root user check.
                    Note that data collection may be limited.
      --hostname HOSTNAME
                    Specify the target system hostname.
      --temp-dir PATH   
                    Write all temporary data to this directory.

Filter Arguments:
      --date-range-start YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    after the given date.
      --date-range-end YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    before the given date.

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

Remote Transfer Arguments:
      --sftp SERVER
                    Transfer output file to remote SFTP server.
                    SERVER must be specified in the form [user@]host:[path]
      --sftp-port PORT
                    Remote SFTP server port (default: 22).
      --sftp-identity-file FILE
                    File from which the identity (private key) for public key
                    authentication is read.
      --s3-presigned-url URL
                    Transfer output file to AWS S3 using a pre-signed URL.
      --s3-presigned-url-log-file URL
                    Transfer log file to AWS S3 using a pre-signed URL.
      --azure-storage-sas-url URL
                    Transfer output file to Azure Storage using a SAS URL.
      --azure-storage-sas-url-log-file URL
                    Transfer log file to Azure Storage using a SAS URL.
      --ibm-cos-url URL
                    Transfer output file to IBM Cloud Object Storage.
      --ibm-cos-url-log-file URL
                    Transfer log file to IBM Cloud Object Storage.
      --ibm-cloud-api-key KEY
                    IBM Cloud API key / Bearer token.
      --delete-local-on-successful-transfer
                    Delete local output and log files on successful transfer.

Validation Arguments:
      --validate-artifacts-file FILE
                    Validate artifacts file.

"

}