include Map.Make(String)

let to_string symbol_map of_string =
	fold (fun symbol t acc -> acc ^ "Symbol " ^ symbol ^ ": " ^
		(of_string t) ^ "  ") symbol_map "" 
