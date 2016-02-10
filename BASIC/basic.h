#ifndef __BASIC_H__
#define __BASIC_H__
void init(FILE*);
int final();
int stmtno;

typedef enum { typeList, typeCon, typeStrPtr, typeSym, typeOpr } nodeEnum;


typedef struct {
	struct nodeTypeTag* node;
	struct nodeTypeTag* next;
} listNodeType;

typedef struct {
	int value;
} conNodeType;

typedef struct {
	char* ptr;
} strPtrNodeType;

typedef struct {
	struct symbol* sym;
} symNodeType;

typedef struct {
	int oper;
	int nops;
	struct nodeTypeTag **op;
} oprNodeType;

typedef struct nodeTypeTag {
	nodeEnum type;

	union {
		listNodeType list;
		conNodeType con;
		strPtrNodeType strPtr;
		symNodeType sym;
		oprNodeType opr;
	};
} nodeType;

struct symbol {
	char* name;
	int id;
	int type;
	union {
		int ival;
		char* sptr;
	};
	struct symbol* next;
} symbol0;

#endif
