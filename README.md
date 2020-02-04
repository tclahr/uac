# UAC (Unix-like Artifacts Collector)

## Description

UAC is a command line shell script that makes use of built-in tools to automate the collection of system artifacts. The script respects the order of volatility and artifacts that are changed during the execution. It can also be run against mounted forensic images. Please take a look on the ```conf/uac.conf``` file for more details.

UAC was created for Incident Responders, Forensic Analysts, Auditors and System Administrators to facilitate and speed up data collection, and depend less on remote support.

## Contributing to the project
We welcome contributions to the uac Project in many forms. There's always plenty to do! Full details of how to contribute to this project are documented in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## Maintainers
The project's [maintainers](MAINTAINERS.md) are responsible for reviewing and merging all pull requests and they guide the over-all technical direction of the project.

## Supported Systems

- AIX
- BSD (FreeBSD, NetBSD, OpenBSD...)
- Linux
- macOS
- Solaris

## Collectors

### Process Listing (-p)
Collect current process listing.
### Network (-n)
Collect active network connections with related process information.
### User Accounts (-u)
Collect information about user accounts and login activities.
### System (-y)
Collect low level system information and kernel related details.
### Hardware (-w)
Collect low level hardware information.
### Software (-s)
Collect information about installed packages and software.
### Disk Volume and File System (-d)
Collect information about disk volumes and file systems.
### Body File (-b)
Extract information from files and directories using the ```stat``` tool to create a [body file](https://wiki.sleuthkit.org/index.php?title=Body_file). The body file is an intermediate file when creating a timeline of file activity. It is a pipe ("|") delimited text file that contains one line for each file.
The [mactime](https://wiki.sleuthkit.org/index.php?title=Mactime) tool can be used to read this file and sorts the contents.
### Logs (-l)
Collect log files and directories. The list of files and directories that will be collected can be found in the ```conf/logs.conf``` file.
### System Files (-f)
Collect system wide configuration files and directories. The list of files and directories that will be collected can be found in the ```conf/system_files.conf``` file.
### Hash Running Processes (-r)
Collect current process listing with hash (MD5) values.

## Extensions

### chkrootkit
Run [chkrootkit](http://www.chkrootkit.org) tool (if available).
Note that chrootkit is not provided by UAC. You need to either install it on the target system or download and compile it, and then copy the binary file to ```extensions/chkrootkit/bin``` directory.

### hash_exec
Collect MD5 hashes for all executable files. By default, only files smaller than 3072000 bytes (3MB) will be hashed. Please take a look on the ```extensions/hash_exec/hash_exec.conf``` file more details.
Warning: this extension will change the last accessed date of the touched files.

## Profiles
One of the following profiles will be selected automatically according to the kernel name running on the current system. You can manually select one using the -P option though. This is useful when either UAC was not able to identify the correct profile for the current running system or when you are running UAC against a mounted forensic image.

### aix
Use this profile to collect AIX artifacts.

### bsd
Use this profile to collect BSD (OpenBSD, FreeBSD, NetBSD...) artifacts.

### linux
Use this profile to collect Linux artifacts.

### macos
Use this profile to collect macOS artifacts.

### solaris
Use this profile to collect Solaris artifacts.

## Configuration Files

### conf/uac.conf
The main UAC configuration file.

### conf/logs.conf
Directory or file paths that will be searched and collected by the logs collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

### conf/system_files.conf
Directory or file paths that will be searched and collected by the system_files collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

## Usage
```
UAC (Unix-like Artifacts Collector)
Collects artifacts from Unix-like systems

Usage: ./uac COLLECTORS [-e EXTENSION_LIST] [-P PROFILE] [OPTIONS] [DESTINATION]

COLLECTORS:
    -a           Enable all collectors.
    -p           Collect current process listing.
    -n           Collect active network connections with related process information.
    -u           Collect information about user accounts and login activities.
    -y           Collect low level system information and kernel related details.
    -w           Collect low level hardware information.
    -s           Collect information about installed packages and software.
    -d           Collect information about disk volumes and file systems.
    -b           Extract information from files and directories using the stat tool to create a body file.
    -l           Collect log files and directories.
    -f           Collect system wide configuration files and directories.
    -r           Collect current process listing with hash (MD5) values.

EXTENSIONS:
    -e EXTENSION_LIST
                 Comma separated list of extensions.
                 all: Enable all extensions.
                 chkrootkit: Run chkrootkit tool.
                 hash_exec: Hash executable files.

PROFILES:
    -P PROFILE   Force UAC to use a specific profile.
                 aix: Use this to collect AIX artifacts.
                 bsd: Use this to collect BSD (OpenBSD, FreeBSD, NetBSD...) artifacts.
                 linux: Use this to collect Linux artifacts.
                 macos: Use this to collect macOS artifacts.
                 solaris: Use this to collect Solaris artifacts.

OPTIONS:
    -D           Increase debugging level.
    -V           Increase verbosity level.
    -U           Allow UAC to be run by a non-root user. Note that data collection will be limited.
    -h           Print this help summary page.

DESTINATION:
    Specify the directory the output will be saved to.
    The default is the current directory.
```

## Output
When UAC finishes, all collected data is compressed and the resulting file is stored in the destination directory. The compressed file is hashed (MD5) and the value is stored on a .md5 file.

## Examples
Run all collectors against the current running system and use the current directory as the destination. Extensions will not be run:
```
./uac -a
```
Run all collectors and all extensions against the current running system, and use ```/tmp``` as the destination directory:
```
./uac -a -e all /tmp
```
Run only hash_exec and chkrootkit extensions against the current running system, force ```linux``` profile and use ```/mnt/share``` as the destination directory:
```
./uac -e hash_exec,chkrootkit -P linux /mnt/share
```
Run only process listing, hardware and logs collectors against the current running system, force ```solaris``` profile, use ```/tmp``` as the destination directory and increase verbosity level:
```
./uac -p -w -l -P solaris -V /tmp
```

## License
The UAC project uses the [Apache License Version 2.0](LICENSE) software license.
