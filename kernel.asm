; kernel.asm
; CircleOS kernel - a simple shell with basic commands.

[BITS 16]           ; assemble these instructions for 16-bit mode
[ORG 0x7E00]        ; this code lives at 0x7e00

start:
    mov ax, 0           ; clear register AX temporarily to initialise segment registers
    mov ds, ax          ; clear and initialise data segment
    mov es, ax          ; clear and initialise extra segment

    mov si, boot_msg    ; move boot message to source
    call print_string   ; calls print string (prints SI)


; begin main shell loop
.shell_loop:
    mov si, prompt      ; move prompt (arcsh >)
    call print_string   ; print prompt

    ; read command from keyboard
    xor cx, cx          ; cx=0, start at first byte
    mov bx, command_buf ; bx points to command buffer start

.read_loop:
    mov ah, 0x00        ; bios wait for key press and return 
    int 0x16            ; bios interrupt to return key press
    
    ; check for enter key
    cmp al, 13          ; key press goes into AL for the ascii code, ascii code of carriage return is 13 or 0D
    je .command_ready   ; enter means command is finished, so jump to command execution

    cmp al, 8           ; check for backspace character
    je .backspace       ; jump if ZF is set, if AL = 8 then the previous line set ZF so jump to .backspace jump target

    ; print character via BIOS TTY by running int 10 and setting AH to 0E
    mov ah, 0x0E
    int 0x10

    ; store typed character in command buffer at [BX+CX], bx is base and cx is index
    mov byte [bx + cx], al
    inc cx

    ; limit input length to 32 bytes
    cmp cx, 32
    jl .read_loop

    ; if at or over 32 keep reading but ignore storage
    jmp .read_loop

.backspace:
    cmp cx, 0           ; is the cursor already at the start?
    je .read_loop       ; if yes, exit backspace loop and go to read loop

    mov ah, 0x0E
    mov al, 8           ; ASCII backspace
    int 0x10
    mov al, ' '         ; print ' ' to cover/erase old character
    int 0x10
    mov al, 8           ; backspace again :)
    int 0x10

    dec cx
    jmp .read_loop

.command_ready:




