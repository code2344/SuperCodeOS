; mem.asm
; Shared low-level memory helper routines.

[BITS 32]

global mem_set
global mem_copy
global mem_zero
global mem_cmp
global mem_move

section .text

mem_set:
    mov eax, edi
    test ecx, ecx
    jz .done
    cld
    rep stosb
.done:
    ret

mem_zero:
    xor al, al
    jmp mem_set

mem_copy:
    mov eax, edi
    test ecx, ecx
    jz .done
    cld
    rep movsb
.done:
    ret

mem_move:
    mov eax, edi
    test ecx, ecx
    jz .done
    cmp edi, esi
    je .done

    ; if dest < src, forward copy is safe
    jb .forward

    ; if dest >= src + len, forward copy is safe
    mov edx, esi
    add edx, ecx
    cmp edi, edx
    jae .forward

    ; overlapping and dest > src: copy backward
    std
    lea esi, [esi + ecx - 1]
    lea edi, [edi + ecx - 1]
    rep movsb
    cld
    ret

.forward:
    cld
    rep movsb
.done:
    ret

; mem_cmp
; IN: ESI=a, EDI=b, ECX=len
; OUT: EAX=0 equal, EAX=1 different
mem_cmp:
    xor eax, eax
    test ecx, ecx
    jz .eq
    cld
    repe cmpsb
    je .eq
    mov eax, 1
.eq:
    ret