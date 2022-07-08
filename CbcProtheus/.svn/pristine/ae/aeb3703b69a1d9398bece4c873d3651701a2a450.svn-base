#include 'protheus.ch'
#include 'parmtype.ch'

class cbcExpIntegra
    data lOk
    data cMsgErr
    data lShowErr
    data cUrlApi
    data cMnUrlApi
    data aHeader

    method newcbcExpIntegra()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getHeader()
    method getUrl()
    method getMntUrl()
    method genLog()
    method addProd()
    method fullProd()
    method manutProd()
    method addOS()
    method removeOS()
    method addEndereco()
    method addPesagem()
    method doMovimento()
    method GetInvent()
    method chgStsInvent()
    method fromNFe()
    method getEnder()
    method getProd()
    method getEndMovs()
    method getInvAjuste()
    method getSaldoProd()
endClass

method newcbcExpIntegra(lShowErr) class cbcExpIntegra
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::cUrlApi   := AllTrim(GetNewPar("ZZ_EXPDAPI", "http://192.168.1.220:3397"))
    ::cMnUrlApi := Alltrim(GetNewPar("ZZ_MNTAPI", "http://192.168.1.25:3397"))
    ::aHeader   := {}
    aadd(::aHeader, 'Content-Type: application/json')
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcExpIntegra
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcExpIntegra] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcExpIntegra')
            endif
        endif
    endif
return(self)

method isOk() class cbcExpIntegra
return(::lOk)

method getErrMsg() class cbcExpIntegra
return(::cMsgErr)

method showErr() class cbcExpIntegra
return(::lShowErr)

method getHeader() class cbcExpIntegra
return(::aHeader)

method getUrl() class cbcExpIntegra
return(::cUrlApi)

method getMntUrl() class cbcExpIntegra
return(::cMnUrlApi)

method genLog(cTipo, aLog) class cbcExpIntegra
    local oFWMsExcel := nil
    local cSrvPath   := "\ExpIntegra\"
    local cNomArqv   := cSrvPath + 'cbcExpIntegra_' + cTipo + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local nX         := 0
    default aLog     := {}

    if !empty(aLog)
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:AddworkSheet("ExpIntegra")
        oFWMsExcel:AddTable("ExpIntegra", 'Err')
        for nX := 1 to len(aLog[01])
            oFWMsExcel:AddColumn("ExpIntegra",'Err','Col' + cValToChar(nX),1)
        next nX
        for nX := 1 to len(aLog)
            oFWMsExcel:AddRow("ExpIntegra",'Err',aLog[nX])
        next nX
        aLog := {}
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cNomArqv)
        FreeObj(oFWMsExcel)
    endif
return(self)

method addProd(cAls, nRec, lLog, nID, lCheck) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreacAls	:= (cAls)->(GetArea())
    local oRest		:= FWRest():New(::getUrl())
    local oBody		:= nil
    local aLog      := {}
    local oResp     := nil
    local aValue    := {}
    local lOk       := .T.
    default nID     := nil
    default lLog    := GetNewPar("ZZ_EXPDLOG", .T.)
    default lCheck  := .T.

    dbSelectArea(cAls)
    (cAls)->(DbGoTo(nRec))
    if cAls == 'ZAA'
        aAdd(aValue, AllTrim((cAls)->ZAA_CHAVE))
        aAdd(aValue, AllTrim((cAls)->ZAA_CHAVE) + AllTrim((cAls)->ZAA_BARINT))
        aAdd(aValue, AllTrim((cAls)->ZAA_BARINT))
        aAdd(aValue, AllTrim((cAls)->ZAA_NOME) + AllTrim((cAls)->ZAA_SECAO))
    elseif cAls == 'SZE'
        aAdd(aValue, AllTrim((cAls)->ZE_PRODUTO) + 'B' + StrZero(ZE_QUANT, 5))
        aAdd(aValue, AllTrim((cAls)->ZE_PRODUTO) + 'B' + StrZero(ZE_QUANT, 5) + '96' + (cAls)->ZE_FILORIG + StrZero(Val((cAls)->ZE_NUMBOB),7))
        aAdd(aValue, '96' + (cAls)->ZE_FILORIG + StrZero(Val((cAls)->ZE_NUMBOB),7))
        aAdd(aValue, AllTrim((cAls)->ZE_DESCPRO))
    endif
    if !empty(aValue)
        if lCheck
            lOk := checkDuplic(.F., AllTrim(aValue[3]), @Self, @nID)
        endif
        if lOk
            oBody := JsonObject():new()
            oBody['codigo']         := EncodeUtf8(AllTrim(aValue[1]))
            oBody['codProdBarInt']  := EncodeUtf8(AllTrim(aValue[2]))
            oBody['barint']         := EncodeUtf8(AllTrim(aValue[3]))
            oBody['descricao']      := EncodeUtf8(AllTrim(aValue[4]))
            oRest:SetPath('/produtos')
            oRest:SetPostParams(oBody:toJson())
            if !(oRest:Post(::getHeader()))
                if lLog
                    aAdd(aLog, {aValue[2], oRest:GetLastError()})
                endif
            else
                if(nID <> nil)
                    oResp := JsonObject():new()
                    oResp:fromJson(oRest:GetResult())
                    if !empty(oResp:GetNames())
                        nID := oResp['id']
                    endif
                endif
            endif
            FreeObj(oBody)
            FreeObj(oResp)
        else
            if lLog
                aAdd(aLog, {aValue[2], 'Produto Duplicado!'})
            endif
        endif
        if !empty(aLog)
            ::genLog('Add - (' + cAls + ') - ' + aValue[1], aLog)
        endif
    endif
    FreeObj(oRest)
    RestArea(aAreacAls)
    RestArea(aArea)
return(self)


