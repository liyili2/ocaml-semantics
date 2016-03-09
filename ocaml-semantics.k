requires "ocaml-syntax.k"
requires "ocaml-abstract-syntax.k"
require "modules/substitution.k"

module OCAML-SYNTAX-EXTRAS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX

    syntax KResult ::= Int | Bool | Id 

    syntax KResult ::= "EvalExprLabelId" "(" Id "," K ")" | "EvalExprOptLabelId" "(" Id "," K ")"

    syntax KItem
      ::= "initEnv"
        | "binding"
        | "matching"
        | "assigning"
        | "debug"


    syntax Location ::= Location(Int)
    syntax KResult ::= Location

    syntax KResult ::= cons(K, ElemList)

    syntax KItem ::= env(Map)



endmodule

module OCAML-TRANS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX
    
    syntax KItem ::= translation(ModuleItemListFactor)   [function] 
    syntax KItem ::= translationParam(Parameter) [function] 
    syntax KItem ::= translationTypeExpr(TypeExpr) [function] 
    syntax KItem ::= translationApp(K, ArgumentList) [function]
    syntax KItem ::= translationArg(Argument) [function]
    syntax KItem ::= translationPattern(Pattern) [function]
    syntax KItem ::= translationPatternList(PatternList) [function]
    syntax KItem ::= translationPatternFieldList(FieldPatternList) [function]
    syntax KItem ::= translationParams(ParameterList, Expr) [function] 
    syntax KItem ::= translationLetBindings(LetBindingList) [function]
    syntax KItem ::= translationLetBinding(LetBinding) [function]
    syntax KItem ::= translationLetRecBindings(LetBindingList) [function]
    syntax KItem ::= translationToBindingForm(K) [function]
    syntax KItem ::= translationPatternMatching(PatternMatching) [function]

 syntax KItem ::= "assign" "(" K ")"

    rule translation(I:IntegerLiteral) => ExInt(String2Int(#tokenToString(I)))
    rule translation(F:FloatLiteral) => ExFloat(String2Float(#tokenToString(F)))
    rule translation(B:Bool) => ExBool(B)
   //rule translation('label(L:LabelName,, E:Expr)) => translation()

    //I think these two labels can be put into only one kind of labels.
    rule translation('label('tlabel(L:LowerCaseName),, E:Expr))
                               => ExprLabelId(String2Id(#tokenToString(L)), translation(E))
    rule translation('label('optionalLabel(L:LowerCaseName),, E:Expr))
                               => ExprOptLabelId(String2Id(#tokenToString(L)), translation(E))


    rule translationPattern(X:ValueName)
                              => PatternIdentifier(String2Id(#tokenToString(X))) 
    rule translationPattern(I:IntegerLiteral)
                              => PatternInteger(String2Int(#tokenToString(I)))
    rule translationPattern(I:Constant)
                              => PatternConst(I)
    rule translationPattern(C1:CharLiteral .. C2:CharLiteral)
                              => PatternDoubleChar(C1, C2)
    rule translationPattern('patternList(P:Pattern,, Ps:Pattern))
                           => PaOrp(translationPattern(P), translationPattern(Ps)) 
    rule translationPattern(lazy P:Pattern)
                              => PatternLazy(translationPattern(P))
    rule translationPattern( ( P:Pattern : T:TypeExpr ) )
                              => PaTyc(translationPattern(P), translationTypeExpr(T))
    rule translationPattern('patternWithConstr(C:Constr, P:Pattern))
                              => PaCom(C, translationPattern(P))
    rule translationPattern(` C:CapitalizedName P:Pattern)
                              => PatternTag(C, translationPattern(P))
    rule translationPattern(# Tc:TypeConstr)
                              => PatternIdentifier(Tc)
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
                                   => FieldPattern(F, translationPattern(P))
    rule translationPatternFieldList(F:Field = P:Pattern ; Fps:FieldPatternList)
                                   => PaList(FieldPattern(F, translationPattern(P)),
                                               translationPatternFieldList(Fps))


    rule translation(I:LowerCaseName) => ExId(String2Id(#tokenToString(I)))
    rule translation((O:ImportantOps)) => ExId(IdLid(O))

    rule translationParam(X:ValueName)
                              => PatternIdentifier(String2Id(#tokenToString(X))) 

    rule translationParam(~ X:LowerCaseName)
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, none, none)
    rule translationParam('parenthesisLabel(X:LowerCaseName))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, none, none)
    rule translationParam(? X:LowerCaseName)
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, none, none)
    rule translationParam('parenthesisOptionalLabel(X:LowerCaseName))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, none, none)
    rule translationParam(~ X:LowerCaseName : P:Pattern)
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false,translationPattern(P), none, none)
    rule translationParam(? X:LowerCaseName : P:Pattern)
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false,translationPattern(P), none, none)
    rule translationParam(~ (X:LowerCaseName : T:TypeExpr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, translationTypeExpr(T), none)
    rule translationParam(? (X:LowerCaseName : T:TypeExpr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, translationTypeExpr(T), none)
    rule translationParam(? (X:LowerCaseName = E:Expr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, none, translation(E))
    rule translationParam(? (X:LowerCaseName : T:TypeExpr = E:Expr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, none, translationTypeExpr(T), translation(E))
    rule translationParam('parameterLabelPattern(X:LowerCaseName,, P:Pattern))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false,translationPattern(P) ,none ,none)
    rule translationParam('parameterLabelPatternType(X:LowerCaseName,,
                                                           P:Pattern,, T:TypeExpr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, translationPattern(P), translationTypeExpr(T), none)
    rule translationParam(? X:LowerCaseName : (P:Pattern = E:Expr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, translationPattern(P), none, translation(E))
    rule translationParam(? X:LowerCaseName : (P:Pattern : T:TypeExpr = E:Expr))
                           => labelPattern(String2Id(#tokenToString(X)),
                                           false, translationPattern(P)
                                                     ,translationTypeExpr(T), translation(E))
/*
    rule translationParam(~ L:LowerCaseName)
                           => PatternLabel(String2Id(#tokenToString(L)))
    rule translationParam(? L:LowerCaseName)
                           => PatternOptionalLabel(String2Id(#tokenToString(L)))
*/



//Binary Integer Operator Expressions
 rule translation('mathTimesOp(E1:Expr,, Bin:MathOp ,, E2:Expr)) => ExApp(ExApp(ExId(IdLid(Bin)), translation(E1)),translation(E2)) 
 rule translation('mathPlusOp(E1:Expr,, Bin:AllPlusAndMinus ,, E2:Expr)) => ExApp(ExApp(ExId(IdLid(Bin)), translation(E1)),translation(E2)) 
 rule translation('unaryOp(Un:Minus ,, E1:Expr)) => ExApp(ExApp(ExId(IdLid(Un)), ExInt(0)),translation(E1)) 
 rule translation('unaryOp(Un:MinusDot ,, E1:Expr)) => ExApp(ExApp(ExId(IdLid(Un)), ExFloat(Int2Float(0,53,11))),translation(E1)) 

// Binary boolean Operator Expressions
 rule translation('binaryOrOp (B1:Expr,, Or:BinaryOr ,, B2:Expr)) => ExIfe(translation(B1), ExBool(true), translation(B2))
 rule translation('binaryAndOp (B1:Expr,, Or:BinaryAnd ,, B2:Expr)) => BinaryAnd(translation(B1), translation(B2)) //to be desugared into ExIfe
rule translation('unaryOp(Un:Not ,, E1:Expr)) => ExApp(ExId(IdLid(Un)),translation(E1))



   rule translation(E1:Expr Args:ArgumentList) => translationApp(translation(E1),Args)
   rule translationApp(E1:K, Arg:Argument Args:ArgumentList)
                    => translationApp(ExApp(E1,translationArg(Arg)),Args)
   rule translationApp(E1:K, Arg:Argument)
                    => ExApp(E1,translationArg(Arg))
 
   rule translation(fun 'parameterListExpr(X:Parameter,, Xs:ParameterList,, E:Expr))
                                  => ExFun(McArr(translationParam(X),ExNil,translationParams(Xs, E)))

   rule translationParams(X:Parameter Xs:ParameterList, E:Expr)
                                  => ExFun(McArr(translationParam(X), ExNil, translationParams(Xs, E)))
   rule translationParams(.ParameterList, E:Expr) => translation(E)


 rule translation(E1:Expr ; E2:Expr)  => ExSem(translation(E1),translation(E2))
 rule translation(if E1:Expr then E2:Expr else E3:Expr)
                      => ExIfe(translation(E1),translation(E2),translation(E3))


 rule translation(let A:LetBindingList in E:Expr) => ExLet(translationLetBindings(A),translation(E))
 rule translationLetBinding('patternexpr(X:Pattern,, E:Expr)) => BindingEquality(translationPattern(X), translation(E))
 rule translationLetBinding('letfunexpr(X:ValueName,,  P:Parameter Pl:ParameterList,, E:Expr)) => BindingEquality(PatternIdentifier(String2Id(#tokenToString(X))),
  ExFun(McArr(translationParam(P),ExNil,translationParams(Pl, E))))
 rule translationLetBindings(L:LetBinding) => translationLetBinding(L)
 rule translationLetBindings(L1:LetBinding and L2:LetBindingList)
                               => BindingAnd(translationLetBinding(L1),translationLetBindings(L2))
 

rule translation(let rec A:LetBindingList in E:Expr) => ExLetRec(translationLetBindings(A),translation(E))


rule translation(let rec Bl:LetBindingList in E3:Expr)
                      => ExRec(translationLetRecBindings(Bl),translation(E3))
rule translation(match E1 with P:PatternMatching) //TODO FIX ExMat, adapt to multiple arguments
                    => ExMat(translation(E1),translationPatternMatching(P))
rule translationPatternMatching('patternMatchExpr(P:Pattern,, E:Expr) | Ps:PatternMatchs) => McOr(McArr(translationPattern(P),ExNil,translation(E)), 
        translationPatternMatching(Ps))
rule translationPatternMatching('patternMatchExpr(P:Pattern,, E:Expr)) => McArr(translationPattern(P),ExNil,translation(E))

 rule translation('binarySepOp(E1:Expr,, S:SepOp ,, E2:Expr)) => 'ExTup(translation(E1),, translation(E2))

rule ExBool(B:Bool) => B
rule valValue(B:Bool) => B


rule BinaryAnd(true, true) => ExBool(true) 
rule BinaryAnd(false, _) => ExBool(false)
rule BinaryAnd(true, false) => ExBool(false)



endmodule


module OCAML-CONFIGURATION
    imports OCAML-SYNTAX
    imports OCAML-TRANS
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS



    configuration
        <T>
            <k color="LightGreen"> initEnv ~> translation($PGM:ModuleItemListFactor) </k>
            <env color="LightSkyBlue"> .Map </env>
            <store color="LightSteelBlue"> .Map </store>
            <tenv color="GreenYellow"> .Map </tenv>
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
        </T>
        <result multiplicity="?" color="DodgerBlue">
            <exprResult> .K </exprResult>
            <outputInResult> "" </outputInResult>
        </result>


endmodule

module OCAML-APPLICATION
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX

    syntax KItem ::= apply(K, K) [strict]
    //syntax KItem ::= dealWithExternal(K) [strict]
    syntax KItem ::= flattenApp(K, ElemList)

    rule ExApp(K1:K, K2:K) => apply(K1,val(K2))
/*
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

    rule
        apply(externalClosure(Op:K, Arity:Int, Args:ElemList), NewArgs:KResult)
        => externalClosure(Op, Arity -Int 1, combineElemList(Args, valValue(NewArgs)))
        when Arity >Int 1
  
    rule apply(externalClosure(Op:K, Arity:Int, Args:ElemList), NewArgs:KResult)
        => getKLabel(Op)(toKList(combineElemList(Args, valValue(NewArgs))))
        when Arity ==Int 1

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
        <k> ExId(LId:Id) => K ...</k>
        <env>... LId |-> L:Location ...</env>
        <store>... L |-> K:K ...</store>



    syntax KItem ::= "group" "(" K "," K ")"
    syntax KItem ::= "letbody" "(" K ")"

    // TODO this can probably be better
    rule
        <k> ExLet(Binding:K, Exp:K)
            => group(ExId(IdUid("()")), PatternIdentifier(IdUid("()")))
            ~> Binding ~> letbody(Exp) ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> group(_, _) ~> (BindingAnd(Binding1:K, Binding2:K) => Binding1 ~> Binding2) ...</k>

    rule
        <k> group(Exp1:K, Pat1:K) ~> BindingEquality(Pat2:K, Exp2:K)
            => group(ExCom(Exp1, Exp2), PaCom(Pat1, Pat2))
        ...</k>

    rule
        <k> group(Exp1:K, Pat:K) ~> letbody(Exp2:K) ~> K
            => ExMat(Exp1, McArr(Pat, ExNil, Exp2)) ~> K
        </k>

    syntax KItem ::= "recbind" "(" K ")"
   
    syntax KItem ::= "assignType" "(" K ")"
    syntax KItem ::= "assignTypes" "(" K ")"


    context assign(BindingEquality(_, HOLE))

    rule
        <k> ExLetRec(Binding:K, Exp:K) => recbind(Binding) ~> assign(Binding) ~> Exp ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> recbind(BindingAnd(Binding1:K, Binding2:K)) => recbind(Binding1) ~> recbind(Binding2) ...</k>

    rule
        <k> assign(BindingAnd(Binding1:K, Binding2:K)) => assign(Binding1) ~> assign(Binding2) ...</k>

    rule
        <k> recbind(BindingEquality(PatternIdentifier(X:Id), _)) => . ...</k>
        <env> Env:Map => Env[X <- Location(N)] </env>
        <nextLocation> N:Int => N +Int 1 </nextLocation>

    rule
        <k> assign(BindingEquality(PatternIdentifier(X:Id), V:KResult)) => .K ...</k>
        <env>... X |-> L:Location ...</env>
        <store>... .Map => L |-> V ...</store>


 //   rule type T:TypeDef Ts:TypeDefList   =>  assignType(T) ~>  assignTypes(Ts)
  //  rule assignTypes(.TypeDefList) => . 
  //  rule assignTypes(T:TypeDef Ts:TypeDefList) => assignType(T) ~> assignTypes(Ts)

  //  rule 

endmodule

module OCAML-FUNCTIONS
    imports SUBSTITUTION
    imports OCAML-INCLUDE

    rule
        <k> ExId(UId:UId) => UId ...</k>

    //context apply(UId:UId, _:KList,, HOLE,, _:KList) [superheat]

    rule apply(UId:UId, VS:ElemList) => cons(UId, VS)

    syntax KResult ::= "closure" "(" Map "," K ")"
    syntax KItem ::= "reduceClosure" "(" Map "," K ")"

    //context apply(closure(_, _), _:KList,, HOLE,, _:KList)

   rule
        <k> ExFun(MC:K) => closure(Env, MC) ...</k>
        <env> Env:Map </env> 

   //rule <k> ExFun() 



    rule
        <k> apply(closure(Env':Map, MC:K), V:KResult) => ExMat(V, MC) ~> env(Env) ...</k>
        <env> Env => Env' </env>

    rule closure(_, K:KResult) => K


syntax KItem ::= matchLabel(K, K, K) 
                | "matched" "(" K ")"
    
  //  rule <k> labelPattern()

    rule <k> apply(closure(Env':Map, Matching:K), ExprLabelId(L:Id, C:KResult)) => matchLabel(Matching, L, C) 
    ~> closure(Env':Map /*+ MapItem(L |-> C)*/, Matching) ~> env(Env) ... </k>
    <env> Env => Env' </env>

    rule matchLabel(McArr(labelPattern(L:Id, false, Pattern:K, Type:K, Default:K), S:K , E1:K), L, E2:K) => matched(McArr(labelPattern(L, true, Pattern, Type, Default), S, E1))
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

    rule
        <k> apply(closure(Env':Map, MC:K), V:KResult, Args:ElemList) => apply(ExMat(V, MC), Args) ~> env(Env) ...</k>
        <env> Env => Env' </env>



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
        <k> ExAcc(recordEntry(N:Int), ExId(X:Id)) => V ...</k>
        <recordId> N </recordId>
        <fields>... X |-> V:KResult ...</fields>

    context ExAss(ExAcc(HOLE, _), _)

    rule
        <k> ExAss(ExAcc(recordEntry(N:Int), ExId(X:Id)), V:KResult) => unit ...</k>
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



    rule PatternInteger(I:Int) <- I => .K [anywhere]


    rule
        <patterns> (PatternIdentifier(X:Id) <- K:K) => .K ...</patterns>
        <subst>... .Map => X |-> K ...</subst>

    rule 'wildcard(.KList) <- K:K => .K [anywhere] //wildcard. 

//    rule PatternIdentifier(UId:UId) <- UId => .K [anywhere]

   // rule PatternIdentifier(IdUid("()")) <- unit => .K [anywhere]

    rule PaTup(Pat:K) <- ExTup(Exp:K) => Pat <- Exp [anywhere]


    rule PaCom(Pat1:K, Pat2:K) <- ExCom(Exp1:K, Exp2:K) =>
               (Pat1 <- Exp1)
               ~> (Pat2 <- Exp2) [anywhere]

    rule ((PaApp(Pat1:K, Pat2:K) => flattenApp(PaApp(Pat1, Pat2), .ElemList)) <- _)
         [anywhere]

    rule apply(Pat:K, Pats:ElemList) <- cons(UId:UId, Args:ElemList)
            => (Pat <- UId) ~> zip<-(Pats, Args)
         [anywhere]

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
    rule matches ExCom(_, _) PaCom(_, _) => true
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

    rule
        <k> matching => assigning ~> K ~> env(Env) ...</k>
        <env> Env:Map </env>
        <assign> _ => Subst </assign>
        <matchK> match-success(K:K, Subst:Map) => . </matchK>

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

    rule
        <k> V:KResult ~> (env(Env:Map) => .K) ...</k>
        <env> _ => Env </env>

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
