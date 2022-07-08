#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful cbcApiCobi DESCRIPTION "API Rest do COBI"
	wsMethod GET description "Rotas GET: /lista /find "
end wsRestful

wsMethod GET wsService cbcApiCobi
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
    local cRoute	:= ""

	cRoute := oRequest:getRoute()
	if (cRoute == "lista")
		lista(@self, @oRes)
	elseif (cRoute == "acha")
		acha(@self, @oRes)
	else
		oRes["status"] 			:= .F.
        oRes["data"]			:= '{}'
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function lista(oWs, oRes)
	local lRet			:= .T.
	local cMsgErr		:= ''
	local cJson         := '{}'

    cJson := pegaRepres()
    if !(lRet := !empty(cJson))
        cMsgErr := 'Nao localizado ou bloqueado!'
    endif

	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
    oRes["data"]			:= cJson
return(nil)

static function pegaRepres()
    local oSql      := LibSqlObj():newLibSqlObj()
    local aDados    := {}
    local oJson     := JsonObject():new()

    oSql:newAlias(qryfind())
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            aAdd(aDados, oSql:getValue("WHATS"))
            oSql:skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
    if !empty(aDados)
        oJson['WHATSAPP'] := aDados
    endif
return(oJson:ToJson())

static function acha(oWs, oRes)
    local lRet			:= .T.
	local cMsgErr		:= ''
	local cNum			:= ''

	if (Len(oWs:aURLParms) >= 2)
		cNum := oWs:aURLParms[2]
	endif

	if Empty(cNum)
		cMsgErr := "Forneca o numero do whatsapp!"
		lRet    := .F.
	else
		if !(lRet := localiza(cNum))
			cMsgErr := 'Nao localizado ou bloqueado!'
		endif
	endIf
    
    //cMsgErr := oWs:aURLParms[2]

	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsgErr
    oRes["data"]			:= '{}'
return(nil)

static function localiza(cNum)
    local lRet := .F.
    local oSql := LibSqlObj():newLibSqlObj()
    
    oSql:newAlias(qryfind(cNum))
    lRet := oSql:hasRecords()
    oSql:Close()
    FreeObj(oSql)
return(lRet)

static function qryfind(cNum)
    local cQry      := ""
    default cNum    := ""

    cQry += " SELECT SA3.A3_ZWHTAPP AS [WHATS] "
    cQry += " FROM SA3010 SA3 "
    cQry += " WHERE "
    if !empty(cNum)
        cQry += " SA3.A3_ZWHTAPP = '" + cNum + "'"
    else
        cQry += " SA3.A3_ZWHTAPP <> '' "
    endif
    cQry += " AND SA3.A3_ZUSECOB = '2' "
    cQry += " AND SA3.A3_MSBLQL = '2' "
    cQry += " AND SA3.A3_DEMISS = '' "
    cQry += " AND SA3.D_E_L_E_T_ = '' "
return(cQry)
