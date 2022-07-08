#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"

#define TO_USERS	"users"
#define TO_GROUPS	"groups" 


/*/{Protheus.doc} CbcMessageWs

Web Service de Manutenção de Mensagens do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcMessageWs description "Web Service de Manutenção de Mensagens do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcmessagews.apw"
	
	wsData requestCreate as WsCbcRequestCreateMessage
	wsData responseCreate as WsCbcResponseCreateMessage
	wsData requestMessagesByUser as WsCbcRequestMessagesByUser		
	wsData responseMessagesByUser as WsCbcResponseMessagesByUser
	wsData requestMessagesBySender as WsCbcRequestMessagesBySender
	wsData responseMessagesBySender as WsCbcResponseMessagesBySender	
	wsData requestMessagesByQuotation as WsCbcRequestMessagesByQuotation
	wsData responseMessagesByQuotation as WsCbcResponseMessagesByQuotation
	wsData requestSetMessageDisplayed as WsCbcRequestSetMessageDisplayed
	wsData responseSetMessageDisplayed as WsCbcResponseSetMessageDisplayed
	wsData requestToUsers as WsCbcRequestToUsersMessage
	wsData responseToUsers as WsCbcResponseToUsersMessage
	wsData requestToGroups as WsCbcRequestToGroupsMessage
	wsData responseToGroups as WsCbcResponseToGroupsMessage
	wsData requestDelete as WsCbcRequestDeleteMessage
	wsData responseDelete as WsCbcResponseDeleteMessage
	wsData requestArchive as WsCbcRequestArchiveMessage
	wsData responseArchive as WsCbcResponseArchiveMessage
	
	wsMethod create description "Criação das Mensagens"
	wsMethod findMessagesByUser description "Retorna as Mensagens de um Usuário"
	wsMethod findMessagesBySender description "Retorna as Mensagens de um Usuário agrupando por Remetentes"
	wsMethod findMessagesByQuotation description "Retorna as Mensagens de um Orçamento"
	wsMethod setMessageDisplayed description "Define uma Mensagem como Visualizada"
	wsMethod getToUsers description "Coleta os Usuários para Envio de Mensagens"
	wsMethod getToGroups description "Coleta os Grupos de Usuários para Envio de Mensagens"
	wsMethod delete description "Remove uma mensagem"
	wsMethod archive description "Arquiva uma mensagem"
	
endWsService


/*/{Protheus.doc} create

Criação das Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod create wsReceive requestCreate wsSend responseCreate wsService CbcMessageWs
		
	local aToUsers	 := {} 
	local aToGroups	 := {}
	local oRequest	 := ::requestCreate
	local oStatus    := WsClassNew("WsCbcResponseStatus")
	local oService	 := CbcMessageService():newCbcMessageService()
	
	if !Empty(oRequest:toUsers)
		aToUsers := StrTokArr(oRequest:toUsers, ",")
	endIf	 
	
	if !Empty(oRequest:toGroups)
		aToGroups := StrTokArr(oRequest:toGroups, ",")
	endIf	
	
	lOk := oService:create(oRequest:fromUser, aToUsers, aToGroups, oRequest:subject, oRequest:text, oRequest:quotationId)
	
	if lOk
		oStatus:success := .T.
		oStatus:message := "Mensagem criada com sucesso"		
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage() 		 
	endIf
	
	::responseCreate:status := oStatus
	
return .T.


/*/{Protheus.doc} findMessagesByUser

Retorna as Mensagens de um Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findMessagesByUser wsReceive requestMessagesByUser wsSend responseMessagesByUser wsService CbcMessageWs
	
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oRequest 			:= ::requestMessagesByUser
	local oService			:= CbcMessageService():newCbcMessageService()
	local nNotDisplayed		:= oService:getNotDisplayedCount(oRequest:userId)
	local aMessages			:= oService:findByUser(oRequest:userId, oRequest:showDisplayed, oRequest:fromUser, oRequest:lastId, oRequest:maxRegs, oRequest:setDisplayed)
	
	if (Len(aMessages) > 0)
		oStatus:success := .T.
		oStatus:message := "Mensagens fornecidas com sucesso" 
		setWsMessages(@aMessages) 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhuma Mensagem encontrada"		 
	endIf
	
	::responseMessagesByUser:status    		   := oStatus
	::responseMessagesByUser:notDisplayedCount := nNotDisplayed
	::responseMessagesByUser:messages  		   := aMessages 
	
return .T.

/**
 * Converte as Mensagens para o formato de Web Service
 */
