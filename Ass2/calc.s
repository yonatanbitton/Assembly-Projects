section .data
calc_fmt: db ">>calc: ",0 ;this is our message
msg: db "Debug printing: ",0 ;this is our message
exp_error: db ">>Error: exponent too large",10,0 ;this is our message
stack_error: db ">>Error: Operand Stack Overflow",10,0 ;this is our message
cap_error: db ">>Error: Insufficient Number of Arguments on Stack",10,0 ;this is our message
input_error: db ">>Error: Illegal Input",10,0 ;this is our message
dec_fmt: db "%d",10,0
tail_fmt: db "%x",0
firstPrintTail_fmt: db ">>%x",0
double_fmt: db "%x%x",0
firstPrint_fmt: db ">>%x%x",0
string_fmt: db "%s",0
ent: db "",10,0
elementsCounter: dd 0
operationCounter: dd 0
makeNode: dd 0

section .bss
firstData: resb 1
secondData: resb 1
inputOffset: resb 10
input: resd 120
nextAddress: resb 4
holder: resb 4
head: resb 4
curr: resb 4
runner: resb 4
upperCurr: resb 4
first: resb 4
second: resb 4
data: resb 4
carry: resb 1
counter: resb 4
fData: resb 1
sData: resb 1
twoK: resb 4
boolSH: resb 1
boolDELETE: resb 1
boolDEBUG: resb 1
boolPRINT: resb 1
boolFIRSTPRINT: resb 1
globalD: resb 1
globalP: resb 1


section .text 
     align 16 
     extern printf 
     extern fprintf 
     extern malloc 
     extern free
     extern fgets 
     extern gets 
     extern stderr 
     extern stdin 
     extern stdout
     extern fflush 
     extern exit

global main

main:
	push ebp
	mov ebp, esp 
	mov byte [boolDEBUG],1 	;if (argv[1]==-d) then boolDEBUG=1
	cmp dword [ebp+8],1
	je init
	mov eax,[ebp+12]
	mov ebx,dword [eax+4]
	cmp byte [ebx],'-'
	jne init	
	cmp byte [ebx+1],'d'
	jne init
	cmp byte [ebx+2],0
	jne init
	mov byte [boolDEBUG],1
	mov byte [globalD],0
	mov byte [globalP],0

	
	init: 	
	mov esi,0
	mov dword [operationCounter],0
	mov dword [elementsCounter],0
	mov dword [holder],0
	mov dword [upperCurr],0
	mov byte [boolSH],0

my_calc: 
	jmp Go 

myLoop:	
	mov byte [boolSH],0
	cmp dword [ebp+8],1
	je Go
	mov eax,[ebp+12]
	mov ebx,dword [eax+4]
	cmp byte [ebx],'-'
	jne Go	
	cmp byte [ebx+1],'d'
	jne Go
	cmp byte [ebx+2],0
	jne Go
	mov byte [boolDEBUG],1
	cmp byte [boolDEBUG],1
	mov byte [globalD],1

	je dupAndPrintDebug
	Go:
	
	cmp byte [globalD],1
	jne aqui2
	cmp byte [globalP],1
	jne aqui2
	push ent
	push string_fmt
	call printf 
	add esp,8

	aqui2:
	push calc_fmt
	call printf
	add esp, 4
	push dword [stdin]              ;fgets need 3 param
	push dword 120                   ;max lenght
	push dword input               ;input buffer
	call fgets
	add esp, 12
	mov eax,0  ;eax = NUMBER ACCUMULATOR!!!
	mov ebx,0  ;ebx = DIGIT at input
	mov ecx,0  ;the number 10
	mov edi,0  ;edi is the input iterator number
	mov dword [nextAddress],0
	mov dword [head],0
	mov dword [curr],0
	mov dword [first],0
	mov dword [second],0
	mov dword [data],0
	mov dword [firstData],0
	mov dword [secondData],0
	mov byte [counter],0
	mov dword [twoK],0
	mov byte [carry],0
	mov byte [boolPRINT],0
	mov byte [globalP],0

	mov bl, [input]
	cmp bl,10
	je Go
	cmp bl,'q' 			;if received q: go to finish. 
	je finish
	cmp bl,'+'
	je addition			
	cmp bl,'p'
	je popAndPrint
	cmp bl,'d'
	je duplicate
	cmp bl,'r'
	je shiftRightOrLeft
	cmp bl,'l'
	je shiftRightOrLeft

	mov edx,0

