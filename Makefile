export SHELL := bash
export MAKEFLAGS += --warn-undefined-variables

export ASM ?= nasm
export CC ?= clang

export SRC_DIR ?= src
export BUILD_DIR ?= $(abspath build)

.PHONY: all
all:

.PHONY: floppy
floppy: $(BUILD_DIR)/floppy/stage1.bin

$(BUILD_DIR)/floppy/stage1.bin:
	@$(MAKE) -C $(SRC_DIR)/stage1/floppy

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