static function setWsMessages(aMessages)
	
	local nI	   := 0
	local aWsMsgs  := {}
	
	for nI := 1 to Len(aMessages)
		aAdd(aWsMsgs, aMessages[nI]:toWsObject())
	next nI
	
	aMessages := aClone(aWsMsgs) 
	
return


/*/{Protheus.doc} findMessagesBySender

Retorna as Mensagens de um Usuário agrupando por Remetentes
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findMessagesBySender wsReceive requestMessagesBySender wsSend responseMessagesBySender wsService CbcMessageWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local aSenders	:= getSenders(::requestMessagesBySender)
	
	if (Len(aSenders) > 0)
		oStatus:success := .T.
		oStatus:message := "Mensagens fornecidas com sucesso"    
	else
		oStatus:success := .F.
		oStatus:message := "Nenhuma Mensagem encontrada"		 
	endIf
	
	::responseMessagesBySender:status  := oStatus
	::responseMessagesBySender:senders := aSenders 
	
return .T.

/**
 * Coleta as Mensagens dos Remetentes
 */
static function getSenders(oRequest)

	local oWsSender	:= nil
	local cLastId	:= nil
	local aMsgs		:= {}
	local aSenders 	:= {}
	local aWsMsgs	:= {}
	local cQuery   	:= ""
	local oSql	   	:= LibSqlObj():newLibSqlObj()
	local oService	:= CbcMessageService():newCbcMessageService()

	cQuery := " SELECT DISTINCT " 
	cQuery += "		ZP3_USRORI USER_ID, ZP1_NOME USER_NAME, "
	cQuery += "  	( SELECT MAX(ZP3_CODIGO) FROM "+RetSqlName("ZP3")+" LAST_MSG "
	cQuery += "       WHERE LAST_MSG.ZP3_FILIAL = '"+xFilial("ZP3")+"' AND LAST_MSG.ZP3_USRDES = '"+oRequest:userId+"' AND "
	cQuery += " 	  	    LAST_MSG.ZP3_USRDES = '"+oRequest:userId+"' AND LAST_MSG.ZP3_USRORI = ZP3.ZP3_USRORI AND " 
	cQuery += "				ZP3_ARQ != 'S' AND %ZP3.NOTDEL% )	AS LAST_MSG_ID "
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP3_USRORI AND %ZP1.NOTDEL% "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_USRDES = '"+oRequest:userId+"' AND ZP3_ARQ != 'S' AND %ZP3.NOTDEL% "
	cQuery += " ORDER BY 3 DESC "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oWsSender := WsClassNew("WsCbcMessageBySender")
		oWsSender:fromUserId 		:= oSql:getValue("USER_ID")
		oWsSender:fromUserName 		:= oSql:getValue("USER_NAME")
		oWsSender:notDisplayedCount := oService:getNotDisplayedCount(oRequest:userId, oWsSender:fromUserId)
		
		aMsgs := oService:findByUser(oRequest:userId, oRequest:showDisplayed, oWsSender:fromUserId, cLastId, oRequest:maxRegs, oRequest:setDisplayed)		
		
		setWsMessages(@aMsgs)
		
		oWsSender:messages := aMsgs
		
		aAdd(aSenders, oWsSender)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aSenders


