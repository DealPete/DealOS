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
; OUT: di contains address of string.

intToStr:
	mov cx, 10		; int's are base 10
	mov di, heap
	push 0		 	; null-terminate string

.repeat:
	xor dx, dx
	div cx
	add dx, 48
	push dx
	or ax, ax
	jnz .repeat

.write:
	pop ax
	stosb
	or ax, ax
	je .done
	jmp .write

.done:
	mov di, heap
	ret

; IN: si contains address of string to convert.
; OUT: ax contains number.

strToInt:
	push bx
	mov bx, 10
	xor cx, cx
	xor dx, dx

.repeat:
	lodsb
	cmp al, 0
	je .done
	cmp al, 48		; ascii 48 is '0'
	jl .repeat
	cmp al, 57		; ascii 57 is '9'
	jg .repeat
	mov cl, al
	mov ax, dx
	mul bx
	sub cl, 48
	add ax, cx
	mov dx, ax
	jmp .repeat

.done:
	pop bx
	mov ax, dx
	ret

; IN:	top of stack # of inputs,
;		followed by addresses of inputs.
; OUT:  stack addresses will point to input values.

getInput:
	push bp
	mov bp, sp
	push bx
	push si
	push di
	mov si, prompt
	call print
.start:
	mov cx, 0		; use cx to store # of fields
	mov di, heap	; store the result in the heap
.getKey:
	mov ah, 0x10
	int 0x16		; BIOS int 16h, 10h - wait for a keypress
	cmp al, 0x0D
	je .nextField
	mov ah, 0x0E
	int 0x10
	cmp al, 44		; increment field on comma
	je .nextField
	cmp al, 48
	jl .getKey		; not a number
	cmp al, 57
	jg .getKey		; not a number
	stosb
	jmp .getKey
.nextField:
	mov dx, ax
	push dx
	push cx
	mov [di], byte 0
	mov si, heap
	call strToInt
	pop cx
	pop dx
	push ax
	inc cx
	mov di, heap
	cmp dl, 0x0D	; stop getting input on ENTER
	jne .getKey
	mov si, newl
	call print
	cmp cx, [bp+4]
	je .fieldCountCorrect
.popBadAXs:
	pop ax
	loop .popBadAXs
	mov si, redo
	call print
	jmp .start
.fieldCountCorrect:		; assign inputs to vars on stack
	mov ax, 2
	mul cx
	mov di, ax
.saveInputs:
	pop ax
	mov bx, [bp+di+4]
	mov [bx], ax
	sub di, 2
	loop .saveInputs
	pop di
	pop si
	pop bx
	leave
	ret

; IN/OUT: di points to string

getStringInput:
	push bp
	mov bp, sp
	push bx
	push si
	push di
	mov si, prompt
	call print
.start:
	mov cx, 0		; use cx to store # of fields
	mov di, heap	; store the result in the heap
.getKey:
	mov ah, 0x10
	int 0x16		; BIOS int 16h, 10h - wait for a keypress
	cmp al, 0x0D
	je .nextField
	mov ah, 0x0E
	int 0x10
	cmp al, 44		; increment field on comma
	je .nextField
	cmp al, 48
	jl .getKey		; not a number
	cmp al, 57
	jg .getKey		; not a number
	stosb
	jmp .getKey
.nextField:
	mov dx, ax
	push dx
	push cx
	mov [di], byte 0
	mov si, heap
	call strToInt
	pop cx
	pop dx
	push ax
	inc cx
	mov di, heap
	cmp dl, 0x0D	; stop getting input on ENTER
	jne .getKey
	mov si, newl
	call print
	cmp cx, [bp+4]
	je .fieldCountCorrect
.popBadAXs:
	pop ax
	loop .popBadAXs
	mov si, redo
	call print
	jmp .start
.fieldCountCorrect:		; assign inputs to vars on stack
	mov ax, 2
	mul cx
	mov di, ax
.saveInputs:
	pop ax
	mov bx, [bp+di+4]
	mov [bx], ax
	sub di, 2
	loop .saveInputs
	pop di
	pop si
	pop bx
	leave
	ret

	SECTION .data
prompt	db	"?  ", 0
redo	db	"?Redo from start  ", 0
newl	db	`\n\r`, 0
