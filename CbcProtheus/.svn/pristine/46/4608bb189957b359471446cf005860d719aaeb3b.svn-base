#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


wsRestful CbcBoletosApi DESCRIPTION "API Rest para obter titulos e boletos Portal Cobrecom"
	wsMethod POST description "Rotas POST: /gettitle /boleto"	
end wsRestful

wsMethod POST wsService CbcBoletosApi
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oRes		:= JsonObject():new()
	local lOk		:= .F.
	local cRoute	:= ''
	
	cRoute := oRequest:getRoute()
	
	if(cRoute == "boleto")
		lOk := genBoleto(@self, @oRes)
	elseif(cRoute == "gettitle")
		lOk := getTitle(@self, @oRes)
    else
        ::SetStatus(500)
	    ::SetResponse("Rota invalida")
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(lOk)

static function genBoleto(oWs, oRes)	
    local lOk		:= .F.	
	Local lLib		:= SuperGetMv("ZZ_LIBBOL1",,.F.)		
    local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oBody     := JsonObject():new()
	local cMsgErr   := ''
	local aData     := {}
	local aBol      := {}
	local oJwt		:= LibJwtObj():newLibJwtObj()
	local cToken	:= oWs:getHeader("auth-token")
	local cData		:= oJwt:decode(cToken, "!token#p@$$w0rd")
	Local oData		:= JsonObject():new()
	
	oWs:SetContentType("application/json")

    if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oData:FromJson(cData)
	if lLib .Or. oData["userId"] $ SuperGetMv("ZZ_LIBBOL",,"000001")
		oBody:fromJson(oWs:getContent())
		if !empty(oBody["idcli"]) .and. !empty(oBody["idtitulo"])
			aBol := u_zxBolPort(oBody["idcli"], oBody["idtitulo"])
			if (lOk := aBol[1])
				aAdd(aData, aBol[2])
			else
				cMsgErr	:= 'Boleto nao localizado! Redirecionando ao banco!'
			endif
		else
			lOk	:= .F.
			cMsgErr	:= 'Chave de pesquisa vazia!'
		endif		
		oRes["status"]	:= lOk
		oRes["msg"]		:= cMsgErr
		oRes["data"]	:= aData
	else
		lOk             := .T.
		oRes["status"]  := .F.
		oRes["msg"]     := 'Usuario bloqueado para emissao boleto'	
	endIf
	
	FreeObj(oBody)
return(lOk)

static function getTitle(oWs, oRes)				
	local lOk		:= .F.
	Local lLib		:= SuperGetMv("ZZ_LIBBOL1",,.F.)
    local oAuthSrv	:= CbcAuthService():newCbcAuthService()
    local oBody		:= JsonObject():new()
	local oJsBol 	:= JsonObject():new()
	local oJwt		:= LibJwtObj():newLibJwtObj()
	local cToken	:= oWs:getHeader("auth-token")
	local cData		:= oJwt:decode(cToken, "!token#p@$$w0rd")
	Local oData		:= JsonObject():new()
	Local oStatic   := IfcXFun():newIfcXFun()

	oWs:SetContentType("application/json")

    if !oAuthSrv:validToken(oWs)
		return .F.
	endIf

	oData:FromJson(cData)
	if  lLib .Or. oData["userId"] $ SuperGetMv("ZZ_LIBBOL",,"000001")
		oBody:fromJson(oWs:getContent())
		if !Empty(oBody["idcli"]) .and. !Empty(oBody["idtitulo"])	
			if !empty(cQry 	:= oStatic:sP(2):callStatic('qryBoletos', 'qryGetTit', oBody["idcli"], oBody["idtitulo"]))
				oJsBol 		:= u_cbcQRYexec(cQry)
			endif
			lOk             := .T.
			oRes["status"]  := .T.
			oRes["msg"]     := ''	
			oRes["data"]    := oJsBol
		endif
	else
		lOk             := .T.
		oRes["status"]  := .F.
		oRes["msg"]     := 'Usuario bloqueado para emissao boleto'	
	endIf

	FreeObj(oJsBol)
	FreeObj(oBody)
return(lOk)
