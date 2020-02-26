# Changelog
All notable changes to this project will be documented in this file.

## [1.1.0-dev]

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
  - .zlogin
  - .zlogout
- system_files.conf
  - /var/spool
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
- system_files.conf
  - /var/spool/cron

### Fixed
- body_file collector will only run if either ```stat``` or ```perl``` is available on the system.
- hash_exec extension will only run if ```file``` tool is available on the system.

## [1.0.0] - 2020-02-04
- Initial Release
