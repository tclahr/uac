# Changelog
All notable changes to this project will be documented in this file.

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
    - docker inspect <ID>
    - docker network inspect <ID>
    - docker top <ID>
    - docker version
    - docker container logs
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
