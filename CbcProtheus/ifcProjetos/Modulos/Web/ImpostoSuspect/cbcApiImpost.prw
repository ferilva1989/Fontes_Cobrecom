#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful cbcApiImpost DESCRIPTION "API Rest de Calculo de Imposto"
	wsMethod GET description "Rotas GET: /calcimp "
end wsRestful

wsMethod GET wsService cbcApiImpost
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
    local cRoute	:= ""

	cRoute := oRequest:getRoute()

	if (cRoute == "calcimp")
		calcImp(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function calcImp(oWs, oRes)
	local oBody		    := JsonObject():new()
    local aRet			:= {}
	local lRet			:= .F.
	local cMsg			:= ''
	local cJson			:= '{}'

    //Tipo do conteudo para retorno
	oWs:SetContentType("application/json")
	
    oBody:fromJson(oWs:getContent())
    if empty(oBody:GetNames())
		lRet    := .F.
		cMsg	:= "Sem dados para calculo!"
    else
		aRet := u_cbcCalcImpost(oReq)
		lRet := aRet[01]
		if lRet
			cJson := aRet[02]
		else
			cMsg := aRet[02]
		endif
    endif
	oRes["status"] 			:= lRet
	oRes["msg"]				:= cMsg
	oRes["data"]			:= cJson
return(.T.)