method manutProd(cProd, lLog, lDel, lCheck, cWmsDesc, cEstMin) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreaSB1 	:= SB1->(GetArea())
    local oRest		:= FWRest():New(::getMntUrl())
    local oSql		:= LibSqlObj():newLibSqlObj()
    local oBody		:= nil
    local aLog      := {}
    local lOk       := .T.
    default lLog    := GetNewPar("ZZ_MNTDLOG", .F.)
    default cProd   := ''
    default cWmsDesc := ''

    if lDel == nil
        lDel := MsgYesNo('Substituir o Itens Duplicados?','Duplicados')
    endif

    if lCheck == nil .and. !lDel
        lCheck := MsgYesNo('Verificar Duplicados?','Duplicados')
    elseif lCheck == nil
        lCheck := .T.
    endif

    oRest:SetPath('/produtos')
    oSql:newAlias(qryMntProd(cProd))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            lOk := .T.
            if lCheck
                lOk := checkDuplic(lDel, EncodeUtf8(AllTrim(oSql:getValue("BARINT"))), @self,,::getMntUrl())
            endif
            if lOk
                oBody := JsonObject():new()
                oBody['codigo']         := EncodeUtf8(AllTrim(oSql:getValue("COD")))
                oBody['codProdBarInt']  := EncodeUtf8(AllTrim(oSql:getValue("COD_BAR")))
                oBody['barint']         := EncodeUtf8(AllTrim(oSql:getValue("BARINT")))
                oBody['descricao']      := EncodeUtf8(AllTrim(iif(!Empty(cWmsDesc),cWmsDesc,oSql:getValue("DESC"))))
                oBody['est_minimo']     := cEstMin
                oRest:SetPostParams(oBody:toJson())
                if !(oRest:Post(::getHeader()))
                    if lLog
                        aAdd(aLog, {oSql:getValue("COD_BAR"), oRest:GetLastError()})
                    endif
                endif
                FreeObj(oBody)
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oRest)
    if !empty(aLog)
        ::genLog('Full', aLog)
    endif
    RestArea(aAreaSB1)
    RestArea(aArea)
return(self)


method fullProd(lLog, lDel, lCheck) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreaZAA 	:= ZAA->(GetArea())
    local aAreaSZE 	:= SZE->(GetArea())
    local oRest		:= FWRest():New(::getUrl())
    local oSql		:= LibSqlObj():newLibSqlObj()
    local oBody		:= nil
    local aLog      := {}
    local lOk       := .T.
    default lLog    := GetNewPar("ZZ_EXPDLOG", .T.)

    if lDel == nil
        lDel := MsgYesNo('Substituir o Itens Duplicados?','Duplicados')
    endif

    if lCheck == nil .and. !lDel
        lCheck := MsgYesNo('Verificar Duplicados?','Duplicados')
    elseif lCheck == nil
        lCheck := .T.
    endif

    oRest:SetPath('/produtos')
    oSql:newAlias(qryFullProd())
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            lOk := .T.
            if lCheck
                lOk := checkDuplic(lDel, EncodeUtf8(AllTrim(oSql:getValue("BARINT"))), @self)
            endif
            if lOk
                oBody := JsonObject():new()
                oBody['codigo']         := EncodeUtf8(AllTrim(oSql:getValue("COD")))
                oBody['codProdBarInt']  := EncodeUtf8(AllTrim(oSql:getValue("COD_BAR")))
                oBody['barint']         := EncodeUtf8(AllTrim(oSql:getValue("BARINT")))
                oBody['descricao']      := EncodeUtf8(AllTrim(oSql:getValue("DESC")))
                oRest:SetPostParams(oBody:toJson())
                if !(oRest:Post(::getHeader()))
                    if lLog
                        aAdd(aLog, {oSql:getValue("COD_BAR"), oRest:GetLastError()})
                    endif
                endif
                FreeObj(oBody)
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oRest)

    if !empty(aLog)
        ::genLog('Full', aLog)
    endif
    RestArea(aAreaZAA)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(self)

method addOS(oOS, lLog) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local oRest		:= FWRest():New(::getUrl())
    local aLog      := {}
    default lLog    := GetNewPar("ZZ_EXPDLOG", .T.)

    oRest:SetPath('/enderecos')
    oRest:SetPostParams(oOS:toJson())
    if !(oRest:Post(::getHeader()))
        ::setStatus(.F., oRest:GetLastError())
        if lLog
            aAdd(aLog, {oOS['codUnico'] , oRest:GetLastError()})
        endif
    endif
    FreeObj(oRest)
    if !empty(aLog)
        ::genLog('OS', aLog)
    endif

    RestArea(aAreaZZR)
    RestArea(aArea)
return(self)

method removeOS(oOS, nId) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oBody     := JsonObject():new()

    oRest:SetPath('/enderecos/del/' + cValToChar(nId))
    if !(oRest:Put(::getHeader(), oBody:toJson()))
        ::setStatus(.F., oRest:GetLastError())
    endif
    FreeObj(oBody)
    FreeObj(oRest)
return(self)

method addEndereco(oEnder, nID) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    default oEnder  := JsonObject():new()
    default nID     := 0

    if(::setStatus(!empty(oEnder:GetNames()), 'Dados de Endereço não informados!'):isOk())
        if chkAddress(.F., oEnder['codUnico'], @self, @nID)
            oRest:SetPath('/enderecos')
            oRest:SetPostParams(oEnder:toJson())
            if !(oRest:Post(::getHeader()))
                ::setStatus(.F., oRest:GetLastError())
            else
                oResp := JsonObject():new()
                oResp:fromJson(oRest:GetResult())
                if !empty(oResp:GetNames())
                    nID := oResp['id']
                endif
                FreeObj(oResp)
            endif
        endif
    endif
    FreeObj(oRest)
    FreeObj(oEnder)
return(self)

