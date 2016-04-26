type lval =
	[ `Var of string
	| `Temp of int ]

type rval =
	[ lval | `Con of Types.ocaml_const * Types.t ]

type library_function =
	| Print of Types.t * lval

type op =
	| BinOp of Types.op_type * lval * rval * rval 
	| BeginSub of string
	| Call of string
	| EndProgram
	| Flib of library_function
	| FuncProlog
	| PopParams of int
	| Push of rval
	| Return
	| VarEq of lval * rval

type subroutine = {
	local_symbol_table: Types.symbol SymbolMap.t;
	name: string;
	main: op list
}

type program = {
	global_symbol_table: Types.symbol SymbolMap.t;
	main: op list;
	subroutines: subroutine list
}

