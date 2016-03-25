{
open Lexing
open Parser

exception Error of string
}

let letter = ['A'-'Z']
let digit = ['0'-'9']
let specialCharacter = ' ' | '=' | '+' | '-' | '*' | '/' | '(' | ')' |
  '.' | ',' | '$' | '\'' | ':'
let comment = 'C' [^'\n'] '\n'
let white = [' ' '\t']
let str = '"' [^'"']+ '"'

rule line = parse
| [^'\n']* '\n' as line
	{ Some line, true }
| eof
	{ None, false }
| ([^'\n']+ as line) eof
	{ Some (line ^ "\n"), false }

and token = parse
| "      "
	{ SIX_SPACES }
| white
	{ token lexbuf }
| "\n"
	{ EOL }
| str
	{ STRING (lexeme lexbuf) } 
| ','
	{ COMMA }
| '*'
	{ STAR }
| "PRINT"
	{ PRINT }
| "END"
	{ END }
| _
	{ raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
