[BITS 32]

extern vga_text_init
extern vga_text_clear
extern vga_text_putc
extern vga_text_puts
extern vga_text_set_color
extern vga_fb_set_base
extern vga_fb_clear8
extern vga_fb_putpixel8

global gfx_init
global gfx_text_clear
global gfx_text_putc
global gfx_text_puts
global gfx_text_set_color
global gfx_fb_set_base
global gfx_fb_clear8
global gfx_fb_putpixel8

gfx_init:
	call vga_text_init
	ret

gfx_text_clear:
	call vga_text_clear
	ret

gfx_text_putc:
	call vga_text_putc
	ret

gfx_text_puts:
	call vga_text_puts
	ret

gfx_text_set_color:
	call vga_text_set_color
	ret

gfx_fb_set_base:
	call vga_fb_set_base
	ret

gfx_fb_clear8:
	call vga_fb_clear8
	ret

gfx_fb_putpixel8:
	call vga_fb_putpixel8
	ret