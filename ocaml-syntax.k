module OCAML-SYNTAX

    syntax LowerCaseName ::= Token{[a-z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax CapitalizedName ::= Token{[A-Z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax Identifier ::= LowerCaseName | CapitalizedName

    syntax ValueName ::= LowerCaseName
                       | "(" OperatorName ")"
    syntax OperatorName ::= PrefixSymbol | InfixSymbol
                          | ImportantOps [prefer]
    syntax PrefixSymbol ::= Token{[\!][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]*}
                            [onlyLabel]
                          | Token{[\? \~][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]+}
                            [onlyLabel]

    syntax InfixSymbol ::= Token{[\= \< \> \@ \^ \| \& \+ \- \* \/ \$ \%][\! \$ \% \& \* \+ \- \. \/ \: \< \= \> \? \@ \^ \| \~]*}
                       [onlyLabel]
    syntax Plus ::= "+"
    syntax Minus ::= "-"
    syntax MinusDot ::= "-."
    syntax Variance ::= Plus | Minus
    syntax PlusUnOp ::= Plus | "+."
    syntax AllPlusAndMinus ::= MinusUnOp | PlusUnOp
    syntax MinusUnOp ::= Minus | MinusDot
    syntax AllIntFloat ::= AllPlusAndMinus | MathOp
    syntax ImportantOps ::= LogicShiftOp
                          | ExOp
                          | CompareOp
                          | BinaryAnd
                          | BinaryOr
                          | AssignOp
                          | AllIntFloat
                          | Not

    syntax AssignOp ::= ":="
    syntax CompareOp ::= "=" | "!=" | "<" | ">"
    syntax BinaryAnd ::= "&" | "&&" 
    syntax BinaryOr ::= "or" | "||"
    syntax ConcatOp ::= "@" | "^" 
    syntax MathOp ::=  "lor"
                     | "lxor"
                     | "land"
                     | "mod"
                     | "*"
                     | "*."
                     | "/"
                     | "/."

    syntax Not ::= "not"

    syntax LogicShiftOp ::= "lsl"
                          | "lsr"
                          | "asr"
    syntax ExOp ::= "**"

    syntax Unit ::= "()"
    syntax ConsOp ::= "#"
    syntax ListOp ::= "::"
    syntax SepOp ::= ","
    syntax ListSepOp ::= ";"

    syntax Constant ::= IntegerLiteral | FloatLiteral | CharLiteral | StringLiteral
                       | Constr | Bool | Unit | "begin" "end"
                       | "[]" | "[||]" | "`" CapitalizedName
    syntax IntegerLiteral ::= Token{[0-9][0-9 \_]*} [onlyLabel, prefer]
 	           | Token{([0x]| [0X])[0-9 A-F a-f][0-9 A-F a-f \_]*}
                     [onlyLabel]
                   | Token{([0o]| [0O])[0-7][0-7 \_]*}
                     [onlyLabel]
                   | Token{([0b]| [0B])[0-1][0-1 \_]*}
                     [onlyLabel]
		   | Int
    syntax FloatLiteral ::= Token{[0-9][0-9 \_]*(([\.][0-9 \_]*)|(([e]|[E])([\+]|[\-])?[0-9][0-9 \_]*))}
                     [onlyLabel]
    syntax CharLiteral ::= Token{[\'] (~[\' \\]) [\']} [onlyLabel]
                          | Token{[\'](([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f]))[\']}        
                            [onlyLabel]
    syntax StringLiteral ::= Token{[\"] (~[\" \\] | (([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f])) | ([\\][\n][\t \ ]))* [\"]} [onlyLabel]


    syntax Constr ::= CapitalizedName | CapitalizedName "." Constr


    //define type expression
    syntax ArrowTypeExpr ::= TypeExpr "->" TypeExpr [right]
    syntax TypeExpr ::= Identifier
                      | "_" [onlyLabel, klabel('typeAny)]
                      | TypeConstr
                      | TypeExpr TypeConstr                    [prec(5)]
                      | "(" TypeExprList ")" TypeConstr        [prec(5)]
                      | TypeExpr "*" TypeExpr                  [prec(5),left]
                      | "<" ">"                                [prec(5)]
                      | "<" ".." ">"                           [prec(5)] 
                      | "<" MethodTypeList ">"                 [prec(5),klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ">"             [prec(5),klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ".." ">"        [prec(5)] 
                      | ConsOp Field                           [prec(6),klabel('onlyFieldType)] 
                      | TypeExpr ConsOp Field                  [prec(6),klabel('typeFieldType)] 
                      | "(" TypeExprList ")" ConsOp Field      [prec(6),klabel('typeListFieldField)] 
                      | ArrowTypeExpr                          [prec(7)] 
                      | "?" LowerCaseName ":" ArrowTypeExpr    [prec(7)] 
                      | LowerCaseName ":" ArrowTypeExpr        [prec(7)] 
                      | TypeExpr "as" Identifier               [prec(8)] 
                      |"(" TypeExpr ")"                        [bracket,prec(8)]

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
		| "_"  [onlyLabel, klabel('paAny)]
		| Constant
                | CharLiteral ".." CharLiteral       [left,prec(10)]
                | "lazy" Pattern                     [prec(11)]
		| "(" Pattern ":" TypeExpr ")"       [prec(11),klabel('patternWithType)]
		| Constr Pattern                     [prec(11),klabel('patternWithConstr)]
                | "`" CapitalizedName Pattern        [prec(11),klabel('patternWithTag)]
                | ConsOp TypeConstr                  [prec(11),klabel('typeConstrPattern)]
                | Pattern ListOp Pattern             [right,prec(12),klabel('listOpPattern)]
                | Pattern SepOp Pattern              [left,prec(13),klabel('sepOpPattern)]
                | Pattern "|" Pattern                [left,prec(14),klabel('patternList)]
                | Pattern "as" ValueName             [prec(15),klabel('patternAsName)]
                | "[" PatternList "]"                [prec(15),klabel('patternAsList)]
                | "[" PatternList ";" "]"            [prec(15),klabel('patternAsList)]
                | "[|" PatternList "|]"              [prec(15),klabel('patternAsRecord)]
                | "[|" PatternList ";" "|]"          [prec(15),klabel('patternAsRecord)]
                | "[|" FieldPatternList "|]"         [prec(15),klabel('patternAsField)]
                | "[|" FieldPatternList ";" "|]"     [prec(15),klabel('patternAsField)]
		| "(" Pattern ")"                    [prec(15),bracket]

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
    syntax Expr ::= Constant                                       [prec(10)]
                  | ValuePath                                      [prec(10)]
                  | PrefixSymbol Expr                              [prec(15)]
                  | AllowArrowExpr                                 [prec(20)]
                  | Expr ConsOp LowerCaseName                      [prec(25),klabel('exprAsName)]
                  | "assert" Expr                                  [prec(30)]
                  | "lazy" Expr                                    [prec(30)]
                  | "new" Field                                    [prec(30)]
                  | Expr ArgumentList                              [left,prec(30),klabel('exprWithArgs)]
                  | "`" CapitalizedName Expr                       [left,prec(30),klabel('exprWithTag)]
                  | Constr Expr                                    [left,prec(30),klabel('exprWithConstr)]
                  | Not Expr                                        [prec(35),klabel('unaryOp)]
                  | MinusUnOp Expr                                     [prec(35),klabel('unaryOp)]
                  | Expr ExOp Expr                                 [right,prec(40),klabel('binaryRightOp)]
                  | Expr LogicShiftOp Expr                         [right,prec(40),klabel('binaryRightOp)]
                  | Expr MathOp Expr                               [left,prec(45),klabel('binaryLeftOp)]
                  | Expr AllPlusAndMinus Expr                      [left,klabel('binaryLeftOp),prec(50)]
                  | Expr ListOp Expr                                 [right,prec(55),klabel('binaryRightOp)]
                  | Expr ConcatOp Expr                             [right,prec(60),klabel('binaryRightOp)]
                  | Expr CompareOp Expr                            [right,prec(65),klabel('binaryRightOp)]
                  | Expr BinaryAnd Expr                            [right,prec(70),klabel('binaryRightOp)]
                  | Expr BinaryOr Expr                             [left,prec(75),klabel('binaryLeftOp)]
                  | Expr InfixSymbol Expr                          [avoid,left,prec(80),klabel('binaryLeftOp)]
                  | Expr SepOp Expr                                [left,prec(85),klabel('binaryLeftOp)]
                  | AllowArrowExpr "<-" Expr                       [right,prec(90),klabel('assignTo)]
                  | Expr AssignOp Expr                             [right,prec(90),klabel('binaryRightOp)]
                  | "if" Expr "then" Expr                          [prec(95)]
                  | "if" Expr "then" Expr "else" Expr              [prec(95)]
                  | Expr ListSepOp Expr                            [right,prec(100),klabel('binaryRightOp)]
                  | "match" Expr "with" PatternMatching            [prec(105),klabel('matchingExpr)]
                  | "function" PatternMatching                     [prec(105)]
                  | "fun" MultipleMatching                         [prec(105)]
                  | "try" Expr "with" PatternMatching              [prec(105)]
                  | "let" LetBindingList "in" Expr                 [prec(105)]
                  | "let" "rec" LetBindingList "in" Expr           [prec(105)]
                  | "begin" Expr "end"                             [prec(105)]
                  | "while" Expr "do" Expr "done"                  [prec(105)]
                  | "for" ValueName "=" Expr "to" Expr "do" Expr "done"      [prec(105)]
                  | "for" ValueName "=" Expr "downto" Expr "do" Expr "done"  [prec(105)]
                  | ObjectClassBody                                          [prec(105)]
                  | "(" Expr ":" TypeExpr ")"                                [prec(105)]
                  | "(" Expr ":>" TypeExpr ")"                               [prec(105)]
                  | "(" Expr ":" TypeExpr ":>" TypeExpr ")"                  [prec(105)]
                  | "[" ExprList "]"                            [klabel('exprAsList),prec(105)]
                  | "[" ExprList ";" "]"                        [klabel('exprAsList),prec(105)]
                  | "[|" ExprList "|]"                          [klabel('exprBarAsList),prec(105)]
                  | "[|" ExprList ";" "|]"                      [klabel('exprBarAsList),prec(105)]
                  | "{" FieldExprList "}"                       [klabel('fieldExprAsList),prec(105)]
                  | "{" FieldExprList ";" "}"                   [klabel('fieldExprAsList),prec(105)]
                  | "{" Expr "with" FieldExprList "}"           [klabel('theFieldExprAsList),prec(105)]
                  | "{" Expr "with" FieldExprList ";" "}"       [klabel('theFieldExprAsList),prec(105)]
                  | "{<" InstNameExprList ">}"                  [klabel('instNameExprAsList),prec(105)]
                  | "{<" InstNameExprList ";" ">}"              [klabel('instNameExprAsList),prec(105)]
                  | "(" Expr ")"                                [bracket,prec(105)]

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

    syntax ClassDefinition ::= "class" ClassBindingList
    syntax OptClassType ::= ":" ClassType | "" [klabel('nullClassType),onlyLabel]
    syntax TypeParameters ::= "[" IdentifierQuoteList "]" | "" [klabel('nullTypeParameters),onlyLabel]
    syntax ClassBinding ::= OptVirtual TypeParameters LowerCaseName ParameterList OptClassType "=" ClassExpr
    syntax ClassBindingList ::= ClassBinding | ClassBinding "and" ClassBindingList

    syntax ClassSpec ::= OptVirtual TypeParameters LowerCaseName ":" ClassType
    syntax ClassSpecList ::= ClassSpec | ClassSpec "and" ClassSpecList
    syntax ClassSpecification ::= "class" ClassSpecList

    syntax ClassTypeDef ::= OptVirtual TypeParameters LowerCaseName "=" ClassBodyType
    syntax ClassTypeDefList ::= ClassTypeDef | ClassTypeDef "and" ClassTypeDefList
    syntax ClassTypeDefinition ::= "class" "type" ClassTypeDefList

    //define the type and exception expressions.
    syntax TypeDefinition ::= "type" TypeDefList
    syntax TypeDefList ::= TypeDef | TypeDef "and" TypeDefList
    syntax TypeDef ::= TypeParams LowerCaseName TypeInformation
    syntax OptVariance ::= Variance | "" [klabel('nullVariance),onlyLabel]
    syntax TypeParam ::= OptVariance "'" Identifier
    syntax TypeParamList ::= TypeParam | TypeParam "," TypeParamList
    syntax TypeParams ::= TypeParam | "(" TypeParamList ")" | "" [klabel('nullTypeParams),onlyLabel]
    syntax TypeInformation ::= TypeEquation TypeRepresentation TypeConstraints
                             | TypeRepresentation TypeConstraints

    syntax TypeEquation ::= "=" TypeExpr | "" [klabel('nullTypeEquation),onlyLabel]
    syntax TypeConstraint ::= "constraint" "'" Identifier "=" TypeExpr
    syntax TypeConstraints ::= List{TypeConstraint,""}
    
    syntax TypeExprStars ::= TypeExpr | TypeExpr "*" TypeExprStars
    syntax FieldDecl ::= OptMutable LowerCaseName PolyTypeExpr
    syntax ConstrDecl ::= CapitalizedName | Unit
                        | CapitalizedName "of" TypeExprStars
                        | Unit "of" TypeExprStars
    syntax ConstrDeclList ::= ConstrDecl | ConstrDecl "|" ConstrDeclList
    syntax FieldDeclList ::= FieldDecl | FieldDecl ";" FieldDeclList
    syntax TypeRepresentation ::= "=" ConstrDeclList | "=" "|" ConstrDeclList
                                | "=" "{" FieldDeclList "}"
                                |  "=" "{" FieldDeclList ";" "}"
                                | ""  [klabel('nullTypeRep),onlyLabel]


    syntax ExceptionDefinition ::= "exception" CapitalizedName
                                 | "exception" CapitalizedName "=" Constr
                                 | "exception" CapitalizedName "of" TypeExprStars

    //definition of module specifications.
    syntax Specification ::= "val" ValueName ":" TypeExpr
                           | "external" ValueName ":" TypeExpr "=" ExternalDeclaration
                           | TypeDefinition
                           | "exception" ConstrDecl
                           | ClassSpecification
                           | ClassTypeDefinition
                           | "module" CapitalizedName ModuleNameTypePairs ":" ModuleType
                           | "module" "type" CapitalizedName "=" ModuleType
                           | OpenModulePath
                           | "include" ModuleType

    syntax OpenModulePath ::= "open" Constr
    syntax ModConstraint ::= "type" TypeParams TypeConstr "=" TypeExpr
                           | "module" Constr "=" ExtendedModulePath
    syntax ModConstraintList ::= ModConstraint | ModConstraint "and" ModConstraintList
    syntax ModTypePath ::= ExtendedModulePath "." Identifier
    syntax ModuleType ::= ModTypePath
                        | "sig" SpecificationList "end"
                        | "functor" "(" CapitalizedName ":" ModuleType ")" "->" ModuleType
                        |  ModuleType "with" ModConstraintList
                        | "(" ModuleType ")"                            [bracket]

    syntax Specifications ::= Specification | Specification ";;"
    syntax SpecificationList ::= List{Specifications,""}
    syntax ModuleNameTypePair ::= "(" CapitalizedName ":" ModuleType ")"
    syntax ModuleNameTypePairs ::= List{ModuleNameTypePair,""}
    syntax ExternalDeclaration ::= StringLiteral | StringLiteral StringLiteral
                                 | StringLiteral StringLiteral StringLiteral

    //definition of module expressions.
    syntax ModuleExpr ::= Constr
                        | "struct" ModuleItems "end"
                        | "functor" "(" CapitalizedName ":" ModuleType ")" "->" ModuleExpr
                        | ModuleExpr "(" ModuleExpr ")"
                        |  "(" ModuleExpr ":" ModuleType ")"
                        | "(" ModuleExpr ")"                            [bracket]

    syntax ModuleItemFactor ::= Definition | Expr
    syntax ModuleItemListFactor ::= ModuleItemFactor
                                  | ModuleItemListFactor ";;" ModuleItemFactor
                                  | ModuleItemListFactor Definition

    syntax ModuleItems ::= ModuleItemListFactor
                         | ";;" ModuleItemListFactor
                         | ModuleItemListFactor ";;"
                         | ";;" ModuleItemListFactor ";;"
                         | "" [klabel('nullModuleItems),onlyLabel]

    syntax Definition ::= "let" LetBindingList
                        | "let" "rec" LetBindingList
                        | "external" ValueName ":" TypeExpr "=" ExternalDeclaration
                        | TypeDefinition
                        | ExceptionDefinition
                        | ClassDefinition
                        | ClassTypeDefinition
                        | "module" CapitalizedName ModuleNameTypePairs "=" ModuleExpr
                        | "module" CapitalizedName ModuleNameTypePairs ":" ModuleType "=" ModuleExpr
                        | "module" "type" Identifier "=" ModuleType
                        | OpenModulePath
                        | "include" ModuleExpr

    //define unit interface and implementation
    syntax UnitInterface ::= SpecificationList
    syntax UnitImplementation ::= ModuleItems

endmodule
