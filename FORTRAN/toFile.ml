open Printf
open Types
open TAC 

let strings = Hashtbl.create 255

let go oc (main : op list) (symbols : Types.symbol SymbolMap.t) =
	let symbol = function
	| `Temp n ->
		"heap + " ^ string_of_int (n * 2) (* assumes 16-bit temps atm *)
	| `Var sym -> (
		try
			match SymbolMap.find sym symbols with
			| (_, Global n) -> "ID_" ^ sym
			| (_, Stack n) -> "bp - " ^ string_of_int n
		with
			Not_found -> failwith "Can't find symbol " ^ sym
	)
	| _ -> failwith "Can't compute address of constant rval" in

	List.iter (function 
		| BinOp (ADD, target, source1, source2) ->
			fprintf oc "\tmov ax, [%s]\n" (symbol source1);
			fprintf oc "\tadd ax, [%s]\n" (symbol source2);
			fprintf oc "\tmov [%s], ax\n" (symbol target)
		| BeginSub name ->
			fprintf oc "\n%s:\n" name
		| Call proc ->
			fprintf oc "\tcall %s\n" proc
		| EndProgram ->
			output_string oc "\tjmp $\n"
		| Flib func ->
			Flib.call oc symbol func
		| FuncProlog ->
			output_string oc "\tpush bp\n";
			output_string oc "\tmov bp, sp\n"
		| PopParams bytes ->
			fprintf oc "\tadd sp, %d\n" bytes;
			output_string oc "\tpop bp\n"
		| Push param ->
			(match param with
			| `Con (Int i, Int16) ->
				fprintf oc "\tpush %d\n" i
			| sym ->	(* assume Int16 atm *)
				fprintf oc "\tmov ax, [%s]\n" (symbol sym);
				output_string oc "\tpush ax\n")
		| Return ->
			output_string oc "\tret\n"
		| VarEq (lval, rval) ->
			(match rval with
			| `Con (String str, _) ->
				let strVar = "str" ^ (string_of_int (Hashtbl.length strings)) in
				Hashtbl.add strings str strVar;
				fprintf oc "\tmov ax, %s\n" strVar;
				fprintf oc "\tmov [%s], ax\n" (symbol lval)
			| `Con (Int i, _) ->
				fprintf oc "\tmov word [%s], %d\n" (symbol lval) i
			| sym -> (* assumes Int16 atm *)
				fprintf oc "\tmov ax, [%s]\n" (symbol sym);
				fprintf oc "\tmov [%s], ax\n" (symbol lval))	
		| _ ->
			failwith "Error, unrecognized three address code."
	) main

let write (program : TAC.program) =
	let oc = open_out (Sys.argv.(1) ^ ".asm") in
	output_string oc ";	Created by DealOS FORTRAN Compiler.\n\n";
	output_string oc "SECTION .text\n";

	go oc program.main program.global_symbol_table; 
	
	List.iter (fun (sub : TAC.subroutine) -> go oc sub.main sub.local_symbol_table)
		program.subroutines;
	
	output_string oc "\n%include \"flib.asm\"\n\n";
	output_string oc "SECTION .data\n\n";

	Hashtbl.iter (fun str name ->
		fprintf oc "%s\tdb\t%s\n" name ("\"" ^ str ^ "\"")) strings;

	output_string oc "\nSECTION .bss\n\n";

	SymbolMap.iter (fun key (t, _) ->
		fprintf oc "ID_%s: resb %d\n" key (type_size t)
		) program.global_symbol_table;

	output_string oc "\nheap:\n"
