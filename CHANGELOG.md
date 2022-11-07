# Changelog

All notable changes to this project will be documented in this file.

## 2.4.0-rc1 (2022-11-07)

### New Features

- Added '--ibm-cos-url' switch which allows for pushing the output file to IBM Cloud Object Storage (if curl is available) ([#106](https://github.com/tclahr/uac/issues/106)).
- Added '--ibm-cos-url-log-file' switch which allows for pushing the output log file to IBM Cloud Object Storage (if curl is available) ([#106](https://github.com/tclahr/uac/issues/106)).
- Added '--ibm-cloud-api-key' switch which is required for transferring files to IBM Cloud Object Storage ([#106](https://github.com/tclahr/uac/issues/106)).
- Added '--azure-storage-sas-url' switch which allows for pushing the output file to Azure Storage using shared access signature (SAS) URLs (if curl is available) ([#62](https://github.com/tclahr/uac/issues/62)).
- Added '--azure-storage-sas-url-log-file' switch which allows for pushing the output log file to Azure Storage using shared access signature (SAS) URLs (if curl is available) ([#62](https://github.com/tclahr/uac/issues/62)).
- AVML was updated to v0.9.0.

### New Artifacts

- New artifact that collects macOS Biome data files (if SIP is disabled) (files/system/biome.yaml).
- New artifact that collects macOS saved application state files (files/system/saved_application_state.yaml).
- New artifact that collects macOS Unified Logs UUID and Timesync files (files/logs/macos_unified_logs.yaml).
- New artifact that collects macOS System Integrity Protection (SIP) status (live_response/system/csrutil.yaml).
- New artifact that collects macOS login items installed using the Service Management framework (files/system/startup_items.yaml).
- New artifact that collects macOS installed updates history information (live_response/packages/softwareupdate.yaml).
- New artifact that collects SSH rc files (files/ssh/rc.yaml).
- New artifact that collects Google Earth KML files (files/applications/google_earth.yaml).
- New artifact that collects the status of firewall and ufw managed rules (live_response/network/ufw.yaml).
- New artifact that collects kernel audit status and rules on Linux systems (live_response/system/auditctl.yaml).
- New artifact that collects installed packages on Gentoo Linux systems (live_response/packages/qlist.yaml).
- New artifact that collects the values of parameters in the EEPROM on Solaris systems (live_response/system/eeprom.yaml).
- New artifact that collects information about installed zones on Solaris systems (live_response/system/zoneadm.yaml).

### Updated Artifacts

- 'files/system/var_db_diagnostics.yaml' was moved and renamed to 'files/logs/macos_unified_logs.yaml'.

## 2.3.0 (2022-08-09)

## New Features

- You can now use as many --artifacts (-a) and --profile (-p) as you want to build an even more customized collection. Artifacts will be collected in the order they were provided in the command line. Please check the [project's documentation page](https://tclahr.github.io/uac-docs/#using-uac) for more information.
- UAC now collects copies of '/proc/[pid]/fd/*' from deleted processes even if they are not shown up as being (deleted).
- AVML was updated to v0.7.0.

### New Artifacts

- New artifact that collects the contents of /dev/shm (files/system/dev_shm.yaml) ([#68](https://github.com/tclahr/uac/issues/68)).
- New artifact that collects the contents of /run/shm (files/system/run_shm.yaml) ([#68](https://github.com/tclahr/uac/issues/68)).
- New artifact that collects the contents of /var/tmp (files/system/var_tmp.yaml) ([#68](https://github.com/tclahr/uac/issues/68)).
- New artifact that lists hidden files created outside of user home directories (live_response/system/hidden_files.yaml) ([#69](https://github.com/tclahr/uac/issues/69)).
- New artifact that lists hidden directories created outside of user home directories (live_response/system/hidden_directories.yaml) ([#69](https://github.com/tclahr/uac/issues/69)).
- New artifact that lists world writable files (live_response/system/world_writable_files.yaml).
- New artifact that lists world writable directories (live_response/system/world_writable_directories.yaml).
- New artifact that lists loaded kernel modules from /sys/module directory (live_response/system/sys_module.yaml).
- New artifact that collects last logins and logouts (live_response/system/last.yaml).
- New artifact that collects unsuccessful logins (live_response/system/lastb.yaml).
- New artifact that lists all socket files (live_response/system/socket_files.yaml).
- New artifact that collects sessions files from /run/systemd/sessions (files/system/systemd.yaml).
- New artifact that collects scope files from /run/systemd/transient (files/system/systemd.yaml).
- New artifact that collects Vivaldi browser artifacts (files/browsers/vivaldi.yaml).
- New artifact that collects Linux terse runtime status information about one or more logged in users, followed by the most recent log data from the journal (live_response/system/loginctl.yaml).
- New artifact that collects fish shell history files (files/shell/history.yaml).
- New artifact that collects Tracker database files (files/system/tracker.yaml).
- New artifact that collects macOS .DS_Store files (files/system/ds_store.yaml).
- New artifact that collects macOS network and application usage database files (files/system/network_application_usage.yaml).
- New artifact that collects macOS Powerlog files (files/system/powerlog.yaml).
- New artifact that collects macOS recovery account information files (files/system/recovery_account_info.yaml).
- New artifact that collects macOS system keychain file (files/system/keychain.yaml).
- New artifact that collects macOS system version file (files/system/system_version.yaml).
- New artifact that collects macOS unified logging and activity tracing files (files/system/var_db_diagnostics.yaml).
- New artifact that collects macOS time machine information (live_response/system/tmutil.yaml).
- New artitact that collects macOS Photos application database files (files/applications/photos.yaml).
- New artifact that collects AIX failed login attemtps from /etc/security/failedlogin (live_response/system/who.yaml).

### Updated Artifacts

- /dev was removed from the exclusion list during deleted process collection ([#65](https://github.com/tclahr/uac/issues/65)).
- files/system/time_machine.yaml, files/system/wifi.yaml, files/applications/macos_dock.yaml are no longer available because the same artifacts are been collected by files/system/library_preferences.yaml.

### Deprecated Command Line Option

- '-o' command line switch is no longer available because it was replaced by '-s'.

### Deprecated Profiles

- 'full-with-memory-dump' profile is no longer available because '-a memory_dump/avml.yaml -p full' can be used instead.
- 'memory-dump-only' profile is no longer available because '-a memory_dump/avml.yaml' can be used instead.

### Fixed

- UAC now copies all collected artifacts to a destination directory if 'tar' tool is not available ([#63](https://github.com/tclahr/uac/issues/63)).

## 2.2.0 (2022-05-02)

### New Features

- VMware ESXi is now fully supported as an operating system. Note that ESXi is not built upon the Linux kernel, and uses its own VMware proprietary kernel (the VMkernel) and software. So it misses most of the applications and components that are commonly found in all Linux distributions ([#33](https://github.com/tclahr/uac/issues/33)).
- UAC now collects copies of '/proc/[pid]/exe' and their related '/proc/[pid]/fd/*' if they are shown up as being (deleted). They are copied using 'dd conv=swab' tool in order to avoid UAC output file being flagged and quarantined by any antivirus tool ([#36](https://github.com/tclahr/uac/issues/36)).
- Added '--s3-presigned-url' switch which allows for pushing the output file to S3 pre-signed URLs (if curl available) ([#38](https://github.com/tclahr/uac/issues/38)).
- Added '--s3-presigned-url-log-file' switch which allows for pushing the output log file to S3 pre-signed URLs (if curl available) ([#38](https://github.com/tclahr/uac/issues/38)).
- Added '--delete-local-on-successful-transfer' switch which will delete both local output and log files after they are successfully transferred either via sftp or to a pre-signed S3 URL.
- AVML was updated to v0.6.1 ([#45](https://github.com/tclahr/uac/issues/45)).

### New Artifacts

- New artifact to collect ESXi running processes information (live_response/process/esxcli.yaml).
- New artifact to collect ESXi network connections information (live_response/network/esxcli.yaml and live_response/network/vim-cmd.yaml).
- New artifact to collect ESXi hardware information (live_response/hardware/esxcli.yaml).
- New artifact to collect ESXi system information (live_response/system/esxcli.yaml).
- New artifact to collect ESXi packages information (live_response/packages/esxcli.yaml).
- New artifact to collect ESXi storage information (live_response/storage/esxcli.yaml and live_response/storage/ls_vmfs_devices.yaml).
- New artifact to collect ESXi running virtual machines information (live_response/vms/esxcli.yaml, live_response/vms/vm-support.yaml and live_response/vms/vim-cmd.yaml).
- New artifact to collect ESXi log files located in /var/run/log directory (files/logs/var_run_log.yaml).
- New artifact to collect the binary of (malicious) processes after they have been deleted (live_response/process/deleted.yaml).
- New artifact to collect files of (malicious) processes after they have been deleted (live_response/process/deleted.yaml).
- New artifact to collect Linux NetworkManager files (files/system/networkmanager.yaml).
- New artifacts added to 'live_response/process/procfs_information.yaml' ([#35](https://github.com/tclahr/uac/issues/35)):
  - ls -l /proc/[pid]/cwd
  - cat /proc/[pid]/stack
  - cat /proc/[pid]/status
- New artifact was added to 'live_response/containers/docker.yaml':
  - docker stats --all --no-stream --no-trunc
  - docker network ls
  - docker network inspect [network_id]
  - docker volume ls
  - docker volume inspect [volume_name]
  - docker diff [container_id]
- New artifact was added to 'live_response/containers/podman.yaml':
  - podman stats --all --no-stream
  - podman network ls
  - podman network inspect [network_id]
  - podman volume ls
  - podman volume inspect [volume_name]
  - podman diff [container_id]

### Updated Artifacts

- ESXi support was added to the following artifacts:
  - live_response/process/ps.yaml
  - live_response/process/lsof.yaml
  - live_response/process/hash_running_processes.yaml
  - live_response/network/hostname.yaml
  - live_response/network/ifconfig.yaml
  - live_response/network/lsof.yaml
  - live_response/network/netstat.yaml
  - live_response/storage/mount.yaml
- 'files/applications/icloud_drive.yaml' was renamed to 'files/applications/icloud.yaml'.
- A new artifact to collect iCloud accounts information files was added to 'files/applications/icloud.yaml'.

### Deprecated

- '-o' command line switch was replaced by '-s', and will be removed in the next release. So don't forget to update your documentation.
- '--sftp-delete-local-on-success' command line switch was replaced by '--delete-local-on-successful-transfer'.

### Fixed

- Issue that was preventing UAC to collect files from home directories when executing it via EDR and the system HOME variable was not set by the current shell ([#47](https://github.com/tclahr/uac/issues/47)).

## 2.1.0 (2022-02-15)

### Added

- Now you can use PROFILE (-p) and ARTIFACTS (-a) options together to create even more customizable collections. Please check the docs for more info. 
- '9p' file system, used by Microsoft's WSL to mount local drives, was added to the global file system exclusion list in 'config/uac.conf'. This avoids UAC to recursively search artifacts through mounted local drives (like C:).

### New Artifacts

#### Applications

- New artifact to collect Discord artifacts (files/applications/discord.yaml).
- New artifact to collect Facebook Messenger artifacts (files/applications/facebook_messenger.yaml).
- New artifact to collect iMessage artifacts (files/applications/imessage.yaml).
- New artifact to collect Microsoft Teams artifacts (files/applications/microsoft_teams.yaml).
- New artifact to collect Signal artifacts (files/applications/signal.yaml).
- New artifact to collect Slack artifacts (files/applications/slack.yaml).
- New artifact to collect Skype artifacts (files/applications/skype.yaml).
- New artifact to collect Telegram Desktop artifacts (files/applications/telegram.yaml).
- New artifact to collect Viber Desktop artifacts (files/applications/viber.yaml).
- New artifact to collect WhatsApp Desktop artifacts (files/applications/whatsapp.yaml).
- New artifact to collect AddressBook database, metadata and image files (files/applications/addressbook.yaml).
- New artifact to collect Apple Notes app database file (files/applications/apple_notes.yaml).
- New artifact to collect Aspera Connect file transfer log files (files/applications/aspera_connect.yaml).
- New artifact to collect Dropbox Cloud Storage Metadata files (files/applications/dropbox.yaml).
- New artifact to collect FileZilla XML and sqlite files (files/applications/filezilla.yaml).
- New artifact to collect iCloud databases that contain information about files that have been imported from the local computer or synced remotely from the iCloud (files/applications/icloud_drive.yaml).
- New artifact to collect iTunes Backup directory (files/application/itunes_backup.yaml).
- New artifact to collect VLC recently opened files (files/applications/vlc.yaml).
- New artifact to collect Thunderbird artifacts (files/applications/thunderbird.yaml).

#### System

- New artifact to collect Apple Accounts database file (files/system/apple_accounts.yaml).
- New artifact to collect information about the permissions that a user is prompted to accept or decline while using macOS applications (files/system/tcc.yaml).
- New artifact to collect Linux Most Recent Used files information (files/system/linux_mru.yaml).
- New artifact to collect macOS knowledgeC.db file (files/system/knowledgec.yaml).
- New artifact to collect macOS system and user's preferences and configuration plist files (files/system/library_preferences.yaml).
- New artifact to collect information about the applications that are set to reopen after macOS computer restarts or resumes from sleep (files/system/resumed_applications.yaml).
- New artifact to collect temporary files located in the '/tmp' directory (files/system/tmp.yaml).

#### Live Response

- New artifact to collect information about installed bundles on Clear Linux (live_response/packages/swupd.yaml).
- New artifact to collect information about installed packages using zypper tool (live_response/packages/zypper.yaml).
- New artifact to collect information about installed applications on macOS (live_response/packages/pkgutil.yaml).
- New artifact to collect statistics about GEOM disks on FreeBSD (live_response/storage/gstat.yaml)
- New artifact to collect VirtualBox VMs information (live_response/vms/virtualbox.yaml).

### Updated Artifacts

- A new command was added to the rpm artifact to compare information about the installed files in the rpm packages with information about the files taken from the package metadata stored in the rpm database (live_response/packages/rpm.yaml).
- 'files/browsers/chromium_based.yaml' artifact was split and replaced by 'files/browsers/brave.yaml', 'files/browsers/chrome.yaml', 'files/browsers/chromium.yaml', 'files/browsers/edge.yaml' and 'files/browsers/opera.yaml'.
- Firefox browser artifacts updated to include Flatpak and Snap versions (files/browsers/firefox.yaml).
- Safari artifact updated to collect Safari Recently Closed Tabs plist file (files/browsers/safari.yaml).

### New Profile

- New 'ir_triage' profile is now available. This profile is more focused on collecting incident response triage artifacts only.

### Updated Profiles

- 'full' and 'full-with-memory-dump' profiles were updated so 'bodyfile/bodyfile.yaml' will now be collected sooner. 

### Deprecated Profiles

- 'full-with-memory-dump' profile will be removed in the future because '--profile full --artifacts memory_dump/avml.yaml' can be used instead. 
- 'memory-dump-only' profile will be removed in the future because '--artifacts memory_dump/avml.yaml' can be used instead.

### Fixed

- 'live_response/process/proctree.yaml' artifact file was missing on both 'full' and 'full-with-memory-dump' profiles ([#28](https://github.com/tclahr/uac/issues/28)).
- Issue that was preventing ```stat``` to collect some information from directories and symbolic links.
- Issue that was preventing file names with single and double quotes to be hashed and stated properly.
- Issue that was preventing UAC to run as root on VMWare ESXi systems.
- Issue that was preventing UAC to properly collect files from mounted disk images.

## 2.0.0 (2021-11-24)

### Highlights

- Faster collection engine.
- Artifacts collections are now based on YAML files.
- Nine supported operating systems: android (via adb shell), aix, freebsd, linux, macos, netbsd, netscaler, openbsd and solaris.
- New command line options.
- New output and log file format.
- Revamped uac.log file.
- Command errors will now be stored into individual .stderr files.
- New Linux memory dump collection via avml tool.

### New Artifacts

- New browser artifacts
  - Chromium based (Chrome, Edge, Opera, Brave...)
  - Firefox
  - Safari
- New applications artifacts
  - macOS dock
  - LibreOffice MRU
  - Microsoft Office MRU
  - WPS Office MRU
- New system artifacts
  - macOS MRU
  - macOS autoruns
  - macOS quarantine events
  - macOS time machine information
  - macOS wifi information
- New docker/containers artifacts
  - containerd config dump
- New process artifacts
  - proctree -a
  - ps auxwwwf
- New network artifacts
  - ss -tap
  - ss -tanp
  - ss -tlp
  - ss -tlnp

## 1.7.0 (2021-09-04)

### Added

- If native ```stat``` tool does not collect file's birth time on linux systems, the new ```statx``` tool will be used instead during body file creation. ```statx``` tool uses the new statx() system call (kernel 4.11+) that solves the deficiencies of the existing stat() system call.
- New system collectors
  - linux and macos
    - falconctl -g --aid
    - falconctl -g --cid
    - falconctl -g --feature
    - falconctl -g --trace
    - falconctl -g --rfm-state
    - falconctl -g --rfm-reason
    - falconctl -g --version
    - falconctl stats

### Fixed

- Fixed issue related to /dev/tty device when running UAC via CrowdStrike RTR (Real Time Response) console ([#24](https://github.com/tclahr/uac/issues/24)).

### Removed

- Solution to collect file's birth time (ext4 only) using ```debugfs``` tool, during body file creation.

## 1.6.0 (2021-07-24)

### Added

- logs, system_files, user_files and suspicious_files will now be stored into a single compressed file (files.tar.gz).
- New entries added to system_files.conf
  - /private/var/spool
- New docker_virtual_machine collectors
  - podman container ls --all --size
  - podman image ls --all
  - podman info
  - podman container logs <ID>
  - podman inspect <ID>
  - podman network inspect <ID>
  - podman top <ID>
  - podman version

## 1.5.1 (2021-06-07)

### Added

- ```devtmpfs```, ```fuse```, ```nfs4```, ```sysfs``` and ```tmpfs``` were added to the list of file systems that will be excluded from the collection.

### Fixed

- strings were not being properly collected from running processes ([#21](https://github.com/tclahr/uac/issues/21)).

## 1.5.0 (2021-05-26)

### Added

- New hardware collectors
  - cat /proc/cpuinfo
- New network collectors
  - hostnamectl
- New process collectors
  - aix
    - procfiles -n -c <PID>
- New system collectors
  - mdatp exclusion list
  - uptime -s
- New entries added to system_files.conf
  - /lib/systemd/system
  - /usr/lib/systemd/system

### Fixed

- File's crtime on ext4 file system was not being collected by bodyfile collector on systems using old 'stat' tool ([#19](https://github.com/tclahr/uac/issues/19)).

## 1.4.0 (2021-02-22)

### Added

- Output file can be automatically transferred (scp) to a remote server using -T option.
- ```afs``` and ```rpc_pipefs``` mounted file systems will also be excluded from the collection if EXCLUDE_MOUNTED_REMOTE_FILE_SYSTEMS option is set to true.
- New entries added to exclude.conf
  - /etc/shadow
- New network collectors
  - linux
    - firewall-cmd --get-active-zones
    - firewall-cmd --get-default-zone
    - firewall-cmd --get-services
    - firewall-cmd --list-all
    - firewall-cmd --list-all-zones
- New system collectors
  - linux
    - getenforce
    - mdatp health
    - sestatus -v

## 1.3.1 (2020-12-10)

### Fixed

- UAC was creating an empty output file if tar was not available in the target system ([#15](https://github.com/tclahr/uac/issues/15)).

## 1.3.0 (2020-10-18)

### Added

- File creation time (Linux and ext4 file systems only) will now be collected by the bodyfile collector if debugfs tool is available on the target system. This will extremely increase the collection time, so it can be disabled by editing ```conf/uac.conf``` and setting BODY_FILE_CRTIME to false.
- SHA-1 hashes will also be calculated by default. It can be disabled by editing ```conf/uac.conf``` and setting CALCULATE_SHA1 to false.
- New disk_volume_file_system collectors
  - solaris
    - df -n
- New system collector
  - List of files that have setuid and/or setgid permissions set.

## 1.2.0 (2020-07-26)

### Added

- UAC will collect even more information about running processes.
- Strings will now be extracted from running processes by the process collector.
- New docker and virtual machines information collector (-k).
- Files and directories added to ```conf/exclude.conf``` will be skipped during collection.
- By default, mounted remote file systems will be excluded from the collection. Please refer to ```conf/uac.conf``` for more information.
- New docker_virtual_machine collectors
  - docker container ls --all --size
  - docker image ls --all
  - docker info
  - docker container logs <ID>
  - docker inspect <ID>
  - docker network inspect <ID>
  - docker top <ID>
  - docker version
  - virsh list --all
  - virsh domifaddr <NAME>
  - virsh dominfo <NAME>
  - virsh dommemstat <NAME>
  - virsh snapshot-list <NAME>
  - virsh vcpuinfo <DOMAIN>
  - virsh net-list --all
  - virsh net-info <NAME>
  - virsh net-dhcp-leases <NAME>
  - virsh nodeinfo
  - virsh pool-list --all
  - virt-top -n 1
- New process collectors
  - ps -eo pid,etime,args
  - ps -eo pid,lstart,args
  - aix
    - strings /proc/<PID>/psinfo
  - linux
    - pstree
    - cat /proc/<PID>/comm
    - strings /proc/<PID>/cmdline
    - cat /proc/<PID>/maps
    - strings /proc/<PID>/environ
    - cat /proc/<PID>/task/<PID>/children
    - ls -la /proc/<PID>/fd
- New network collectors
  - bsd
    - sockstat -w
  - linux
    - netstat -l -p -e -a -n -u -t
  - macos
    - plutil -p /Library/Preferences/SystemConfiguration/preferences.plist
    - scutil --proxy
- New hardware collectors
  - bsd
    - pciconf -l -v
- New system collectors
  - linux
    - service list
- New software collectors
  - macos
    - lsappinfo list
- New user collectors
  - macos
    - dscl . list /Users UniqueID
- New entries added to logs.conf
  - /var/nsproflog
  - /var/nssynclog
  - catalina.out
- New entries added to user_files.conf
  - /.xsession-errors

### Changed

- Hash running processes will now be executed by the process collector (-p).
- conf/uac.conf
  - BODY_FILE_MAX_DEPTH default value changed from 4 to 5.
- misc files was renamed to suspicious files collector.

### Removed

- hash running processes collector (-r).

### Fixed

- Data range option not adding the "+" prefix for the second -atime, -mtime and -ctime parameters ([#10](https://github.com/tclahr/uac/issues/10)).

## 1.1.1 (2020-06-16)

### Fixed

- Operating system error message being sent to terminal if an invalid directory is used as destination ([#5](https://github.com/tclahr/uac/issues/5)).
- hash_running_processes collector and hash_exec extension not working on AIX 6 ([#6](https://github.com/tclahr/uac/issues/6)).

## 1.1.0 (2020-05-27)

### Added

- Now you can use your own validated tools (binary files) during artifacts collection. Please refer to ```bin/README.txt``` for more information.
- Date Range (-R) option can be used to limit the amount of data collected by logs (-l), misc_files (-f) and user_accounts (-u) collectors.
- New Sleuthkit fls tool extension.
- New misc_files (-f) collector. Please refer to ```conf/misc_files.conf``` for more information.
- Files and directories added to ```conf/user_files.conf``` will be collected by the user_accounts (-u) collector.
- You can set a max depth and max file size for logs (-l), misc_files (-f) and user_accounts (-u) collectors. Please refer to ```conf/uac.conf``` for more information.
- New disk_volume_file_system collectors
  - solaris
    - iostat
- New harware collectors
  - linux
    - lsscsi
- New software collectors
  - linux
    - dnf history list
    - dnf history userinstalled
    - dnf list installed
    - ipkg list-installed
    - ipkg list_installed
    - opkg list-installed
    - pacman -Q -e
    - pacman -Q -m
    - pacman -Q -n
- New system collectors
  - aix
    - mpstat
  - linux
    - systemctl list-timers --all
    - systemctl list-unit-files
    - vmstat
  - solaris
    - mpstat
    - vmstat
- New user_accounts collectors
  - last -i
- New entries in user_files.conf
  - .login
  - .*_login
  - .logout
  - .zhistory
  - .zlogin
  - .zlogout
  - .cshdirs
  - .cshrc
  - .kshrc
  - .tcshrc
  - .zprofile
  - .zshenv
  - .zshrc
- New entries in system_files.conf
  - /var/spool

### Changed

- Files and directories added to ```conf/system_files.conf``` will be collected by the system (-y) collector.
- aix collectors
  - iostat moved from system to disk_volume_file_system collector
- bsd collectors
  - iostat moved from system to disk_volume_file_system collector
- chkrootkit extension
  - ```chkrootkit``` binary file must be placed in the main ```bin``` directory now. Please refer to ```bin/README.txt``` for more information.
- moved from logs.conf to user_files.conf
  - .history
  - *.history
  - .*_history
  - .*_logout
  - .*_session
  - *.session
- moved from system_files.conf to misc_files.conf
  - /var/spool/cron
  - /tmp
  - /private/tmp
- moved from system_files.conf to user_files.conf
  - .rhosts
  - .profile
  - .bashrc
  - .*_profile

### Removed

- Entries removed from system_files.conf
  - /var/spool/cron

### Fixed

- ```compress_data``` function not working properly on Linux systems that use an old busybox (tar) version.
- body_file collector will only run if either ```stat``` or ```perl``` is available on the system.
- hash_exec extension will only run if ```file``` tool is available on the system.

## 1.0.1 (2020-03-26)

### Fixed

- running UAC and quickly terminating the process was making it to propose the user to delete the root folder "/" ([#1](https://github.com/tclahr/uac/issues/1)).

## 1.0.0 (2020-02-04)

- Initial Release
