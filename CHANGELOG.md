# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

- Introduced support for [user-defined variables](https://tclahr.github.io/uac-docs/user_defined_variables) passed via the command line `--define` / `-D`, which can be expanded in UAC artifacts using `%var%` or `%var=default_value%` syntax, enabling greater flexibility and customization ([#408](https://github.com/tclahr/uac/issues/408)).
- The output and log file names are now automatically appended to the URL provided in `--azure-storage-sas-url` ([#389](https://github.com/tclahr/uac/issues/389)). Consequently, the `--azure-storage-sas-url-log-file` option is no longer needed and has been removed.
- Introduced the `statf` tool, which leverages the `stat` system call to produce file status information in bodyfile format for FreeBSD-based systems lacking the `stat` and `perl` tools.
- You can now use the `find` collector to run a specified `command` once for each matched file ([#420](https://github.com/tclahr/uac/issues/420)). Please check the [documentation](https://tclahr.github.io/uac-docs/artifacts/#field-reference-and-examples) for more information. (by [halpomeranz](https://github.com/halpomeranz))

### Artifacts

- `files/applications/imessage.yaml`: Renamed to `files/applications/messages.yaml` to better reflect its contents.
- `files/applications/jenkins.yaml`: Added collection of Jenkins config.xml and build.xml files [linux, macos]. (by [halpomeranz](https://github.com/halpomeranz))
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
- `files/ssh/public_keys.yaml`: Added collection of SSH public keys [all]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/system/biome.yaml`: Updated collection of Biome artifacts [macos].
- `files/system/boot.yaml`: Added collection of boot config, initramfs/initrd, sysvers, System.map, and GRUB config files, possible persistence mechanisms [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/system/dbus.yaml`: Added collection of D-Bus config files, a possible persistence mechanism [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/system/dracut.yaml`: Added collection of dracut config files, a possible persistence mechanism [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/system/keychain.yaml`: Updated collection of macOS keychain artifacts [macos].
- `files/system/polkit.yaml`: Added collection of polkit config files, a possible persistence mechanism [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `files/system/startup_items.yaml`: Updated collection of macOS startup items [macos].
- `live_response/network/esxcli.yaml`: Updated collection of network firewall artifacts [esxi].
- `live_response/network/ss.yaml`: Updated to show PACKET sockets, socket classic BPF filters, and show the process name and PID of the program to which socket belongs [linux]. (by [ekt0-syn](https://github.com/ekt0-syn))
- `live_response/system/binfmt_misc`: Added collection of binfmt_misc handlers [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `memory_dump/avml.yaml`: Updated to collect dumps when memory size is 256GB or less. This behavior can be changed using the `avml_max_memory` variable [linux].
- `memory_dump/avml.yaml`: Updated to collect vmlinu\* and System.map* files to help build Volatility profiles [linux]. (by [halpomeranz](https://github.com/halpomeranz))
- `ssh/private_keys_with_null_passphrases.yaml`: Added collection of SSH public keys when the associated private key has a null (empty) passphrase [all]. (by [halpomeranz](https://github.com/halpomeranz))
- `system/group_name_unknown_directories.yaml`: List directories with an unknown group ID name [aix, freebsd, linux, macos, netbsd, netscaler, openbsd, solaris]. ([#418](https://github.com/tclahr/uac/issues/418))
- `system/group_writable_directories.yaml`: List group writable directories using permission bits mode -0040 [all]. ([#417](https://github.com/tclahr/uac/issues/417))
- `system/group_writable_files.yaml`: List group writable files using permission bits mode -0040 [all]. ([#417](https://github.com/tclahr/uac/issues/417))
- `system/user_name_unknown_directories.yaml`: List directories with an unknown user ID name [aix, freebsd, linux, macos, netbsd, netscaler, openbsd, solaris]. ([#418](https://github.com/tclahr/uac/issues/418))
- `system/world_writable_directories.yaml`: Updated collection to use permission bits mode -0004 [all]. ([#417](https://github.com/tclahr/uac/issues/417))
- `system/world_writable_files.yaml`: Updated collection to use permission bits mode -0004 [all]. ([#417](https://github.com/tclahr/uac/issues/417))

### Fixed

- Resolved a bug that prevented proper artifact collection when the mountpoint of a mounted disk image included spaces or special characters.

### Tools

- `statx` updated to fix a bug where it was not parsing the special permissions returned by syscall `statx`. (by [synacktiv](https://github.com/synacktiv))
