#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful cbcApiCred DESCRIPTION "API Rest para consulta de dados para aprovacao de credito"
	wsMethod GET description "Rotas GET: /crederp/:cCgc "
end wsRestful

wsMethod GET wsService cbcApiCred
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
    local cRoute	:= ""

	cRoute := oRequest:getRoute()

	if (cRoute == "crederp")
		crederp(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function crederp(oWs, oRes)
    Local oCbcCredErp := Nil
    Local oJson		  := JsonObject():new()
    Local cCgc        := ''
    Local cMsg		  := ''
    Local lRet		  := .F.

	oWs:SetContentType("application/json")
	
    if (Len(oWs:aURLParms) < 2)
		lRet    := .F.
		cMsg	:= "CNPJ Vazio"
    else
        cCgc := oWs:aURLParms[2]
        oCbcCredErp := cbcCredErp():newccbcCredErp(cCgc)
        if !oCbcCredErp:vldCGC(cCgc)
            lRet    := .F.
		    cMsg	:= "CNPJ Invalido"
        else
            oJson := oCbcCredErp:getDadosJson(cCgc)
            oRes["data"] := oJson
            lRet := .T.
        endIf
    endif
    oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsg
return(.T.)

