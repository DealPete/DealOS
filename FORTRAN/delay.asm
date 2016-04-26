;	Created by DealOS FORTRAN Compiler.

SECTION .text
	mov byte [ID_t0], 20
	mov ax, [ID_t0]
	push ax
	call DELAY
	mov ax, str0
	mov [ID_t0], ax
	mov si, [ID_t0]
	mov cx, 14
	call print
	jmp $

DELAY:
	pop ax
	mov [ID_NSEC], ax
	mov ax, [ID_NSEC]
	mov [ID_t0], ax
	mov ax, [ID_t0]
	push ax
	call SLEEP
	ret

%include "flib.asm"

SECTION .data

str0	db	"Done delaying."

SECTION .bss

ID_NSEC: resb 2
ID_t0: resb 2

heap:
