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

	/*if ((stringTable = malloc(sizeof((*char)) * MAX_STRINGS)) == NULL)
		printf("out of memory initializing string table");
		exit(1);*/

	fputs(";	Created by DealOS BASIC Compiler.\n\n",  f);
	return;
}

int ex(nodeType *p) {
	if (!p) return;
	switch(p->type) {
	case typeStrPtr:
		if ((stringTable[stringTableSize] = malloc(strlen(p->strPtr.ptr))) == NULL)
			yyerror("out of memory adding string to table");
		strcpy(stringTable[stringTableSize], p->strPtr.ptr);
		fprintf(f, "\tmov si, str%d\n", stringTableSize++);
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
				fputs("\tcall print\n", f);
				break;
		}
	}
	return 0;
}

int final() {
	int i;

	fputs("jmp $\n\n", f);
	fputs("\%include \"blib.asm\"\n\n", f);
	for(i = 0; i < stringTableSize; i++) {
		fprintf(f, "str%d\tdb\t\"%s\", 0\n", i, stringTable[i]);
		free(stringTable[i]);
	}

	return 0;
}
