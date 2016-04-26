type location =
	| Global of int
	| Stack of int

let string_of_loc (loc : location) =
	match loc with
	| Global n -> "Global " ^ string_of_int n
	| Stack n -> "Stack " ^ string_of_int n

type t = Char of int | Int16 | Int32 | Float | Double | Bool

let string_of_t (t : t) =
	match t with
	| Char n -> "Char " ^ string_of_int n
	| Int16 -> "Int16 "
	| Int32 -> "Int32 "
	| Float -> "Float "
	| Double -> "Double "
	| Bool -> "Bool "

type symbol = t * location

let string_of_symbol ((t, loc) : symbol) =
	(string_of_t t) ^ (string_of_loc loc)

type id = string * t

type ocaml_const =
	| Int of int
	| String of string
	| Float of float

type op_type =
	ADD | SUB | MULT | DIV

let type_size = function
    | Char _ -> 2
    | Bool -> 1
    | Int16 -> 2
    | Int32 | Float -> 4
    | Double -> 8
