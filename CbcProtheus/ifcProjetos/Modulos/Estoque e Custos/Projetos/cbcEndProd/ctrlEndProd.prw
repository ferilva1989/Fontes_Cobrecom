#include 'Totvs.ch'

class ctrlEndProd
    data lOk
    data cMsgErr
    data lShowErr
    data cUrlApi
    data aHeader

    method newctrlEndProd()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getHeader()
    method getUrl()
    method getEnder()
    method getinEnder()
    method listaInEnder()
    method listaEnder()
    method detUnMov()
    method addEnder()
    method altEnder()
    method bloqEnder()
endClass

method newctrlEndProd(lShowErr) class ctrlEndProd
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::cUrlApi   := Alltrim(GetNewPar("ZZ_VERTPRD", "http://192.168.1.220:3294"))
    ::aHeader   := {}
    aadd(::aHeader, 'Content-Type: application/json')
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class ctrlEndProd
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::cMsgErr   := '[ctrlEndProd] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - ctrlEndProd')
            endif
        endif
    endif
return(self)

method isOk() class ctrlEndProd
return(::lOk)

method getErrMsg() class ctrlEndProd
return(::cMsgErr)

method showErr() class ctrlEndProd
return(::lShowErr)

method getHeader() class ctrlEndProd
return(::aHeader)

method getUrl() class ctrlEndProd
return(::cUrlApi)

method getEnder(aWhere) class ctrlEndProd
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

method getinEnder(aWhere) class ctrlEndProd
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
        oRest:SetPath('/movimentos?filter=' + AllTrim(cParams))
    else
        oRest:SetPath('/movimentos')
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

method listaInEnder() class ctrlEndProd
    local oJson     := JsonObject():new()
    local aLista    := {}
    local nX        := 0
    local nPosi     := 0
    local aWhere    := {}

    aAdd(aWhere,{"removeu", nil})
    oJson := ::getinEnder(aWhere)
    if (len(oJson) > 0)
        for nX := 1 to len(oJson)
            nPosi := aScan(aLista, {|x| x[1] == AllTrim(oJson[nX]['onde'])})
            if nPosi > 0
                aAdd(aLista[nPosi, 02], {AllTrim(oJson[nX]['oque']), AllTrim(oJson[nX]['quem']), oJson[nX]['inventario']})
            else
                aAdd(aLista, {AllTrim(oJson[nX]['onde']), {{AllTrim(oJson[nX]['oque']), AllTrim(oJson[nX]['quem']), oJson[nX]['inventario']}}})
            endif
        next nX
        for nX := 1 to len(aLista)
            aSort(aLista[nX,02],,,{|x,y| x[01]<y[01]})
        next nX
        aSort(aLista,,,{|x,y| x[01]<y[01]})
    endif
    FreeObj(oJson)
return(aLista)

method listaEnder() class ctrlEndProd
    local oJson     := JsonObject():new()
    local aLista    := {}
    local nX        := 0
    local aWhere    := {}

    aAdd(aWhere,{"status", .T.})
    oJson := ::getEnder(aWhere)
    if (len(oJson) > 0)
        for nX := 1 to len(oJson)
            aAdd(aLista, {AllTrim(oJson[nX]['nome']), oJson[nX]['nivel']})
        next nX
        aSort(aLista,,,{|x,y| x[01]<y[01]})
    endif
    FreeObj(oJson)
return(aLista)

method detUnMov(cUnMov) class ctrlEndProd
    local oJson     := JsonObject():new()
    local oSql 	    := LibSqlObj():newLibSqlObj()

    oSql:newAlias(u_qryEndProd('D', cUnMov))
    if oSql:hasRecords()
        oSql:goTop()
        oJson['Unimov']     := oSql:getValue("UNIMOV")
        oJson['Produto']    := AllTrim(oSql:getValue("PROD"))
        oJson['Descricao']  := AllTrim(oSql:getValue("DESCRI"))
        oJson['Quant']      := oSql:getValue("QTD")
        oJson['Data']       := oSql:getValue("ODATA")
        oJson['Hora']       := oSql:getValue("OHORA")
        oJson['Lote']       := AllTrim(oSql:getValue("LOTE"))
    endif
    oSql:close()
    FreeObj(oSql)
