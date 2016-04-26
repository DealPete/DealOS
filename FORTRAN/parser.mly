%{
	open Types
	open AST
%}

%start <AST.program> program 

%token <string> CON_STRING ID
%token <int> CON_INT
%token <float> CON_REAL

%token PLUS MINUS TIMES SLASH EQUALS
%token COMMA STAR LPAREN RPAREN

%token EQ FALSE TRUE

%token CHARACTER INTEGER LOGICAL REAL PARAMETER
%token CALL CONTINUE DO RETURN
%token PRINT READ WRITE

%token PROGRAM SUBROUTINE COMMON END 
%token EOL EOF

%%

program:
PROGRAM ID EOL
declares = declaration*
commons = common
lines = line*
END EOL
subs = subroutine*
EOF
	{{
		globals = List.flatten declares;
		commons = commons;
		main = lines;
		subroutines = subs
	}}

subroutine:
SUBROUTINE name = ID params = parameters EOL
declares = declaration*
commons = common
lines = line*
END EOL
	{{
		commons = commons;
		name = name;
		locals = List.flatten declares;
		parameters = params; 
		main = lines
	}}

declaration:
	| varType ids = separated_list(COMMA, ID) EOL
		{ List.map (fun id -> (id, $1)) ids }

common:
	| COMMON separated_list(COMMA, ID) EOL
		{ $2 }
	|	{ [] }

parameters:
	| delimited(LPAREN, separated_list(COMMA, ID), RPAREN)
		{ $1 }
	|	{ [] }

varType:
	| CHARACTER STAR CON_INT { Char $3 }
	| CHARACTER { Char 1 }
	| INTEGER STAR CON_INT { if $3 = 2 then Int16 else Int32 }
	| INTEGER { Int16 }
	| REAL STAR CON_INT { if $3 = 8 then Double else Float }
	| REAL { Float }
	| LOGICAL { Bool }

line:
	| statement EOL { $1 }

statement:
	| CALL ID arguments
		{ CALL ($2, $3) }
	| PRINT STAR COMMA e = expr
		{ PRINT e }
	| READ LPAREN STAR COMMA STAR RPAREN lval
		{ READ $7 }
	| RETURN
		{ RETURN }
	| WRITE LPAREN STAR COMMA STAR RPAREN e = expr
		{ PRINT e }
	| lval EQUALS expr
		{ ASSIGN ($1, $3) } 

arguments:
	| delimited(LPAREN, separated_list(COMMA, expr), RPAREN)
		{ $1 }
	|	{ [] }

expr:
	| expr PLUS expr { BinOp (ADD, $1, $3) }
	| expr MINUS expr { BinOp (SUB, $1, $3) }
	| expr TIMES expr { BinOp (MULT, $1, $3) }
	| expr SLASH expr { BinOp (DIV, $1, $3) }
	| lval { Sym $1 }
	| CON_INT { Con (Int $1) }
	| CON_STRING { Con (String $1) }
	| CON_REAL { Con (Float $1) }

lval:
	| ID LPAREN expr RPAREN { $1 }
	| ID { $1 }

%%
