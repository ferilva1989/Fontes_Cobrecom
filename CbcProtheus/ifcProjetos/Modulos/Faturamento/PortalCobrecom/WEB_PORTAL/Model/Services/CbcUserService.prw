#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch" 


/*/{Protheus.doc} CbcUserService

Servi�os referentes aos Usu�rios do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcUserService from CbcService		
	
	method newCbcUserService() constructor		
		
	method findById()
	method findByLogin()
	method create()
	method update()
	method passwordRecovery()
	method setUserGroup()
	method createWelcomeNotification()
	method acceptUseTerms()
	method getGroupName()
	method getGroupDescription()	
	method getFullName()
	method checkEvent()
	method usrIsGroup()

endClass


/*/{Protheus.doc} newCbcUserService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcUserService() class CbcUserService
	
	::cErrorMessage := "" 
	
return self


/*/{Protheus.doc} findById

Retorna usu�rios pelo C�digo
	
@author victorhugo
@since 24/02/2016

@param cId, String, C�digo do Usu�rio

@return CbcUser Usu�rio do Portal
/*/
method findById(cId) class CbcUserService
	
	local oUser := nil
	local oSql	:= LibSqlObj():newLibSqlObj()

	if Empty(cId)
		return nil
	endIf
	
	oSql:newTable("ZP1", "*", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+cId+"'") 
	
	if oSql:hasRecords()
		oUser := createFromSql(oSql)
	endIf
	
	oSql:close() 
	
return oUser


/*/{Protheus.doc} findByLogin

Retorna usu�rios pelo Login e Senha
	
@author victorhugo
@since 24/02/2016

@param cLogin, String, Login do Usu�rio
@param cPassword, String, Senha do Usu�rio

@return CbcUser Usu�rio do Portal
/*/
method findByLogin(cLogin, cPassword) class CbcUserService
	
	local oUser := nil
	local oSql	:= LibSqlObj():newLibSqlObj()

	if (Empty(cLogin) .or. Empty(cPassword))
		return nil
	endIf
	
	cLogin 		:= AllTrim(Lower(cLogin))
	cLogin		:= StrTran(cLogin, "'", "")
	cLogin		:= StrTran(cLogin, "-", "") 	
	cPassword	:= AllTrim(cPassword)
	cPassword	:= StrTran(cPassword, "'", "")
	cPassword	:= StrTran(cPassword, "-", "")
	
	oSql:newTable("ZP1", "*", "%ZP1.XFILIAL% AND (Lower(ZP1_LOGIN) = '"+cLogin+"' OR Lower(ZP1_EMAIL) = '"+cLogin+"') AND ZP1_SENHA = '"+cPassword+"'") 
	
	if oSql:hasRecords()
		oUser := createFromSql(oSql)  
	endIf
	
	oSql:close() 

return oUser

/**
 * Cria��o do Usu�rio a partir do objeto SQL
 */
