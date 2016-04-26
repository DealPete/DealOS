;	Created by DealOS FORTRAN Compiler.

SECTION .text
	mov word [heap + 0], 5
	mov ax, [heap + 0]
	mov [ID_I], ax
	mov word [heap + 0], 2345
	mov ax, [heap + 0]
	mov [ID_J], ax
	mov ax, [ID_I]
	mov [heap + 2], ax
	mov ax, [ID_J]
	mov [heap + 6], ax
	mov word [heap + 8], 10
	mov ax, [heap + 6]
	add ax, [heap + 8]
	mov [heap + 4], ax
	mov ax, [heap + 2]
	add ax, [heap + 4]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	mov [ID_K], ax
	mov ax, str0
	mov [heap + 0], ax
	mov si, [heap + 0]
	mov cx, 28
	call print
	mov ax, [ID_K]
	mov [heap + 0], ax
	mov ax, [heap + 0]
	call intToStr
	mov si, di
	mov cx, bx
	call print
	jmp $

%include "flib.asm"

SECTION .data

str0	db	"This number should be 2360: "

SECTION .bss

ID_I: resb 2

ID_J: resb 2

ID_K: resb 2

heap:
