section	.rodata
LC0:
	DB	"The result is:  %s", 10, 0	; Format string

section .bss
LC1:
	RESB	256

section .text
	align 16
	global my_func
	extern printf

my_func:
	push	ebp
	mov	ebp, esp	; Entry code - set up ebp and esp
	pusha			; Save registers

	mov ecx, dword [ebp+8]	; Get argument (pointer to string)
	mov eax,0
	mov edx,0
	mov edi,0

;       Your code should be here...
	;mov edi,[ecx+1]
	mov edx,16
	mov al,[ecx]
	mul edx
	inc ecx
	mov edi,[ecx]
	add eax,edi
	mov [LC1],eax


	push	LC1		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call

	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret