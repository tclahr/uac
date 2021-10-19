# UAC (Unix-like Artifacts Collector)
UAC is a Live Response collection tool for Incident Response that makes use of built-in tools to automate the collection of Unix-like systems artifacts. It was created to facilitate and speed up data collection, and depend less on remote support during incident response engagements.

UAC reads YAML files on the fly and, based on their contents, collects relevant artifacts using 5 different collectors: command, find, hash, stat and file. This makes UAC very customizable and extensible.

## Main Features
- Fast and continuously tested
- Runs everywhere with no dependencies (no installation required)
- Customizable and extensible collections and artifacts
- Respects the order of volatility during artifacts collection
- Collects information from processes running without a binary on disk
- Extracts information from files and directories to create a bodyfile
- Hash running processes and executable files

## Supported Operating Systems
- Android
- AIX
- FreeBSD
- Linux
- macOS
- NetBSD
- NetScaler
- OpenBSD
- Solaris

## Usage
```
Usage: ./uac [OPTIONS] COLLECTION DESTINATION
   or: ./uac --validate-artifacts-file FILE

Positional Arguments:
  COLLECTION        Specify the collection name.
  DESTINATION       Specify the directory the output file will be created in.

Collection Arguments:
  -m, --mount-point MOUNT_POINT
                    Specify the mount point (default: /).
  -o, --operating-system OPERATING_SYSTEM
                    Specify the operating system.
                    Options: android, aix, freebsd, linux, macos, netbsd
                             netscaler, openbsd and solaris
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
```

## Examples

Run ```full```collection and create the output file in ```/tmp```:
```
./uac full /tmp
```

## License
The UAC project uses the [Apache License Version 2.0](LICENSE) software license.