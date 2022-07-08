#include 'Totvs.ch'
class cbcAlmoxInteg
    data lOk
    data cMsgErr
    data lShowErr
    data cUrlApi
    data aHeader

    method newcbcAlmoxInteg()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getHeader()
    method getUrl()
    method genLog()
    method manutProd()
    method addEndereco()    
    method doMovimento()
    method fromNFe()
    method getEnder()
    method getProd()
    method getEndMovs()
    method getSaldoProd()
    method addSmc()
    method getInvAjuste()
    method chgStsInvent()
    method removeOS()
    method isSMCCanc()
    method reservar()
endClass

method newcbcAlmoxInteg(lShowErr) class cbcAlmoxInteg
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::cUrlApi   := Alltrim(GetNewPar("ZZ_MNTAAPI", "http://192.168.1.25:3397"))
    ::aHeader   := {}
    aadd(::aHeader, 'Content-Type: application/json')
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcAlmoxInteg
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[cbcAlmoxInteg] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcAlmoxInteg')
            endif
        endif
    endif
return(self)

method isOk() class cbcAlmoxInteg
return(::lOk)

method getErrMsg() class cbcAlmoxInteg
return(::cMsgErr)

method showErr() class cbcAlmoxInteg
return(::lShowErr)

method getHeader() class cbcAlmoxInteg
return(::aHeader)

method getUrl() class cbcAlmoxInteg
return(::cUrlApi)

method genLog(cTipo, aLog) class cbcAlmoxInteg
    local oFWMsExcel := nil
    local cSrvPath   := "\AlmoxInteg\"
    local cNomArqv   := cSrvPath + FwFilial() + '_cbcAlmoxInteg_' + cTipo + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local nX         := 0
    default aLog     := {}

    if !empty(aLog)
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:AddworkSheet("AlmoxInteg")
        oFWMsExcel:AddTable("AlmoxInteg", 'Err')
        for nX := 1 to len(aLog[01])
            oFWMsExcel:AddColumn("AlmoxInteg",'Err','Col' + cValToChar(nX),1)
        next nX
        for nX := 1 to len(aLog)
            oFWMsExcel:AddRow("AlmoxInteg",'Err',aLog[nX])
        next nX
        aLog := {}
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cNomArqv)
        FreeObj(oFWMsExcel)
    endif
return(self)

method manutProd(cProd, lLog, lDel, lCheck, cWmsDesc) class cbcAlmoxInteg
    local aArea    	:= GetArea()
    local aAreaSB1 	:= SB1->(GetArea())
    local oRest		:= FWRest():New(::getUrl())
    local oSql		:= LibSqlObj():newLibSqlObj()
    local oBody		:= nil
    local aLog      := {}
    local lOk       := .T.
    default lLog    := GetNewPar("ZZ_MNTALOG", .F.)
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
                lOk := checkDuplic(lDel, EncodeUtf8(AllTrim(oSql:getValue("BARINT"))), @self,,::getUrl())
            endif
            if lOk
                oBody := JsonObject():new()
                oBody['codigo']         := EncodeUtf8(AllTrim(oSql:getValue("COD")))
                oBody['codProdBarInt']  := EncodeUtf8(AllTrim(oSql:getValue("COD_BAR")))
                oBody['barint']         := EncodeUtf8(AllTrim(oSql:getValue("BARINT")))
                oBody['descricao']      := EncodeUtf8(AllTrim(oSql:getValue("DESC"))+Alltrim(cWmsDesc))
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

method addEndereco(oEnder, nID) class cbcAlmoxInteg
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

method doMovimento(oMov) class cbcAlmoxInteg
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

method fromNFe(cCodUniq, aItems, lAddProd) class cbcAlmoxInteg
    local aArea    	:= GetArea()
    local oJson     := JsonObject():new()
    local aMovs     := {}
    local nIDProd   := 0
    local nIDEnder  := 0
    local nX        := 0
    default nRec    := 0
    default lAddProd:= .F.

    mntEndereco('NFE', AllTrim(cCodUniq), @oJson)
    if ::addEndereco(oJson, @nIDEnder):isOk()
        if(::setStatus((!empty(nIDEnder)),'ID do Endereço não Localizada!'):isOk())
            for nX := 1 to len(aItems)
                chkProdut(.F., aItems[nX,01], @self, @nIDProd)
                if empty(nIDProd) .and. lAddProd
                    ::manutProd(aItems[nX,01], .F., .T., .T.,aItems[nX,02])
                endif
                if(::setStatus((!empty(nIDProd)),aItems[nX,01] + ' - ID do Produto não Localizada!'):isOk())
                    aAdd(aMovs,{nIDProd, nIDEnder, aItems[nX,03]})
                else
                    aMovs := {}
                    EXIT
                endif
            next nX
            if !empty(aMovs) .and. ::isOk()
                FreeObj(oJson)
                oJson   := JsonObject():new()
                mntMovimento(aMovs, @oJson)
                ::doMovimento(oJson)
            endif
        endif
    endif
    FreeObj(oJson)
    RestArea(aArea)
