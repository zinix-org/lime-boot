OUTPUT_FORMAT("binary")

SECTIONS
{
    . = 0x9E00;

    .text : { *(.text) }

    .rodata : { *(.rodata) }

    .data : { *(.data) }

    .bss : { *(.bss) }
}