static function createFromSql(oSql)
	
	local oCustomer		  := nil
	local lProspect		  := .F.
	local cCodeCustomer	  := ""
	local cUnitCustomer	  := "" 
	local oUser  		  := CbcUser():newCbcUser()
	local oSrvCustomer	  := CbcCustomerService():newCbcCustomerService()	
	
	oUser:setId(oSql:getValue("ZP1_CODIGO"))
	oUser:setName(oSql:getValue("AllTrim(ZP1_NOME)"))
	oUser:setLastName(oSql:getValue("AllTrim(ZP1_SOBREN)"))
	oUser:setLogin(oSql:getValue("AllTrim(ZP1_LOGIN)"))
	oUser:setPassword(oSql:getValue("ZP1_SENHA"))
	oUser:setDepartment(oSql:getValue("AllTrim(ZP1_DEPTO)"))
	oUser:setEmail(oSql:getValue("AllTrim(ZP1_EMAIL)"))
	oUser:setGroup(oSql:getValue("AllTrim(ZP1_GRUPO)"))
	oUser:setGroupName(oSql:getValue("Capital(AllTrim(ZP1_NOMGRP))"))
	oUser:setErpId(oSql:getValue("AllTrim(ZP1_CODERP)"))
	oUser:setBlocked(oSql:getValue("(ZP1_MSBLQL == '1')"))
	oUser:setLastLogin(oSql:getValue("StoD(ZP1_ULTLOG)"))
	oUser:setUseTerms(oSql:getValue("(ZP1_ACEITE == 'S')"))
	oUser:setPswChanged(oSql:getValue("(ZP1_ALTSEN == 'S')"))
	
	if (oUser:getGroup() == USER_PROSPECT)
		lProspect 		:= .T.
		cCodeCustomer	:= oSql:getValue("ZP1_CODPRO")
		cUnitCustomer	:= oSql:getValue("ZP1_LOJPRO")
	elseIf (oUser:getGroup() == USER_CUSTOMER)
		cCodeCustomer	:= oSql:getValue("ZP1_CODCLI")
		cUnitCustomer	:= oSql:getValue("ZP1_LOJCLI")
	elseIf (oUser:getGroup() == USER_SELLER)
		oUser:setSeller(CbcSeller():newCbcSeller(oSql:getValue("ZP1_CODVEN")))
	endIf
	
	if !Empty(cCodeCustomer)
		oCustomer := oSrvCustomer:findByCode(cCodeCustomer, cUnitCustomer, lProspect)
		oUser:setCustomer(oCustomer)
	endIf	
	
	checkApproverProfile(@oUser)
	
	if (oUser:getGroup() == USER_PROSPECT .or. oUser:getGroup() == USER_CUSTOMER)
		oUser:setShowDashboard(.F.)
	else
		oUser:setShowDashboard(GetNewPar("ZZ_DASHPOR", .T.))
	endIf
	
return oUser

/**
 * Verifica se o usu�rio � Aprovador de Or�amentos
 */
static function checkApproverProfile(oUser)
	
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local oProfile	:= nil
	
	oUser:setApprover(.F.)
	
	oSql:newTable("ZPB", "*", "%ZPB.XFILIAL% AND ZPB_CODUSR = '"+oUser:getId()+"'")
	
	if oSql:hasRecords()
		
		oProfile := CbcApproverProfile():newCbcApproverProfile()
		oProfile:setMinDiscount(0)
		oProfile:setMaxDiscount(0)
		oProfile:setMinValue(oSql:getValue("ZPB_VLRMIN"))
		oProfile:setMaxValue(oSql:getValue("ZPB_VLRMAX"))
		oProfile:setMinRg(oSql:getValue("ZPB_RGMIN"))
		oProfile:setMaxRg(oSql:getValue("ZPB_RGMAX"))		
		oProfile:setMinCommission(oSql:getValue("ZPB_COMMIN"))
		oProfile:setMaxCommission(oSql:getValue("ZPB_COMMAX"))
		oProfile:setCanStealApproval(oSql:getValue("ZPB_ASSUME == 'S'"))
		oProfile:setCanApproveBonus(oSql:getValue("ZPB_BONIF == 'S'")) 
		
		oUser:setApprover(.T.)
		oUser:setAppProfile(oProfile)
		
	endIf
	
	oSql:close()
	
return


/*/{Protheus.doc} create

Cria��o de um novo usu�rio
	
@author victorhugo
@since 24/02/2016

@param oUser, CbcUser, Usu�rio do Portal
@param cUserId, String, C�digo gerado para o Usu�rio

@return Logico Indica se o usu�rio foi criado
/*/
method create(oUser, cUserId) class CbcUserService
	
	local lOk := .F.
	
	if validRequiredData("create", @self, oUser)
		lOk := createUser(@self, oUser, @cUserId)
	endIf
	
return lOk