return(self)

method getEnder(aWhere, cParams) class cbcAlmoxInteg
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local oJson     := JsonObject():new()
    local oAux      := JsonObject():new()        
    local nX        := 0
    default cParams := ""
    default aWhere  := {}

    for nX := 1 to len(aWhere)
        oAux[aWhere[nX, 01]] := aWhere[nX, 02]
    next nX
    if !empty(oAux:GetNames()) .and. empty(cParams)
        oJson:FromJson('{"where": {}}')
        oJson["where"] := oAux
        cParams := oJson:ToJson()
        oRest:SetPath('/enderecos?filter=' + AllTrim(cParams))
    elseif !empty(cParams)
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

method getProd(aWhere) class cbcAlmoxInteg
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

method getEndMovs(nIdEnd, aWhere) class cbcAlmoxInteg
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

method getSaldoProd(cCodBar) class cbcAlmoxInteg
    local oRest		:= FWRest():New(::getUrl())
    local oRet      := JsonObject():new()
    local nSaldo    := 0
    local nX        := 0
    default cCodBar := ""
    
    //chkProdut(.F., cCodBar, @self, @nIDProd)
    if !empty(cCodBar)
        oRest:SetPath("/enderecados/saldoproduto/" + cValToChar(cCodBar))
        if !(oRest:Get(::getHeader()))
            ::setStatus(.F., oRest:GetLastError())
        else
            oRet:fromJSON(oRest:GetResult())
            for nX := 1 to len(oRet)
                nSaldo += (oRet[nX]['saldo'])
            next nX
        endif
    endif
    FreeObj(oRest)
return(nSaldo)

method addSmc(cSMC, aSMC, nSeq) class cbcAlmoxInteg
    local oEnder    := JsonObject():new()
    local oJson     := JsonObject():new()
    local nX        := 0
    local cWhere    := ""
    local nNxtSeq   := 0
    local lReserv   := .F.
    default cSepCod := ""
    default aSepara := {}
    default nSeq    := 0

    if !empty(cSMC) .and. !empty(aSMC)
        cWhere := '{"where":{"mov_tipo":"SEP","codUnico":{"like":"' + cSMC + '%25"}}}'
        oEnder := ::getEnder({},cWhere)
        for nX := 1 to len(oEnder)
            if nNxtSeq < Val(Substr(oEnder[nX]["codUnico"],7,2))
                nNxtSeq := Val(Substr(oEnder[nX]["codUnico"],7,2))
            endif
        next nX
        FreeObj(oEnder)
        nNxtSeq++
        lReserv := ::reservar(aSMC):isOk()
        oJson['rua']            := 'X'
        oJson['prateleira']     := 'X'
        oJson['nivel']          := 'X'
        oJson['posicao']        := 'X'
        oJson['cap_max']        := 0
        oJson['perc_ocupado']   := 0
        oJson['op_atual']       := ''
        oJson['ativo']          := lReserv
        oJson['mov_tipo']       := 'SEP'
        oJson['codUnico']       := AllTrim(cSMC) + StrZero(nNxtSeq,2)
        oJson['json_regra']     := mntItems(aSMC)
        ::setStatus(::addEndereco(oJson):isOk(), 'SMC:' + AllTrim(cSMC) + StrZero(nNxtSeq,2) + ' não Integrada!',.T.)
        FreeObj(oJson)
        nSeq := nNxtSeq
    endif
return(self)

method getInvAjuste(cDtDe, cDtAte, aEnds) class cbcAlmoxInteg
    local oRest		    := nil
    local oRet          := JsonObject():new()
    local oBody         := JsonObject():new()
    local cUrlApi       := AllTrim(GetNewPar("ZZ_NODAWMS", "http://192.168.1.25:4877"))
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

