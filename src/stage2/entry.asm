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

bits 16         ; the assembler should emit 16-bit code

jmp _start


%define ENDL 0x0D, 0x0A


section .text

_start:
    cli
    cld

    ; setup data segments
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x9E00      ; the stack grows downwards from where we are loaded

    sti

    mov si, msg_welcome
    call puts

    cli

halt:
    hlt
    jmp halt


;
; print a string to the screen
; parameters:
;   - DS:SI: the string to print
;
puts:
    pusha

.loop:
    lodsb       ; load SI into AL and increment SI
    or al, al
    jz .done

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    popa
    ret


section .rodata

msg_welcome: db "We are running stage 2 code now :D", ENDL, 0