method addPesagem(cNumPes, nRec) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreaSZL 	:= SZL->(GetArea())
    local aAreaSZE 	:= SZE->(GetArea())
    local aAreaZAA 	:= ZAA->(GetArea())
    local oJson     := nil
    local aTemp     := {}
    local cCodUniq  := ''
    local nIDProd   := 0
    local nIDEnder  := 0
    local nRecBob   := 0
    default nRec    := 0

    if nRec == 0
        aTemp = findRecno('SZL', cNumPes)
        if !empty(aTemp)
            nRec := aTemp[1]
        endif
    endif
    if(::setStatus((nRec > 0), 'Pesagem não localizada!'):isOk())
        DbSelectArea('SZL')
        SZL->(DbGoTo(nRec))
        if (validPesagem(AllTrim(SZL->ZL_STATUS), AllTrim(SZL->ZL_TIPO), @Self):isOk())
            nIDProd := checkProd(AllTrim(SZL->ZL_PRODUTO), AllTrim(SZL->ZL_ACOND),;
                iif(AllTrim(SZL->ZL_ACOND) == 'B', AllTrim(SZL->ZL_NUMBOB), AllTrim(SZL->ZL_ACOND) + StrZero(SZL->ZL_LANCE, 5)),;
                @self)
            if(::setStatus((!empty(nIDProd)),'ID do Produto não Localizada!'):isOk())
                cCodUniq := AllTrim(cNumPes)
                if (AllTrim(SZL->ZL_ACOND) == 'B')
                    aTemp := findRecno('SZE', AllTrim(SZL->ZL_NUMBOB))
                    if !empty(aTemp)
                        nRecBob := aTemp[1]
                    endif
                    if !empty(nRecBob)
                        DbSelectArea('SZE')
                        SZE->(DbGoTo(nRecBob))
                        cCodUniq := AllTrim(SZE->ZE_FILORIG) + StrZero(Val(SZE->ZE_NUMBOB),7)
                    endif
                endif
                mntEndereco('BMM', cCodUniq, @oJson)
                if ::addEndereco(oJson, @nIDEnder):isOk()
                    if(::setStatus((!empty(nIDEnder)),'ID do Endereço não Localizada!'):isOk())
                        FreeObj(oJson)
                        mntMovimento({{nIDProd, nIDEnder, SZL->ZL_QTLANCE}}, @oJson)
                        if(::setStatus(chkMovimento(nIDEnder, @Self),'Movimentos já realizado no Endereço do BMM!'):isOk())
                            ::doMovimento(oJson)
                        endif
                    endif
                endif
                FreeObj(oJson)
            endif
        endif
    endif
    RestArea(aAreaSZL)
    RestArea(aAreaZAA)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(self)

method doMovimento(oMov) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    default oMov    := JsonObject():new()

    if(::setStatus(!empty(oMov:GetNames()), 'Dados do Movimento não informados!'):isOk())
        oRest:SetPath('/movimentos')
        oRest:SetPostParams(oMov:toJson())
        if !(oRest:Post(::getHeader()))
            ::setStatus(.F., oRest:GetLastError())
        endif
    endif
    FreeObj(oRest)
    FreeObj(oMov)
return(self)

method GetInvent(cDtDe, cDtAte) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local cJsInvent := '{[]}'

    oRest:SetPath("/inventario/resulerp/'" + cDtDe + "'/'" + cDtAte + "'")
    if (oRest:Get(::getHeader()))
        cJsInvent := oRest:GetResult()
    endif
    FreeObj(oRest)
return(cJsInvent)

method chgStsInvent(cDtDe, cDtAte, nStatus) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local lRet      := .F.
    default nStatus := 1
    oRest:SetPath("/inventario/finalinv/'" + cDtDe + "'/'" + cDtAte + "'/" + cValToChar(nStatus))
    lRet := oRest:Get(::getHeader())
    FreeObj(oRest)
return(lRet)

method fromNFe(cChv) class cbcExpIntegra
    local aArea    	:= GetArea()
    local aAreaSF1 	:= SF1->(GetArea())
    local aAreaSD1 	:= SD1->(GetArea())
    local aAreaZAA 	:= ZAA->(GetArea())
    local oSql		:= LibSqlObj():newLibSqlObj()
    local oJson     := JsonObject():new()
    local aMovs     := {}
    local nIDProd   := 0
    local nIDEnder  := 0
    default nRec    := 0

    oSql:newAlias(qryLoadNF(cChv))
    if(::setStatus(oSql:hasRecords(), 'NFe Não Localizada!'):isOk())
        oSql:goTop()                       
        mntEndereco('NFE', AllTrim(oSql:getValue('DOC')), @oJson)
        if ::addEndereco(oJson, @nIDEnder):isOk()
            if(::setStatus((!empty(nIDEnder)),'ID do Endereço não Localizada!'):isOk())
                if(::setStatus(chkMovimento(nIDEnder, @Self),'Movimentos já realizados no Endereço da NFe!'):isOk())
                    while oSql:notIsEof()
                        nIDProd := 0
                        if(::addProd('ZAA', oSql:getValue('REC_ZAA'), .F., @nIDProd):isOk())
                            if(::setStatus((!empty(nIDProd)),'ID do Produto não Localizada!'):isOk())
                                aAdd(aMovs,{nIDProd, nIDEnder, (oSql:getValue('QTD')/Val(SubStr(oSql:getValue('LOCALIZ'), 2)))})
                            else
                                aMovs := {}
                                EXIT
                            endif
                        endif
                        oSql:skip()
                    endDo
                    if !empty(aMovs) .and. ::isOk()
                        FreeObj(oJson)
                        oJson   := JsonObject():new()
                        mntMovimento(aMovs, @oJson)
                        ::doMovimento(oJson)
                    endif
                endif
            endif
        endif
    endif
    oSql:close()
    FreeObj(oSql)
    FreeObj(oJson)
    RestArea(aAreaSD1)
    RestArea(aAreaZAA)
    RestArea(aAreaSF1)
    RestArea(aArea)
return(self)

