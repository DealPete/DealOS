[bits 16]

	call enable_a20line
	jmp $

%include "BASIC/blib.asm"
%include "enableA20.asm"

heap:
