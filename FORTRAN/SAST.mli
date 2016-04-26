type subroutine = {
	local_symbol_table: Types.symbol SymbolMap.t;
	name: string;
	main: AST.stmt list
}

type program = {
	global_symbol_table: Types.symbol SymbolMap.t;
	main: AST.stmt list;
	subroutines: subroutine list
}
