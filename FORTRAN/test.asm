;	Created by DealOS FORTRAN Compiler.

SECTION .text
	mov word [ID_t0], 5
	mov ax, [ID_t0]
	mov [ID_M], ax
	mov word [ID_t0], 20
	mov ax, [ID_t0]
	mov [ID_N], ax
	mov ax, [ID_M]
	mov [ID_t1], ax
	mov ax, [ID_N]
	mov [ID_t2], ax
	mov ax, [ID_t1]
	add ax, [ID_t2]
	mov [ID_t0], ax
	mov ax, [ID_t0]
	mov [ID_N], ax
	mov ax, [ID_N]
	mov [ID_t0], ax
	mov ax, [ID_t0]
	call intToStr
	mov si, di
	mov cx, bx
	call print
	jmp $

%include "flib.asm"

SECTION .data


SECTION .bss

ID_t0: resb 2
ID_M: resb 2
ID_N: resb 2
ID_t1: resb 2
ID_t2: resb 2

heap:
