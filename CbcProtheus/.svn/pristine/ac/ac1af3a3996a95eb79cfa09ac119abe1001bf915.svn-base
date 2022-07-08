user function MT260TOK()
    local lRet := .T.
    if !(FwIsAdmin() .or. validAccess())
        if (lRet := vldCodProd(cCodOrig, cCodDest))
           lRet := vldLocaliz(cCodOrig, cLocLzOrig, cCodDest, cLoclzDest)
        endif
    endif
    if lRet
        makeLog(cCodOrig, cLocLzOrig, cCodDest, cLoclzDest)
    endif
return(lRet)

static function vldCodProd(cOri, cDest)
    local lOk := .T.
    if empty(cOri) .or. empty(cDest)
        lOk := .F.
        MsgAlert('Códigos de Origem e Destino devem ser preenchidos!','Código Vazio')
    else
        if !(lOk := (Substr(cOri, 1, 10) == Substr(cDest, 1, 10)))
            MsgAlert('Transferência entre produtos diferentes não são permitidas!','Produtos Diferentes')
        endif
    endif
return(lOk)

static function vldLocaliz(cCodOri, cLocOri, cCodDest, cLocDest)
    local lOk       := .T.
    local aArea     := GetArea()
    local aAreaSb1  := SB1->(GetArea())

    DbSelectArea("SB1")
    if (Posicione("SB1",1,xFilial("SB1")+AllTrim(cCodOri),"B1_LOCALIZ")=="S") .or. (Posicione("SB1",1,xFilial("SB1")+AllTrim(cCodDest),"B1_LOCALIZ")=="S")
       if !(lOk := (AllTrim(cLocOri) == AllTrim(cLocDest)))
            MsgAlert('Troca de acondicionamento deve ser realizada via RETRABALHO!','Troca Acondicionamento')
       endif
    endif
    
    RestArea(aAreaSb1)
    RestArea(aArea)
return(lOk)

static function makeLog(cCodOrig, cLocLzOrig, cCodDest, cLoclzDest)
    local cEmail    := AllTrim(GetNewPar('ZZ_LOGTRFI', 'wfti@cobrecom.com.br'))
    local cLinha    := '<br>'
    local lProd     := (AllTrim(cCodOrig) <> AllTrim(cCodDest))
    local lLocali   := (AllTrim(cLocLzOrig) <> AllTrim(cLoclzDest))
    local cTitulo   := 'Alteração de '
    local cMsgLog   := ''

    if !empty(cCodOrig) .and. !empty(cCodDest)
        if lProd .or. lLocali
            cTitulo += iif(lProd, 'Produto', '')
            cTitulo += iif(lLocali, iif(lProd, ' e', '') + ' Acondicionamento', '')
            cMsgLog += cLinha
            cMsgLog += '[ORIGEM] - Produto: ' + cCodOrig + cLinha
            cMsgLog += '[ORIGEM] - Acondic: ' + cLocLzOrig + cLinha
            cMsgLog += cLinha
            cMsgLog += '[DESTINO] - Produto: ' + cCodDest + cLinha
            cMsgLog += '[DESTINO] - Acondic: ' + cLoclzDest + cLinha
            u_SendMail(cEmail,"[LOG - Transferência Interna] - " + cTitulo, cMsgLog)
        endif
    endif
return(nil)

static function validAccess()
    local oAcl := cbcAcl():newcbcAcl()
    local lVld := .F.
	lVld := oAcl:aclValid('TransferFull')
	FreeObj(oAcl)
return(lVld)
