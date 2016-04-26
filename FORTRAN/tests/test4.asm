;	Created by DealOS FORTRAN Compiler.

SECTION .text
	mov word [heap + 0], 5
	mov ax, [heap + 0]
	mov [ID_M], ax
	mov word [heap + 0], 20
	mov ax, [heap + 0]
	mov [ID_N], ax
	push bp
	mov bp, sp
	mov ax, [ID_M]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	push ax
	mov ax, [ID_N]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	push ax
	call ADD
	add sp, 4
	pop bp
	jmp $

ADD:
	mov ax, [bp - 2]
	mov [heap + 2], ax
	mov ax, [bp - 4]
	mov [heap + 4], ax
	mov ax, [heap + 2]
	add ax, [heap + 4]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	mov [bp - 4], ax
	mov ax, [bp - 4]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	call intToStr
	mov si, di
	mov cx, bx
	call print
	ret

%include "flib.asm"

SECTION .data


SECTION .bss

ID_M: resb 2
ID_N: resb 2

heap:
