#!/bin/sh
# SPDX-License-Identifier: Apache-2.0

# Print the command line usage for the program.
# Arguments:
#   none
# Returns:
#   none
_usage()
{
  printf "%s" "Usage: $0 [-h] [-V] [--debug] {-p PROFILE | -a ARTIFACT} DESTINATION

  or: $0 --validate-artifact FILE
  or: $0 --validate-profile FILE

Optional Arguments:
  -h, --help        Display this help and exit.
  -v, --verbose     Increases the verbosity level.
      --debug       Enable debug mode.
      --trace       Enable trace messages.
  -V, --version     Output version information and exit.

Profiling Arguments:
  -p, --profile   PROFILE
                    Specify the collection profile name or path.
                    Use '--profile list' to list all available profiles.
  -a, --artifacts ARTIFACT
                    Specify the artifact(s) to be collected during the collection.
                    The expression is a comma separated string where each element
                    is an artifact. You can exclude individual artifacts by
                    prefixing them with an exclamation mark (!).
                    Special characters such as ! and * must be escaped with a
                    backslash.
                    Examples: --artifacts files/logs/\*,\!files/logs/var_log.yaml
                    Use '--artifacts list [OPERATING_SYSTEM]' to list available 
                    artifacts (default: all).

Positional Arguments:
  DESTINATION       Specify the directory the output file should be copied to.

Output Arguments:
  -o, --output-base-name BASENAME
                    Specify the base name of the output file (without extension).
                    Default: uac-%hostname%-%os%-%timestamp%
  -f, --output-format FORMAT
                    Specify the output format.
                    Compression will be enabled if gzip is available.
                    Options: none, tar, zip (default: tar)
  -P, --output-password PASSWORD
                    Specify the password to be used to encrypt the contents
                    of the archive file.
                    Applies to zip output format only.

Collection Arguments:
  -c, --config      FILE
                    Load config from a specific file.
  -m, --mount-point MOUNT_POINT
                    Specify the mount point (default: /).
  -s, --operating-system OPERATING_SYSTEM
                    Specify the operating system.
                    Options: aix, esxi, freebsd, linux, macos, netbsd
                      netscaler, openbsd, solaris
  -H, --hash-collected
                    Hash all collected files.
  -u, --run-as-non-root
                    Disable root user check.
                    Note that data collection may be limited.
      --enable-modifiers
                    Enable artifacts that change the system state.
      --hostname  HOSTNAME
                    Specify the target system hostname.
      --temp-dir  PATH
                    Write all temporary data to this directory.

Filter Arguments:
      --start-date YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    after the given date.
      --end-date  YYYY-MM-DD
                    Only collects files that were last modified/accessed/changed
                    before the given date.

Informational Arguments:
      --case-number CASE_NUMBER
                    Specify the case number.
      --description DESCRIPTION
                    Specify the description.
      --evidence-number EVIDENCE_NUMBER
                    Specify the evidence number.
      --examiner  EXAMINER
                    Specify the examiner name.
      --notes     NOTES
                    Specify the notes.

Remote Transfer Arguments:
      --sftp SERVER
                    Transfer the output file to remote SFTP server.
                    SERVER must be specified in the form [user@]host:[path]
      --sftp-port PORT
                    Remote SFTP server port (default: 22).
      --sftp-identity-file FILE
                    File from which the identity (private key) for public key
                    authentication is read.
      --sftp-ssh-option
                    Allow setting SSH options as key=value pairs.
                    Can be used multiple times to set multiple options.
      --s3-provider
                    Transfer the output and log files to S3 service.
                    Options: amazon, google, ibm
      --s3-region
                    S3 region name (default: us-east-1 [amazon], us-south [ibm]).
      --s3-bucket
                    S3 bucket/cloud object storage name.
      --s3-access-key
                    The access key for the bucket/cloud object storage.
      --s3-secret-key
                    The secret access key for the bucket/cloud object storage.
      --s3-token
                    The session/bearer token for the bucket/cloud object storage.
      --aws-s3-presigned-url URL
                    Transfer the output file to AWS S3 using a pre-signed URL.
                    Use single quotes to enclose the URL.
      --aws-s3-presigned-url-log-file URL
                    Transfer the log file to AWS S3 using a pre-signed URL.
                    Use single quotes to enclose the URL.
      --azure-storage-sas-url URL
                    Transfer the output file to Azure Storage using a SAS URL.
                    Use single quotes to enclose the URL.
      --azure-storage-sas-url-log-file URL
                    Transfer the log file to Azure Storage using a SAS URL.
                    Use single quotes to enclose the URL.
      --delete-local-on-successful-transfer
                    Delete local output and log files on successful transfer.

Validation Arguments:
      --validate-artifact FILE
                    Validate artifact.
      --validate-profile FILE
                    Validate profile.

"
}
