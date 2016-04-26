;	Created by DealOS FORTRAN Compiler.

SECTION .text
	push bp
	mov bp, sp
	call THESUB
	add sp, 0
	pop bp
	jmp $

THESUB:
	mov ax, str0
	mov [heap + 0], ax
	mov si, [heap + 0]
	mov cx, 3
	call print
	ret

%include "flib.asm"

SECTION .data

str0	db	"HEY"

SECTION .bss

ID_I: resb 2

ID_J: resb 2

heap:
