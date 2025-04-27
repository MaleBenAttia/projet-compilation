%{
#include <string.h>
#include <stdlib.h>
#include "dessin.tab.h"
%}

%%
"Draw"          { return DRAW; }
"Circle"        { return CIRCLE; }
"Rectangle"     { return RECTANGLE; }
"Triangle"      { return TRIANGLE; }
"noir"          { yylval.couleur = 1; return COULEUR; }
"rouge"         { yylval.couleur = 2; return COULEUR; }
"vert"          { yylval.couleur = 3; return COULEUR; }
"jaune"         { yylval.couleur = 4; return COULEUR; }
"bleu"          { yylval.couleur = 5; return COULEUR; }
"magenta"       { yylval.couleur = 6; return COULEUR; }
"cyan"          { yylval.couleur = 7; return COULEUR; }
"blanc"         { yylval.couleur = 8; return COULEUR; }
[0-9]+          { yylval.nombre = atoi(yytext); return NOMBRE; }
"("             { return OUVRIR_PAR; }
")"             { return FERMER_PAR; }
","             { return VIRGULE; }
[ \t\n]         { /* ignorer les espaces */ }
.               { fprintf(stderr, "Caractère non reconnu: '%s'\n", yytext); }
%%

int yywrap() {
    return 1;
}
