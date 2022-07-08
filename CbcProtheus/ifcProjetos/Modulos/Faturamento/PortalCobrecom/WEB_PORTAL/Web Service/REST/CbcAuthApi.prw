#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcAuthApi

API Rest para controle de autenticação do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcAuthApi DESCRIPTION "API Rest para controle de autenticação do Portal Cobrecom"
	
	wsMethod POST description "Rotas POST: /login  /logout  /password-recovery  /check-token  /change-password"
	
end wsRestful


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcAuthApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "login")
		
		lOk := login(self)
				
	elseIf (cRoute == "logout")
		
		lOk := logout(self)
		
	elseIf (cRoute == "password-recovery")
	
		lOk := passwordRecovery(self)				
	
	elseIf (cRoute == "check-token")
	
		lOk := checkToken(self)
		
	elseIf (cRoute == "change-password")
	
		lOk := changePassword(self)	
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Login de usuários
 */
static function login(oWs)
		
	local oUser			:= nil		
	local oData			:= nil
	local oBody		    := JsonObject():new()
	local oUserSrv		:= CbcUserService():newCbcUserService()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oResponse		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	oBody:fromJson(oWs:getContent())	
	
	oUser := oUserSrv:findByLogin(oBody["login"], oBody["password"])
	
	if oUtils:isNull(oUser) .or. oUser:isBlocked()
		oResponse:notFound("Login invalido")
		return .F.
	endIf
	
	oData := JsonObject():new()	
	
	oData["authToken"] 	 := oAuthSrv:createToken(oUser:getId())
	oData["uploadToken"] := u_CbcTokenApi()
	oData["user"]  		 := oUser:toJsonObject()
	
	oUserSrv:checkEvent(EVENT_PORTAL_LOGIN, oUser, "Login realizado pelo usuário " + oUser:getName())	
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Logout de usuários
 */
static function logout(oWs)
	
	local oUser		:= nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oUserSrv	:= CbcUserService():newCbcUserService()
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validUser(oWs, @oUser)
		return .F.
	endIf
	
	if oUtils:isNotNull(oUser)
		oUserSrv:checkEvent(EVENT_PORTAL_LOGOUT, oUser, "Logout realizado pelo usuário " + oUser:getName())
		oResponse:success()
	else
		oResponse:badRequest("Token invalido")
		return .F.
	endIf
	
return .T.

/**
 * Recuperação de Senha
 */
static function passwordRecovery(oWs)
	
	local oBody	    := JsonObject():new()
	local oSrvUser  := CbcUserService():newCbcUserService()	
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)

	oBody:fromJson(oWs:getContent())	
	
	if Empty(oBody["email"])
		oResponse:badRequest("E-mail nao fornecido")
		return .F.
	endIf
	
	if oSrvUser:passwordRecovery(oBody["email"])
		oResponse:success()
	else
		oResponse:badRequest(oSrvUser:getErrorMessage())
		return .F.
	endIf
	
return .T.

/**
 * Validação dos Tokens
 */
static function checkToken(oWs)
		
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oResponse:success()
	
return .T.

/**
 * Alteração de Senha
 */
static function changePassword(oWs)
	
	local cUserId		:= ""
	local cCurrentPsw	:= ""
	local cNewPsw		:= ""
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oBody	    	:= JsonObject():new()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	cCurrentPsw := AllTrim(oBody["currentPassword"])
	cNewPsw     := AllTrim(oBody["newPassword"])
	
	if !oSql:exists("ZP1", "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + cUserId + "' AND ZP1_SENHA = '" + cCurrentPsw + "'")
		oResponse:badRequest("Senha atual inválida")
		return .F.
	endIf	
	
	if !oAuthSrv:isValidLoginOrPswString(cNewPsw)
		oResponse:badRequest("A nova senha possui caracteres inválidos")
		return .F.
	endIf
	
	if oAuthSrv:createPassword(cUserId, cNewPsw)
		oResponse:success()
	else
		oResponse:badRequest(oAuthSrv:getErrorMessage())
		return .F.
	endIf
	
return .T.
