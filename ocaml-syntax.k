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

    syntax Exp ::= AExp | BExp 	| FunExp

    syntax Label ::= Token{[a-z]+}  [onlyLabel]



    syntax Pattern ::= Id 
		| "_"
		| Int
		| "(" Pattern ")" [bracket]
		| Pattern "as" Id
//		| "(" Pattern ":" TypeExpr ")"
		| Pattern "|" Pattern
//		| Constr Pattern
//     		...


    syntax FunExp ::= "fun" "[" Label "]" Pattern "->" Exp

endmodule
