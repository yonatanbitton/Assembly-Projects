section	.rodata
LC0:
	DB	"%s", 10, 0	; Format string

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

 	mov esi,LC1  	;target buf
	mov eax,0  		;initialize eax as 0
	mov ebx,0
	mov edx,1 		;initialize boolean - finishedLoop = false. (Will be updated after the numbers are converted)
	mov edi,0 		;initialize data holder - edi.


my_loop: ;code 
	mov al,[ecx]	;put first char (33h) at eax's al (OR second char at second iteration)
	inc ecx			;increase the source buffer

compare:
	cmp al,10
	je print

	cmp al,'0'               ;now al has VALUE, not address, so no need to compare with [al].
	jge greater_then_0
	jmp big_letters

	greater_then_0:
	cmp al,'9'
	jle greater_then_0_and_smaller_then_9
	jmp big_letters

	greater_then_0_and_smaller_then_9:
	sub al,48d
	jmp check_loop_and_convert

	big_letters:
	cmp al,'A'
	jge greater_then_A
	jmp small_letters

	greater_then_A:
	cmp al,'Z'
	jle greater_then_A_and_smaller_then_Z
	jmp small_letters

	greater_then_A_and_smaller_then_Z:
	sub al,55d
	jmp check_loop_and_convert

	small_letters:
	cmp al,'a'
	jge greater_then_a
	jmp check_loop_and_convert

	greater_then_a:
	cmp al,'z'
	jle greater_then_a_and_smaller_then_z
	jmp check_loop_and_convert

	greater_then_a_and_smaller_then_z:
	sub al,87d
	jmp check_loop_and_convert

	check_loop_and_convert:	
	dec edx      ;decrease edx. from edx:1 to edx:0 (at the start)
	cmp edx,0 
	je another_loop ;if [edx]=0, first time, go to another_loop
	;else: second time here.
	mov ebx, eax ;ebx = eax (the latest "work" register)
	mov eax, edi ;eax = edi (the first "work" that was done)
	mov edx,1    ;edx=1 again, for next iteration
	jmp sum_results
	
	another_loop:
	mov edi,16
	mul edi      ;eax = eax * edi.  eax <- 3*16 
	mov edi, eax ;edi = eax - save that data for later!
	jmp my_loop

	sum_results:
	add eax, ebx ;eax = eax + ebx	eax <- 3*16+4 = 48+4 = 52 = Decimal representaion of the number 4.
	mov [esi],eax ;push the result into the target buffer

	end:
    inc esi      	    ; increment target buffer pointer
	cmp byte [ecx], 10   ; check if byte pointed to is zero [input ends with \n]
	jne my_loop      ; keep looping until it is null terminated

	print:
	mov byte [esi],0 	 ; mark the end of the target buffer

	push	LC1		; Call printf with 2 arguments: pointer to str
	push	LC0		; and pointer to format string.
	call	printf
	add 	esp, 8		; Clean up stack after call

	popa			; Restore registers
	mov	esp, ebp	; Function exit code
	pop	ebp
	ret

