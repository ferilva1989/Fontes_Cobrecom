#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcMessagesApi

API Rest para manutenção de mensagens do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcMessagesApi DESCRIPTION "API Rest para manutenção de mensagens do Portal Cobrecom"
	
	wsMethod GET description "Rotas GET: /users  /groups  /senders"	
	wsMethod POST description "Rotas POST: /find  /find-by-quotation/:id  /create"
	wsMethod PUT description "Rotas PUT: /set-displayed  /archive"
	wsMethod DELETE description "Rotas DELETE: /remove"
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcMessagesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "users")
		
		lOk := getTo("users", self)
		
	elseIf (cRoute == "groups")	
		
		lOk := getTo("groups", self)
	
	elseIf (cRoute == "senders")	
		
		lOk := getSenders(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcMessagesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "find")
		
		lOk := find(self)
		
	elseIf (cRoute == "find-by-quotation")
		
		lOk := findByQuotation(self)
	
	elseIf (cRoute == "create")	
		
		lOk := create(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} PUT

Rotas PUT
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod PUT wsService CbcMessagesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "set-displayed")
		
		lOk := setDisplayed(self)
		
	elseIf (cRoute == "archive")	
		
		lOk := archive(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} DELETE

Rotas DELETE
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod DELETE wsService CbcMessagesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "remove")
		
		lOk := remove(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna os usuários ou grupos para envio de mensagens
 */
static function getTo(cOption, oWs)
	
	local oUser     := nil
	local oData     := nil
	local aValues   := {}
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validUser(oWs, @oUser)
		return .F.
	endIf

	oData 		   := JsonObject():new()
	oData[cOption] := getToValues(cOption, oUser)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Coleta a lista de Usuários ou Grupos para envio de Mensagens
 */
static function getToValues(cOption, oUser)
	
	local aValues := {}
	local aIds	  := {}
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if oUser:isProspect()
	
		if (cOption == "groups")
			aAdd(aIds, USER_SUPERVISOR)
		endIf
		
	elseIf oUser:isCustomer()
	
		aIds := getToCustomersIds(cOption, oUser)
		
	elseIf oUser:isSeller()
			
		aIds := getToSellersIds(cOption, oUser)
		
	else
		
		aIds := getToCobrecomIds(cOption, oUser)
		
	endIf
	
	if (Len(aIds) > 0)
		aValues := getToJsValues(cOption, aIds)
	endIf
	
return aValues

/**
 * Coleta os Destinátarios de Mensagens para Clientes
 */
static function getToCustomersIds(cOption, oUser)
	
	local aIds	  := {}
	local oSeller := oUser:getCustomer():getSeller()
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (oUtils:isNotNull(oSeller) .and. cOption == "users")
		
		oSql:newTable("ZP1", "ZP1_CODIGO [ID]", "%ZP1.XFILIAL% AND ZP1_CODVEN = '"+oSeller:getId()+"' AND ZP1_MSBLQL != '1'")
		
		if oSql:hasRecords()
			aAdd(aIds, oSql:getValue("ID")) 	
		endIf
		
		oSql:close()
		
	elseIf (cOption == "groups")
		
		aIds := { USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER }
		
	endIf
	
return aIds


/**
 * Coleta os Destinátarios de Mensagens para Vendedores
 */
static function getToSellersIds(cOption, oUser)
	
	local aIds	  := {}
	local cQuery  := ""
	local oSeller := oUser:getSeller()
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (cOption == "users")
		
		cQuery := " SELECT ZP1_CODIGO [ID] "
		cQuery += " FROM %ZP1.SQLNAME% "
		cQuery += " WHERE %ZP1.XFILIAL% AND ZP1_GRUPO NOT IN ('"+USER_PROSPECT+"','"+USER_CUSTOMER+"','"+USER_SELLER+"') AND "
		cQuery += " 	  ZP1_MSBLQL != '1' AND %ZP1.NOTDEL% "
		cQuery += " UNION ALL " 
		cQuery += " SELECT ZP1_CODIGO [ID] "
		cQuery += " FROM %ZP1.SQLNAME% "
		cQuery += " 	INNER JOIN %SUS.SQLNAME% ON "
		cQuery += " 		%SUS.XFILIAL% AND US_COD = ZP1_CODPRO AND US_LOJA = ZP1_LOJPRO AND %SUS.NOTDEL% "	
		cQuery += " WHERE %ZP1.XFILIAL% AND US_VEND = '"+oSeller:getId()+"' AND "
		cQuery += " 	  ZP1_MSBLQL != '1' AND %ZP1.NOTDEL% "
		cQuery += " UNION ALL " 
		cQuery += " SELECT ZP1_CODIGO [ID] "
		cQuery += " FROM %ZP1.SQLNAME% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP1_CODCLI AND A1_LOJA = ZP1_LOJCLI AND %SA1.NOTDEL% "	
		cQuery += " WHERE %ZP1.XFILIAL% AND A1_VEND = '"+oSeller:getId()+"' AND "
		cQuery += " 	  ZP1_MSBLQL != '1' AND %ZP1.NOTDEL% " 
		
 		oSql:newAlias(cQuery)
 		
		while oSql:notIsEof()		
			aAdd(aIds, oSql:getValue("ID"))		
			oSql:skip() 	
		endDo
		
		oSql:close()
		
	elseIf (cOption == "groups")
		
		aIds := { USER_ADMINISTRATOR, USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER, USER_DIRECTOR }
		
	endIf
	
return aIds

/**
 * Coleta os Destinátarios de Mensagens para funcionários da Cobrecom
 */
static function getToCobrecomIds(cOption)
	
	local aIds	  := {}
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (cOption == "users")
		
		oSql:newTable("ZP1", "ZP1_CODIGO [ID]", "%ZP1.XFILIAL% AND ZP1_MSBLQL != '1'")
		
		while oSql:notIsEof()
			aAdd(aIds, oSql:getValue("ID"))
			oSql:skip() 	
		endDo
		
		oSql:close()
		
	elseIf (cOption == "groups")
		
		aIds := { USER_ADMINISTRATOR, USER_SELLER, USER_PROSPECT, USER_CUSTOMER, USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER, USER_DIRECTOR }
		
	endIf
	
return aIds

/**
 * Coleta os Valores para o array de destinatários das Mensagens
 */
static function getToJsValues(cOption, aIds)
	
	local nI 	   := 0	
	local cGroup   := ""
	local aValues  := {}
	local aJsValues:= {}
	local oUser	   := nil 
	local oJsObj   := nil
	local oSrvUser := CbcUserService():newCbcUserService()
	
	for nI := 1 to Len(aIds)
	
		if (cOption == "users")
		
			oUser  := oSrvUser:findById(aIds[nI])
			cGroup := oSrvUser:getGroupDescription(oUser:getGroup())
			
			if (oUser:isProspect() .or. oUser:isCustomer())
				cGroup := AllTrim(cGroup) + " - " + AllTrim(oUser:getCustomer():getName())
			endIf
				
			aAdd(aValues, { oUser:getId(), oUser:getName(), cGroup })
			
		elseIf (cOption == "groups")
		
			aAdd(aValues, { aIds[nI], oSrvUser:getGroupName(aIds[nI]) })
			
		endIf
		
	next nI 
	
	if (cOption == "users")
		aSort(@aValues, nil, nil, { | x,y | x[3]+x[2] < y[3]+y[2] } )
	elseIf (cOption == "groups")
		aSort(@aValues, nil, nil, { | x,y | x[2] < y[2] } )
	endIf
	
	for nI := 1 to Len(aValues)
		
		oJsObj       := JsonObject():new()				
		oJsObj["id"] := aValues[nI,1]
		
		if (cOption == "users")
			oJsObj["name"] := AllTrim(aValues[nI,2]) + " (" + AllTrim(aValues[nI,3]) + ")"
		elseIf (cOption == "groups")
			oJsObj["name"] := aValues[nI,2]
		endIf
		
		aAdd(aJsValues ,oJsObj)
		
	next nI
	
return aJsValues

/**
 * Retorna os remetentes de um usuário
 */
static function getSenders(oWs)
	
	local aSenders 		:= {}
	local cQuery   		:= ""
	local cUserId   	:= ""
	local oSender		:= nil	
	local oSql	   		:= LibSqlObj():newLibSqlObj()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oService		:= CbcMessageService():newCbcMessageService()
	local oData	     	:= JsonObject():new()
	local oResponse     := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf

	cQuery := " SELECT DISTINCT " 
	cQuery += "		ZP3_USRORI USER_ID, ZP1_NOME USER_NAME, ZP1_SOBREN LAST_NAME, ZP1_EMAIL EMAIL, ZP1_NOMGRP [GROUP], "
	cQuery += "  	( SELECT MAX(ZP3_CODIGO) FROM " + RetSqlName("ZP3") + " LAST_MSG "
	cQuery += "       WHERE LAST_MSG.ZP3_FILIAL = '" + xFilial("ZP3") + "' AND LAST_MSG.ZP3_USRDES = '" + cUserId + "' AND "
	cQuery += " 	  	    LAST_MSG.ZP3_USRDES = '" + cUserId + "' AND LAST_MSG.ZP3_USRORI = ZP3.ZP3_USRORI AND " 
	cQuery += "				ZP3_ARQ != 'S' AND %ZP3.NOTDEL% )	AS LAST_MSG_ID "
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP3_USRORI AND %ZP1.NOTDEL% "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_USRDES = '" + cUserId + "' AND ZP3_ARQ != 'S' AND %ZP3.NOTDEL% "
	cQuery += " ORDER BY 3 DESC "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oSender 					 := JsonObject():new()
		oSender["id"] 		 		 := oSql:getValue("USER_ID")
		oSender["name"] 	 		 := oSql:getValue("AllTrim(USER_NAME)")
		oSender["lastName"] 	 	 := oSql:getValue("AllTrim(LAST_NAME)")
		oSender["email"] 	 	 	 := oSql:getValue("AllTrim(EMAIL)")
		oSender["group"] 	 	 	 := oSql:getValue("AllTrim(Capital(GROUP))")
		oSender["notDisplayedCount"] := oService:getNotDisplayedCount(cUserId, oSender["id"])
		
		aAdd(aSenders, oSender)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oData["senders"] := aSenders
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna mensagens por usuários ou por remetentes
 */
static function find(oWs)

	local cUserId   := ""	
	local aMessages := {}
	local oData		:= JsonObject():new()
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcMessageService():newCbcMessageService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	aMessages := oService:findByUser(cUserId, oBody["showDisplayed"], oBody["fromUser"], oBody["lastId"], oBody["maxRegs"], oBody["setDisplayed"])		
		
	oData["notDisplayedCount"] := oService:getNotDisplayedCount(cUserId)
	oData["messages"]		   := oService:getJsArray(aMessages)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna mensagens de um orçamento
 */
static function findByQuotation(oWs)

	local cQuotationId	:= ""
	local aMessages 	:= {}
	local oData			:= JsonObject():new()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oService		:= CbcMessageService():newCbcMessageService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cQuotationId := oWs:aURLParms[2]
	endIf
	
	if Empty(cQuotationId)
		oResponse:badRequest("Informe o ID do orcamento")
		return .F.
	endIf
	
	aMessages 		  := oService:findByQuotation(cQuotationId)				
	oData["messages"] := oService:getJsArray(aMessages)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Criação de mensagens
 */
static function create(oWs)
	
	local lOk		:= .F.
	local cUserId   := ""
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcMessageService():newCbcMessageService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(EncodeUTF8(oWs:getContent()))
	
	if oService:create(cUserId, oBody["toUsers"], oBody["toGroups"], oBody["subject"], oBody["text"], oBody["quotationId"])
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Define uma mensagem com visualizada
 */
static function setDisplayed(oWs)
	
	local lOk		:= .F.
	local cUserId   := ""
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcMessageService():newCbcMessageService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oService:setDisplayed(oBody["messageId"], cUserId)
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Arquiva uma mensagem
 */
static function archive(oWs)

	local lOk		:= .F.
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcMessageService():newCbcMessageService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oService:archive(oBody["messageId"])
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Remove uma mensagem
 */
static function remove(oWs)
	
	local lOk		:= .F.
	local oBody		:= JsonObject():new()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oService	:= CbcMessageService():newCbcMessageService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oService:delete(oBody["messageId"])
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk


