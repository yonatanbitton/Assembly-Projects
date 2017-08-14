#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: calc

# Tool invocations
# Executable "calc_ass0" depends on the files calc_ass0.o and calc_ass0.o.
calc: calc.o 
	gcc -g -m32 -Wall -o calc calc.o

calc.o: calc.s
	nasm -g -f elf32 -w+all -o calc.o calc.s

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o calc