checkInpLength:
	mov bl, [input+edx]
	inc dx 
	cmp bl,'0'
	je increaseCounter ; DONT KNOW WHY IT'S GOOD !!!
	back2loop:
	cmp bl,10
	jne checkInpLength
	dec dx
	cmp dx,[counter]
	je makeZeros
	mov ax, dx 	; ax: hold count
	mov bl, 2		; bl=2
	div bl 			; ax=count / 2 => ah holds the reminder
	mov edi,0		; counter=0
	mov edx,0		; counter=0
	cmp ah,0		; check the reminder. if it's 0 => zugi. keep. else - makeOddInp.
	je accumulateNumber
	mov ecx,0
	mov cl, [input+edi]			;take the next digit from the input to bl
	inc edi
	cmp cl,10					;if next digit = end of input, jump to handleNumber (push it to the stack and get another input)
	je endOfNumberFirstDigit
	mov bl,'0'
	cmp cl,'0'
	jne checkValidity
	jmp accumulateNumber

	increaseCounter:
	inc dword [counter]
	jmp back2loop 


accumulateNumber:				;zugi label 
	mov ebx,0
	mov bl, [input+edi]			;take the next digit from the input to bl
	inc edi
	cmp bl,10					;if next digit = end of input, jump to handleNumber (push it to the stack and get another input)
	je endOfNumberFirstDigit
	mov ecx,0
	mov cl, [input+edi]
	inc edi
	cmp cl,10 
	je endOfNumberSecondDigit							
	cmp bl,'0'
	jne checkValidity
	cmp cl,'0'
	jne checkValidity
	cmp dword [nextAddress],0
	jne checkValidity
	jmp accumulateNumber

checkValidity:					;else, check the validity of the digit
	cmp bl,'0'
	jl errorInput
	cmp bl,'9'
	jg errorInput
	cmp cl,'0'
	jl errorInput
	cmp cl,'9'
	jg errorInput
	cmp dword [elementsCounter],5
	jge errorStack

numbersAreValid:	;if input = 01
	sub bl,30h  	;now actually contains the values. bl=0
	sub cl,30h		; 								   cl=1
	push ecx		;save ecx from dying 
	push 12 
	call malloc 	;eax contains the address of the new node
	add esp,4					;recover push 12 
	pop ecx 		;restore ecx
	mov dword [eax],ebx
	mov dword [eax+4],ecx
	mov dword [eax+8],0
	mov ecx, [nextAddress]
	mov dword [eax+8], ecx		;put ZEROs at the end of that node. [firstTime]							
	mov [nextAddress],eax
	mov eax,0
	jmp accumulateNumber 
		
	endOfNumberFirstDigit: ;situation: input: 10.
	push dword [nextAddress]
	mov dword [nextAddress],0
	inc dword [elementsCounter]		
	jmp myLoop

	endOfNumberSecondDigit: ;situation: input: 5.
	cmp bl,'0'
	jl errorInput
	cmp bl,'9'
	jg errorInput
	sub bl,30h  	;now actually contains the values. bl=0
	push 12 
	call malloc 	;eax contains the address of the new node
	mov dword [eax],' '
	mov dword [eax+4],ebx
	mov dword [eax+8],0
	mov ecx, [nextAddress]
	mov dword [eax+8], ecx		;put ZEROs at the end of that node. [firstTime]							
	add esp,4					;recover push 12 
	mov [nextAddress],eax
	mov eax,0
	jmp endOfNumberFirstDigit 
	
	makeZeros:
	cmp dword [elementsCounter],5	;debugging addition.
	jge errorStack
	push 12 
	call malloc 	;eax contains the address of the new node
	add esp,4					;recover push 12 
	mov dword [eax],0
	mov dword [eax+4],0
	mov dword [eax+8],0
	push eax
	mov eax,0
	inc dword [elementsCounter]		
	jmp myLoop

