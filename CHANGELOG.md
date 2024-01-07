# Changelog

## DEVELOPMENT VERSION

### Artifacts

- files/applications/box_drive.yaml: Renamed to box.yaml.
- files/applications/box.yaml: Added collection support for Box log files [macos].
- files/applications/wget.yaml: Added collection support for wget hsts file. This file is used to store the HSTS cache for the wget utility [aix, esxi, freebsd, linux, macos, netbsd, openbsd, solaris] (by [firexfly](https://github.com/firexfly)).
- files/browsers/brave.yaml: Updated collection support for Flatpak version [linux].
- files/browsers/chrome.yaml: Updated collection support for Flatpak version [linux].
- files/browsers/edge.yaml: Updated collection support for Flatpak version [linux].
- files/browsers/opera.yaml: Updated collection support for Flatpak version [linux].
- files/browsers/vivaldi.yaml: Updated collection support for Flatpak version [linux].
- files/system/etc.yaml: Added "master.passwd" and "spwd.db" to the exclude_name_pattern list as they contain the hashed passwords of local users [freebsd, netbsd, netscaler, openbsd] (by [Herbert-Karl](https://github.com/Herbert-Karl)).
- files/system/etc.yaml: Added exclusion for the group shadow files 'gshadow' and 'gshadow-'. Those files contain password hashes for groups [linux] (by [Herbert-Karl](https://github.com/Herbert-Karl)).
- live_response/network/ss.yaml: Updated collection support for processes listening on UDP ports/sockets [android, linux].

### Profiles

- profiles/offline.yaml: New 'offline' profile that can be used during offline collections (by [randomaccess3](https://github.com/randomaccess3)).

### Tools

- statx source code was moved to a dedicated repository at https://github.com/tclahr/statx