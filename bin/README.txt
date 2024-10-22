Place your validated executables (binary files and scripts) here!

In most cases, the executables should be placed in the '[UAC_DIRECTORY]/bin' directory,
along with any additional support files it needs to run.

For example, if you have an artifact that uses an executable named 'my_script.sh', you should place
this binary in the '[UAC_DIRECTORY]/bin' directory.

In the case where you have executables with the same name, but for multiple operating systems,
they should be placed in the '[UAC_DIRECTORY]/bin/[OS]' directory.

For example, if you have an artifact that uses an executable named 'lsof', but you
have two binary files, one for Linux and one for FreeBSD, you should place the binaries
in the '[UAC_DIRECTORY]/bin/linux' and '[UAC_DIRECTORY]/bin/freebsd' directories.
Note that the operating system name must be in lowercase.

In the case where you have executables that can be run on multiple operating systems, they
should be placed in the '[UAC_DIRECTORY]/bin/[OS1_OS2_OS3]' directory. Note that you
can have multiple operating systems separated by an underscore '_'.

For example, if you have an artifact that uses an executable named 'netstat' that
runs on both Linux and ESXi systems, you should place the binary either in the
'[UAC_DIRECTORY]/bin/linux_esxi' directory, or place the binary in the '[UAC_DIRECTORY]/bin/linux' and
'[UAC_DIRECTORY]/bin/esxi' directories.

In the case where you have executables with the same name, but for multiple operating systems
and multiple architectures, they should be placed in the '[UAC_DIRECTORY]/bin/[OS]/[ARCH]' directory.

For example, if you have an artifact that uses an executable named 'ss', but you
have binary files for Linux arm64 and ppc64, FreeBSD i386, and Solaris x86_64 and sparc64,
you should place the binary files in the '[UAC_DIRECTORY]/bin/linux/arm64',
'[UAC_DIRECTORY]/bin/linux/ppc64', '[UAC_DIRECTORY]/bin/freebsd/i386',
'[UAC_DIRECTORY]/bin/solaris/x86_64' and '[UAC_DIRECTORY]/bin/solaris/sparc64' directories.
