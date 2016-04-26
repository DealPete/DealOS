;	Created by DealOS FORTRAN Compiler.

SECTION .text
	mov word [heap + 2], 12
	mov word [heap + 4], 13
	mov ax, [heap + 2]
	add ax, [heap + 4]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	mov [ID_J], ax
	mov ax, [ID_J]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	call intToStr
	mov si, di
	mov cx, bx
	call print
	jmp $

%include "flib.asm"

SECTION .data

SECTION .bss

ID_J: resb 2

heap:
