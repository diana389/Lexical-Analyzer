# Stefan Diana 332CC

all: main

main: lex.yy.c
	gcc -o main lex.yy.c -Wall -Wno-unused-function

lex.yy.c: main.l
	flex main.l

clean:
	rm -f main lex.yy.c

.PHONY: all clean
