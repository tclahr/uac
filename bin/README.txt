Please follow the instructions below if you want to use your own validated tools (binary files) during artifacts collection.

1. Create a subdirectory here using the desired kernel/operating system name in lowercase (case sensitive). i.e. aix, linux, freebsd, darwin, etc...
2. Create a subdirectory in the directory ./[KERNEL_NAME] using the desired archtecture name in lowercase (case sensitive). i.e. powerpc, i386, x86_64, sparc, etc...
3. Place your validated tools (binary files) in the directory ./[KERNEL_NAME]/[ARCH_NAME] . They will be used instead of the built-in ones provided by the target system.

Examples:
./aix/powerpc
./freebsd/amd64
./freebsd/i386
./netbsd/amd64
./openbsd/amd64
./linux/i686
./linux/ppc64le
./linux/x86_64
./darwin/x86_64
./sunos/i386
./sunos/sparc