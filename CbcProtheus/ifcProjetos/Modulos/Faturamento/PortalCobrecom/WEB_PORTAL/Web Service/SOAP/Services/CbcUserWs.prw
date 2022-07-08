#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcUserWs

Web Service de Manutenção de Usuários do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcUserWs description "Web Service de Manutenção de Usuários do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcuserws.apw"
	
	wsData requestUserById as WsCbcRequestUserById
	wsData responseUserById as WsCbcResponseUserById
	wsData requestUserByLogin as WsCbcRequestUserByLogin
	wsData responseUserByLogin as WsCbcResponseUserByLogin		
	wsData requestCreateUser as WsCbcRequestCreateUser
	wsData responseCreateUser as WsCbcResponseCreateUser
	wsData requestUpdateUser as WsCbcRequestUpdateUser
	wsData responseUpdateUser as WsCbcResponseUpdateUser
	wsData requestPasswordRecovery as WsCbcRequestPasswordRecovery
	wsData responsePasswordRecovery as WsCbcResponsePasswordRecovery
	wsData requestAcceptUseTerms as WsCbcRequestAcceptUseTerms
	wsData responseAcceptUseTerms as WsCbcResponseAcceptUseTerms
	wsData requestLogout as WsCbcRequestLogout
	wsData responseLogout as WsCbcResponseLogout
	
	wsMethod findUserById description "Retorna um Usuário pelo Código"
	wsMethod findUserByLogin description "Retorna um Usuário pelo Login e Senha"
	wsMethod createUser description "Criação de Usuários do Portal"
	wsMethod updateUser description "Atualização de Usuários do Portal"
	wsMethod passwordRecovery description "Recuperação de Senhas de Usuários do Portal"
	wsMethod acceptUseTerms description "Controle de Aceite dos Termos de Uso do Portal"
	wsMethod logout description "Log-Out de Usuários do Portal"
	
endWsService


/*/{Protheus.doc} findUserById

Retorna um Usuário pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findUserById wsReceive requestUserById wsSend responseUserById wsService CbcUserWs
	
	local oWsUser	:= nil
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestUserById
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(oRequest:id)	
	
	if oUtils:isNull(oUser)
		oStatus:success := .F.
		oStatus:message := "Código inválido" 
	else
		oStatus:success := .T.
		oStatus:message := "Usuário fornecido com sucesso"
		oWsUser			:= oUser:toWsObject()	   		 
	endIf
	
	::responseUserById:status := oStatus
	::responseUserById:user   := oWsUser 
	
return .T.


/*/{Protheus.doc} findUserByLogin

Retorna um Usuário pelo Login e Senha
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findUserByLogin wsReceive requestUserByLogin wsSend responseUserByLogin wsService CbcUserWs
	
	local oWsUser	:= nil
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestUserByLogin
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findByLogin(oRequest:login, oRequest:password)	
	
	if oUtils:isNull(oUser)
		oStatus:success := .F.
		oStatus:message := "Login inválido" 
	else
		if oUser:isBlocked()
			oStatus:success := .F.
			oStatus:message := "Usuário bloqueado"
		else
			oStatus:success 	:= .T.
			oStatus:message 	:= "Usuário fornecido com sucesso"
			oWsUser				:= oUser:toWsObject()
			oWsUser:uploadToken := u_CbcTokenApi()
			checkEvent(EVENT_PORTAL_LOGIN, oUser, "Login realizado pelo usuário "+oUser:getName())
		endIf	   		 
	endIf
	
	::responseUserByLogin:status := oStatus
	::responseUserByLogin:user   := oWsUser 
	
return .T.


/*/{Protheus.doc} createUser

Criação de Usuários do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod createUser wsReceive requestCreateUser wsSend responseCreateUser wsService CbcUserWs
	
	local cUserId	   := "" 
	local oStatus      := WsClassNew("WsCbcResponseStatus")
	local oWsUser      := ::requestCreateUser:user
	local oUser	   	   := CbcUser():newCbcUser() 
	local oSrvUser     := CbcUserService():newCbcUserService()
	
	oUser:fromWsObject(oWsUser)
	
	if oSrvUser:create(oUser, @cUserId)
		oStatus:success := .T.
		oStatus:message := "Usuário criado com sucesso"
		checkEvent(EVENT_USER_CREATE, oUser, "Usuário "+AllTrim(oUser:getName())+" criado via Portal")
	else
		oStatus:success := .F.
		oStatus:message := oSrvUser:getErrorMessage() 		  		
	endIf
	
	::responseCreateUser:status := oStatus
	::responseCreateUser:userId := cUserId
	
return .T.


/*/{Protheus.doc} updateUser

