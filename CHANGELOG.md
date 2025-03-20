# Changelog

All notable changes to this project will be documented in this file.  

## 3.1.0 (2025-03-20)

### Highlights

- Added collection of hidden `/etc/ld.so.preload` using `debugfs` and `xfs_db` tools, enhancing visibility into stealthy Linux rootkits.
- Added artifact to list immutable files on Linux systems.
- Numerous artifacts added to collect information about recently accessed files on popular BSD and Linux systems.
- Introduced a new `offline_ir_triage` profile for offline triage collections.

### Added

- `chkrootkit/hidden_etc_ld_so_preload.yaml`: Added collection of hidden `/etc/ld.so.preload` using `debugfs` and `xfs_db` tools [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `files/applications/ark.yaml`: Added collection of metadata about recently opened archive files in Ark, the KDE archive manager [freebsd, linux, netbsd, openbsd].
- `files/applications/atftp.yaml`: Added collection of atftp history files [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `files/applications/dolphin.yaml`: Added collection of session data for the Dolphin file manager in the KDE desktop environment. This includes open directories and their paths [freebsd, linux, netbsd, openbsd].
- `files/applications/dragon_player.yaml`: Added collection of paths to recently opened video files using Dragon Player [freebsd, linux, netbsd, openbsd].
- `files/applications/geany.yaml`: Added collection of metadata about recently opened files in the Geany text editor [freebsd, linux, netbsd, openbsd].
- `files/applications/gedit.yaml`: Added collection of metadata about recently opened files in the Gedit text editor [freebsd, linux, netbsd, openbsd].
- `files/applications/gnome_text_editor.yaml`: Added collection of metadata about recently opened files in the Gnome Text Editor [freebsd, linux, netbsd, openbsd].
- `files/applications/katesession.yaml`: Added collection of metadata about recently opened files in Kwrite and Kate text editors [freebsd, linux, netbsd, openbsd].
- `files/applications/kde_mru.yaml`: Added collection of metadata about recently opened files in KDE [freebsd, linux, netbsd, openbsd].
- `files/applications/nano.yaml`: Added collection of nano history files [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `files/applications/okular.yaml`: Added collection of metadata related to documents opened using Okular, a KDE document viewer [freebsd, linux, netbsd, openbsd].
- `files/applications/php.yaml`: Added collection of PHP history files [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `files/browsers/konqueror.yaml`: Added collection of Konqueror browser history, bookmark, cookies, cache, sessions, extensions and configuration files [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `files/system/aws_ssm_agent.yaml`: Added collection of AWS Systems Manager Agent (SSM Agent) configuration files and logs [linux].
- `files/system/azure_vm_agent.yaml`: Added collection of Azure Linux VM Agent logs and executed scripts [linux].
- `files/system/gvfs_metadata.yaml`: Added collection of user-specific metadata from the `gvfs-metadata` directory [freebsd, linux, netbsd, openbsd].
- `files/system/kactivitymanagerd.yaml`: Added collection of activity tracking data from KActivityManager [freebsd, linux, netbsd, openbsd].
- `files/system/upstart.yaml`: Added collection of system-wide and user-session Upstart configuration files [linux].
- `files/system/xdg_autostart.yaml`: Added collection of system-wide and user-specific XDG autostart files [linux].
- `live_response/network/nmcli.yaml`: Added displaying information from network connections managed by NetworkManager [linux].
- `live_response/packages/0install.yaml`: Added collection of installed packages managed by Zero Install [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/apk.yaml`: Added collection of installed packages managed by apk package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/cargo.yaml`: Added collection of installed packages managed by cargo [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/cargo.yaml`: Added collection of installed packages managed by guix [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/conary.yaml`: Added collection of installed packages managed by Conary [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/kiss.yaml`: Added collection of the installed packages managed by the KISS package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/npm.yaml`: Added collection of the installed packages managed by the npm package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/package_owns_file.yaml`: Added functionality to determine which installed package owns a specific file or command. This artifact is resource-intensive and time-consuming, so it is disabled by default in all profiles [linux]. ([mnrkbys](https://github.com/mnrkbys))
- `live_response/packages/paludis.yaml`: Added collection of the installed packages managed by the Paludis package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/pkgin.yaml`: Added functionality to list information for fully installed packages only [netbsd]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/portage.yaml`: Added collection of installed package lists using the Portage package management system [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/slackpkg.yaml`: Added collection of installed and upgradable packages managed by the Slackpkg package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/soar.yaml`: Added collection of installed packages managed by Soar package manager [all]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/tazpkg.yaml`: Added collection of the installed packages managed by the Tazpkg package manager [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/storage/findmnt.yaml`: Added JSON output support for listing all mounted file systems [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/storage/lsblk.yaml`: Added JSON output support for listing block devices [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/coredump.yaml`: Added collection of information about core dump files [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/getcap.yaml`: Added functionality to collect a list of files with associated process capabilities [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/group_name_unknown_files.yaml`: List files with an unknown group ID name [aix, freebsd, linux, macos, netbsd, netscaler, openbsd, solaris].
- `live_response/system/immutable_files.yaml`: Added functionality to list immutable files on the system [linux].
- `live_response/system/journalctl.yaml`: Added collection of boot time period listings using `journalctl` [linux]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/sudo_lectured.yaml`: Added collection of the timestamps of users who saw the sudo lecture message [all]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/ulimit.yaml`: Added collection of all resource limits information [all]. (by [mnrkbys](https://github.com/mnrkbys))
- `live_response/system/user_name_unknown_files.yaml`: List files with an unknown user ID name [aix, freebsd, linux, macos, netbsd, netscaler, openbsd, solaris].
- `memory_dump/coredump.yaml`: Added collection of core dump, ABRT, Apport, and kdump files [esxi, linux, netbsd]. (by [mnrkbys](https://github.com/mnrkbys))
- `osquery/osquery.yaml`: Added collection of multiple artifacts using OSQuery tool. Please note that the `osqueryi` binary is not included in the UAC package and must be manually placed in the `bin` directory [linux]. (by [SolitudePy](https://github.com/SolitudePy))

### Changed

- `files/logs/macos_unified_logs.yaml`: Updated to include collection of ASL logs [macos]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `files/system/job_scheduler.yaml`: Updated to include anacron job scheduler [aix, esxi, freebsd, linux, netbsd, netscaler, openbsd, solaris]. (by [0xThiebaut](https://github.com/0xThiebaut))
- `live_response/packages/dpkg.yaml`: Updated to validate all installed packages by comparing the installed files against the package metadata stored in the dpkg database [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/snap.yaml`: Updated collection to display installed packages including all revisions [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/packages/swupd.yaml`: Updated to list all available bundles for the current version of Clear Linux [linux]. (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal))
- `live_response/process/ps.yaml`: Updated to collect the system date before reporting a snapshot of the current processes including elapsed time since the process was started [all].
- `live_response/system/falconctl.yaml`: Updated as `falconctl -g` is no longer a valid option [linux, macos].
- `memory_dump/avml.yaml`: Updated output file name from avml.raw to avml.lime [linux].

### Fixed

- Resolved an issue where the `hash` and `stat` collectors failed to function correctly when the `%user_home%` variable was included in the path property. ([#289](https://github.com/tclahr/uac/issues/289))
- Resolved an issue where directories were also being collected when `max_file_size` or `min_file_size` was set. ([#338](https://github.com/tclahr/uac/issues/338))
- Resolved an issue where UAC was failing to create output file names longer than 255 characters. ([#341](https://github.com/tclahr/uac/issues/341))

### Profiles

- Added `offline_ir_triage.yaml`: New 'offline_ir_triage' profile for offline triage collections. (by [clausing](https://github.com/clausing))

### New Artifact Properties

- Introduced `no_group`: Use this option to search for files that have a group ID (GID) that no longer exists in the system.
- Incroduced `no_user`: Use this option to search for files that have a user ID (UID) that no longer exists in the system.
- Introduced `redirect_stderr_to_stdout`: When enabled, this property redirects error messages (stderr) to standard output (stdout). Useful for debugging and ensuring complete logs.
