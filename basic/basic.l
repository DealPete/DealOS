%{
#include "basic.h"
#include "y.tab.h"
int yyerror(const char*);
%}

%%
[ \t\n] ;
[0-9]+	{ yylval.ival = atoi(yytext); return INTEGER; }
"CLS"	{ return CLS; }
"PRINT" { return PRINT; }
\".*\"	{ parseString(); return STRING; }
.		yyerror("unknown token");
%%

int yyerror(char const *str) {
	fprintf(stderr, "line %d: %s\nnext token: %s\n", yylineno, str, yytext);
}

int parseString() {
	yylval.sval = strdup(yytext+1);
	if (yylval.sval[yyleng - 2] != '"') {
		yyerror("String not terminated with \"");
	} else
		yylval.sval[yyleng-2] = 0;
}
