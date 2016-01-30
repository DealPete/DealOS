    BITS 16
    
    mov ax, 07C0h	; set up 4K of stack space
    add ax, 4122	; after the 32 paragraph bootloader
    cli			; and the first 64K segment
    mov ss, ax
    mov sp, 4096
    sti			; disable interrupts while changing stack

    mov ax, 07C0h	; set data segment to beginning of program in memory
    mov ds, ax

    mov ah, 0Eh
    
    mov [bootDevice], dl
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

    mov cx, 1		; DONKEYQB.EXE is in sector 1
    mov dh, 0		; on head 0

    mov ax, 1000h	; load file at 1000:0000h
    mov es, ax

    mov ah, 2		; read DONKEYQB.EXE from disk
    mov al, 83
    mov dl, [bootDevice]
    mov bx, 0h

    stc
    int 13h
  
    mov ax, 1000h
    mov ds, ax
    mov es, ax

    jmp 0x1000:0xA3D0			; start the program
    
; ---------------------------------------------------------------------
; VARIABLES
    welcomeMessage db 'Welcome to DealOS!', 0

    bootDevice		db 0
    sectorsPerTrack	db 0
    headsPerCylinder	db 0
    
    times 510-($-$$) db 0

    dw 0xAA55		; The standard PC boot signature
