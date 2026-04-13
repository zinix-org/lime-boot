export SHELL := bash
export MAKEFLAGS += --warn-undefined-variables

export ASM ?= nasm
export CC ?= clang

export SRC_DIR ?= src
export BUILD_DIR ?= $(abspath build)

TARGET ?= floppy.img

.PHONY: all
all: $(BUILD_DIR)/$(TARGET)

.PHONY: run
run: always $(BUILD_DIR)/$(TARGET)
	qemu-system-i386 														\
		-cpu 486,fpu=off 													\
		-drive file=$(BUILD_DIR)/$(TARGET),format=raw,if=floppy

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR)/$(TARGET): always $(BUILD_DIR)/stage1.bin
	dd if=/dev/zero of=$(BUILD_DIR)/$(TARGET) bs=512 count=2880
	mkfs.fat -F 12 -n "ZFLIP" $(BUILD_DIR)/$(TARGET)
	dd if=$(BUILD_DIR)/stage1.bin of=$(BUILD_DIR)/$(TARGET) conv=notrunc


$(BUILD_DIR)/stage1.bin:
	$(MAKE) -C $(SRC_DIR)/stage1

.PHONY: always
always:
	@mkdir -p $(BUILD_DIR)
