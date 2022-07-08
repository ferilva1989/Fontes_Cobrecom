#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcQuotationsApi

API Rest para manutenção dos orçamentos do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcQuotationsApi DESCRIPTION "API Rest para manutenção dos orçamentos do Portal Cobrecom"

	wsData quotationType
	wsData codeCustomer
	wsData unitCustomer
	wsData family
	wsData bitola
	wsData isRetail
	
	wsMethod GET description "Rotas GET:  /quotations/:id/:revision  /entity-list/:entity  /payment-conditions  /product-families  /bitolas  /product-packages  /attachments-categories"
			
	wsMethod POST description "Rotas POST: /get-product-price  /get-price-from-rg  /search  /create  /finish-maintenance  /take-approval  /giveup-approval  /approve  /disapprove  /undo-approval  /cancel  /lock-update  /unlock-update  /request-tecnical-approval  /confirm  /print  /batch-approval  /batch-price-update  /valid-item"	
	
	wsMethod PUT description "Rotas PUT: /quotations  /update-customer  /update-app-price"
	
	wsMethod DELETE description "Rotas DELETE: /quotations/:id"
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcQuotationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "quotations")
		
		lOk := getQuotationById(self)
		
	elseIf (cRoute == "entity-list")	
		
		lOk := getEntityList(self)
	
	elseIf (cRoute == "payment-conditions")	
		
		lOk := getPaymentConditions(self)
	
	elseIf (cRoute == "product-families")	
		
		lOk := getFamilies(self)
				
	elseIf (cRoute == "bitolas")	
		
		lOk := getBitolas(self)
	
	elseIf (cRoute == "product-packages")	
		
		lOk := getProdPackages(self)		
	
	elseIf (cRoute == "attachments-categories")	
		
		lOk := getAttachmentsCategories(self)
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcQuotationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "get-product-price")	
		
		lOk := getPriceProduct(self)
	
	elseIf (cRoute == "get-price-from-rg")	
		
		lOk := getPriceFromRg(self)
	
	elseIf (cRoute == "search")
		
		lOk := search(self)
		
	elseIf (cRoute == "create")	
		
		lOk := create(self)
	
	elseIf (cRoute == "finish-maintenance")	
		
		lOk := finishMaintenance(self)
		
	elseIf (cRoute == "take-approval")	
		
		lOk := takeApproval(self)
		
	elseIf (cRoute == "giveup-approval")	
		
		lOk := giveupApproval(self)
		
	elseIf (cRoute == "approve")	
		
		lOk := approve(self)
	
	elseIf (cRoute == "activatecanceled")	
		
		lOk := activatecanceled(self)
		
	elseIf (cRoute == "disapprove")	
		
		lOk := disapprove(self)	
		
	elseIf (cRoute == "undo-approval")	
		
		lOk := undoApproval(self)
	
	elseIf (cRoute == "cancel")	
		
		lOk := cancel(self)
		
	elseIf (cRoute == "lock-update")	
		
		lOk := lockUpdate(self)
		
	elseIf (cRoute == "unlock-update")	
		
		lOk := unlockUpdate(self)
		
	elseIf (cRoute == "request-tecnical-approval")	
		
		lOk := requestTecnicalApproval(self)
		
	elseIf (cRoute == "print")	
		
		lOk := print(self)	
		
	elseIf (cRoute == "confirm")	
		
		lOk := confirm(self)	
		
	elseIf (cRoute == "batch-approval")	
		
		lOk := batchApproval(self)		
		
	elseIf (cRoute == "batch-price-update")
	
		lOk := batchPriceUpdate(self)
		
	elseIf (cRoute == "valid-item")
	
		lOk := validItem(self)
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} PUT

Rotas PUT
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod PUT wsService CbcQuotationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "quotations")
		
		lOk := updateQuotation(self)
		
	elseIf (cRoute == "update-customer")	
		
		lOk := updateCustomer(self)
		
	elseIf (cRoute == "update-app-price")	
		
		lOk := updateAppPrice(self)	
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} DELETE

Rotas DELETE
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod DELETE wsService CbcQuotationsApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "quotations")
		
		lOk := delete(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Obtem um orçamento pelo ID
 */
static function getQuotationById(oWs)
	
	local cQuotationId := ""
	local cRevision	   := ""
	local cUserId	   := ""
	local oQuotation   := nil	
	local oJsQuotation := nil
	local nX			:= nil
	local oUtils	   := LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oService 	   := CbcQuotationService():newCbcQuotationService()
	local oSrvUser	   := CbcUserService():newCbcUserService()
	local oSrvCustomer := CbcCustomerService():newCbcCustomerService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local lImpostos		:= .F.

	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cQuotationId := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cRevision := oWs:aURLParms[3]
	endIf
	
	for nX := 1 to len(oWs:aQueryString)
		if oWs:aQueryString[nX][1] == "IMPOSTOS"
			lImpostos := iif(oWs:aQueryString[nX][2] == "true",.T.,.F.)
		endif
	next nX
	
	if Empty(cQuotationId)
		oResponse:badRequest("Informe o ID do orcamento")
		return .F.
	endIf
	
	oQuotation := oService:getById(cQuotationId, cUserId, cRevision, lImpostos)
	
	if oUtils:isNull(oQuotation) 
		oResponse:notFound("ID invalido")
		return .F.
	endIf
	
	oJsQuotation		     := oQuotation:toJsonObject()
	oJsQuotation["user"]     := oSrvUser:findById(oJsQuotation["idUser"]):toJsonObject()
	oJsQuotation["customer"] := oSrvCustomer:findByCode(oJsQuotation["codeCustomer"], oJsQuotation["unitCustomer"], .F., cUserId):toJsonObject()
	
	if !Empty(oJsQuotation["idApprover"])
		oJsQuotation["approver"] := oSrvUser:findById(oJsQuotation["idApprover"]):toJsonObject() 
	endIf	
	
	if !Empty(oJsQuotation["delCodeCustomer"])
		oJsQuotation["deliveryCustomer"] := oSrvCustomer:findByCode(oJsQuotation["delCodeCustomer"], oJsQuotation["delUnitCustomer"], .F., cUserId):toJsonObject() 
	endIf 
	
	oResponse:send(oJsQuotation:toJson())
	
return .T.

/**
 * Retorna a Lista de Entidades Relacionadas aos Orçamentos
 */		
static function getEntityList(oWs)		
	
	local cQuery	:= ""
	local cUserId	:= ""
	local cEntity	:= ""			
	local aList		:= {}
	local oItem		:= nil
	local oUser		:= nil
	local oData		:= JsonObject():new() 	
	local oSql		:= LibSqlObj():newLibSqlObj()
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)	
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf  
	
	if (Len(oWs:aURLParms) >= 2)
		cEntity := oWs:aURLParms[2]
	endIf
	
	if Empty(cEntity)
		oResponse:badRequest("Informe a entidade")
		return .F.
	endIf
	
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
	
		oUser := oSrvUser:findById(cUserId)
	
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
		
	else
	
		oResponse:badRequest("Entidade invalida")
		return .F.
		
	endIf
	
	oSql:newAlias(cQuery) 
	
	while oSql:notIsEof()
		
		oItem		   := JsonObject():new()
		oItem["id"]    := oSql:getValue("ID")
		oItem["value"] := oSql:getValue("AllTrim(VALUE)")	
		
		if (cEntity != "cancel-reason")
			oItem["value"] := Capital(oItem["value"])
		endIf
		
		aAdd(aList, oItem) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oData["list"] := aList
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna a Lista de Condições de Pagamentos
 */		
static function getPaymentConditions(oWs)
	
	local nI			:= 0
	local cQuery		:= ""
	local aValues		:= {}			
	local aConditions	:= {}
	local oCbcCond  	:= nil
	local oCondition	:= nil
	local oUser			:= nil
	local oData			:= JsonObject():new() 	
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local lVldCond		:= GetNewPar("ZZ_ONVLDPG", .T.)
	
	if !oAuthSrv:validUser(oWs, @oUser)
		return .F.
	endIf
	
	if !Empty(oWs:quotationType) .and. (oWs:quotationType == QUOTATION_TYPE_BONUS)
	
		oCondition		   			:= JsonObject():new()
		oCondition["id"]    		:= BONUS_PAYMENT_CONDITION
		oCondition["description"] 	:= oSql:getFieldValue("SE4", "E4_DESCRI", "%SE4.XFILIAL% AND E4_CODIGO = '" + BONUS_PAYMENT_CONDITION + "'")
		oCondition["description"] 	:= AllTrim(oCondition["description"])				
		aConditions		    		:= { oCondition }		
	
	elseIf lVldCond .and. oUser:getGroup() != USER_MANAGER .and. oUser:getGroup() != USER_DIRECTOR .and. oUser:getGroup() != USER_ADMINISTRATOR
		
		oCbcCond := CbcCondPagto():newCbcCondPagto(.T.)
		aValues  := oCbcCond:getPaymentTerms(oWs:codeCustomer, oWs:unitCustomer)
		
		for nI := 1 to Len(aValues)
			oCondition		   		  := JsonObject():new()
			oCondition["id"]    	  := AllTrim(aValues[nI]:id)
			oCondition["description"] := AllTrim(aValues[nI]:value)	
			aAdd(aConditions, oCondition)	
		next nI
		
	else
	
		cQuery := " SELECT E4_CODIGO [ID], E4_DESCRI [DESCRIPTION] "
		cQuery += " FROM %SE4.SQLNAME% "
		cQuery += " WHERE %SE4.XFILIAL% AND E4_XPORTAL = 'S' AND E4_MSBLQL != '1' AND %SE4.NOTDEL% "
		cQuery += " ORDER BY 2 " 
		
		oSql:newAlias(cQuery) 
		
		while oSql:notIsEof()
			
			oCondition		   		  := JsonObject():new()
			oCondition["id"]    	  := oSql:getValue("AllTrim(ID)")
			oCondition["description"] := oSql:getValue("AllTrim(DESCRIPTION)")	
			
			aAdd(aConditions, oCondition)
			
			oSql:skip()
		endDo
		
		oSql:close()
		
	endIf
	
	oData["conditions"] := aConditions
	
	oResponse:send(oData:toJson())	

return .T.

/**
 * Retorna as Familias de Produtos
 */			
static function getFamilies(oWs)
	
	local nI			:= 0
	local aValues		:= {}
	local aFamilies		:= {}
	local cCodeCustomer	:= ""
	local cUnitCustomer	:= ""	
	local cUserId	    := ""
	local lRetail		:= .F.	
	local lUsrEsp	    := .F.
	local oCbcRet		:= nil
	local oFamily		:= nil
	local oCbcProdDet	:= nil
	local oData			:= JsonObject():new()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oSrvUser		:= CbcUserService():newCbcUserService()
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	cCodeCustomer := oWs:codeCustomer
	cUnitCustomer := oWs:unitCustomer
	
	if Empty(cCodeCustomer) .or. Empty(cUnitCustomer)
		oResponse:badRequest("Informe o codigo e a loja do cliente")
		return .F.
	endIf
	
	if !Empty(oWs:isRetail)
		lRetail := (oWs:isRetail == "true")
	endIf

	lUsrEsp := oSrvUser:usrIsGroup({USER_SPECIAL, USER_ADMINISTRATOR, USER_SUPERVISOR}, cUserId)
	oCbcProdDet := CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail, lUsrEsp)	
	oCbcProdDet:getProducts()
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		aValues := oCbcRet:aObjProduct
		for nI := 1 to Len(aValues)
			oFamily 			   := JsonObject():new()
			oFamily["id"]   	   := aValues[nI]:cId
			oFamily["description"] := AllTrim(aValues[nI]:cText)
			aAdd(aFamilies, oFamily)
		next nI
	endIf
	
	oData["families"] := aFamilies
	
	oResponse:send(oData:toJson())	

return .T.

/**
 * Retorna as Bitolas de uma Familia
 */
static function getBitolas(oWs)
	
	local nI			:= 0
	local aValues		:= {}
	local aBitolas		:= {}
	local cUserId	    := ""
	local cCodeCustomer	:= ""
	local cUnitCustomer	:= ""
	local cFamily		:= ""	
	local lRetail		:= .F.	
	local lUsrEsp	    := .F.
	local oCbcRet		:= nil
	local oBitola		:= nil
	local oCbcProdDet	:= nil
	local oData			:= JsonObject():new()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oSrvUser		:= CbcUserService():newCbcUserService()
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	cCodeCustomer := oWs:codeCustomer
	cUnitCustomer := oWs:unitCustomer
	cFamily		  := oWs:family
	
	if Empty(cCodeCustomer) .or. Empty(cUnitCustomer) .or. Empty(cFamily)
		oResponse:badRequest("Informe o codigo, a loja do cliente e a familia de produtos")
		return .F.
	endIf
	
	if !Empty(oWs:isRetail)
		lRetail := (oWs:isRetail == "true")
	endIf
	
	lUsrEsp := oSrvUser:usrIsGroup({USER_SPECIAL, USER_ADMINISTRATOR, USER_SUPERVISOR}, cUserId)
	oCbcProdDet := CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail, lUsrEsp)	
	oCbcProdDet:getGauges(cFamily)
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		aValues := oCbcRet:aObjGauge
		for nI := 1 to Len(aValues)
			oBitola 			   := JsonObject():new()
			oBitola["id"]   	   := aValues[nI]:cId
			oBitola["description"] := AllTrim(aValues[nI]:cText)
			aAdd(aBitolas, oBitola)
		next nI
	endIf
	
	oData["bitolas"] := aBitolas
	
	oResponse:send(oData:toJson())	

return .T.

/**
 * Retorna as Acondicionamentos e Especialidades
 */			
