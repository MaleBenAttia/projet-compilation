CC=gcc
CFLAGS=-Wall
LDFLAGS=-lSDL2 -lm

all: dessin_compiler

# Build the compiler
dessin_compiler: y.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o dessin_compiler y.tab.c lex.yy.c $(LDFLAGS)

# Generate parser
y.tab.c: syntax-dessin.y
	yacc -d syntax-dessin.y

# Generate lexer
lex.yy.c: lexical-dessin.l
	lex lexical-dessin.l

clean:
	rm -f dessin_compiler y.tab.c y.tab.h lex.yy.c

# Cibles additionnelles pour faciliter l'exécution
test: dessin_compiler
	./dessin_compiler test.prog

exemple: dessin_compiler
	./dessin_compiler exemple.dessin

.PHONY: all clean test exemple
