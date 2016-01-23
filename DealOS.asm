    BITS 16
    
    mov ax, 07C0h
    mov ds, ax

    mov si, text_string	; Put string position into SI

    mov ah, 0Eh		; int 10h 'print char' function

repeat:
    lodsb			; Get character from string
    cmp al, 0
    je done		; If char is zero, end of string
    int 10h			; Otherwise, print it
    jmp repeat

done:
    jmp $			; Jump here - infinite loop!


    text_string db 'Welcome to DealOS!', 0

    times 510-($-$$) db 0

    dw 0xAA55		; The standard PC boot signature
