#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch" 


/*/{Protheus.doc} CbcQuotationWs

Web Service de Manutenção de Orçamentos do Portal Cobrecom
	
@author victorhugo
@since 02/06/2016
/*/
wsService CbcQuotationWs description "Web Service de Manutenção de Orçamentos do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcquotationws.apw"
	
	wsData requestEntityList as WsCbcRequestQuotationsEntityList
	wsData responseEntityList as WsCbcResponseQuotationsEntityList
	wsData requestPaymentConditions as WsCbcRequestQuotationPaymentConditions
	wsData responsePaymentConditions as WsCbcResponseQuotationPaymentConditions
	wsData requestSearch as WsCbcRequestSearchQuotations
	wsData responseSearch as WsCbcResponseSearchQuotations
	wsData requestById as WsCbcRequestQuotationById
	wsData responseById as WsCbcResponseQuotationById		
	wsData requestCreate as WsCbcRequestCreateQuotation
	wsData responseCreate as WsCbcResponseCreateQuotation
	wsData requestUpdate as WsCbcRequestUpdateQuotation
	wsData responseUpdate as WsCbcResponseUpdateQuotation
	wsData requestDelete as WsCbcRequestDeleteQuotation
	wsData responseDelete as WsCbcResponseDeleteQuotation
	wsData requestFinishMaintenance as WsCbcRequestFinishMaintenanceQuotation
	wsData responseFinishMaintenance as WsCbcResponseFinishMaintenanceQuotation
	wsData requestTakeApproval as WsCbcRequestTakeApprovalQuotation
	wsData responseTakeApproval as WsCbcResponseTakeApprovalQuotation
	wsData requestGiveUpApproval as WsCbcRequestGiveUpApprovalQuotation
	wsData responseGiveUpApproval as WsCbcResponseGiveUpApprovalQuotation
	wsData requestApprove as WsCbcRequestApproveQuotation
	wsData responseApprove as WsCbcResponseApproveQuotation
	wsData requestDisapprove as WsCbcRequestDisapproveQuotation
	wsData responseDisapprove as WsCbcResponseDisapproveQuotation
	wsData requestUndoApproval as WsCbcRequestUndoApprovalQuotation
	wsData responseUndoApproval as WsCbcResponseUndoApprovalQuotation
	wsData requestCancel as WsCbcRequestCancelQuotation
	wsData responseCancel as WsCbcResponseCancelQuotation
	wsData requestLockUpdate as WsCbcRequestLockUpdateQuotation
	wsData responseLockUpdate as WsCbcResponseLockUpdateQuotation
	wsData requestUnlockUpdate as WsCbcRequestUnlockUpdateQuotation
	wsData responseUnlockUpdate as WsCbcResponseUnlockUpdateQuotation
	wsData requestTecnicalApproval as WsCbcRequestTecnicalApproval
	wsData responseTecnicalApproval as WsCbcResponseTecnicalApproval
	wsData requestPdf as WsCbcRequestQuotationPdf
	wsData responsePdf as WsCbcResponseQuotationPdf
	wsData requestFamilies as WsCbcRequestProductFamilies
	wsData responseFamilies as WsCbcResponseProductFamilies
	wsData requestBitolas as WsCbcRequestBitolas
	wsData responseBitolas as WsCbcResponseBitolas
	wsData requestPackages as WsCbcRequestProductPackages
	wsData responsePackages as WsCbcResponseProductPackages
	wsData requestConfirm as WsCbcRequestConfirmQuotation
	wsData responseConfirm as WsCbcResponseConfirmQuotation
	wsData requestProductPrice as WsCbcRequestProductPrice
	wsData responseProductPrice as WsCbcResponseProductPrice
	wsData requestUpdateAppPrice as WsCbcRequestUpdateAppPrice
	wsData responseUpdateAppPrice as WsCbcResponseUpdateAppPrice
	wsData requestPriceFromRg as WsCbcRequestPriceFromRg
	wsData responsePriceFromRg as WsCbcResponsePriceFromRg
	wsData requestCustomerUpdate as WsCbcRequestQuotationCustomerUpdate
	wsData responseCustomerUpdate as WsCbcResponseQuotationCustomerUpdate
	wsData requestBatchApproval as WsCbcRequestQuotationBatchApproval
	wsData responseBatchApproval as WsCbcResponseQuotationBatchApproval
	wsData requestWaitingConfirmation as WsCbcRequestQuotationWaitingConfirmation
	wsData responseWaitingConfirmation as WsCbcResponseQuotationWaitingConfirmation
	wsData requestAttachmentsCategories as WsCbcRequestAttachmentsCategories
	wsData responseAttachmentsCategories as WsCbcResponseAttachmentsCategories
	
	wsMethod getEntityList description "Retorna a Lista de Entidades Relacionadas aos Orçamentos"
	wsMethod getPaymentConditions description "Retorna a Lista de Condições de Pagamentos"		
	wsMethod search description "Pesquisa Orçamentos"
	wsMethod getById description "Retorna um Orçamento pelo ID"
	wsMethod create description "Criação de um Orçamento"
	wsMethod update description "Atualização de um Orçamento"
	wsMethod delete description "Exclusão de um Orçamento"
	wsMethod finishMaintenance description "Finaliza a Manutenção de um Orçamento"
	wsMethod takeApproval description "Assume a Aprovação de um Orçamento"
	wsMethod giveUpApproval description "Desiste da Aprovação de um Orçamento"
	wsMethod approve description "Aprovação de um Orçamento"
	wsMethod disapprove description "Rejeição da Aprovação de um Orçamento"
	wsMethod undoApproval description "Desfazer a Aprovação/Rejeição de um Orçamento"
	wsMethod cancel description "Cancelamento de um Orçamento"
	wsMethod lockUpdate description "Bloqueia a alteração de um Orçamento"
	wsMethod unlockUpdate description "Desbloqueia a alteração de um Orçamento"
	wsMethod requestTecnicalApproval description "Requisição de Aprovação Técnica dos Orçamentos"
	wsMethod getPdf description "Coleta o PDF dos Orçamentos"
	wsMethod getFamilies description "Retorna as Familias de Produtos"
	wsMethod getBitolas description "Retorna as Bitolas de uma Familia"
	wsMethod getProductPackages description "Retorna as Acondicionamentos e Especialidades"
	wsMethod confirm description "Confirmação de Orçamentos"
	wsMethod getProductPrice description "Retorna informações sobre o Preço dos Produtos"
	wsMethod updateAppPrice description "Atualização da Aprovação dos Preços dos Itens dos Orçamentos"
	wsMethod getPriceFromRg description "Obtem um Preço Unitário a partir de um RG"
	wsMethod updateCustomer description "Altera o cliente de um Orçamento"
	wsMethod batchApproval description "Aprovação em Lote de um Orçamento"
	wsMethod getWaitingConfirmation description "Retorna Orçamentos aguardando confirmação"
	wsMethod getAttachmentsCategories description "Retorna as categorias de anexos"
	
endWsService


/*/{Protheus.doc} getEntityList

Retorna a Lista de Entidades Relacionadas aos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getEntityList wsReceive requestEntityList wsSend responseEntityList wsService CbcQuotationWs

	local aValues	:= {}
	local cUserId	:= ::requestEntityList:userId
	local cEntity	:= AllTrim(Lower(::requestEntityList:entity))
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oUtils	:= LibUtilsObj():newLibUtilsObj()	
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(cUserId)		
	
	if oUtils:isNull(oUser)
		oStatus:success := .F.
		oStatus:message := "Usuário inválido" 
	else	
		aValues := getEntityValues(oUser, cEntity)
		if (Len(aValues) > 0)
			oStatus:success := .T.
			oStatus:message := "Dados fornecidos com sucesso" 
		else
			oStatus:success := .F.
			oStatus:message := "Nenhum registro encontrado"   		 
		endIf
	endIf	
	
	::responseEntityList:status := oStatus
	::responseEntityList:values := aValues
	
return .T.

/**
 * Carrega as Entidades conforme o tipo solicitado
 */
static function getEntityValues(oUser, cEntity)
	
	local aValues	:= {} 
	local cQuery	:= ""
	local oWsObj    := nil
	local oSql		:= LibSqlObj():newLibSqlObj()  
	
	if (cEntity == "seller")
	
		cQuery := " SELECT DISTINCT [ID], [VALUE] "
		cQuery += " FROM ( "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP5.SQLNAME% "
		cQuery += " 		INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  			%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = A1_VEND AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP5.XFILIAL% AND %ZP5.NOTDEL% AND A1_VEND != ' ' "
		cQuery += "		UNION ALL "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP5.SQLNAME% "
		cQuery += " 		INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  			%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = ZP1_CODVEN AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP5.XFILIAL% AND %ZP5.NOTDEL% AND ZP1_CODVEN != ' ' ) AS QRY "
		cQuery += " ORDER BY 2 "
	elseIf (cEntity == "manager")
		cQuery := " SELECT DISTINCT [ID], [VALUE] "
		cQuery += " FROM ( "
		cQuery += "  	SELECT DISTINCT MANAGER.A3_COD [ID], MANAGER.A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP5.SQLNAME% "
		cQuery += " 		INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  			%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
		cQuery += " 		INNER JOIN " + RetSqlName("SA3") + " SELLER ON "
		cQuery += "  			SELLER.A3_FILIAL = '" + xFilial("SA3") + "' AND SELLER.A3_COD = A1_VEND AND SELLER.D_E_L_E_T_ = ' ' "
		cQuery += " 		INNER JOIN " + RetSqlName("SA3") + " MANAGER ON "
		cQuery += "  			MANAGER.A3_FILIAL = '" + xFilial("SA3") + "' AND MANAGER.A3_COD = SELLER.A3_GEREN AND MANAGER.D_E_L_E_T_ = ' ' "
		cQuery += " 	WHERE %ZP5.XFILIAL% AND %ZP5.NOTDEL% AND A1_VEND != ' ' "
		cQuery += "		UNION ALL "
		cQuery += "  	SELECT DISTINCT MANAGER.A3_COD [ID], MANAGER.A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP5.SQLNAME% "
		cQuery += " 		INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  			%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
		cQuery += " 		INNER JOIN " + RetSqlName("SA3") + " SELLER ON "
		cQuery += "  			SELLER.A3_FILIAL = '" + xFilial("SA3") + "' AND SELLER.A3_COD = ZP1_CODVEN AND SELLER.D_E_L_E_T_ = ' ' "
		cQuery += " 		INNER JOIN " + RetSqlName("SA3") + " MANAGER ON "
		cQuery += "  			MANAGER.A3_FILIAL = '" + xFilial("SA3") + "' AND MANAGER.A3_COD = SELLER.A3_GEREN AND MANAGER.D_E_L_E_T_ = ' ' "
		cQuery += " 	WHERE %ZP5.XFILIAL% AND %ZP5.NOTDEL% AND ZP1_CODVEN != ' ' ) AS QRY "
		cQuery += " ORDER BY 2 "	 
	elseIf (cEntity == "user")
		cQuery := " SELECT DISTINCT ZP5_RESPON [ID], ZP1_NOME [VALUE] "
		cQuery += " FROM %ZP5.SQLNAME% "
		cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP5_RESPON AND %ZP1.NOTDEL% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  		%SA1.XFILIAL% AND A1_COD = ZP5_CLIENT AND A1_LOJA = ZP5_LOJA AND %SA1.NOTDEL% "
		cQuery += " WHERE %ZP5.XFILIAL% AND %ZP5.NOTDEL% " 	
		if oUser:isSeller()
			cQuery += " AND A1_VEND = '"+oUser:getSeller():getId()+"' "
		endIf
		cQuery += " ORDER BY 2 "
	elseIf (cEntity == "competitor")
		cQuery := " SELECT ZPF_CODIGO [ID], ZPF_NOME [VALUE] "
		cQuery += " FROM %ZPF.SQLNAME% "
		cQuery += " WHERE %ZPF.XFILIAL% AND %ZPF.NOTDEL% " 	
		cQuery += " ORDER BY 2 "
	elseIf (cEntity == "cancel-reason")
		cQuery := " SELECT X5_CHAVE [ID], X5_DESCRI [VALUE] "
		cQuery += " FROM %SX5.SQLNAME% "
		cQuery += " WHERE %SX5.XFILIAL% AND X5_TABELA = '_3' AND %SX5.NOTDEL% " 	
		cQuery += " ORDER BY 2 "
	endIf
	
	if Empty(cQuery)
		return {} 
	endIf
	
	oSql:newAlias(cQuery) 
	
	while oSql:notIsEof()
		
		oWsObj       := WsClassNew("WsCbcGenericObject")
		oWsObj:id    := oSql:getValue("ID")
		oWsObj:value := oSql:getValue("AllTrim(VALUE)")	
		
		if (cEntity != "cancel-reason")
			oWsObj:value := Capital(oWsObj:value)
		endIf
		
		aAdd(aValues, oWsObj) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aValues


/*/{Protheus.doc} getPaymentConditions

Retorna a Lista de Condições de Pagamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getPaymentConditions wsReceive requestPaymentConditions wsSend responsePaymentConditions wsService CbcQuotationWs

	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local aValues	:= getWsPaymentConditions(::requestPaymentConditions)
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso" 
	
	::responsePaymentConditions:status := oStatus
	::responsePaymentConditions:values := aValues
	
return .T.

/**
 * Coleta as Condições de Pagamento para uso no Portal
 */
static function getWsPaymentConditions(oRequest)
	
	local aValues	:= {} 
	local cQuery	:= ""
	local oWsObj    := nil	
	local oCbcCond  := nil
	local oSql		:= LibSqlObj():newLibSqlObj()
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUser		:= oSrvUser:findById(oRequest:userId)
	local lVldCond	:= GetNewPar("ZZ_ONVLDPG", .T.)
	
	if !Empty(oRequest:quotationType) .and. (oRequest:quotationType == QUOTATION_TYPE_BONUS)
		oWsObj       := WsClassNew("WsCbcGenericObject")
		oWsObj:id    := BONUS_PAYMENT_CONDITION
		oWsObj:value := oSql:getFieldValue("SE4", "E4_DESCRI", "%SE4.XFILIAL% AND E4_CODIGO = '" + BONUS_PAYMENT_CONDITION + "'")
		oWsObj:value := AllTrim(oWsObj:value)		
		aAdd(aValues, oWsObj)
		return aValues
	endIf 	
	
	if lVldCond .and. oUtils:isNotNull(oUser) .and. oUser:getGroup() != USER_MANAGER .and. oUser:getGroup() != USER_DIRECTOR .and. oUser:getGroup() != USER_ADMINISTRATOR	
		oCbcCond := CbcCondPagto():newCbcCondPagto(.T.)
		aValues  := oCbcCond:getPaymentTerms(oRequest:customerCode, oRequest:customerUnit)
		return aValues
	endIf	
	
	cQuery := " SELECT E4_CODIGO [ID], E4_DESCRI [VALUE] "
	cQuery += " FROM %SE4.SQLNAME% "
	cQuery += " WHERE %SE4.XFILIAL% AND E4_XPORTAL = 'S' AND E4_MSBLQL != '1' AND %SE4.NOTDEL% "
	cQuery += " ORDER BY 2 " 
	
	oSql:newAlias(cQuery) 
	
	while oSql:notIsEof()
		
		oWsObj       := WsClassNew("WsCbcGenericObject")
		oWsObj:id    := oSql:getValue("ID")
		oWsObj:value := oSql:getValue("AllTrim(VALUE)")	
		
		aAdd(aValues, oWsObj) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aValues

/*/{Protheus.doc} search

Pesquisa Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod search wsReceive requestSearch wsSend responseSearch wsService CbcQuotationWs
	
	local aQuotations := {}
	local oStatus  	  := WsClassNew("WsCbcResponseStatus")
	local oRequest	  := ::requestSearch
	local oService 	  := CbcQuotationService():newCbcQuotationService()
	local oFilter     := CbcQuotationFilter():newCbcQuotationFilter()			
	
	oFilter:setUserId(oRequest:userId)
	oFilter:setStartDate(oRequest:startDate)
	oFilter:setEndDate(oRequest:endDate)
	oFilter:setQuotationId(oRequest:quotationId)
	oFilter:setSalesOrderId(oRequest:salesOrderId)
	oFilter:setInvoiceId(oRequest:invoiceId)
	oFilter:setCustomerKeyWord(oRequest:customerKeyWord)
	oFilter:setStatus(oRequest:status)
	oFilter:setOwnerId(oRequest:ownerId)	
	oFilter:setSellerId(oRequest:sellerId)
	oFilter:setManagerId(oRequest:managerId)
	oFilter:setApproval(oRequest:approval)
	oFilter:setCodeCustomer(oRequest:codeCustomer)
	oFilter:setUnitCustomer(oRequest:unitCustomer)
	
	aQuotations := oService:search(oFilter)
		
	if (Len(aQuotations) > 0)
		oService:setWsArray(@aQuotations) 
		oStatus:success := .T.
		oStatus:message := "Orçamentos fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage() 
	endIf
	
	::responseSearch:status     := oStatus
	::responseSearch:quotations := aQuotations

return .T.


/*/{Protheus.doc} getById

