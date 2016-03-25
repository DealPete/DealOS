		
let process (line : string) =
	let linebuf = Lexing.from_string line in
(*	try*)
		ToTAC.go (Parser.line Lexer.token linebuf)
(*	with
	| Lexer.Error msg ->
		Printf.fprintf stderr "%s%!" msg
	| Parser.Error ->
		Printf.fprintf stderr "At offset %d: syntax error.\n%!" (Lexing.lexeme_start linebuf)
*)

let process (optional_line : string option) =
	match optional_line with
	| None ->
		[]
	| Some line ->
		process line

let rec processLines channel =
	let optional_line, continue = Lexer.line channel in
	let line = process optional_line in
	if continue then
		line @ processLines channel
	else
		line

let () =
	if Array.length Sys.argv = 1 then
		print_string ("Usage: " ^ Sys.argv.(0) ^ " <source file name (sans extension)>\n")
	else
		ToFile.write (processLines (Lexing.from_channel (open_in (Sys.argv.(1) ^ ".f"))))
