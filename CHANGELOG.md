# Changelog
All notable changes to this project will be documented in this file.

## 1.1.0-rc1

### Added
- Now you can use your own validated tools (binary files) during artifacts collection. Please refer to ```bin/README.txt``` for more information.
- Date Range (-R) option can be used to limit the amount of data collected by logs (-l) and misc_files (-f) collectors.
- New misc_files (-f) collector. Please refer to ```conf/misc_files.conf``` for more information.
- Files and directories added to ```conf/user_files.conf``` will be collected by the user_accounts (-u) collector.
- You can set a max depth and max file size for the logs (-l) and misc_files (-f) collectors. Please refer to ```conf/uac.conf``` for more information.
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
- user_files.conf
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
- system_files.conf
  - /var/spool

### Changed
- system_files collector renamed to misc_files (-f). Files and directories added to ```conf/system_files.conf``` will now be collected by the system (-y) collector instead.
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
- system_files.conf
  - /var/spool/cron

### Fixed
- ```compress_data``` function not working properly on Linux systems that use an old busybox (tar) version.
- body_file collector will only run if either ```stat``` or ```perl``` is available on the system.
- hash_exec extension will only run if ```file``` tool is available on the system.

## 1.0.1 (2020-03-26)

### Fixed
- running UAC and quickly terminating the process was making it to propose the user to delete the root folder "/" [#1](https://github.com/tclahr/uac/issues/1)

## 1.0.0 (2020-02-04)
- Initial Release