Retorna um Orçamento pelo ID
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod getById wsReceive requestById wsSend responseById wsService CbcQuotationWs
	
	local oStatus  	  := WsClassNew("WsCbcResponseStatus")
	local oUtils	  := LibUtilsObj():newLibUtilsObj()
	local oService 	  := CbcQuotationService():newCbcQuotationService()
	local oQuotation  := oService:getById(::requestById:quotationId, ::requestById:userId, ::requestById:revision)			
		
	if oUtils:isNotNull(oQuotation) 
		oStatus:success := .T.
		oStatus:message := "Orçamento fornecido com sucesso"
		::responseById:quotation := oQuotation:toWsObject()
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage() 
	endIf
	
	::responseById:status := oStatus

return .T.


/*/{Protheus.doc} create

Criação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod create wsReceive requestCreate wsSend responseCreate wsService CbcQuotationWs
	
	local cId  		 := ""
	local oStatus  	 := WsClassNew("WsCbcResponseStatus")
	local oQuotation := CbcQuotation():newCbcQuotation()
	local oService 	 := CbcQuotationService():newCbcQuotationService()
	
	oQuotation:fromWsObject(::requestCreate:quotation)
		
	cId := oService:create(oQuotation)	
		
	if Empty(cId) 
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()		
	else
		oStatus:success := .T.
		oStatus:message := "Orçamento criado com sucesso" 
	endIf
	
	::responseCreate:status      := oStatus
	::responseCreate:quotationId := cId

return .T.


/*/{Protheus.doc} update

Alteração de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod update wsReceive requestUpdate wsSend responseUpdate wsService CbcQuotationWs
	
	local oStatus  	 	:= WsClassNew("WsCbcResponseStatus")
	local oQuotation 	:= CbcQuotation():newCbcQuotation()
	local oService 	 	:= CbcQuotationService():newCbcQuotationService()
	local cUserId	 	:= ::requestUpdate:userId 			
	local lItemsChanged	:= ::requestUpdate:itemsChanged
		
	oQuotation:fromWsObject(::requestUpdate:quotation)	
		
	if oService:update(cUserId, oQuotation, lItemsChanged) 
		oStatus:success := .T.
		oStatus:message := "Orçamento alterado com sucesso"		
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage()	 
	endIf
	
	::responseUpdate:status := oStatus

return .T.


/*/{Protheus.doc} delete

Exclusão de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod delete wsReceive requestDelete wsSend responseDelete wsService CbcQuotationWs
	
	executeAction("delete", ::requestDelete, @::responseDelete)

return .T.


/*/{Protheus.doc} finishMaintenance

Finaliza a Manutenção de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod finishMaintenance wsReceive requestFinishMaintenance wsSend responseFinishMaintenance wsService CbcQuotationWs
	
	executeAction("finishMaintenance", ::requestFinishMaintenance, @::responseFinishMaintenance)
	
return .T.


/*/{Protheus.doc} takeApproval

Assume a Aprovação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod takeApproval wsReceive requestTakeApproval wsSend responseTakeApproval wsService CbcQuotationWs
	
	executeAction("takeApproval", ::requestTakeApproval, @::responseTakeApproval)

return .T.


/*/{Protheus.doc} giveUpApproval

Desiste da Aprovação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod giveUpApproval wsReceive requestGiveUpApproval wsSend responseGiveUpApproval wsService CbcQuotationWs
	
	executeAction("giveUpApproval", ::requestGiveUpApproval, @::responseGiveUpApproval)

return .T.


/*/{Protheus.doc} approve

Aprovação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod approve wsReceive requestApprove wsSend responseApprove wsService CbcQuotationWs
	
	executeAction("approve", ::requestApprove, @::responseApprove)

return .T.


/*/{Protheus.doc} disapprove

Rejeição da Aprovação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod disapprove wsReceive requestDisapprove wsSend responseDisapprove wsService CbcQuotationWs
	
	executeAction("disapprove", ::requestDisapprove, @::responseDisapprove)

return .T.


/*/{Protheus.doc} undoApproval

Desfazer a Aprovação/Rejeição de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod undoApproval wsReceive requestUndoApproval wsSend responseUndoApproval wsService CbcQuotationWs
	
	executeAction("undoApproval", ::requestUndoApproval, @::responseUndoApproval)

return .T.


/*/{Protheus.doc} cancel

Cancelamento de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod cancel wsReceive requestCancel wsSend responseCancel wsService CbcQuotationWs
	
	executeAction("cancel", ::requestCancel, @::responseCancel)

return .T.


/*/{Protheus.doc} lockUpdate

Bloqueia a alteração de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod lockUpdate wsReceive requestLockUpdate wsSend responseLockUpdate wsService CbcQuotationWs
	
	executeAction("lockUpdate", ::requestLockUpdate, @::responseLockUpdate)

return .T.


/*/{Protheus.doc} unlockUpdate

