export SHELL := bash
export MAKEFLAGS += --warn-undefined-variables

.ONESHELL:

TARGET ?= floppy.img

.PHONY: all
all: $(TARGET)

.PHONY: run
run: always $(TARGET)
	qemu-system-i386 														\
		-cpu 486,fpu=off 													\
		-drive file=$(TARGET),format=raw,if=floppy

.PHONY: clean
clean:
	rm -rf $(TARGET)

$(TARGET):
	cd ..
	$(MAKE) floppy
	cd example

	dd if=/dev/zero of=$(TARGET) bs=512 count=2880
	mkfs.fat -F 12 -n "LIMEBOOT" $(TARGET)
	dd if=../build/floppy/stage1.bin of=$(TARGET) conv=notrunc
	mcopy -i $(TARGET) ../build/stage2.bin "::stage2.bin"
