{
open Lexing
open Parser

exception Error of string

let update_loc lexbuf =                 
	let pos = lexbuf.lex_curr_p in        
	lexbuf.lex_curr_p <- { pos with       
		pos_lnum = pos.pos_lnum + 1;        
		pos_bol = pos.pos_cnum;             
	}                                     

}

let letter = ['A'-'Z']
let specialCharacter = ' ' | '=' | '+' | '-' | '*' | '/' | '(' | ')' |
  '.' | ',' | '$' | '\'' | ':'
let white = [' ' '\t']
let digit = ['0'-'9']
let integer = ('+' | '-')? ['1'-'9']* digit
let real = integer '.' digit* ('e' integer)?
(* This rule returns a triple of an optional string (None if no line or a
	comment), and two Boolean flags (whether the line is a continuation
	line, and whether eof was reached *)

rule line = parse
| '\n'		(* blank line *)
	{ None, false, true }
| "C" [^'\n']* '\n'		(* comment *)
	{ None, false, true }
| "     " [^' ' '\t' '0'] ([^'\n']* '\n' as line) (* continuation line *)
	{ Some line, true, true }
| [^'\n']* '\n' as line			(* regular line *)
	{ Some line, false, true }
| eof
	{ None, false, false }

and token = parse
| '"' ([^'"']* as text) '"'
	{ CON_STRING text }
| '\'' ([^'\'']* as text) '\'' 
	{ CON_STRING text }
| '~'					(* this character is added by the preprocessor *)
	{ EOF }				(* to signify the end of the input file *)
| '\n'
	{ update_loc lexbuf; EOL }
| white
	{ token lexbuf }
| real
	{ CON_REAL (float_of_string (lexeme lexbuf)) }
| integer
	{ CON_INT (int_of_string (lexeme lexbuf)) }
| ','
	{ COMMA }
| '+'
	{ PLUS }
| '-'
	{ MINUS }
| '*'
	{ STAR }
| '/'
	{ SLASH }
| '='
	{ EQUALS }
| '('
	{ LPAREN }
| ')'
	{ RPAREN }
| ".EQ."
	{ EQ }
| ".FALSE."
	{ FALSE }
| ".TRUE."
	{ TRUE }
| "CALL"
	{ CALL }
| "CHARACTER"
	{ CHARACTER }
| "COMMON"
	{ COMMON }
| "CONTINUE"
	{ CONTINUE }
| "DO"
	{ DO }
| "END"
	{ END }
| "INTEGER"
	{ INTEGER }
| "LOGICAL"
	{ LOGICAL }
| "PARAMETER"
	{ PARAMETER }
| "PROGRAM"
	{ PROGRAM }
| "PRINT"
	{ PRINT }
| "READ"
	{ READ }
| "REAL"
	{ REAL }
| "RETURN"
	{ RETURN }
| "SUBROUTINE"
	{ SUBROUTINE }
| "WRITE"
	{ WRITE }
| letter (letter|digit)* 
	{ ID (lexeme lexbuf) }
| _
	{ raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