Desbloqueia a alteração de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod unlockUpdate wsReceive requestUnlockUpdate wsSend responseUnlockUpdate wsService CbcQuotationWs
	
	executeAction("unlockUpdate", ::requestUnlockUpdate, @::responseUnlockUpdate)

return .T.	


/*/{Protheus.doc} requestTecnicalApproval

Requisição de Aprovação Técnica dos Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod requestTecnicalApproval wsReceive requestTecnicalApproval wsSend responseTecnicalApproval wsService CbcQuotationWs
	
	executeAction("requestTecnicalApproval", ::requestTecnicalApproval, @::responseTecnicalApproval)

return .T.


/*/{Protheus.doc} confirm

Confirmação de um Orçamento
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod confirm wsReceive requestConfirm wsSend responseConfirm wsService CbcQuotationWs
	
	executeAction("confirm", ::requestConfirm, @::responseConfirm)

return .T.
	
/**
 * Executa as ações relacionadas aos Orçamentos
 */
static function executeAction(cAction, oRequest, oResponse)
	
	local lOk		 		:= .F.
	local lMsgHtml			:= .T.
	local oSalesOrderData	:= nil
	local cUserId	 		:= oRequest:userId
	local cQuotationId		:= oRequest:quotationId
	local oStatus  	 		:= WsClassNew("WsCbcResponseStatus")
	local oService 	 		:= CbcQuotationService():newCbcQuotationService()			
	
	if (cAction == "delete")
	
		lOk := oService:delete(cUserId, cQuotationId)
		
	elseIf (cAction == "finishMaintenance")
	
		lOk := oService:finishMaintenance(cUserId, cQuotationId)
		
	elseIf (cAction == "takeApproval")
		
		lOk := oService:takeApproval(cUserId, cQuotationId)
		
	elseIf (cAction == "giveUpApproval")
		
		lOk := oService:giveUpApproval(cUserId, cQuotationId)
	
	elseIf (cAction == "approve")
		
		lOk := oService:approve(cUserId, cQuotationId)
		
	elseIf (cAction == "disapprove")
		
		lOk := oService:disapprove(cUserId, cQuotationId)	
	
	elseIf (cAction == "undoApproval")
		
		lOk := oService:undoApproval(cUserId, cQuotationId)
	
	elseIf (cAction == "cancel")
		
		lOk := oService:cancel(cUserId, cQuotationId, oRequest:reason, oRequest:comments)
	
	elseIf (cAction == "lockUpdate")
		
		lOk := oService:lockUpdate(cUserId, cQuotationId)
	
	elseIf (cAction == "unlockUpdate")
		
		lOk := oService:unlockUpdate(cUserId, cQuotationId)
	
	elseIf (cAction == "requestTecnicalApproval")
		
		lOk := oService:requestTecnicalApproval(cUserId, cQuotationId)
			
	elseIf (cAction == "confirm")
		
		oSalesOrderData := CbcSalesOrderData():newCbcSalesOrderData()
		oSalesOrderData:fromWsObject(oRequest:salesOrderData)
		
		lOk := oService:confirm(cUserId, cQuotationId, oSalesOrderData)		
			
	endIf
	
	if lOk 
		oStatus:success := .T.
		oStatus:message := "Operação realizada com sucesso"		
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage(lMsgHtml)	 
	endIf
	
	oResponse:status := oStatus

return


/*/{Protheus.doc} getPdf

Retorna o PDF dos Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsMethod getPdf wsReceive requestPdf wsSend responsePdf wsService CbcQuotationWs
	
	local cFolder 	 	:= ""
	local cPdf		 	:= ""
	local oQuotation 	:= nil
	local oReport	 	:= nil
	local oStatus  	 	:= WsClassNew("WsCbcResponseStatus")	
	local cUserId		:= ::requestPdf:userId
	local cQuotationId	:= ::requestPdf:quotationId
	local cRevision		:= ::requestPdf:quotationRevision
	local oService	 	:= CbcQuotationService():newCbcQuotationService()			
	local oUtils	 	:= LibUtilsObj():newLibUtilsObj()
	
	if !checkReportFolder(@cFolder, @::responsePdf)
		return .T.
	endIf
	
	oQuotation := oService:getById(cQuotationId, cUserId, cRevision)
	
	if oUtils:isNotNull(oQuotation)
	 	
	 	oReport	:= CbcQuotationReport():newCbcQuotationReport(oQuotation, cFolder)
		cPdf    := oReport:run()
		
		oReport:clear()
		if File(cPdf)
			setPdfLink(cPdf, @::responsePdf)
			oStatus:success := .T.
			oStatus:message := "PDF fornecido com sucesso"
		else
			oStatus:success := .F.
			oStatus:message := "Falha ao gerar PDF do Orçamento"
		endIf	
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage() 
	endIf
	
	::responsePdf:status := oStatus
	
return .T.	

/**
 * Prepara o diretório para geração dos PDFs dos Orçamentos
 */
static function checkReportFolder(cFolder, oResponse)
	
	local nI	 	:= 0
	local lOk 	 	:= .T.
	local cFile  	:= ""
	local aFiles 	:= {}
	local dFileDate := CtoD("")
	
	cFolder := "\web\ws\reports\quotation\"
	aFiles  := Directory(cFolder+"*.pdf")
	
	for nI := 1 to Len(aFiles)
		
		cFile := AllTrim(Lower(aFiles[nI,1]))
		
		if !("_orcamento_" $ cFile)
			loop
		endIf
		
		dFileDate := StoD(Left(cFile, 8))
		
		if ((Date() - dFileDate) >= 2)
			FErase(cFolder+cFile)
		endIf
		
	next nI
	