addition:		

	cmp byte [boolSH],0
	je label1
	mov esi, edi 	
	dec edi 
	cmp edi,1
	jl myLoop
	jmp popit

	label1:
	mov byte [carry],0
	cmp dword [elementsCounter],2
	jl errorCapability
	inc dword [operationCounter]	; increment the operation counter
	
	popit:
	pop ebx							; first element to eax
	pop ecx							; second element to ebx
	
	checkNext:
	cmp dword ebx,0
	jg hasNext
	cmp dword ecx, 0
	jg hasNext
	cmp byte [carry],1
	je handleCarry

	pushHeadAndMyLoop:
	push dword [head]
	mov dword [head],0
	mov dword [first],0
	mov dword [second],0
	mov dword [data],0
	dec dword [elementsCounter]
	cmp byte [boolSH],1
	je addition ;Instead of finishedDup! ;if finished with one, go to finishedDup - will send you to another one
	jmp myLoop

	hasNext:
	mov [first], ebx
	mov [second], ecx
	mov eax,0		  ; al = 0
	cmp ebx,0
 	je addFirst0
	cmp ecx,0
 	je addSecond0

	addNormal:	;ebx contains '10', ecx '40', I build sum(40,10) into eax
 	mov byte [firstData],0
 	mov byte [secondData],0
	add al, [ebx+4]		;al =0. now al=9.
	daa
	mov [firstData], al	;firstData = 9, useless.
	add al, [ecx+4]		;al (9) = al + 9. ah sherit, al mana. 
	daa 
	add al, [carry] 	;get the carry moving ! 
	daa 
	mov byte [carry], 0 ;carry = 0 now. 
	mov edx,0
	mov dl,16
	div dl  
	mov [firstData], ah 
	mov dl, ah  
	push edx ;push sherit
	mov edx,0 
	mov dl, al ;mana for dl 
	c1: 
	mov eax,0
	add al, [ebx]		;al =0. now al=9.
	daa
	add al, [ecx]		;al (9) = al + 9
	daa 
	add al, dl 			;add the carry from the AHADOT to the ASAROT  
	daa 
	cmp al,10 
	jge greaterThen10   ;if there is a need to set the carry for next iteration - do it . 
	push eax 
	mov [secondData], al 
	jmp makeLink 
	
	greaterThen10: 
	mov edx,0
	mov dl,16
	div dl  
	mov [secondData], ah 
	mov dl, ah  
	push edx ;push sherit
	mov edx,0 
	mov dl, al ;mana for dl 
	mov [carry],dl
	jmp makeLink 

	addFirst0:	;ebx not exists
	mov byte [firstData],0
 	mov byte [secondData],0
	mov eax,0
	mov al,[ecx+4]
	add al, [carry] 	;get the carry moving ! 
	daa 
	mov byte [carry], 0 ;carry = 0 now. 
	
	mov edx,0
	mov dl,16
	div dl  
	mov dl, ah  
	push edx ;push sherit
	mov edx,0 
	mov dl, al ;mana for dl 

	mov [firstData],al 
	mov eax,0
	mov al,[ecx]
	add al,dl 
	daa
	cmp al,10 
	jge greaterThen10   ;if there is a need to set the carry for next iteration - do it . 
	push eax 
	mov [secondData], al 
	jmp makeLink 

	addSecond0:	;ecx not exists
	mov byte [firstData],0
 	mov byte [secondData],0
	mov eax,0
	mov al,[ebx+4]
	add al, [carry] 	;get the carry moving ! 
	daa 
	mov byte [carry], 0 ;carry = 0 now. 
	
	mov edx,0
	mov dl,16
	div dl  
	mov [firstData], ah 
	mov dl, ah  
	push edx ;push sherit
	mov edx,0 
	mov dl, al ;mana for dl 

	mov [firstData],al 
	mov eax,0
	mov al,[ebx]
	add al,dl 
	daa
	cmp al,10 
	jge greaterThen10   ;if there is a need to set the carry for next iteration - do it . 
	push eax 
	mov [secondData], al 
	jmp makeLink 

	makeLink: 
	cmp dword [head],0 
	je makeHead
	push 12 
	call malloc					;return address -> to eax
	add esp,4
	mov edx,0
	pop edx 

	mov dword [eax],edx

	pop edx 
	mov dword [eax+4],edx
	mov dword [eax+8],0
	jmp updateCurrAndArrow

	makeHead:
	push 12 
	call malloc					;return address -> to eax
	add esp,4					;recover push 12 

	mov [head],eax
	mov [curr],eax
	mov edx,0

	pop edx 
	mov dword [eax],edx   		;insert the number 25 (data) into the address that is pointed from eax,
	mov edx, 0

	pop edx 
	mov dword [eax+4],edx 		;insert the number 25 (data) into the address that is pointed from eax,
								;that's the pointer which has returned from the malloc
	mov dword [eax+8], 0		;put ZEROs at the end of that node. [firstTime]		
	jmp advance

	handleCarry:		;enters here at the end of the process, only if carry exists.
	push 12 
	call malloc					;return address -> to eax
	add esp,4					;recover push 12 
	mov dword [eax],0
	mov dword [eax+4],1
	mov dword [eax+8],0
	mov edx,[curr]				;make the arrow. edx = curr
	add edx,8					;
	mov [edx], eax				;curr[8] <- eax (new Node)	
	mov [curr],eax				;now curr will point to the new node. 
	mov byte [carry], 0 ;carry = 0 now. 
	jmp pushHeadAndMyLoop

	updateCurrAndArrow: 
	mov edx,[curr]				;make the arrow. edx = curr
	add edx,8					;
	mov [edx], eax				;curr[8] <- eax (new Node)	
	mov [curr],eax				;now curr will point to the new node.

	updateFirstAndSecond:	
	mov ebx,[first]				; make ebx point to first node
	mov ecx, [second]			; make ecx point to second node
	cmp ebx,0
	je updateFirstIs0

	cmp ecx,0
	je updateSecondIs0
	jmp normalUpdate
	
	updateFirstIs0:
	cmp ecx,0
	je update
	add ecx, 8
	mov ecx, [ecx]
	jmp update 

	updateSecondIs0:
	cmp ebx, 0
	je update 
	add ebx, 8
	mov ebx, [ebx]
	jmp update

	normalUpdate:
	add ebx, 8					; make ebx point to first.next
	add ecx, 8					; make ebx point to second.next
	mov ebx, [ebx]
	mov ecx, [ecx]

	update:
	mov [first],ebx
	mov [second],ecx
	jmp checkNext
								
	advance:	; in this point the new node has been built inside eax.
	mov ebx,0
	mov ecx,0
	mov ebx,[first]				; make ebx point to first node
	mov ecx, [second]			; make ecx point to second node
	add ebx, 8					; make ebx point to first.next
	add ecx, 8					; make ebx point to second.next
	mov ebx, [ebx]
	mov ecx, [ecx]
	mov [first],ebx
	mov [second],ecx
	jmp checkNext
	
	
