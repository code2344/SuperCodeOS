; TUI for CircleOS - SphereTUI
; Provides a simple text-based user interface for file browsing and program launching
; CEX1 VERSION 1

[BITS 16]           ; 16-bit real mode assembly
[ORG 0xA000]        ; load address for user programs

SYSCALL_INT equ 0x80
SYS_PUTC equ 0x01
SYS_PUTS equ 0x02
SYS_NEWLINE equ 0x03
SYS_GETC equ 0x04
SYS_FS_READ equ 0x09
SYS_FS_LIST equ 0x0B
SYS_CLEAR equ 0x05

start:
    mov ax, 0           ; zero AX for data segment setup
    mov ds, ax          ; point DS to segment 0 for message access
    mov es, ax          ; point ES to segment 0 for any file read buffers
    mov ah, SYS_CLEAR        ; clear the screen before showing TUI
    int SYSCALL_INT


