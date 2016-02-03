#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "basic.h"
#include "y.tab.h"
#define MAX_STRINGS 255

FILE* f;
int stringTableSize = 0;
char* stringTable[255];

void init(FILE* outputFile) {
	if (!outputFile)
		usage();
	
	f = outputFile;
	
	symbol0.name = NULL;
	symbol0.id = 0;
	symbol0.next = NULL;

	/*if ((stringTable = malloc(sizeof((*char)) * MAX_STRINGS)) == NULL)
		printf("out of memory initializing string table");
		exit(1);*/

	fputs(";\tCreated by DealOS BASIC Compiler.\n\n",  f);
	fputs("\tSECTION .text\n", f);
	return;
}

int ex(nodeType *p) {
	if (!p) return;
	switch(p->type) {
	case typeCon:
		fprintf(f, "\tmov si, %d\n", p->con.value);
		break;
	case typeStrPtr:
		if ((stringTable[stringTableSize] = malloc(strlen(p->strPtr.ptr))) == NULL)
			yyerror("out of memory adding string to table");
		strcpy(stringTable[stringTableSize], p->strPtr.ptr);
		fprintf(f, "\tmov ax, str%d\n", stringTableSize++);
		break;

	case typeSym:
		if (p->sym.sym == NULL)
			yyerror("Syntax error, variable unassigned.");
		switch(p->sym.sym->type) {
		case INTEGER:
			fprintf(f, "\tmov ax, %d\n", p->sym.sym->ival);
			break;

		case STRING:
			fprintf(f, "\tmov ax, [sym%d]\n", p->sym.sym->id);
			break;
		}
		break;

	case typeOpr:
		switch(p->opr.oper) {
		case CLS:
			fputs("\tmov ah, 0\n", f);
			fputs("\tmov al, 0\n", f);
			fputs("\tint 10h\n", f);
			break;

		case END:
			fputs("\tjmp $\n", f);
			break;

		case PRINT:
			ex(p->opr.op[0]);
			fputs("\tmov si, ax\n", f);
			fputs("\tcall print\n", f);
			fputs("\tmov ah, 0x0E\n", f);
			fputs("\tmov al, 0x0D\n", f); 
			fputs("\tint 10h\n", f); 
			fputs("\tmov al, 0x0A\n", f); 
			fputs("\tint 10h\n", f); 
			break;

		case '=':
			switch(p->opr.op[0]->sym.sym->type) {
			case INTEGER:
				if(p->opr.op[1]->type != typeCon)
					yyerror("Syntax error, assigning string to numeric variable.");
				fprintf(f, "\tmov [sym%d], word %d\n", p->opr.op[0]->sym.sym->id, p->opr.op[1]->con.value);
				break;

			case STRING:
				if(p->opr.op[1]->type != typeStrPtr)
					yyerror("Syntax error, assigning number to string variable.");
				ex(p->opr.op[1]);
				fprintf(f, "\tmov [sym%d], ax\n", p->opr.op[0]->sym.sym->id);
				break;
			}
			break;
		}
	}
	return 0;
}

int final() {
	int i;

	fputs("\tjmp $\n\n", f);
	fputs("\%include \"blib.asm\"\n\n", f);
	fputs("\tSECTION .data\n", f);
	for(i = 0; i < stringTableSize; i++) {
		fprintf(f, "str%d\tdb\t\"%s\", 0\n", i, stringTable[i]);
		free(stringTable[i]);
	}

	fputs("\n\tSECTION .bss\n", f);
	struct symbol* prev = &symbol0;	
	struct symbol* s = prev->next;

	while (s != NULL) {
		switch (s->type) {
		case INTEGER:
			fprintf(f, "sym%d: resw 1\n", s->id);
			break;

		case STRING:
			fprintf(f, "sym%d: resb 255\n", s->id);
			break;
		}

		prev = s;
		s = s->next;
		free(prev);
	}

	return 0;
}
