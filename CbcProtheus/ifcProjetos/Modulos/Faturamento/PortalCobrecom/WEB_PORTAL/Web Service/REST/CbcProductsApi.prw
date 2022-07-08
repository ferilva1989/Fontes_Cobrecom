#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcProductsApi

API Rest para manutenção dos produtos do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcProductsApi DESCRIPTION "API Rest para manutenção dos produtos do Portal Cobrecom"
	
	wsMethod GET description "Rotas GET:  /products/:code  /properties/:property  /colors/:name/:bitola"			
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcProductsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "products")
		
		lOk := getProductByCode(self)
		
	elseIf (cRoute == "properties")	
		
		lOk := getProperties(self)
	
	elseIf (cRoute == "colors")	
		
		lOk := getColors(self)
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna um Produto pelo Código
 */		
static function getProductByCode(oWs)
	
	local lOk		   := .F.
	local cCode		   := ""
	local oProduct     := nil
	local oUtils	   := LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oService	   := CbcProductService():newCbcProductService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cCode := oWs:aURLParms[2]
	endIf
	
	if Empty(cCode)
		oResponse:badRequest("Informe o codigo do produto")
		return .F.
	endIf
	
	oProduct := oService:findByCode(cCode)
	
	if oUtils:isNull(oProduct)
		oResponse:notFound()
	else
		lOk := .T.
		oResponse:send(oProduct:toJsonString())
	endIf	

return lOk

/**
 * Retorna as Propriedades dos Produtos
 */		
static function getProperties(oWs)
	
	local cUserId	   := ""
	local cProperty	   := ""
	local lUsrEsp	   := .F.
	local aProperties  := {}
	local oData		   := JsonObject():new()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oService	   := Nil
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cProperty := oWs:aURLParms[2]
	endIf
	
	if Empty(cProperty)
		oResponse:badRequest("Informe a propriedade desejada")
		return .F.
	endIf
	
	lUsrEsp := oSrvUser:usrIsGroup({USER_SPECIAL, USER_ADMINISTRATOR, USER_SUPERVISOR}, cUserId)
	oService := CbcProductService():newCbcProductService(lUsrEsp)
	aProperties 	    := oService:getProperties(cProperty)	
	oData["properties"] := oService:getJsArray(aProperties)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna as Cores dos Produtos de acordo com o Nome e a Bitola
 */		
static function getColors(oWs)
	
	local cName		   := ""
	local cBitola	   := ""
	local aColors	   := {}
	local oData		   := JsonObject():new()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oService	   := CbcProductService():newCbcProductService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cName := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cBitola := oWs:aURLParms[3]
	endIf
	
	if Empty(cName) .or. Empty(cBitola)
		oResponse:badRequest("Informe o nome e a bitola")
		return .F.
	endIf
	
	aColors 	    := oService:getColors(cName, cBitola)	
	oData["colors"] := oService:getJsArray(aColors)
	
	oResponse:send(oData:toJson())

return .T.
