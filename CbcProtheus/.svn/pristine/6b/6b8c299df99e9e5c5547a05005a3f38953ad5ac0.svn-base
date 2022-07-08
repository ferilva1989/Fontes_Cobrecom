#include 'Totvs.ch'

class ctrlCbcBudget
    data lOk
    data cMsgErr
    data lShowErr
    data cUrlApi
    data aHeader
    data aApiToken
    data lLog
    data aLogs

    method newctrlCbcBudget()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getHeader()
    method actUrl()
    method getUrl()
    method actLog()
    method isLog()
    method addLog()
    method genLog()
    method login()
    method setApiTkn()
    method getApiTkn()
    method listVigencias()
    method vigencia()
    method listSld()
    method listBudgets()
    method budgetSld()
    method addBudget()
    method movimento()
    method libMov()
endClass

method newctrlCbcBudget(lShowErr) class ctrlCbcBudget
    default lShowErr := .T.

    ::lShowErr  := lShowErr
    ::aApiToken := {}
    ::actUrl()
    ::actLog()
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class ctrlCbcBudget
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[ctrlCbcBudget] - ' + cMsgErr
        ::addLog(cMsgErr)
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - ctrlCbcBudget')
            endif
        endif
    endif
return(self)

method isOk() class ctrlCbcBudget
return(::lOk)

method getErrMsg() class ctrlCbcBudget
return(::cMsgErr)

method showErr() class ctrlCbcBudget
return(::lShowErr)

method getHeader(lApiTkn, lErpTkn) class ctrlCbcBudget
    default lApiTkn := .F.
    default lErpTkn := .F.

    ::aHeader   := {}
    aadd(::aHeader, 'Content-Type: application/json')
    aadd(::aHeader, 'filial: ' + FwFilial())
    if lApiTkn
        aadd(::aHeader, "x-access-token: " + ::getApiTkn())
    endif
    if lErpTkn
        aadd(::aHeader, "erp_tkn: COBRECOM_IFC##@@45cbFonte")
    endif
return(::aHeader)

method actUrl() class ctrlCbcBudget
    ::cUrlApi   := Alltrim(GetNewPar("ZZ_BUDGAPI", "https://192.168.1.217:3012"))
return(self)

method getUrl() class ctrlCbcBudget
return(::cUrlApi)

method actLog() class ctrlCbcBudget
    ::lLog      := GetNewPar("ZZ_BUDGLOG", .F.)
    ::aLogs     := {}
return(self)

method isLog() class ctrlCbcBudget
return(::lLog)

method addLog(cMsgErr) class ctrlCbcBudget
    ConOut(cMsgErr)
    aAdd(::aLogs, cMsgErr)
return(self)

method genLog(cTipo) class ctrlCbcBudget
    local oFWMsExcel := nil
    local cSrvPath   := "\CbcBudget\"
    local cNomArqv   := cSrvPath + FwFilial() + '_ctrlCbcBudget_' + cTipo + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local nX         := 0

    if ::isLog() .and. !empty(::aLogs)
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:AddworkSheet("CbcBudget")
        oFWMsExcel:AddTable("CbcBudget", 'Err')
        for nX := 1 to len(::aLogs[01])
            oFWMsExcel:AddColumn("CbcBudget",'Err','Col' + cValToChar(nX),1)
        next nX
        for nX := 1 to len(::aLogs)
            oFWMsExcel:AddRow("CbcBudget",'Err',::aLogs[nX])
        next nX
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cNomArqv)
        FreeObj(oFWMsExcel)
    endif
    ::aLogs := {}
return(self)

method login() class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oBody     := JsonObject():new()
    local oResp     := nil
    local cApiTkn   := ""
    
    oBody['user']       := AllTrim(UsrRetName(RetCodUsr()))
    oRest:SetPath('/login')
    oRest:SetPostParams(oBody:toJson())
    if ::setStatus((oRest:Post(::getHeader(.F., .T.))), "Login do User: " + oBody['user'] + "Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if !empty(oResp:GetNames())
            if ValType(oResp:GetJsonObject('data')) <> 'U'
                cApiTkn := oResp['data']['api_tkn']
            endif
        endif
        FreeObj(oResp)
        if ::setStatus(!empty(cApiTkn), "Token da API não Encontrado"):isOk()
            ::setApiTkn(cApiTkn)
        endif
    endif
    FreeObj(oBody)
    FreeObj(oRest)
    ::genLog('Login')
return(self)

method setApiTkn(cTkn) class ctrlCbcBudget
    default cTkn := ""
    ::aApiToken := {cTkn, Time()}
return(self)

method getApiTkn() class ctrlCbcBudget
    local cTkn := ""
    if !empty(::aApiToken)
        if vldExpire(::aApiToken[02], self)
            cTkn := ::aApiToken[01]
        endif
    else
        if ::login():isOk()
            cTkn := ::getApiTkn()
        endif
    endif
return(cTkn)

method listVigencias() class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local nX        := 0
    local aVigencia := {}
    
    oRest:SetPath('/budget/vigencia_lista')
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Lista Vigencias - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) == 'A'
            for nX := 1 to len(oResp['data'])
                aAdd(aVigencia, oResp['data'][nX]['vigencia'])
            next nX
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('ListaVigencias')
return(aVigencia)

method vigencia() class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local cVigencia := {}
    
    oRest:SetPath('/budget/vigencia_atual')
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Vigencia Atual - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) <> 'U'
            cVigencia := oResp['data']
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('Vigencia Atual')
return(cVigencia)

