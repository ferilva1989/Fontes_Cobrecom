#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcEventService

Serviços referentes aos Eventos do Portal Cobrecom
    
@author victorhugo
@since 28/02/2016
/*/
class CbcEventService from CbcService	
	
	method newCbcEventService() constructor
	
	method check() 
	
endClass


/*/{Protheus.doc} newCbcEventService

Construtor
    
@author victorhugo
@since 28/02/2016
/*/
method newCbcEventService() class CbcEventService
return self


/*/{Protheus.doc} check

Processa as ações relacionadas ao Evento
	
@author victorhugo
@since 28/02/2016

@param oEvent, CbcEvent, Evento do Portal Cobrecom
/*/
method check(oEvent) class CbcEventService
	
	sendNotifications(oEvent) 

return

/**
 * Envia as Notificações do Evento
 */
static function sendNotifications(oEvent)
	
	local oSrvNotif := CbcNotificationService():newCbcNotificationService()
	
	checkUsersToNotify(@oEvent)	
	
	oSrvNotif:create(oEvent) 
	
return


/**
 * Verifica quais usuários receberão as Notificações
 */
static function checkUsersToNotify(oEvent)
	
	local cQuery 		:= ""
	local cUserId		:= ""
	local lSendEmail	:= .F.
	local aNotifyUsers  := oEvent:getNotifyUsers()
	local aEmailUsers   := oEvent:getEmailUsers()
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT ZP1_CODIGO USERID, ZP8_EMAIL SEND_EMAIL "
	cQuery += " FROM %ZP8.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += "  		%ZP1.XFILIAL% AND ZP1_GRUPO = ZP8_GRUPO AND %ZP1.NOTDEL% "
	cQuery += " WHERE %ZP8.XFILIAL% AND ZP8_EVENTO = '"+oEvent:getId()+"' AND %ZP8.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		cUserId 	:= oSql:getValue("USERID")
		lSendEmail	:= oSql:getValue("SEND_EMAIL == 'S'") 
	
		if (oEvent:getId() $ EVENT_PORTAL_LOGIN+","+EVENT_PORTAL_LOGOUT) .and. (cUserId == oEvent:getFromUser())
			oSql:skip()
			loop
		endIf
	
		if (aScan(aNotifyUsers, cUserId) == 0)
			aAdd(aNotifyUsers, cUserId)
		endIf
		
		if lSendEmail .and. (aScan(aEmailUsers, cUserId) == 0)
			aAdd(aEmailUsers, cUserId)
		endIf
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oEvent:setNotifyUsers(aNotifyUsers)
	oEvent:setEmailUsers(aEmailUsers)		
	
return



