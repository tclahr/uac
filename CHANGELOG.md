# Changelog

## DEVELOPMENT VERSION

### Artifacts

- live_response/system/coredump.yaml: Added collection of core dump files information [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/system/ulimit.yaml: Added collection of all resource limits information [all] ([mnrkbys](https://github.com/mnrkbys)).
- memory_dump/coredump.yaml: Added collection of core dump, ABRT, Apport, and kdump files [esxi, linux, netbsd] ([mnrkbys](https://github.com/mnrkbys)).

### New Artifacts Properties

- Added the new 'redirect_stderr_to_stdout' property, an optional feature available exclusively for the command collector. When set to true, this property redirects all error messages (stderr) to standard output (stdout), ensuring they are written to the output file.

### Fixes

- Resolves an issue where the hash and stat collectors failed to function correctly when the %user_home% variable was included in the path property ([#289](https://github.com/tclahr/uac/issues/289)).
