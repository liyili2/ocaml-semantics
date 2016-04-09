requires "ocaml-syntax.k"
requires "ocaml-abstract-syntax.k"
require "modules/substitution.k"

module OCAML-SYNTAX-EXTRAS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX

    syntax KResult ::= Int | Bool | Id 

    

    syntax KResult ::= ExComValue(K,K)

    syntax KItem
      ::= "initEnv"
        | "binding"
        | "matching"
        | "assigning"
        | "debug"
        | "getArrayElement"
        | "getRecordElement"
        | "getStringElement"
        | "getFieldValue"  // from a class
        | "assert"        //apply an assert to a boolean expression
        | "assignElement"        //apply an assert to a boolean expression

    syntax Location ::= Location(Int)
    syntax KResult ::= Location

    syntax KResult ::= cons(K, ElemList)

/*
    syntax KItem ::= env(Map) 
        | funlabel (K, KList, KList, K) [strict(1,2,3)]// non-labeled arg, tilde labeled args, optional args, Expr
*/



endmodule

module OCAML-TRANS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS
    

    syntax KItem ::= translationParam(Parameter) 

    syntax KItem ::= translationApp(K, ArgumentList)
    syntax KItem ::= translationArg(Argument)
    syntax KItem ::= translationArgs(ArgumentList)
    syntax KItem ::= translationPattern(Pattern)           [function]
    syntax KItem ::= translationPatternList(PatternList)
    syntax KItem ::= translationPatternFieldList(FieldPatternList)
    syntax KItem ::= translationParams(ParameterList, Expr)
    syntax KItem ::= translationParams(ParameterList, K, Expr)

    syntax KItem ::= translationLetRecBindings(LetBindingList)
    syntax KItem ::= translationToBindingForm(K)
    syntax KItem ::= translationPatternMatching(PatternMatching)
    
    //translating type expressions
    syntax KItem ::= translationTypeExpr(TypeExpr) 
    syntax KItem ::= translationTypeExprList(TypeExprList)
    syntax KItem ::= translationPolyType(PolyTypeExpr)
    syntax KItem ::= translationMethodTypeList(MethodTypeList)

    //translation of long list of ids
    syntax KItem ::= translationIdentifierList(IdentifierQuoteList)    [function]
    syntax KItem ::= translationField(Field)                           [function]
    syntax KItem ::= translationValuePath(ValuePath)                   [function]
    syntax KItem ::= translationExtendedModulePath(ExtendedModulePath) [function]
    syntax KItem ::= translationConstr(Constr)                         [function]
    syntax KItem ::= translationTypeConstr(TypeConstr)                 [function]

    //translation of expressions
    syntax KItem ::= translation(ModuleItemListFactor)                 [function]
    syntax KItem ::= translationDef(Definition)                        [function]
    syntax KItem ::= translationExpr(Expr)                             [function]
    syntax KItem ::= translationAllowExpr(AllowArrowExpr)              [function]
    syntax KItem ::= translationConstant(Constant)                     [function]
    syntax KItem ::= translationExprWithArgs(K, ArgumentList, K)       [function]

    //helper functions for constructing apply of expressions.
    syntax ElemList ::= getAllTildas(ArgumentList)                     [function]
    syntax ElemList ::= getAllMarks(ArgumentList)                      [function]
    syntax ElemList ::= getAllNormals(ArgumentList)                    [function]
    syntax KItem ::= constructApp(K, ElemList)                         [function]

    //translation of let bindings.
    syntax KItem ::= translationLetBindings(LetBindingList)            [function]
    syntax KItem ::= translationLetBinding(LetBinding)                 [function]

    syntax KItem ::= "assign" "(" K ")"

    //Translation Patterns
    /*
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
      */
    rule translationPattern(X:LowerCaseName)
                              => PatternIdentifier(IdUid(X)) 
    rule translationPattern('operatorAsName(X:OperatorName))
                              => PatternIdentifier(IdUid(X))
    rule translationPattern(I:Constant)
                              => PatternConst(translationExpr(I))
    rule translationPattern(C1:CharLiteral .. C2:CharLiteral)
                              => PatternDoubleChar(C1, C2)
    rule translationPattern('patternList(P:Pattern,, Ps:Pattern))
                           => PaOrp(translationPattern(P), translationPattern(Ps)) 
    rule translationPattern(lazy P:Pattern)
                              => PatternLazy(translationPattern(P))
    rule translationPattern( ( P:Pattern : T:TypeExpr ) )
                              => PaTyc(translationPattern(P), translationTypeExpr(T))
    rule translationPattern('patternWithConstr(C:Constr, P:Pattern))
                              => PaCom(translationConstr(C)
                                              , translationPattern(P))
    rule translationPattern(` C:CapitalizedName P:Pattern)
                              => PatternTag(C, translationPattern(P))
    rule translationPattern(# Tc:TypeConstr)
                              => PaConstType(translationTypeConstr(Tc))
    rule translationPattern(P1:Pattern :: P2:Pattern)
                              => PaList(translationPattern(P1), translationPattern(P2))
    rule translationPattern(P1:Pattern , P2:Pattern)
                              => PaTuple(translationPattern(P1), translationPattern(P2))
    rule translationPattern(P1:Pattern as V:ValueName)
                              => PaAli(translationPattern(P1), translationPattern(V))
    rule translationPattern('patternAsList(Ps:PatternList))
                              => translationPatternList(Ps)
    rule translationPattern('patternAsRecord(Ps:PatternList))
                              => PaRecord(translationPatternList(Ps))
    rule translationPattern('patternAsField(Ps:FieldPatternList))
                              => PaRecord(translationPatternFieldList(Ps))


    rule translationPatternList(P1:Pattern) => translationPattern(P1)
    rule translationPatternList(P1:Pattern ; Ps:PatternList)
                                   => PaList(translationPattern(P1), translationPatternList(Ps))
    rule translationPatternFieldList(F:Field = P:Pattern)
                                   => FieldPattern(translationField(F), translationPattern(P))
    rule translationPatternFieldList(F:Field = P:Pattern ; Fps:FieldPatternList)
                                   => PaList(FieldPattern(translationField(F), translationPattern(P)),
                                               translationPatternFieldList(Fps))



    //translating the type expressions.
    /*
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
    */

    rule translationTypeExpr(X:Identifier) => TyId(IdUid(X))
    rule translationTypeExpr(C:TypeConstr) => TyConstr(translationTypeConstr(C))
    rule translationTypeExpr(E:TypeExpr C:TypeConstr)
                            => TyWithArg(translationTypeExpr(E), translationTypeConstr(C))
    rule translationTypeExpr((El:TypeExprList) C:TypeConstr)
                            => TyWithArg(TyList(translationTypeExprList(El)), translationTypeConstr(C))
    rule translationTypeExpr(E1:TypeExpr * E2:TypeExpr)
                            => TyPair(translationTypeExpr(E1), translationTypeExpr(E2))
    rule translationTypeExpr('methodTypeListAsType(Ml:MethodTypeList))
                            => TyMethods(translationMethodTypeList(Ml), false)
    rule translationTypeExpr(< .. >)
                            => TyMethods(none, true)
    rule translationTypeExpr(< >)
                            => TyMethods(none, false)
    rule translationTypeExpr(<Ml:MethodTypeList ; .. >)
                            => TyMethods(translationMethodTypeList(Ml), true)
    rule translationTypeExpr('onlyFieldType(C:ConsOp,, F:Field))
                            => TyFieldType(translationField(F), none)
    rule translationTypeExpr('typeFieldType(T:TypeExpr,, C:ConsOp,, F:Field))
                            => TyFieldType(translationField(F), translationTypeExpr(T))
    rule translationTypeExpr('typeListFieldField(Ts:TypeExprList,, C:ConsOp,, F:Field))
                            => TyFieldType(translationField(F)
                                                    , TyList(translationTypeExprList(Ts)))
    rule translationTypeExpr(T1:TypeExpr -> T2:TypeExpr)
                          => TyFun(none, translationTypeExpr(T1), translationTypeExpr(T2))
    rule translationTypeExpr(? A:LowerCaseName : T1:TypeExpr -> T2:TypeExpr)
                          => TyFun(TyQuestionMark(IdUid(A)),
                                 translationTypeExpr(T1), translationTypeExpr(T2))
    rule translationTypeExpr('labelAsType(A:LowerCaseName,, T1:TypeExpr -> T2:TypeExpr))
                          => TyFun(TyTilda(IdUid(A)),
                                 translationTypeExpr(T1), translationTypeExpr(T2))
    rule translationTypeExpr(T:TypeExpr as A:Identifier)
                          => TyWithName(translationTypeExpr(T), translationTypeExpr(A))


    rule translationTypeExprList(T:TypeExpr) => translationTypeExpr(T)
    rule translationTypeExprList(T:TypeExpr, Ts:TypeExprList)
                         => TyListCons(translationTypeExpr(T), translationTypeExprList(Ts))


    rule translationMethodTypeList('labelAsPolyType(X:LowerCaseName,, P:PolyTypeExpr))
                 => TySingleMethod(IdUid(X),translationPolyType(P))
    rule translationMethodTypeList(X:LowerCaseName : P:PolyTypeExpr ; Ms:MethodTypeList)
                 => TyMethodCons(TySingleMethod(IdUid(X),
                        translationPolyType(P)), translationMethodTypeList(Ms))


    rule translationPolyType(T:TypeExpr) => translationTypeExpr(T)
    rule translationPolyType('polyTypeExprDot(As:IdentifierQuoteList,, T:TypeExpr))
                                          => TyQuantifier(translationIdentifierList(As)
                                                                     , translationTypeExpr(T))

    rule translationIdentifierList(' I:Identifier) => IdUid(I)
    rule translationIdentifierList(' I:Identifier Is:IdentifierQuoteList)
                                        => ConsUId(IdUid(I), translationIdentifierList(Is))

    /*
          syntax Constant ::= IntegerLiteral | FloatLiteral | CharLiteral | StringLiteral
                       | Constr | Bool | Unit | "begin" "end"
                       | "[]" | "[||]" | "`" CapitalizedName
    */
    rule translationConstant(I:IntegerLiteral) => ExInt(String2Int(#tokenToString(I)))
    rule translationConstant(F:FloatLiteral) => ExFloat(String2Float(#tokenToString(F)))
    rule translationConstant(B:Bool) => ExBool(B)
    rule translationConstant(C:CharLiteral) => ExChar(#tokenToString(C))
    rule translationConstant(S:StringLiteral) => ExStr(#tokenToString(S))
    rule translationConstant(C:Constr) => ExConstr(translationConstr(C))
    rule translationConstant(()) => ExId(IdUid("()"))
    rule translationConstant(begin end) => ExId(IdUid("()"))
    rule translationConstant([ ]) => ExNilList
    rule translationConstant([| |]) => ExNilArray
    rule translationConstant(` C:CapitalizedName) => ExTagVal(IdUid(C), ExNil) //no argument tag

    //translate constructors
    rule translationConstr(C:CapitalizedName) => IdUid(C)
    rule translationConstr('constrDot(C:CapitalizedName,, Cs:Constr))
                        => ConsUId(IdUid(C), translationConstr(Cs))

    //translate Field Name
    rule translationField(C:LowerCaseName) => IdUid(C)
    rule translationField('fieldNameDot(C:CapitalizedName,, Cs:Field))
                        => ConsUId(IdUid(C), translationField(Cs))


    //translate type constructors
    rule translationTypeConstr(C:LowerCaseName) => IdUid(C)
    rule translationTypeConstr('typeConstrDot(M:ExtendedModulePath,, C:LowerCaseName))
                        => ConsUId(translationExtendedModulePath(M), IdUid(C))

    rule translationExtendedModulePath(C:CapitalizedName) => IdUid(C)
    rule translationExtendedModulePath(M:ExtendedModuleName (E:ExtendedModulePath))
                 => ModuleNameList(translationExtendedModulePath(M), translationExtendedModulePath(E))
    rule translationExtendedModulePath('extendedPathDot(M:ExtendedModuleName,, E:ExtendedModulePath))
                 => ModulePathList(translationExtendedModulePath(M), translationExtendedModulePath(E))

    //translating the valuepath
    rule translationValuePath(C:LowerCaseName) => IdUid(C)
    rule translationValuePath('operatorAsName(X:OperatorName)) => IdUid(X)
    rule translationValuePath('valuePathDot(C:CapitalizedName,, Cs:ValuePath))
                        => ConsUId(IdUid(C), translationValuePath(Cs))

    //translating allow arrow expressions
    rule translationAllowExpr(V:LowerCaseName) => ExId(translationValuePath(V))
    rule translationAllowExpr(E:Expr . F:Field) => ExApp(ExApp(ExId(IdUid(getRecordElement))
                                                        ,translationExpr(E)), translationField(F))
    rule translationAllowExpr(E:Expr . (E':Expr)) => ExApp(ExApp(ExId(IdUid(getArrayElement))
                                                        ,translationExpr(E)), translationExpr(E'))
    rule translationAllowExpr(E:Expr . [E':Expr]) => ExApp(ExApp(ExId(IdUid(getStringElement))
                                                        ,translationExpr(E)), translationExpr(E'))

    //translating argument lists with expression.
    rule constructApp(K:K, .ElemList) => K
    rule constructApp(K:K, (val(E:K),As:ElemList)) => constructApp(ExApp(K,E), As)

    rule getAllTildas(~ X:LowerCaseName) => val(ExprLabelId(IdUid(X),ExNil))
    rule getAllTildas(~ X:LowerCaseName : E:Expr)
                                         => val(ExprLabelId(IdUid(X),translationExpr(E)))
    rule getAllTildas(? X:LowerCaseName) => .ElemList
    rule getAllTildas(? X:LowerCaseName : E:Expr) => .ElemList
    rule getAllTildas(E:Expr) => .ElemList
    rule getAllTildas('argCon(~ X:LowerCaseName,, As:ArgumentList))
                                   => val(ExprLabelId(IdUid(X),ExNil)),getAllTildas(As)
    rule getAllTildas('argCon(~ X:LowerCaseName : E:Expr,, As:ArgumentList))
                            => val(ExprLabelId(IdUid(X),translationExpr(E))),getAllTildas(As)
    rule getAllTildas('argCon(? X:LowerCaseName,, As:ArgumentList)) => getAllTildas(As)
    rule getAllTildas('argCon(? X:LowerCaseName : E:Expr,, As:ArgumentList)) => getAllTildas(As)
    rule getAllTildas('argCon(E:Expr,, As:ArgumentList)) => getAllTildas(As)


    rule getAllMarks(~ X:LowerCaseName) => .ElemList
    rule getAllMarks(~ X:LowerCaseName : E:Expr) => .ElemList
    rule getAllMarks(? X:LowerCaseName) => val(ExprOptLabelId(IdUid(X),ExNil))
    rule getAllMarks(? X:LowerCaseName : E:Expr)
                                   => val(ExprOptLabelId(IdUid(X),translationExpr(E)))
    rule getAllMarks(E:Expr) => .ElemList
    rule getAllMarks('argCon(~ X:LowerCaseName,, As:ArgumentList))
                                   => getAllMarks(As)
    rule getAllMarks('argCon(~ X:LowerCaseName : E:Expr,, As:ArgumentList))
                            => getAllMarks(As)
    rule getAllMarks('argCon(? X:LowerCaseName,, As:ArgumentList))
                            => val(ExprOptLabelId(IdUid(X), ExNil)),getAllMarks(As)
    rule getAllMarks('argCon(? X:LowerCaseName : E:Expr,, As:ArgumentList))
                     => val(ExprOptLabelId(IdUid(X), translationExpr(E))),getAllMarks(As)
    rule getAllMarks('argCon(E:Expr,, As:ArgumentList)) => getAllMarks(As)


    rule getAllNormals(~ X:LowerCaseName) => .ElemList
    rule getAllNormals(~ X:LowerCaseName : E:Expr) => .ElemList
    rule getAllNormals(? X:LowerCaseName) => .ElemList
    rule getAllNormals(? X:LowerCaseName : E:Expr) => .ElemList
    rule getAllNormals(E:Expr) => val(translationExpr(E))
    rule getAllNormals('argCon(~ X:LowerCaseName,, As:ArgumentList))
                                   => getAllNormals(As)
    rule getAllNormals('argCon(~ X:LowerCaseName : E:Expr,, As:ArgumentList))
                            => getAllNormals(As)
    rule getAllNormals('argCon(? X:LowerCaseName,, As:ArgumentList)) => getAllNormals(As)
    rule getAllNormals('argCon(? X:LowerCaseName : E:Expr,, As:ArgumentList)) => getAllNormals(As)
    rule getAllNormals('argCon(E:Expr,, As:ArgumentList)) => val(translationExpr(E)),getAllNormals(As)

    //translating Exprs
    rule translationExpr(V:ValuePath) => ExId(translationValuePath(V))
    rule translationExpr(V:Constant) => translationConstant(V)
    rule translationExpr('unaryOp(P:OperatorUnName,, E:Expr))
                                     => ExApp(ExId(IdUid(P)), translationExpr(E))
    rule translationExpr(V:AllowArrowExpr) => translationAllowExpr(V)
    rule translationExpr(E:Expr # S:LowerCaseName) => ExApp(ExApp(ExId(IdUid(getFieldValue))
                                                      ,translationExpr(E)), translationValuePath(S))
    rule translationExpr(assert E:Expr) => ExApp(ExId(IdUid(getFieldValue)), translationExpr(E))
    rule translationExpr(lazy E:Expr) => ExLazy(translationExpr(E))
    rule translationExpr(new F:Field) => ExNew(ExId(translationField(F)))
    rule translationExpr('exprWithTag(C:CapitalizedName,, E:Expr))
                                     => ExTagVal(ExId(IdUid(C)), translationExpr(E))
    rule translationExpr('exprWithConstr(C:Constr,, E:Expr))
                                     =>  ExApp(ExId(translationConstr(C)), translationExpr(E))
    rule translationExpr('unaryOp(Op:ImportantOps,, E:Expr))
                                     => ExApp(ExId(IdUid(Op)), translationExpr(E))
    rule translationExpr('binaryExOp(Op:ExOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryLogicOp(Op:LogicShiftOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('mathTimesOp(Op:MathOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('mathPlusOp(Op:AllPlusAndMinus,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryListOp(Op:ListOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('concatOp(Op:ConcatOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('compareOp(Op:CompareOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryAndOp(Op:BinaryAnd,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryOrOp(Op:BinaryOr,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryUnknownOp(Op:InfixSymbol,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binarySepOp(Op:SepOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryAssignOp(Op:AssignOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr('binaryListSepOp(Op:ListSepOp,, E1:Expr,, E2:Expr))
                                     => ExApp(ExApp(ExId(IdUid(Op))
                                                , translationExpr(E1)),translationExpr(E1))
    rule translationExpr(begin E:Expr end) => translationExpr(E)
    rule translationExpr(if E1:Expr then E2:Expr) 
                      => ExMat(translationExpr(E1), McOr(McArr(true, ExNil, translationExpr(E2)),
                                                    McArr(false, ExNil, ExId(IdUid("()")))))
    rule translationExpr(if E1:Expr then E2:Expr else E3:Expr) 
                      => ExMat(translationExpr(E1), McOr(McArr(true, ExNil, translationExpr(E2)),
                                                    McArr(false, ExNil, translationExpr(E3))))
    rule translationExpr('exprWithArgs(E:Expr,, As:ArgumentList))
                                  => ExAppList(translationExpr(E), getAllTildas(As),
                                                       getAllMarks(As), getAllNormals(As))
                      requires getAllTildas(As) =/=K .ElemList
                          orBool getAllMarks(As) =/=K .ElemList
    rule translationExpr('exprWithArgs(E:Expr,, As:ArgumentList))
                                  => constructApp(translationExpr(E),getAllNormals(As))
                      requires getAllTildas(As) ==K .ElemList
                                 andBool getAllMarks(As) ==K .ElemList
    rule translationExpr(fun 'parameterListExpr(P:Parameter,, .ParameterList,, E:Expr))
                     => ExFun(McArr(translationParam(P), ExNil, translationExpr(E)))
    rule translationExpr(fun 'parameterListExpr(P:Parameter,,
                                        'paramCon(P':Parameter,, Ps:ParameterList),, E:Expr))
                     => ExFun(McArr(translationParam(P), ExNil,
                                   translationExpr(fun 'parameterListExpr(P',, Ps,, E:Expr))))
    rule translationExpr(fun 'paramListWhenExpr(P:Parameter,, .ParameterList,, E1:Expr,, E2:Expr))
                     => ExFun(McArr(translationParam(P), translationExpr(E1), translationExpr(E2)))
    rule translationExpr(fun 'paramListWhenExpr(P:Parameter,,
                                'paramCon(P':Parameter,, Ps:ParameterList),, E1:Expr,, E2:Expr))
                     => ExFun(McArr(translationParam(P), translationExpr(E1),
                                   translationExpr(fun 'parameterListExpr(P',, Ps,, E2:Expr))))
    rule translation(let A:LetBindingList in E:Expr)
                                       => ExLet(translationLetBindings(A),translation(E))
    rule translation(let rec A:LetBindingList in E:Expr)
                                   => ExRec(translationLetBindings(A),translation(E))


/*
syntax Expr ::=
                  > "match" Expr "with" PatternMatching            [klabel('matchingExpr)]
                  | "function" PatternMatching

                  | "try" Expr "with" PatternMatching
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

*/


    //defining let bindings and let binding
    /*
    syntax LetBinding ::= ValueName ParameterList "=" Expr [klabel('letfunexpr)] 
                        | Pattern "=" Expr [klabel('patternexpr), prefer]
                        | ValueName ParameterList ":" TypeExpr "=" Expr
                        | ValueName ParameterList ":>" TypeExpr "=" Expr
                        | ValueName ParameterList ":" TypeExpr ":>" TypeExpr "=" Expr
    syntax LetBindingList ::= LetBinding | LetBinding "and" LetBindingList
    */
     rule translationLetBindings(L:LetBinding) => translationLetBinding(L)
     rule translationLetBindings(L1:LetBinding and L2:LetBindingList)
                         => BindingAnd(translationLetBinding(L1),translationLetBindings(L2))
     rule translationLetBinding('patternexpr(X:Pattern,, E:Expr))
                              => BindingEquality(translationPattern(X), ExNil, ExNil, translation(E))
     rule translationLetBinding('letfunexpr(X:ValueName,, .ParameterList,, E:Expr))
                      => BindingEquality(PatternIdentifier(IdUid(X)), ExNil, ExNil,
                                 translationExpr(E))
     rule translationLetBinding('letfunexpr(X:ValueName,,
                                    'paramCon(P:Parameter,, Ps:ParameterList),, E:Expr))
                      => BindingEquality(PatternIdentifier(IdUid(X)), ExNil, ExNil,
                                 translationExpr(fun 'parameterListExpr(P,, Ps,, E)))
     rule translationLetBinding(X:ValueName .ParameterList
                                                    : T1:TypeExpr = E:Expr)
                   => BindingEquality(PatternIdentifier(IdUid(X)),
                       translationTypeExpr(T1), ExNil, translationExpr(E))
     rule translationLetBinding(X:ValueName 'paramCon(P:Parameter,, Ps:ParameterList)
                                       : T1:TypeExpr = E:Expr)
                      => BindingEquality(PatternIdentifier(IdUid(X)),
                                 translationTypeExpr(T1), ExNil,
                                 translationExpr(fun 'parameterListExpr(P,, Ps,, E)))
     rule translationLetBinding(X:ValueName .ParameterList
                                                           :> T2:TypeExpr = E:Expr)
                   => BindingEquality(PatternIdentifier(IdUid(X)),
                       ExNil, translationTypeExpr(T2), translationExpr(E))
     rule translationLetBinding(X:ValueName 'paramCon(P:Parameter,, Ps:ParameterList)
                                       :> T2:TypeExpr = E:Expr)
                      => BindingEquality(PatternIdentifier(IdUid(X)),
                                 ExNil, translationTypeExpr(T2),
                                 translationExpr(fun 'parameterListExpr(P,, Ps,, E)))
     rule translationLetBinding(X:ValueName .ParameterList : T1:TypeExpr
                                                           :> T2:TypeExpr = E:Expr)
                   => BindingEquality(PatternIdentifier(IdUid(X)),
                       translationTypeExpr(T1), translationTypeExpr(T2), translationExpr(E))
     rule translationLetBinding(X:ValueName 'paramCon(P:Parameter,, Ps:ParameterList)
                                       : T1:TypeExpr :> T2:TypeExpr = E:Expr)
                      => BindingEquality(PatternIdentifier(IdUid(X)),
                                 translationTypeExpr(T1), translationTypeExpr(T2),
                                 translationExpr(fun 'parameterListExpr(P,, Ps,, E)))

    //Translation Parameters
    /*
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
    */
    rule translationParam(P:Pattern) => translationPattern(P)
    rule translationParam(? X:LowerCaseName : (P:Pattern = E:Expr))
                           => optionalLabelPattern(IdUid(X),
                                           translationPattern(P), ExNil, translation(E))
    rule translationParam(? X:LowerCaseName : (P:Pattern : T:TypeExpr = E:Expr))
                           => optionalLabelPattern(IdUid(X),
                                translationPattern(P), translationTypeExpr(T), translation(E))

    rule translationParam(? (X:LowerCaseName : T:TypeExpr))
                           => optionalLabelPattern(IdUid(X),
                                           ExNil, translationTypeExpr(T), ExNil)
    rule translationParam(? (X:LowerCaseName = E:Expr))
                           => optionalLabelPattern(IdUid(X),
                                           ExNil, ExNil, translation(E))
    rule translationParam(? (X:LowerCaseName : T:TypeExpr = E:Expr))
                           => optionalLabelPattern(IdUid(X),
                                           ExNil, translationTypeExpr(T), translation(E))
    rule translationParam('parameterLabelPattern(X:LowerCaseName,, P:Pattern))
                           => optionalLabelPattern(IdUid(X),
                                           translationPattern(P) ,ExNil ,ExNil)
    rule translationParam('parameterLabelPatternType(X:LowerCaseName,,
                                                           P:Pattern,, T:TypeExpr))
                           => optionalLabelPattern(IdUid(X),
                                           translationPattern(P), translationTypeExpr(T), ExNil)
    rule translationParam(? X:LowerCaseName : P:Pattern)
                           => optionalLabelPattern(IdUid(X),
                                           translationPattern(P), ExNil, ExNil)
    rule translationParam(? X:LowerCaseName)
                           => optionalLabelPattern(IdUid(X),
                                           ExNil, ExNil, ExNil)
    rule translationParam('parenthesisOptionalLabel(X:LowerCaseName))
                           => optionalLabelPattern(IdUid(X),
                                           ExNil, ExNil, ExNil)
    rule translationParam(~ X:LowerCaseName)
                           => tildaLabelPattern(IdUid(X),
                                           ExNil, ExNil, ExNil)
    rule translationParam('parenthesisLabel(X:LowerCaseName))
                           => tildaLabelPattern(IdUid(X),
                                           ExNil, ExNil, ExNil)
    rule translationParam(~ X:LowerCaseName : P:Pattern)
                           => tildaLabelPattern(IdUid(X),
                                           translationPattern(P), ExNil, ExNil)
    rule translationParam(~ (X:LowerCaseName : T:TypeExpr))
                           => tildaLabelPattern(IdUid(X),
                                           ExNil, translationTypeExpr(T), ExNil)

    //translation of top level
    rule translation(D:Definition) => translationDef(D)
    rule translation(E:Expr) => translationExpr(E)
    rule translation(M:ModuleItemListFactor D:Definition)
                           => StSem(translation(M), translationDef(D))
    rule translation(M:ModuleItemListFactor ;; D:Definition)
                           => StSem(translation(M), translationDef(D))
    rule translation(M:ModuleItemListFactor ;; E:Expr)
                           => StSem(translation(M), translationExpr(E))

    syntax KItem ::= flipOrder(K, K)    [function]
    rule flipOrder(StSem(A:K, B:K), .K) =>  flipOrder(A, B)
    rule flipOrder(StSem(A:K, B:K), C:K) =>  flipOrder(A, StSem(B, C))
          when B =/=K .K
    rule flipOrder(A, .K) => A
    rule flipOrder(A, C:K) => StSem(A, C)    [owise]
/*
rule BinaryAnd(true, true) => ExBool(true) 
rule BinaryAnd(false, _) => ExBool(false)
rule BinaryAnd(true, false) => ExBool(false)

*/

    syntax KItem ::= substitution(K, K, K)  [function]//type id, type expr, to expr
    syntax List ::= substitutionInList(K,K, List)     [function]
    syntax Map ::= substitutionInMap(K, K, Map)       [function]
                 | substitutionInMapList(List, Map)   [function]

    rule substitution(A:K, B:K, A) => B
         requires getKLabel(A) ==KLabel 'TyId
    rule substitution(A:K, B:K, C:SimpleTypeKItem) => C
    rule substitution(A:K, B:K, none) => none
    rule substitution(A:K, B:K, TyList(C:K)) => TyList(substitution(A, B, C))
    rule substitution(A:K, B:K, TyPair(C:K, D:K))
                      => TyPair(substitution(A, B, C), substitution(A, B, D))
    rule substitution(A:K, B:K, TyFun(C:K, D:K, E:K))
                      => TyFun(C, substitution(A, B, D), substitution(A, B, E))
    rule substitution(A:K, B:K, TyConstr(C:K)) => TyConstr(substitution(A, B, C))
    rule substitution(A:K, B:K, TyTilda(C:K)) => TyTilda(C)
    rule substitution(A:K, B:K, TyQuestionMark(C:K)) => TyQuestionMark(C)
    rule substitution(A:K, B:K, TyListCons(C:K, D:K))
                         => TyListCons(substitution(A, B, C), substitution(A, B, D))
    rule substitutionInList(A:K, B:K, .List) => .List
    rule substitutionInList(A:K, B:K, ListItem(unifier(C:K, D:K)) L:List)
                 => ListItem(unifier(substitution(A,B,C), substitution(A,B,D))) substitutionInList(A, B, L)

    rule substitutionInMap(A:K, B:K, .Map) => .Map
    rule substitutionInMap(A:K, B:K, (X:K |-> C:K M:Map))
                 => X |-> substitution(A, B, C) substitutionInMap(A, B, M)
    rule substitutionInMapList(.List, M:Map) => M
    rule substitutionInMapList(ListItem(unifier(A:K, B:K)) L:List, M:Map)
                 => substitutionInMapList(L, substitutionInMap(A, B, M))

    syntax KItem ::= "badState"
    syntax List ::= decompose(KList, KList) [function]
    rule decompose(.KList, .KList) => .List
    rule decompose(A:K,, Kl:KList, B:K,, Kl':KList)
               => ListItem(unifier(A, B)) decompose(Kl, Kl')
    rule decompose(A:KList , B:KList)
               => ListItem(badState)

    rule <k> toUnify => .K ...</k>
         <unifiers> .List </unifiers>
         <unfiySubst> L':List </unfiySubst>
         <types> TEnv:Map => substitutionInMapList(L', TEnv) </types>

    rule <k> toUnify ...</k>
         <unifiers> (ListItem(unifier(A:K, TyId(B:K)))
                        => ListItem(unifier(TyId(B), A))) L:List </unifiers>
         <unfiySubst> L':List </unfiySubst>
         requires getKLabel(A) =/=KLabel 'TyId

    rule <k> toUnify ...</k>
         <unifiers> (ListItem(unifier(A:K, A:K)) => .List) L:List </unifiers>
         <unfiySubst> L':List </unfiySubst>

    rule <k> toUnify ...</k>
         <unifiers> (ListItem(unifier(F:KLabel(Kl:KList), F(Kl':KList)))
                                    => decompose(Kl, Kl')) L:List </unifiers>
         <unfiySubst> L':List </unfiySubst>

    rule <k> toUnify ...</k>
         <unifiers> (ListItem(unifier(TyId(B:K), A:K)) => .List)
                    (L:List => substitutionInList(TyId(B:K), A, L)) </unifiers>
         <unfiySubst> L':List => substitutionInList(TyId(B:K), A, L') </unfiySubst>
         requires A =/=K TyId(B)

    rule <k> typeInfer(A:K) => typeInferInExpr(TEnv, A, !X:Id) ...</k>
         <types> TEnv:Map </types>
         requires getKLabel(A) =/=KLabel 'StSem
    rule <k> typeInfer(StSem(A:K, B:K)) => typeInferInExpr(TEnv, A, !X:Id) ~> typeInfer(B) ...</k>
         <types> TEnv:Map </types>

/*
    rule <k>typeInferInExpr(Env:Map, ExInt(I:Int), X:Id)
                 => resultType(unification(getFirst(L ListItem(unifier(X, int))))) ...</k>
         <unifiers> L:List (.List  => ListItem(unifier(X, int))) </unifiers>
    rule <k> typeInferInExpr(ExId(A:Id), X:Id) => resultType(unification(X)) ...</k>
         <types>... A |-> T:K ...</types>
         <unifiers> L:List (.List => ListItem(unifier(X, T))) </unifiers>
    rule <k> typeInferInExpr(ExId(A:Id), X:Id) ~> K => .K </k>
         <stdout>... .List => ListItem("Error: Unbound value a") </stdout>
         <types> M:Map </types>
         requires notBool (A in keys(M))
*/


    rule <k> typeInfer(A:K) => typeInferInExpr(TEnv, A, !X:Id) ~> toUnify ...</k>
         <types> TEnv:Map </types>
         requires getKLabel(A) =/=KLabel 'StSem
    rule <k> typeInfer(StSem(A:K, B:K)) => typeInferInExpr(TEnv, A, !X:Id) ~> toUnify ~> typeInfer(B) ...</k>
         <types> TEnv:Map </types>
    rule <k> (resultType(L:List) => .K) ~> toUnify ...</k>
         <unifiers> _:List => L </unifiers>


    rule typeInferInExpr(TEnv:Map, ExInt(I:Int), X:K)
                 => resultType(ListItem(unifier(X, int)))

    //deal with ids
    rule typeInferInExpr(TEnv:Map, ExId(A:Id), X:K) => resultType(ListItem(unifier(X,TEnv[A])))
         requires A in keys(TEnv)
    rule <k> typeInferInExpr(TEnv:Map, ExId(A:Id), X:K) => resultType(ListItem(unifier(X,T))) ...</k>
         <types>... A |-> T:K ...</types>
         requires notBool A in keys(TEnv)

    //translation of fun
    rule typeInferInExpr(TEnv:Map, ExFun(McArr(tildaLabelPattern(X:Id, E1:K, T:K, E3:K), ExNil, E:K)), Tau:K)
                       => typeInferInExpr(TEnv[X <- T], E, TyId(!Beta:Id))
                              ~> typeInferInExpr(TEnv, TyFun(TyTilda(X), T, TyId(!Beta)), Tau)
         requires T =/=K 'ExNil(.KList)

    rule typeInferInExpr(TEnv:Map, ExFun(McArr(tildaLabelPattern(X:Id, E1:K, ExNil, E3:K), ExNil, E:K)), Tau:K)
                       => typeInferInExpr(TEnv[X <- TyId(!Alpha:Id)], E, TyId(!Beta:Id))
                              ~> typeInferInExpr(TEnv, TyFun(TyTilda(X), TyId(!Alpha), TyId(!Beta)), Tau)

    rule typeInferInExpr(TEnv:Map, ExFun(McArr(optionalLabelPattern(X:Id, E1:K, T:K, E3:K), ExNil, E:K)), Tau:K)
                       => typeInferInExpr(TEnv[X <- T], E, TyId(!Beta:Id))
                              ~> typeInferInExpr(TEnv, TyFun(TyQuestionMark(X), T, TyId(!Beta)), Tau)
         requires T =/=K 'ExNil(.KList) 
         
    rule typeInferInExpr(TEnv:Map, ExFun(McArr(optionalLabelPattern(X:Id, E1:K, ExNil, E3:K), ExNil, E:K)), Tau:K)
                       => typeInferInExpr(TEnv[X <- TyId(!Alpha:Id)], E, TyId(!Beta:Id))
                              ~> typeInferInExpr(TEnv, TyFun(TyQuestionMark(X), TyId(!Alpha), TyId(!Beta)), Tau)                

    rule typeInferInExpr(TEnv:Map, ExFun(McArr(Var:K, ExNil, E:K)), Tau:K)
                       => typeInferInExpr(TEnv[Var <- TyId(!Alpha:Id)], E, TyId(!Beta:Id))
                              ~> typeInferInExpr(TEnv, TyFun(none, TyId(!Alpha), TyId(!Beta)), Tau)

    rule resultType(L:List) ~> typeInferInExpr(TEnv:Map , TyFun(X:K, Alpha:K, Beta:K), Tau:K)
                     => resultType(L ListItem(unifier(Tau, TyFun(X:K, Alpha, Beta))))

endmodule


module OCAML-CONFIGURATION
    imports OCAML-SYNTAX
    imports OCAML-TRANS
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS



    configuration
        <T>
            <k color="LightGreen"> initEnv ~> typeInfer(flipOrder(translation($PGM:ModuleItemListFactor), .K)) </k>
            <env color="LightSkyBlue"> .Map </env>
            <store color="LightSteelBlue"> .Map </store>
            <tenv color="GreenYellow"> .Map </tenv>
            <types color="GreenYellow"> .Map </types>
            <unifiers color="GreenYellow"> .List </unifiers>
            <unfiySubst color="GreenYellow"> .List </unfiySubst>
            <xstack color="LightSlateBlue"> .K </xstack>
            <nextLocation> 0 </nextLocation>
            <assign> .Map </assign>
            <records>
                <record multiplicity="*">
                    <recordId> 0 </recordId>
                    <fields> .Map </fields>
                </record>
            </records>
            <br/>
            <matchAnalysis multiplicity="?" color="LightGoldenrod">
                <matchK color="PaleGreen"> matching </matchK>
                <cases> .K </cases>
                <scrutinee> .K </scrutinee>
                <expr> .K </expr>
            </matchAnalysis>
            <br/>
            <patternAttempts>
                <patternAttempt multiplicity="*">
                    <patterns color="Violet"> .K </patterns>
                    <subst color="GreenYellow"> .Map </subst>
                </patternAttempt>
            </patternAttempts>
            <output> "" </output>
            <stdout stream="stdout"> .List </stdout>
        </T>
        <result multiplicity="?" color="DodgerBlue">
            <exprResult> .K </exprResult>
            <outputInResult> "" </outputInResult>
        </result>


endmodule

module OCAML-APPLICATION
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX

/*
    syntax KItem ::= apply(K, KList) [strict]
    syntax KItem ::= apply(Map, K, KList) [strict]

    //syntax KItem ::= dealWithExternal(K) [strict]
    syntax KItem ::= flattenApp(K, ElemList)

 //   rule ExApp(K1:K, K2:KList) => apply(K1,val(K2)) // what does val do?
 //rule ExApp(K1:K, K2:KList) => apply(K1,K2)

    rule flattenApp(ExApp(K:K, Arg:K), Args:ElemList) => flattenApp(K, val(Arg), Args)
    rule flattenApp(PaApp(K:K, Arg:K), Args:ElemList) => flattenApp(K, val(Arg), Args)
    rule flattenApp(K:K, Args:ElemList) => dealWithExternal(apply(K, Args))
        when getKLabel(K) =/=KLabel 'ExApp orBool getKLabel(K) =/=KLabel 'PaApp
*/
endmodule

module OCAML-EXTERNAL
    imports OCAML-APPLICATION

    syntax KItem ::= "external" "(" K "," Int ")"
    syntax KResult ::= "externalClosure" "(" K "," Int "," ElemList ")"
    //syntax KResult ::= externalClosureResult(K, Int, ElemList)

    syntax Int ::= lengthKList(KList) [function]

    rule lengthKList(.KList) => 0
    rule lengthKList((K:K ,, KL:KList)) => 1 +Int lengthKList(KL)

    /*rule 'isKResult(externalClosure(_, Arity:Int, _)) => true
        when Arity >Int 0 */

    rule
        external(Op:K, Arity:Int)
        => externalClosure(Op, Arity, .ElemList)
        when Arity >=Int 0

    syntax External ::= "%undefined"

    //context apply(externalClosure(_:External, _, _), _:KList,, HOLE,, _:KList) [superheat]

/*    rule
        apply(externalClosure(Op:K, Arity:Int, Args:ElemList), NewArgs:KResult)
        => externalClosure(Op, Arity -Int 1, combineElemList(Args, valValue(NewArgs)))
        when Arity >Int 1
  
    rule apply(externalClosure(Op:K, Arity:Int, Args:ElemList), NewArgs:KResult)
        => getKLabel(Op)(toKList(combineElemList(Args, valValue(NewArgs))))
        when Arity ==Int 1
*/
endmodule

module OCAML-INCLUDE
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS
    imports OCAML-CONFIGURATION
    imports OCAML-APPLICATION
    imports OCAML-EXTERNAL

endmodule

module OCAML-UNIT
    imports OCAML-INCLUDE

    syntax KResult ::= "unit"
    rule IdUid("()") => unit

endmodule

module OCAML-ARITHMETIC
    imports OCAML-INCLUDE

    rule ExInt(I:Int) => I

    syntax External
      ::= "%addint"
        | "%subint"
        | "%mulint"
        | "%divint"
        | "%modint"
        | "%negint"

    rule '%addint(I1:Int,, I2:Int) => I1 +Int I2
    rule '%subint(I1:Int,, I2:Int) => I1 -Int I2
    rule '%mulint(I1:Int,, I2:Int) => I1 *Int I2
    rule '%divint(I1:Int,, I2:Int) => I1 /Int I2
    rule '%modint(I1:Int,, I2:Int) => I1 %Int I2
    rule '%negint(I:Int) => 0 -Int I

    rule valValue(I:Int) => I 

endmodule

module OCAML-BOOLEANS
    imports OCAML-INCLUDE

    rule IdUid("False") => false
    rule IdUid("True") => true

    syntax External ::= "%boolnot"

    rule '%boolnot(false) => true
    rule '%boolnot(true) => false

    syntax LazyExternal ::= "%sequand" | "%sequor"

    rule '%sequand(Exp1:K,, Exp2:K) => ExIfe(Exp1, Exp2, false)
    rule '%sequor(Exp1:K,, Exp2:K) => ExIfe(Exp1, true, Exp2)

endmodule

module OCAML-CONTROL-FLOW
    imports OCAML-INCLUDE

    rule ExIfe(true, Exp:K, _) => Exp
    rule ExIfe(false, _, Exp:K) => Exp

    rule
        <k> ExSeq(K:K) => K ...</k>

    rule
        <k> ExSem(V:KResult, Exp:K) => Exp ...</k>

endmodule

module OCAML-LET-LETREC
    imports OCAML-INCLUDE

    //@ Variable lookup
    rule
        <k> ExId(LId:K) => K ...</k>
        <env>... LId |-> L:Location ...</env>
        <store>... L |-> K:K ...</store>



    syntax KItem ::= "group" "(" K "," K ")"
    syntax KItem ::= "letbody" "(" K ")"

    // TODO this can probably be better
/*
    rule
        <k> ExLet(Binding:K, Exp:K)
            => group(ExId(IdUid("()")), PatternIdentifier(IdUid("()")))
            ~> Binding ~> letbody(Exp) ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> group(_, _) ~> (BindingAnd(Binding1:K, Binding2:K) => Binding1 ~> Binding2) ...</k>

    rule
        <k> group(Exp1:K, Pat1:K) ~> BindingEquality(Pat2:K, _:K, _:K, Exp2:K)
            => group(ExCom(Exp1, Exp2), PaCom(Pat1, Pat2))
        ...</k>



    rule ExCom(V1:KResult, V2:KResult) => ExComValue(V1,V2)

    rule
        <k> group(Exp1:K, Pat:K) ~> letbody(Exp2:K) ~> K
            => ExMat(Exp1, McArr(Pat, ExNil, Exp2)) ~> K
        </k>

    syntax KItem ::= "recbind" "(" K ")"
   
    syntax KItem ::= "assignType" "(" K ")"
    syntax KItem ::= "assignTypes" "(" K ")"


    context assign(BindingEquality(_, _, _, HOLE))

    rule
        <k> ExLetRec(Binding:K, Exp:K) => recbind(Binding) ~> assign(Binding) ~> Exp ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> recbind(BindingAnd(Binding1:K, Binding2:K)) => recbind(Binding1) ~> recbind(Binding2) ...</k>

    rule
        <k> assign(BindingAnd(Binding1:K, Binding2:K)) => assign(Binding1) ~> assign(Binding2) ...</k>

    rule
        <k> recbind(BindingEquality(PatternIdentifier(X:Id), _:K, _:K, _)) => . ...</k>
        <env> Env:Map => Env[X <- Location(N)] </env>
        <nextLocation> N:Int => N +Int 1 </nextLocation>

    rule
        <k> assign(BindingEquality(PatternIdentifier(X:Id), _:K, _:K, V:KResult)) => .K ...</k>
        <env>... X |-> L:Location ...</env>
        <store>... .Map => L |-> V ...</store>
*/

 //   rule type T:TypeDef Ts:TypeDefList   =>  assignType(T) ~>  assignTypes(Ts)
  //  rule assignTypes(.TypeDefList) => . 
  //  rule assignTypes(T:TypeDef Ts:TypeDefList) => assignType(T) ~> assignTypes(Ts)

  //  rule 

endmodule

module OCAML-FUNCTIONS
    imports SUBSTITUTION
    imports OCAML-INCLUDE
/*
    rule
        <k> ExId(UId:UId) => UId ...</k>

    //context apply(UId:UId, _:KList,, HOLE,, _:KList) [superheat]

    rule apply(UId:UId, VS:ElemList) => cons(UId, VS)

    syntax KResult ::= "closure" "(" Map "," K ")"
    syntax KResult ::= closure(Map, K, KList, KList, K)
    syntax KItem ::= "reduceClosure" "(" Map "," K ")"
    //syntax KResult
                    
    //context apply(closure(_, _), _:KList,, HOLE,, _:KList)

   rule
        <k> ExFun(MC:K) => closure(Env, MC) ...</k>
        <env> Env:Map </env> 

   rule <k> funlabel(NArg1:K, T1:KList, O1:KList, R1:K) => closure(Env, NArgs1, T1, O1, R1)  ... </k>
        <env> Env:Map </env>   


*/

  /*  rule
        <k> apply(closure(Env':Map, MC:K), V:KResult) => ExMat(V, MC) ~> env(Env) ...</k>
        <env> Env => Env' </env>

        when getKLabel(V) =/=KLabel 'ExprLabelIdVal
*/
    //TODO: rule closure(_, K:KResult) => K


syntax KItem ::= matchLabel(K, K, K) 
                | "matched" "(" K ")"
    
  //  rule <k> labelPattern()

   /* rule <k> apply(closure(Env':Map, Matching:K), ExprLabelIdVal(L:Id, C:KResult)) => matchLabel(Matching, L, C) 
    ~> closure(Env':Map + MapItem(L |-> C), Matching) ~> env(Env) ... </k>
    <env> Env => Env' </env>
*/
 /*   rule matchLabel(McArr(labelPattern(L:Id, false, Pattern:K, Type:K, Default:K), S:K , E1:K), L, E2:K) => matched(McArr(labelPattern(L, true, Pattern, Type, Default), S, E1))
    rule matchLabel(McArr(labelPattern(P:Id, false, Pattern:K, Type:K, Default:K), S:K , E1:K), L:Id, E2:K) => matchLabel(E1, L, E2) 
    ~> matchLabel(McArr(labelPattern(P:Id, false, Pattern:K, Type:K, Default:K), S, E1), L, E2) when P =/=K L

    rule (matched(MC:K) ~> matchLabel(McArr(P:K, S:K, E1:K), L:Id, E2:K)) => matched(McArr(P, S, MC))

    rule (matched(MC:K) ~> closure(Env':Map , _)) => reduceClosure(Env', MC)
    rule reduceClosure(Env, McArr(labelPattern(L:Id, true, _, _, _), S:K, E1:K))=> reduceClosure(Env, E1)
    rule reduceClosure(Env, V:KResult) => V

    rule reduceClosure(Env, McArr(labelPattern(L:Id, false, Pattern:K, Type:K, Default:K), S:K, E1:K)) => 
    closure(Env, McArr(labelPattern(L:Id, false, Pattern:K, Type:K, Default:K), S:K, E1:K))

    rule reduceClosure(Env, McArr(P:K, S:K, E1:K)) => 
    closure(Env, McArr(P, S:K, E1:K))   //where P =/= labelPattern
*/

/*ToDo
    rule
        <k> apply(closure(Env':Map, MC:K), V:KResult, Args:ElemList) => apply(ExMat(V, MC), Args) ~> env(Env) ...</k>
        <env> Env => Env' </env>
*/
syntax KItem ::= matchArgs(Map, K, KList, KList, K, KList) 
                | copylabels(KList, KList, K)

/*TODO
    rule <k> apply(closure(Env':Map,NArg1:K, T1:KList, O1:KList, R1:K), Args:KList) => 
        matchArgs(Env':Map,NArg1:K, T1:KList, O1:KList, R1:K, Args:KList) ~> env(Env) ... </k>
<env> Env => Env' </env>
*/



//Liyi, is that syntactically correct? Which adaptations do you propose?
/* rule matchArgs(Env':Map,NArg1:K, T1:KList, ... optionalLabelPattern(I:Id, B:Bool, P:K, T:K, DV:K) ..., R1:K, ... ExprOptLabelIdVal(X:Id, V:KResult)...) => 
    matchArgs(Env':Map (.Map => I:Id |-> V) , NArg1:K, T1:KList, 
      ... optionalLabelPattern(I:Id, False => True, P:K, T:K, DV:K) ..., R1:K, ... (ExprOptLabelIdVal(I:Id, V:KResult) => .KList) ...)


rule matchArgs(Env':Map (.Map => I:Id |-> V) , NArg1:K, ... tildeLabelPattern(I:Id, False => True, P:K, T:K, DV:K) ..., O:Klist, 
      R1:K, ... (ExprLabelIdVal(I:Id, V:KResult) => .KList) ...)
//We need an efficient way to go through "R1" and find the first non-labeled argument that matches. Any suggestions?
rule matchArgs(Env':Map, Pattern:K, TList: KList, OList:KList, R1:K, Args:KList) => apply(Env', copylabels(TList, OList, ExMat(R1, Pattern, R1)), Args)
  when notBool (OList contains optionalLabelPattern(I2:Id, B:Bool, P:K, T:K, DV:K) && Args contains ExprOptLabelIdVal(I2:Id, V:KResult))
  

*/


endmodule

module OCAML-EXCEPTIONS
    imports OCAML-INCLUDE

    syntax External ::= "%raise"
    syntax KItem ::= xex(K, K, Map) [avoid]
    syntax KItem ::= "popx"

    rule
        <k> (ExTry(Exp:K, MC:K) => Exp ~> popx) ~> K:K </k>
        <env> Env:Map </env>
        <xstack> . => xex(K, MC, Env) ...</xstack>

    rule
        <k> V:KResult ~> popx => V ...</k>
        <xstack> K:K => . ...</xstack>

    rule
        <k> '%raise(V:KResult) ~> _ => ExMat(V, McOr(MC, McArr('wildcard(.KList), ExNil, 'primRaise(V)))) ~> K </k>
        <xstack> xex(K:K, MC:K, Env:Map) => . ...</xstack>
        <env> _ => Env </env>

endmodule

module OCAML-RECORDS
    imports OCAML-INCLUDE
    imports OCAML-UNIT

    syntax KResult ::= "recordEntry" "(" Int ")"

    rule
        <k> ExRec(K:K, _) => recordEntry(N) ...</k>
        <nextLocation> N:Int => N +Int 1 </nextLocation>
        ( . =>
            <record>...
                <recordId> N </recordId>
                <fields> getFields(K) </fields>
            ...</record>
        )

    syntax Map ::= getFields(K)   [function]
    rule getFields(RbSem(R1:K, R2:K)) => getFields(R1) getFields(R2)
    rule getFields(RbEq(Id:Id, K:K)) => Id |-> K

    rule
        <k> ExAcc(recordEntry(N:Int), ExId(X:K)) => V ...</k>
        <recordId> N </recordId>
        <fields>... X |-> V:KResult ...</fields>

    context ExAss(ExAcc(HOLE, _), _)

    rule
        <k> ExAss(ExAcc(recordEntry(N:Int), ExId(X:K)), V:KResult) => unit ...</k>
        <recordId> N </recordId>
        <fields>... X |-> (_ => V) ...</fields>
        [supercool]

endmodule

module OCAML-REF
    imports OCAML-INCLUDE

    syntax External ::= "%ref" // %makemutable

//    rule
//        <k> '%ref(V:KResult) => ExRec(RbEq(IdLid("val"), V), ExNil) ...</k>
//
endmodule

module OCAML-IO
    imports OCAML-INCLUDE
    imports OCAML-UNIT

    syntax External
      ::= "%print-int"

    rule
        <k> '%print-int(I:Int) => unit ...</k>
        <output> S:String => S +String Int2String(I) </output>
        [supercool]

endmodule


//Michael: this pattern matching might contains problems
//because it requires associative matching in K, but K doesn't have associative matching anymore. 
module OCAML-PATTERNS
    imports OCAML-INCLUDE
    imports OCAML-UNIT

    syntax KItem ::= "pattern-failure" "(" K "," K ")"


/*TODO: fix the syntax
    rule PatternInteger(I:Int) <- I => .K [anywhere]
*/

    rule
        <patterns> (PatternIdentifier(X:Id) <- K:K) => .K ...</patterns>
        <subst>... .Map => X |-> K ...</subst>

    rule 'wildcard(.KList) <- K:K => .K [anywhere] //wildcard. 

//    rule PatternIdentifier(UId:UId) <- UId => .K [anywhere]

   // rule PatternIdentifier(IdUid("()")) <- unit => .K [anywhere]

    rule PaTup(Pat:K) <- ExTup(Exp:K) => Pat <- Exp [anywhere]

/*
    rule PaCom(Pat1:K, Pat2:K) <- ExComValue(Exp1:K, Exp2:K) =>
               (Pat1 <- Exp1)
               ~> (Pat2 <- Exp2) [anywhere]
*/
/*TODO:
    rule ((PaApp(Pat1:K, Pat2:K) => flattenApp(PaApp(Pat1, Pat2), .ElemList)) <- _)
         [anywhere]

    rule apply(Pat:K, Pats:ElemList) <- cons(UId:UId, Args:ElemList)
            => (Pat <- UId) ~> zip<-(Pats, Args)
         [anywhere]
*/
    syntax KItem ::= "zip<-" "(" ElemList "," ElemList ")" [function]
    rule zip<-(valValue(Pat:K), Pats:ElemList, valValue(Arg:K), Args:ElemList)
                  => (Pat <- Arg) ~> zip<-(Pats, Args)
    rule zip<-(.ElemList, .ElemList) => .K

    rule
        <patterns> PaAli(Pat:K, PatternIdentifier(X:Id)) <- Exp:K => Pat <- Exp ...</patterns>
        <subst>... .Map => X |-> Exp ...</subst>

    rule
        <patternAttempt>...
            <patterns> PaOrp(Pat1:K, Pat2:K) <- Exp:K ~> Rest:K </patterns>
            <subst> Subst:Map </subst>
        ...</patternAttempt>
        =>
        <patternAttempt>...
            <patterns> Pat1 <- Exp ~> Rest:K </patterns>
            <subst> Subst </subst>
        ...</patternAttempt>
        <patternAttempt>...
            <patterns> Pat2 <- Exp ~> Rest:K </patterns>
            <subst> Subst </subst>
        ...</patternAttempt>

    rule
        <patterns> (Pat:K <- K:K) ~> Rest:K => pattern-failure(Pat, K) </patterns>
        when notBool (matches K Pat)

    rule
        <patternAttempt>...
            <patterns> pattern-failure(_, _) </patterns>
        ...</patternAttempt>
        => .Bag

    /*@ Unfortunately, we have to define the predicate below since we don't
    have a way of saying "when no other rule matches" */
    syntax Bool ::= "matches" K K [function]
    rule matches _ PatternIdentifier(LId:LId) => true
    rule matches UId:UId PatternIdentifier(UId) => true
    rule matches unit PatternIdentifier(IdUid("()")) => true
    rule matches _ 'wildcard(.KList) => true
    rule matches _ PaAli(_, _) => true
    rule matches _ PaTyc(_, _) => true
    rule matches _ PaOrp(_, _) => true
    rule matches ExTup(_) PaTup(_) => true
    rule matches ExComValue(_, _) PaCom(_, _) => true
    rule matches I:Int PatternInteger(I) => true
    rule matches . . => true
    rule matches _ _ => false [owise]

endmodule

module OCAML-MATCHING
    imports OCAML-INCLUDE
    imports OCAML-PATTERNS



    rule
        <k> ExMat(V:KResult, MC:K) => matching ...</k>
        (. =>
            <matchAnalysis>...
                <cases> MC </cases>
                <scrutinee> V </scrutinee>
            ...</matchAnalysis>
        )

/*TODO:
    rule
        <k> matching => assigning ~> K ~> env(Env) ...</k>
        <env> Env:Map </env>
        <assign> _ => Subst </assign>
        <matchK> match-success(K:K, Subst:Map) => . </matchK>
*/
    syntax KItem
      ::= "match-failure"
        | "match-success" "(" K "," Map ")"

    rule
        <cases> McOr(MC1:K, MC2:K) => MC1 ~> MC2 ...</cases>

    rule
        <matchK> matching => binding </matchK>
        <cases> McArr(Pat:K, _, Exp:K) => . ...</cases>
        <scrutinee> V:KResult </scrutinee>
        <expr> _ => Exp </expr>
        <patternAttempts>
            (_ =>
                <patternAttempt>...
                    <patterns> Pat <- V </patterns>
                ...</patternAttempt>
            )
        </patternAttempts>

    rule
        <matchK> binding => matching </matchK>
        <patternAttempts> .Bag </patternAttempts>

    rule
        <matchK> binding => match-success(Exp, Subst) </matchK>
        <patternAttempts>
            (<patternAttempt>
                <patterns> .K </patterns>
                <subst> Subst:Map </subst>
            </patternAttempt>
            Rest:Bag) => .Bag
        </patternAttempts>
        <expr> Exp:K => .K </expr>

    rule
        <matchK> matching => match-failure </matchK>
        <cases> .K </cases>

    rule
        <matchAnalysis>...
            <matchK> .K </matchK>
        ...</matchAnalysis>
        => .

endmodule

module OCAML-TOP-LEVEL
    //@ Top-level phrases in an OCaml module (also known as structure items?)
    imports OCAML-INCLUDE

    rule
        <k> StSem(K1:K, K2:K) => K1 ~> K2 ...</k>

    //@ Ignore exception definitions since we assume the program type checks
    rule
        <k> StExc(_, _) => .K ...</k>

    rule
        <k> StExp(Exp:K) => Exp ...</k>

endmodule

module OCAML-HELPERS
    imports OCAML-INCLUDE

    rule
        <assign> X:Id |-> K:K => .Map ...</assign>
        <env> Env:Map => Env[X <- Location(N)] </env>
        <store>... .Map => Location(N) |-> K ...</store>
        <nextLocation> N:Int => N +Int 1 </nextLocation>

    rule
        <k> assigning => .K ...</k>
        <assign> .Map </assign>
/*TODO: fixed the syntax
    rule
        <k> V:KResult ~> (env(Env:Map) => .K) ...</k>
        <env> _ => Env </env>
*/
endmodule

module OCAML-INIT
    imports OCAML-INCLUDE
    imports OCAML-ARITHMETIC
    imports OCAML-BOOLEANS
    imports OCAML-REF
    imports OCAML-EXCEPTIONS
    imports OCAML-IO

    syntax KItem ::= preassign(Map)

    // TODO eventually this will go in a separate Pervasives module
/*TODO:syntax problem
    rule
        initEnv => preassign( IdLid(+) |-> external(%addint, 2)
            IdLid(-) |-> external(%subint, 2)
            IdLid(*) |-> external(%mulint, 2)
            IdLid(/) |-> external(%divint, 2)
            IdLid(mod) |-> external(%modint, 2)
    //       IdLid(-) |-> external(%negint, 1))//TODO - monop vs binop 
        ) ~> preassign(
            IdLid(not) |-> external(%boolnot, 1) // to cover later
            IdLid(&&) |-> external(%sequand, 2)
            IdLid(||) |-> external(%sequor, 2)
  //          IdLid(raise) |-> external(%raise, 1)
   //         IdLid(ref) |-> external(%ref, 1)
  //          IdLid(print_int) |-> external(%print-int, 1)
  )
*/
    rule <k> preassign(M':Map) => assigning ...</k>
        <assign> M:Map => M M':Map </assign>
endmodule

module OCAML-CLEANUP
    imports OCAML-INCLUDE

    rule
        <T>...
            <k> V:KResult </k>
            <output> S:String </output>
        ...</T>
        =>
        <result>
            <exprResult> V </exprResult>
            <outputInResult> S </outputInResult>
        </result>

endmodule

module OCAML-SEMANTICS
    imports OCAML-TRANS
    imports OCAML-INCLUDE

    imports OCAML-UNIT
    imports OCAML-ARITHMETIC
    imports OCAML-BOOLEANS

    imports OCAML-CONTROL-FLOW
    imports OCAML-LET-LETREC
    imports OCAML-FUNCTIONS
    imports OCAML-EXCEPTIONS

    imports OCAML-RECORDS
    imports OCAML-REF
    imports OCAML-IO
    imports OCAML-PATTERNS
    imports OCAML-MATCHING

    imports OCAML-TOP-LEVEL

    imports OCAML-HELPERS

    imports OCAML-INIT

    imports OCAML-CLEANUP

endmodule
