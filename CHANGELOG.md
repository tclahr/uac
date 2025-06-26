# Changelog

All notable changes to this project will be documented in this file.  

## DEVELOPMENT VERSION

### Highlights

- Amazon S3 output file transfer now supports AWS Signature Version 4 (AWS4-HMAC-SHA256).
- You can create files with the operating system name in the `config` directory to **override** the default configuration for a specific operating system. Please check the [documentation](https://tclahr.github.io/uac-docs/config_file/) for more information.
- Most artifacts were updated to also collect symlinks ([#355](https://github.com/tclahr/uac/issues/355)).

### Added

- `files/browsers/cache.yaml`: Added collection of browser cache data. This artifact is resource-intensive and time-consuming, so it is disabled by default in all profiles [freebsd, linux, macos].
- `live_response/modifiers/disable_ftrace.yaml`: Added modifier to disable ftrace to prevent syscall hooking by LKM rootkits [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/process/procfs_information.yaml`: Added collection of /proc/modules [aix, freebsd, linux, netbsd, netscaler, solaris]. (by [SolitudePy](https://github.com/SolitudePy))
- `osquery/osquery.yaml`: Added new queries for apt_sources, deb_packages, shell_history, system_controls, logged_in_users and last_logins [linux]. (by [SolitudePy](https://github.com/SolitudePy))

### Changed

- `live_response/packages/slackpkg.yaml`: Moved to `packages/slackpkg.yaml`.
- `live_response/system/group_name_unknown_files.yaml`: Moved to `system/group_name_unknown_files.yaml`.
- `live_response/system/hidden_directories.yaml`: Moved to `system/hidden_directories.yaml`.
- `live_response/system/hidden_files.yaml`: Moved to `system/hidden_files.yaml`.
- `live_response/system/immutable_files.yaml`: Moved to `system/immutable_files.yaml`.
- `live_response/system/loginctl.yaml`: Added terse runtime status information collection for each user in the system [linux]. (by [clausing](https://github.com/clausing))
- `live_response/system/sgid.yaml`: Moved to `system/sgid.yaml`.
- `live_response/system/suid.yaml`: Moved to `system/suid.yaml`.
- `live_response/system/user_name_known_files.yaml`: Moved to `system/user_name_known_files.yaml`.
- `live_response/system/world_writable_directories.yaml`: Moved to `system/world_writable_directories.yaml`.
- `live_response/system/world_writable_files.yaml`: Moved to `system/world_writable_files.yaml`.
- `osquery/osquery.yaml`: Fixed query for authorized_keys [linux]. (by [SolitudePy](https://github.com/SolitudePy))

### Fixed

- Fixed a bug where the global `max_depth` set in uac.conf was not being respected in some cases. ([#359](https://github.com/tclahr/uac/issues/359))
- Fixed a bug where sftp ssh options were not being set correctly. ([#366](https://github.com/tclahr/uac/issues/366))
- Fixed a bug where the bodyfile artifact was returning corrupted file names when `statx` was being used with `xargs -0`. ([#369](https://github.com/tclahr/uac/issues/369)) (by [halpomeranz](https://github.com/halpomeranz))

### Profiles

### Command Line Option Changes

- `--sftp-ssh-options` is now `--sftp-ssh-option`: This allows setting SSH options as key=value pairs. Can be used multiple times to set multiple options. ([#366](https://github.com/tclahr/uac/issues/366))

### New Artifact Properties
