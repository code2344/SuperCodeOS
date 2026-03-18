; ls.asm - List available programs
; Lists all programs from program table

bits 16
org 0xA000

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Print header
    mov si, msg_header
    call sys_puts

    ; Program table is at kernel-known address 0x0600
    mov di, 0x0600
    
    ; Get entry count
    mov al, [di + 4]
    xor cx, cx

.list_loop:
    cmp cl, al
    jae .done

    ; Calculate entry offset: base(0x0600) + 16 + (index * 16)
    xor ax, ax
    mov ah, cl
    shl ax, 4
    mov bx, di
    add bx, 16          ; skip header
    add bx, ax          ; add index offset

    ; Print program name (first 8 bytes of entry)
    mov si, bx
    call print_name_8bytes
    
    ; Print newline
    mov si, msg_newline
    call sys_puts

    inc cl
    jmp .list_loop

.done:
    ret

; Print exactly 8 bytes or until first null
print_name_8bytes:
    xor cx, cx
.name_loop:
    cmp cx, 8
    jae .name_done
    
    lodsb
    cmp al, 0
    je .name_done
    call sys_putc_char
    
    inc cx
    jmp .name_loop
.name_done:
    ret

; Syscall: putc
sys_putc_char:
    mov ah, al
    xor ax, ax
    mov al, ah
    mov ah, 0           ; SYS_PUTC
    int 0x80
    ret

; Syscall: puts
sys_puts:
    mov ah, 1           ; SYS_PUTS
    int 0x80
    ret

msg_header:
    db "Available programs:", 0x0A, 0
msg_newline:
    db 0x0A, 0
