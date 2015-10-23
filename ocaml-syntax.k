module OCAML-SYNTAX

    syntax Exp ::= Int
		 | "(" Exp ")" [bracket]
                 | Exp "*" Exp [left]
		 | Exp "/" Exp [left]
		 > Exp "+" Exp [left]
		 | Exp "-" Exp [left]
		  > Exp Exp [left]




endmodule
