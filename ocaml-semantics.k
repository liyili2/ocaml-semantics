requires "ocaml-syntax.k"
requires "ocaml-abstract-syntax.k"

module OCAML-SYNTAX-EXTRAS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX

    syntax KResult ::= Int | Bool | Id

    syntax KItem
      ::= "initEnv"
        | "binding"
        | "matching"
        | "assigning"
        | "debug"


    syntax Loc ::= loc(Int)
    syntax KResult ::= Loc

    syntax KResult ::= cons(K, ElemList)

    syntax KItem ::= env(Map)



endmodule

module OCAML-TRANS
    imports OCAML-SYNTAX
    imports OCAML-ABSTRACT-SYNTAX
    
    syntax KItem ::= translation(ModuleItemListFactor)   [function] 
    syntax KItem ::= translationParam(Parameter) [function] 
    syntax KItem ::= translationLetBindings(LetBindingList) [function]
    syntax KItem ::= translationLetBinding(LetBinding) [function]
    syntax KItem ::= translationLetRecBindings(LetBindingList) [function]
    syntax KItem ::= translationToBindingForm(K) [function]
//    syntax KItem ::= translation(Expr)  [function]
//    syntax KItem ::= translations(Exprs)  [function]
 //   syntax KItem ::= translationTuples(Tuples)  [function]
//    syntax KItem ::= translationTupleNext(TupleNext)  [function]
//    syntax KItem ::= translation(BExp) [function]

