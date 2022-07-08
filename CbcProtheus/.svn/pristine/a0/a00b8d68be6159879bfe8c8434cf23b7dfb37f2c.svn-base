#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcNotificationWs

Web Service de Manutenção de Notificações do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcNotificationWs description "Web Service de Manutenção de Notificações do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcnotificationws.apw"
	
	wsData requestNotificationsByUser as WsCbcRequestNotificationsByUser		
	wsData responseNotificationsByUser as WsCbcResponseNotificationsByUser
	wsData requestSetNotificationDisplayed as WsCbcRequestSetNotificationDisplayed
	wsData responseSetNotificationDisplayed as WsCbcResponseSetNotificationDisplayed
	
	wsMethod findNotificationsByUser description "Retorna as Notificações de um Usuário"
	wsMethod setNotificationDisplayed description "Define uma Notificação como Visualizada"
	
endWsService


/*/{Protheus.doc} findNotificationsByUser

Retorna as Notificações de um Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findNotificationsByUser wsReceive requestNotificationsByUser wsSend responseNotificationsByUser wsService CbcNotificationWs
	
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oRequest 			:= ::requestNotificationsByUser
	local oService			:= CbcNotificationService():newCbcNotificationService()
	local nNotDisplayed		:= oService:getNotDisplayedCount(oRequest:userId)
	local aNotifications	:= oService:findByUser(oRequest:userId, oRequest:showDisplayed, oRequest:lastId, oRequest:maxRegs, oRequest:setDisplayed)
	
	if (Len(aNotifications) > 0)
		oStatus:success := .T.
		oStatus:message := "Notificações fornecidas com sucesso" 
		setWsNotifications(@aNotifications) 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhuma notificação encontrada"		 
	endIf
	
	::responseNotificationsByUser:status 		    := oStatus
	::responseNotificationsByUser:notDisplayedCount := nNotDisplayed
	::responseNotificationsByUser:notifications     := aNotifications 
	
return .T.

/**
 * Converte as Notificações para o formato de Web Service
 */
static function setWsNotifications(aNotifications)
	
	local nI	   	:= 0
	local aWsNotif 	:= {}
	
	for nI := 1 to Len(aNotifications)		
		aAdd(aWsNotif, aNotifications[nI]:toWsObject())		
	next nI
	
	aNotifications := aClone(aWsNotif) 
	
return


/*/{Protheus.doc} setNotificationDisplayed

Define uma Notificação como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod setNotificationDisplayed wsReceive requestSetNotificationDisplayed wsSend responseSetNotificationDisplayed wsService CbcNotificationWs
	
	local oWsUser			:= nil
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oRequest 			:= ::requestSetNotificationDisplayed
	local oService			:= CbcNotificationService():newCbcNotificationService()
	
	if oService:setDisplayed(oRequest:notificationId, oRequest:userId)
		oStatus:success := .T.
		oStatus:message := "Notificação "+oRequest:notificationId+" definida como visualizada para o usuário "+oRequest:userId 
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()		 
	endIf
	
	::responseSetNotificationDisplayed:status := oStatus
	
return .T.