return lOk

/**
 * Gera o Link para download do PDF
 */
static function setPdfLink(cPdf, oResponse)
	
	local cMvPar 	 := if ( PORTAL_REST_API, "ZZ_URLAPI", "ZZ_URLWS" )
	local cWsUrl 	 := GetNewPar(cMvPar, "http://10.211.55.5:8088/ws")
	local cWsReports := "/reports/quotation/"
	local oFile		 := LibFileObj():newLibFileObj(cPdf)
	local cFileName	 := oFile:getFileName()
	local cLink		 := cWsUrl+cWsReports+cFileName
	
	oResponse:link := cLink
	
return


/*/{Protheus.doc} getFamilies

Retorna as Familias de Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getFamilies wsReceive requestFamilies wsSend responseFamilies wsService CbcQuotationWs
	
	local nI			:= 0
	local aValues		:= {}
	local aFamilies		:= {}
	local cCodeCustomer	:= ::requestFamilies:codeCustomer
	local cUnitCustomer	:= ::requestFamilies:unitCustomer	
	local lRetail		:= ::requestFamilies:isRetail
	local oCbcRet		:= nil
	local oWsObj		:= nil
	local oCbcProdDet	:= CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail)
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	
	oCbcProdDet:getProducts()
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		aValues := oCbcRet:aObjProduct
		for nI := 1 to Len(aValues)
			oWsObj := WsClassNew("WsCbcGenericObject")
			oWsObj:id 	 := aValues[nI]:cId
			oWsObj:value := aValues[nI]:cText
			aAdd(aFamilies, oWsObj)
		next nI
	endIf 
	
	if (Len(aFamilies) > 0)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
		::responseFamilies:families := aFamilies
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf
	
	::responseFamilies:status := oStatus

return .T.


/*/{Protheus.doc} getBitolas

Retorna as Bitolas de uma Familia
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getBitolas wsReceive requestBitolas wsSend responseBitolas wsService CbcQuotationWs
	
	local nI			:= 0
	local aValues		:= {}
	local aBitolas		:= {}
	local cCodeCustomer	:= ::requestBitolas:codeCustomer
	local cUnitCustomer	:= ::requestBitolas:unitCustomer
	local cFamily		:= ::requestBitolas:family
	local lRetail		:= ::requestBitolas:isRetail
	local oCbcRet		:= nil
	local oWsObj		:= nil
	local oCbcProdDet	:= CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail)
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	
	oCbcProdDet:getGauges(cFamily)
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		aValues := oCbcRet:aObjGauge
		for nI := 1 to Len(aValues)
			oWsObj := WsClassNew("WsCbcGenericObject")
			oWsObj:id 	 := aValues[nI]:cId
			oWsObj:value := aValues[nI]:cText
			aAdd(aBitolas, oWsObj)
		next nI
	endIf 
	
	if (Len(aBitolas) > 0)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
		::responseBitolas:bitolas := aBitolas
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf
	
	::responseBitolas:status := oStatus
	
return .T.


/*/{Protheus.doc} getProductPackages

Retorna as Acondicionamentos e Especialidades
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getProductPackages wsReceive requestPackages wsSend responsePackages wsService CbcQuotationWs
	
	local cCodeCustomer	:= ::requestPackages:codeCustomer
	local cUnitCustomer	:= ::requestPackages:unitCustomer
	local cFamily		:= ::requestPackages:family
	local cBitola		:= ::requestPackages:bitola
	local lRetail		:= ::requestPackages:isRetail
	local oCbcRet		:= nil
	local oWsObj		:= nil
	local oCbcProdDet	:= CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail)
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	
	oCbcProdDet:getPackagings(cFamily, cBitola)
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		oStatus:success 				 := .T.
		oStatus:message 				 := "Dados fornecidos com sucesso"
		::responsePackages:packages 	 := getPackages(oCbcRet)
		::responsePackages:specialties   := getSpecialties(oCbcRet)
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf
	
	::responsePackages:status := oStatus
	
return .T.

/**
 * Retorna os Acondicionamentos
 */
static function getPackages(oCbcRet)
	
	local nI	    := 0
	local aPackages := {}
	local aValues   := oCbcRet:aObjPkFtage
	
	for nI := 1 to Len(aValues)
		aAdd(aPackages, createPackage(aValues[nI]))	
	next nI
	
return aPackages

/**
 * Cria um Acondicionamento
 */
static function createPackage(oObj)
	
	local nI		   := 0
	local aAmounts     := {}
	local oWsPackage   := WsClassNew("WsCbcProductPackage")
	local oSrvProd	   := CbcProductService():newCbcProductService()
	
	for nI := 1 to Len(oObj:aFootage)
		aAdd(aAmounts, Val(oObj:aFootage[nI]))
	next nI
	
	oWsPackage:id 		   := oObj:cPackage
	oWsPackage:description := oSrvProd:getPackageDescription(oObj:cPackage)
	oWsPackage:amounts	   := aAmounts
	
return oWsPackage


/**
 * Retorna as Especialidades
 */
static function getSpecialties(oCbcRet)
	
	local nI 	  		:= 0
	local aSpecialties 	:= {}
	local oWsSpecialty	:= nil
	local aValues		:= oCbcRet:aObjColorSpec
	
	for nI := 1 to Len(aValues)
		aAdd(aSpecialties, createSpecialty(oCbcRet, aValues[nI]))
	next nI
	
