# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

### Artifacts

- `files/browser/firefox.yaml`: Added support for Firefox 147+ path changes (`.config/mozilla/firefox`) while retaining the legacy path (`.mozilla/firefox`) for compatibility and ESR releases [freebsd, linux]. (by [reece394](https://github.com/reece394))

### Removed Artifacts

### Fixed

- Tar options for reading a file list are now detected at runtime (`-T`, `-I`, `-L` or `-I` after `-cf`), by testing each variant and checking the created package, instead of being chosen by operating system. This fixes packaging on systems where the default `tar` does not match the OS, such as Solaris with GNU tar. The selected option is written to the log.

### Tools