static function getProdPackages(oWs)

	local cUserId	    := ""
	local cCodeCustomer	:= ""
	local cUnitCustomer	:= ""
	local cFamily		:= ""	
	local cBitola		:= ""
	local lRetail		:= .F.
	local lUsrEsp	    := .F.
	local aPackages     := {}
	local aSpecialties  := {}	
	local oCbcRet		:= nil
	local oCbcProdDet	:= nil
	local oData			:= JsonObject():new()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oSrvUser		:= CbcUserService():newCbcUserService()
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	cCodeCustomer := oWs:codeCustomer
	cUnitCustomer := oWs:unitCustomer
	cFamily		  := oWs:family
	cBitola		  := oWs:bitola
	
	if Empty(cCodeCustomer) .or. Empty(cUnitCustomer) .or. Empty(cFamily) .or. Empty(cBitola)
		oResponse:badRequest("Informe o codigo, a loja do cliente, a familia de produtos e a bitola")
		return .F.
	endIf
	
	if !Empty(oWs:isRetail)
		lRetail := (oWs:isRetail == "true")
	endIf

	lUsrEsp := oSrvUser:usrIsGroup({USER_SPECIAL, USER_ADMINISTRATOR, USER_SUPERVISOR}, cUserId)
	oCbcProdDet := CbcProductDetails():newCbcProductDetails(cCodeCustomer, cUnitCustomer, lRetail, lUsrEsp)	
	oCbcProdDet:getPackagings(cFamily, cBitola)
	
	oCbcRet := oCbcProdDet:oCmbResp
	
	if oCbcRet:lOk
		aPackages    := getPackages(oCbcRet)
		aSpecialties := getSpecialties(oCbcRet)
	endIf
	
	oData["packages"] 	 := aPackages
	oData["specialties"] := aSpecialties
	
	oResponse:send(oData:toJson())

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
	local oPackage     := JsonObject():new()
	local oSrvProd	   := CbcProductService():newCbcProductService()
	
	for nI := 1 to Len(oObj:aFootage)
		aAdd(aAmounts, Val(oObj:aFootage[nI]))
	next nI
	
	oPackage["id"] 		    := oObj:cPackage
	oPackage["description"] := oSrvProd:getPackageDescription(oObj:cPackage)
	oPackage["amounts"]	    := aAmounts
	
return oPackage

/**
 * Retorna as Especialidades
 */
static function getSpecialties(oCbcRet)
	
	local nI 	  		:= 0
	local aSpecialties 	:= {}
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
	local oColor	   := nil
	local oSpecialty   := JsonObject():new()
	
	for nI := 1 to Len(oObj:aColor)
		oColor := JsonObject():new()
		oColor["id"]    		  := oObj:aColor[nI,1]
		oColor["description"] 	  := AllTrim(oObj:aColor[nI,2])
		oColor["requireApproval"] := (oObj:aColor[nI,3] == "S")	
		aAdd(aColors, oColor)
	next nI
	
	oSpecialty["id"] 			 := oObj:cSpec
	oSpecialty["colors"]		 := aColors
	oSpecialty["specificColors"] := .F.
	
	nScan := aScan(oCbcRet:aSpecialtys, { |oSpecialty| oSpecialty:cId == oObj:cSpec })
	
	if (nScan > 0)
		oSpecialty["description"] := oCbcRet:aSpecialtys[nScan]:cText
	else
		oSpecialty["specificColors"] := .T.
		oSpecialty["description"] 	 := oObj:cSpec
	endIf	
	
return oSpecialty

/**
 * Retorna informações sobre o Preço dos Produtos
 */			
static function getPriceProduct(oWs)
		
	local nUnitPrice	:= 0
	local cPackage		:= ""
	local cProductCode	:= ""
	local cCodeCustomer := ""
	local cUnitCustomer := ""	
	local cPaymentCond  := ""
	local cFreight	  	:= ""
	local cUserId	    := ""
	local lOk			:= .F.
	local lListPriceOk	:= .F.
	local lRetail		:= .F.
	local lUsrEsp	    := .F.
	local oCbcProdVal	:= nil
	local oUser			:= nil
	local oCustomer	    := nil
	local oData			:= JsonObject():new()
	local oBody			:= JsonObject():new()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oItem			:= CbcQuotationItem():newCbcQuotationItem()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oSrvCustomer	:= CbcCustomerService():newCbcCustomerService()
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId) //newCbcProductDetails
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	cCodeCustomer := oBody["codeCustomer"]
	cUnitCustomer := oBody["unitCustomer"]
	nUnitPrice	  := oBody["unitPrice"]
	cPaymentCond  := oBody["paymentCondition"]
	cFreight	  := oBody["freight"]
	lRetail		  := oBody["isRetail"]
	oUser		  := oSrvUser:findById(oBody["userId"])
		
	oItem:fromJsonObject(oBody["item"])
	
	lUsrEsp := oSrvUser:usrIsGroup({USER_SPECIAL, USER_ADMINISTRATOR, USER_SUPERVISOR}, cUserId)
	cPackage	 := oItem:getIdPackage() + StrZero(oItem:getAmountPackage(), 5)
	cProductCode := oSrvQuotation:getProductCode(cCodeCustomer, cUnitCustomer, oItem, nil, nil, lRetail, lUsrEsp)	
	oCbcProdVal	 := CbcProductValues():newCbcProductValues(cCodeCustomer, cUnitCustomer, cProductCode, cPackage, oItem:getQuantity(), nUnitPrice)
	
	oCbcProdVal:setPayTerm(cPaymentCond)
	oCbcProdVal:setTpFreight(cFreight)
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
	
		lOk := .T.
		
		oData["listPriceId"] 			:= oCbcProdVal:cPriceTable
		oData["listPrice"] 				:= if(Empty(oCbcProdVal:nPrice), 0, oCbcProdVal:nPrice)
		oData["defaultDiscountRange"] 	:= oCbcProdVal:cActDiscRange
		oData["cashPaymentDiscount"] 	:= 0
		oData["freightDiscount"] 		:= 0
		oData["minPrice"]				:= if(Empty(oCbcProdVal:nMinPrice), 0, oCbcProdVal:nMinPrice)	
		oData["minRg"]					:= if(Empty(oCbcProdVal:nMinRg), 0, oCbcProdVal:nMinRg)	
		oData["effectiveDiscountRange"] := oCbcProdVal:cCalcDiscRange
		oData["unitPriceRg"] 			:= if(Empty(oCbcProdVal:nCalcRg), 0, oCbcProdVal:nCalcRg)
		oData["commission"] 			:= if(Empty(oCbcProdVal:nCommission), 0, oCbcProdVal:nCommission)
		
		oResponse:send(oData:toJson())
	
	else
	
		oResponse:badRequest(if (lListPriceOk, oCbcProdVal:cMsg, "Tabela de preco fora de vigencia"))
	
	endIf

