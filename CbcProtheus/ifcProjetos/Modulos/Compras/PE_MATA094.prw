#include 'Totvs.ch'

user function MT094FIL()
    local cFiltro   := nil
    if u_cbcUseBudget()
        cFiltro := 'CR_ACLASSI <> "S"'
    endif
return(cFiltro)

user function MTALCALT()
    local aArea     := getArea()
    local aAreaSC7  := SC7->(GetArea())
    local aAreaSCR  := SCR->(GetArea())
    Local oStatic    := IfcXFun():newIfcXFun()

    if u_cbcUseBudget()
        DbSelectArea("SC7")
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('pontoEntrada', 'qryRec7', AllTrim(SCR->CR_FILIAL), AllTrim(SCR->CR_NUM)))
        oSql:GoTop()
        while oSql:notIsEof()
            SC7->(DbGoTo(oSql:getValue('REC')))
            if (lBloq := empty(u_trgNatureza(SC7->C7_PRODUTO, SC7->C7_FORNECE, SC7->C7_LOJA)))
                EXIT
            endif
            oSql:skip()
        enddo
        oSql:close()
        Freeobj(oSql)
        if lBloq
            RecLock("SCR", .F.)
                SCR->CR_ACLASSI := 'S'
            SCR->(MsUnlock())
        endif
    endif
    restArea(aAreaSCR)
    restArea(aAreaSC7)
    restArea(aArea)
return(nil)

user function MATA094()
    local aParam        := PARAMIXB
    local xRet          := .T.
    local oObj          := ""
    local cIdPonto      := ""
    local cIdModel      := ""
    local lIsGrid       := .F.
    local cMsg          := ""
    local nOp

    if (aParam <> NIL)
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)

        nOp := oObj:GetOperation() // PEGA A OPERAÇÃO

        if (cIdPonto == "FORMPOS")
            if FWIsInCallStack("U_cbcLibPC")
                xRet := u_budgetPCMov(AllTrim(SCR->CR_NUM), @cMsg)
                oObj:oFormModel:SetErrorMessage('MATA094', 'C7_NATUREZ' , 'MATA094' , 'C7_NATUREZ' , 'Erro', cMsg,'') 
            endif
        endif
    endif
return(xRet)
