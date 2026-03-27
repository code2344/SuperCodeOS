[BITS 32]

extern ps2c_init
extern ps2kbd_init
extern ps2kbd_irq_handler
extern ps2kbd_getc_nonblock
extern ps2mouse_init
extern ps2mouse_irq_handler
extern ps2mouse_get_state

global input_init
global input_irq1
global input_irq12
global input_getc_nonblock
global input_mouse_state

input_init:
	call ps2c_init
	call ps2kbd_init
	call ps2mouse_init
	ret

input_irq1:
	call ps2kbd_irq_handler
	ret

input_irq12:
	call ps2mouse_irq_handler
	ret

input_getc_nonblock:
	call ps2kbd_getc_nonblock
	ret

input_mouse_state:
	call ps2mouse_get_state
	ret