return lOk

/**
 * Obtem um Preço Unitário a partir de um RG
 */		
static function getPriceFromRg(oWs)
	
	local cProductCode	:= ""
	local cCodeCustomer	:= ""
	local cUnitCustomer	:= ""
	local lRetail		:= .F.
	local nRg	   		:= 0
	local oData			:= JsonObject():new()
	local oBody			:= JsonObject():new()
	local oCbcProd 		:= CbcProductValues():newCbcProductValues()
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()		
	local oItem			:= CbcQuotationItem():newCbcQuotationItem()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	cCodeCustomer := oBody["codeCustomer"]
	cUnitCustomer := oBody["unitCustomer"]
	lRetail		  := oBody["isRetail"]
	nRg	   		  := oBody["rg"]
	
	oItem:fromJsonObject(oBody["item"])
	
	cProductCode := oSrvQuotation:getProductCode(cCodeCustomer, cUnitCustomer, oItem, nil, nil, lRetail)
	
	oCbcProd:setRetail(lRetail)
	
	oData["price"] := oCbcProd:getPrcFrmRG(nRg, oItem:getQuantity(), cProductCode)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna as categorias de anexos
 */
static function getAttachmentsCategories(oWs)
	
	local aCategories   := {}	
	local oCategory		:= nil
	local oData			:= JsonObject():new()
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oSql:newTable("SX5", "X5_CHAVE [ID], X5_DESCRI [VALUE]", "%SX5.XFILIAL% AND X5_TABELA = '_5'", nil, "X5_CHAVE")
	
	while oSql:notIsEof()
	
		oCategory	 	   := JsonObject():new()
		oCategory["id"]    := oSql:getValue("AllTrim(ID)")
		oCategory["value"] := oSql:getValue("AllTrim(VALUE)")
		
		aAdd(aCategories, oCategory)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oData["categories"] := aCategories
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Pesquisa Orçamentos
 */
static function search(oWs)
	
	local nI		  	:= 0
	local aQuotations 	:= {}
	local aJsQuotations	:= {}
	local cUserId     	:= ""
	local oQuotation	:= nil
	local oBody		  	:= JsonObject():new()
	local oData		  	:= JsonObject():new()
	local oUtils	  	:= LibUtilsObj():newLibUtilsObj()
	local oService 	  	:= CbcQuotationService():newCbcQuotationService()
	local oFilter     	:= CbcQuotationFilter():newCbcQuotationFilter()		
	local oAuthSrv	  	:= CbcAuthService():newCbcAuthService()
	local oResponse   	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	oFilter:setUserId(cUserId)
	oFilter:setStartDate(oUtils:fromJsDate(oBody["startDate"]))
	oFilter:setEndDate(oUtils:fromJsDate(oBody["endDate"]))
	oFilter:setQuotationId(oBody["quotationId"])
	oFilter:setSalesOrderId(oBody["salesOrderId"])
	oFilter:setInvoiceId(oBody["invoiceId"])
	oFilter:setCustomerKeyWord(oBody["customerKeyWord"])
	oFilter:setStatus(oBody["status"])
	oFilter:setOwnerId(oBody["ownerId"])	
	oFilter:setSellerId(oBody["sellerId"])
	oFilter:setManagerId(oBody["managerId"])
	oFilter:setApproval(oBody["approval"])
	oFilter:setCodeCustomer(oBody["codeCustomer"])
	oFilter:setUnitCustomer(oBody["unitCustomer"])
	
	aQuotations := oService:search(oFilter)	
	
	for nI := 1 to Len(aQuotations)
		oQuotation 			   		:= JsonObject():new()
		oQuotation["status"]   		:= aQuotations[nI]:getStatus()
		oQuotation["id"]   	   		:= aQuotations[nI]:getId()
		oQuotation["date"] 			:= oUtils:getJsDate(aQuotations[nI]:getDate())
		oQuotation["time"] 			:= aQuotations[nI]:getTime()  
		oQuotation["nameUser"] 		:= aQuotations[nI]:getNameUser()
		oQuotation["nameCustomer"] 	:= aQuotations[nI]:getNameCustomer()
		oQuotation["sugTotal"] 		:= aQuotations[nI]:getSugTotal()
		oQuotation["appTotal"] 		:= aQuotations[nI]:getAppTotal()
		oQuotation["rules"] 		:= badGuyRules(@aQuotations[nI],oService)
		
		setSearchDocuments(@oQuotation, aQuotations[nI])
		aAdd(aJsQuotations, oQuotation)
		
	next nI
	
	oData["quotations"] := aJsQuotations
	
	oResponse:send(oData:toJson())

