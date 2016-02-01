; IN: si comtains string to print.

print:
	pusha
	mov ah, 0Eh

print_repeat:
	lodsb
	cmp al, 0
	je print_done
	int 10h
	jmp print_repeat

print_done:
	popa
	ret
