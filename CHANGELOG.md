# Changelog
All notable changes to this project will be documented in this file.

## [1.1.0-dev]

### Added
#### software collector
##### linux
- ipkg list-installed
- opkg list-installed

### Changed

### Removed

### Fixed

#### body_file collector
- body_file collector will only run if either ```stat``` or ```perl``` is available on the system.
#### hash_exec extension
- hash_exec extension will only run if ```file``` tool is available on the system.

## [1.0.0] - 2020-02-04
- Initial Release