return .T.

/**
 	* Obtem descrição das regras que foram violadas
	* 02/07/21-Leonardo
*/
static function badGuyRules(oQuot,oSrv)
	local aOcorr 	:= {}
	local aRules 	:= {}
	local nX		:= 0
	Local oStatic   := IfcXFun():newIfcXFun()
	default oSrv 	:= CbcQuotationService():newCbcQuotationService()
	oQuot:setItems(oStatic:sP(1):callStatic('CbcQuotationService','getItems',@oQuot))
	oSrv:checkRules(@oQuot)
	aRules := oQuot:getRules()
	for nX := 1 to Len(aRules)
		if !aRules[nX]:isOk()
			if aRules[nX]:getType() == QUOTATION_OTHER_RULES
				aadd(aOcorr,alltrim(aRules[nX]:getComments()))
			else
				aadd(aOcorr,alltrim(aRules[nX]:getdescription()))
			endif
		endif
	next nX
return aOcorr

/**
 * Define os documentos de um orçamento na pesquisa
 */
static function setSearchDocuments(oJson, oQuotation)
	
	local nI		    := 0
	local nOrdersCount  := 0
	local nInvoiceCount := 0
	local oDoc		    := nil
	local cLastOrder    := ""
	local cLastInvoice  := ""
	local aDocuments    := oQuotation:getDocuments()
	
	for nI := 1 to Len(aDocuments)
	
		oDoc := aDocuments[nI]
		
		if (oDoc:getType() == QUOTATION_DOC_SALES_ORDER)
			nOrdersCount++
			cLastOrder := oDoc:getId()
		elseIf (oDoc:getType() == QUOTATION_DOC_INVOICE)
			nInvoiceCount++
			cLastInvoice := oDoc:getId()
		endIf
	
	next nI
	
	oJson["ordersCount"]   := nOrdersCount
	oJson["invoicesCount"] := nInvoiceCount
	oJson["lastOrder"] 	   := cLastOrder
	oJson["lastInvoice"]   := cLastInvoice

return

/**
 * Criação de um Orçamento
 */		
static function create(oWs)	
	
	local lOk		  := .F.
	local cId		  := ""
	local cUserId	  := ""
	local oQuotation  := CbcQuotation():newCbcQuotation()
	local oService 	  := CbcQuotationService():newCbcQuotationService()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oQuotation:fromJsonObject(oWs:getContent())
		
	cId := oService:create(oQuotation)
	
	if Empty(cId)
		oResponse:badRequest(oService:getErrorMessage())
	else
		lOk := .T.
		oResponse:send('{ "id": "' + cId + '" }') 
	endIf

return lOk

/**
 * Finaliza a Manutenção de um Orçamento
 */		
static function finishMaintenance(oWs)	
return executeAction(oWs, "finishMaintenance")
		
/**
 * Assume a Aprovação de um Orçamento
 */		
static function takeApproval(oWs)
return executeAction(oWs, "takeApproval")

/**
 * Desiste da Aprovação de um Orçamento
 */		
static function giveupApproval(oWs)	
return executeAction(oWs, "giveupApproval")	

/**
 * Aprovação de um Orçamento
 */		
static function approve(oWs)
return executeAction(oWs, "approve")

/**
 * Reativar orçamento cancelado
 */		
static function activatecanceled(oWs)
return executeAction(oWs, "activatecanceled")


/** 
 * Rejeição da Aprovação de um Orçamento
 */		
static function disapprove(oWs)
return executeAction(oWs, "disapprove")

/**
 * Desfazer a Aprovação/Rejeição de um Orçamento
 */					
static function undoApproval(oWs)
return executeAction(oWs, "undoApproval")

/**
 * Cancelamento de um Orçamento
 */		
static function cancel(oWs)
return executeAction(oWs, "cancel")

/**
 * Bloqueia a alteração de um Orçamento
 */
static function lockUpdate(oWs)
return executeAction(oWs, "lockUpdate")

/**
 * Desbloqueia a alteração de um Orçamento
 */		
static function unlockUpdate(oWs)
return executeAction(oWs, "unlockUpdate")

/**
 * Requisição de Aprovação Técnica dos Orçamentos
 */		
static function requestTecnicalApproval(oWs)
return executeAction(oWs, "requestTecnicalApproval")

/**
 * Confirmação de um Orçamento
 */		
static function confirm(oWs)
return executeAction(oWs, "confirm")

/**
 * Exclusão de um Orçamento
 */
static function delete(oWs)
return executeAction(oWs, "delete") 

/**
 * Executa as ações relacionadas aos Orçamentos
 */
static function executeAction(oWs, cAction)
	
	local lOk		 		:= .F.
	local lMsgHtml			:= .T.
	local oSalesOrderData	:= nil
	local cUserId	 		:= ""
	local cQuotationId		:= ""
	local oBody				:= JsonObject():new()
	local oService 	 		:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oUtils			:= LibUtilsObj():newLibUtilsObj()
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	cQuotationId := oBody["quotationId"]
	
	if (Empty(cQuotationId) .and. Len(oWs:aURLParms) >= 2)
		cQuotationId := oWs:aURLParms[2]
	endIf				
	
	if Empty(cQuotationId)
		oResponse:badRequest("Informe o ID do orcamento")
		return .F.
	endIf
	
	if (cAction == "delete")		
	
		lOk := oService:delete(cUserId, cQuotationId)
		
	elseIf (cAction == "finishMaintenance")
	
		lOk := oService:finishMaintenance(cUserId, cQuotationId)
		
	elseIf (cAction == "takeApproval")
		
		lOk := oService:takeApproval(cUserId, cQuotationId)
		
	elseIf (cAction == "giveupApproval")
		
		lOk := oService:giveUpApproval(cUserId, cQuotationId)
	
	elseIf (cAction == "approve")
		
		lOk := oService:approve(cUserId, cQuotationId)
		
	elseIf (cAction == "activatecanceled")
		
		lOk := oService:activatecanceled(cUserId, cQuotationId)
	
	elseIf (cAction == "disapprove")
		
		lOk := oService:disapprove(cUserId, cQuotationId)	
	
	elseIf (cAction == "undoApproval")
		
		lOk := oService:undoApproval(cUserId, cQuotationId)
	
	elseIf (cAction == "cancel")
		
		lOk := oService:cancel(cUserId, cQuotationId, oBody["reason"], oBody["comments"])
	
	elseIf (cAction == "lockUpdate")
		
		lOk := oService:lockUpdate(cUserId, cQuotationId)
	
	elseIf (cAction == "unlockUpdate")
		
		lOk := oService:unlockUpdate(cUserId, cQuotationId)
	
	elseIf (cAction == "requestTecnicalApproval")
		
		lOk := oService:requestTecnicalApproval(cUserId, cQuotationId)
			
	elseIf (cAction == "confirm")
		
		oSalesOrderData := CbcSalesOrderData():newCbcSalesOrderData()
		oSalesOrderData:fromJsonObject(oBody["salesOrderData"])
		
		lOk := oService:confirm(cUserId, cQuotationId, oSalesOrderData)		
			
	endIf
	
	if lOk 
		oResponse:success()	
	else
		oResponse:badRequest(oService:getErrorMessage(lMsgHtml))	 
	endIf

return lOk

/**
 * Retorna o PDF dos Orçamentos
 */	
static function print(oWs)
	
	local lOk		 		:= .F.
	local cUserId	 		:= ""
	local cQuotationId		:= ""
	local cRevision			:= ""
	local cFolder 	 		:= ""
	local cPdf		 		:= ""
	local oQuotation 		:= nil
	local oReport	 		:= nil
	local oBody				:= JsonObject():new()
	local oUtils	 		:= LibUtilsObj():newLibUtilsObj()
	local oService 	 		:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	cQuotationId := oBody["quotationId"]
	cRevision	 := oBody["revision"]
	
	checkReportFolder(@cFolder)
	
	oQuotation := oService:getById(cQuotationId, cUserId, cRevision)
	
	if oUtils:isNotNull(oQuotation)
	 	
	 	oReport	:= CbcQuotationReport():newCbcQuotationReport(oQuotation, cFolder)	 	
		cPdf    := oReport:run()
		
		oReport:clear()
		
		if File(cPdf)
			lOk	:= .T.
			oResponse:send('{ "link": "' + getPdfLink(cPdf) + '" }') 
		else
			oResponse:badRequest("Falha ao gerar PDF do Orçamento")
		endIf
			
	else
		oResponse:badRequest(oService:getErrorMessage()) 
	endIf	

return lOk

/**
 * Prepara o diretório para geração dos PDFs dos Orçamentos
 */
static function checkReportFolder(cFolder)
	
	local nI	 	:= 0
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
	
return

/**
 * Gera o Link para download do PDF
 */