method chgStsInvent(cDtDe, cDtAte, nStatus) class cbcAlmoxInteg
    local oRest		:= FWRest():New(::getUrl())
    local lRet      := .F.
    default nStatus := 1
    oRest:SetPath("/inventario/finalinv/'" + cDtDe + "'/'" + cDtAte + "'/" + cValToChar(nStatus))
    lRet := oRest:Get(::getHeader())
    FreeObj(oRest)
return(lRet)

method isSMCCanc(cSMC) class cbcAlmoxInteg
    local oEnder    := JsonObject():new()
    local cWhere    := ""
    local nX        := 0
    local lCanc     := .F.
    default cSMC    := ""

    if !empty(cSMC)
        cWhere := '{"where":{"mov_tipo":"SEP","codUnico":"' + cSMC + '"}}'
        oEnder := ::getEnder({},cWhere)
        for nX := 1 to len(oEnder)
            lCanc := oEnder[nX]["delend"]
            if !lCanc
                EXIT
            endif
        next nX
    endif
    FreeObj(oEnder)
return(lCanc)

method reservar(aSMC) class cbcAlmoxInteg
    local oRest		:= FWRest():New(::getUrl())
    local oBody     := JsonObject():new()
    local oItem     := nil
    local nX        := 0
    local aJsItems  := {}
    default aSMC    := {}

    if (::setStatus(!empty(aSMC),'Sem Itens para Reservar!'):isOk())
        for nX := 1 to len(aSMC)
            oItem           := JsonObject():new()
            oItem["cod"]    := EncodeUtf8(AllTrim(aSMC[nX, 01]))
            oItem["qtd"]    := aSMC[nX, 02]
            aAdd(aJsItems, oItem)
            FreeObj(oItem)
        next nX
        if (::setStatus(!empty(aJsItems),'Sem Itens para Reservar!'):isOk())
            oBody['reserva']    := .T.
            oBody['lista']      := aJsItems
            oRest:SetPath("/produtos/saldoatende")
            oRest:SetPostParams(oBody:toJson())
            if !(oRest:Post(::getHeader()))
                ::setStatus(.F., oRest:GetLastError())
            else
                ::setStatus((oRest:GetResult() == 'true'),'Não foi possivel reservar os produtos!'):isOk()
            endif
        endif
    endif
    FreeObj(oBody)
    FreeObj(oRest)
return(self)

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

static function qryLoadNF(cChv) //50210102544042000208550010000811281100064576
    local cQry      := ""
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
return(cQry)

/*FUNCTIONS ZONE*/
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

static function chkMovimento(nIDEnder, oSelf, aWhere)
    local lOk       := .F.
    local oJson     := JsonObject():new()
    default aWhere  := {}

    oJson := oSelf:getEndMovs(nIDEnder, aWhere)
    if (len(oJson) > 0)
        lOk := .T.
    endif
    FreeObj(oJson)
return(lOk)

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

static function mntItems(aItems)
    local aArea    	:= GetArea()
    local aAreaSB1 	:= SB1->(GetArea())
    local oData     := JsonObject():new()
    local oItem     := nil
    local nX        := 0
    local nPos      := 0
    local aJsItems  := {}
    default aItems  := {}

    DbSelectArea('SB1')

    for nX := 1 to len(aItems)
        nPos := 0
        if !empty(aJsItems)
            nPos := AScan( aJsItems, {|x| x["barint"] == EncodeUtf8(AllTrim(aItems[nX, 01]))})
        endif
        if nPos > 0
            aJsItems[nPos]["qtdBar"] += aItems[nX, 02]
        else
            oItem           := JsonObject():new()
            oItem["barint"] := EncodeUtf8(AllTrim(aItems[nX, 01]))
            oItem["qtdBar"] := aItems[nX, 02]
            oItem["itm"]    := EncodeUtf8(StrZero(nX,3))
            oItem["descr"]  := EncodeUtf8(AllTrim(Posicione("SB1",1,xFilial("SB1")+ PadR(aItems[nX, 01],TamSX3('B1_COD')[1]),"B1_DESC")))
            aAdd(aJsItems, oItem)
            FreeObj(oItem)
        endif
    next nX

    if !empty(aJsItems)
        oData['data']	    := aJsItems
    endif
    RestArea(aAreaSB1)
    RestArea(aArea)
return(oData:ToJson())


/*TESTE ZONE*/
user function zTstcbcAlmoxInteg()//zTstcbcAlmoxInteg("00097102")
    local oInt := cbcAlmoxInteg():newcbcAlmoxInteg()

    oInt:reservar({{'MC15001974',12}})
return(nil)
