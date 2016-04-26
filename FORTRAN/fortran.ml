let rec repeat channel =
	let optional_line, continuation, continue = Lexer.line channel in
	let nextline = match optional_line with
	| None ->
		""
	| Some line ->
		line in
	let returnline =
		if continue then repeat channel
			else ("", false) in
	match returnline with
	| (line, true) -> 
		(String.sub nextline 0 ((String.length nextline) - 1) ^ line, continuation)
	| (line, false) ->
		(nextline ^ line, continuation)

let preprocess channel =
	match repeat channel with
	| (line, _) -> Lexing.from_string (line ^ "~")

let () =
	if Array.length Sys.argv = 1 then
		print_string ("Usage: " ^ Sys.argv.(0) ^ " <source file name (sans extension)>\n")
	else
		let progbuf = Lexing.from_channel (open_in (Sys.argv.(1) ^ ".f")) in
		let progbuf = preprocess progbuf in
		(
			try
				Parser.program Lexer.token progbuf
			with
			| Parser.Error ->
				let curr = progbuf.Lexing.lex_curr_p in
				let line = curr.Lexing.pos_lnum in
				let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
				let tok = Lexing.lexeme progbuf in
				Printf.fprintf stderr "line: %d, column: %d, lexeme: %s\n%!" line cnum tok;
				failwith "Program failed to compile."
		)
		|> ToSAST.add_symbol_table |> ToTAC.toTAC |> ToFile.write
