CFLAGS=-static -O2

all: aarch64 arm armhf i686 mips mips64 mips64el powerpc powerpc64 powerpc64le s390x sparc64 x86_64

aarch64: statx.c
	mkdir $@
	aarch64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

arm: statx.c
	mkdir $@
	arm-linux-gnueabi-gcc $(CFLAGS) -o $@/statx statx.c

armhf: statx.c
	mkdir $@
	arm-linux-gnueabihf-gcc $(CFLAGS) -o $@/statx statx.c

i686: statx.c
	mkdir $@
	i686-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

mips: statx.c
	mkdir $@
	mips-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

mips64: statx.c
	mkdir $@
	mips64-linux-gnuabi64-gcc $(CFLAGS) -o $@/statx statx.c

mips64el: statx.c
	mkdir $@
	mips64el-linux-gnuabi64-gcc $(CFLAGS) -o $@/statx statx.c

powerpc: statx.c
	mkdir $@
	powerpc-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

powerpc64: statx.c
	mkdir $@
	powerpc64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

powerpc64le: statx.c
	mkdir $@
	powerpc64le-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

s390x: statx.c
	mkdir $@
	s390x-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

sparc64: statx.c
	mkdir $@
	sparc64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

x86_64: statx.c
	mkdir $@
	x86_64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

clean:
	rm -rf aarch64 arm armhf i686 mips mips64 mips64el powerpc powerpc64 powerpc64le s390x sparc64 x86_64