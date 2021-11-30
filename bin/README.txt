Place your validated binary files in the '[uac_directory]\bin' directory if you want them to be executed instead of the built-in ones provided by the target operating system.

UAC will detect and run CPU architecture specific executable files, so they need to be placed within the following directory structure: '[uac_directory]\bin\[operating_system]\[architecture]'.

Operating system must be one of the following options (in lowercase): android, aix, freebsd, linux, macos, netbsd, netscaler, openbsd or solaris.

Architecture is the kernel architecture (in lowercase). It can be retrieved using 'uname' tool.

For example:

- if you have a 'ss' binary for Linux x86_64, it needs to be placed in the '[uac_directory]\bin\linux\x86_64' directory.
- if you have a 'lsof' binary for AIX powerpc, it needs to be placed in the '[uac_directory]\bin\aix\powerpc' directory.
- if you have a 'netstat' binary for Android aarch64, it needs to be placed in the '[uac_directory]\bin\android\aarch64' directory.