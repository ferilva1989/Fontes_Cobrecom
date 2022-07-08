#include 'protheus.ch'
user function cbcGetTes(cTpOp,cFilter,cFor,cLoja,cProd)
    local cTes      := ''
    local oTes      := ctrlTesIntel():newctrlTesIntel()
    default cTpOp   := "51"
    default cFor    := ""
    default cLoja   := ""
    default cFilter := "3"
    cTes := oTes:findTes(1, cFilter,cTpOp,cFor ,cLoja ,'F', cProd)
    FreeObj(oTes)
return cTes

user function cbcDefTes(nOpr, cFilter, cTpOper, cTipo, cCliFor, cLoja, cProd)
    local aArea     := getArea()
    local cTes      := ""
    local cTpCliFor := ""
    local oTes      := ctrlTesIntel():newctrlTesIntel()
    default nOpr    := 1
    default cTpOper := "51"
    default cTipo   := "N"
    default cCliFor := ""
    default cLoja   := ""
    default cProd   := ""
    default cUfOrig := ""
    default cFilter := "3"

    cTpCliFor := If(cTipo$"DB","C","F")
    cTes := oTes:findTes(nOpr, cFilter,cTpOper, cCliFor, cLoja, cTpCliFor, AllTrim(cProd))
    FreeObj(oTes)
    
    if empty(cTes)
        cTes := MaTesInt(nOpr,cTpOper,cCliFor,cLoja,cTpCliFor,cProd,iif(1, "D1_TES", "C6_TES"))
    endif

    RestArea(aArea)
return(cTes)


/*
    GATILHOS NOTA ENTRADA SD1
*/
/* Trigger D1_OPER -> D1_TES 001 */
/* Trigger D1_CLASFIS -> D1_TES 001  */
user function zTrgrOpTes()
    local aArea    	:= GetArea()
    local aAreaSD1	:= SD1->(getArea())
    local aAreaSX3	:= SX3->(GetArea())
    local cRet      := ""
    local lNewWay   := GetNewPar('ZZ_MTSTRG', .T.)
    local cTpOp     := ""
    local cCodigo   := ""
    local nX        := 0
    local cProg		:= "MT100"
    local nPosCpo   := 0
    local nPosCfo   := 0
    local cTabela   := ""

    if lNewWay
        cCodigo         := gf('D1_COD')
        cTpOp           := gf('D1_OPER')
        M->D1_CLASFIS   := gf('D1_CLASFIS')
        if !empty(cTpOp) .And. (len(alltrim(M->D1_CLASFIS)) == TamSx3('D1_CLASFIS')[1])
            cRet := u_cbcGetTes(cTpOp,'2',cA100For,cLoja,cCodigo)
        endif
    else
        //cRet := MaTesInt(1,M->D1_OPER,cA100For,cLoja,If(cTipo$"DB","C","F"),M->D1_COD,"D1_TES",,cUfOrig)
        for nX := 1 to len(aHeader)
            &('M->' + AllTrim(aHeader[nX, 02]) + ' := aCols[n][nX]')
        next nX
        cRet := U_cbcDefTes(1,'2',M->D1_OPER, cTipo, cA100For, cLoja, M->D1_COD)
        If ValType(aHeader) == "A"
            nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_TES")})
            If nPosCpo > 0
                dbSelectArea("SX3")
                dbSetOrder(2)
                MsSeek(aHeader[nPosCpo,2])
                cTabela := SX3->X3_ARQUIVO
                RestArea(aAreaSX3)
            EndIf
        EndIf
        If nPosCpo > 0 .And. !Empty(cRet) .And. Type('aCols') <> "U"
            aCols[n][nPosCpo] := cRet
            nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
            If nPosCfo > 0
                aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
            EndIf
            If MaFisFound("IT",N)
                MaFisAlt("IT_TES",cRet,n)
                MaFisRef("IT_TES",cProg,cRet)
            EndIf
        EndIf
    endif
    RestArea(aAreaSX3)
    RestArea(aAreaSD1)
    RestArea(aArea)
return cRet

/* Trigger D1_TES -> D1_CLASFIS 001*/
user function zTrgTesClFis()
    local cRet := "" 
    If SF4->(DbSeek( xFilial('SF4') + M->(D1_TES) ))
        cRet := SubStr(M->D1_CLASFIS,1,1)+SF4->F4_SITTRIB
    endif
return cRet


/* Trigger D1_COD -> D1_CLASFIS */
user function zTrgCodClFis()
    local cRet := "" 
    local lNewWay := GetNewPar('ZZ_MTSTRG', .T.)
    if lNewWay
        cRet            := ""
        M->(D1_OPER)    := ""
        trg('D1_OPER')
        M->(D1_TES)     := ""
        trg('D1_TES')
    else 
        If SF4->(DbSeek( xFilial("SF4") + SB1->(B1_TE) ))
            cRet := Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
        endif
    endif
return cRet


user function zVldClFis()
    local lRet      := .T.
    local aArea     := getArea()
    local aAreaSF1  := getArea()
    if INCLUI
        lRet := !FwIsInCallStack('COMCOLGER')
    elseif ALTERA
        lRet := !(Alltrim(SF1->(F1_ORIGEM)) == 'COMXCOL')
    endif
    restArea(aAreaSF1)
    restArea(aArea)
return lRet



/*Funções statics*/
static function trg(cField)
    if ExistTrigger(cField) 
        RunTrigger(2,n,nil,,cField)
    endif
return nil

static function gf(cFld)
return aCols[n][aScan(aHeader,{|x|trim(x[2])==cFld})]



/*TEST ZONE*/
user function seTteGcbc()
    MsgInfo(U_cbcGetTes("51","000102","01","MC15000055"),'12-IPI') //435
    MsgInfo(U_cbcGetTes("51","V00616","01","MC15000044"),'10-IPI') //435
    MsgInfo(U_cbcGetTes("51","V00AHF","01","MC15000059"),'0-IPI')  //434
    MsgInfo(U_cbcGetTes("51","000048","01","MC15000077"),'0-IPI')  //434
return nil