return aSpecialties

/**
 * Cria uma Especialidade
 */
static function createSpecialty(oCbcRet, oObj)
	
	local nI		   := 0
	local nScan		   := 0
	local aColors      := {}
	local oWsObj	   := nil
	local oWsSpecialty := WsClassNew("WsCbcProductSpecialty")
	
	for nI := 1 to Len(oObj:aColor)
		oWsObj 	     			:= WsClassNew("WsCbcProductColor")
		oWsObj:id    			:= oObj:aColor[nI,1]
		oWsObj:description 		:= oObj:aColor[nI,2]
		oWsObj:requireApproval	:= (oObj:aColor[nI,3] == "S")	
		aAdd(aColors, oWsObj)
	next nI
	
	oWsSpecialty:id 			:= oObj:cSpec
	oWsSpecialty:colors			:= aColors
	oWsSpecialty:specificColors	:= .F.
	
	nScan := aScan(oCbcRet:aSpecialtys, { |oSpecialty| oSpecialty:cId == oObj:cSpec })
	
	if (nScan > 0)
		oWsSpecialty:description := oCbcRet:aSpecialtys[nScan]:cText
	else
		oWsSpecialty:specificColors	:= .T.
		oWsSpecialty:description 	:= oObj:cSpec
	endIf	
	
return oWsSpecialty


/*/{Protheus.doc} getProductPrice

Retorna informações sobre o Preço dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getProductPrice wsReceive requestProductPrice wsSend responseProductPrice wsService CbcQuotationWs

	local lListPriceOk	:= .F.		
	local oCbcProdVal	:= nil
	local oItem			:= CbcQuotationItem():newCbcQuotationItem()
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()
	local cProductCode	:= ""	
	local cCodeCustomer	:= ::requestProductPrice:customerCode
	local cUnitCustomer	:= ::requestProductPrice:customerUnit
	local cPaymentCond	:= ::requestProductPrice:paymentCondition
	local cFeight		:= ::requestProductPrice:freight
	local nUnitPrice	:= ::requestProductPrice:unitPrice
	local lRetail		:= ::requestProductPrice:isRetail		
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	local oUser			:= oSrvUser:findById(::requestProductPrice:userId)
	
	oItem:fromWsObject(::requestProductPrice:item)
	
	cPackage	 := oItem:getIdPackage() + StrZero(oItem:getAmountPackage(), 5)
	cProductCode := oSrvQuotation:getProductCode(cCodeCustomer, cUnitCustomer, oItem, nil, nil, lRetail)	
	oCbcProdVal	 := CbcProductValues():newCbcProductValues(cCodeCustomer, cUnitCustomer, cProductCode, cPackage, oItem:getQuantity(), nUnitPrice)
	
	oCbcProdVal:setPayTerm(cPaymentCond)
	oCbcProdVal:setTpFreight(cFeight)
	oCbcProdVal:setRetail(lRetail)	
	
	if oUser:isSeller()
		oCbcProdVal:setSalesMan(oUser:getSeller():getId())
	else
		oCustomer := oSrvCustomer:findByCode(cCodeCustomer, cUnitCustomer)
		if oUtils:isNotNull(oCustomer) .and. oUtils:isNotNull(oCustomer:getSeller())
			oCbcProdVal:setSalesMan(oCustomer:getSeller():getId())
		endIf	
	endIf
	
	oCbcProdVal:initCalc()

	lListPriceOk := oCbcProdVal:isVldPriceTab()
	
	if (oCbcProdVal:lOk .and. lListPriceOk)
		
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
		
		::responseProductPrice:listPriceId 				:= oCbcProdVal:cPriceTable
		::responseProductPrice:listPrice 				:= if(Empty(oCbcProdVal:nPrice), 0, oCbcProdVal:nPrice)
		::responseProductPrice:defaultDiscountRange 	:= oCbcProdVal:cActDiscRange
		::responseProductPrice:cashPaymentDiscount 		:= 0
		::responseProductPrice:freightDiscount 			:= 0
		::responseProductPrice:minPrice					:= if(Empty(oCbcProdVal:nMinPrice), 0, oCbcProdVal:nMinPrice)	
		::responseProductPrice:minRg					:= if(Empty(oCbcProdVal:nMinRg), 0, oCbcProdVal:nMinRg)	
		::responseProductPrice:effectiveDiscountRange 	:= oCbcProdVal:cCalcDiscRange
		::responseProductPrice:unitPriceRg 				:= if(Empty(oCbcProdVal:nCalcRg), 0, oCbcProdVal:nCalcRg)
		::responseProductPrice:commission 				:= if(Empty(oCbcProdVal:nCommission), 0, oCbcProdVal:nCommission)
		
	else
	
		oStatus:success := .F.
		oStatus:message := if (lListPriceOk, oCbcProdVal:cMsg, "Tabela de preço fora de vigência")
		
	endIf
	
	::responseProductPrice:status := oStatus
	
return .T.


/*/{Protheus.doc} updateAppPrice

Atualização da Aprovação dos Preços dos Itens dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod updateAppPrice wsReceive requestUpdateAppPrice wsSend responseUpdateAppPrice wsService CbcQuotationWs
			
	local oItem			:= CbcQuotationItem():newCbcQuotationItem()
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()
	local cUserId		:= ::requestUpdateAppPrice:userId
	local cQuotationId	:= ::requestUpdateAppPrice:quotationId
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	
	oItem:fromWsObject(::requestUpdateAppPrice:item)
	
	if oSrvQuotation:updateAppPrice(cUserId, cQuotationId, oItem)		
		oStatus:success := .T.
		oStatus:message := "Dados atualizados com sucesso"		
	else	
		oStatus:success := .F.
		oStatus:message := oSrvQuotation:getErrorMessage()		
	endIf
	
	::responseUpdateAppPrice:status := oStatus
	
