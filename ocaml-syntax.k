module OCAML-SYNTAX

/*
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
*/


/*
    syntax FunExp ::= //"fun" Id "->" FunExp
			 "fun" Id "->" Exp
		//	| "fun" "x" "->" Exp
		//	| "fun" "[" Label "]" Pattern "->" FunExp
			| "fun" "[" Label "]" Pattern "->" Exp
			| "(" FunExp ")" [bracket]
*/


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


    syntax Constr ::= CapitalizedName | CapitalizedName "." Constr


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
                      > "#" Field
                      | TypeExpr "#" Field
                      | "(" TypeExprList ")" "#" Field
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
                > CharLiteral ".." CharLiteral       [left]
                > "lazy" Pattern
		| "(" Pattern ":" TypeExpr ")"
		| Constr Pattern
                | "`" CapitalizedName Pattern
                | "#" TypeConstr
                > Pattern "::" Pattern               [right]
                > Pattern "," Pattern                [left]
                > Pattern "|" Pattern                [left]
                > Pattern "as" ValueName
                | "[" PatternList "]"                [klabel('patternAsList)]
                | "[" PatternList ";" "]"            [klabel('patternAsList)]
                | "[|" PatternList "|]"              [klabel('patternAsRecord)]
                | "[|" PatternList ";" "|]"          [klabel('patternAsRecord)]
                | "[|" FieldPatternList "|]"         [klabel('patternAsField)]
                | "[|" FieldPatternList ";" "|]"     [klabel('patternAsField)]
		| "(" Pattern ")"                    [bracket]

    syntax PatternList ::= Pattern
                         | Pattern ";" PatternList
    syntax FieldPatternList ::= FieldPattern
                              | FieldPattern ";" FieldPatternList
    syntax FieldPattern ::= Field "=" Pattern
    syntax FieldExprList ::= FieldExpr | FieldExpr ";" FieldExprList
    syntax FieldExpr ::= Field "=" Expr
    syntax Field ::= LowerCaseName | CapitalizedName "." Field

    //define expressions.
    syntax ValuePath ::= ValueName | CapitalizedName "." ValuePath
    syntax Expr ::= Constant | ValuePath                        [prefer]
                  > PrefixSymbol Expr
                  > AllowArrowExpr
                  > Expr "#" LowerCaseName
                  > "assert" Expr
                  | "lazy" Expr
                  | "new" Field
                  | Expr ArgumentList                           [left]
                  | "`" CapitalizedName Expr                    [left]
                  | Constr Expr                                 [left]
                  > "-" Expr
                  | "-." Expr
                  > Expr InfixOp Expr                           [left]
                  > Expr "::" Expr                              [right]
                  > Expr "," Expr                               [left]
                  > AllowArrowExpr "<-" Expr                    [right]
                  > "if" Expr "then" Expr
                  | "if" Expr "then" Expr "else" Expr
                  > Expr ";" Expr                               [right]
                  > "match" Expr "with" PatternMatching
                  | "function" PatternMatching
                  | "fun" MultipleMatching
                  | "try" Expr "with" PatternMatching
                  | "let" LetBindingList "in" Expr
                  | "let" "rec" LetBindingList "in" Expr
                  | "begin" Expr "end"
                  | "while" Expr "do" Expr "done"
                  | "for" ValueName "=" Expr "to" Expr "do" Expr "done"
                  | "for" ValueName "=" Expr "downto" Expr "do" Expr "done"
                  | ObjectClassBody
                  | "(" Expr ":" TypeExpr ")"
                  | "(" Expr ":>" TypeExpr ")"
                  | "(" Expr ":" TypeExpr ":>" TypeExpr ")"
                  | "[" ExprList "]"                            [klabel('exprAsList)]
                  | "[" ExprList ";" "]"                        [klabel('exprAsList)]
                  | "[|" ExprList "|]"                          [klabel('exprBarAsList)]
                  | "[|" ExprList ";" "|]"                      [klabel('exprBarAsList)]
                  | "{" FieldExprList "}"                       [klabel('fieldExprAsList)]
                  | "{" FieldExprList ";" "}"                   [klabel('fieldExprAsList)]
                  | "{" Expr "with" FieldExprList "}"           [klabel('theFieldExprAsList)]
                  | "{" Expr "with" FieldExprList ";" "}"       [klabel('theFieldExprAsList)]
                  | "{<" InstNameExprList ">}"                  [klabel('instNameExprAsList)]
                  | "{<" InstNameExprList ";" ">}"              [klabel('instNameExprAsList)]
                  | "(" Expr ")"                                [bracket]

    syntax ExprList ::= Expr
                      | Expr ";" ExprList

    syntax LabelName ::= "~" LowerCaseName | "?" LowerCaseName

    syntax Argument ::= Expr | LabelName
                      | LabelName ":" Expr

    syntax ArgumentList ::= Argument | Argument ArgumentList
    syntax AllowArrowExpr ::= LowerCaseName
                            | Expr "." Field
                            | Expr "." "(" Expr ")"
                            | Expr "." "[" Expr "]"

    syntax InstNameExpr ::= LowerCaseName "=" Expr
    syntax InstNameExprList ::= InstNameExpr | InstNameExpr ";" InstNameExprList
    syntax LetBinding ::= Pattern "=" Expr | ValueName ParameterList "=" Expr
                        | ValueName ParameterList ":" TypeExpr "=" Expr
                        | ValueName ParameterList ":>" TypeExpr "=" Expr
                        | ValueName ParameterList ":" TypeExpr ":>" TypeExpr "=" Expr
    syntax LetBindingList ::= LetBinding | LetBinding "and" LetBindingList

    syntax PatternMatch ::= Pattern "when" Expr "->" Expr
                          | Pattern "->" Expr
    syntax PatternMatchs ::= PatternMatch | PatternMatch "|" PatternMatchs
    syntax PatternMatching ::= "|" PatternMatchs | PatternMatchs
    syntax MultipleMatching ::= Parameter ParameterList "->" Expr
                              | Parameter ParameterList "when" Expr "->" Expr

    syntax ParameterList ::= List{Parameter,""}
    syntax Parameter ::= Pattern | LabelName | LabelName ":" Pattern
                       | "~" "(" LowerCaseName ")"
                       | "~" "(" LowerCaseName ":" TypeExpr ")"
                       | "?" "(" LowerCaseName ")"
                       | "?" "(" LowerCaseName ":" TypeExpr ")"
                       | "?" "(" LowerCaseName "=" Expr ")"
                       | "?" "(" LowerCaseName ":" TypeExpr "=" Expr ")"
                       | "?" LowerCaseName ":" "(" Pattern ")"
                       | "?" LowerCaseName ":" "(" Pattern ":" TypeExpr ")"
                       | "?" LowerCaseName ":" "(" Pattern "=" Expr ")"
                       | "?" LowerCaseName ":" "(" Pattern ":" TypeExpr "=" Expr ")"


    //define class expressions and class fields
    syntax Mutable ::= "mutable"
    syntax OptMutable ::= Mutable | "" [klabel('nullMutable),onlyLabel]
    syntax Virtual ::= "virtual"
    syntax OptVirtual ::= Virtual | "" [klabel('nullVirtual),onlyLabel]
    syntax Private ::= "private"
    syntax OptPrivate ::= Private | "" [klabel('nullPrivate),onlyLabel]
    syntax ConstraintTypeOfType ::= "constraint" TypeExpr "=" TypeExpr
    syntax ClassBodyType ::= Field
                           | "[" TypeExprList "]" Field
                           | "object" ClassFieldSpecs "end"
                           | "object" "(" TypeExpr ")" ClassFieldSpecs "end"
    syntax ClassFieldSpecs ::= List{ClassFieldSpec,""}
    syntax ClassFieldSpec ::= "inherit" ClassBodyType
                            | "val" OptMutable OptVirtual LowerCaseName ":" TypeExpr
                            | "val" Virtual Mutable LowerCaseName ":" TypeExpr
                            | "method" OptMutable OptVirtual LowerCaseName ":" PolyTypeExpr
                            | "method" Virtual Mutable LowerCaseName ":" PolyTypeExpr
                            | ConstraintTypeOfType
    syntax ClassType ::= ClassBodyType | TypeExpr "->" ClassType
                       | LowerCaseName ":" TypeExpr "->" ClassType
                       | "?" LowerCaseName ":" TypeExpr "->" ClassType

    syntax ObjectClassBody ::= "object" ClassBody "end"
    syntax ClassExpr ::= Field
                       | "[" TypeExprList "]" Field
                       | ClassExpr ArgumentList                          [left]
                       > "fun" Parameter ParameterList "->" ClassExpr
                       | "let" LetBindingList "in" ClassExpr
                       | "let" "rec" LetBindingList "in" ClassExpr
                       | ObjectClassBody
                       | "(" ClassExpr ":" ClassType ")"
                       | "(" ClassExpr ")"                               [bracket]

    syntax ClassField ::= "inherit" ClassExpr
                        | "inherit" ClassExpr "as" LowerCaseName
                        | "val" OptMutable LowerCaseName ":" TypeExpr "=" Expr
                        | "val" OptMutable LowerCaseName "=" Expr
                        | "val" OptMutable Virtual LowerCaseName ":" TypeExpr
                        | "val" Virtual Mutable LowerCaseName ":" TypeExpr
                        | "method" OptPrivate LowerCaseName ParameterList "=" Expr
                        | "method" OptPrivate LowerCaseName ParameterList ":" TypeExpr "=" Expr
                        | "method" OptPrivate Virtual LowerCaseName ":" PolyTypeExpr
                        | "method" Virtual Private LowerCaseName ":" PolyTypeExpr
                        | ConstraintTypeOfType
                        | "initializer" Expr
    syntax ClassFieldList ::= List{ClassField,""}
    syntax ClassBody ::= ClassFieldList | "(" Pattern ")" ClassFieldList
                       | "(" Pattern ":" TypeExpr ")" ClassFieldList

endmodule