/*/{Protheus.doc} update

Atualiza��o de um usu�rio
	
@author victorhugo
@since 24/02/2016

@param oUser, CbcUser, Usu�rio do Portal

@return Logico Indica se o usu�rio foi atualizado
/*/
method update(oUser) class CbcUserService
	
	local lOk := .F.
	
	if validRequiredData("update", @self, oUser)
		lOk := updateUser(@self, oUser)
	endIf
	
return lOk

/**
 * Valida os campos obrigat�rios para cria��o do Usu�rio
 */
static function validRequiredData(cOperation, oSelf, oUser)
	
	local lOk    := .F.
	local cMsg   := ""
	local cWhere := "" 
	local oSql	 := LibSqlObj():newLibSqlObj()
	local oUtils := LibUtilsObj():newLibUtilsObj() 
	
	begin sequence
		
		if Empty(oUser:getName())
			cMsg := "Nome n�o informado"
			break
		endIf
		
		if Empty(oUser:getLastName())
			cMsg := "Sobrenome n�o informado"
			break
		endIf
		
		if Empty(oUser:getLogin())
			cMsg := "Login n�o informado"
			break
		endIf
		
		cWhere := "%ZP1.XFILIAL% AND ZP1_LOGIN = '"+oUser:getLogin()+"'"
		if (cOperation == "update")
			cWhere += " AND ZP1_CODIGO != '"+oUser:getId()+"' "
		endIf
		if oSql:exists("ZP1", cWhere)
			cMsg := "Login j� cadastrado"
			break
		endIf
		
		if !PORTAL_REST_API .and. Empty(oUser:getPassword())
			cMsg := "Senha n�o informada"
			break
		endIf
		
		if Empty(oUser:getEmail())
			cMsg := "E-mail n�o informado"
			break
		endIf
		
		if !isValidLogin(oUser)
			cMsg := "O login ou a senha possuem caracteres inv�lidos"
			break
		endIf
		
		cWhere := "%ZP1.XFILIAL% AND ZP1_EMAIL = '"+oUser:getEmail()+"'"
		if (cOperation == "update")
			cWhere += " AND ZP1_CODIGO != '"+oUser:getId()+"' "
		endIf
		if oSql:exists("ZP1", cWhere)
			cMsg := "E-mail j� cadastrado"
			break
		endIf
		
		if (oUser:getGroup() == USER_PROSPECT .or. oUser:getGroup() == USER_CUSTOMER) .and. Empty(oUser:getDepartment())
			cMsg := "Departamento n�o informado"
			break
		endIf
		
		if (cOperation == "update")
			lOk := .T.
			break
		endIf
		
		if Empty(oUser:getGroup())
			cMsg := "Grupo n�o informado"
			break
		endIf
		
		if !oSql:exists("SX5", "%SX5.XFILIAL% AND X5_TABELA = '_1' AND X5_CHAVE = '"+oUser:getGroup()+"'")
			cMsg := "Grupo inv�lido"
			break
		endIf
		
		if (oUser:getGroup() == USER_PROSPECT .or. oUser:getGroup() == USER_CUSTOMER)
			if oUtils:isNull(oUser:getCustomer())
				cMsg := "Para usu�rios dos grupos Prospects ou Clientes � necess�rio informar os dados do cliente"
				break
			elseIf (Empty(oUser:getCustomer():getCode()) .or. Empty(oUser:getCustomer():getUnit())) 
				cMsg := "Para usu�rios dos grupos Prospects ou Clientes � necess�rio informar o c�digo e a loja do Cliente ou Prospect"
				break
			endIf	
		endIf
		
		if (oUser:getGroup() == USER_PROSPECT .and. !oSql:exists("SUS", "%SUS.XFILIAL% AND US_COD = '"+oUser:getCustomer():getCode()+"' AND US_LOJA = '"+oUser:getCustomer():getUnit()+"'"))
			cMsg := "C�digo de Prospect inv�lido"
			break
		endIf
		
		if (oUser:getGroup() == USER_CUSTOMER .and. !oSql:exists("SA1", "%SA1.XFILIAL% AND A1_COD = '"+oUser:getCustomer():getCode()+"' AND A1_LOJA = '"+oUser:getCustomer():getUnit()+"'"))
			cMsg := "C�digo de Cliente inv�lido"
			break
		endIf
		
		if (oUser:getGroup() == USER_SELLER) .and. (Empty(oUser:getSeller() .or. Empty(oUser:getSeller():getId())))
			cMsg := "Para usu�rios do grupo Representantes � necess�rio informar o C�digo de Vendedor"
			break
		endIf
		
		if (oUser:getGroup() == USER_SELLER .and. !oSql:exists("SA3", "%SA3.XFILIAL% AND A3_COD = '"+oUser:getCodeSeller()+"'"))
			cMsg := "C�digo de Vendedor inv�lido"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	if !lOk
		oSelf:cErrorMessage := cMsg
	endIf
	
