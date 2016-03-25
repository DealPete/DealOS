open TypesTAC
open TypesAST

let rec go tree =
	match tree with
	| Tree (left, right) -> go left @ go right
	| Leaf (END, 0, []) ->
		[(End, NOP, NOP)]
	| Leaf (PRINT, 1, [String op]) -> 
		[(Param, StrCon op, NOP); (Call, Proc "print", NOP)]
