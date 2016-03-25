[bits 16]

	call enable_a20line
	hlt


%include "BASIC/blib.asm"
%include "enableA20.asm"

heap:
