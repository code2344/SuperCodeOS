[BITS 32]

extern vga_text_init
extern vga_text_set_color
extern vga_text_clear
extern vga_text_putc
extern vga_text_puts
extern vga_text_newline

global drv_console_init
global drv_console_clear
global drv_console_putc
global drv_console_puts
global drv_console_newline
global drv_console_set_color
global drv_console_write_line

drv_console_init:
	call vga_text_init
	ret

drv_console_clear:
	call vga_text_clear
	ret

drv_console_putc:
	; AL = char
	call vga_text_putc
	ret

drv_console_puts:
	; ESI = string
	call vga_text_puts
	ret

drv_console_newline:
	call vga_text_newline
	ret

drv_console_set_color:
	; AL = attr
	call vga_text_set_color
	ret

drv_console_write_line:
	; ESI = string
	call vga_text_puts
	call vga_text_newline
	ret