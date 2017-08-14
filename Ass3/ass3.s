        global main, state, generations, kForPrint, length, realLength, WorldLength, WorldWidth
        extern init_co, start_co, resume, cell
        extern scheduler, printer, initState, printf

 
sys_exit:       equ   1
sys_write:      equ   4
stdout:         equ   1

fileLen:       equ   10
lengthLen:       equ   7
widthLen:       equ   6
genLen:       equ   22
freqLen: 	equ   16
section .data 
 
	stateArr: dd 0
	kLabel: db 'k is!',10 
	fileName:  db 'file name=', 0
	lenChars:  db 'length=', 0
	width:  db 'width=', 0
	numGen:  db 'number of generations=', 0
	hello:  db 'hello', 0
	printFreq:  db 'print frequency=', 0
	ten: dd 10
	ent: db '',10,0


section .bss
length: resb 4
realLength: resb 4
WorldWidth: resb 4
WorldLength: resb 4
kForPrint: resb 4
generations: resb 4
state: resb 10000
fileDescriptor: resb 4
x: resb 4
y: resb 4
res: resb 4
curr: resb 4
calcBy: resb 4
eset: resb 4
debug: resb 4
argv: resb 4


section .text


%macro initArgs 0
	argsLabel:
	mov edi, ebp
	mov ebx, dword [edi + 4 + 2*4] ; argv[] = -d inputExample.txt 5 5 10 3
	mov dword [argv], ebx

	mov dword [eset],0
	cmp dword [debug],0
	je noEset
	mov dword [eset],4
	noEset:
	mov eax,0
	mov eax, dword [eset]
	mov ecx,0
	mov ecx,[ebx+8+eax] ;argv[4+eset]=length 
	push ecx ;needs to push the pointer to WorldLength
	call myToi

	mov dword [WorldLength],eax 

	mov ebx, dword [argv]
	mov eax,0
	mov eax, dword [eset]
	mov esi,[ebx+4+eax] ;First argument - fileName pointer
	initState ;opens the file, and update state array
		
	mov ebx, dword [argv]	
	mov eax,0
	mov eax, dword [eset]
	mov ecx,[ebx+12+eax]
	push ecx
	call myToi 
	mov dword [WorldWidth],eax

	mov ebx, dword [argv]
	mov eax,0
	mov eax, dword [eset]
	mov ecx,[ebx+16+eax]
	push ecx
	call myToi 
	mov dword [generations],eax

	mov ebx, dword [argv]
	mov eax,0
	mov eax, dword [eset]
	mov ecx,[ebx+20+eax] ;place of k
	push ecx
	call myToi 
	mov dword [kForPrint],eax

	cmp dword [debug],1 
	je printLabel


%endmacro
 
myToi:
        push    ebp
        mov     ebp, esp         
        push ecx
        push edx
        push ebx
        mov ecx, dword [ebp+8]   
        xor eax,eax
        xor ebx,ebx
myToi_loop:
        xor edx,edx
        cmp byte[ecx],0
        jz  myToi_end
        imul dword[ten]
        mov bl,byte[ecx]
        sub bl,'0'
        add eax,ebx
        inc ecx
        jmp myToi_loop
myToi_end:
        pop ebx                 
        pop edx
        pop ecx
        mov     esp, ebp        
        pop     ebp
        ret


; This macro should open the filename at eax, and put the info in eax
%macro initState 0
	initLabel:
	;call the open system call for read & write
	mov ecx,0
    mov cl, 0x0000          ;read permission
    syscall 5,    esi,      ecx,    0777 
    ;open:  sysid fileName  perm1  perm2   
    ;eax holds the file descriptor
    mov dword [fileDescriptor], eax
    BeforeRead:
    syscall 3,    eax, state, 10000    
    ;read:  sysid fd  buffer fileSize
    ;eax holds file size
    mov dword [realLength],eax 

    sub eax,dword [WorldLength]
    inc eax
    AfterRead:
    mov dword [length],eax ;The real length is number of readbytes, reduce all enters, and increase 1 for the last row.
     
    mov esi,dword [realLength] ;prints board  

    updateState 

    mov esi,dword [realLength] ;prints board  

    mov eax, 6 	;file close system_call
    mov ebx, dword [fileDescriptor]
    int 0x80

%endmacro

%macro updateState 0 ;Tranform ' ' (spaces) to zeros. 
	 mov esi, dword [realLength]
	 %%loopState:
	 cmp byte [state+esi],' '
	 je makeZero
	 back:
	 dec esi
	 cmp esi,-1
	 jne %%loopState

%endmacro

makeZero:
	mov byte [state+esi],'0'
	jmp back

%macro syscall 4
    mov eax, %1              ; 
    mov ebx, %2             ; 
 	mov ecx, %3
    mov edx, %4           ; 
    int 0x80                ;interrupt - make system call. The return address of the file open --> eax

%endmacro

%macro newline 0
	mov eax,4			;write system code
	mov ebx,1			;stdout
	mov ecx,ent 		;message debug printing.
	mov edx,1			;message length
	int 0x80
%endmacro
 
