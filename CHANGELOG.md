# Changelog

All notable changes to this project will be documented in this file.

## DEVELOPMENT VERSION

### Highlights

### Artifacts

- `live_response/containers/docker.yaml`: Updated to extend docker artifacts collection on macos [macos]. (by [sudesh0sudesh](https://github.com/sudesh0sudesh))
- `live_response/network/netstat.yaml`: Updated to include `netstat -Aan` [aix].
- `live_response/network/rmsock.yaml`: Identify process ownership for TCP network connections. Used to associate PIDs with network activity on AIX systems where lsof is unavailable [aix].
- `live_response/process/fstat.yaml`: Updated to include `fstat -n` [freebsd, netbsd, netscaler, openbsd].
- `live_response/process/ps.yaml`:
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,stat,lstart,args` [freebsd, linux, macos, netbsd, netscaler, openbsd].
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,stat,etime,args` [aix, freebsd, linux, macos, netbsd, netscaler, openbsd].
  - Updated to include `ps -eo user,pid,ppid,pcpu,pmem,tty,s,etime,args` [solaris].

### Removed Artifacts

- `live_response/process/ps.yaml`:
  - `ps auxwwwf`, `ps -deaf` and `ps -efl` commands were removed.
  - `date` command was removed. The exact date and time when `ps` was executed can be checked in the `uac.log` file.

### Fixed

### Tools
