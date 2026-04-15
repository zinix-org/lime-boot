# Lime Boot Design Document

## Floppy disks

This section describes the boot workflow when using floppy disks. Floppy disks
are never partitioned and always have a FAT12 filesystem.

### Stage 1 (boot sector)

The first stage is the boot sector. It is the first 512 bytes of the disk. Keep
in mind that we don't support partitioning as there is no need for it on floppy
disks. This means first sector isn't a MBR but just a regular boot sector.

This stage essentially just loads a flat binary into memory and executes it.
Keep in mind that it doesn't know the name of the binary just the lower cluster
number which is set when running the install program for rebuilding the boot
sector.

### Stage 2

The second stage is located in a file called "STAGE2.BIN" which is a flat
binary written in assembly. Its goal is to get all the data it needs from real
mode, then it loads another flat binary called "LIMEBOOT.BIN" into memory,
switches to 32-bit protected mode and executes the binary.

### Stage 3

The third and final stage of the bootloader resides in a file called
"LIMEBOOT.BIN". It is a flat binary written in C for the i386 architecture. It
gathers the information it needs which cant be obtained by the 2nd stage in
16-bit real mode. Then it loads the kernel binary ELF which is specified in a
config file named "LIMEBOOT.CFG".

### The Installation

There is also an installation tool for setting the lower cluster number of the
"STAGE2.BIN". It should be run after writing "STAGE2.BIN", "LIMEBOOT.bin",
"LIMEBOOT.CFG", the kernel and any other files to the floppy disk. It is also
important if any changes has made to the floppy disk the installation tool
should be run again.
