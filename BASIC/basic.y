%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "basic.h"

#define YYDEBUG 1

nodeType *list(nodeType* node, nodeType* next);
nodeType *con(int value);
nodeType *opr(int oper, int nops, ...);
nodeType *sym(char* ptr);
nodeType *str(char* ptr);

void addData(int);
void labelLine(int);
void freeNode(nodeType*);
int ex(nodeType*);
int yylex();
int yyerror(const char*);
%}

%union {            
    int ival;       
    char *sval;
	char sIndex;    
    nodeType *nPtr; 
}                   

%token <ival> INTEGER
%token <sval> STRING VAR
%token CLS DATA END GOTO IF THEN INPUT LET PRINT READ REM EOL

%left '=' '<' '>'
%left '+' '-'
%left '*' '/'

%type <nPtr> statement expr prexprs varlist
%%
program		: line program
			|
			;
line		: INTEGER { labelLine($1); } statements EOL
			| INTEGER { labelLine($1); } DATA datalist EOL
			| INTEGER { labelLine($1); } EOL
			| EOL
			;
statements	: statement ':' statements 	{ stmtno++; ex($1); freeNode($1); }
			| statement					{ stmtno++; ex($1); freeNode($1); }
			;
statement	: CLS					{ $$ = opr(CLS, 0); }
			| END					{ $$ = opr(END, 0); }
			| GOTO INTEGER			{ $$ = opr(GOTO, 1, con($2)); }
			| INPUT varlist			{ $$ = opr(INPUT, 1, $2); }
			| PRINT prexprs			{ $$ = opr(PRINT, 1, $2); }
			| PRINT					{ $$ = opr(PRINT, 1, str("\\n\\r")); }
			| READ varlist			{ $$ = opr(READ, 1, $2); }
			| VAR '=' expr			{ $$ = opr(LET, 2, sym($1), $3); }
			| IF expr THEN INTEGER	{ $$ = opr(IF, 2, $2, con($4)); }
			;

prexprs		: expr ';' prexprs	{ $$ = opr(PRINT, 2, $1, $3); } 
			| expr ',' prexprs	{ $$ = opr(PRINT, 3, $1, str("\\t"), $3); }
			| expr ';'			{ $$ = opr(PRINT, 1, $1); }
			| expr				{ $$ = opr(PRINT, 2, $1, str("\\n\\r")); }
			;

datalist	: INTEGER { addData($1); } ',' datalist		
			| INTEGER { addData($1); }
			;

varlist		: VAR ',' varlist	{ $$ = list(sym($1), $3); }
			| VAR 				{ $$ = list(sym($1), NULL); }
			;

expr		: expr '+' expr		{ $$ = opr('+', 2, $1, $3); }
			| expr '-' expr		{ $$ = opr('-', 2, $1, $3); }
			| expr '*' expr		{ $$ = opr('*', 2, $1, $3); }
			| expr '/' expr		{ $$ = opr('/', 2, $1, $3); }
			| expr '=' expr		{ $$ = opr('=', 2, $1, $3); }
			| expr '<' expr		{ $$ = opr('<', 2, $1, $3); }
			| expr '>' expr		{ $$ = opr('>', 2, $1, $3); }
			| INTEGER			{ $$ = con($1); }
			| STRING			{ $$ = str($1); }
			| VAR				{ $$ = sym($1); } 
			;
%%

#include "lex.yy.c"

nodeType *con(int value) {
	nodeType *p;

	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	p->type = typeCon;
	p->con.value = value;
	return p;
}

nodeType *str(char* ptr) {
	nodeType *p;

	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	p->type = typeStrPtr;
	p->strPtr.ptr = ptr;
	return p;
}

nodeType *sym(char* ptr) {
	nodeType *p;

	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	p->type = typeSym;
	
	struct symbol* s = &symbol0;

	for(;;) {
		if (s->next == NULL) {
			if ((s->next = malloc(sizeof(struct symbol))) == NULL)
				yyerror("out of memory");
			p->sym.sym = s->next;
			s->next->name = ptr;
			s->next->id = s->id + 1;
			switch (ptr[strlen(ptr) - 1]) {
			case '$':
				s->next->type = STRING;
				s->next->sptr = NULL;
				break;

			default:	
				s->next->type = INTEGER;
				s->next->ival = 0;
				break;
			}
			break;
		}

		if (!strcmp(s->next->name, ptr)) {
			p->sym.sym = s->next;
			break;
		}
		s = s->next;
	}
	return p;
}

nodeType *list(nodeType* head, nodeType* next) {
	nodeType* p;
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");

	p->type = typeList;
	p->list.node = head;
	p->list.next = next;
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
	if (p->type == typeList) {
		free(p->list.node);
		if (p->list.next)
			free(p->list.next);
	}

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
	//yydebug = 1;
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
	if (!yyparse())
		return final();
}

