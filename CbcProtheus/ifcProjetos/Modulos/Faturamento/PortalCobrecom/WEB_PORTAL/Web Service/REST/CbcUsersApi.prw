#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcUsersApi

API Rest para manutenção de usuários do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcUsersApi DESCRIPTION "API Rest para manutenção de usuários do Portal Cobrecom"
		
	wsMethod GET description "Rotas GET: /users/:id"
	wsMethod POST description "Rotas POST: /create  /accept-use-terms"
	wsMethod PUT description "Rotas PUT: /update"
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcUsersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "users")
		
		lOk := getById(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcUsersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "create")
		
		lOk := create(self)
				
	elseIf (cRoute == "accept-use-terms")
		
		lOk := acceptUseTerms(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} PUT

Rotas PUT
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod PUT wsService CbcUsersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "update")
		
		lOk := update(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna usuários pelo ID
 */
static function getById(oWs)
		
	local cId		:= ""			
	local oUser		:= nil
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oSrvUser	:= CbcUserService():newCbcUserService()	
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cId := oWs:aURLParms[2]
	endIf
	
	if Empty(cId)
		oResponse:badRequest("ID nao fornecido")
		return .F.
	endIf
	
	oUser := oSrvUser:findById(cId)
	
	if oUtils:isNull(oUser)
		oResponse:notFound("ID invalido")
		return .F.
	endIf
	
	oResponse:send(oUser:toJsonString())
	
return .T.

/**
 * Criação de usuários
 */
static function create(oWs)
	
	local lOk		:= .F.
	local cUserId	:= ""
	local oUser	   	:= CbcUser():newCbcUser() 
	local oSrvUser  := CbcUserService():newCbcUserService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	oUser:fromJsonObject(oWs:getContent())
	
	if oSrvUser:create(oUser, @cUserId)
		lOk := .T.
		oSrvUser:checkEvent(EVENT_USER_CREATE, oUser, "Usuário " + AllTrim(oUser:getName()) + " criado via Portal")
		oResponse:send('{ "id": "' + cUserId + '" }')
	else
		oResponse:badRequest(oSrvUser:getErrorMessage()) 		  		
	endIf
	
return lOk

/**
 * Atualização de usuários
 */
static function update(oWs)
	
	local lOk	    := .F.	
	local oUser	   	:= CbcUser():newCbcUser()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()	
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)	
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oUser:fromJsonObject(oWs:getContent())
	
	if oSrvUser:update(oUser)
		lOk := .T.
		oSrvUser:checkEvent(EVENT_USER_UPDATE, oUser, "Usuário " + AllTrim(oUser:getName()) + " atualizado via Portal")
		oResponse:success()
	else
		oResponse:badRequest(oSrvUser:getErrorMessage()) 		  		
	endIf
	
return lOk

/**
 * Controle de Aceite dos Termos de Uso
 */
static function acceptUseTerms(oWs)
			
	local lOk	    := .F.	
	local oBody		:= JsonObject():new()
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)	
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oSrvUser:acceptUseTerms(oBody["userId"], oBody["accepted"])
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oSrvUser:getErrorMessage()) 		  		
	endIf
	
return lOk