method getEnder(aWhere) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local oJson     := JsonObject():new()
    local oAux      := JsonObject():new()        
    local nX        := 0
    local cParams   := nil
    default aWhere  := {}

    for nX := 1 to len(aWhere)
        oAux[aWhere[nX, 01]] := aWhere[nX, 02]
    next nX
    if !empty(oAux:GetNames())
        oJson:FromJson('{"where": {}}')
        oJson["where"] := oAux
        cParams := oJson:ToJson()
        oRest:SetPath('/enderecos?filter=' + AllTrim(cParams))
    else
        oRest:SetPath('/enderecos')
    endif
    if !(oRest:Get(::getHeader()))
        ::setStatus(.F., oRest:GetLastError())
    else
        oRet:fromJSON(oRest:GetResult())
    endif
    FreeObj(oAux)
    FreeObj(oJson)
    FreeObj(oRest)
return(oRet)

method getProd(aWhere) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local oJson     := JsonObject():new()
    local oAux      := JsonObject():new()
    local nX        := 0
    local cParams   := nil
    default aWhere  := {}
    
    for nX := 1 to len(aWhere)
        oAux[aWhere[nX, 01]] := aWhere[nX, 02]
    next nX
    if !empty(oAux:GetNames())
        oJson:FromJson('{"where": {}}')
        oJson["where"] := oAux
        cParams := oJson:ToJson()
        oRest:SetPath('/produtos?filter=' + AllTrim(cParams))
    else
        oRest:SetPath('/produtos')
    endif
    if !(oRest:Get(::getHeader()))
        ::setStatus(.F., oRest:GetLastError())
    else
        oRet:fromJSON(oRest:GetResult())
    endif
    FreeObj(oAux)
    FreeObj(oJson)
    FreeObj(oRest)
return(oRet)

method getEndMovs(nIdEnd, aWhere) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local oJson     := JsonObject():new()
    local oAux      := JsonObject():new()        
    local nX        := 0
    local cParams   := nil
    default aWhere  := {}

    for nX := 1 to len(aWhere)
        oAux[aWhere[nX, 01]] := aWhere[nX, 02]
    next nX
    if !empty(oAux:GetNames())
        oJson:FromJson('{"where": {}}')
        oJson["where"] := oAux
        cParams := oJson:ToJson()
        oRest:SetPath("/enderecos/" + cValToChar(nIdEnd) + "/movimentos?filter=" + AllTrim(cParams))
    else
        oRest:SetPath("/enderecos/" + cValToChar(nIdEnd) + "/movimentos")
    endif
    if !(oRest:Get(::getHeader()))
        ::setStatus(.F., oRest:GetLastError())
    else
        oRet:fromJSON(oRest:GetResult())
    endif
    FreeObj(oAux)
    FreeObj(oJson)
    FreeObj(oRest)
return(oRet)

method getInvAjuste(cDtDe, cDtAte, aEnds) class cbcExpIntegra
    local oRest		    := nil
    local oRet          := JsonObject():new()
    local oBody         := JsonObject():new()
    local cUrlApi       := AllTrim(GetNewPar("ZZ_LNODWMS", "http://192.168.1.220:4877"))
    default aEnds       := {}

    oRest		        := FWRest():New(cUrlApi)
    oBody['de']         := cDtDe
    oBody['ate']        := cDtAte
    oBody['codUnico']   := aEnds
    oRest:SetPath('/inv')
    oRest:SetPostParams(oBody:toJson())
    if !(oRest:Post(::getHeader()))
        ::setStatus(.F., oRest:GetLastError())
    else
        oRet:fromJSON(oRest:GetResult())
    endif

    FreeObj(oBody)
    FreeObj(oRest)
return(oRet)

method getSaldoProd(cCodBar) class cbcExpIntegra
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local nIDProd   := 0
    local nSaldo    := 0
    local nX        := 0

    chkProdut(.F., cCodBar, @self, @nIDProd)
    if !empty(nIDProd)
        oRest:SetPath("/produtos/" + cValToChar(nIDProd) + "/enderecados")
        if !(oRest:Get(::getHeader()))
            ::setStatus(.F., oRest:GetLastError())
        else
            oRet:fromJSON(oRest:GetResult())
            for nX := 1 to len(oRet)
                if oRet[nX]['enderecoId'] <> 33
                    nSaldo += (oRet[nX]['saldo'] - oRet[nX]['reservado'])
                endif
            next nX
        endif
    endif
    FreeObj(oRest)
return(nSaldo)

/*QUERY ZONE*/
static function qryMntProd(cCod)
    local cQry      := ''
    default cCod    := ''
    if !empty(cCod)
        cQry := "SELECT " 
        cQry += "B1_COD		AS [COD], "
        cQry += "B1_DESC	AS [DESC], "
        cQry += "B1_COD		AS [BARINT], "
        cQry += "B1_COD		AS [COD_BAR] "
        cQry += "FROM " + RetSqlName('SB1') + " B1 WITH(NOLOCK) "
        cQry += "WHERE B1.B1_FILIAL = '' "
        cQry += "AND B1.B1_TIPO NOT IN ('PA') "
        cQry += "AND B1.B1_COD = '" + cCod + "' "
        cQry += "AND B1.B1_MSBLQL <> 1 "
        cQry += "AND D_E_L_E_T_ = '' "
    endif
return cQry

