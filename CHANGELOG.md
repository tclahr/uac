# Changelog

## DEVELOPMENT VERSION

### Features

- Now it is possible to create password-protected zip output files using -z/--zip command line option. Default password: 'infected'.
- You can use --zip-password command line option to set a custom password.
- Now it is possible to set a custom output file name using -o/--output-filename command line option. You can also use variables to format the filename. Please refer to the [project's documentation page](https://tclahr.github.io/uac-docs/) for more information.

### Artifacts

- files/applications/box_drive.yaml was renamed to box.yaml.
- files/applications/box.yaml: Added the collection of Box log files [macos].
- files/applications/wget.yaml: Added the collection of wget hsts file. This file is used to store the HSTS cache for the wget utility [aix, esxi, freebsd, linux, macos, netbsd, openbsd, solaris].
- files/system/etc.yaml: Add exclusions for the group shadow files 'gshadow' and 'gshadow-'. Those files contain password hashes for groups [linux].
- files/system/etc.yaml: Added "master.passwd" and "spwd.db" to the exclude_name_pattern list as they contain the hashed passwords of local users [freebsd, netbsd, netscaler, openbsd].

### Profiles

- profiles/offline.yaml: New 'offline' profile that can be used during offline collections.

### Tools

- statically linked ```zip``` is now available for the following systems:
  - linux/esxi (arm, arm64, i386 and x86_64)
  - freebsd/netscaler (i386 and x86_64)
- ```statx``` source code was moved to a dedicated repository at https://github.com/tclahr/statx