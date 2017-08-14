;prints helloWorld
section .data
msg: db "x or k, or both are off range",10,0 ;this is our message
fmt: db "%d",10,0

section .bss

z: resw 1

section .text
extern printf
extern check

global calc_div

calc_div:
	push ebp
	mov ebp, esp 

	pusha			; Save registers

	mov esi,0		; Initialize registers with 0
	mov edi,0		; Later on: esi = x, edi = k
	mov eax,1 		; eax = 1. Later will be used to multiply.
	mov ebx,2		; ebx = 2. Later will be used to be the multiplied.
 
	mov esi, dword [ebp+8]	; Get first argument (pointer)
	mov edi, dword [ebp+12]	; Get second argument (pointer)

	push edi		; push the second int to the stack
	push esi      ; push the first int to the stack
	call check			; problem with activating check
	;needs to remember to: add esp,8 ;clean up the stack
	cmp eax,0   ; the return value of check is at eax
	je error	; check return 0, go to error. else, go on.
	mov eax,1
	add esp,8 ;clean up the stack

 
	myLoop:	;k>0. So first time - for sure. 
	mul ebx			;eax=eax*ebx --> eax=1*2=2 [first iteration].
	dec edi			;edi=edi-1 -> k=k-1. 

	cmp edi,0		;if edi=k=0 go to makeDiv.
	je makeDiv 		;else, Loop.
	jmp myLoop 

	error:
	add esp,8 ;clean up the stack
	push msg ;pushes the msg address into the stack. Like push 2042492
	call printf
	jmp finish

	makeDiv: ;now eax: 2^k, esi:x, I want the opposite.
	xchg eax,esi
 	div esi ; eax = eax / esi => eax = x/2^k - the result! 

  	push eax
 	push DWORD fmt
	call printf  ;call the printf to print it
	jmp finish

	finish:
	add esp,8 ;clean up the stack from push eax

	popa			; Restore registers
	mov esp, ebp
	pop ebp
	ret

