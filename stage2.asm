[bits 16]

	call enable_a20line
	call setupGDT
	jmp 0x08:PModeMain

PModeMain:
	mov si, diag
	call print
	mov [0xb8000], dword 0x07690748
	jmp $

%include "BASIC/blib.asm"
%include "enableA20.asm"
%include "setupGDT.asm"

diag	db "Hey! I'm here.", 0
heap:
