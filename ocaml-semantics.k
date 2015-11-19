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

    syntax KItem ::= translation(Exp)  [function]
    syntax KItem ::= translation(BExp) [function]

 rule translation(I:Int) => ExInt(I)
// rule translation(false) => ExInt(0)
// rule translation(true) => ExInt(1) 


//Binary Integer Operator Expressions
 rule translation(E1:AExp + E2:AExp) => ExApp(ExApp(ExId(IdLid("+")), translation(E1)),translation(E2))
 rule translation(E1:AExp - E2:AExp) => ExApp(ExApp(ExId(IdLid("-")), translation(E1)),translation(E2))
 rule translation(E1:AExp * E2:AExp) => ExApp(ExApp(ExId(IdLid("*")), translation(E1)),translation(E2))
 rule translation(E1:AExp / E2:AExp) => ExApp(ExApp(ExId(IdLid("/")), translation(E1)),translation(E2))

// Binary boolean Operator Expressions
 rule translation(B1:BExp || B2:BExp) => McOr(translation(B1), translation(B2))
 rule translation(B1:BExp && B2:BExp) => BiAnd(translation(B1), translation(B2))


 rule translation(E1:Exp E2:Exp) => ExApp(translation(E1),translation(E2))
 rule translation(fun X -> E)  => ExFun(fun X -> E) 

endmodule


module OCAML-CONFIGURATION
    imports OCAML-SYNTAX
    imports OCAML-TRANS
    imports OCAML-ABSTRACT-SYNTAX
    imports OCAML-SYNTAX-EXTRAS

    configuration
        <T>
            <k color="LightGreen"> initEnv ~> translation($PGM:Exp) </k>
            <env color="LightSkyBlue"> .Map </env>
            <store color="LightSteelBlue"> .Map </store>
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

    rule ExApp(K1:K, K2:K) => apply(K1,K2)
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
        <k> ExId(LId:LId) => K ...</k>
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
    syntax KItem ::= "assign" "(" K ")"

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
        <k> apply(closure(Env':Map, MC:K), valValue(V:KResult)) => ExMat(V, MC) ~> env(Env) ...</k>
        <env> Env => Env' </env>

    rule
        <k> apply(closure(Env':Map, MC:K), valValue(V:KResult), Args:ElemList) => apply(ExMat(V, MC), Args) ~> env(Env) ...</k>
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

    rule
        <k> '%ref(V:KResult) => ExRec(RbEq(IdLid("val"), V), ExNil) ...</k>

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

    syntax KItem ::= K "<-" K

    syntax KItem ::= "pattern-failure" "(" K "," K ")"

    rule PaInt(I:Int) <- I => .K [anywhere]


    rule
        <patterns> (PaId(X:LId) <- K:K) => .K ...</patterns>
        <subst>... .Map => X |-> K ...</subst>

    rule PaAny <- K:K => .K [anywhere]

    rule PaId(UId:UId) <- UId => .K [anywhere]

    rule PaId(IdUid("()")) <- unit => .K [anywhere]

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
        <patterns> (Pat <- K) ~> Rest:K => pattern-failure(Pat, K) </patterns>
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
        <assign> . => Subst </assign>
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
            Rest:Bag) => .
        </patternAttempts>
        <expr> Exp:K => . </expr>

    rule
        <matchK> matching => match-failure </matchK>
        <cases> . </cases>

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
        <k> StExc(_, _) => . ...</k>

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
        initEnv => preassign( IdLid("+") |-> external(%addint, 2)
            IdLid("-") |-> external(%subint, 2)
            IdLid("*") |-> external(%mulint, 2)
            IdLid("/") |-> external(%divint, 2)
            IdLid("mod") |-> external(%modint, 2)
            IdLid("~-") |-> external(%negint, 1))
         ~> preassign(
            IdLid("not") |-> external(%boolnot, 1)
            IdLid("&&") |-> external(%sequand, 2)
            IdLid("||") |-> external(%sequor, 2)
            IdLid("raise") |-> external(%raise, 1)
            IdLid("ref") |-> external(%ref, 1)
            IdLid("print_int") |-> external(%print-int, 1))

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
