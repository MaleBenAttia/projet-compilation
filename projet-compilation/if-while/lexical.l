%{
#include "y.tab.h"
#include <stdlib.h>
void yyerror(const char *);
%}

%%

[0-9]+          { yylval.ival = atoi(yytext); return NUMBER; }
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
[a-zA-Z][a-zA-Z0-9]* { yylval.sval = strdup(yytext); return IDENTIFIER; }
[ \t\n]         ; /* ignore whitespace */
.               { yyerror("Caractère invalide"); }

%%

int yywrap() {
    return 1;
}
