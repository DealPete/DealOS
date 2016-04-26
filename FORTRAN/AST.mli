type expr =
	| BinOp of Types.op_type * expr * expr
	| Con of Types.ocaml_const
	| Sym of string

type stmt =
	| CALL of string * expr list
	| ASSIGN of string * expr
	| PRINT of expr
	| READ of string
	| RETURN
	| WRITE of expr

type subroutine = {
	commons: string list;
	name: string;
	parameters: string list;
	locals: Types.id list;
	main: stmt list
}

type program = {
	commons: string list;
	globals: Types.id list;
	main: stmt list;
	subroutines: subroutine list
}
