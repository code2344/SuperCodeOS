; ringbuf.asm
; Shared ring buffer implementation for IRQ-driven devices.

[BITS 32]

global ringbuf_init
global ringbuf_is_empty
global ringbuf_is_full
global ringbuf_count
global ringbuf_push8
global ringbuf_pop8
global ringbuf_clear

%define RB_DATA 0
%define RB_SIZE 4
%define RB_HEAD 8
%define RB_TAIL 12
%define RB_COUNT 16

section .text

ringbuf_init:
    cmp esi, 0
    je .bad
    cmp edi, 0
    je .bad
    cmp ecx, 2
    jb .bad

    mov [esi + RB_DATA], edi
    mov [esi + RB_SIZE], ecx
    mov dword [esi + RB_HEAD], 0
    mov dword [esi + RB_TAIL], 0
    mov dword [esi + RB_COUNT], 0

    xor ah, ah ; set return value to 0 (success)
    ret
.bad:
    mov ah, 1          ; error code 1 = invalid argument
    ret

ringbuf_is_empty:
    mov eax, [esi + RB_COUNT]
    test eax, eax
    jz .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1
    ret

ringbuf_is_full:
    mov eax, [esi + RB_COUNT]
    cmp eax, [esi + RB_SIZE]
    je .yes
    xor eax, eax
    ret
.yes:
    mov eax, 1       ; return 1 if full
    ret

ringbuf_count:
    mov eax, [esi + RB_COUNT]
    ret

ringbuf_push8:
    push ebx
    push ecx
    push edx

    mov dl, al ; save byte
    mov ecx, [esi + RB_COUNT]
    cmp ecx, [esi + RB_SIZE]
    jae .full

    mov ecx, [esi + RB_HEAD]
    mov ebx, [esi + RB_DATA]
    mov [ebx + ecx], dl
    inc ecx
    cmp ecx, [esi + RB_SIZE]
    jb .head_ok
    xor ecx, ecx
.head_ok:
    mov [esi + RB_HEAD], ecx
    inc dword [esi + RB_COUNT]
    pop edx
    pop ecx
    pop ebx
    ret
.full:
    pop edx
    pop ecx
    pop ebx
    ret

ringbuf_pop8:
    push ebx
    push ecx

    mov ecx, [esi + RB_COUNT]
    test ecx, ecx
    jz .empty

    mov ecx, [esi + RB_TAIL]    ; index = tail
    mov ebx, [esi + RB_DATA]
    mov al, [ebx + ecx]         ; read byte at tail

    inc ecx
    cmp ecx, [esi + RB_SIZE]
    jb .tail_ok
    xor ecx, ecx
.tail_ok:
    mov [esi + RB_TAIL], ecx
    dec dword [esi + RB_COUNT]

    xor ah, ah ; success
    jmp .done
.empty:
    xor al, al ; return 0 if empty
    mov ah, 1  ; error code 1 = empty
.done:
    pop ecx
    pop ebx
    ret

ringbuf_clear:
    mov dword [esi + RB_HEAD], 0
    mov dword [esi + RB_TAIL], 0
    mov dword [esi + RB_COUNT], 0
    ret

