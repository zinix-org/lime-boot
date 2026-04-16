OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x7C00;

    .bpb : { *(.bpb) }

    .text : { *(.text) }

    .rodata : { *(.rodata) }

    .data : { *(.data) }

    .bios_footer 0x7DFE : { SHORT(0xAA55) }

    .bss : { *(.bss) }
}