return lOk

/**
 * Valida o Login e Senha do Usu�rio
 */
static function isValidLogin(oUser)
	
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local cLoginPsw := oUser:getLogin()
	
	if !PORTAL_REST_API
		cLoginPsw += oUser:getPassword()
	endIf

return oAuthSrv:isValidLoginOrPswString(cLoginPsw)


/**
 * Cria��o do Usu�rio
 */
static function createUser(oSelf, oUser, cUserId)
	
	local lOk 	 	:= .F.
	local aData  	:= {}
	local oCustomer	:= oUser:getCustomer() 
	local oSql	 	:= LibSqlObj():newLibSqlObj()
	local oUtils 	:= LibUtilsObj():newLibUtilsObj()		
	
	if oUtils:isNull(oUser:isBlocked())
		oUser:setBlocked(.F.) 
	endIf
	
	cUserId := GetSxeNum("ZP1", "ZP1_CODIGO") 
	
	aAdd(aData, {"ZP1_FILIAL", xFilial("ZP1")})
	aAdd(aData, {"ZP1_CODIGO", cUserId})
	aAdd(aData, {"ZP1_NOME", oUser:getName()})
	aAdd(aData, {"ZP1_SOBREN", oUser:getLastName()})
	aAdd(aData, {"ZP1_LOGIN", oUser:getLogin()})
	aAdd(aData, {"ZP1_SENHA", oUser:getPassword()})
	aAdd(aData, {"ZP1_EMAIL", oUser:getEmail()})
	aAdd(aData, {"ZP1_DEPTO", oUser:getDepartment()})
	aAdd(aData, {"ZP1_GRUPO", oUser:getGroup()})
	aAdd(aData, {"ZP1_NOMGRP", oSql:getFieldValue("SX5", "X5_DESCRI", "%SX5.XFILIAL% AND X5_TABELA = '_1' AND X5_CHAVE = '"+oUser:getGroup()+"'")})
	aAdd(aData, {"ZP1_CODERP", oUser:getErpId()})
	aAdd(aData, {"ZP1_MSBLQL", if(oUser:isBlocked(), "1", "2")}) 
	aAdd(aData, {"ZP1_ACEITE", "N"})
  aAdd(aData, {"ZP1_ALTSEN", "S"}) 
	
	if (oUser:getGroup() == USER_PROSPECT)
		aAdd(aData, {"ZP1_CODPRO", oCustomer:getCode()})
		aAdd(aData, {"ZP1_LOJPRO", oCustomer:getUnit()})
		aAdd(aData, {"ZP1_NOMCLI", oSql:getFieldValue("SUS", "US_NOME", "%SUS.XFILIAL% AND US_COD = '"+oCustomer:getCode()+"' AND US_LOJA = '"+oCustomer:getUnit()+"'")})
	elseIf (oUser:getGroup() == USER_CUSTOMER)
		aAdd(aData, {"ZP1_CODCLI", oCustomer:getCode()})
		aAdd(aData, {"ZP1_LOJCLI", oCustomer:getUnit()})
		aAdd(aData, {"ZP1_NOMCLI", oSql:getFieldValue("SA1", "A1_NOME", "%SA1.XFILIAL% AND A1_COD = '"+oCustomer:getCode()+"' AND A1_LOJA = '"+oCustomer:getUnit()+"'")})
	elseIf (oUser:getGroup() == USER_SELLER)
		aAdd(aData, {"ZP1_CODVEN", oUser:getSeller():getId()})
		aAdd(aData, {"ZP1_NOMVEN", oUser:getSeller():getName()}) 
	endIf					
		
	if oSql:insert("ZP1", aData)
		lOk := .T.
		ConfirmSx8()
	else
		RollBackSx8()
		oSelf:cErrorMessage := "Falha ao gravar Usu�rio"
 	endIf
	
