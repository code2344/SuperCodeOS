[BITS 32]

global ps2c_init
global ps2c_read_data
global ps2c_write_data
global ps2c_write_mouse_data
global ps2c_read_status

; Minimal PS/2 controller driver for i8042-compatible hardware.

PS2_DATA_PORT    equ 0x60
PS2_STATUS_PORT  equ 0x64
PS2_CMD_PORT     equ 0x64

PS2_ST_OUT_FULL  equ 0x01
PS2_ST_IN_FULL   equ 0x02

ps2c_wait_write_ready:
	push ecx
	mov ecx, 100000
.w_loop:
	in al, PS2_STATUS_PORT
	test al, PS2_ST_IN_FULL
	jz .w_ok
	dec ecx
	jnz .w_loop
	stc
	pop ecx
	ret
.w_ok:
	clc
	pop ecx
	ret

ps2c_wait_read_ready:
	push ecx
	mov ecx, 100000
.r_loop:
	in al, PS2_STATUS_PORT
	test al, PS2_ST_OUT_FULL
	jnz .r_ok
	dec ecx
	jnz .r_loop
	stc
	pop ecx
	ret
.r_ok:
	clc
	pop ecx
	ret

ps2c_read_status:
	in al, PS2_STATUS_PORT
	ret

ps2c_read_data:
	call ps2c_wait_read_ready
	jc .rd_fail
	in al, PS2_DATA_PORT
	xor ah, ah
	ret
.rd_fail:
	mov ah, 1
	xor al, al
	ret

ps2c_write_data:
	; AL = byte
	push eax
	call ps2c_wait_write_ready
	jc .wd_fail
	pop eax
	out PS2_DATA_PORT, al
	xor ah, ah
	ret
.wd_fail:
	pop eax
	mov ah, 1
	ret

ps2c_write_mouse_data:
	; AL = byte
	push eax
	call ps2c_wait_write_ready
	jc .wm_fail
	mov al, 0xD4
	out PS2_CMD_PORT, al
	call ps2c_wait_write_ready
	jc .wm_fail2
	pop eax
	out PS2_DATA_PORT, al
	xor ah, ah
	ret
.wm_fail2:
	pop eax
.wm_fail:
	mov ah, 1
	ret

ps2c_init:
	; Disable both PS/2 ports.
	call ps2c_wait_write_ready
	jc .fail
	mov al, 0xAD
	out PS2_CMD_PORT, al

	call ps2c_wait_write_ready
	jc .fail
	mov al, 0xA7
	out PS2_CMD_PORT, al

	; Flush output buffer if needed.
	in al, PS2_STATUS_PORT
	test al, PS2_ST_OUT_FULL
	jz .cfg
	in al, PS2_DATA_PORT

.cfg:
	; Read controller config byte.
	call ps2c_wait_write_ready
	jc .fail
	mov al, 0x20
	out PS2_CMD_PORT, al

	call ps2c_wait_read_ready
	jc .fail
	in al, PS2_DATA_PORT
	and al, 0xBC
	or al, 0x03

	; Write controller config byte.
	push eax
	call ps2c_wait_write_ready
	jc .fail_pop
	mov al, 0x60
	out PS2_CMD_PORT, al
	call ps2c_wait_write_ready
	jc .fail_pop
	pop eax
	out PS2_DATA_PORT, al

	; Enable ports.
	call ps2c_wait_write_ready
	jc .fail
	mov al, 0xAE
	out PS2_CMD_PORT, al
	call ps2c_wait_write_ready
	jc .fail
	mov al, 0xA8
	out PS2_CMD_PORT, al

	; Enable keyboard scanning.
	mov al, 0xF4
	call ps2c_write_data

	; Enable mouse streaming.
	mov al, 0xF4
	call ps2c_write_mouse_data

	xor ah, ah
	ret

.fail_pop:
	pop eax
.fail:
	mov ah, 1
	ret