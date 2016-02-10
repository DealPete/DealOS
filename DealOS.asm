    BITS 16
    
    mov ax, 0800h	; put the stack pointer at the 
    cli				; end of the 64k segment.
    mov ss, ax
    mov sp, 0xFFFF
    sti				; disable interrupts while changing stack

    mov ax, 07C0h	; set data segment to beginning of program in memory
    mov ds, ax

    mov ah, 0Eh
    
    mov si, welcomeMessage

    mov ah, 0Eh		

repeat:
    lodsb
    cmp al, 0
    je done		
    int 10h	
    jmp repeat
done:
   
    mov ah, 8		; get drive parameters
    int 13h
    
    and cx, 3Fh
    mov [sectorsPerTrack], cx
    movzx dx, dh
    add dx, 1
    mov [headsPerCylinder], dx

    
; ---------------------------------------------------------------------
; To use int 13h, we must convert the logical address to CHS form - see
; https://en.wikipedia.org/wiki/Logical_block_addressing#CHS_conversion

    mov cl, 2		; the program is in sector 1
    mov dh, 0		; on head 0
	mov ch, 0		; on track 0

    mov ax, 0x800
	mov ds, ax
    mov es, ax

    mov ah, 2		; read program from disk
    mov al, 64		; assume program is 64K
    mov dl, 80h
    mov bx, 0h

    int 13h

   	jmp 0x800:0000

; ---------------------------------------------------------------------
; VARIABLES
    welcomeMessage db `Welcome to DealOS!\n\r`, 0

    sectorsPerTrack	db 0
    headsPerCylinder	db 0
    
    times 510-($-$$) db 0

    dw 0xAA55		; The standard PC boot signature