return lOk


/**
 * Atualiza��o do Usu�rio
 */
static function updateUser(oSelf, oUser)
	
	local lOk 	 	:= .F.
	local cFields	:= "" 
	local oSql	 	:= LibSqlObj():newLibSqlObj()
	
	cFields := " ZP1_NOME = '"+oUser:getName()+"', ZP1_SOBREN = '"+oUser:getLastName()+"', "
	cFields += " ZP1_LOGIN = '"+oUser:getLogin()+"', ZP1_EMAIL = '"+oUser:getEmail()+"' " 
	
	if !PORTAL_REST_API
		cFields += ",  ZP1_SENHA = '"+oUser:getPassword()+"' "
	endIf
	
	if !Empty(oUser:getDepartment())
		cFields += ", ZP1_DEPTO = '"+oUser:getDepartment()+"' "
	endIf	
		
	if oSql:update("ZP1", cFields, "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+oUser:getId()+"'")
		lOk := .T.
	else	
		oSelf:cErrorMessage := "Falha ao atualizar Usu�rio"
 	endIf
	
return lOk


/*/{Protheus.doc} passwordRecovery

Recupera��o das Senhas dos Usu�rios
	
@author victorhugo
@since 10/03/2016

@param cEmail, String, E-mail cadastrado para o Usu�rio

@return Logico Indica se o E-mail de Recupera��o foi enviado
/*/
method passwordRecovery(cEmail) class CbcUserService
	
	local lOk      := .F.
	local cUserId  := ""
	local oSql	   := LibSqlObj():newLibSqlObj()
	local oAuthSrv := CbcAuthService():newCbcAuthService()

	if Empty(cEmail)
		return .F.
	endIf
	
	oSql:newTable("ZP1", "ZP1_CODIGO", "%ZP1.XFILIAL% AND ZP1_EMAIL = '"+cEmail+"' AND ZP1_MSBLQL != '1' ") 
	
	if oSql:hasRecords()		
		cUserId := oSql:getValue("ZP1_CODIGO")
	endIf
	
	oSql:close()
	
	if Empty(cUserId)
		::cErrorMessage := "E-mail n�o cadastrado"
		return .F.
	endIf		
	
	if oAuthSrv:createPassword(cUserId)
		lOk := .T.
	else
		::cErrorMessage := oAuthSrv:getErrorMessage()
	endIf	

return lOk


/*/{Protheus.doc} setUserGroup

Define o Grupo de um Usu�rio
	
@author victorhugo
@since 16/03/2016

@param cId, String, C�digo do Usu�rio
@param cGroup, String, Grupo do Usu�rio
@param cCode, String, C�digo do Prospect, Cliente ou Vendedor
@param cUnit, String, Loja do Prospect ou Cliente
/*/
method setUserGroup(cId, cGroup, cCode, cUnit) class CbcUserService
	
	local oSql   	:= LibSqlObj():newLibSqlObj()
	local oSrvEvent := CbcEventService():newCbcEventService()
	local oSrvNotif := CbcNotificationService():newCbcNotificationService()
	local oEvent    := nil
	local cUpate 	:= "" 
	local cLogin	:= ""
	local cName		:= ""
	local cGroupName:= "" 
	local cMsg		:= ""
	local cCodCli 	:= "" 
	local cLojCli 	:= ""
	local cNomCli 	:= ""
	local cCodPro 	:= ""
	local cLojPro 	:= ""
	local cCodVen 	:= ""
	local cNomVen 	:= ""
	local cWhere	:= "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+cId+"'"
		
	oSql:newTable("ZP1", "ZP1_LOGIN LOGIN, ZP1_NOME NAME", cWhere)
	
	cLogin  	:= oSql:getValue("LOGIN")
	cName   	:= oSql:getValue("Capital(AllTrim(NAME))")
	cGroupName	:= oSql:getFieldValue("SX5", "X5_DESCRI", "%SX5.XFILIAL% AND X5_TABELA = '_1' AND X5_CHAVE = '"+cGroup+"'")
	
	oSql:close()	
	
	if (cGroup == USER_PROSPECT)
		cCodPro := cCode
		cLojPro := cUnit
		cNomCli := oSql:getFieldValue("SUS", "US_NOME", "%SUS.XFILIAL% AND US_COD = '"+cCode+"' AND US_LOJA = '"+cUnit+"'")
	elseIf (cGroup == USER_CUSTOMER)
		cCodCli := cCode
		cLojCli := cUnit
		cNomCli := oSql:getFieldValue("SA1", "A1_NOME", "%SA1.XFILIAL% AND A1_COD = '"+cCode+"' AND A1_LOJA = '"+cUnit+"'")
	elseIf (cGroup == USER_SELLER)
		cCodVen := cCode
		cNomVen := oSql:getFieldValue("SA3", "A3_NOME", "%SA3.XFILIAL% AND A3_COD = '"+cCode+"'")		
	endIf
	
	cUpdate := " ZP1_GRUPO = '"+cGroup+"', ZP1_NOMGRP = '"+cGroupName+"', "
	cUpdate += " ZP1_CODPRO = '"+cCodPro+"', ZP1_LOJPRO = '"+cLojPro+"', "
	cUpdate += " ZP1_CODCLI = '"+cCodCli+"', ZP1_LOJCLI = '"+cLojCli+"', "
	cUpdate += " ZP1_NOMCLI = '"+cNomCli+"', ZP1_CODVEN = '"+cCodVen+"', ZP1_NOMVEN = '"+cNomVen+"' "
	
	oSql:update("ZP1", cUpdate, cWhere)
	
	cMsg   := "O grupo do usu�rio "+cName+" ("+AllTrim(cLogin)+") foi definido como "+Capital(AllTrim(cGroupName))+"."
	oEvent := CbcEvent():newCbcEvent(EVENT_USER_GROUP_CHANGE, nil, cMsg)
	oSrvEvent:check(oEvent)
	
	cMsg := "Seu grupo de usu�rio foi definido como "+Capital(AllTrim(cGroupName))+"."
	if (cGroup == USER_CUSTOMER)
		cMsg := MemoRead(PROSPECT_TO_CUSTOMER_HTML)
		cMsg := StrTran(cMsg, "%userName%", cName)
		cMsg := StrTran(cMsg, "%useTermsUrl%", getUseTermsUrl())
	endIf
	oEvent := CbcEvent():newCbcEvent(EVENT_USER_GROUP_CHANGE, nil, cMsg, {cId}, {cId})
	oSrvNotif:create(oEvent)
	
return


/*/{Protheus.doc} createWelcomeNotification

Cria a Notifica��o de Boas-vindas para um Usu�rio
	
@author victorhugo
@since 08/04/2016

@param cUserId, String, ID do Usu�rio

@return Logico indica se a Notifica��o foi criada
/*/
method createWelcomeNotification(cUserId) class CbcUserService
	
	local oEvent		:= nil
	local oUser  		:= ::findById(cUserId)
	local oUtils 		:= LibUtilsObj():newLibUtilsObj()
	local oMail 		:= LibMailObj():newLibMailObj()
	local oSrvEvent 	:= CbcEventService():newCbcEventService()
	local lOk	 		:= .F.
	local cBody			:= ""
	local cMsg			:= ""	
	local cUserName		:= ""
	local cUseTermsUrl	:= ""	
	local cTo	   		:= oUser:getEmail() 		
	local cHtml			:= USER_WELCOME_HTML
	local cSubject		:= "Seja bem-vindo(a) ao Portal Cobrecom"  		

	if oUtils:isNull(oUser)
		::cErrorMessage := "Usu�rio inv�lido"
		return .F.
	endIf
	
	if !Empty(cHtml) .and. !File(cHtml)
		::cErrorMessage := "Arquivo "+cHtml+" n�o encontrado"
		return .F.
	endIf
	
	cUserName := AllTrim(Capital(oUser:getName()))
	
	if Empty(cHtml)
		cMsg := "Ol�, "+cUserName+" !"+CRLF+CRLF
		cMsg += "Agradecemos por ter se cadastrado no Portal Cobrecom. Caso tenha alguma d�vida, n�o hesite em nos contatar."+CRLF+CRLF
		cMsg += "Atenciosamente,"+CRLF
		cMsg += "Equipe Cobrecom"
	else
		cMsg := MemoRead(cHtml)
	endIf	
	
	cMsg := StrTran(cMsg, "%userName%", cUserName)	
	cMsg := StrTran(cMsg, "%useTermsUrl%", getUseTermsUrl())
	 
	oEvent := CbcEvent():newCbcEvent(EVENT_USER_WELCOME, nil, cMsg) 	
	oEvent:setNotifyUsers({cUserId})
	oEvent:setEmailUsers({cUserId})
	oSrvEvent:check(oEvent)
	
	oMail:send(cTo, cSubject, cMsg)	
	
return .T.

/**
 * Coleta a URL dos Termos de Uso do Portal
 */
static function getUseTermsUrl()
	
	local cUseTermsUrl := ""
	local cMvPar 	   := if ( PORTAL_REST_API, "ZZ_PTURL", "ZZ_URLPORT" )
	local cPortalUrl   := GetNewPar(cMvPar, "")	
	
	if Empty(cPortalUrl)
		return ""
	endIf
	
	cPortalUrl := AllTrim(cPortalUrl)
	
	if (Right(cPortalUrl, 1) != "/")
		cPortalUrl += "/" 
	endIf
	
	cUseTermsUrl := cPortalUrl+"useTerms/show"
	
return cUseTermsUrl


/*/{Protheus.doc} acceptUseTerms

Define o aceite dos termos de uso de um Usu�rio
	
@author victorhugo
@since 20/04/2016

@param cUserId, String, ID do Usu�rio
@param lAccepted, Logico, Indica se o usu�rio aceitou os termos

@return Logico Indica se o aceite foi gravado
/*/
method acceptUseTerms(cUserId, lAccepted) class CbcUserService
		
	local cMsg			:= ""
	local cAccepted		:= ""
	local cEvent		:= ""
	local cUserName		:= ""	
	local oEvent		:= nil	
	local oSql    		:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSrvEvent		:= CbcEventService():newCbcEventService()
	local oUser			:= ::findById(cUserId)
	default lAccepted	:= .T.
	
	if oUtils:isNull(oUser)					
		::cErrorMessage := "Usu�rio inv�lido"
		return .F.  
	endIf
	
	if lAccepted
		cAccepted := "S"
		cEvent	  := EVENT_USE_TERMS_ACCEPT
	else
		cAccepted := "N"
		cEvent	  := EVENT_USE_TERMS_REJECT 
	endIf
	
	cMsg := "O usu�rio "+oUser:getFullName()
	cMsg += if(lAccepted, " aceitou ", " rejeitou ")
	cMsg += " os Termos de Uso do Portal"
	
	begin transaction
	
		oSql:update("ZP1", "ZP1_ACEITE = '"+cAccepted+"'", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+cUserId+"'")
	
		if lAccepted
			::createWelcomeNotification(cUserId)
		endIf
		
		oEvent := CbcEvent():newCbcEvent(cEvent, cUserId, cMsg) 	
		oSrvEvent:check(oEvent)	
	
	end transaction

return .T.

/*/{Protheus.doc} getGroupName

Coleta o Nome de um Grupo de Usu�rios
	
@author victorhugo
@since 03/05/2016
/*/
method getGroupName(cGroup) class CbcUserService
		
	local oSql	:= LibSqlObj():newLibSqlObj()
	local cName := oSql:getFieldValue("SX5", "X5_DESCRI", "%SX5.XFILIAL% AND X5_TABELA = '_1' AND X5_CHAVE = '"+cGroup+"'")
	
	cName := AllTrim(Capital(cName))
	
return cName

/*/{Protheus.doc} getGroupDescription

Coleta a Descri��o do Cargo de um Grupo de Usu�rios
	
@author victorhugo
@since 03/05/2016
/*/
method getGroupDescription(cGroup) class CbcUserService
	
	local cDescription := ""
	
	if (cGroup == USER_ADMINISTRATOR)
		cDescription := "Administrador"
	elseIf (cGroup == USER_SELLER)
		cDescription := "Representante Comercial"
	elseIf (cGroup == USER_PROSPECT)
		cDescription := "Prospect"
	elseIf (cGroup == USER_CUSTOMER)
		cDescription := "Cliente"
	elseIf (cGroup == USER_ASSISTANT)
		cDescription := "Assistente de Vendas"
	elseIf (cGroup == USER_SUPERVISOR)
		cDescription := "Supervisor de Vendas"
	elseIf (cGroup == USER_MANAGER)
		cDescription := "Gerente"
	elseIf (cGroup == USER_DIRECTOR)
		cDescription := "Diretor"
	endIf

return cDescription


/*/{Protheus.doc} getFullName

Retorna o Nome Completo de um Usu�rio
	
@author victorhugo
@since 16/08/2016
/*/
method getFullName(cUserId) class CbcUserService
	
	local cFullName := ""
	local oSql 	 	:= LibSqlObj():newLibSqlObj()
	
	if Empty(cUserId)
		return ""
	endIf
	
	oSql:newTable("ZP1", "ZP1_NOME [NAME], ZP1_SOBREN [LAST_NAME]", "%ZP1.XFILIAL% AND ZP1_CODIGO = '"+cUserId+"'")
	
	cFullName := oSql:getValue("AllTrim(Capital(NAME))+' '+AllTrim(Capital(LAST_NAME))")
	
	oSql:close()
	
return cFullName


/*/{Protheus.doc} checkEvent

Verifica os Eventos relacionados aos Usu�rios
	
@author victorhugo
@since 09/10/2018
/*/
method checkEvent(cEvent, oUser, cMessage) class CbcUserService
	
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

method usrIsGroup(aGrp, cUserId) class CbcUserService
	local cGrpUsr	:= ""
	local nPos		:= 0
	local nX		:= 0
	local lRet		:= .F.
	local oSql		:= LibSqlObj():newLibSqlObj()
	default aGrp	:= {}

	oSql:newTable("ZP1", "ZP1_GRUPO", "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + cUserId + "' AND ZP1_MSBLQL <> '1' ") 

	if oSql:hasRecords()		
		cGrpUsr := oSql:getValue("ZP1_GRUPO")
	endIf
		nPos := AScan(aGrp, cGrpUsr)
		if nPos > 0
			lRet := .T.
		endif
	oSql:close()
return(lRet)

/**
 * Verifica os Eventos de Login e Logout
 */
static function getGroups()
	
	local lLoginLogs := GetNewPar("ZZ_LOGNOT", .T.)
	local oNotSrv	 := CbcNotificationService():newCbcNotificationService()
	
	if !lLoginLogs
		return
	endIf
	
	oEvent:setNotifyUsers({""})
	oEvent:setEmailUsers({})
	
	oNotSrv:create(oEvent)
	
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
