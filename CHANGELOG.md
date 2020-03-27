# Changelog
All notable changes to this project will be documented in this file.

## 1.1.0-dev

### Added
- Now you can use your own validated tools (binary files) during artifacts collection. Please refer to ```bin/README.txt``` for more information.
- New aix collectors
  - system
    - mpstat
- New linux collectors
  - system 
    - vmstat
  - software
    - ipkg list-installed
    - ipkg list_installed
    - opkg list-installed
- New solaris collectors
  - system
    - mpstat
    - vmstat
  - disk_volume_file_system
    - iostat
- logs.conf
  - .login
  - .*_login
  - .logout
  - .zhistory
  - .zlogin
  - .zlogout
- system_files.conf
  - /var/spool
  - *.sessions
  - .*_sessions
  - .cshdirs
  - .cshrc
  - .kshrc
  - .tcshrc
  - .zprofile
  - .zshenv
  - .zshrc

### Changed
- aix collectors
  - iostat moved from system to disk_volume_file_system collector
- bsd collectors
  - iostat moved from system to disk_volume_file_system collector
- chkrootkit extension
  - ```chkrootkit``` binary file must be placed in the main ```bin``` directory now. Please refer to ```bin/README.txt``` for more information.

### Removed
- logs.conf
  - .*_session
  - *.session
- system_files.conf
  - /var/spool/cron

### Fixed
- ```has_tool``` function not working properly on Android (Linux) systems.
- ```compress_data``` function not working properly on Linux systems that use an old busybox (tar) version.
- body_file collector will only run if either ```stat``` or ```perl``` is available on the system.
- hash_exec extension will only run if ```file``` tool is available on the system.

## 1.0.1 (2020-03-26)

### Fixed
- running UAC and quickly terminating the process was making it to propose the user to delete the root folder "/" [#1](https://github.com/tclahr/uac/issues/1)

## 1.0.0 (2020-02-04)
- Initial Release