Atualização de Usuários do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod updateUser wsReceive requestUpdateUser wsSend responseUpdateUser wsService CbcUserWs
	
	local oStatus      := WsClassNew("WsCbcResponseStatus")
	local oWsUser      := ::requestUpdateUser:user
	local oUser	   	   := CbcUser():newCbcUser() 
	local oSrvUser     := CbcUserService():newCbcUserService()
	
	oUser:fromWsObject(oWsUser)
	
	if oSrvUser:update(oUser)
		oStatus:success := .T.
		oStatus:message := "Usuário atualizado com sucesso"
		checkEvent(EVENT_USER_UPDATE, oUser, "Usuário "+AllTrim(oUser:getName())+" atualizado via Portal")
	else
		oStatus:success := .F.
		oStatus:message := oSrvUser:getErrorMessage() 		  		
	endIf
	
	::responseUpdateUser:status := oStatus
	
return .T.


/**
 * Verifica os Eventos relacionados aos Usuários
 */
static function checkEvent(cEvent, oUser, cMessage)
	
	local oSql		:= LibSqlObj():newLibSqlObj()
	local oService	:= CbcEventService():newCbcEventService()
	local oEvent	:= CbcEvent():newCbcEvent(cEvent, oUser:getId(), cMessage) 
		
	oService:check(oEvent)  		 
	
	if (cEvent == EVENT_PORTAL_LOGIN)
		oSql:update("ZP1", "ZP1_ULTLOG = '"+DtoS(Date())+"'", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+oUser:getId()+"'") 
	endIf
	
	if (cEvent == EVENT_PORTAL_LOGIN .or. cEvent == EVENT_PORTAL_LOGOUT)
		checkLoginEvents(oEvent) 
	endIf
	
return

/**
 * Verifica os Eventos de Login e Logout
 */
static function checkLoginEvents(oEvent)
	
	local lLoginLogs := GetNewPar("ZZ_LOGNOT", .T.)
	local oNotSrv	 := CbcNotificationService():newCbcNotificationService()
	
	if !lLoginLogs
		return
	endIf
	
	oEvent:setNotifyUsers({""})
	oEvent:setEmailUsers({})
	
	oNotSrv:create(oEvent)
	
return


/*/{Protheus.doc} passwordRecovery

Recuperação de Senhas de Usuários do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod passwordRecovery wsReceive requestPasswordRecovery wsSend responsePasswordRecovery wsService CbcUserWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestPasswordRecovery
	local oSrvUser	:= CbcUserService():newCbcUserService()
	
	if oSrvUser:passwordRecovery(oRequest:email)
		oStatus:success := .T.
		oStatus:message := "Senha enviada com sucesso" 
	else
		oStatus:success := .F.
		oStatus:message := oSrvUser:getErrorMessage()
	endIf
	
	::responsePasswordRecovery:status := oStatus
	
return .T.


/*/{Protheus.doc} acceptUseTerms

Controle de Aceite dos Termos de Uso do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod acceptUseTerms wsReceive requestAcceptUseTerms wsSend responseAcceptUseTerms wsService CbcUserWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestAcceptUseTerms
	local oSrvUser	:= CbcUserService():newCbcUserService()
	
	if oSrvUser:acceptUseTerms(oRequest:userId, oRequest:accepted)
		oStatus:success := .T.
		oStatus:message := "Termos de Uso "+if(oRequest:accepted, "aceitado", "rejeitado")  
	else
		oStatus:success := .F.
		oStatus:message := oSrvUser:getErrorMessage()
	endIf
	
	::responseAcceptUseTerms:status := oStatus
	
return .T.


/*/{Protheus.doc} logout

Logout de Usuários do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod logout wsReceive requestLogout wsSend responseLogout wsService CbcUserWs
		
	local cUserId 	:= ::requestLogout:userId
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(cUserId)
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	
	if oUtils:isNotNull(oUser)
		oStatus:success := .T.
		oStatus:message := "Logout realizado pelo usuário "+oUser:getName()
		checkEvent(EVENT_PORTAL_LOGOUT, oUser, oStatus:message)  
	else
		oStatus:success := .F.
		oStatus:message := "Usuário inválido"
	endIf
	
	::responseLogout:status := oStatus
	
return .T.
