CFLAGS=-static -O2
BIN_DIR=../bin

all: arm arm64 i686 x86_64 mips mips64 ppc ppc64 ppc64le s390 sparc

arm: statx.c
	mkdir -p $(BIN_DIR)/$@
	arm-linux-gnueabi-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

arm64: statx.c
	mkdir -p $(BIN_DIR)/$@
	aarch64-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

i686: statx.c
	mkdir -p $(BIN_DIR)/$@
	i686-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

x86_64: statx.c
	mkdir -p $(BIN_DIR)/$@
	x86_64-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

mips: statx.c
	mkdir -p $(BIN_DIR)/$@
	mips-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

mips64: statx.c
	mkdir -p $(BIN_DIR)/$@
	mips64-linux-gnuabi64-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

ppc: statx.c
	mkdir -p $(BIN_DIR)/$@
	powerpc-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

ppc64: statx.c
	mkdir -p $(BIN_DIR)/$@
	powerpc64-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

ppc64le: statx.c
	mkdir -p $(BIN_DIR)/$@
	powerpc64le-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

s390: statx.c
	mkdir -p $(BIN_DIR)/$@
	s390x-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

sparc: statx.c
	mkdir -p $(BIN_DIR)/$@
	sparc64-linux-gnu-gcc $(CFLAGS) -o $(BIN_DIR)/$@/statx statx.c

clean:
	rm -rf $(BIN_DIR)/arm $(BIN_DIR)/arm64 $(BIN_DIR)/i686 $(BIN_DIR)/x86_64 $(BIN_DIR)/mips $(BIN_DIR)/mips64 $(BIN_DIR)/ppc $(BIN_DIR)/ppc64 $(BIN_DIR)/ppc64le $(BIN_DIR)/s390 $(BIN_DIR)/sparc