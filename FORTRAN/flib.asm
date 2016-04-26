; IN: ax contains number to convert.
; OUT: bx contains length of string.
;      di contains address of string.

intToStr:
	xor bx, bx
    mov cx, 10      ; int's are base 10
    mov di, heap

.repeat:
	inc bx
    xor dx, dx
    div cx
    add dx, 48
    push dx
    or ax, ax
    jnz .repeat
	mov cx, bx

.write:
    pop ax
    stosb
    loop .write
    mov di, heap
    ret

; IN: si contains string to print.
;     cx contains length of string.

print:
	mov ah, 0Eh

.repeat:
	lodsb
	int 10h
	loop .repeat

.done:
	ret

; IN: ah contains the number of ticks to wait.
; (there are 18.2 ticks/second)

SLEEP:
	push bx

	mov bx, ax
	mov ah, 00h
	int 1Ah
	add bx, dx
.repeat:
	mov ah, 00h
	int 1Ah
	cmp dx, bx
	jl .repeat

	pop bx
	ret
