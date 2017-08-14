#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: ass3

# Tool invocations
# Executable "task0" depends on the files numbers.o and ass3.o.
ass3:  ass3.o cell.o coroutines.o scheduler.o printer.o
	gcc -m32 -g ass3.o coroutines.o scheduler.o printer.o cell.o -o ass3

# Depends on the source and header files
ass3.o: ass3.s
	nasm -g -f elf ass3.s -o ass3.o

coroutines.o: coroutines.s
	nasm -g -f elf coroutines.s -o coroutines.o

scheduler.o: scheduler.s
	nasm -g -f elf scheduler.s -o scheduler.o

printer.o: printer.s
	nasm -g -f elf printer.s -o printer.o

cell.o: cell.c
	gcc -g -m32 -Wall -ansi -c -nostdlib -fno-stack-protector cell.c -o cell.o
	

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o ass3