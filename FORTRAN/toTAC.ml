open AST
open SAST
open TAC
open Types

let fortran_type const =
	match const with
	| Int i -> Int16
	| String str -> Char (String.length str)
	| Float f -> Float

let translate_block statements (symbol_table : Types.symbol SymbolMap.t) =
	
	let symbol_type sym =
		try
			fst (SymbolMap.find sym symbol_table)
		with
			Not_found -> 
				failwith ("Couldn't find symbol " ^ sym) in

	(* IN: expression to be parsed and next free temp variable (i.e. "tX" X=tmp)
	   OUT: three address code for expression, last temp used, type of expression *)
	let rec go_expr expr tmp =
		match expr with
		| AST.BinOp (op, lhs, rhs) ->
			let (lhs_ops, lhs_tmp, lhs_typ) = go_expr lhs (tmp + 1) in
			let (rhs_ops, rhs_tmp, rhs_typ) = go_expr rhs (lhs_tmp + 1) in
			if lhs_typ <> rhs_typ then failwith "Type error.";
			(lhs_ops @ rhs_ops @ [BinOp (op, `Temp tmp,
				(`Temp (tmp + 1)), (`Temp (lhs_tmp + 1)))], rhs_tmp, lhs_typ)
		| Con con ->
			let typ = fortran_type con in
			([VarEq (`Temp tmp, `Con (con, typ))], tmp, typ)
		| Sym var ->
			([VarEq (`Temp tmp, `Var var)], tmp, symbol_type var) in

	let rec go stmt =
		match stmt with
		| ASSIGN (var, expr) ->
			let code, _, _ = go_expr expr 0 in
			code @ [VarEq (`Var var, `Temp 0)]
		| CALL (sub, args) ->
			[FuncProlog] @ 
			let args = List.map (fun expr ->
				go_expr expr 0) args in	
			List.flatten (List.map (fun (code, _, typ) ->
				code @ [Push (`Temp 0)]
			) args) @ [Call sub]
			@ [PopParams (List.fold_left (fun acc (_, _, typ) ->
				type_size typ + acc) 0 args)]
		| PRINT expr ->
			let code, _, typ = go_expr expr 0 in
				code @ [Flib (Print (typ, `Temp 0))]
		| RETURN ->
			[Return]
		| _ -> failwith "Unrecognized statement type." in

	List.concat (List.map go statements)

let toTAC (p : SAST.program) : TAC.program =
	{
		global_symbol_table = p.global_symbol_table;
		main = translate_block p.main p.global_symbol_table @ [EndProgram];
		subroutines =
		List.map (fun (sub : SAST.subroutine) ->
		{
			local_symbol_table = sub.local_symbol_table;
			name = sub.name;
			main = 
				[BeginSub sub.name] @
				translate_block sub.main sub.local_symbol_table
				@ [Return]
		}) p.subroutines
	}