return(oJson)

method addEnder(cCode, lNivel, nId) class ctrlEndProd
    local oRest		    := FWRest():New(::getUrl())
    local oEnder        := JsonObject():new()
    local oResp         := nil
    local aWhere        := {}
    default nId         := 0
    default cCode       := ""
    default lNivel      := .T.

    if(::setStatus(!empty(cCode), 'Dados de Endereço não informados!'):isOk())
        aAdd(aWhere,{"nome", cCode})
        oResp := ::getEnder(aWhere)
        if ::isOk()
            //if (::setStatus(!(len(oResp) > 0), 'Endereço já cadastrado!'):isOk())
            if (!(len(oResp) > 0))
                FreeObj(oResp)
                oEnder["nome"]   := cCode
                oEnder["status"] := .T.
                oEnder["nivel"]  := lNivel
                oRest:SetPath('/enderecos')
                oRest:SetPostParams(oEnder:toJson())
                if !(oRest:Post(::getHeader()))
                    ::setStatus(.F., oRest:GetLastError())
                else
                    oResp := JsonObject():new()
                    oResp:fromJson(oRest:GetResult())
                    if !empty(oResp:GetNames())
                        nId := oResp["id"]
                    endif
                    FreeObj(oResp)
                endif
            else
                if !(::bloqEnder(Upper(AllTrim(cCode)), .T.):isOk())
                    ::setStatus(.F., 'Endereço já cadastrado!')
                endif
            endif
        endif
    endif
    FreeObj(oRest)
    FreeObj(oEnder)
return(self)

method altEnder(cEnder, oAlt) class ctrlEndProd
    local oResp     := JsonObject():new()
    local cHdrRet   := ""
    local cErrMsg   := ""
    local cRet      := ""
    local cId       := 0
    local aWhere    := {}
    default oAlt    := JsonObject():new()

    if(::setStatus((!empty(oAlt:GetNames()) .and. !empty(cEnder)), 'Dados não informados!'):isOk())
        aAdd(aWhere,{"nome", cEnder})
        oResp := ::getEnder(aWhere)
        if ::isOk()
            if (::setStatus((len(oResp) > 0), 'Endereço não encontrado!'):isOk())
                cId := cValToChar(oResp[1]['id'])
                cRet := HTTPQuote( ::getUrl()+'/enderecos/'+cId, "PATCH", , oAlt:ToJson() /*cPOSTParms*/, 120, ::getHeader(), @cHdrRet )
                if !empty(cRet)
                    HttpGetStatus(@cErrMsg)
                    ::setStatus(.F., cValToChar(cErrMsg))
                endif
            endif
        endif
    endif
    FreeObj(oResp)
return(self)

method bloqEnder(cEnder, lDo) class ctrlEndProd
    local oJson     := JsonObject():new()
    local aWhere    := {}
    default lDo     := .F.

    aAdd(aWhere,{"removeu", nil})
    aAdd(aWhere,{"onde", cEnder})
    oJson := ::getinEnder(aWhere)
    if ::isOk()
        if (::setStatus(!(len(oJson) > 0),'Endereço possui unimovs endereçadas!'):isOk())
            FreeObj(oJson)
            oJson := JsonObject():new()
            oJson["status"] := lDo
            ::altEnder(cEnder, oJson)
        endif
    endif
    FreeObj(oJson)
return(self)

/*TESTE ZONE*/
user function ztstEProd()
    local oCtrl       := ctrlEndProd():newctrlEndProd()
    local cCode       := 'L001A02'
    
    if (oCtrl:bloqEnder(cCode):isOk())
        MsgInfo('Sucesso','Sucesso')
    else
        Alert(oCtrl:getErrMsg())
    endif
return(nil)
