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

    syntax LowerCaseName ::= Token{[a-z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax CapitalizedName ::= Token{[A-Z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax Identifier ::= LowerCaseName | CapitalizedName

    syntax ValueName ::= LowerCaseName
                       | "(" OperatorName ")"
    syntax OperatorName ::= PrefixSymbol | InfixOp
    syntax PrefixSymbol ::= Token{[\!][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]*}
                            [onlyLabel]
                          | Token{[\? \~][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]+}
                            [onlyLabel]

    syntax InfixSymbol ::= Token{[\= \< \> \@ \^ \| \& \+ \- \* \/ \$ \%][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]*}
                       [onlyLabel]
    syntax InfixOp ::= InfixSymbol
                     | "*"    [prefer]
                     | "+"    [prefer]
                     | "-"    [prefer]
                     | "-."   [prefer]
                     | "="    [prefer]
                     | "!="   [prefer]
                     | "<"    [prefer]
                     | ">"    [prefer]
                     | "or"   [prefer]
                     | "||"   [prefer]
                     | "&"    [prefer]
                     | "&&"   [prefer]
                     | ":="   [prefer]
                     | "mod"  [prefer]
                     | "land" [prefer]
                     | "lor"  [prefer]
                     | "lxor" [prefer]
                     | "lsl"  [prefer]
                     | "lsr"  [prefer]
                     | "asr"  [prefer]

    syntax Constant ::= IntegerLiteral | FloatLiteral | CharLiteral | StringLiteral
                       | Constr | "false" | "true" | "()" | "begin" "end"
                       | "[]" | "[||]" | "`" CapitalizedName
    syntax IntegerLiteral ::= Token{[\-]?[0-9][0-9 \_]*} [onlyLabel, prefer]
 	           | Token{[\-]?([0x]| [0X])[0-9 A-F a-f][0-9 A-F a-f \_]*}
                     [onlyLabel]
                   | Token{[\-]?([0o]| [0O])[0-7][0-7 \_]*}
                     [onlyLabel]
                   | Token{[\-]?([0b]| [0B])[0-1][0-1 \_]*}
                     [onlyLabel]
    syntax FloatLiteral ::= Token{[\-]?[0-9][0-9 \_]*([\.][0-9 \_]*)?(([e]|[E])([\+]|[\-])?[0-9][0-9 \_]*)?}
                     [onlyLabel]
    syntax CharLiteral ::= Token{[\'] (~[\' \\]) [\']} [onlyLabel]
                          | Token{[\'](([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f]))[\']}        
                            [onlyLabel]
    syntax StringLiteral ::= Token{[\"] (~[\" \\] | (([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f])) | ([\\][\n][\t \ ]))* [\"]} [onlyLabel]


    syntax Constr ::= ConstrName
    syntax ConstrName ::= CapitalizedName | CapitalizedName "." ConstrName


    //define type expression
    syntax ArrowTypeExpr ::= TypeExpr "->" TypeExpr [right]
    syntax TypeExpr ::= Identifier | "_" [onlyLabel, klabel('typeUnderLine)]
                      | TypeConstr
                      | TypeExpr TypeConstr
                      | "(" TypeExprList ")" TypeConstr
                      | TypeExpr "*" TypeExpr [left]
                      | "<" ">"
                      | "<" ".." ">"
                      | "<" MethodTypeList ">"       [klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ">"   [klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ".." ">"
                      > "#" ConstrName
                      | TypeExpr "#" ConstrName
                      | "(" TypeExprList ")" "#" ConstrName
                      > ArrowTypeExpr
                      | "?" LowerCaseName ":" ArrowTypeExpr
                      | LowerCaseName ":" ArrowTypeExpr
                      > TypeExpr "as" Identifier
                      |"(" TypeExpr ")"             [bracket]

    syntax TypeConstr ::= LowerCaseName | ExtendedModulePath "." LowerCaseName
    syntax ExtendedModuleName ::= CapitalizedName | ExtendedModuleName "(" ExtendedModulePath ")"
    syntax ExtendedModulePath ::= ExtendedModuleName | ExtendedModuleName "." ExtendedModulePath

    syntax TypeExprList ::= TypeExpr
                          | TypeExpr "," TypeExprList
    syntax PolyTypeExpr ::= TypeExpr | IdentifierQuoteList "." TypeExpr
    syntax IdentifierQuoteList ::= "'" Identifier | "'" Identifier IdentifierQuoteList
    syntax MethodType ::= LowerCaseName ":" PolyTypeExpr
    syntax MethodTypeList ::= MethodType | MethodType ";" MethodTypeList

    //define polymorphic-variant-type
    syntax TagSpec ::= "`" CapitalizedName | "`" CapitalizedName "of" TypeExpr | TypeExpr
    syntax TagSpecList ::= TagSpec | TagSpec "|" TagSpecList
    syntax TagSpecFull ::= TagSpec | "`" CapitalizedName "of" TagTypeExprList
    syntax TagTypeExprList ::= "&" TypeExpr | "&" TypeExpr TagTypeExprList
    syntax TagSpecFullList ::= TagSpecFull | TagSpecFull "|" TagSpecList
    syntax TagNameList ::= "`" CapitalizedName | "`" CapitalizedName TagNameList

    syntax PolyVariantType ::= "[" TagSpecList "]"           [klabel('TagSepcAsPolyType)]
                             | "[" "|" TagSpecList "]"       [klabel('TagSepcAsPolyType)]
                             | "[" ">" TagSpecList "]"
                             | "[" "<" TagSpecFullList "]"
                             | "[" "<" "|" TagSpecFullList "]"
                             | "[" "<" TagSpecFullList ">" TagNameList "]"
                             | "[" "<" "|" TagSpecFullList ">" TagNameList "]"

    //define patterns
    syntax Pattern ::= ValueName
		| "_"  [onlyLabel, klabel('patternUnderLine)]
		| Constant
		| "(" Pattern ":" TypeExpr ")"
		| Constr Pattern
                | "`" CapitalizedName Pattern
                | "#" TypeConstr
                > Pattern "::" Pattern        [right]
                > Pattern "," Pattern         [left]
                > Pattern "|" Pattern         [left]
                > Pattern "as" ValueName
                | "[" PatternList "]"         [klabel('patternAsList)]
                | "[" PatternList ";" "]"     [klabel('patternAsList)]
                | "[|" PatternList "|]"         [klabel('patternAsRecord)]
                | "[|" PatternList ";" "|]"     [klabel('patternAsRecord)]
                | "[|" FieldPatternList "|]"         [klabel('patternAsField)]
                | "[|" FieldPatternList ";" "|]"     [klabel('patternAsField)]
		| "(" Pattern ")"             [bracket]

    syntax PatternList ::= Pattern
                         | Pattern ";" PatternList
    syntax FieldPatternList ::= FieldPattern
                              | FieldPattern ";" FieldPatternList
    syntax FieldPattern ::= Field "=" Pattern
    syntax Field ::= LowerCaseName | CapitalizedName "." ConstrName

    syntax FunExp ::= //"fun" Id "->" FunExp
			 "fun" Id "->" Exp
/*
		//	| "fun" "x" "->" Exp
		//	| "fun" "[" Label "]" Pattern "->" FunExp
			| "fun" "[" Label "]" Pattern "->" Exp
			| "(" FunExp ")" [bracket]
*/
endmodule
