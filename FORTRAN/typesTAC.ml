type opcode = 
	Param | Call | End

and operand =
	Proc of string | StrCon of string | NOP

and op = opcode * operand * operand 