static function qryFullProd(cBarInt)
    local cQry      := ''
    default cBarInt := ''

    cQry += " SELECT LTRIM(RTRIM(ZAA.ZAA_CHAVE)) AS [COD], "
    cQry += " LTRIM(RTRIM(ZAA.ZAA_NOME)) + LTRIM(RTRIM(ZAA.ZAA_SECAO)) AS [DESC], "
    cQry += " LTRIM(RTRIM(ZAA.ZAA_BARINT)) AS [BARINT], "
    cQry += " LTRIM(RTRIM(ZAA.ZAA_CHAVE)) + LTRIM(RTRIM(ZAA.ZAA_BARINT)) AS [COD_BAR] "
    cQry += " FROM " + RetSqlName('ZAA') + " ZAA WITH(NOLOCK) "
    cQry += " WHERE ZAA.ZAA_FILIAL = '" + xFilial('ZAA') + "' "
    cQry += " AND ZAA.D_E_L_E_T_ = '' "
    if !empty(cBarInt)
        cQry += " AND ZAA.ZAA_BARINT = '" + AllTrim(cBarInt) + "'"
    endif
    cQry += " UNION ALL "
    cQry += " SELECT LTRIM(RTRIM(SZE.ZE_PRODUTO)) + 'B' + REPLICATE('0',(5- LEN(CAST(SZE.ZE_QUANT AS VARCHAR(10)))))+ CAST(SZE.ZE_QUANT AS VARCHAR(10)) AS [COD], "
    cQry += " SZE.ZE_DESCPRO AS [DESC], "
    cQry += " '96' + SZE.ZE_FILORIG + REPLICATE('0', (7-LEN(SZE.ZE_NUMBOB))) + SZE.ZE_NUMBOB AS [BARINT], "
    cQry += " LTRIM(RTRIM(SZE.ZE_PRODUTO)) + 'B' + REPLICATE('0',(5- LEN(CAST(SZE.ZE_QUANT AS VARCHAR(10)))))+ CAST(SZE.ZE_QUANT AS VARCHAR(10)) + ('96' + SZE.ZE_FILORIG + REPLICATE('0', (7-LEN(SZE.ZE_NUMBOB))) + SZE.ZE_NUMBOB) AS [COD_BAR] "
    cQry += " FROM " + RetSqlName('SZE') + " SZE WITH(NOLOCK)"
    cQry += " WHERE SZE.D_E_L_E_T_ = '' "
    if !empty(cBarInt)
        cQry += " AND '96' + SZE.ZE_FILORIG + REPLICATE('0', (7-LEN(SZE.ZE_NUMBOB))) + SZE.ZE_NUMBOB = '" + AllTrim(cBarInt) + "'"
    else
        cQry += " AND SZE.ZE_STATUS NOT IN ('F','C') "
    endif
return(cQry)

static function qryFindRec(cAls, cContent)
    local cQry := ''
    cContent   := AllTrim(cContent)
    if cAls == 'ZAA'
        cQry += " SELECT ZAA.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('ZAA') + " ZAA "
        cQry += " WHERE ZAA.ZAA_CHAVE = '" + cContent + "' "
        cQry += " AND ZAA.D_E_L_E_T_ = '' "
    elseif cAls == 'SZE'
        cQry += " SELECT SZE.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('SZE') + " SZE "
        cQry += " WHERE SZE.ZE_FILIAL = '" + xFilial('SZE') + "' "
        cQry += " AND SZE.ZE_NUMBOB = '" + cContent + "' "
        cQry += " AND SZE.D_E_L_E_T_ = '' "
    elseif cAls == 'SZL'
        cQry += " SELECT SZL.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('SZL') + " SZL "
        cQry += " WHERE SZL.ZL_FILIAL = '" + xFilial('SZL') + "' "
        cQry += " AND SZL.ZL_NUM = '" + cContent + "' "
        cQry += " AND SZL.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function isTransf(cChv)
    local cFilTrf := ""
    local oSql    := LibSqlObj():newLibSqlObj()

    oSql:newAlias(qryIsTransf(cChv))
    if oSql:hasRecords()
        cFilTrf := AllTrim(oSql:getValue("FILIAL"))
    endif
    oSql:close()
    FreeObj(oSql)
return(cFilTrf)

static function qryIsTransf(cChv)
    local cQry := ''
    cQry += " SELECT DISTINCT(SF2.F2_FILIAL) AS [FILIAL] "
    cQry += " FROM SF2010 SF2 "
    cQry += " WHERE SF2.F2_FILIAL <> '" + xFilial('SF2') + "' "
    cQry += " AND SF2.F2_CHVNFE = '" + AllTrim(cChv) + "' "
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return(cQry)

