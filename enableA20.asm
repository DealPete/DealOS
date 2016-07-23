; The following code is public domain licensed
 
[bits 16]
 
; Function: check_a20
;
; Purpose: to check the status of the a20 line in a completely self-contained state-preserving way.
;
; Returns: 0 in ax if the a20 line is disabled (memory wraps around)
;          1 in ax if the a20 line is enabled (memory does not wrap around)
 
enable_a20line:
	call check_a20
	
	or ax, ax
	jnz a20_enabled
	in al, 0x92
	or al, 2
	out 0x92, al
	
	call check_a20
	or ax, ax
	jnz a20_enabled

	mov si, a20_error 
	call print
	hlt

a20_enabled:
	ret

check_a20:
	push ds
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je check_a20__exit
 
    mov ax, 1
 	
check_a20__exit:
	pop ds
	sti
    ret

a20_error		db	"Error! Couldn't disable A20 line.", 0
