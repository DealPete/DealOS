type constant =
	| Int of int
	| String of string

and stmt_type =
	PRINT | END

and stmt =
	stmt_type * int * constant list

and source_tree =
	| Leaf of stmt 
	| Tree of source_tree * source_tree

and program = {
	strings: string list;
	main: source_tree list
}
