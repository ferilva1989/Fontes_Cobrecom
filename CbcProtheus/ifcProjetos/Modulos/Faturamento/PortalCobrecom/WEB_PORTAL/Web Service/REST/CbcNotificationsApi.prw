#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcNotificationsApi

API Rest para manutenção de notificações do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcNotificationsApi DESCRIPTION "API Rest para manutenção de notificações do Portal Cobrecom"
		
	wsMethod POST description "Rotas POST: /find"
	wsMethod PUT description "Rotas PUT: /set-displayed"
	
end wsRestful


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcNotificationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "find")
		
		lOk := find(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} PUT

Rotas PUT
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod PUT wsService CbcNotificationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "set-displayed")
		
		lOk := setDisplayed(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna as Notificações de um Usuário
 */
static function find(oWs)

	local cUserId     	 := ""
	local oData			 := nil
	local aNotifications := {}
	local oBody			 := JsonObject():new()
	local oAuthSrv		 := CbcAuthService():newCbcAuthService()
	local oService		 := CbcNotificationService():newCbcNotificationService()
	local oResponse 	 := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	aNotifications := oService:findByUser(cUserId, oBody["showDisplayed"], oBody["lastId"], oBody["maxRegs"], oBody["setDisplayed"])		
		
	oData					   := JsonObject():new()
	oData["notDisplayedCount"] := oService:getNotDisplayedCount(cUserId)
	oData["notifications"]	   := getJsNotifications(aNotifications)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Converte as Notificações para JSON
 */
static function getJsNotifications(aNotifications)
	
	local nI	   := 0
	local aJsNotif := {}
	
	for nI := 1 to Len(aNotifications)
		aAdd(aJsNotif, aNotifications[nI]:toJsonObject())
	next nI 
	
return aJsNotif

/**
 * Define uma notificação com visualizada
 */
static function setDisplayed(oWs)
	
	local lOk		:= .F.
	local cUserId   := ""
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcNotificationService():newCbcNotificationService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oService:setDisplayed(oBody["notificationId"], cUserId)
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

