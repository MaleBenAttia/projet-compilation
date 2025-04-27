CC = gcc
LEX = flex
YACC = bison -y

all: compilateur

compilateur: y.tab.c lex.yy.c
	$(CC) -o $@ y.tab.c lex.yy.c -lfl

y.tab.c: syntax.y
	$(YACC) -d syntax.y

lex.yy.c: lexical.l
	$(LEX) lexical.l

clean:
	rm -f *.o compilateur y.tab.c y.tab.h lex.yy.c

test: compilateur
	./compilateur test.txt
