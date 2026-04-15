SOURCE := bootsect.asm

$(BUILD_DIR)/floppy/stage1.bin: $(BUILD_DIR)/floppy/stage1.o
	$(LD) -m elf_i386 -T linker.ld -Map=$(BUILD_DIR)/floppy/stage1.map $^ -o $@

$(BUILD_DIR)/floppy/stage1.o: $(SOURCE)
	@mkdir -p $(@D)
	$(ASM) -f elf -g $(SOURCE) -o $@
