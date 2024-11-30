# Changelog

## DEVELOPMENT VERSION

### Artifacts

- live_response/system/getcap.yaml: Added functionality to collect the list of files with associated process capabilities [linux] ([mnrkbys](https://github.com/mnrkbys)).

### New Artifacts Properties

- Added the new 'redirect_stderr_to_stdout' property, an optional feature available exclusively for the command collector. When set to true, this property redirects all error messages (stderr) to standard output (stdout), ensuring they are written to the output file.

### Fixes

- Resolves an issue where the hash and stat collectors failed to function correctly when the %user_home% variable was included in the path property ([#289](https://github.com/tclahr/uac/issues/289)).
