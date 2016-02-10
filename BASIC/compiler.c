#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "basic.h"
#include "y.tab.h"
#define MAX_STRINGS 255

FILE* f;
int stringTableSize = 0;
char* stringTable[256];
int DATATableSize = 0;
int dataTable[65536];

void init(FILE* outputFile) {
	stmtno = 0;

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
	fputs("\tmov [doffset], word DATA\n", f); 
	return;
}

void addData(int value) {
	dataTable[DATATableSize++] = value; 
}

void labelLine(int lnum) {
	fprintf(f, "l%d:\n", lnum);
}

int ex(nodeType *p) {
	if (!p) return;
	switch(p->type) {
	case typeCon:
		fprintf(f, "\tpush %d\n", p->con.value);
		return INTEGER;

	case typeStrPtr:
		if ((stringTable[stringTableSize] = malloc(strlen(p->strPtr.ptr))) == NULL)
			yyerror("out of memory adding string to table");
		strcpy(stringTable[stringTableSize], p->strPtr.ptr);
		fprintf(f, "\tmov si, str%d\n", stringTableSize++);
		return STRING;

	case typeSym:
		if (p->sym.sym == NULL)
			yyerror("Syntax error, variable unassigned.");
		switch(p->sym.sym->type) {
		case INTEGER:
			fprintf(f, "\tpush word [sym%d]\n", p->sym.sym->id);
			return INTEGER;

		case STRING:
			fprintf(f, "\tmov si, sym%d\n", p->sym.sym->id);
			return STRING;
		}
		break;

	case typeList:
		if (p->list.next)
			ex(p->list.next);
		else
			fputs("\tmov cx, 0\n", f);

		fprintf(f, "\tpush sym%d\n", p->list.node->sym.sym->id);
		fputs("\tinc cx\n", f);
		break;

	case typeOpr:
		switch(p->opr.oper) {
		int i;
		case CLS:
			fputs("\tmov ah, 0\n", f);
			fputs("\tmov al, 0\n", f);
			fputs("\tint 10h\n", f);
			break;

		case END:
			fputs("\tjmp $\n", f);
			break;
		
		case GOTO:
			fprintf(f, "\tjmp l%d\n", p->opr.op[0]->con.value);
			break;

		case IF:
			ex(p->opr.op[0]);
			fputs("\tpop ax\n", f);
			fputs("\tcmp ax, 0xFFFF\n", f);
			fprintf(f, "\tje l%d\n", p->opr.op[1]->con.value);
			break;

		case READ:
			ex(p->opr.op[0]);
			fprintf(f, ".loop%d:\n", stmtno);
			fputs("\tmov bx, [doffset]\n", f);
			fputs("\tmov ax, [bx]\n", f);
			fputs("\tpop bx\n", f);
			fputs("\tmov [bx], ax\n", f);
			fputs("\tadd [doffset], word 2\n", f);
			fprintf(f, "\tloop .loop%d\n", stmtno);
			break;

		case INPUT:
			ex(p->opr.op[0]);
			fputs("\tpush cx\n", f);
			fputs("\tcall getInput\n", f);
			fputs("\tmov ax, 2\n", f);
			fputs("\tpop cx\n", f);
			fputs("\tmul cx\n", f);
			fputs("\tadd sp, ax\n", f);
			break;

		case LET:
			switch(p->opr.op[0]->sym.sym->type) {
			case INTEGER:
				if(ex(p->opr.op[1]) != INTEGER)
					yyerror("Syntax error, assigning string to numeric variable.");
				fputs("\tpop ax\n", f);
				fprintf(f, "\tmov [sym%d], ax\n", p->opr.op[0]->sym.sym->id);
				break;

			case STRING:
				if(ex(p->opr.op[1]) != STRING)
					yyerror("Syntax error, assigning number to string variable.");
				fprintf(f, "\tmov [sym%d], si\n", p->opr.op[0]->sym.sym->id);
				break;
			}
			break;

		case PRINT:
			for(i = 0; i < p->opr.nops; i++) {
				switch(ex(p->opr.op[i])) {
				case INTEGER:
					fputs("\tmov al, byte 0x20\n", f);
					fputs("\tmov ah, 0Eh\n", f);
					fputs("\tint 10h		; space before number...\n", f);
					fputs("\tpop ax\n", f);
					fputs("\tcall intToStr\n", f);
					fputs("\tmov si, di\n", f);
					fputs("\tcall print\n", f);
					fputs("\tmov al, byte 0x20\n", f);
					fputs("\tmov ah, 0Eh\n", f);
					fputs("\tint 10h		; ...and space after.\n", f);
					break;

				case STRING:
					fputs("\tcall print\n", f);
					break;
				}
			}
			break;

		case '+':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop ax\n", f);
			fputs("\tpop dx\n", f);
			fputs("\tadd ax, dx\n", f);
			fputs("\tpush ax\n", f);
			return INTEGER;
			break;

		case '-':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop dx\n", f);
			fputs("\tpop ax\n", f);
			fputs("\tsub ax, dx\n", f);
			fputs("\tpush ax\n", f);
			return INTEGER;
			break;

		case '*':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop ax\n", f);
			fputs("\tpop dx\n", f);
			fputs("\tmul dx\n", f);
			fputs("\tpush ax\n", f);
			return INTEGER;
			break;

		case '/':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop bx\n", f);
			fputs("\tpop ax\n", f);
			fputs("\txor dx, dx\n", f);
			fputs("\tdiv bx\n", f);
			fputs("\tpush ax\n", f);
			return INTEGER;
			break;

		case '=':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop ax\n", f);
			fputs("\tpop dx\n", f);
			fputs("\tcmp ax, dx\n", f);
			fprintf(f, "\tje .equ%d\n", stmtno); 
			fputs("\tpush 0x0000\n", f);
			fprintf(f, "jmp .end%d\n", stmtno);
			fprintf(f, ".equ%d:\n", stmtno);
			fputs("\tpush 0xFFFF\n", f);
			fprintf(f, ".end%d:\n", stmtno);
			return 0;
			break;

		case '<':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop dx\n", f);
			fputs("\tpop ax\n", f);
			fputs("\tcmp ax, dx\n", f);
			fprintf(f, "\tjl .lt%d\n", stmtno); 
			fputs("\tpush 0x0000\n", f);
			fprintf(f, "jmp .end%d\n", stmtno);
			fprintf(f, ".lt%d:\n", stmtno);
			fputs("\tpush 0xFFFF\n", f);
			fprintf(f, ".end%d:\n", stmtno);
			return 0;
			break;

		case '>':
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			fputs("\tpop dx\n", f);
			fputs("\tpop ax\n", f);
			fputs("\tcmp ax, dx\n", f);
			fprintf(f, "\tjg .gt%d\n", stmtno); 
			fputs("\tpush 0x0000\n", f);
			fprintf(f, "jmp .end%d\n", stmtno);
			fprintf(f, ".gt%d:\n", stmtno);
			fputs("\tpush 0xFFFF\n", f);
			fprintf(f, ".end%d:\n", stmtno);
			return 0;
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
	fputs("DATA:\n", f);

	for(i = 0; i < DATATableSize; i++)
		fprintf(f, "\tdw %d\n", dataTable[i]);

	for(i = 0; i < stringTableSize; i++) {
		fprintf(f, "str%d\tdb\t`%s`, 0\n", i, stringTable[i]);
		free(stringTable[i]);
	}

	fputs("\n\tSECTION .bss\n", f);
	struct symbol* prev = &symbol0;	
	struct symbol* s = prev->next;

	fprintf(f, "doffset: resw 1\t; Beginning of data from DATA statements.\n");
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

	fputs("\nheap:", f);
	
	return 0;
}
