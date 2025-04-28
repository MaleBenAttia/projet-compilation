%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
void yyerror(const char *);
%}

%%

[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"print"         { return PRINT; }
"{"             { return '{'; }
"}"             { return '}'; }
"("             { return '('; }
")"             { return ')'; }
"=="            { return EQ; }
"!="            { return NE; }
"<"             { return '<'; }
">"             { return '>'; }
"<="            { return LE; }
">="            { return GE; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"="             { return '='; }
";"             { return ';'; }

"Draw"          { return DRAW; }
"Circle"        { return CIRCLE; }
"Rectangle"     { return RECTANGLE; }
"Triangle"      { return TRIANGLE; }
"noir"          { yylval.color_val = 1; return COULEUR; }
"rouge"         { yylval.color_val = 2; return COULEUR; }
"vert"          { yylval.color_val = 3; return COULEUR; }
"jaune"         { yylval.color_val = 4; return COULEUR; }
"bleu"          { yylval.color_val = 5; return COULEUR; }
"magenta"       { yylval.color_val = 6; return COULEUR; }
"cyan"          { yylval.color_val = 7; return COULEUR; }
"blanc"         { yylval.color_val = 8; return COULEUR; }
","             { return ','; }

[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return IDENTIFIER; }
[ \t\n]         ; /* ignore whitespace */
.               { yyerror("Caractère invalide"); }

%%

int yywrap() {
    return 1;
}