/*/{Protheus.doc} findMessagesByQuotation

Retorna as Mensagens de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findMessagesByQuotation wsReceive requestMessagesByQuotation wsSend responseMessagesByQuotation wsService CbcMessageWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oService	:= CbcMessageService():newCbcMessageService()
	local aMessages	:= oService:findByQuotation(::requestMessagesByQuotation:quotationId)
	
	if (Len(aMessages) > 0)
		oService:setWsArray(@aMessages)
		oStatus:success := .T.
		oStatus:message := "Mensagens fornecidas com sucesso"    
	else
		oStatus:success := .F.
		oStatus:message := "Nenhuma Mensagem encontrada"		 
	endIf
	
	::responseMessagesByQuotation:status   := oStatus
	::responseMessagesByQuotation:messages := aMessages 
	
return .T.


/*/{Protheus.doc} setMessageDisplayed

Define uma Mensagem como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod setMessageDisplayed wsReceive requestSetMessageDisplayed wsSend responseSetMessageDisplayed wsService CbcMessageWs
	
	local oWsUser	:= nil
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestSetMessageDisplayed
	local oService	:= CbcMessageService():newCbcMessageService()
	
	if oService:setDisplayed(oRequest:MessageId, oRequest:userId)
		oStatus:success := .T.
		oStatus:message := "Mensagem "+oRequest:MessageId+" definida como visualizada para o usuário "+oRequest:userId 
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()		 
	endIf
	
	::responseSetMessageDisplayed:status := oStatus
	
return .T.


/*/{Protheus.doc} getToUsers

Coleta os Usuários para Envio de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getToUsers wsReceive requestToUsers wsSend responseToUsers wsService CbcMessageWs
	
	getToMessages(TO_USERS, ::requestToUsers, @::responseToUsers)
	
return .T.


/*/{Protheus.doc} getToGroups

Coleta os Grupos de Usuários para Envio de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getToGroups wsReceive requestToGroups wsSend responseToGroups wsService CbcMessageWs
	
	getToMessages(TO_GROUPS, ::requestToGroups, @::responseToGroups)
	
return .T.


/**
 * Coleta os Usuários ou Grupos de Usuários para envio de mensagens
 */
static function getToMessages(cOption, oRequest, oResponse)
 	
	local aValues  := {}
	local oStatus  := WsClassNew("WsCbcResponseStatus")
	local oUtils   := LibUtilsObj():newLibUtilsObj() 
	local oSrvUser := CbcUserService():newCbcUserService()
	local oUser	   := oSrvUser:findById(oRequest:fromUser)
	
	if oUtils:isNull(oUser)
		oStatus:success := .F.
		oStatus:message := "Usuário inválido"		
	else
		aValues := getToValues(cOption, oUser)
		if (Len(aValues) > 0)
			oStatus:success := .T.
			oStatus:message := "Dados fornecidos com sucesso"
		else
			oStatus:success := .F.
			oStatus:message := "Nenhum registro encontrado"
		endIf	
	endIf
	
	oResponse:status := oStatus
	
	if (cOption == TO_USERS)
		oResponse:users := aValues
	elseIf (cOption == TO_GROUPS)
		oResponse:groups := aValues
	endIf
	
return

/**
 * Coleta a lista de Usuários ou Grupos para envio de Mensagens
 */
static function getToValues(cOption, oUser)
	
	local aValues := {}
	local aIds	  := {}
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if oUser:isProspect()
		if (cOption == TO_GROUPS)
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
		aValues := getToWsValues(cOption, aIds)
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
	
	if (oUtils:isNotNull(oSeller) .and. cOption == TO_USERS)
		
		oSql:newTable("ZP1", "ZP1_CODIGO [ID]", "%ZP1.XFILIAL% AND ZP1_CODVEN = '"+oSeller:getId()+"' AND ZP1_MSBLQL != '1'")
		
		if oSql:hasRecords()
			aAdd(aIds, oSql:getValue("ID")) 	
		endIf
		
		oSql:close()
		
	elseIf (cOption == TO_GROUPS)
		
		aIds := {USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER}
		
	endIf
	
return aIds


/**
 * Coleta os Destinátarios de Mensagens para Vendedores
 */
