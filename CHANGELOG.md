# Changelog

## 2.9.0 (2024-05-28)

### Features

- uac.log and uac.log.stderr files were moved to the front of the output archive file (by [rbcrwd](https://github.com/rbcrwd)).

### Artifacts

- files/logs/macos.yaml: Updated collection support for auditd logs [macos] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- files/logs/solaris.yaml: Added collection support for lastlog, wtmpx, utmpx, svc and webui logs that are stored outside /var/log directory [solaris] (by [sec-hbaer](https://github.com/sec-hbaer)).
- files/logs/var_log.yaml: Updated collection to support new system [esxi] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- files/packages/pkg_contents.yaml: Updated collection support for NetBSD 10 [netbsd] (by [Herbert-Karl](https://github.com/Herbert-Karl)).
- files/packages/pkg_contents.yaml: Updated collection support for package table of contents files [solaris] (by [sec-hbaer](https://github.com/sec-hbaer)).
- files/system/svc.yaml: Added collection support for svc manifest and method (service start) files [solaris] (by [sec-hbaer](https://github.com/sec-hbaer)).
- files/system/systemd.yaml: Updated collection to support artifacts related to transient and per-user systemd timers [linux] (by [halpomeranz](https://github.com/halpomeranz)).
- files/system/var_ld.yaml: Added collection support for ld config files [solaris] (by [sec-hbaer](https://github.com/sec-hbaer)).
- live_response/containers/docker.yaml: Added collection support for resource usage statistics of each container [linux].
- live_response/containers/podman.yaml: Added collection support for resource usage statistics of each container [linux].
- live_response/packages/brew.yaml: Added collection support for packages installed through brew package manager [macos] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/equo.yaml: Added collection support for packages installed through Entropy package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/nix.yaml: Added collection support for packages installed through Nix package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/pip.yaml: Added collection support for Python packages installed through pip [linux] (by [sanderu](https://github.com/sanderu)).
- live_response/packages/pisi.yaml: Added collection support for packages installed through pisi package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/pkg.yaml: Updated collection support for information about installed packages [solaris] (by [sec-hbaer](https://github.com/sec-hbaer)).
- live_response/packages/xbps.yaml: Added collection support for packages installed through XBPS package manager [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/packages/yay.yaml: Added collection support for packages installed through Yay [linux] (by [Pierre-Gronau-ndaal](https://github.com/Pierre-Gronau-ndaal)).
- live_response/process/procfs_information.yaml: Added collection support for entries corresponding to memory-mapped files [linux].
- live_response/process/procfs_information.yaml: Added collection support for listing the contents of /proc/modules [linux].
- live_response/process/procfs_information.yaml: Added collection support for listing Unix sockets [linux].
- live_response/system/ebpf.yaml: Added collection support for listing pinned eBPF progs [linux].
- live_response/system/kernel_modules.yaml: Added collection support for listing available parameters per kernel module [linux].
- live_response/system/kernel_modules.yaml: Added collection support for listing loaded kernel modules to compare with /proc/modules [linux].
- live_response/system/modinfo.yaml: Added collection support for information about loaded kernel modules [linux, solaris] (by [sanderu](https://github.com/sanderu)).
