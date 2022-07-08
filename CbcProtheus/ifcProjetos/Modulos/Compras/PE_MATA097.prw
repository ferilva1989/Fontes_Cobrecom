#include 'Totvs.ch'

user function MTA097()
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local lRet      := .T.
    local cMsg      := ""

    lRet := u_budgetPCMov(AllTrim(SC7->C7_NUM), @cMsg)
    
    if !lRet
        MsgAlert(cMsg, 'Bloqueio de Validação')
    endif
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(lRet)

user function ztstMata097(nRec)//u_ztstMata097(170)
    u_cbcLibPC(nRec)
return(nil)
