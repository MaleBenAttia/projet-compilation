all: dessin_compiler

dessin_compiler: lex.yy.c dessin.tab.c
	gcc -o dessin_compiler lex.yy.c dessin.tab.c -lfl

lex.yy.c: dessin.l dessin.tab.h
	flex dessin.l

dessin.tab.c dessin.tab.h: dessin.y
	bison -d dessin.y

clean:
	rm -f dessin_compiler lex.yy.c dessin.tab.c dessin.tab.h dessin_genere.c
