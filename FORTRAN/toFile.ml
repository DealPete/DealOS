open Printf
open TypesTAC

let strings = Hashtbl.create 255

let rec go tac oc =
	match tac with
	[] -> ()
	| (hd::tl) -> 
		(match hd with
		| (Call, Proc proc, NOP) ->
			output_string oc "\tcall print\n"
		| (End, NOP, NOP) ->
			output_string oc "\tjmp $\n"
		| (Param, StrCon str, NOP) ->
			let strVar = "str" ^ (string_of_int (Hashtbl.length strings)) in
			Hashtbl.add strings str strVar;
			fprintf oc "\tmov si, %s\n" strVar
		| _ ->
			failwith "Error, unrecognized three address code.");
		go tl oc

let write tac =
	let oc = open_out (Sys.argv.(1) ^ ".asm") in
	output_string oc ";	Created by DealOS FORTAN Compiler.\n\n";
	output_string oc "SECTION .text\n";

	go tac oc; 

	output_string oc "\n%include \"flib.asm\"\n\n";
	output_string oc "SECTION .data\n\n";

	Hashtbl.iter (fun str name ->
		fprintf oc "\t%s\tdb\t%s, 0\n" name str) strings
