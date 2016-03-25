%{
#include "basic.h"
#include "y.tab.h"
int yyerror(const char*);
void parseString();
%}

%option yylineno

%%
"\n"					{ return EOL; }
\"[^"]*\"				{ parseString(); return STRING; }
"GO TO"					{ return GOTO; }
[ \t] ;
[0-9]+					{ yylval.ival = atoi(yytext); return INTEGER; }
[=+*/\-,;<>()]			{ return *yytext; }
"CLS"					{ return CLS; }
"DATA"					{ return DATA; }
"DIM"					{ return DIM; }
"END"					{ return END; }
"GOTO"					{ return GOTO; }
"IF"					{ return IF; }
"INPUT"					{ return INPUT; }
"LET" ;
"PRINT"					{ return PRINT; }
"READ"					{ return READ; }
"REM"[^\n]* ;
"THEN"					{ return THEN; }
[A-Z][A-Z0-9]*(%|$)?	{ yylval.sval = strdup(yytext); return SYM; }
.						yyerror("unknown token");
%%

int yyerror(char const *str) {
	fprintf(stderr, "line %d: %s\nnext token: %s\n", yylineno, str, yytext);
}

void parseString() {
	yylval.sval = strdup(yytext+1);
	if (yylval.sval[yyleng - 2] != '"') {
		yyerror("String not terminated with \"");
	} else
		yylval.sval[yyleng-2] = 0;
}