static function getPdfLink(cPdf)
	
	local cMvPar 	 := if ( PORTAL_REST_API, "ZZ_URLAPI", "ZZ_URLWS" )
	local cWsUrl 	 := GetNewPar(cMvPar, "http://10.211.55.5:8088/ws")
	local cWsReports := "/reports/quotation/"
	local oFile		 := LibFileObj():newLibFileObj(cPdf)
	local cFileName	 := oFile:getFileName()
	local cLink		 := cWsUrl+cWsReports+cFileName
	
return cLink

/**
 * Atualização da Aprovação dos Preços dos Itens dos Orçamentos
 */	
static function updateAppPrice(oWs)
	
	local lOk		:= .F.
	local cUserId	:= ""
	local oBody		:= JsonObject():new()	
	local oItem		:= CbcQuotationItem():newCbcQuotationItem()
	local oService 	:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())	
	oItem:fromJsonObject(oBody["item"])
	
	if oService:updateAppPrice(cUserId, oBody["quotationId"], oItem)		
		lOk := .T.
		oResponse:success()	
	else	
		oResponse:badRequest(oService:getErrorMessage())		
	endIf

return lOk

/**
 * Aprovação em Lote de um Orçamento
 */				
static function batchApproval(oWs)
	
	local lOk				:= .F.
	local cUserId			:= ""
	local cQuotationId		:= ""
	local cOption			:= ""
	local nValue			:= ""
	local cProduct			:= ""
	local cBitola			:= ""
	local cPackage			:= ""
	local lOnlyNotApproved	:= .F.
	local oBody				:= JsonObject():new()	
	local oService 			:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())	
	
	cQuotationId	 := oBody["quotationId"]
	cOption			 := oBody["option"]
	nValue			 := oBody["value"]
	cProduct		 := oBody["product"]
	cBitola			 := oBody["bitola"]
	cPackage		 := oBody["package"]
	lOnlyNotApproved := oBody["onlyNotApproved"]
	
	if oService:batchApproval(cUserId, cQuotationId, cOption, nValue, cProduct, cBitola, cPackage, lOnlyNotApproved)		
		lOk := .T.
		oResponse:success()	
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Alteração em Lote dos Preços
 */				
static function batchPriceUpdate(oWs)
	
	local lOk				:= .F.
	local cUserId			:= ""
	local cQuotationId		:= ""
	local cOption			:= ""
	local nValue			:= ""
	local cProduct			:= ""
	local cBitola			:= ""
	local cPackage			:= ""
	local lOnlyNotApproved	:= .F.
	local oBody				:= JsonObject():new()	
	local oService 			:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())	
	
	cQuotationId	 := oBody["quotationId"]
	cOption			 := oBody["option"]
	nValue			 := oBody["value"]
	cProduct		 := oBody["product"]
	cBitola			 := oBody["bitola"]
	cPackage		 := oBody["package"]
	
	if oService:batchPriceUpdate(cUserId, cQuotationId, cOption, nValue, cProduct, cBitola, cPackage)		
		lOk := .T.
		oResponse:success()	
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Alteração de um Orçamento
 */
static function updateQuotation(oWs)
	
	local lOk		 	:= .F.
	local cUserId	 	:= ""
	local oBody		 	:= JsonObject():new()
	local oQuotation 	:= CbcQuotation():newCbcQuotation()
	local oService 	 	:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv	 	:= CbcAuthService():newCbcAuthService()
	local oResponse  	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	oQuotation:fromJsonObject(oBody["quotation"])		
	
	if oService:update(cUserId, oQuotation, oBody["itemsChanged"])		
		lOk := .T.
		oResponse:success()	
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk		

/**
 * Altera o cliente de um Orçamento
 */				
static function updateCustomer(oWs)
	
	local lOk				:= .F.
	local cUserId			:= ""
	local cQuotationId		:= ""
	local cCodeCustomer		:= ""
	local cUnitCustomer		:= ""
	local oBody				:= JsonObject():new()	
	local oService 			:= CbcQuotationService():newCbcQuotationService()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())	
	
	cQuotationId  := oBody["quotationId"]
	cCodeCustomer := oBody["codeCustomer"]
	cUnitCustomer := oBody["unitCustomer"]
	
	if oService:updateCustomer(cQuotationId, cCodeCustomer, cUnitCustomer, cUserId)		
		lOk := .T.
		oResponse:success()	
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk	


/**
 * Valida os itens do Orçamento
 */
static function validItem(oWs)

	local lOk				:= .F.	
	local cError			:= ""
	local oItem				:= CbcQuotationItem():newCbcQuotationItem()	
	local oCbcManager 		:= CbcBudgetManager():newCbcBudgetManager()
	local oAuthSrv			:= CbcAuthService():newCbcAuthService()
	local oResponse 		:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oItem:fromJsonObject(oWs:getContent())	
	
	if oCbcManager:vldItemQuotation(oItem, @cError)		
		lOk := .T.
		oResponse:success()	
	else
		oResponse:badRequest(cError)
	endIf

return lOk
