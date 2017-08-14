        global scheduler
        extern resume, end_co, state, length
section .bss
lastEBX: resb 4
relocK: resb 4
relocGen: resb 4

section .text

scheduler:
        mov ebx, 1
        pop eax ;eax hold [kForPrint]
        pop edi ;edi holds [generations]
        ;mov edi,dword [generations]
        mov dword [relocK], eax
        mov dword [relocGen], edi

        mov ecx, dword [length]
        mov esi, 0
schedulerNext:  
	   ; put in ebx the address of the stack of the thread 
       ; The scheduler needs to call resume(threadOf(cell)) for each cell, twice each loop. Calc and update. 
       ; two loops. first: calculation for all threads. second: update for all threads. Each loop includes K checking. 
       ; when finished the 2 loops (after getting 'break' because of the generation) last call to printer.
        mov ebx,2
        loopCalc:
	        call resume
	        inc ebx
	        inc esi
	        cmp esi, dword [relocK]
	        je printCallCalc
	        contLoopCalc:
        	dec ecx
        	cmp ecx,0
        jne loopCalc

        mov ebx,2
        mov ecx, dword [length]
        loopUpdate:
	        call resume
	        inc ebx
	        inc esi
	        cmp esi, dword [relocK]
	        je printCallUpdate
	        contLoopUpdate:
        	dec ecx
        	cmp ecx,0
        jne loopUpdate

        mov ecx, dword [length]

    	dec edi
    	cmp edi,0
    	jne schedulerNext
        ;loop schedulerNext

        mov ebx,1
        call resume             ; resume printer
        
        call end_co             ; stop co-routines

printCallCalc:
mov dword [lastEBX],ebx
mov ebx,1
mov esi,0
call resume
mov ebx, dword [lastEBX]
jmp contLoopCalc

printCallUpdate:
mov dword [lastEBX],ebx
mov ebx,1
mov esi,0
call resume 
mov ebx, dword [lastEBX]
jmp contLoopUpdate