%macro printArgs 0	 
	printArgsLabel: 
 
 	mov ebx, dword [argv]
    syscall sys_write, stdout, lenChars , lengthLen  
	;mov eax,[ebp+20]
 	mov ebx, dword [argv]
	badBadPlace:
	calcLength [ebx+12]
	mov edx, dword [argv]
	badPlace:
    syscall sys_write, stdout, [edx+12],esi   ;prints WorldLength
    newline

    mov edx, dword [argv]
    syscall sys_write, stdout, width , widthLen   
    mov edx, dword [argv]
	calcLength [edx+16]
    syscall sys_write,    stdout, [edx+16], esi ;prints WorldWidth
    
    newline
    syscall sys_write, stdout, numGen , genLen  
    mov edx, dword [argv]
 	calcLength [edx+20]
    syscall sys_write,    stdout, [edx+20], esi ;prints t - generations
    newline

    mov edx, dword [argv]
    syscall sys_write, stdout, printFreq , freqLen  
    mov edx, dword [argv]
	calcLength [edx+24]
    syscall sys_write,    stdout, [edx+24], esi ;prints kForPrint - k 
    newline
	newline

    boardP:
    mov esi,dword [realLength] ;prints board 
    syscall sys_write, stdout, state, esi
	newline
	newline

%endmacro

;gets number, and calculates it's length into esi
%macro calcLength 1
   mov ebx,%1
   mov eax,0
   %%loopCalcLen:
   inc eax
   inc ebx
   cmp byte [ebx],0
   jne %%loopCalcLen
   mov esi, eax
%endmacro

%macro catchDebug 0
   debugLabel: 
   mov dword [debug],0
   mov ebx,0 
   mov ebx, dword [ebp + 8] ; argc
   cmp ebx,7
   jne noD
   mov dword [debug],1
   noD:
%endmacro

%macro initCors 0
	; init the structure of every one of the coroutins
	; iterate the state array,
	mov eax, dword [WorldLength]
	mov ecx, dword [WorldWidth]
	mul ecx ;EAX will hold the correct size of all of the threads
	add eax,2
	mov ebx, 2 ;ebx holds the current number, start from 2
	; mov edx ; corrent i and j. esi:row edi: call
	mov edx, cell_func
	DIVDIV: 
	mov dword [calcBy],ebx
	loopBoard:
	;if ebx is special. curr <- ebx. ebx++. calcXY. ebx<-curr. call init_co
	jmp checkSpecial
	afterCalcBy:
 	calcXY ;it calcualtes by dword [calcBy] value 
 	mov esi, dword [x]
 	mov edi, dword [y]
 	initXY esi,edi
 	
 	;if ebx holds unique number, calcualte this initXY with ebx+1, and update the result to ebx's thread 
 	call init_co
	inc ebx 
	inc dword [calcBy]
	cmp eax,ebx
	jne loopBoard
%endmacro

%macro initXY 2
	mov esi, %1
	mov edi, %2
%endmacro

%macro zeroREGS 0
	mov eax, 0
	mov ecx, 0
	mov edx, 0
%endmacro

checkSpecial: ;checks if calcBy is special. If it is, calcBy++
	pushad
	mov eax,dword [y]
	inc eax
	cmp eax,[WorldWidth]
	jne aqui 
	inc dword [calcBy]
	aqui: 
	popad 
	jmp afterCalcBy

%macro calcXY 0
	pushad
	zeroREGS
	mov ecx,dword [calcBy] 
	sub ecx,2; ecx will hold the actuall thread number, from 0 to n 
	;place = x*(numOfCols+1)+y. We want x and y. So place/(numOfCols+1) = x. place - x*(numOfCols+1) = y 
	mov eax, dword [WorldWidth]
	inc eax
	xchg eax, ecx ;eax holds place. ecx holds (numOfCols+1)
	idiv ecx ;eax holds place/(numOfCols+1)
	mov dword [x], eax
	mov ecx,dword [WorldWidth]
	inc ecx
	mul ecx ;eax holds x*(numOfCols+1)
	mov ecx,dword [calcBy] ;ecx holds place
	sub ecx,2
	sub ecx,eax ;ecx = place - x*(numOfCols+1) = y
	mov dword [y],ecx
	;mov eax, dword [x]
	popad  
%endmacro


printLabel:
	printArgs
	jmp continue

main:
        enter 0, 0

 		catchDebug

        initArgs
       
        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        mov ecx, [ebp + 4]      ; ecx = argc
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state

        continue:
        initCors
        
        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines

        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h


cell_func:
	mov dword [res],0
	mov dword [x],esi
	mov dword [y],edi
	push edi	;y
	push esi	;x
	call cell ;eax holds the next state of the cell 
	mov dword [res],eax
	;resume . matrix update. resume. 
	xor ebx,ebx 
	call resume
	;x*(numOfCols+1)+y
	mov ebx,state 
	foo1: 
	mov dword [res],eax
	mov ecx,esi
	mov eax,dword [WorldWidth]
	inc eax ;eax = numOfCols+1
	mul ecx ;eax holds x*(numOfCols+1)
	add eax,edi ;eax = place = x*(numOfCols+1)+y 
	mov ecx,0
	mov ecx, dword [res]
	foo2: 
	mov byte [state+eax],cl
	foo3:
	mov ebx,state 

	xor ebx,ebx 
	call resume

	jmp cell_func
