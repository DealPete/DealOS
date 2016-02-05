;	Created by DealOS BASIC Compiler.

	SECTION .text
	mov ax, str0
	mov [sym1], ax
	mov [sym2], word 10
	mov ax, str1
	mov si, ax
	call print
	mov ah, 0x0E
	mov al, 0x0D
	int 10h
	mov al, 0x0A
	int 10h
	mov ax, [sym1]
	mov si, ax
	call print
	mov ah, 0x0E
	mov al, 0x0D
	int 10h
	mov al, 0x0A
	int 10h
	mov ax, [sym2]
	call intToStr
	call print
	mov ah, 0x0E
	mov al, 0x0D
	int 10h
	mov al, 0x0A
	int 10h
	mov ax, str2
	mov si, ax
	call print
	mov ah, 0x0E
	mov al, 0x0D
	int 10h
	mov al, 0x0A
	int 10h
	jmp $

%include "blib.asm"

	SECTION .data
str0	db	"Hello World", 0
str1	db	"I'm here.", 0
str2	db	"At the end.", 0

	SECTION .bss
sym1: resb 255
sym2: resw 1

heap: