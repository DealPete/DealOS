;	Created by DealOS BASIC Compiler.

	SECTION .text
	mov [doffset], word DATA
l10:
	push 7
	mov al, byte 0x20
	mov ah, 0Eh
	int 10h		; space before number...
	pop ax
	call intToStr
	mov si, di
	call print
	mov al, byte 0x20
	mov ah, 0Eh
	int 10h		; ...and space after.
	mov si, str0
	call print
	jmp $

%include "blib.asm"

	SECTION .data
DATA:
str0	db	`\n\r`, 0

	SECTION .bss
doffset: resw 1	; Beginning of data from DATA statements.

heap: