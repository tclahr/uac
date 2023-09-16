# Changelog

## 2.7.0 (2023-09-16)

### Artifacts

- files/applications/findmy.yaml: Added the collection of the list of user's items/devices and items/devices info registered within the Find My application [macos].
- files/applications/rclone.yaml: Added the collection of rclone application configuration and log files [freebsd, linux, macos, netbsd, openbsd, solaris].
- files/applications/rustdesk.yaml: Added the collection of RustDesk application access logs and screen recording files [linux, macos].
- files/applications/splashtop.yaml: Added the collection of Splashtop application artifacts [linux, macos].
- files/applications/steam.yaml: Added the collection of Steam browser artifacts, avatar pictures, configuration and log files [linux, macos].
- files/applications/teamviewer.yaml: Added the collection of TeamViewer application artifacts [linux, macos].
- files/applications/thinlinc.yaml: Added the collection of ThinLinc application configuration files, connections and post-session logs [linux, macos].
- files/package/installed_applications: Added the collection of Info.plist from installed applications [macos].
- files/system/netscaler.yaml: Added the collection of '/var/vpn', '/var/netscaler/logon', and '/netscaler/ns_gui' system files and directories [netscaler].
- files/system/nsconfig.yaml: Deprecated. All artifacts were moved to 'files/system/netscaler.yaml' [netscaler].
- live_response/storage/mdadm.yaml: Added the collection of information on Linux software RAID [linux].
- live_response/storage/zpool.yaml: Added the collection of the command history of all pools [aix, freebsd, linux, macos, netbsd, netscaler, openbsd, solaris].

### Tools

- AVML updated to v0.12.0.