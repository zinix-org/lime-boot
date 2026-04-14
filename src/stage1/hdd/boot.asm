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

;
; IBM's El Torito Emulation tries to fix up the BPB values if they don't look
; like regular values for a disk.
;
; Source: https://github.com/freebsd/freebsd-src/blob/master/stand/i386/boot2/boot1.S
;
bdb:
.oem_id:                db "LIMEBOOT"
.sector_size:           dw 512
.sectors_per_cluster:   db 0
.reserved_sectors:      dw 0
.fat_count:             db 0
.root_entries:          dw 0
.sector_count:          dw 0
.media_type:            db 0
.sectors_per_fat:       dw 0
.sectors_per_track:     dw 18   ; requied for thinkpads
.head_count:            dw 2    ; requied for thinkpads
.hidden_sector_count:   dd 0
.large_sector_count:    dd 0
ebr:
.drive_number:          db 0
                        db 0    ; reserved
.signature:             db 0
.volume_id:             db 0x12, 0x34, 0x56, 0x78
.volume_label:          db "LIMEBOOT   "
.filesystem_id:         db "        "   ; invalid FAT partition

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