// rule translation(K:K) => ExInt(0) [owise]

 syntax KItem ::= "assign" "(" K ")"

 rule translation(I:IntegerLiteral) => ExInt(String2Int(#tokenToString(I)))
  rule translation(F:FloatLiteral) => ExFloat(String2Float(#tokenToString(F)))
   rule translation(B:Bool) => ExBool(B)
// rule translation(false) => ExInt(0)
// rule translation(true) => ExInt(1) 
 rule translation(I:LowerCaseName) => ExId(String2Id(#tokenToString(I)))
 rule translation((O:ImportantOps)) => ExId(IdLid(O))

//Binary Integer Operator Expressions
 rule translation('mathTimesOp(E1:Expr,, Bin:MathOp ,, E2:Expr)) => ExApp(ExApp(ExId(IdLid(Bin)), translation(E1)),translation(E2)) 
 rule translation('mathPlusOp(E1:Expr,, Bin:AllPlusAndMinus ,, E2:Expr)) => ExApp(ExApp(ExId(IdLid(Bin)), translation(E1)),translation(E2)) 
 rule translation('unaryOp(Un:Minus ,, E1:Expr)) => ExApp(ExApp(ExId(IdLid(Un)), ExInt(0)),translation(E1)) 
 rule translation('unaryOp(Un:MinusDot ,, E1:Expr)) => ExApp(ExApp(ExId(IdLid(Un)), ExFloat(Int2Float(0,53,11))),translation(E1)) 
 //      when E1 =/=KList .KList

// rule translation(E1:Exp - E2:Exp) => ExApp(ExApp(ExId(IdLid("-")), translation(E1)),translation(E2))
// rule translation(E1:Exp * E2:Exp) => ExApp(ExApp(ExId(IdLid("*")), translation(E1)),translation(E2))
// rule translation(E1:Exp / E2:Exp) => ExApp(ExApp(ExId(IdLid("/")), translation(E1)),translation(E2))

// Binary boolean Operator Expressions
 rule translation('binaryOrOp (B1:Expr,, Or:BinaryOr ,, B2:Expr)) => ExIfe(translation(B1), ExBool(true), translation(B2))
 rule translation('binaryAndOp (B1:Expr,, Or:BinaryAnd ,, B2:Expr)) => BiAnd(translation(B1), translation(B2)) //to be desugared into ExIfe
rule translation('unaryOp(Un:Not ,, E1:Expr)) => ExApp(ExId(IdLid(Un)),translation(E1))


 rule translation(E1:Expr E2:Expr) => ExApp(translation(E1),translation(E2))
 rule translation(fun X1:Parameter (X2:Parameter Xs:ParameterList) -> E:Expr)
           => translation(fun X1 .ParameterList -> (fun X2:Parameter Xs:ParameterList -> E:Expr))
 rule translation(fun X1:Parameter .ParameterList -> E:Expr)
            => ExFun(McArr(translationParam(X1),ExNil,translation(E))) 
    //       => wholeFun(funFactor(translationParam(X1),translation(E)))
// rule translation(function P:PatternMatching) => wholeFun(translation(P))
 //rule translation(fun X:Parameter .ParameterList -> E:Expr)  => ExFun(McArr(PaId(X),ExNil,translation(E))) 
 //rule translation(fun X1:Parameter X2:Parameter .ParameterList -> E:Expr)  => ExFun(McArr(PaId(X1),ExNil,translation(fun X2 Xs -> E))) 
 rule translation(E1:Expr ; E2:Expr)  => ExSem(translation(E1),translation(E2))
 rule translation(if E1:Expr then E2:Expr else E3:Expr)
                      => ExIfe(translation(E1),translation(E2),translation(E3))
 rule translation(let A:LetBindingList in E:Expr) => ExLet(translationLetBindings(A),translation(E))
 //rule translationLetBinding(...) => translationLetBindings BiEq(PaId(String2Id(#tokenToString(X))), translation(fun P Pl  -> E1))
 rule translationLetBindings(L:LetBinding) => translationLetBinding(L)
 rule translationLetBindings(L1:LetBinding and L2:LetBindingList)
                               => BiAnd(translationLetBinding(L1),translationLetBindings(L2))

/*
 rule translation(let 'patternexpr(X:Pattern,, E1:Expr) and Bl:LetBindingList in E3:Expr) => translation(let Bl:LetBindingList in ((fun X .ParameterList -> E3) E1) ) //what if variable occurs twice?
 rule translation(let 'patternexpr(X:Pattern,, E1:Expr) in E3:Expr) => translation(((fun X .ParameterList -> E3) E1))  //use the ExFun directly. 
 rule translation(let 'letfunexpr(X:ValueName,, P:Parameter Pl:ParameterList,, E1:Expr) and Bl:LetBindingList in E2:Expr) => 
 assign(BiEq(PaId(String2Id(#tokenToString(X))), translation(fun P Pl  -> E1))) ~> translation(let Bl:LetBindingList in E2:Expr) 
*/


//    translation(let X P = E1)
//                      => ExLet(translationLetBindings(Bl),translation(E3))
 rule translation(let rec Bl:LetBindingList in E3:Expr)
                      => ExRec(translationLetRecBindings(Bl),translation(E3))
// rule translation(match E1 with P:PatternMatching) TODO FIX ExMat, adapt to multiple arguments
  //                    => ExMat(translation(E3),McArr(translation(E1), ExNil, translation(E2)))
// rule translation(try E1 with E2 -> E3)
  //                    => ExTry(translation(E3),McArr(translation(E1), ExNil, translation(E2)))
// rule translation('ocamlList(E:Exps)) => translations(E)
// rule translations(.Exps) => ExNil   QUERY LIYI
// rule translation(E:Expr; Es:ExprList) => 'ExCom(translation(E),, translation(Es))
// rule translation('tuple(E:Tuples)) => translationTuples(E)
 rule translation('binarySepOp(E1:Expr,, S:SepOp ,, E2:Expr)) => 'ExTup(translation(E1),, translation(E2))
// rule translationTupleNext(E:Exp) => translation(E)
// rule translationTupleNext(E:Exp , T:TupleNext) => 'ExTup(translation(E),, translationTupleNext(T))

//rule translation((E:Expr))=> translation(E)

rule ExBool(B:Bool) => B
rule valValue(B:Bool) => B


rule BiAnd(true, true) => ExBool(true) 
rule BiAnd(false, _) => ExBool(false)
rule BiAnd(true, false) => ExBool(false)

rule translationParam(X:ValueName) => PaId(String2Id(#tokenToString(X))) 
//rule translationParam(X:ValueName) => PaId(X) 

//rule String2Int(#tokenToString(V:K)) => valValue(V) 

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
            <nextLoc> 0 </nextLoc>
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
        <env>... LId |-> L:Loc ...</env>
        <store>... L |-> K:K ...</store>



    syntax KItem ::= "group" "(" K "," K ")"
    syntax KItem ::= "letbody" "(" K ")"

    // TODO this can probably be better
    rule
        <k> ExLet(Binding:K, Exp:K)
            => group(ExId(IdUid("()")), PaId(IdUid("()")))
            ~> Binding ~> letbody(Exp) ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> group(_, _) ~> (BiAnd(Binding1:K, Binding2:K) => Binding1 ~> Binding2) ...</k>

    rule
        <k> group(Exp1:K, Pat1:K) ~> BiEq(Pat2:K, Exp2:K)
            => group(ExCom(Exp1, Exp2), PaCom(Pat1, Pat2))
        ...</k>

    rule
        <k> group(Exp1:K, Pat:K) ~> letbody(Exp2:K)
            => ExMat(Exp1, McArr(Pat, ExNil, Exp2))
        ...</k>

    syntax KItem ::= "recbind" "(" K ")"
   
    syntax KItem ::= "assignType" "(" K ")"
    syntax KItem ::= "assignTypes" "(" K ")"


    context assign(BiEq(_, HOLE))

    rule
        <k> ExLetRec(Binding:K, Exp:K) => recbind(Binding) ~> assign(Binding) ~> Exp ~> env(Env) ...</k>
        <env> Env:Map </env>

    rule
        <k> recbind(BiAnd(Binding1:K, Binding2:K)) => recbind(Binding1) ~> recbind(Binding2) ...</k>

    rule
        <k> assign(BiAnd(Binding1:K, Binding2:K)) => assign(Binding1) ~> assign(Binding2) ...</k>

    rule
        <k> recbind(BiEq(PaId(X:Id), _)) => . ...</k>
        <env> Env:Map => Env[X <- loc(N)] </env>
        <nextLoc> N:Int => N +Int 1 </nextLoc>

    rule
        <k> assign(BiEq(PaId(X:Id), V:KResult)) => .K ...</k>
        <env>... X |-> L:Loc ...</env>
        <store>... .Map => L |-> V ...</store>


 //   rule type T:TypeDef Ts:TypeDefList   =>  assignType(T) ~>  assignTypes(Ts)
  //  rule assignTypes(.TypeDefList) => . 
  //  rule assignTypes(T:TypeDef Ts:TypeDefList) => assignType(T) ~> assignTypes(Ts)

  //  rule 

endmodule

module OCAML-FUNCTIONS
    imports OCAML-INCLUDE

    rule
        <k> ExId(UId:UId) => UId ...</k>

    //context apply(UId:UId, _:KList,, HOLE,, _:KList) [superheat]

    rule apply(UId:UId, VS:ElemList) => cons(UId, VS)

    syntax KResult ::= "closure" "(" Map "," K ")"

    //context apply(closure(_, _), _:KList,, HOLE,, _:KList)

    rule
        <k> ExFun(MC:K) => closure(Env, MC) ...</k>
        <env> Env:Map </env>



    rule
        <k> apply(closure(Env':Map, MC:K), V:KResult) => ExMat(V, MC) ~> env(Env) ...</k>
        <env> Env => Env' </env>

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
        <k> '%raise(V:KResult) ~> _ => ExMat(V, McOr(MC, McArr(PaAny, ExNil, 'primRaise(V)))) ~> K </k>
        <xstack> xex(K:K, MC:K, Env:Map) => . ...</xstack>
        <env> _ => Env </env>

endmodule

module OCAML-RECORDS
    imports OCAML-INCLUDE
    imports OCAML-UNIT

    syntax KResult ::= "recordEntry" "(" Int ")"

    rule
        <k> ExRec(K:K, _) => recordEntry(N) ...</k>
        <nextLoc> N:Int => N +Int 1 </nextLoc>
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

    rule PaInt(I:Int) <- I => .K [anywhere]


    rule
        <patterns> (PaId(X:Id) <- K:K) => .K ...</patterns>
        <subst>... .Map => X |-> K ...</subst>

    rule PaAny <- K:K => .K [anywhere] //wildcard. 

//    rule PaId(UId:UId) <- UId => .K [anywhere]

   // rule PaId(IdUid("()")) <- unit => .K [anywhere]

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
        <patterns> PaAli(Pat:K, PaId(X:Id)) <- Exp:K => Pat <- Exp ...</patterns>
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
    rule matches _ PaId(LId:LId) => true
    rule matches UId:UId PaId(UId) => true
    rule matches unit PaId(IdUid("()")) => true
    rule matches _ PaAny => true
    rule matches _ PaAli(_, _) => true
    rule matches _ PaTyc(_, _) => true
    rule matches _ PaOrp(_, _) => true
    rule matches ExTup(_) PaTup(_) => true
    rule matches ExCom(_, _) PaCom(_, _) => true
    rule matches I:Int PaInt(I) => true
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
        <env> Env:Map => Env[X <- loc(N)] </env>
        <store>... .Map => loc(N) |-> K ...</store>
        <nextLoc> N:Int => N +Int 1 </nextLoc>

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
