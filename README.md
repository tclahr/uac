# UAC (Unix-like Artifacts Collector)

## Description

UAC is a command line shell script that makes use of built-in tools to automate the collection of Unix-like systems artifacts. The script respects the order of volatility and artifacts that are changed during the execution. It can also be run against mounted forensic images. Please take a look on the ```conf/uac.conf``` file for more details.

UAC was created for Incident Responders, Forensic Analysts, Auditors and System Administrators to facilitate and speed up data collection, and depend less on remote support.

You can use your own validated tools during artifacts collection. They will be used instead of the built-in ones provided by the target system. Please refer to ```bin/README.txt``` for more information.

## Contributing to the project
We welcome contributions to the uac Project in many forms. There's always plenty to do! Full details of how to contribute to this project are documented in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## Maintainers
The project's [maintainers](MAINTAINERS.md) are responsible for reviewing and merging all pull requests and they guide the over-all technical direction of the project.

## Supported Systems

- AIX
- BSD
- Linux
- macOS
- Solaris

## Collectors

### Process Listing (-p)
Collect current process listing.

### Network (-n)
Collect active network connections with related process information.

### User Accounts (-u)
Collect user accounts information, login related files and activities. The list of files and directories that will be collected can be found in the ```conf/user_files.conf``` file.

### System (-y)
Collect system information, system configuration files and kernel related details. The list of files and directories that will be collected can be found in the ```conf/system_files.conf``` file.

### Hardware (-w)
Collect low level hardware information.

### Software (-s)
Collect information about installed packages and software.

### Disk Volume and File System (-d)
Collect information about disks, volumes and file systems.

### Body File (-b)
Extract information from files and directories using the ```stat``` or ```stat.pl``` tool to create a [body file](https://wiki.sleuthkit.org/index.php?title=Body_file). The body file is an intermediate file when creating a timeline of file activity. It is a pipe ("|") delimited text file that contains one line for each file.
[Plaso](https://github.com/log2timeline/plaso) or [mactime](https://wiki.sleuthkit.org/index.php?title=Mactime) tools can be used to read this file and sorts the contents.

### Logs (-l)
Collect log files and directories. The list of files and directories that will be collected can be found in the ```conf/logs.conf``` file.

### Suspicious Files (-f)
Collect suspicious files and directories. The list of files and directories that will be collected can be found in the ```conf/suspicious_files.conf``` file.

### Hash Running Processes (-r)
Collect current process listing with hash (MD5) values.

## Extensions

### chkrootkit
Run [chkrootkit](http://www.chkrootkit.org) tool (if available).
Note that chrootkit tool is not provided by UAC. You need to either have it available on the target system or download and compile it, and make its static binary file available through ```bin``` directory. Please refer to ```bin/README.txt``` for more information.

### fls
Run Sleuth Kit [fls](http://wiki.sleuthkit.org/index.php?title=Fls) tool (if available) against all mounted block devices.
Note that fls tool is not provided by UAC. You need to either have it available on the target system or download and compile it, and make its static binary file available through ```bin``` directory. Please refer to ```bin/README.txt``` for more information.

### hash_exec
Collect MD5 hashes for all executable files. By default, only files smaller than 3072000 bytes (3MB) will be hashed. Please take a look on the ```extensions/hash_exec/hash_exec.conf``` file more details.
Warning: this extension will change the last accessed date of the touched files.

## Profiles
One of the following profiles will be selected automatically according to the kernel name running on the current system. You can manually select one using the -P option though. This is useful when either UAC was not able to identify the correct profile for the current running system or when you are running UAC against a mounted forensic image.

### aix
Use this profile to collect AIX artifacts.

### bsd
Use this profile to collect BSD-based systems artifacts.  
*e.g. FreeBSD, NetBSD, OpenBSD, NetScaler...*

### linux
Use this profile to collect Linux-based systems artifacts.  
*e.g. Debian, Red Hat, SuSE, Arch Linux, OpenWRT, QNAP QTS, Windows Subsystem for Linux...*

### macos
Use this profile to collect macOS artifacts.

### solaris
Use this profile to collect Solaris artifacts.

## Options

### Date Range (-R)
The range of dates to be used during logs, suspicious files, user files and hash executable files collection. The date range is used to limit the amount of data collected by filtering files using find's -atime, -mtime or -ctime parameter. By default, UAC will search for files that data was last modified (-mtime) OR status last changed (-ctime) within the given date range. Please refer to ```conf/uac.conf``` for more details.
The standard format is YYYY-MM-DD for a starting date and no ending date. For an ending date, use YYYY-MM-DD..YYYY-MM-DD.

### Debug (-D)
Increase debugging level.

### Verbose (-V)
Increase verbosity level.

### Run as non-root (-U)
Allow UAC to be run by a non-root user. Note that data collection will be limited.

## Configuration Files

### conf/uac.conf
The main UAC configuration file.

### conf/logs.conf
Directory or file paths that will be searched and collected by the logs (-l) collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

### conf/suspicious_files.conf
Directory or file paths that will be searched and collected by the suspicious files (-f) collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

### conf/system_files.conf
Directory or file paths that will be searched and collected by the system files (-y) collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

### conf/user_files.conf
Directory or file paths that will be searched and collected by the user files (-u) collector. If a directory path is added, all files and subdirectories will be collected automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with the ```-name``` option. Please check ```find``` man pages for instructions.

### conf/exclude.conf
Directory or file paths that will be excluded from collection. If a directory path is added, all files and subdirectories will be skilled automatically.
The ```find``` command line tool will be used to search for files and directories, so the patterns added to this file need to be compatible with ```-path``` and ```-name``` options. Please check ```find``` man pages for instructions.

## Usage
```
UAC (Unix-like Artifacts Collector)
Usage: ./uac COLLECTORS [-e EXTENSION_LIST] [-P PROFILE] [OPTIONS] [DESTINATION]

COLLECTORS:
    -a           Enable all collectors.
    -p           Collect current process listing.
    -n           Collect active network connections with related process information.
    -u           Collect user accounts information, login related files and activities.
    -y           Collect system information, system configuration files and kernel related details.
    -w           Collect low level hardware information.
    -s           Collect information about installed packages and software.
    -d           Collect information about disks, volumes and file systems.
    -b           Extract information from files and directories using the stat tool to create a body file.
    -l           Collect log files and directories.
    -f           Collect suspicious files and directories.
    -r           Collect current process listing with hash (MD5) values.

EXTENSIONS:
    -e EXTENSION_LIST
                 Comma separated list of extensions.
                 all: Enable all extensions.
                 chkrootkit: Run chkrootkit tool.
                 fls: Run Sleuth Kit fls tool.
                 hash_exec: Hash executable files.

PROFILES:
    -P PROFILE   Force UAC to use a specific profile.
                 aix: Use this one to collect AIX artifacts.
                 bsd: Use this one to collect BSD-based systems artifacts.
                 linux: Use this one to collect Linux-based systems artifacts.
                 macos: Use this one to collect macOS artifacts.
                 solaris: Use this one to collect Solaris artifacts.

OPTIONS:
    -R           Starting date YYYY-MM-DD or range YYYY-MM-DD..YYYY-MM-DD
    -D           Increase debugging level.
    -V           Increase verbosity level.
    -U           Allow UAC to be run by a non-root user. Note that data collection will be limited.
    -v           Print version number.
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
