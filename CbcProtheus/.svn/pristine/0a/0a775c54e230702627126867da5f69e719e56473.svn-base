#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful cbcSucApi DESCRIPTION "API Rest de Sucata"
	wsMethod GET description "Rotas GET: /operadores /operador "
end wsRestful

wsMethod GET wsService cbcSucApi
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local cRoute	:= ""
	local oRes		:= JsonObject():new()

	cRoute := oRequest:getRoute()

	if (cRoute == "operadores")
	    multiOper(@self, @oRes)
    elseif (cRoute == "operador")
	    singleOper(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function multiOper(oWs, oRes)
	local oJson         := nil
    local oRet          := nil
    local lRet			:= .T.
	local cMsgErr		:= ''
    local cData         := ''
	local aOperadores   := u_srvSucPCF('U')
    local aItens        := {}
    local nX            := 0
	
    if empty(aOperadores)
        lRet    := .F.
        cMsgErr := "Nenhum operador localizo"
    else
        for nX := 1 to len(aOperadores)
            oJson := JsonObject():new()
            oJson['Cracha'] := aOperadores[nX,01]
            oJson['Nome'] := aOperadores[nX,02]
            aAdd(aItens, oJson)
            FreeObj(oJson)
        next nX
        oRet := JsonObject():new()
        oRet['Operadores'] := aItens
        cData := oRet:ToJson()
        FreeObj(oRet)
    endif
	oRes["status"]  := lRet
	oRes["msg"]     := cMsgErr
    oRes["data"]	:= cData
return(nil)

static function singleOper(oWs, oRes)
    local lRet			:= .T.
	local cMsgErr		:= ''
	local aOperadores   := u_srvSucPCF('U')
    local nX            := 0
    local cCracha       := ""
	local cData         := ""
    
    if (Len(oWs:aURLParms) >= 2)
        cCracha := AllTrim(oWs:aURLParms[2])
    endif
    if empty(cCracha)
        lRet    := .F.
        cMsgErr := "Nenhum cracha informado"
    else
        if empty(aOperadores)  
            lRet    := .F.
            cMsgErr := "Nenhum operador localizo"
        else
            nX := AScan(aOperadores, {|x| AllTrim(x[1]) == AllTrim(cCracha)})
            if (lRet := (nX > 0))
                cData := AllTrim(aOperadores[nX, 02])
            endif
        endif
    endif
	oRes["status"]  := lRet
	oRes["msg"]     := cMsgErr
    oRes["data"]	:= cData
return(nil)