static function qryLoadNF(cChv) //50210102544042000208550010000811281100064576
    local cQry      := ""
    local cFilTrf   := isTransf(cChv)

    if !empty(cFilTrf)
        cQry += " SELECT SD2.D2_DOC AS [DOC],
        cQry += " SD2.D2_COD	    AS [COD], "
        cQry += " SDB.DB_LOCALIZ	AS [LOCALIZ], "
        cQry += " SUM(SDB.DB_QUANT)	AS [QTD], "
        cQry += " ZAA.R_E_C_N_O_	AS [REC_ZAA] "
        cQry += " FROM " + RetSqlName('SD2') + " SD2 WITH(NOLOCK)"
        cQry += " INNER JOIN " + RetSqlName('SF2') + " SF2 WITH(NOLOCK) ON SD2.D2_FILIAL	= SF2.F2_FILIAL "
        cQry += " 					AND SD2.D2_DOC		= SF2.F2_DOC "
        cQry += " 					AND SD2.D2_SERIE	= SF2.F2_SERIE "
        cQry += " 					AND SD2.D_E_L_E_T_	= SF2.D_E_L_E_T_ "
        cQry += " INNER JOIN " + RetSqlName('SDB') + " SDB WITH(NOLOCK) ON SD2.D2_FILIAL	= SDB.DB_FILIAL "
        cQry += " 					AND SD2.D2_NUMSEQ	= SDB.DB_NUMSEQ "
        cQry += " 					AND SD2.D2_DOC		= SDB.DB_DOC "
        cQry += " 					AND 'S'				<> SDB.DB_ESTORNO "
        cQry += " 					AND SD2.D_E_L_E_T_	= SDB.D_E_L_E_T_ "
        cQry += " INNER JOIN " + RetSqlName('ZAA') + " ZAA WITH(NOLOCK) ON ''				= ZAA.ZAA_FILIAL "
        cQry += " 					AND RTRIM(LTRIM(SD2.D2_COD)) + RTRIM(LTRIM(SDB.DB_LOCALIZ)) = ZAA.ZAA_CHAVE "
        cQry += " 					AND SD2.D_E_L_E_T_	= ZAA.D_E_L_E_T_ "
        cQry += " WHERE SD2.D2_FILIAL = '" + AllTrim(cFilTrf) + "' "
        cQry += " AND SF2.F2_CHVNFE = '" + AllTrim(cChv) + "' "
        cQry += " AND SD2.D_E_L_E_T_ = '' "
        cQry += " AND SUBSTRING(SDB.DB_LOCALIZ, 1,1) <> 'B' "
        cQry += " GROUP BY SD2.D2_COD, SDB.DB_LOCALIZ, ZAA.R_E_C_N_O_, SD2.D2_DOC "
    else
        cQry += " SELECT SD1.D1_DOC AS [DOC],
        cQry += " SD1.D1_COD			AS [COD], "
        cQry += " SDB.DB_LOCALIZ				AS [LOCALIZ], "
        cQry += " SUM(SDB.DB_QUANT)			AS [QTD], "
        cQry += " ZAA.R_E_C_N_O_				AS [REC_ZAA] "
        cQry += " FROM " + RetSqlName('SD1') + " SD1 WITH(NOLOCK)"
        cQry += " INNER JOIN " + RetSqlName('SF1') + " SF1 WITH(NOLOCK) ON SD1.D1_FILIAL	= SF1.F1_FILIAL "
        cQry += " 					AND SD1.D1_DOC		= SF1.F1_DOC "
        cQry += " 					AND SD1.D1_SERIE	= SF1.F1_SERIE "
        cQry += " 					AND SD1.D1_FORNECE	= SF1.F1_FORNECE "
        cQry += " 					AND SD1.D1_LOJA		= SF1.F1_LOJA "
        cQry += " 					AND SD1.D_E_L_E_T_	= SF1.D_E_L_E_T_ "
        cQry += " INNER JOIN " + RetSqlName('SDB') + " SDB WITH(NOLOCK) ON SD1.D1_FILIAL	= SDB.DB_FILIAL "
        cQry += " 					AND SD1.D1_NUMSEQ	= SDB.DB_NUMSEQ "
        cQry += " 					AND SD1.D1_DOC		= SDB.DB_DOC "
        cQry += " 					AND 'S'				<> SDB.DB_ESTORNO "
        cQry += " 					AND SD1.D_E_L_E_T_	= SDB.D_E_L_E_T_ "
        cQry += " INNER JOIN " + RetSqlName('ZAA') + " ZAA WITH(NOLOCK) ON ''				= ZAA.ZAA_FILIAL "
        cQry += " 					AND RTRIM(LTRIM(SD1.D1_COD)) + RTRIM(LTRIM(SDB.DB_LOCALIZ)) = ZAA.ZAA_CHAVE "
        cQry += " 					AND SD1.D_E_L_E_T_	= ZAA.D_E_L_E_T_ "
        cQry += " WHERE SD1.D1_FILIAL = '" + xFilial('SD1') + "' "
        cQry += " AND SF1.F1_CHVNFE = '" + AllTrim(cChv) + "' "
        cQry += " AND SD1.D_E_L_E_T_ = '' "
        cQry += " AND SUBSTRING(SDB.DB_LOCALIZ, 1,1) <> 'B' "
        cQry += " GROUP BY SD1.D1_COD, SDB.DB_LOCALIZ, ZAA.R_E_C_N_O_, SD1.D1_DOC "
    endif
return(cQry)

/*USER ZONE*/
user function shcEndFull()
    local oInt := cbcExpIntegra():newcbcExpIntegra(.F.)
    oInt:fullProd(.T., .T.)
return(nil)

user function shcEndDifer()
    local oInt := cbcExpIntegra():newcbcExpIntegra(.F.)
    oInt:fullProd(.T., .F., .T.)
return(nil)

user function wmsPrdLoad()
    local oInt := cbcExpIntegra():newcbcExpIntegra(.F.)
    oInt:fullProd(.T., .F., .F.)
return(nil)

user function cbcIPrdWms()
    local oModal        := nil
    local nPosiList		:= 1
    local oPnl  		:= nil
    local oFont		    := TFont():New("Arial",,20,,.T.)
    local oList 		:= nil
    local cSay          := ''
    local cGet          := ''
    local bConfirm		:= {|| procIntSingle(nPosiList, AllTrim(cGet), @oSay, @oGet, @cSay, @cGet)}
    local bRefresh      := {|| rshMdl(nPosiList, @cSay, @oSay, @oGet, @cGet)}
    local aList			:= {'BOBINAS', 'OUTROS'}
    local oSay          := nil
    local oGetSze       := nil
    local oGetZza       := nil

    oModal:= FWDialogModal():New()
    oModal:setSize(150,250)
    oModal:SetEscClose(.T.)
    oModal:setTitle('Adicionar Produto - cbcWMS')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:addOkButton(bConfirm, "Adicionar", {||.T.} )
    oModal:setInitBlock({|| oList:SetFocus()})
    oPnl := TPanel():New( ,,, oModal:getPanelMain())
    oPnl:SetCss("")
    oPnl:Align := CONTROL_ALIGN_ALLCLIENT

    oList   := TListBox():New(05,05,{|u|if(Pcount()>0, nPosiList := u, nPosiList)},;
        aList,240,35,,oPnl, /*bRefresh*/,,,.T.,,,oFont)

    oList:BlDblClick := bRefresh
    oSay	:= TSay():New(60,05,	{||cSay }, oPnl,,oFont,,,,.T.,,,100, 25)
    oGet	:= TGet():New(54,90, 	{ | u | If( PCount() == 0, cGet, cGet := u ) },;
        oPnl, 140, 25,"@!",,0,,oFont,.F.,,.T.,;
        ,.F.,,.F.,.F.,,.F.,.F.,,cGet,,,, )
    oGet:Hide()
    oModal:Activate()

    FreeObj(oSay)
    FreeObj(oGetSze)
    FreeObj(oGetZza)
    FreeObj(oList)
    FreeObj(oPnl)
    FreeObj(oModal)
return(nil)

