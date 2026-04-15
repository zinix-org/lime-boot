SOURCE := bootsect.asm

$(BUILD_DIR)/floppy/stage1.bin: $(SOURCE)
	@mkdir -p $(@D)
	$(ASM) $(SOURCE) -f bin -o $@