method listSld(cVigencia) class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local nX        := 0
    local aLista    := {}
    default cVigencia := ::vigencia()

    oRest:SetPath('/budget/classe/' + AllTrim(cVigencia))
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Lista Saldos - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) == 'A'
            for nX := 1 to len(oResp:GetJsonObject('data'))
                aAdd(aLista, {  oResp['data']["id"],;
                                oResp['data']["classe"],;
                                oResp['data']["descricao"],;
                                oResp['data']["vigencia"],;
                                oResp['data']["inicial"],;
                                oResp['data']["saldo"]})
            next nX
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('Lista Saldos')
return(aLista)

method listBudgets() class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local nX        := 0
    local aLista    := {}

    oRest:SetPath('/budget')
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Lista Budgets - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) == 'A'
            for nX := 1 to len(oResp:GetJsonObject('data'))
                aAdd(aLista, {  oResp['data']["id"],;
                                oResp['data']["classe"],;
                                oResp['data']["descricao"],;
                                oResp['data']["vigencia"],;
                                oResp['data']["inicial"],;
                                oResp['data']["createdAt"],;
                                oResp['data']["updateAt"]})
            next nX
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('Lista Budgets')
return(aLista)

method budgetSld(cVigencia, cBudget) class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local nSaldo    := 0
    default cVigencia := ::vigencia()
    default cBudget   := ""

    oRest:SetPath('/budget/saldo/' + AllTrim(cBudget) + "/" + AllTrim(cVigencia))
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Saldo Budget - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) <> 'U'
            nSaldo := oResp['data']
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('Saldo Budget')
return(nSaldo)

method addBudget(aBudgets) class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oBody     := JsonObject():new()
    local oJson     := nil
    local nX        := 0
    local aLista    := {}
    local cVigencia := ::vigencia()

    for nX := 1 to len(aBudgets)
        oJson     := JsonObject():new()
        oJson["classe"]         := aBudgets[nX,01]
        oJson["descricao"]      := aBudgets[nX,02]
        oJson["vigencia"]       := cVigencia
        oJson["saldo_inicial"]  := 0
        aAdd(aLista, oJson)
        FreeObj(oJson)
    next nX
    oBody['classes'] = aLista
    oRest:SetPath('/budget/add/')
    oRest:SetPostParams(oBody:toJson())
    ::setStatus((oRest:Post(::getHeader(.T.))), "Adiciona Budget - Err: " + oRest:GetLastError()):isOk()
    FreeObj(oRest)
    ::genLog('Adiciona Budget')
return(self)

method movimento(aMovimentos) class ctrlCbcBudget
    local oRest		:= nil
    local oBody     := JsonObject():new()
    local oJson     := nil
    local nX        := 0
    local aLista    := {}
    local cFilaURL  := Alltrim(GetNewPar("ZZ_BDGFAPI", "http://192.168.1.217:3057"))
    default cVigencia := ::vigencia()

    if empty(cFilaURL)
        oRest := FWRest():New(::getUrl())
    else
        oRest := FWRest():New(cFilaURL)
    endif

    for nX := 1 to len(aMovimentos)
        oJson                   := JsonObject():new()
        oJson["tipo"]           := aMovimentos[nX,01]
        oJson["tipo_origem"]    := aMovimentos[nX,02]
        oJson["origem"]         := aMovimentos[nX,03]
        oJson["budgetId"]       := getBudgetId(aMovimentos[nX,04], self)
        oJson["valor"]          := aMovimentos[nX,05]
        aAdd(aLista, oJson)
        FreeObj(oJson)
    next nX
    oBody['movimentos'] = aLista
    oRest:SetPath('/add')
    oRest:SetPostParams(oBody:toJson())
    ::setStatus((oRest:Post(::getHeader(.T.))), "Movimento - Err: " + oRest:GetLastError()):isOk()
    FreeObj(oRest)
    ::genLog('Movimento')
return(self)

method libMov(cVigencia, cBudget, nValor) class ctrlCbcBudget
    local oRest		:= FWRest():New(::getUrl())
    local oResp     := nil
    local aRet      := {.F., 0}
    default cVigencia := ::vigencia()
    default cBudget   := ""
    default nValor    := 0

    oRest:SetPath('/budget/saldo/' + AllTrim(cBudget) + "/" + AllTrim(cVigencia) + "/" + cValToChar(nValor))
    if ::setStatus((oRest:Get(::getHeader(.T.))), "Lib.Movimento - Err: " + oRest:GetLastError()):isOk()
        oResp := JsonObject():new()
        oResp:fromJson(oRest:GetResult())
        if ValType(oResp:GetJsonObject('data')) <> 'U'
            aRet[1] := oResp['tem']
            aRet[2] := oResp['data']
        endif
        FreeObj(oResp)
    endif
    FreeObj(oRest)
    ::genLog('Lib.Movimento')
return(aRet)

static function vldExpire(cTimeIni, oCtrl)
    local cExpTime  := "04:00:00"
    local cDifTime  := ElapTime( cTimeIni, Time() ) // Resultado: "01:15:15"
    local lRet      := .F.
    
    if !(lRet := (cDifTime < cExpTime))
        lRet := oCtrl:login():isOk()
    endif
return(lRet)

static function getBudgetId(cBudget, oCtrl)
    local nBdgId    := 0
    local aBudgets  := oCtrl:listBudgets()

    nPosi := aScan(aBudgets, {|x| x[02] == cBudget})
    if nPosi > 0
        nBdgId := aBudgets[nPosi, 01]
    endif
return(nBdgId)
