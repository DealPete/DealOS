%{
	open TypesAST
%}

%start <TypesAST.source_tree> line

%token <string> STRING

%token COMMA
%token STAR

%token PRINT

%token SIX_SPACES
%token EOL
%token END

%%

line:
	| SIX_SPACES statement EOL { $2 }

statement:
	| PRINT STAR COMMA s = STRING	{ Leaf (PRINT, 1, [String s]) }
	| END { Leaf (END, 0, []) } 

%%
