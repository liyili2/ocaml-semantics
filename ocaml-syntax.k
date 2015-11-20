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

    syntax Exp ::= AExp | BExp 	| FunExp
                 | Id
                 | Exp Exp [left]
                 | Exp ";" Exp [left,onlyLabel,klabel('ocamlSeq)]
                 | "if" Exp "then" Exp "else" Exp  [klabel('ocamlIf),onlyLabel]
                 | "let" Exp "=" Exp "in" Exp
                 | "let" "rec" Exp "=" Exp "in" Exp
                 | "match" Exp "with" Exp "->" Exp
                 | "try" Exp "with" Exp "->" Exp
                 | "[" Exps "]"   [klabel('ocamlList),onlyLabel]
                 | "(" Tuples ")" [klabel('tuple),onlyLabel]

    syntax Exps  ::= List{Exp,";"}
    syntax Tuples ::= Exp "," TupleNext [klabel('tupleFirst)]
    syntax TupleNext ::= Exp | Exp "," TupleNext [klabel('tupleSecond)]

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
		//	| "fun" "x" "->" Exp
		//	| "fun" "[" Label "]" Pattern "->" FunExp
			| "fun" "[" Label "]" Pattern "->" Exp
			| "(" FunExp ")" [bracket]
endmodule
