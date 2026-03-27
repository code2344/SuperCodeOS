[BITS 32]

global vga_fb_set_base
global vga_fb_clear8
global vga_fb_putpixel8
global vga_fb_blit8

; Default Mode 13h linear framebuffer assumptions (320x200, 8bpp).
vga_fb_set_base:
	; EAX = framebuffer base
	mov [vga_fb_base], eax
	ret

vga_fb_clear8:
	; AL = color
	push eax
	push ecx
	push edi
	mov edi, [vga_fb_base]
	mov ecx, 320 * 200
	rep stosb
	pop edi
	pop ecx
	pop eax
	ret

vga_fb_putpixel8:
	; EAX = x, EBX = y, CL = color
	push edx
	push edi
	cmp eax, 320
	jae .px_out
	cmp ebx, 200
	jae .px_out

	mov edx, ebx
	imul edx, 320
	add edx, eax
	mov edi, [vga_fb_base]
	add edi, edx
	mov [edi], cl

.px_out:
	pop edi
	pop edx
	ret

vga_fb_blit8:
	; ESI=src, EAX=dst_x, EBX=dst_y, EDX=width, EDI=height
	mov [blit_src], esi
	mov [blit_x], eax
	mov [blit_y], ebx
	mov [blit_w], edx
	mov [blit_h], edi

	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	xor edi, edi
.row_loop:
	cmp edi, [blit_h]
	jae .done
	xor ecx, ecx
.col_loop:
	cmp ecx, [blit_w]
	jae .next_row

	mov eax, [blit_x]
	add eax, ecx
	mov ebx, [blit_y]
	add ebx, edi
	cmp eax, 320
	jae .skip
	cmp ebx, 200
	jae .skip

	mov edx, ebx
	imul edx, 320
	add edx, eax
	mov eax, [vga_fb_base]
	add eax, edx
	mov esi, [blit_src]
	mov ebx, [blit_w]
	imul ebx, edi
	add ebx, ecx
	add esi, ebx
	mov bl, [esi]
	mov [eax], bl

.skip:
	inc ecx
	jmp .col_loop

.next_row:
	inc edi
	jmp .row_loop

.done:
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

vga_fb_base: dd 0xA0000
blit_src:    dd 0
blit_x:      dd 0
blit_y:      dd 0
blit_w:      dd 0
blit_h:      dd 0