#include "totvs.ch"

user function cbcIncCompras(aSolic, cUsuar)
    local aArea    	    := GetArea()
    local aAreaSC1 	    := SC1->(GetArea())
    local cDoc          := GetSXENum("SC1","C1_NUM")
    local cErrMsg       := ""
    local aRet          := {.F., 'Sem Itens'}
    local aErrPCAuto    := {}
    local aCabSC        := {}
    local aItensSC      := {}
    local aLinhaC1      := {}
    local nX            := 0
    private lMsErroAuto := .F.
    default aSolic      := {}
    default cUsuar      := "Administrador"
    
    if !empty(aSolic)
        SC1->(dbSetOrder(1))
        while SC1->(dbSeek(xFilial("SC1")+cDoc))
            ConfirmSX8()
            cDoc := GetSXENum("SC1","C1_NUM")
        endDo

        aadd(aCabSC,{"C1_NUM" ,cDoc})
        aadd(aCabSC,{"C1_SOLICIT", PadR(cUsuar, TamSX3('C1_SOLICIT')[1])})
        aadd(aCabSC,{"C1_EMISSAO",dDataBase})

        for nX := 1 to len(aSolic)
            aLinhaC1 := {}
            aadd(aLinhaC1,{"C1_ITEM", StrZero(nX,len(SC1->C1_ITEM)), Nil})
            aadd(aLinhaC1,{"C1_PRODUTO", aSolic[nX, 01],Nil})
            aadd(aLinhaC1,{"C1_QUANT" , aSolic[nX, 02], Nil})
            if (len(aSolic[nX]) > 2)
                aadd(aLinhaC1,{"C1_OBS" , AllTrim(aSolic[nX, 03]), Nil})
            endif
            aadd(aItensSC,aLinhaC1)
        next nX

        MSExecAuto({|x,y| Mata110(x,y)},aCabSC,aItensSC)
        If lMsErroAuto
            aErrPCAuto := GETAUTOGRLOG()
            For nX := 1 to Len(aErrPCAuto)
                cErrMsg += aErrPCAuto[nX]
            Next nX
            aRet := {.F., cErrMsg}
        else
            aRet := {.T., 'Concluido com Sucesso!'}
        EndIf
    endif
    RestArea(aAreaSC1)
    RestArea(aArea)
return(aRet)