static function rshMdl(nPos, cSay, oSay, oGet, cGet)
    if nPos == 1
        cSay := 'Num. Bobina: '
        cGet := Space(TamSx3("ZE_NUMBOB")[1])
    else
        cSay := 'Cod.Prod + Acondic.: '
        cGet := Space(TamSx3("B1_NOME")[1] +;
            TamSx3("B1_BITOLA")[1] +;
            TamSx3("B1_COR")[1] +;
            TamSx3("B1_CLASENC")[1] +;
            TamSx3("B1_ESPECIA")[1] +;
            6)
    endif
    oGet:Show()
    oSay:Refresh()
    oGet:Refresh()
return(.T.)

static function procIntSingle(nOpc, cContent, oSay, oGet, cSay, cGet)
    local cAls  := iif(nOpc == 1, 'SZE', 'ZAA')
    local oInt  := cbcExpIntegra():newcbcExpIntegra(.F.)
    local aRec  := findRecno(cAls, cContent)
    local nX    := 0

    if empty(aRec)
        msgAlert('Produto não encontrado!', 'Erro na Integração')
    endif

    for nX := 1 to len(aRec)
        if !(oInt:addProd(cAls, aRec[nX]):isOk())
            msgAlert(oInt:getErrMsg(), 'Erro na Integração')
        else
            msgInfo('Produto integrado com sucesso!', 'Integração cbcWms')
        endif
    next
    FreeObj(oInt)
    //Refresh Tela
    cSay := ''
    cGet := ''
    oGet:Hide()
    oSay:Refresh()
    oGet:Refresh()
return(.T.)

static function checkProd(cProd, cAcond, cKey, oSelf)
    local aArea    	:= GetArea()
    local aAreaSZL 	:= SZL->(GetArea())
    local aAreaSZE 	:= SZE->(GetArea())
    local aAreaZAA 	:= ZAA->(GetArea())
    local cAls      := iif(cAcond == 'B','SZE','ZAA')
    local aRec      := {}
    local nID       := 0

    aRec := findRecno(cAls, iif(cAcond == 'B', cKey, (cProd + cKey)))
    if !empty(aRec)
        oSelf:addProd(cAls, aRec[1], .F., @nID)
    endif

    RestArea(aAreaSZL)
    RestArea(aAreaZAA)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(nID)

static function checkDuplic(lDel, cBarint, oSelf, nID, cUrl)
    local lOk       := .T.
    local oRest		:= nil
    local oJson     := JsonObject():new()
    default nID     := 0
    default lDel    := .F.
    default cUrl    := oSelf:getUrl()

    oRest := FWRest():New(cUrl)
    oRest:SetPath('/produtos/codefrombar/' + cBarint)
    if (oRest:Get(oSelf:getHeader()))
        oJson:fromJSON(oRest:GetResult())
        if (len(oJson) > 0)
            nID := oJson[1]['id']
            if lDel
                oRest:SetPath('/produtos/' + AllTrim(cValToChar(nID)))
                oRest:Delete(oSelf:getHeader())
                lOk := (oRest:GetHTTPCode() == "204")
            else
                lOk := .F.
            endif
        endif
    endif
    FreeObj(oJson)
    FreeObj(oRest)
return(lOk)

static function chkAddress(lDel, cCodUniq, oSelf, nID)
    local lOk       := .T.
    local oJson     := JsonObject():new()
    local aWhere    := {}
    default nID     := 0
    default lDel    := .F.

    aAdd(aWhere,{"codUnico", cCodUniq})
        
    oJson := oSelf:getEnder(aWhere)
    if (len(oJson) > 0)
        nID := oJson[1]['id']
        if lDel
            oRest:SetPath('/enderecos/' + AllTrim(cValToChar(nID)))
            oRest:Delete(oSelf:getHeader())
            lOk := (oRest:GetHTTPCode() == "204")
        else
            lOk := .F.
        endif
    endif
    FreeObj(oJson)
return(lOk)

static function chkMovimento(nIDEnder, oSelf)
    local lOk       := .F.
    local oRest		:= FWRest():New(oSelf:getUrl())
    local oJson     := JsonObject():new()

    oRest:SetPath('/enderecos/' + cValToChar(nIDEnder) + '/movimentos')
    if (oRest:Get(oSelf:getHeader()))
        oJson:fromJSON(oRest:GetResult())
        if (len(oJson) <= 0)
            lOk := .T.
        endif
    endif
    FreeObj(oJson)
    FreeObj(oRest)
return(lOk)

static function getBarInt(cProd, cAcond, cKey)
    local aArea    	:= GetArea()
    local aAreaSZL 	:= SZL->(GetArea())
    local aAreaSZE 	:= SZE->(GetArea())
    local aAreaZAA 	:= ZAA->(GetArea())
    local cAls      := iif(aAcond == 'B','SZE','ZAA')
    local aRec      := {}

    aRec := findRecno(cAls, iff(aAcond == 'B', cKey, (cProd + cKey)))
    if !empty(aRec)
        dbSelectArea(cAls)
        (cAls)->(DbGoTo(aRec[01]))
        if cAls == 'ZAA'
            cBarInt :=  AllTrim((cAls)->ZAA_BARINT)
        elseif cAls == 'SZE'
            cBarInt := '96' + (cAls)->ZE_FILORIG + StrZero(Val((cAls)->ZE_NUMBOB),7)
        endif
    endif

    RestArea(aAreaSZL)
    RestArea(aAreaZAA)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(cBarInt)

static function getProdDet(cBarInt)
    local aArea    	:= GetArea()
    local aAreaSZL 	:= SZL->(GetArea())
    local aAreaSZE 	:= SZE->(GetArea())
    local aAreaZAA 	:= ZAA->(GetArea())
    local cAls      := iif(aAcond == 'B','SZE','ZAA')
    local aRec      := {}

    aRec := findRecno(cAls, iff(aAcond == 'B', cKey, (cProd + cKey)))
    if !empty(aRec)
        dbSelectArea(cAls)
        (cAls)->(DbGoTo(aRec[01]))
        if cAls == 'ZAA'
            cBarInt :=  AllTrim((cAls)->ZAA_BARINT)
        elseif cAls == 'SZE'
            cBarInt := '96' + (cAls)->ZE_FILORIG + StrZero(Val((cAls)->ZE_NUMBOB),7)
        endif
    endif

    RestArea(aAreaSZL)
    RestArea(aAreaZAA)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(cBarInt)

