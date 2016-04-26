open Printf
open TAC

let call oc symbol func =
	match func with
	| Print (Char n, lval) ->
		fprintf oc "\tmov si, [%s]\n" (symbol lval);
		fprintf oc "\tmov cx, %d\n" n;
		output_string oc "\tcall print\n"

	| Print (Int16, lval) ->
		fprintf oc "\tmov ax, [%s]\n" (symbol lval);
		output_string oc "\tcall intToStr\n";
		output_string oc "\tmov si, di\n";
		output_string oc "\tmov cx, bx\n";
		output_string oc "\tcall print\n"
