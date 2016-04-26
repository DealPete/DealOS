open AST
open SAST
open Types

let make_commons commons symbols =
	List.fold_left (fun (bytes, sym_map) common ->
		let sym, t = (
			try
				List.find (fun (id, t) -> id = common) symbols
			with
				Not_found ->
				failwith "Common variable not declared."
		) in
		(bytes + type_size t, SymbolMap.add sym (t, Global bytes) sym_map)) 
		(0, SymbolMap.empty) commons

let find_implicits symbols stmts =
	List.fold_left (fun acc stmt ->
		match stmt with
		| ASSIGN (sym, expr) ->
			if List.exists (fun (sym', t) -> sym = sym') symbols then
				acc
			else (
				match sym.[0] with
				| 'I' .. 'N' -> (sym, Int16)
				| _ -> (sym, Float)
			)::acc
		| _ -> acc) [] stmts
	
let add_local_symbol_table (subroutine : AST.subroutine) : SAST.subroutine =
	let _, commons_map = make_commons subroutine.commons subroutine.locals in
	{
		main = subroutine.main;
		name = subroutine.name;
		local_symbol_table = snd (
			List.fold_left (fun (bytes, sym_map) (sym, t) ->
				try
					bytes, SymbolMap.add sym (SymbolMap.find sym commons_map) sym_map
				with
					Not_found ->
						bytes + type_size t, SymbolMap.add sym
							(t, Stack (bytes + type_size t)) sym_map
				) (0, SymbolMap.empty)
				(subroutine.locals @ find_implicits subroutine.locals subroutine.main)
		)
	}

let add_symbol_table (program : AST.program) : SAST.program =
	let count, commons_map = make_commons program.commons program.globals in
	{
		global_symbol_table = snd (
			List.fold_left (fun (bytes, sym_map) (sym, t) ->
				try
					bytes, SymbolMap.add sym (SymbolMap.find sym commons_map) sym_map
				with
					Not_found ->
						bytes + type_size t, SymbolMap.add sym (t, Global bytes) sym_map
				) (0, SymbolMap.empty)
					(program.globals @ find_implicits program.globals program.main)
		);
		main = program.main;
		subroutines = List.map add_local_symbol_table program.subroutines
	}		
