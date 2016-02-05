; IN: si comtains string to print.

print:
	mov ah, 0Eh

.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	ret

; IN: ax contains number to convert.
; OUT: si contains address of string.

intToStr:
	mov bx, 10		; int's are base 10
	mov di, heap
	mov si, di
	push 0		 	; null-terminate string

.repeat:
	cmp ax, 0
	je .write
	xor dx, dx
	div bx
	add dx, 48
	push dx
	jmp .repeat

.write:
	pop ax
	cmp ax, 0
	je .done
	stosb
	jmp .write

.done:
	ret
