CC = gcc
LEX = flex
CFLAGS = -Wall -Wno-unused-function
LDFLAGS =

TARGET = lexer

all: $(TARGET)

$(TARGET): lex.yy.c
	$(CC) $(CFLAGS) -o $(TARGET) lex.yy.c $(LDFLAGS)

lex.yy.c: main.l
	$(LEX) main.l

clean:
	rm -f $(TARGET) lex.yy.c

.PHONY: all clean
