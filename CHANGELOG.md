# Changelog

## DEVELOPMENT VERSION

### Features

- Added extraction of memory sections and strings from '/proc/[pid]/mem' using the data available in '/proc/[pid]/maps', even if processes are shown up as being (deleted). This functionality is enabled via 'tools/linux_procmemdump.sh' script.
- Artifacts file: Added a new option to define a custom output file name where the standard error messages (stderr stream) will be stored in. Please check the [project's documentation page](https://tclahr.github.io/uac-docs/collectors/#stderr_output_file) for more information.

### Artifacts

- files/applications/anydesk.yaml: Added the collection of AnyDesk configuration, chat transcript, screenshot, session recording and trace files [freebsd, linux, macos].
- files/applications/box_drive.yaml: Added the collection of Box Drive client configuration and sqlite database files [macos].
- files/applications/qnap_qsync.yaml: Added the collection of QNAP Qsync client configuration and log files [linux, macos].
- files/applications/spotlight_shortcuts.yaml: Added the collection of searches that a user performed in the Spotlight application [macos].
- files/applications/synology_drive.yaml: Added the collection of Synology Drive client configuration, database and log files [linux, macos].
- files/system/coreanalytics.yaml: Added the collection of information about the system usage and application execution history [macos].
- files/system/powerlog.yaml: Added the collection of Powerlog archive files [macos].
- live_response/network/lsof.yaml: Added the listing of UNIX domain socket files.
- live_response/packages/synopkg.yaml: Added the collection of installed packages on Synology DSM systems [linux].
- live_response/process/deleted.yaml: Added the collection of process memory sections and strings (for processes shown up as being deleted) from '/proc/[pid]/mem' [linux].
- live_response/system/lastlog.yaml: Added the collection of the last login log '/var/log/lastlog' file [linux].
- live_response/system/timedatectl.yaml: Added the collection of current settings of the system clock and RTC, including whether network time synchronization is active or not [linux].
- memory_dump/process_memory_sections_strings.yaml: Added the collection of process memory sections and strings from '/proc/[pid]/mem' [linux].
- memory_dump/process_memory_strings.yaml: Added the collection of process memory strings only from '/proc/[pid]/mem' [linux].

### Tools

- AVML updated to v0.10.0.