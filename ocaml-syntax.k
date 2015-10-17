module OCAML-SYNTAX

    syntax Exp ::= Int
                 | Exp "+" Exp [left]
                 > Exp Exp [left]

endmodule
