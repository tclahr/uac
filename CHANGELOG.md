# Changelog

## DEVELOPMENT VERSION

### Artifacts

- live_response/packages/dpkg.yaml: Updated to verify all packages to compare information about the installed files in the package with information about the files taken from the package metadata stored in the dpkg database [linux] ([mnrkbys](https://github.com/mnrkbys)).
- live_response/packages/package_owns_file.yaml: Added collection of which installed package owns a specific file or command. Note that this artifact is resource-intensive and time-consuming to execute, so it is disabled by default in all profiles [linux] ([mnrkbys](https://github.com/mnrkbys)).

### New Artifacts Properties

- Added the new 'redirect_stderr_to_stdout' property, an optional feature available exclusively for the command collector. When set to true, this property redirects all error messages (stderr) to standard output (stdout), ensuring they are written to the output file.

### Fixes

- Resolves an issue where the hash and stat collectors failed to function correctly when the %user_home% variable was included in the path property ([#289](https://github.com/tclahr/uac/issues/289)).
