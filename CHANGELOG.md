# Changelog

## DEVELOPMENT VERSION

### Features

- uac.log and uac.log.stderr files were moved to the front of the output archive file (by [rbcrwd](https://github.com/rbcrwd)).
- UAC will try to collect all artifacts regardless of the operating system if the debugging mode is enabled (--debug).

### Artifacts

- files/logs/var_log.yaml: Updated collection to support new system [esxi] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- files/packages/pkg_contents.yaml: Updated collection support for NetBSD 10 [netbsd] (by [Herbert-Karl](https://github.com/Herbert-Karl)).
- live_response/containers/docker.yaml: Added collection support for resource usage statistics of each container [linux].
- live_response/containers/podman.yaml: Added collection support for resource usage statistics of each container [linux].
- live_response/packages/brew.yaml: Added collection support for packages installed through brew package manager [macos] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/equo.yaml: Added collection support for packages installed through Entropy package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/nix.yaml: Added collection support for packages installed through Nix package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/pip.yaml: Added collection support for Python packages installed through pip [linux] (by [sanderu](https://github.com/sanderu)).
- live_response/packages/pisi.yaml: Added collection support for packages installed through pisi package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/xbps.yaml: Added collection support for packages installed through XBPS package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/yay.yaml: Added collection support for packages installed through Yay [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/system/modinfo.yaml: Added collection support for information about loaded kernel modules [linux, solaris] (by [sanderu](https://github.com/sanderu)).

### Fixes

