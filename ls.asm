; ls.asm - List available programs
; Lists all programs from program table

bits 16
org 0xA000

SYSCALL_INT equ 0x80
SYS_PUTC equ 0x01
SYS_PUTS equ 0x02

start:
    mov ax, cs
    mov ds, ax
    xor ax, ax
    mov es, ax

    ; Print header
    mov si, msg_header
    call sys_puts

    ; Program table is at kernel-known address 0x0600
    ; Keep loop state in memory because syscalls may clobber registers.
    mov byte [entry_index], 0
    mov al, [es:0x0604]
    mov [entry_count], al

.list_loop:
    mov al, [entry_index]
    cmp al, [entry_count]
    jae .done

    ; Calculate entry offset: base(0x0600) + 16 + (index * 16)
    xor ax, ax
    mov al, [entry_index]
    shl ax, 4
    mov bx, 0x0600
    add bx, 16          ; skip header
    add bx, ax          ; add index offset

    ; Print program name (first 8 bytes of entry)
    call print_name_8bytes
    
    ; Print newline
    mov si, msg_newline
    call sys_puts

    inc byte [entry_index]
    jmp .list_loop

.done:
    ret

; Print exactly 8 bytes or until first null
print_name_8bytes:
    xor dx, dx
.name_loop:
    cmp dx, 8
    jae .name_done

    mov al, [es:bx]
    cmp al, 0
    je .name_done
    call sys_putc_char

    inc bx
    inc dx
    jmp .name_loop
.name_done:
    ret

; Syscall: putc
sys_putc_char:
    mov ah, SYS_PUTC
    int SYSCALL_INT
    ret

; Syscall: puts
sys_puts:
    mov ah, SYS_PUTS
    int SYSCALL_INT
    ret

msg_header:
    db "Available programs:", 13, 10, 0
msg_newline:
    db 13, 10, 0

entry_count:
    db 0
entry_index:
    db 0
