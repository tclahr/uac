# Changelog

All notable changes to this project will be documented in this file.

## 2.1.0-dev

## Added

- Now you can use PROFILE (-p) and ARTIFACTS (-a) options together to create even more customizable collections.
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
- New artifact to collect VirtualBox VMs information (live_response/vms/virtualbox.yaml).

## Updated Artifacts

- 'files/browsers/chromium_based.yaml' artifact was split and replaced by 'files/browsers/brave.yaml', 'files/browsers/chrome.yaml', 'files/browsers/chromium.yaml', 'files/browsers/edge.yaml' and 'files/browsers/opera.yaml'.
- Firefox browser artifacts updated to include Flatpak and Snap versions (files/browsers/firefox.yaml).
- Safari artifact updated to collect Safari Recently Closed Tabs plist file (files/browsers/safari.yaml).

## New Profiles

- Two new profiles ('ir' and 'ir-with-memory-dump') are now available. These profiles are more focused on collecting incident response artifacts only.

## Fixed

- 'live_response/process/proctree.yaml' artifact file was missing on both 'full' and 'full-with-memory-dump' profiles ([#28](https://github.com/tclahr/uac/issues/28)).
- Issue that was preventing ```stat``` to collect information from directories and symbolic links.
- Issue that was preventing file names with single and double quotes to be hashed and stated properly.

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
