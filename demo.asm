; demo.asm
; Tiny runnable program loaded by kernel SYS_RUN

[BITS 16]
[ORG 0xA000]

SYSCALL_INT equ 0x80
SYS_PUTS equ 0x02
SYS_NEWLINE equ 0x03

start:
    mov ax, 0
    mov ds, ax

    mov si, demo_msg
    mov ah, SYS_PUTS
    int SYSCALL_INT

    mov ah, SYS_NEWLINE
    int SYSCALL_INT

    ret

demo_msg:
    db "demo program executed", 0
