#ifndef __BASIC_H__
#define __BASIC_H__
void init(FILE*);
int final();

typedef enum { typeStrPtr, typeId, typeOpr } nodeEnum;

/*typedef struct {
	int value;
} conNodeType;*/

typedef struct {
	char* ptr;
} strPtrNodeType;

typedef struct {
	int i;
} idNodeType;

typedef struct {
	int oper;
	int nops;
	struct nodeTypeTag **op;
} oprNodeType;

typedef struct nodeTypeTag {
	nodeEnum type;

	union {
		//conNodeType con;
		strPtrNodeType strPtr;
		idNodeType id;
		oprNodeType opr;
	};
} nodeType;

extern int sym[26];
#endif
