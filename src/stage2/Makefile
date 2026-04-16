SOURCE := entry.asm

$(BUILD_DIR)/stage2.bin: $(BUILD_DIR)/floppy/stage2.o
	$(LD) -m elf_i386 -T linker.ld $^ -o $@

$(BUILD_DIR)/floppy/stage2.o: $(SOURCE)
	@mkdir -p $(@D)
	$(ASM) -f elf -g $(SOURCE) -o $@
