%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include "basic.h"

nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *str(char* ptr);

void freeNode(nodeType* p);
int ex(nodeType* p);

int sym[26];
int yyerror(const char*);
%}

%union {            
    int ival;       
    char *sval;
	char sIndex;    
    nodeType *nPtr; 
}                   

%token <ival> INTEGER
%token <sval> STRING
%token CLS END PRINT

%type <nPtr> statement expr
%%
program		: line program	
			|
			;
line		: lnum statements	
			;
statements	: statement ':' statements 	{ ex($1); freeNode($1); }
			| statement					{ ex($1); freeNode($1); }
			;
lnum		: INTEGER
			;
statement	: CLS				{ $$ = opr(CLS, 0); }
			| END				{ $$ = opr(END, 0); }
			| PRINT expr		{ $$ = opr(PRINT, 1, $2); }
			;

expr		: STRING			{ $$ = str($1); }
			;
%%

#include "lex.yy.c"

nodeType *str(char* ptr) {
	nodeType *p;

	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	p->type = typeStrPtr;
	p->strPtr.ptr = ptr;
	return p;
}

nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	int i;

	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	if ((p->opr.op = malloc(nops * sizeof(nodeType*))) == NULL)
		yyerror("out of memory");
	
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);
	return p;
}

void freeNode(nodeType* p) {
	int i;

	if (!p) return;
	if (p->type == typeOpr) {
		for(i = 0; i < p->opr.nops; i++)
			freeNode(p->opr.op[i]);
		free(p->opr.op);
	}

	free(p);
}

int usage() {
	printf("Usage: basic INPUTFILE [OUTPUTFILE]\n");
	exit(1);	
}

int main(int argc, char** argv) {
    if (argc == 1) {
		usage();
    }
    FILE *parseFile = fopen(argv[1], "r");
    if (!parseFile) {
        printf("Can't open %s!\n", argv[1]);
		exit(1);	
    }
	if (argc > 2) {
		FILE *outputFile = fopen(argv[2], "w");
		if (!outputFile) {
			printf("Can't open %s!\n", argv[2]);
			exit(1);
		}
		init(outputFile);
	} else
		init(NULL);
    yyin = parseFile;
	yyparse();
	return final();
}

