[BITS 32]

global vga_text_init
global vga_text_set_color
global vga_text_clear
global vga_text_putc
global vga_text_puts
global vga_text_newline
global vga_text_set_cursor

VGA_TEXT_BASE equ 0xB8000
VGA_COLS equ 80
VGA_ROWS equ 25

vga_text_init:
	mov byte [vga_attr], 0x0F
	mov byte [vga_x], 0
	mov byte [vga_y], 0
	ret

vga_text_set_color:
	; AL = attribute byte (bg<<4|fg)
	mov [vga_attr], al
	ret

vga_text_set_cursor:
	; BL = x, BH = y
	mov [vga_x], bl
	mov [vga_y], bh
	ret

vga_text_clear:
	push eax
	push ecx
	push edi
	mov edi, VGA_TEXT_BASE
	mov al, ' '
	mov ah, [vga_attr]
	mov ecx, VGA_COLS * VGA_ROWS
	rep stosw
	mov byte [vga_x], 0
	mov byte [vga_y], 0
	pop edi
	pop ecx
	pop eax
	ret

vga_text_newline:
	mov byte [vga_x], 0
	inc byte [vga_y]
	cmp byte [vga_y], VGA_ROWS
	jb .ok
	mov byte [vga_y], VGA_ROWS - 1
.ok:
	ret

vga_text_putc:
	; AL = ASCII
	cmp al, 13
	je .cr
	cmp al, 10
	je .lf
	cmp al, 8
	je .bs

	push eax
	push ebx
	push edi

	movzx ebx, byte [vga_y]
	imul ebx, VGA_COLS
	movzx edi, byte [vga_x]
	add edi, ebx
	shl edi, 1
	add edi, VGA_TEXT_BASE

	pop edi
	pop ebx
	pop eax
	mov ah, [vga_attr]
	mov [edi], ax

	inc byte [vga_x]
	cmp byte [vga_x], VGA_COLS
	jb .out
	mov byte [vga_x], 0
	inc byte [vga_y]
	cmp byte [vga_y], VGA_ROWS
	jb .out
	mov byte [vga_y], VGA_ROWS - 1

.out:
	ret

.cr:
	mov byte [vga_x], 0
	ret
.lf:
	call vga_text_newline
	ret
.bs:
	cmp byte [vga_x], 0
	je .bs_out
	dec byte [vga_x]
.bs_out:
	ret

vga_text_puts:
	; ESI -> null-terminated string
	push eax
.loop:
	mov al, [esi]
	cmp al, 0
	je .done
	call vga_text_putc
	inc esi
	jmp .loop
.done:
	pop eax
	ret

vga_attr: db 0x0F
vga_x:    db 0
vga_y:    db 0