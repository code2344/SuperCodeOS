; ports.asm
; Shared port I/O helper routines and constants.
; calling convention: port number in dx, value in al/ax/eax for out instructions, return value in al/ax/eax for in instructions.

[BITS 32]

global port_in8
global port_in16
global port_in32
global port_out8
global port_out16
global port_out32
global io_wait

section .text

port_in8:
    in al, dx
    ret

port_in16:
    in ax, dx
    ret

port_in32:
    in eax, dx
    ret

port_out8:
    out dx, al
    ret

port_out16:
    out dx, ax
    ret

port_out32:
    out dx, eax
    ret

io_wait:
    push eax
    xor al, al
    out 0x80, al
    pop eax
    ret