module OCAML-SYNTAX

    syntax LowerCaseName ::= Token{[a-z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax CapitalizedName ::= Token{[A-Z \_][0-9 a-z A-Z \' \_]*}   [onlyLabel]
    syntax Identifier ::= LowerCaseName | CapitalizedName

    syntax ValueName ::= LowerCaseName
                       | "(" OperatorName ")"          [klabel('operatorAsName)]
    syntax OperatorUnName ::= PrefixSymbol
                            | ImportantOps [prefer]
    syntax OperatorName ::= OperatorUnName | InfixSymbol
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
                       | "[" "]" | "[|" "|]" | SingleTag
    syntax IntegerLiteral ::= Token{[0-9][0-9 \_]*} [onlyLabel, prefer]
 	           | Token{([0x]| [0X])[0-9 A-F a-f][0-9 A-F a-f \_]*}
                     [onlyLabel]
                   | Token{([0o]| [0O])[0-7][0-7 \_]*}
                     [onlyLabel]
                   | Token{([0b]| [0B])[0-1][0-1 \_]*}
                     [onlyLabel]
    syntax FloatLiteral ::= Token{[0-9][0-9 \_]*(([\.][0-9 \_]*)|(([e]|[E])([\+]|[\-])?[0-9][0-9 \_]*))}
                     [onlyLabel]
    syntax CharLiteral ::= Token{[\'] (~[\' \\]) [\']} [onlyLabel]
                          | Token{[\'](([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f]))[\']}        
                            [onlyLabel]
    syntax StringLiteral ::= Token{[\"] (~[\" \\] | (([\\][\\ \" \' n t b r \ ])|([\\][0-9][0-9][0-9])|([\\][x][0-9 A-F a-f][0-9 A-F a-f])) | ([\\][\n][\t \ ]))* [\"]} [onlyLabel]


    syntax Constr ::= CapitalizedName
                    | CapitalizedName "." Constr     [klabel('constrDot)]


    //define type expression
    syntax ArrowTypeExpr ::= TypeExpr "->" TypeExpr [right]
    syntax TypeExpr ::= Identifier
                      | "_" [onlyLabel, klabel('typeAny)]
                      | TypeConstr
                      |"(" TypeExpr ")"                        [bracket]
                      > TypeExpr TypeConstr                    
                      | "(" TypeExprList ")" TypeConstr        
                      | TypeExpr "*" TypeExpr                  [left]
                      | "<" ">"
                      | "<" ".." ">" 
                      | "<" MethodTypeList ">"                 [klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ">"             [klabel('methodTypeListAsType)]
                      | "<" MethodTypeList ";" ".." ">" 
                      > ConsOp Field                           [klabel('onlyFieldType)] 
                      | TypeExpr ConsOp Field                  [klabel('typeFieldType)] 
                      | "(" TypeExprList ")" ConsOp Field      [klabel('typeListFieldField)] 
                      > ArrowTypeExpr
                      | "?" LowerCaseName ":" ArrowTypeExpr
                      | LowerCaseName ":" ArrowTypeExpr        [klabel('labelAsType)]
                      > TypeExpr "as" Identifier


    syntax TypeConstr ::= LowerCaseName
                        | ExtendedModulePath "." LowerCaseName            [klabel('typeConstrDot)]
    syntax ExtendedModuleName ::= CapitalizedName | ExtendedModuleName "(" ExtendedModulePath ")"
    syntax ExtendedModulePath ::= ExtendedModuleName
                                | ExtendedModuleName "." ExtendedModulePath   [klabel('extendedPathDot)]

    syntax TypeExprList ::= TypeExpr
                          | TypeExpr "," TypeExprList
    syntax PolyTypeExpr ::= TypeExpr
                          | IdentifierQuoteList "." TypeExpr           [klabel('polyTypeExprDot)]
    syntax IdentifierQuoteList ::= "'" Identifier | "'" Identifier IdentifierQuoteList
    syntax MethodType ::= LowerCaseName ":" PolyTypeExpr       [klabel('labelAsPolyType)]
    syntax MethodTypeList ::= MethodType | MethodType ";" MethodTypeList

    //define polymorphic-variant-type
    syntax SingleTag ::= "`" CapitalizedName
    syntax TagSpec ::= SingleTag | "`" CapitalizedName "of" TypeExpr | TypeExpr
    syntax TagSpecList ::= TagSpec | TagSpec "|" TagSpecList
    syntax TagSpecFull ::= TagSpec | "`" CapitalizedName "of" TagTypeExprList
    syntax TagTypeExprList ::= "&" TypeExpr | "&" TypeExpr TagTypeExprList
    syntax TagSpecFullList ::= TagSpecFull | TagSpecFull "|" TagSpecList
    syntax TagNameList ::= SingleTag | "`" CapitalizedName TagNameList

    syntax PolyVariantType ::= "[" TagSpecList "]"           [klabel('TagSepcAsPolyType)]
                             | "[" "|" TagSpecList "]"       [klabel('TagSepcAsPolyType)]
                             | "[" ">" TagSpecList "]"
                             | "[" "<" TagSpecFullList "]"
                             | "[" "<" "|" TagSpecFullList "]"
                             | "[" "<" TagSpecFullList ">" TagNameList "]"
                             | "[" "<" "|" TagSpecFullList ">" TagNameList "]"

    //define patterns
    syntax Pattern ::= ValueName
		| "_"  [onlyLabel, klabel('wildcard)]
		| Constant
		| "(" Pattern ")"                    [bracket]
                > CharLiteral ".." CharLiteral       [left]
                > "lazy" Pattern
		| "(" Pattern ":" TypeExpr ")"       [klabel('patternWithType)]
		| Constr Pattern                     [klabel('patternWithConstr)]
                | "`" CapitalizedName Pattern        [klabel('patternWithTag)]
                | ConsOp TypeConstr                  [klabel('typeConstrPattern)]
                > Pattern ListOp Pattern             [right,klabel('listOpPattern)]
                > Pattern SepOp Pattern              [left,klabel('sepOpPattern)]
                > Pattern "|" Pattern                [left,klabel('patternList)]
                > Pattern "as" ValueName             [klabel('patternAsName)]
                | "[" PatternList "]"                [klabel('patternAsList)]
                | "[" PatternList ";" "]"            [klabel('patternAsList)]
                | "[|" PatternList "|]"              [klabel('patternAsRecord)]
                | "[|" PatternList ";" "|]"          [klabel('patternAsRecord)]
                | "[|" FieldPatternList "|]"         [klabel('patternAsField)]
                | "[|" FieldPatternList ";" "|]"     [klabel('patternAsField)]

    syntax PatternList ::= Pattern
                         | Pattern ";" PatternList
    syntax FieldPatternList ::= FieldPattern
                              | FieldPattern ";" FieldPatternList
    syntax FieldPattern ::= Field "=" Pattern        [klabel('fieldPatternAssign)]
    syntax FieldExprList ::= FieldExpr | FieldExpr ";" FieldExprList
    syntax FieldExpr ::= Field "=" Expr              [klabel('fieldExprAssign)]
    syntax Field ::= LowerCaseName
                   | CapitalizedName "." Field       [klabel('fieldNameDot)]

    //define expressions.
    syntax ValuePath ::= ValueName
                       | CapitalizedName "." ValuePath   [klabel('valuePathDot)]

    syntax Expr ::= Constant
                  | ValuePath                                      [prefer]
                  | "(" Expr ")"                                   [bracket]
                  > OperatorUnName Expr                            [klabel('unaryOp)]
                  > AllowArrowExpr
                  > Expr ConsOp LowerCaseName                      [klabel('exprAsName)]
                  > "assert" Expr
                  | "lazy" Expr
                  | "new" Field
                  | Expr ArgumentList                              [left,klabel('exprWithArgs)]
                  | "`" CapitalizedName Expr                       [left,klabel('exprWithTag)]
                  | Constr Expr                                    [left,klabel('exprWithConstr)]
                  //> Not Expr                                       [klabel('unaryOp)]
                  //| MinusUnOp Expr                                 [klabel('unaryOp)]
                  > Expr ExOp Expr                                 [right,klabel('binaryExOp)]
                  | Expr LogicShiftOp Expr                         [right,klabel('binaryLogicOp)]
                  > Expr MathOp Expr                               [left,klabel('mathTimesOp)]
                  > Expr AllPlusAndMinus Expr                      [left,klabel('mathPlusOp)]
                  > Expr ListOp Expr                               [right,klabel('binaryListOp)]
                  > Expr ConcatOp Expr                             [right,klabel('concatOp)]
                  > Expr CompareOp Expr                            [right,klabel('compareOp)]
                  > Expr BinaryAnd Expr                            [right,klabel('binaryAndOp)]
                  > Expr BinaryOr Expr                             [left,klabel('binaryOrOp)]
                  > Expr InfixSymbol Expr                          [avoid,left,klabel('binaryUnknownOp)]
                  > Expr SepOp Expr                                [left,klabel('binarySepOp)]
                  > AllowArrowExpr "<-" Expr                       [right,klabel('assignTo)]
                  | Expr AssignOp Expr                             [right,klabel('binaryAssignOp)]
                  > "if" Expr "then" Expr
                  | "if" Expr "then" Expr "else" Expr
                  > Expr ListSepOp Expr                            [right,klabel('binaryListSepOp)]
                  > "match" Expr "with" PatternMatching            [klabel('matchingExpr)]
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

    syntax ExprList ::= Expr
                      | Expr ";" ExprList

    syntax LabelName ::= "~" LowerCaseName [klabel('tlabel)]
                        | "?" LowerCaseName [klabel('optionalLabel)]

    syntax Argument ::= Expr | LabelName
                      | LabelName ":" Expr [klabel('label)]

    syntax ArgumentList ::= Argument
                          | Argument ArgumentList  [klabel('argCon)]
    syntax AllowArrowExpr ::= LowerCaseName
                            | Expr "." Field
                            | Expr "." "(" Expr ")"
                            | Expr "." "[" Expr "]"

    syntax InstNameExpr ::= LowerCaseName "=" Expr             [klabel('instNameAssign)]
    syntax InstNameExprList ::= InstNameExpr | InstNameExpr ";" InstNameExprList
    syntax LetBinding ::= ValueName ParameterList "=" Expr [klabel('letfunexpr)] 
                        | Pattern "=" Expr [klabel('patternexpr), prefer]
                        | ValueName ParameterList ":" TypeExpr "=" Expr
                        | ValueName ParameterList ":>" TypeExpr "=" Expr
                        | ValueName ParameterList ":" TypeExpr ":>" TypeExpr "=" Expr
    syntax LetBindingList ::= LetBinding | LetBinding "and" LetBindingList

    syntax PatternMatch ::= Pattern "when" Expr "->" Expr
                          | Pattern "->" Expr [klabel('patternMatchExpr)]
    syntax PatternMatchs ::= PatternMatch | PatternMatch "|" PatternMatchs
    syntax PatternMatching ::= "|" PatternMatchs | PatternMatchs
    syntax MultipleMatching ::= Parameter ParameterList "->" Expr      [klabel('parameterListExpr)]
                              | Parameter ParameterList "when" Expr "->" Expr

    syntax ParameterList ::= List{Parameter,""}
    syntax Parameter ::= Pattern | LabelName | LabelName ":" Pattern
                       | "~" "(" LowerCaseName ")"[klabel('parenthesisLabel)]
                       | "~" "(" LowerCaseName ":" TypeExpr ")"
                       | "?" "(" LowerCaseName ")" [klabel('parenthesisOptionalLabel)]
                       | "?" "(" LowerCaseName ":" TypeExpr ")"
                       | "?" "(" LowerCaseName "=" Expr ")"
                       | "?" "(" LowerCaseName ":" TypeExpr "=" Expr ")"
                       | "?" LowerCaseName ":" "(" Pattern ")"
                                                      [klabel('parameterLabelPattern)]
                       | "?" LowerCaseName ":" "(" Pattern ":" TypeExpr ")"
                                                  [klabel('parameterLabelPatternType)]
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

    syntax ClassExpr ::= Field
                       | "[" TypeExprList "]" Field
                       | ClassExpr ArgumentList                          [left]
                       > "fun" Parameter ParameterList "->" ClassExpr
                       | "let" LetBindingList "in" ClassExpr [klabel('classletin)]
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
    syntax ObjectClassBody ::= "object" ClassBody "end"
    syntax ClassFieldList ::= List{ClassField,""}                    [klabel('classFieldCon)]
    syntax ClassBody ::= ClassFieldList
                       | "(" Pattern ")" ClassFieldList
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
    syntax ModTypePath ::= ExtendedModulePath "." Identifier             [klabel('modTypePathDot)]
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
