[BITS 32]

global ps2kbd_init
global ps2kbd_irq_handler
global ps2kbd_getc_nonblock
global ps2kbd_buffer_count

PS2_KBD_DATA_PORT equ 0x60
KBD_BUF_SIZE equ 64

ps2kbd_init:
	mov byte [ps2kbd_head], 0
	mov byte [ps2kbd_tail], 0
	mov byte [ps2kbd_count], 0
	mov byte [ps2kbd_shift], 0
	xor ah, ah
	ret

ps2kbd_buffer_count:
	movzx eax, byte [ps2kbd_count]
	ret

ps2kbd_push:
	cmp byte [ps2kbd_count], KBD_BUF_SIZE
	jae .full
	movzx ebx, byte [ps2kbd_head]
	mov [ps2kbd_buf + ebx], al
	inc bl
	and bl, (KBD_BUF_SIZE - 1)
	mov [ps2kbd_head], bl
	inc byte [ps2kbd_count]
	xor ah, ah
	ret
.full:
	mov ah, 1
	ret

ps2kbd_getc_nonblock:
	cmp byte [ps2kbd_count], 0
	je .empty
	movzx ebx, byte [ps2kbd_tail]
	mov al, [ps2kbd_buf + ebx]
	inc bl
	and bl, (KBD_BUF_SIZE - 1)
	mov [ps2kbd_tail], bl
	dec byte [ps2kbd_count]
	xor ah, ah
	ret
.empty:
	mov ah, 1
	xor al, al
	ret

ps2kbd_irq_handler:
	push eax
	push ebx

	in al, PS2_KBD_DATA_PORT
	mov bl, al

	; Key release
	test bl, 0x80
	jnz .release

	; Shift press
	cmp bl, 0x2A
	je .set_shift
	cmp bl, 0x36
	je .set_shift

	movzx ebx, bl
	cmp byte [ps2kbd_shift], 0
	je .normal
	mov al, [ps2kbd_ascii_shift + ebx]
	jmp .emit
.normal:
	mov al, [ps2kbd_ascii + ebx]

.emit:
	cmp al, 0
	je .done
	call ps2kbd_push
	jmp .done

.release:
	and bl, 0x7F
	cmp bl, 0x2A
	je .clr_shift
	cmp bl, 0x36
	je .clr_shift
	jmp .done

.set_shift:
	mov byte [ps2kbd_shift], 1
	jmp .done

.clr_shift:
	mov byte [ps2kbd_shift], 0

.done:
	pop ebx
	pop eax
	ret

ps2kbd_head:  db 0
ps2kbd_tail:  db 0
ps2kbd_count: db 0
ps2kbd_shift: db 0
ps2kbd_buf:   times KBD_BUF_SIZE db 0

; Set-1 scancode -> ASCII table (partial but practical).
ps2kbd_ascii:
	db 0, 27, '1','2','3','4','5','6','7','8','9','0','-','=', 8, 9
	db 'q','w','e','r','t','y','u','i','o','p','[',']', 13, 0, 'a','s'
	db 'd','f','g','h','j','k','l',';','''','`', 0, '\\','z','x','c','v'
	db 'b','n','m',',','.','/', 0, '*', 0, ' ', 0
	times (128 - ($ - ps2kbd_ascii)) db 0

ps2kbd_ascii_shift:
	db 0, 27, '!','@','#','$','%','^','&','*','(',')','_','+', 8, 9
	db 'Q','W','E','R','T','Y','U','I','O','P','{','}', 13, 0, 'A','S'
	db 'D','F','G','H','J','K','L',':','"','~', 0, '|','Z','X','C','V'
	db 'B','N','M','<','>','?', 0, '*', 0, ' ', 0
	times (128 - ($ - ps2kbd_ascii_shift)) db 0