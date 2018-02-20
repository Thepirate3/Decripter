tema2: tema2.asm
	nasm -f elf32 -o tema2.o tema2.asm
	gcc -m32 -o $@ tema2.o

clean:
	rm -f tema2 tema2.o