static function findRecno(cAls, cKey)
    local oSql      := LibSqlObj():newLibSqlObj()
    local aRec      := {}
    default cAls    := ''
    default cContent:= ''

    oSql:newAlias(qryFindRec(cAls, cKey))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            aAdd(aRec, oSql:getValue("REC"))
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(aRec)

static function mntEndereco(cTipo, cEnd, oEnd)
    default cEnd  := ''
    default cTipo := ''
    default oEnd    := JsonObject():new()

    if !empty(cEnd)
        oEnd['rua']            := 'X'
        oEnd['prateleira']     := 'X'
        oEnd['nivel']          := 'X'
        oEnd['posicao']        := 'X'
        oEnd['cap_max']        := 0
        oEnd['perc_ocupado']   := 0
        oEnd['op_atual']       := ''
        oEnd['ativo']          := .T.
        oEnd['mov_tipo']       := 'END'
        oEnd['codUnico']       := (AllTrim(cTipo) + '_' + AllTrim(cEnd))
        oEnd['json_regra']     := '{"data": []}'
        oEnd['bmm']            := iif(cTipo == 'BMM', .T., .F.)
        oEnd['picking']        := .F.
    endif

return(oEnd)

static function mntMovimento(aMovs, oMov, nEndOri, nOper)
    local aEndMovs  := {}
    local aSaldo    := {}
    local oJson     := nil
    local nX        := nil
    default oMov    := JsonObject():new()
    default aMovs   := {}
    default nEndOri := 33
    default nOper   := 65

    if !empty(aMovs)
        for nX := 1 to len(aMovs)
            if !empty(aMovs[nX,01]) .and. !empty(aMovs[nX,02]) .and. !empty(aMovs[nX,03])
                oJson    := JsonObject():new()
                //#SAIDA
                //"data": "2020-10-08T15:14:07.970Z",
                oJson["tipo"]       := "SAIDA"
                oJson["quantidade"] := aMovs[nX,03]
                oJson["enderecoId"] := nEndOri
                oJson["endMovId"]   := aMovs[nX,02]
                oJson["operadorId"] := nOper
                oJson["produtoId"]  := aMovs[nX,01]
                aAdd(aEndMovs, oJson)
                FreeObj(oJson)

                oJson    := JsonObject():new()
                //#ENTRADA
                //"data": "2020-10-08T15:14:07.970Z",
                oJson["tipo"]       := "ENTRADA"
                oJson["quantidade"] := aMovs[nX,03]
                oJson["enderecoId"] := aMovs[nX,02]
                oJson["endMovId"]   := nEndOri
                oJson["operadorId"] := nOper
                oJson["produtoId"]  := aMovs[nX,01]
                aAdd(aEndMovs, oJson)
                FreeObj(oJson)

                oJson    := JsonObject():new()
                oJson["prodId"]     := aMovs[nX,01]
                oJson["endereco"]   := nEndOri
                aAdd(aSaldo, oJson)
                oJson["endereco"]   := aMovs[nX,02]
                aAdd(aSaldo, oJson)
                FreeObj(oJson)
            else
                aEndMovs := {}
                aSaldo:= {}
                EXIT
            endif
        next nX
    endif
    if !empty(aEndMovs) .and. !empty(aSaldo)
        oMov["mov"] := aEndMovs
        oMov["upd"] := aSaldo
    endif
return(oMov)

static function validPesagem(cStatus, cTipo, oSelf)
    local lPesProc  := iif(cStatus == 'P', GetNewPar('ZZ_HPPCWMS', .T.), .F.)
    local lProd     := ((cStatus == 'A' .or. cStatus == 'E' .or. lPesProc) .and. (cTipo $ 'U|P'))
    local lTroca    := (cTipo $ "TF")
    local lRetrab   := ((cStatus == 'A' .or. cStatus == 'E') .and. (cTipo $ 'R'))
    local lCbcWms   := GetNewPar('ZZ_ICBCWMS', .F.)
    oSelf:setStatus(((lProd .or. lTroca .or. lRetrab) .and. lCbcWms), 'Status ou Tipo de Pesagem inválido para Integração')
return(oSelf)

static function chkProdut(lDel, cCodBar, oSelf, nID)
    local lOk       := .T.
    local oJson     := JsonObject():new()
    local aWhere    := {}
    default nID     := 0
    default lDel    := .F.

    aAdd(aWhere,{"barint", cCodBar})
        
    oJson := oSelf:getProd(aWhere)
    if (len(oJson) > 0)
        nID := oJson[1]['id']
        if lDel
            oRest:SetPath('/produtos/' + AllTrim(cValToChar(nID)))
            oRest:Delete(oSelf:getHeader())
            lOk := (oRest:GetHTTPCode() == "204")
        else
            lOk := .F.
        endif
    endif
    FreeObj(oJson)
return(lOk)

/*TESTE ZONE*/
user function ztstExpIntega(cNumPes, nRec) //ztstExpIntega('91920110100')
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
    default nRec    := 0

    if oInt:addPesagem(cNumPes, nRec):isOk()
        MsgInfo('Pesagem integrada com sucesso', 'Processada')
    else
        MsgAlert(oInt:getErrMsg(), 'Erro')
    endif
    /*
    nRec := oInt:getSaldoProd(cNumPes)
    alert(cValtoChar(nRec))
    */
    FreeObj(oInt)
return(nil)

user function ztstWmsInv()
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
    local oJson     := JsonObject():new()
    oJson:fromJSON(oInt:GetInvent("2020-12-01", "2020-12-01"))
    alert('teste')
return(nil)

user function ztmntAdd(cProd,cDesc,cEstMin)
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
    default cDesc   := ''
    oInt:manutProd(cProd, .F., .T., .T.,cDesc,cEstMin)
    FreeObj(oInt)
return(nil)
