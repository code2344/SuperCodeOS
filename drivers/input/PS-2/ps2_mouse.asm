[BITS 32]

global ps2mouse_init
global ps2mouse_irq_handler
global ps2mouse_get_state

PS2_MOUSE_DATA_PORT equ 0x60

ps2mouse_init:
	mov byte [ps2mouse_idx], 0
	mov dword [ps2mouse_x], 40
	mov dword [ps2mouse_y], 12
	mov byte [ps2mouse_buttons], 0
	xor ah, ah
	ret

ps2mouse_irq_handler:
	push eax
	push ebx
	push ecx
	push edx

	in al, PS2_MOUSE_DATA_PORT
	movzx ebx, byte [ps2mouse_idx]
	mov [ps2mouse_pkt + ebx], al
	inc bl
	cmp bl, 3
	jb .save_idx

	; Parse complete 3-byte packet.
	mov byte [ps2mouse_idx], 0

	mov al, [ps2mouse_pkt + 0]
	and al, 0x07
	mov [ps2mouse_buttons], al

	movsx ecx, byte [ps2mouse_pkt + 1]
	movsx edx, byte [ps2mouse_pkt + 2]

	add dword [ps2mouse_x], ecx
	sub dword [ps2mouse_y], edx

	; Clamp to 80x25 logical text grid.
	cmp dword [ps2mouse_x], 0
	jge .x_hi
	mov dword [ps2mouse_x], 0
.x_hi:
	cmp dword [ps2mouse_x], 79
	jle .y_lo
	mov dword [ps2mouse_x], 79
.y_lo:
	cmp dword [ps2mouse_y], 0
	jge .y_hi
	mov dword [ps2mouse_y], 0
.y_hi:
	cmp dword [ps2mouse_y], 24
	jle .done
	mov dword [ps2mouse_y], 24
	jmp .done

.save_idx:
	mov [ps2mouse_idx], bl

.done:
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

ps2mouse_get_state:
	; EAX=x, EBX=y, CL=buttons
	mov eax, [ps2mouse_x]
	mov ebx, [ps2mouse_y]
	mov cl, [ps2mouse_buttons]
	ret

ps2mouse_idx:     db 0
ps2mouse_pkt:     times 3 db 0
ps2mouse_buttons: db 0
ps2mouse_x:       dd 0
ps2mouse_y:       dd 0