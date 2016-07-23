gdtr	dw 0
		dd 0

;	Initialize Global Descriptor Table
setupGDT:
	cli
	xor eax, eax
	mov ax, ds
	shl eax, 4
	add eax, gdt
	mov [gdtr + 2], eax
	mov eax, gdt_end
	sub eax, gdt
	mov [gdtr], ax
	lgdt [gdt]

	mov eax, cr0
	or al, 1
	mov cr0, eax
	ret

;	See http://wiki.osdev.org/Global_Descriptor_Table for an explanation of this constant.
gdt		dq 0x0000000000000000
		dq 0x00CF9A000000FFFF
		dq 0x00CF92000000FFFF
;		dq 0xFFFF0000009ACF00 
;		dq 0xFFFF00000092CF00
gdt_end:
