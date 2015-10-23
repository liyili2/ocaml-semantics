module OCAML-SYNTAX

    syntax AExp ::= Int
		 | "(" Exp ")" [bracket]
                 | Exp "*" Exp [left]
		 | Exp "/" Exp [left]
		 > Exp "+" Exp [left]
		 | Exp "-" Exp [left]
		  > Exp Exp [left]

    syntax BExp ::= Bool 
		| "(" BExp ")" [bracket]
		| BExp "||" BExp [left]
		| BExp "&&" BExp [left] 

    syntax Exp ::= AExp | BExp 	


endmodule
