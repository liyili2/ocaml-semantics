module OCAML-SYNTAX

    syntax AExp ::= Int
		 | "(" AExp ")" [bracket]
                 | AExp "*" AExp [left]
		 | AExp "/" AExp [left]
		 > AExp "+" AExp [left]
		 | AExp "-" AExp [left]

    syntax BExp ::= Bool 
		| "(" BExp ")" [bracket]
		| BExp "||" BExp [left]
		| BExp "&&" BExp [left] 

    syntax Exp ::= AExp | BExp 	| FunExp | Exp Exp



    syntax Label ::= Token{[a-z]+}  [onlyLabel]
                   | "Empty"

    syntax Pattern ::= Id 
		| "_"  [onlyLabel, klabel('patternUnderLine)]
		| Int
		| "(" Pattern ")" [bracket]
		| Pattern "as" Id
//		| "(" Pattern ":" TypeExpr ")"
		| Pattern "|" Pattern
//		| Constr Pattern
//     		...


    syntax FunExp ::= //"fun" Id "->" FunExp
			 "fun" Id "->" Exp
		//	| "fun" "[" Label "]" Pattern "->" FunExp
			| "fun" "[" Label "]" Pattern "->" Exp
			| "(" FunExp ")" [bracket]
endmodule
