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


%define ENDL 0x0D, 0x0A


jmp short _start
nop

bdb:
.oem_id:                db "LIMEBOOT"               ; 8 bytes        
.sector_size:           dw 512
.sectors_per_cluster:   db 1
.reserved_sectors:      dw 1
.fat_count:             db 2
.root_entries:          dw 0xE0
.sector_count:          dw 2880                     ; 2880 * 512 = 1.44 MB
.media_type:            db 0xF0                     ; 0xF0 = 3.5" floppy disk
.sectors_per_fat:       dw 9
.sectors_per_track:     dw 18
.head_count:            dw 2
.hidden_sector_count:   dd 0
.large_sector_count:    dd 0
ebr:
.drive_number:          db 0                        ; 0x00 = first floppy disk, this is temporary and machine-specific
                        db 0                        ; reserved
.signature:             db 0x29
.volume_id:             db 0x12, 0x34, 0x56, 0x78   ; serial number
.volume_label:          db "LIMEBOOT   "            ; 11 bytes
.filesystem_id:         db "FAT12   "               ; 8 bytes

_start:
    cli
    cld

    ; setup data segments
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00      ; the stack grows downwards from where we are loaded

    sti

    ; make sure we run at 0000:7C00 (some BIOSes might put is at 07C0:0000)
    push es
    push word .continue
    retf

.continue:
    ; we excpect DL to be the drive number
    mov [ebr.drive_number], dl

    mov si, msg_loading
    call puts

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


msg_loading: db "Loading...", ENDL, 0


times 508-($-$$) db 0
stage2_lba: dw 0x0      ; should be set by install tool

times 510-($-$$) db 0
dw 0xAA55
