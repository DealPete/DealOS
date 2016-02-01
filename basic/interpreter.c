#include <stdio.h>
#include "basic.h"
#include "y.tab.h"

char* eval(nodeType* p) {
	return p->strPtr.ptr;
}

void init(FILE* outputFile) {
	return;
}

int final() {
	return 0;
}

int ex(nodeType* p) {
	if (!p) return 0;
	switch(p->type) {
		case typeOpr:
		switch (p->opr.oper) {
			case CLS:	printf("Clearing the screen.");
						return 0;
			case PRINT: printf("%s\n", eval(p->opr.op[0]));
						return 0;
		}
	}
}

