#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"

#define DAYS_TO_EXPIRE_TOKEN	1
#define TOKEN_PASSWORD			"!token#p@$$w0rd"


/*/{Protheus.doc} CbcAuthService

Serviço para manipulação dos tokens de autenticação
    
@author victorhugo
@since 08/10/2018
/*/
class CbcAuthService from CbcService
	
	method newCbcAuthService() constructor
	
	method createToken()
	method validToken()
	method validUser()
	method createPassword()
	method isValidLoginOrPswString()
	
endClass


/*/{Protheus.doc} newCbcAuthService

Construtor
    
@author victorhugo
@since 08/10/2018
/*/
method newCbcAuthService() class CbcAuthService
return self


/*/{Protheus.doc} createToken

Cria um token de autenticação
	
@author victorhugo
@since 08/10/2018
/*/
method createToken(cUserId) class CbcAuthService
	
	local oPayload := JsonObject():new()
	local oJwt	   := LibJwtObj():newLibJwtObj()
	
	oPayload["userId"]    := cUserId
	oPayload["createdAt"] := DtoS(dDatabase)
	oPayload["expiresAt"] := DtoS(dDatabase + DAYS_TO_EXPIRE_TOKEN)
	
return oJwt:encode(oPayload:toJson(), TOKEN_PASSWORD)


/*/{Protheus.doc} validToken

Valida o token de autenticação
	
@author victorhugo
@since 08/10/2018
/*/
method validToken(oWs, cUserId) class CbcAuthService	
return validToken(self, oWs, nil, @cUserId)


/*/{Protheus.doc} validUser

Valida o token de autenticação populando o usuário
	
@author victorhugo
@since 08/10/2018
/*/
method validUser(oWs, oUser) class CbcAuthService
	
	local lGetUser := .T.
	
return validToken(self, oWs, @oUser, nil, lGetUser)

/**
 * Valida o Token de Autenticação
 */
static function validToken(oSelf, oWs, oUser, cUserId, lGetUser)

	local cData		 := ""
	local dExpiresAt := CtoD("")
	local oPayload	 := JsonObject():new()
	local cToken 	 := oWs:getHeader("auth-token")
	local oUtils	 := LibUtilsObj():newLibUtilsObj()
	local oJwt	     := LibJwtObj():newLibJwtObj()
	local oSrvUser	 := CbcUserService():newCbcUserService()
	local oResponse	 := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	default lGetUser := .F.
	
	if Empty(cToken)
		oResponse:unauthorized("token_not_provided")
		return .F.
	endIf
	
	cData := oJwt:decode(cToken, TOKEN_PASSWORD)
	
	if Empty(cData)
		oResponse:unauthorized("invalid_token")
		return .F.
	endIf
	
	oPayload:fromJson(cData)
		
	dExpiresAt := StoD(oPayload["expiresAt"])
	
	if (dExpiresAt <= dDatabase)
		oResponse:unauthorized("token_expired")
		return .F.
	endIf
	
	cUserId := oPayload["userId"]
	
	if lGetUser
		oUser := oSrvUser:findById(cUserId)		
	endIf		
	
return .T.


/*/{Protheus.doc} createPassword

Gera uma senha aleatoria para um usuário
	
@author victorhugo
@since 25/01/2019
/*/
method createPassword(cUserId, cNewPsw) class CbcAuthService
	
	local lOk    		:= .F.
	local lUserUpdate	:= .F.
	local cName  		:= ""
	local cLogin		:= ""
	local cEmail 		:= ""
	local cPsw   		:= ""	
	local cHtml			:= ""
	local cUpdate   	:= ""
	local cSubject		:= ""
	local cUpdPsw		:= "N"
	local cWhere		:= "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + cUserId + "'"	
	local cMvPar 		:= if ( PORTAL_REST_API, "ZZ_PTURL", "ZZ_URLPORT" )
	local cUrl   		:= GetNewPar(cMvPar, "")
	local oSql   		:= LibSqlObj():newLibSqlObj()
	local oMail  		:= LibMailObj():newLibMailObj()	
	default cNewPsw 	:= ""
	
	if Empty(cNewPsw)		
		cNewPsw := DtoS(Date())
		cNewPsw += StrTran(Time(), ":", "")
		cNewPsw += AllTrim(cUserId)			
		cNewPsw := MD5(cNewPsw, 2)
		cNewPsw := Left(cNewPsw, 8)		
	else
		lUserUpdate := .T.
	endIf	
	
	oSql:newTable("ZP1", "ZP1_NOME, ZP1_LOGIN, ZP1_EMAIL, ZP1_SENHA", cWhere)
	
	cName  := oSql:getValue("AllTrim(ZP1_NOME)")
	cLogin := oSql:getValue("AllTrim(ZP1_LOGIN)")
	cEmail := oSql:getValue("AllTrim(ZP1_EMAIL)")
	cPsw   := oSql:getValue("AllTrim(ZP1_SENHA)")
	
	if Empty(cPsw)
		cHtml    := USER_FIRST_ACCESS_EMAIL_HTML
		cSubject := "Portal Cobrecom - Primeiro Acesso"
	else
		cHtml    := PSW_RECOVERY_EMAIL_HTML
		cSubject := "Portal Cobrecom - Redefinição de Senha"
	endIf
	
	oSql:close()	
	
	oMail:setHtmlLayout(cHtml)
	oMail:setHtmlValue("userName", cName)
	oMail:setHtmlValue("url", cUrl)
	oMail:setHtmlValue("userLogin", cLogin)
	oMail:setHtmlValue("userPassword", cNewPsw)
	
	if oMail:send(cEmail, cSubject)
	
		lOk := .T.
		
		cUpdate := " ZP1_SENHA = '" + cNewPsw + "' "
	
		if lUserUpdate
			 cUpdPsw := "S"
		endIf
		
		cUpdate += " , ZP1_ALTSEN = '" + cUpdPsw + "' " 
		
		oSql:update("ZP1", cUpdate, cWhere)
		
	else	
	
		::cErrorMessage := oMail:getError()
	
	endIf	

return lOk


/*/{Protheus.doc} isValidLoginOrPswString

Valida os caracteres do login ou senha
	
@author victorhugo
@since 28/01/2019
/*/
method isValidLoginOrPswString(cLoginOrPsw) class CbcAuthService

	local lOk := .T.
	
	if ("-" $ cLoginOrPsw) .or. ("'" $ cLoginOrPsw) .or. ('"' $ cLoginOrPsw) .or. (',' $ cLoginOrPsw)
		lOk := .F.
	endIf	

return lOk
