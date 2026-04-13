; Lime Bootloader
; Copyright (C) 2026-present Viktor Popp
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <https://www.gnu.org/licenses/>.

org 0x7C00      ; we expect the BIOS to load us at 0x7C00
bits 16         ; the assembler should emit 16-bit code

jmp short _start
nop

_start:
    cli
    cld

    ; setup data segments because some BIOSes might put us at 0x7C00:0x0000
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00      ; the stack grows downwards from where we are loaded

    sti

halt:
    hlt
    jmp halt


times 510-($-$$) db 0
dw 0xAA55
