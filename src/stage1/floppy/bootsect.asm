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


%define ENDL 0x0D, 0x0A
%define STAGE2_LOAD_SEGMENT 0
%define STAGE2_LOAD_OFFSET 0x9E00


section .bpb

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


section .text

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
    mov si, msg_loading
    call puts

    ; we excpect DL to be the drive number
    mov [ebr.drive_number], dl

    ; load the FAT into memory
    mov ax, [bdb.reserved_sectors]
    mov bx, fat_buffer
    mov cl, [bdb.sectors_per_fat]
    mov dl, [ebr.drive_number]
    call disk_read

    mov bx, STAGE2_LOAD_SEGMENT
    mov bx, es
    mov bx, STAGE2_LOAD_OFFSET

    mov ax, [stage2_cluster]
    mov [temp_stage2_cluster], ax

.load_stage2_loop:
    mov ax, [temp_stage2_cluster]

    add ax, 31          ; so it happends that i am way too lazy and stupid to
                        ; calulate this myself. TODO i guess
                        ;
                        ; it is basically just cuz temp_stage2_cluster is
                        ; inside the data region but we want the LBA to be on
                        ; the disk itself
    
    mov cl, 1
    mov dl, [ebr.drive_number]
    call disk_read

    add bx, [bdb.sector_size]

    ; compute LBA of next cluster
    mov ax, [temp_stage2_cluster]
    mov cx, 3
    mul cx                          ; AX = temp_stage2_cluster * 3
    mov cx, 2
    div cx

    mov si, fat_buffer
    add si, ax
    mov ax, [ds:si]

    or dx, dx
    jz .even

.odd:
    shr ax, 4
    jmp .next_cluster_after

.even:
    and ax, 0xFFF

.next_cluster_after:
    cmp ax, 0xFF8
    jae .read_finish

    mov [temp_stage2_cluster], ax
    jmp .load_stage2_loop

.read_finish:
    mov dl, [ebr.drive_number]

    mov ax, STAGE2_LOAD_SEGMENT
    mov ds, ax
    mov es, ax

    jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET

    jmp wait_key_and_reboot
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


;
; convert LBA to CHS address
; parameters:
;   - AX: logical block address
; returns:
;   - CX [bits 0-5]: sector number
;   - CX [bits 6-15]: cylinder
;   - DH: head
;
lba_to_chs:
    push ax
    push dx

    xor dx, dx

    div word [bdb.sectors_per_track]    ; AX = LBA / sectors per track
                                        ; DX = LBA % sectors per track

    inc dx                              ; DX = DX + 1 which is the sector
    mov cx, dx                          ; now CX has the sector

    xor dx, dx

    div word [bdb.head_count]           ; AX = AX / head count which is cylinder
                                        ; DX = AX % head count which is head

    ; AX = cylinder
    ; DX = head
    ; CX = sector

    mov dh, dl

    ; CX =       ---CH--- ---CL---
    ; cylinder : 76543210 98
    ; sector   :            543210

    mov ch, al

    ; now set the weird 2 bits
    ; AH before (from AX) : 0 0 0 0 0 0 9 8 <- the 9 and 8 are bits not numbers but bits
    ; AH after            : 9 8 0 0 0 0 0 0
    shl ah, 6

    or cl, ah       ; now OR it with cl which already contains the sector number (from cx)

    pop ax
    mov dl, al      ; restore DL, and not DH (the head)
    pop ax
    ret


;
; read sectors from a floppy
; parameters:
;   - AX: logical block address
;   - CL: sector count
;   - DL: drive number
;   - es:bx: memory buffer
;
disk_read:
    pusha

    push cx
    call lba_to_chs
    pop ax

    ; AL now has the sector count and CX has sector number and cylinder

    mov ah, 0x2
    mov di, 3           ; retry count

.retry:
    pusha
    stc

    int 0x13
    jnc .done

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    jmp disk_error

.done:
    popa

    popa
    ret


;
; reset the disk controller
; parameters:
;   - DL: drive number
;
disk_reset:
    pusha

    mov ah, 0
    stc
    int 0x13
    jc disk_error

    popa
    ret


disk_error:
    mov si, msg_disk_error
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h             ; wait for keypress
    jmp 0xFFFF:0        ; beginning of BIOS code


section .rodata
msg_loading: db "Loading...", ENDL, 0
msg_disk_error: db "DISK READ ERROR!", ENDL, 0
msg_hi: db "Hi :D", ENDL, 0

section .data
global stage2_cluster
stage2_cluster: dw 0        ; should be set by install tool

temp_stage2_cluster: dw 0   ; cluster inside data region
temp_root_dir_end: dw 0

section .bss
fat_buffer: resb 8 * 1024