popAndPrint:
	mov byte [globalP],1
	cmp dword [elementsCounter],1
	jl errorCapability
	inc dword [operationCounter]	; increment the operation counter
	mov byte [boolFIRSTPRINT],1

	
	.afterCheck:
	dec dword [elementsCounter]
	pop ecx 	;now ecx hold the head for the list.
	mov dword [holder],0
	mov edx, ecx 	;save the first element
	
	TList:
	push ecx			; ashkara link
	cmp dword [ecx+8],0
	je RecStep
	mov ecx, [ecx+8]	; link = link.next
	jmp TList
	
	RecStep:
	pop ecx				; for example: ecx points to "34"
	mov [holder],ecx	; transfer the ecx to holder (it's getting messy)
	cmp dword [ecx+8],0
	je noNext
	
	normalCase:
	mov eax,0
	mov ebx,0
	mov eax,[ecx]		;eax:3 
	mov ebx,[ecx+4]		;ebx:4
	; cmp eax,' '
	; je printOne
	push edx 			;rescue edx from printf
	push ebx
	push eax
	cmp byte [boolFIRSTPRINT],1
	je printFirst
	cmp byte [boolPRINT],1
	je pushErrFmt
	push double_fmt
	call printf
	normalCaseAfterFormat:
	add esp,12 			; recover the printing
	afterFirstPrint: 
	pop edx 			;restore edx
	cmp edx, [holder]	; if ecx (current link) equals to the head of the linkedList that was saved on the start
	je EnterAndMyLoop  	; it's the stopping condition, jump to myLoop 
	jmp RecStep

	pushErrFmt:
	push double_fmt
	push dword [stderr]
	call fprintf 
	add esp,4 ; recover the push 2h, the covering for the rest: later.
	jmp normalCaseAfterFormat

	printFirst:
	cmp byte [boolPRINT],1
	je pushFirstErrFmt
	push firstPrint_fmt
	call printf
	printFirstAfterFormat:
	add esp,12 			; recover the printing
	mov byte [boolFIRSTPRINT],0
	jmp afterFirstPrint

	pushFirstErrFmt:
	push firstPrint_fmt
	push dword [stderr]
	call fprintf 
	add esp,4 ; recover the push 2h, the covering for the rest: later.
	jmp printFirstAfterFormat

	printFirstTail:
	cmp byte [boolPRINT],1
	je pushTailErrFmt
	push firstPrintTail_fmt
	call printf

	printTailAfterFormat:
	add esp,8 			; recover the printing
	mov byte [boolFIRSTPRINT],0
	jmp afterFirstPrintTail

	pushTailErrFmt:
	push firstPrintTail_fmt
	push dword [stderr]
	call fprintf 
	add esp,4 ; recover the push 2h, the covering for the rest: later.
	jmp printTailAfterFormat

	printOne:
	push edx 			;rescue edx from printf
	push ebx
	cmp byte [boolFIRSTPRINT],1
	je printFirstTail
	cmp byte [boolPRINT],1
	je pushTail_One_ErrFmt
	push tail_fmt
	call printf
	AfterFormat_One_ErrFmt:
	add esp,8 			; recover the printing
	afterFirstPrintTail:
	pop edx 			;restore edx

	cmp edx, [holder]	; if ecx (current link) equals to the head of the linkedList that was saved on the start
	je EnterAndMyLoop  	; it's the stopping condition, jump to myLoop 
	jmp RecStep

	pushTail_One_ErrFmt:	
	push tail_fmt
	push dword [stderr]
	call fprintf 
	add esp,4 ; recover the push 2h, the covering for the rest: later.
	jmp AfterFormat_One_ErrFmt

	noNext:

	mov eax,0
	mov ebx,0
	mov eax,[ecx]		;eax:3 
	mov ebx,[ecx+4]		;ebx:4
	cmp eax,0
	je printOne
	jmp normalCase

	EnterAndMyLoop:
	; cmp byte [boolDEBUG],1
	; je pushEnterToStderr
	; cmp byte [boolDEBUG],257
	; je pushEnterToStderr
	cmp byte [globalD],1
	je pushEnterToStderr
	;Normal case
	push ent
	push string_fmt
	call printf
	add esp,8
	jmp Go

	pushEnterToStderr: ;only if -d 
	cmp byte [globalP],1
	jne aqui
	cmp byte [globalD],1
	jne aqui
	jmp Go 
	aqui: 
	push ent
	push string_fmt
	push dword [stderr]
	call fprintf
	add esp,12
	jmp Go

	debugPrinting:
	;WRITING SYSTEM CALL!
	mov eax,4			;write system code
	mov ebx,2			;stderr
	mov ecx,msg 		;message debug printing.
	mov edx,16			;message length
	int 0x80
 	jmp Go


duplicate:
	cmp byte [boolSH],1
	je shiftDupLoop
	cmp dword [elementsCounter],1
	jl errorCapability
	cmp dword [elementsCounter],4
	jg errorStack
	inc dword [operationCounter]	; increment the operation counter

    shiftDupLoop:
    inc dword [elementsCounter]
    mov dword [head],0
    mov dword [nextAddress],0
	mov dword [sData],0
	mov dword [fData],0

    pop ebx
    mov [first],ebx		;first saves the start of ebx
    mov [upperCurr],ebx ;upperCurr holds the upper curr node. 

	iter_CheckNext: 
    cmp dword ebx,0
    jg hasNext2
   	push dword [head]  ;push the new list (the one created)
	push dword [first]	;push the old list (copied one)
	mov dword [head],0
	mov dword [data],0
	cmp byte [boolSH],1
	je checkIfAgainShift
	cmp byte [boolDEBUG],1	;if you came from the dupAndPrintDebug, you've duplicated, now go to print.
	jne myLoop
	cmp byte [boolPRINT],1
	je dupAndPrintDebug.nowPrint
	jmp myLoop
	
	checkIfAgainShift:		;if it's shift's, check if finished making the add.
	mov ecx, esi
	dec ecx 
	mov esi, ecx 
	cmp ecx,1
	jle finishedDup   ;if needs to terminates - do it. 
	jmp shiftDupLoop  ;if not, jump to dupLoop

	hasNext2:
    mov ecx,0
    mov dword [fData],0 
    mov dword [sData],0 
    mov cl,[ebx]
    mov byte [fData],cl
    push ecx 
    mov ecx,0
    mov cl,[ebx+4]
    mov byte [sData],cl
    push ecx 
    cmp dword [head],0

    je makeHead2
    push 12 
    call malloc
    add esp,4
    mov ebx,0
    mov ecx,0
    pop ecx 

    mov byte [eax+4],cl 

    mov ecx,0 
    pop ecx 
    mov byte [eax],cl 
    mov dword [eax+8],0
    mov ecx, 0
    mov ecx, [curr]	;mov [curr+8],eax
    add ecx, 8
    mov dword [ecx], eax
    mov dword [curr], eax

    jmp updateNext

	makeHead2:
	push 12 
	call malloc					;return address -> to eax
	add esp,4					;recover push 12 
	mov [head],eax
	mov [curr],eax

    mov ecx,0
    pop ecx
    mov byte [eax+4],cl 
    mov ecx,0  
    pop ecx

    mov byte [eax],cl 
    mov dword [eax+8],0

	updateNext:
	mov ebx, [upperCurr] 		; ebx: point to the current upper pleasse. 
	add ebx, 8					; make ebx point to first.next
	mov ebx, [ebx]
	mov [upperCurr], ebx
	jmp iter_CheckNext


	errorInput: ;invalid input
	push input_error
	call printf
	add esp,4
	jmp Go

	errorStack: ;invalid input
	push stack_error
	call printf
	add esp,4
	jmp aqui2

	errorCapability: ;invalid input
	push cap_error
	call printf
	add esp,4
	jmp aqui2

	errorExp: ;invalid input
	push edx ;Don't forget to return k to the stack! 
	inc dword [elementsCounter]
	dec dword [operationCounter]	; increment the operation counter
	push exp_error
	call printf
	add esp,4
	jmp aqui2

dupAndPrintDebug:
	mov byte [boolPRINT],1
	push msg 
	push dword [stderr]
	call fprintf 
	add esp, 8 
	jmp shiftDupLoop ;(duplicate.shiftDupLoop checks if boolDEBUG==1, if yes, knows to return to nowPrint label)
	.nowPrint:
	jmp popAndPrint.afterCheck ;(popAndPrint uses format of -d). it'll go to Go automaticly
	.makeZero:
	mov byte [boolPRINT],0
	jmp Go


shiftRightOrLeft:
	cmp dword [elementsCounter],2
 	jl errorCapability
 	inc dword [operationCounter]	; increment the operation counter
 	mov edx,0
 	pop edx 		;now edx holds k (from 2^k)
 	dec dword [elementsCounter]

 	mov edi,[edx+8]
 	cmp edi,0
 	jne errorExp ;If the number k is tlat sifrati - error exp. Else - keep. 
 	
 	mov edi,[edx+4] ;edi holds sifrat ahadot.
 	
 	mov esi,10
 	mov eax,[edx]	;eax holds sifrat asarot
 	mul esi  		;eax = sifrat asarot*10

 	add eax, edi 
 	mov edx, eax 

 	cmp edx,0		;if k=0, 2^k = 1. Neutral for divition and mult.
 	je Go
 					;else, needs to calculate 2^k and check shift right or left
    mov eax,1
    mov ecx,0
    mov ecx,2
    mov esi,0
    mov esi, edx
    cmp bl,'r'
    je shiftRight

    smallLoop:	;ecx:2, eax:0, so   
    mul ecx
    dec esi 
    cmp esi,1
    jge smallLoop
    mov esi, eax ;esi - hold it as well.
    mov edi, esi
    mov dword [twoK],esi
    

shiftLeft: ;shiftLeft: ecx holds 2^k. now needs to do 2^k-1 duplicate. 
	dupLoop: 
	mov byte [boolSH],1
	mov dword [twoK], eax
	jmp duplicate 	;duplicate will check if boolSH==1, and if yes, will make it until
	
	finishedDup: ;now the stack has 2^k times the wanted number. Time to make addition! ;additionOfShiftLeft:	
	mov byte [boolSH],1
    mov esi,[twoK]
    mov esi, edi 	
	jmp addition  ;addition will check if boolSH==1, and if yes, will make it until esi terminates	

shiftRight:

	mov byte [carry],0

	mov edi, edx 
	mov dword [twoK],edx	;it's K, not twoK
	decK:
	cmp dword [twoK], edi 
	je withoutPushing
	push dword [first]
	mov byte [carry],0

	withoutPushing:
	mov esi, edi 	
	cmp esi,0
	je myLoop
	dec edi
	jmp startNode

;edx holds k. Loop k iterations of the following code: 
	;hold first, hold runner, hold curr=first, finishBool=false.
	;advance to last with curr.
	;if (next!=0) advance until (next==0)
		;start Loop. if curr=first, finishBool=true;
		;make number decimal and div 2 with shift.
		;exotic case: if (curr.next==0) and (curr.data==00) deleteBool=true
		;if (cf==1) add 50 to the result. make sure (cf=0).
		;disassemble the result and push it to curr.
		;(if cf==1 fiftyFlag=true.)
		;while runner.next!=curr, runner=runner.next 
		;if (deleteBool==true) delete curr, and curr=runner. deleteBool = false.
		;curr=runner ; runner=first. 
		;go to Loop until finishBool==true
;go to loop if hasn't reached 0.
	startNode:
	mov dword [first],0
	mov dword [curr],0
	mov dword [runner],0

	pop ebx				;the number to be shifted 
    mov [first],ebx		;first saves the start of ebx
    mov [curr],ebx		;first saves the start of ebx
    mov [runner],ebx		;first saves the start of ebx
    mov byte [boolSH],0 		;the finished boolean!!!
    mov byte [boolDELETE],0 		;the finished boolean!!!
    goToLast:
	mov ecx, [curr]			; make ecx point to curr node
	add ecx, 8				; make ecx point to address of curr.next
	mov ecx, [ecx]			; make ecx point to curr.next
	cmp ecx,0
	je shiftLoop
	mov dword [curr],ecx
	jmp goToLast

	shiftLoop:
	mov esi, [first]
	cmp dword [curr],esi 
	jne keep
	mov dword [boolSH],1	;if there is a need to finish, raise that flag.
	keep:		;now curr hold a number. for example 25.
	mov eax,0
	mov ecx, [curr]
	mov al, [ecx]	;now eax holds 2.
	mov esi,10
	mul esi 	;ax = ax*10, meaning ax = 20.
	add ax, [ecx+4]	;ax = 20 + 5

	cmp byte [carry],1 	;if no carry - shift and continue. if there is carry, add 50 to the result.
	je shiftAndAddWithCarry

	shr ax,1	; ax = ax/2
	jc updateCarry
	mov byte [carry],0
	jmp trueResult

	updateCarry:
	mov byte [carry],1
	jmp trueResult

	shiftAndAddWithCarry:
	shr ax,1
	jc updateCarryAGAIN
	mov byte [carry],0
	add50:
	add ax,50
	
	jmp trueResult

	updateCarryAGAIN:
	mov byte [carry],1
	jmp add50

	trueResult:
	mov edx,0
	mov dl,10
	div dl  	;al mana, edx sherit
	mov byte [ecx], al		;put the mana in the asarot
	mov byte [ecx+4], ah 	;put the sherit in the ahadot 

	jmp checkIfNeedsToDelete
	keepAgain:
	mov edx, [runner]
	cmp edx, ecx ;runner = curr on first iteration. finishBool=1
	jne advanceRunnerToCurr
	mov byte [boolSH],1
	jmp decK

	advanceRunnerToCurr:
	mov edx, [runner]
	cmp [edx+8], ecx 
	je finishedNode

	add edx,8
	mov edx, [edx]
	mov dword [runner],edx
	cmp [edx+8], ecx 
	jne advanceRunnerToCurr


	finishedNode: 	
	cmp byte [boolDELETE],1
	je deleteCurr
	mov dword [curr],edx ;curr=runner. runner=first.
	mov edx, [first]
	mov dword [runner],edx 
	cmp byte [boolSH],1
	je decK
	jmp shiftLoop

	deleteCurr: 	;if (deleteBool==true) delete curr, and curr=runner. deleteBool = false.
	mov edx, [runner]
	mov dword [curr], edx ;curr = runner
	add edx,8
	mov dword [edx],0
	mov byte [boolDELETE],0	;deleteBool = false. 
	mov edx, [curr]
	jmp finishedNode

	checkIfNeedsToDelete: 	;exotic case: if (curr.next==0) and (curr.data==00) deleteBool=true
	mov edx, [curr]
	cmp dword [edx],0
	jne keepAgain
	cmp dword [edx+4],0
	jne keepAgain
	add edx,8
	cmp dword [edx],0
	jne keepAgain
	mov byte [boolDELETE],1
	jmp keepAgain

finish:
	;inc dword [operationCounter]	; increment the operation counter
	mov ecx, [operationCounter] 	;print the operationCounter.
	push ecx
	push dec_fmt
	call printf
	add esp,8
 	mov esp, ebp
	pop ebp
	push 0
	call exit