CFLAGS=-static -O2

all: arm arm64 i686 x86_64 mips mips64 ppc ppc64 ppc64le s390 sparc

arm: statx.c
	mkdir $@
	arm-linux-gnueabi-gcc $(CFLAGS) -o $@/statx statx.c

arm64: statx.c
	mkdir $@
	aarch64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

i686: statx.c
	mkdir $@
	i686-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

x86_64: statx.c
	mkdir $@
	x86_64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

mips: statx.c
	mkdir $@
	mips-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

mips64: statx.c
	mkdir $@
	mips64-linux-gnuabi64-gcc $(CFLAGS) -o $@/statx statx.c

ppc: statx.c
	mkdir $@
	powerpc-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

ppc64: statx.c
	mkdir $@
	powerpc64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

ppc64le: statx.c
	mkdir $@
	powerpc64le-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

s390: statx.c
	mkdir $@
	s390x-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

sparc: statx.c
	mkdir $@
	sparc64-linux-gnu-gcc $(CFLAGS) -o $@/statx statx.c

clean:
	rm -rf arm arm64 i686 x86_64 mips mips64 ppc ppc64 ppc64le s390 sparc