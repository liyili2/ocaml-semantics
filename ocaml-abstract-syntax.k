module OCAML-ABSTRACT-SYNTAX
imports  OCAML-SYNTAX
    syntax O ::= Loc(K, K) // LocInfo, K
    syntax O ::= LocInfo(Int, Int) // start, stop

    syntax LId ::= IdLid(AllOps)
    syntax UId ::= IdUid(String)

    syntax Id ::= LId | UId
    syntax O ::= Id

    syntax O ::= PaId(Id)
    syntax O ::= PaInt(Int)
    syntax O ::= "PaAny"
    syntax O ::= PaAli(K, K)
    syntax O ::= PaTyc(K, K)
    syntax O ::= PaTup(K)
    syntax O ::= PaCom(K, K)
    syntax O ::= PaOrp(K, K)
    syntax O ::= PaApp(K, K)

    syntax O ::= McOr(K, K)
    syntax O ::= McArr(K, K, K)

    syntax O ::= BiAnd(K, K)
    syntax O ::= BiEq(K, K) // pat = v

    syntax O ::= RbEq(K, K) [strict(2), hybrid] // x = v
    syntax O ::= RbSem(K, K) [strict, superheat, hybrid]

    syntax O ::= "ExNil"
    syntax O ::= ExId(K) // id
    syntax O ::= ExInt(Int)
    syntax O ::= ExApp(K, K) // e1 e2
    syntax O ::= ExTup(K) [strict, hybrid]
    syntax O ::= ExCom(K, K) [strict, hybrid]
    syntax O ::= ExMat(K, K) [strict(1)] // value, match-case
    syntax O ::= ExFun(K) // match-case
    syntax O ::= ExSeq(K) // sequencing?
    syntax O ::= ExSem(K, K) [strict(1)] // e1 ; e2
    syntax O ::= ExIfe(K, K, K) [strict(1)] // if e1 then e1 else e3
    syntax O ::= ExAss(K, K) [strict(2)] // e1 := e2
    syntax O ::= ExAcc(K, K) [strict(1)] // e1.e2 (access)
    syntax O ::= ExLet(K, K)
    syntax O ::= ExLetRec(K, K)
    syntax O ::= ExTry(K, K)
    syntax O ::= ExRec(K, K) [strict(1)]

    syntax O ::= StExp(K) // expr
    syntax O ::= StSem(K, K) // st1 ;; st2
    syntax O ::= StExc(K, K) // exception
    syntax KItem ::= K "<-" K
    syntax O ::= TyId(K)

    syntax AllOps ::= Unit| ConsOp | ImportantOps | LogicShiftOp | ExOp   | MathOp  | CompareOp   | BinaryAnd    | BinaryOr | AssignOp

    // option types are sometimes used in the AST
    // TODO maybe we should fix this?
    syntax O ::= "None"

    syntax ListFactor ::= funFactor(O,O)
    syntax FunList ::= List{ListFactor,","}
    syntax O ::= wholeFun(FunList)

    syntax Element ::= val(K) [strict]
    syntax ElementResult ::= valValue(K)
    syntax Element ::= ElementResult
    syntax KResult ::= ElementResult
    rule val(K:KResult) => valValue(K) [structural]

    syntax ElemList ::= List{Element,","} [strict]
    syntax Int ::= lengthOfList(ElemList) [function]
    rule lengthOfList(.ElemList) => 0
    rule lengthOfList(val(K:K),L:ElemList) => 1 +Int lengthOfList(L)

    syntax ElemList ::= combineElemList(ElemList, ElemList) [function]

    rule combineElemList(.ElemList,Bs:ElemList) => Bs
    rule combineElemList((A:Element,As:ElemList),Bs:ElemList) => A,combineElemList(As,Bs)

    syntax KList ::= toKList(ElemList) [function]
    rule toKList(.ElemList) => .KList
    rule toKList(valValue(V:K),Vl:ElemList) => V,, toKList(Vl)
    rule toKList(val(V:K),Vl:ElemList) => V,, toKList(Vl)

endmodule
