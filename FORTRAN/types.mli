type location =
	| Global of int
	| Stack of int

val string_of_loc : location -> string

type t = Char of int | Int16 | Int32 | Float | Double | Bool

val string_of_t : t -> string

type symbol = t * location

val string_of_symbol : symbol -> string

type id = string * t

type ocaml_const =
	| Int of int
	| String of string
	| Float of float

type op_type =
	ADD | SUB | MULT | DIV

val type_size : t -> int
