# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

- The output and log file names are now automatically appended to the URL provided in `--azure-storage-sas-url` ([#389](https://github.com/tclahr/uac/issues/389)). Consequently, the `--azure-storage-sas-url-log-file` option is no longer needed and has been removed.
- Introduced the `statf` tool, which leverages the `stat` system call to produce file status information in bodyfile format for FreeBSD-based systems lacking the `stat` and `perl` tools.

### Artifacts

- `files/applications/imessage.yaml`: Renamed to `files/applications/messages.yaml` to better reflect its contents.
- `files/applications/microsoft_teams.yaml`: Updated collection of Microsoft Teams artifacts [linux, macos].
- `files/browsers/brave.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/chrome.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/chromium.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/edge.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/opera.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/safari.yaml`: Added collection of affiliation database file [linux, macos].
- `files/browsers/vivaldi.yaml`: Added collection of affiliation database file [linux, macos].
- `files/logs/journal.yaml`: Updated collection of systemd journal artifacts to search files in `/var/log` only [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/logs/tomcat.yaml`: Updated collection of Apache Tomcat logs to also search in the $CATALINA_BASE and $CATALINA_HOME locations [all].
- `files/system/biome.yaml`: Updated collection of Biome artifacts [macos].
- `files/system/keychain.yaml`: Updated collection of macOS keychain artifacts [macos].
- `files/system/startup_items.yaml`: Updated collection of macOS startup items [macos].
- `live_response/network/esxcli.yaml`: Updated collection of network firewall artifacts [esxi].
- `live_response/network/ss.yaml`: Updated to show PACKET sockets, socket classic BPF filters, and show the process name and PID of the program to which socket belongs [linux]. (by [ekt0-syn](https://github.com/ekt0-syn))
- `live_response/system/binfmt_misc`: Added collection of binfmt_misc handlers [linux]. (by [mnrkbys](https://github.com/mnrkbys))

### Fixed

- Resolved a bug that prevented proper artifact collection when the mountpoint of a mounted disk image included spaces or special characters.

### Tools

- `statx` updated to fix a bug where it was not parsing the special permissions returned by syscall `statx`. (by [synacktiv](https://github.com/synacktiv))
