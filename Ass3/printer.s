        global printer
        extern resume,state,length,realLength
 
sys_write:      equ   4
stdout:         equ   1


section .data

hello:  db 'hello', 10
ent:  db '', 10


section .text

%macro syscall 4
    mov eax, %1              ; 
    mov ebx, %2             ; 
 	mov ecx, %3
    mov edx, %4           ; 
    int 0x80    
%endmacro

printer: 

        mov eax, sys_write
        mov ebx, stdout
        mov ecx, state
        mov edx, dword [realLength]
        print: 
        int 80h
  
        syscall sys_write, stdout, ent, 1  

        xor ebx, ebx
        call resume             ; resume scheduler

        jmp printer