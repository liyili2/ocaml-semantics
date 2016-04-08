module OCAML-ABSTRACT-SYNTAX
imports  OCAML-SYNTAX
    syntax KItem ::= Location(K, K) // LocationInfo, K
    syntax KItem ::= LocationInfo(Int, Int) // start, stop

    syntax LId ::= IdLid(K)
    syntax UId ::= IdUid(K)
    syntax UId ::= ModuleNameList(UId, UId)
    syntax UId ::= ModulePathList(UId, UId)

    syntax Id ::= LId | UId
    syntax KItem ::= Id

    syntax KItem ::= PatternIdentifier(K)
    syntax KItem ::= PatternInteger(Int)
    syntax KItem ::= "Wildcard"
    syntax KItem ::= PaAli(K, K)
    syntax KItem ::= PaTyc(K, K)
    syntax KItem ::= PaTup(K)
    syntax KItem ::= PaCom(K, K)
    syntax KItem ::= PaOrp(K, K)
    syntax KItem ::= PaApp(K, K)
   // syntax KItem ::= PatternLabel(Id)
   // syntax KItem ::= PatternOptionalLabel(Id)
    syntax KItem ::= PatternConst(K)
    syntax KItem ::= PatternDoubleChar(K, K)
    syntax KItem ::= PatternLazy(K)
    syntax KItem ::= PatternTag(K, K)
    syntax KItem ::= PaConstType(K)
    syntax KItem ::= PaList(K, K)
    syntax KItem ::= PaTuple(K, K)
    syntax KItem ::= PaRecord(K)
    syntax KItem ::= FieldPattern(K, K)

    syntax KItem ::= McOr(K, K)
    syntax KItem ::= McArr(K, K, K) [strict(1)]

    syntax KItem ::= BinaryAnd(K,K) [seqstrict]
    syntax KItem ::= BinaryOr(K,K) [seqstrict]

    syntax KItem ::= BindingAnd(K, K) [strict]
    syntax KItem ::= BindingEquality(K, K, K, K) // pat, type, supertype, v

    syntax KItem ::= RbEq(K, K) [strict(2), hybrid] // x = v
    syntax KItem ::= RbSem(K, K) [strict, superheat, hybrid]


    syntax KItem ::= ExApp(K, K) // e1 e2
    syntax KItem ::= ExAppList(K, K, K, K) // (e, arglist, tildas, ?s, normals)
    //syntax KItem ::= ExAppTildas(K, K) // (e,tildas)
    syntax KItem ::= ExTup(K) [strict, hybrid]
    syntax KItem ::= ExCom(K, K) [strict, hybrid]
    syntax KItem ::= ExMat(K, K) [strict(1)] // value, match-case
    syntax KItem ::= ExFun(K) // match-case 
    syntax KItem ::= ExSeq(K) // sequencing?
    syntax KItem ::= ExSem(K, K) [strict(1)] // e1 ; e2
    syntax KItem ::= ExIfe(K, K, K) [strict(1)] // if e1 then e1 else e3
    syntax KItem ::= ExAss(K, K) [strict(2)] // e1 := e2
    syntax KItem ::= ExAcc(K, K) [strict(1)] // e1.e2 (access)
    syntax KItem ::= ExLet(K, K)
    //syntax KItem ::= ExLetRec(K, K)
    syntax KItem ::= ExTry(K, K)
    syntax KItem ::= ExRec(K, K) [strict(1)]
    syntax KItem ::= ExConstr(K) //constructors as expressions.
    syntax KItem ::= ExLazy(K) //lazy type for lazy expr
    syntax KItem ::= ExNew(K)   //create new class

    //constant values.
    syntax KItem ::= "ExNil"
    syntax KItem ::= ExId(K) // id
    syntax KItem ::= ExprLabelId(UId, K) [strict(2)] // name , value 
    syntax KItem ::= ExprOptLabelId(Id, K) [strict(2)]// name , value
    syntax KItem ::= ExBool(Bool)
    syntax KItem ::= ExInt(Int)
    syntax KItem ::= ExFloat(Float)
    syntax KItem ::= ExChar(String)
    syntax KItem ::= ExStr(String)
    syntax UId ::= ConsUId(UId, UId)
    syntax LId ::= ConsLId(K, K)
    syntax KItem ::= "ExNilList"
    syntax KItem ::= "ExNilArray"
    syntax KItem ::= ExTagVal(K, K) //create tag Value type

    syntax KItem ::= StExp(K) // expr
    syntax KItem ::= StSem(K, K) // st1 ;; st2
    syntax KItem ::= StExc(K, K) // exception
    syntax KItem ::= K "<-" K

    //type constructs
    syntax KItem ::= "toUnify"
    syntax SimpleTypeKItem ::= "int" | "float" | "char" | "string"
    syntax KItem ::= SimpleTypeKItem
    syntax KItem ::= TyId(K)
    syntax KItem ::= TyConstr(K)
    syntax KItem ::= TyWithArg(K, K)//type typeConstr
    syntax KItem ::= TyList(K)//type typeConstr
    syntax KItem ::= TyPair(K, K)//type typeConstr
    syntax KItem ::= TyMethods(K, Bool)//typelist, hasExtention? 
    syntax KItem ::= TyFieldType(K, K)//Field name, type
    syntax KItem ::= TyFun(K, K, K)//label, type, type
    syntax KItem ::= TyQuestionMark(K)//labelname
    syntax KItem ::= TyTilda(K)//labelname
    syntax KItem ::= TyWithName(K, K)//type, typename 
    syntax KItem ::= TyListCons(K, K)
    syntax KItem ::= TySingleMethod(K, K)//name, polytype
    syntax KItem ::= TyMethodCons(K, K)
    syntax KItem ::= TyQuantifier(K, K)

    syntax KItem ::= typeInfer(K)
                   | typeInferInExpr(K, K, K)
    syntax KResult ::= resultType(K)
    syntax KItem ::= unifier(K, K)
    syntax KItem ::= unification(K)
    syntax KItem ::= getFirst(List) [function]
    rule getFirst(.List) => ExNil
    rule getFirst(ListItem(unifier(A, B)) L) => A

    syntax AllOps ::= Unit| ConsOp | ImportantOps 

    // option types are sometimes used in the AST
    // TODO maybe we should fix this?
    syntax KItem ::= "none"

    syntax KItem ::= tildaLabelPattern(Id, K, K, K) //name, pattern, type, default value.
    syntax KItem ::= optionalLabelPattern(Id, K, K, K) //name, pattern, type, default value.

    syntax ListFactor ::= funFactor(K, K)
    syntax FunList ::= List{ListFactor,","}
    syntax KItem ::= wholeFun(FunList)

    syntax Element ::= val(K) [strict]
    syntax ElementResult ::= valValue(K)
    syntax Element ::= ElementResult
    syntax KResult ::= ElementResult
    rule val(K:KResult) => K [structural]

    syntax KItem ::= headOfElemList(ElemList)    [function]
    rule headOfElemList(.ElemList) => ExNil
    rule headOfElemList(val(K:K), _:ElemList) => K

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