return .T.


/*/{Protheus.doc} getPriceFromRg

Obtem um Preço Unitário a partir de um RG
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getPriceFromRg wsReceive requestPriceFromRg wsSend responsePriceFromRg wsService CbcQuotationWs
	
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()		
	local oItem			:= CbcQuotationItem():newCbcQuotationItem()
	local oCbcProd 		:= CbcProductValues():newCbcProductValues()
	local oStatus  		:= WsClassNew("WsCbcResponseStatus")
	local cProductCode	:= ""
	local cCodeCustomer	:= ::requestPriceFromRg:customerCode
	local cUnitCustomer	:= ::requestPriceFromRg:customerUnit
	local lRetail		:= ::requestPriceFromRg:isRetail
	local nRg	   		:= ::requestPriceFromRg:rg
	
	oItem:fromWsObject(::requestPriceFromRg:item)
	
	cProductCode := oSrvQuotation:getProductCode(cCodeCustomer, cUnitCustomer, oItem, nil, nil, lRetail)
	
	oCbcProd:setRetail(lRetail)
	
	::responsePriceFromRg:price = oCbcProd:getPrcFrmRG(nRg, oItem:getQuantity(), cProductCode)
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"		
	
	::responsePriceFromRg:status := oStatus
	
return .T.


/*/{Protheus.doc} updateCustomer

Altera o cliente de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod updateCustomer wsReceive requestCustomerUpdate wsSend responseCustomerUpdate wsService CbcQuotationWs
	
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()		
	local oStatus  		:= WsClassNew("WsCbcResponseStatus")
	local cUserId		:= ::requestCustomerUpdate:userId
	local cQuotationId	:= ::requestCustomerUpdate:quotationId
	local cCodeCustomer	:= ::requestCustomerUpdate:customerCode
	local cUnitCustomer	:= ::requestCustomerUpdate:customerUnit
	
	if oSrvQuotation:updateCustomer(cQuotationId, cCodeCustomer, cUnitCustomer, cUserId)
		oStatus:success := .T.
		oStatus:message := "Cliente atualizado com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oSrvQuotation:getErrorMessage()
	endIf		
	
	::responseCustomerUpdate:status := oStatus
	
return .T.


/*/{Protheus.doc} batchApproval

Aprovação em Lote de um Orçamento
	
@author victorhugo
@since 01/06/2017
/*/
wsMethod batchApproval wsReceive requestBatchApproval wsSend responseBatchApproval wsService CbcQuotationWs
	
	local oSrvQuotation 	:= CbcQuotationService():newCbcQuotationService()		
	local oStatus  			:= WsClassNew("WsCbcResponseStatus")
	local cUserId			:= ::requestBatchApproval:userId
	local cQuotationId		:= ::requestBatchApproval:quotationId
	local cOption			:= ::requestBatchApproval:option
	local nValue			:= ::requestBatchApproval:value
	local cProduct			:= ::requestBatchApproval:product
	local cBitola			:= ::requestBatchApproval:bitola
	local cPack				:= ::requestBatchApproval:pack
	local lOnlyNotApproved	:= ::requestBatchApproval:onlyNotApproved
	
	if oSrvQuotation:batchApproval(cUserId, cQuotationId, cOption, nValue, cProduct, cBitola, cPack, lOnlyNotApproved)
		oStatus:success := .T.
		oStatus:message := "Orçamento aprovado com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oSrvQuotation:getErrorMessage()
	endIf		
	
	::responseBatchApproval:status := oStatus
	
return .T.


/*/{Protheus.doc} getWaitingConfirmation

Retorna Orçamentos aguardando confirmação
	
@author victorhugo
@since 13/10/2017
/*/
wsMethod getWaitingConfirmation wsReceive requestWaitingConfirmation wsSend responseWaitingConfirmation wsService CbcQuotationWs
	
	local cUserId		:= ::requestWaitingConfirmation:userId
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")	
	local oService		:= CbcQuotationService():newCbcQuotationService()
	local aQuotations 	:= oService:getWaitingQuotations(cUserId)		
	
	oService:setWsArray(@aQuotations)	
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"
	
	::responseWaitingConfirmation:status := oStatus
	::responseWaitingConfirmation:quotations := aQuotations
	
return .T.


/*/{Protheus.doc} getAttachmentsCategories

Retorna as categorias de anexos
	
@author victorhugo
@since 11/09/2018
/*/
wsMethod getAttachmentsCategories wsReceive requestAttachmentsCategories wsSend responseAttachmentsCategories wsService CbcQuotationWs
	
	local aCategories   := {}
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")
	local oWsObj		:= nil
	
	oSql:newTable("SX5", "X5_CHAVE [ID], X5_DESCRI [VALUE]", "%SX5.XFILIAL% AND X5_TABELA = '_5'", nil, "X5_CHAVE")
	
	while oSql:notIsEof()
	
		oWsObj 		 := WsClassNew("WsCbcGenericObject")
		oWsObj:id 	 := oSql:getValue("AllTrim(ID)")
		oWsObj:value := oSql:getValue("AllTrim(VALUE)")
		
		aAdd(aCategories, oWsObj)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"
	
	::responseAttachmentsCategories:status 	   := oStatus
	::responseAttachmentsCategories:categories := aCategories

return .T.

