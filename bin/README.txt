Please follow the instructions below if you want to use your own validated tools (binary files) during artifacts collection.

1. Create a subdirectory here using the desired kernel/operating system name (case sensitive). i.e. AIX, Linux, FreeBSD, Darwin, etc...
2. Create a subdirectory in the directory ./[KERNEL_NAME] using the desired archtecture name (case sensitive). i.e. powerpc, i386, x86_64, sparc, etc...
3. Place your validated tools (binary files) in the directory ./[KERNEL_NAME]/[ARCH_NAME] . They will be used instead of the built-in ones provided by the target system.

Examples:
./AIX/powerpc
./FreeBSD/amd64
./FreeBSD/i386
./NetBSD/amd64
./OpenBSD/amd64
./Linux/i686
./Linux/ppc64le
./Linux/x86_64
./Darwin/x86_64
./SunOS/i386
./SunOS/sparc