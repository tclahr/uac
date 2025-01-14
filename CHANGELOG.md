# Changelog

## DEVELOPMENT VERSION

### Artifacts

- files/applications/ark.yaml: Added collection of metadata about recently opened archive files in Ark, the KDE archive manager [freebsd, linux, netbsd, openbsd].
- files/applications/dolphin.yaml: Added collection of session data for the Dolphin file manager in the KDE desktop environment. This file contains information about the state of the Dolphin application, such as the currently open directories and their paths and the last accessed locations [freebsd, linux, netbsd, openbsd].
- files/applications/dragon_player.yaml: Added collection of paths to recently opened video files using the Dragon Player [freebsd, linux, netbsd, openbsd].
- files/applications/geany.yaml: Added collection of metadata about recently opened files in Geany text editor [freebsd, linux, netbsd, openbsd].
- files/applications/gedit.yaml: Added collection of metadata about recently opened files in Gedit text editor [freebsd, linux, netbsd, openbsd].
- files/applications/gnome_text_editor.yaml: Added collection of metadata about recently opened files in Gnome Text Editor [freebsd, linux, netbsd, openbsd].
- files/applications/katesession.yaml: Added colleection of metadata about recently opened files in Kwrite and Kate text editors [freebsd, linux, netbsd, openbsd].
- files/applications/okular.yaml: Added collection of metadata related to documents that have been opened or interacted with using Okular, a document viewer for KDE [freebsd, linux, netbsd, openbsd].
- files/system/gvfs_metadata.yaml: Added collection of data from the gvfs-metadata directory to retrieve user-specific metadata, such as file access details, custom properties, and interaction history [freebsd, linux, netbsd, openbsd].
- files/system/kactivitymanagerd.yaml: Added collection of activity tracking data used by KActivityManager (part of KDE) to track and manage user activities, such as recently opened files, applications, and other resources [freebsd, linux, netbsd, openbsd].
- files/system/upstart.yaml: Added collection of system-wide and user-session Upstart configuration files [linux].
- files/system/xdg_autostart.yaml: Added collection of system-wide and user-specific XDG autostart files [linux].
- live_response/packages/0install.yaml: Added collection of the list of installed packages managed by Zero Install package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/conary.yaml: Added collection of the list of installed packages managed by the Conary package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/dpkg.yaml: Updated to verify all packages to compare information about the installed files in the package with information about the files taken from the package metadata stored in the dpkg database [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/packages/package_owns_file.yaml: Added collection of which installed package owns a specific file or command. Note that this artifact is resource-intensive and time-consuming to execute, so it is disabled by default in all profiles [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/packages/paludis.yaml: Added collection of the list of installed packages managed by the Paludis package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/portage.yaml: Added the collection of installed package lists using the Portage package management system [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/snap.yaml: Updated collection to display installed packages including all revisions [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/storage/findmnt.yaml: Added JSON output format for listing all mounted file systems [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/storage/lsblk.yaml: Added JSON output format for listing block devices [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/system/coredump.yaml: Added collection of core dump files information [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/system/getcap.yaml: Added functionality to collect the list of files with associated process capabilities [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/system/journalctl.yaml: Added collection of listing of time periods between boots [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/system/ulimit.yaml: Added collection of all resource limits information [all] ([mnrkbys](https://github.com/mnrkbys)).
- memory_dump/coredump.yaml: Added collection of core dump, ABRT, Apport, and kdump files [esxi, linux, netbsd] ([mnrkbys](https://github.com/mnrkbys)).

### Profiles

- profiles/offline_ir_triage.yaml: New 'offline_ir_triage' profile that can be used during offline triage collections ([clausing](https://github.com/clausing)).

### New Artifacts Properties

- Added the new 'redirect_stderr_to_stdout' property, an optional feature available exclusively for the command collector. When set to true, this property redirects all error messages (stderr) to standard output (stdout), ensuring they are written to the output file.

### Fixes

- Resolves an issue where the hash and stat collectors failed to function correctly when the %user_home% variable was included in the path property ([#289](https://github.com/tclahr/uac/issues/289)).