static function getToSellerIds(cOption, oUser)
	
	local aIds	  := {}
	local cQuery  := ""
	local oSeller := oUser:getSeller()
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (cOption == TO_USERS)
		
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
		
	elseIf (cOption == TO_GROUPS)
		
		aIds := {USER_ADMINISTRATOR, USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER, USER_DIRECTOR}
		
	endIf
	
return aIds

/**
 * Coleta os Destinátarios de Mensagens para funcionários da Cobrecom
 */
static function getToCobrecomIds(cOption)
	
	local aIds	  := {}
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (cOption == TO_USERS)
		
		oSql:newTable("ZP1", "ZP1_CODIGO [ID]", "%ZP1.XFILIAL% AND ZP1_MSBLQL != '1'")
		
		while oSql:notIsEof()
			aAdd(aIds, oSql:getValue("ID"))
			oSql:skip() 	
		endDo
		
		oSql:close()
		
	elseIf (cOption == TO_GROUPS)
		
		aIds := {USER_ADMINISTRATOR, USER_SELLER, USER_PROSPECT, USER_CUSTOMER, USER_ASSISTANT, USER_SUPERVISOR, USER_MANAGER, USER_DIRECTOR}
		
	endIf
	
return aIds

/**
 * Coleta os Valores para o array de destinatários das Mensagens
 */
static function getToWsValues(cOption, aIds)
	
	local nI 	   := 0	
	local cGroup   := ""
	local aValues  := {}
	local aWsValues:= {}
	local oUser	   := nil 
	local oSrvUser := CbcUserService():newCbcUserService()
	
	for nI := 1 to Len(aIds)
		if (cOption == TO_USERS)
			oUser  := oSrvUser:findById(aIds[nI])
			cGroup := oSrvUser:getGroupDescription(oUser:getGroup())
			if (oUser:isProspect() .or. oUser:isCustomer())
				cGroup := AllTrim(cGroup)+" - "+AllTrim(oUser:getCustomer():getName())
			endIf	
			aAdd(aValues, {oUser:getId(), oUser:getName(), cGroup})
		elseIf (cOption == TO_GROUPS)
			aAdd(aValues, {aIds[nI], oSrvUser:getGroupName(aIds[nI])})
		endIf
	next nI 
	
	if (cOption == TO_USERS)
		aSort(@aValues, nil, nil, { | x,y | x[3]+x[2] < y[3]+y[2] } )
	elseIf (cOption == TO_GROUPS)
		aSort(@aValues, nil, nil, { | x,y | x[2] < y[2] } )
	endIf
	
	for nI := 1 to Len(aValues)
		
		oWsObj := WsClassNew("WsCbcGenericObject")
				
		oWsObj:id := aValues[nI,1]
		
		if (cOption == TO_USERS)
			oWsObj:value := AllTrim(aValues[nI,2])+" ("+AllTrim(aValues[nI,3])+")"
		elseIf (cOption == TO_GROUPS)
			oWsObj:value := aValues[nI,2]
		endIf
		
		aAdd(aWsValues ,oWsObj)
		
	next nI
	
return aWsValues


/*/{Protheus.doc} delete

Remove uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod delete wsReceive requestDelete wsSend responseDelete wsService CbcMessageWs
	
	local oStatus    := WsClassNew("WsCbcResponseStatus")
	local oService	 := CbcMessageService():newCbcMessageService()
	
	if oService:delete(::requestDelete:messageId)
		oStatus:success := .T.
		oStatus:message := "Mensagem removida com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()
	endIf

	::responseDelete:status := oStatus

return .T.


/*/{Protheus.doc} archive

Arquiva uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod archive wsReceive requestArchive wsSend responseArchive wsService CbcMessageWs
	
	local oStatus    := WsClassNew("WsCbcResponseStatus")
	local oService	 := CbcMessageService():newCbcMessageService()
	
	if oService:archive(::requestArchive:messageId)
		oStatus:success := .T.
		oStatus:message := "Mensagem arquivada com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()
	endIf

	::responseArchive:status := oStatus

return .T.

