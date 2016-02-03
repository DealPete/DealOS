; IN: si comtains string to print.

print:
	pusha
	mov ah, 0Eh

.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	popa
	ret
