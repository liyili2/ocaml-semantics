module OCAML-ABSTRACT-SYNTAX
imports  OCAML-SYNTAX
    syntax O ::= Location(K, K) // LocationInfo, K
    syntax O ::= LocationInfo(Int, Int) // start, stop

    syntax LId ::= IdLid(K)
    syntax UId ::= IdUid(String)

    syntax Id ::= LId | UId
    syntax O ::= Id

    syntax O ::= PatternIdentifier(K)
    syntax O ::= PatternInteger(Int)
    syntax O ::= "Wildcard"
    syntax O ::= PaAli(K, K)
    syntax O ::= PaTyc(K, K)
    syntax O ::= PaTup(K)
    syntax O ::= PaCom(K, K)
    syntax O ::= PaOrp(K, K)
    syntax O ::= PaApp(K, K)
    syntax O ::= PatternLabel(Id)
    syntax O ::= PatternOptionalLabel(Id)
    syntax O ::= PatternConst(K)
    syntax O ::= PatternDoubleChar(K, K)
    syntax O ::= PatternLazy(K)
    syntax O ::= PatternTag(K, K)
    syntax O ::= PaConstType(K)
    syntax O ::= PaList(K, K)
    syntax O ::= PaTuple(K, K)
    syntax O ::= PaRecord(K)
    syntax O ::= FieldPattern(K, K)

    syntax O ::= McOr(K, K)
    syntax O ::= McArr(K, K, K) [strict(1)]

    syntax O ::= BinaryAnd(K,K) [seqstrict]
    syntax O ::= BinaryOr(K,K) [seqstrict]

    syntax O ::= BindingAnd(K, K) [strict]
    syntax O ::= BindingEquality(K, K) // pat = v

    syntax O ::= RbEq(K, K) [strict(2), hybrid] // x = v
    syntax O ::= RbSem(K, K) [strict, superheat, hybrid]

    syntax O ::= "ExNil"
    syntax O ::= ExId(Id) // id
    syntax O ::= ExprLabelId(Id, K) [strict(2)] // name , value
    syntax O ::= ExprOptLabelId(Id, K) [strict(2)]// name , value
    syntax O ::= ExBool(Bool)
    syntax O ::= ExInt(Int)
    syntax O ::= ExFloat(Float)
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

    syntax O ::= ExChar(String)
    syntax O ::= ExStr(String)
    syntax UId ::= ConsUId(K, K)
    syntax LId ::= ConsLId(K, K)
    syntax O ::= "ExNilList"
    syntax O ::= "ExNilArray"
    syntax O ::= ExTypeVal(String)

    syntax O ::= StExp(K) // expr
    syntax O ::= StSem(K, K) // st1 ;; st2
    syntax O ::= StExc(K, K) // exception
    syntax KItem ::= K "<-" K

    //type constructs
    syntax O ::= TyId(K)
    syntax O ::= TyConstr(K)
    syntax O ::= TyWithArg(K, K)//type typeConstr
    syntax O ::= TyList(K)//type typeConstr
    syntax O ::= TyPair(K, K)//type typeConstr
    syntax O ::= TyMethods(K, Bool)//typelist, hasExtention? 
    syntax O ::= TyFieldType(K, K)//Field name, type
    syntax O ::= TyFun(K, K, K)//label, type, type
    syntax O ::= TyQuestionMark(K)//labelname
    syntax O ::= TyTilter(K)//labelname
    syntax O ::= TyWithName(K, K)//type, typename 
    syntax O ::= TyListCons(K, K)
    syntax O ::= TySingleMethod(K, K)//name, polytype
    syntax O ::= TyMethodCons(K, K)
    syntax O ::= TyQuantifier(K, K)

    syntax AllOps ::= Unit| ConsOp | ImportantOps 

    // option types are sometimes used in the AST
    // TODO maybe we should fix this?
    syntax O ::= "none"

    syntax O ::= labelPattern(Id, Bool, K, K, K) //name, initial yet, pattern, type, default value.

    syntax ListFactor ::= funFactor(O,O)
    syntax FunList ::= List{ListFactor,","}
    syntax O ::= wholeFun(FunList)

    syntax Element ::= val(K) [strict]
    syntax ElementResult ::= valValue(K)
    syntax Element ::= ElementResult
    syntax KResult ::= ElementResult
    rule val(K:KResult) => K [structural]

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
