# Changelog

All notable changes to this project will be documented in this file.

## 3.2.0 (2025-08-12)

### Highlights

- Amazon S3 output file transfer now supports AWS Signature Version 4 (AWS4-HMAC-SHA256).
- Previously, UAC filtered out non-regular files (e.g., symbolic links, sockets, block special files, etc.) before archiving the collected data. Now, if `file_type` is not specified, UAC will collect both regular files and symbolic links by default.
- You can create files with the operating system name in the `config` directory to **override** the default configuration for a specific operating system. Please check the [documentation](https://tclahr.github.io/uac-docs/config_file/) for more information.
- The shell script [timeout.sh](https://github.com/tclahr/timeout.sh) was added to the `bin` directory. It mimics the traditional Linux `timeout` command and can be used to limit the execution time of a command on all operating systems.
- `--validate-artifact` was updated to verify if `f` is included in the `file_type` when `max_file_type` or `min_file_type` is specified.
- Added runtime variable support for `--aws-s3-presigned-url`, `--aws-s3-presigned-url-log-file`, `--azure-storage-sas-url` and `--azure-storage-sas-url-log-file` ([#392](https://github.com/tclahr/uac/issues/392)). Please check the [documentation](https://tclahr.github.io/uac-docs/runtime_variables/) for more information.

### Artifacts

- `files/applications/google_drive.yaml`: Added collection of Google Drive metadata databases and log files [macos].
- `files/applications/spotlight.yaml`: Updated the collection of Spotlight searches performed by users [macos].
- `files/browsers/cache.yaml`: Added collection of browser cache data. This artifact is resource-intensive and time-consuming, so it is disabled by default in all profiles [freebsd, linux, macos].
- `files/logs/advanced_log_search.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/apache.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/macos_unified_logs.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/macos.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/netscaler.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/nginx.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/run_log.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/solaris.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/tomcat.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/var_adm.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/var_log.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/logs/var_run_log.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/acct.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/apple_accounts.yaml`: Moved to `files/system/user_accounts.yaml`.
- `files/system/dev_shm.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/etc.yaml`: `file_type: [f]` removed. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/gvfs_metadata.yaml`: `file_type: [f]` removed. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/netscaler.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/run_shm.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/systemd.yaml`: `file_type: [f]` removed. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/tmp.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/udev.yaml`: `file_type: [f]` removed. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/user_accounts.yaml`: Added collection about the users that have logged in to the macOS computer, as recovered from the settings (.plist) files [macos].
- `files/system/var_tmp.yaml`: `file_type: [f, l]` was added to also collect symlinks as `max_file_type` was specified. ([#355](https://github.com/tclahr/uac/issues/355))
- `files/system/vyatta.yaml`: Added collection of Vyatta and VyOS configuration files [linux].
- `live_response/hardware/lshw.yaml`: Added timeout to the `lshw` command. ([#380](https://github.com/tclahr/uac/issues/380)) (by [qinidema](https://github.com/qinidema))
- `live_response/modifiers/disable_ftrace.yaml`: Added modifier to disable ftrace to prevent syscall hooking by LKM rootkits [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/packages/slackpkg.yaml`: Moved to `packages/slackpkg.yaml`.
- `live_response/process/procfs_information.yaml`: Added collection of /proc/modules [aix, freebsd, linux, netbsd, netscaler, solaris]. (by [SolitudePy](https://github.com/SolitudePy))
- `live_response/system/getcap.yaml`: Moved to `system/getcap.yaml`. Updated to skip non-local file systems [linux]. ([#375](https://github.com/tclahr/uac/issues/375))
- `live_response/system/group_name_unknown_files.yaml`: Moved to `system/group_name_unknown_files.yaml`.
- `live_response/system/hidden_directories.yaml`: Moved to `system/hidden_directories.yaml`.
- `live_response/system/hidden_files.yaml`: Moved to `system/hidden_files.yaml`.
- `live_response/system/immutable_files.yaml`: Moved to `system/immutable_files.yaml`. Updated to skip non-local file systems [linux].
- `live_response/system/loginctl.yaml`: Added terse runtime status information collection for each user in the system [linux]. (by [clausing](https://github.com/clausing))
- `live_response/system/mdatp.yaml`: Update supported OS for mdatp artifacts to include macOS [macos]. (by [JakePeralta7](https://github.com/JakePeralta7))
- `live_response/system/sgid.yaml`: Moved to `system/sgid.yaml`.
- `live_response/system/show.yaml`: Added collection of consolidated tech-support report from Vyatta and VyOS systems [linux].
- `live_response/system/suid.yaml`: Moved to `system/suid.yaml`.
- `live_response/system/user_name_known_files.yaml`: Moved to `system/user_name_known_files.yaml`.
- `live_response/system/utmpdump.yaml`: Added collection of utmp and wtmp (including log rotated) files using `utmpdump` command [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/world_writable_directories.yaml`: Moved to `system/world_writable_directories.yaml`.
- `live_response/system/world_writable_files.yaml`: Moved to `system/world_writable_files.yaml`.
- `osquery/osquery.yaml`: Added new queries for apt_sources, deb_packages, shell_history, system_controls, logged_in_users and last_logins [linux]. (by [SolitudePy](https://github.com/SolitudePy))
- `osquery/osquery.yaml`: Fixed query for authorized_keys [linux]. (by [SolitudePy](https://github.com/SolitudePy))
- `system/hidden_files.yaml`: Added collection of symlinks.

### Fixed

- Fixed a bug where the global `max_depth` set in uac.conf was not being respected in some cases. ([#359](https://github.com/tclahr/uac/issues/359))
- Fixed a bug where sftp ssh options were not being set correctly. ([#366](https://github.com/tclahr/uac/issues/366))
- Fixed a bug where the bodyfile artifact was returning corrupted file names when `statx` was being used with `xargs -0`. ([#369](https://github.com/tclahr/uac/issues/369)) (by [halpomeranz](https://github.com/halpomeranz))

### Command Line Option Changes

- `--sftp-ssh-options` is now `--sftp-ssh-option`: This allows setting SSH options as key=value pairs. Can be used multiple times to set multiple options. ([#366](https://github.com/tclahr/uac/issues/366))

### Tools

- All scripts/binaries from the `tools` directory were moved to `bin`.
- `astrings` helper function was improved and is now available as [strings.sh](https://github.com/tclahr/strings.sh) in the `bin` directory.
