#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcOpportunityBalancesApi

API Rest para manutenção do Estoque de Oportunidades do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcOpportunityBalancesApi DESCRIPTION "API Rest para manutenção do Estoque de Oportunidades do Portal Cobrecom"
	
	wsMethod GET description "Rotas GET: /reserves/:branch/:id  /entities/:entity"
			
	wsMethod POST description "Rotas POST: /search-reserves  /search-balances  /interest  /reserve  /cancel"	
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcOpportunityBalancesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "reserves")
		
		lOk := getReserveById(self)
	
	elseIf (cRoute == "entities")	
		
		lOk := getEntities(self)
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcOpportunityBalancesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "search-reserves")	
		
		lOk := searchReserves(self)
	
	elseIf (cRoute == "search-balances")	
		
		lOk := searchBalances(self)
	
	elseIf (cRoute == "interest")	
		
		lOk := interest(self)
	
	elseIf (cRoute == "reserve")
		
		lOk := reserve(self)
		
	elseIf (cRoute == "cancel")	
		
		lOk := cancel(self)				
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna uma Reserva do Estoque de Oportunidades
 */
static function getReserveById(oWs)	
	
	local lOk		   := .F.
	local cBranch	   := ""
	local cId		   := ""
	local oReserve     := nil
	local oUtils	   := LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oService	   := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cBranch := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cId := oWs:aURLParms[3]
	endIf
	
	if Empty(cBranch) .or. Empty(cId)
		oResponse:badRequest("Informe a filial e o numero da reserva")
		return .F.
	endIf
	
	oReserve := oService:getReserveById(cBranch, cId)
	
	if oUtils:isNotNull(oReserve)
		lOk := .T.
		oResponse:send(oReserve:toJsonString())
	else 
		oResponse:notFound()
	endIf	

return lOk			

/**
 * Retorna a Lista de Clientes, Vendedores ou Usuários das Reservas
 */	
static function getEntities(oWs)
	
	local cQuery	   := ""
	local cEntity	   := ""
	local cGroup	   := ""
	local aEntities    := {}
	local oUser		   := nil
	local oEntity	   := nil
	local oUsrEntity   := nil
	local oSql		   := LibSqlObj():newLibSqlObj()
	local oData		   := JsonObject():new()
	local oAuthSrv	   := CbcAuthService():newCbcAuthService()
	local oSrvUser	   := CbcUserService():newCbcUserService()
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validUser(oWs, @oUser)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cEntity := oWs:aURLParms[2]
	endIf
	
	if Empty(cEntity)
		oResponse:badRequest("Informe a entidade desejada")
		return .F.
	endIf
	
	if (cEntity == "customer")
	
		cQuery := " SELECT DISTINCT ZP4_CODCLI+ZP4_LOJCLI [ID], A1_NOME [VALUE] "
		cQuery += " FROM %ZP4.SQLNAME% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  		%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " WHERE %ZP4.NOTDEL% "
	
		if oUser:isSeller()
			cQuery += " AND A1_VEND = '" + oUser:getSeller():getId() + "' "
		endIf
		 	
		cQuery += " ORDER BY 2 "
		 
	elseIf (cEntity == "seller")
		
		cQuery := " SELECT DISTINCT [ID], [VALUE] "
		cQuery += " FROM ( "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP4.SQLNAME% "
		cQuery += " 		INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  			%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = A1_VEND AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP4.NOTDEL% AND A1_VEND != ' ' "
		cQuery += "		UNION ALL "
		cQuery += "  	SELECT DISTINCT A3_COD [ID], A3_NOME [VALUE] "
		cQuery += " 	FROM %ZP4.SQLNAME% "
		cQuery += " 		INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  			%ZP1.XFILIAL% AND ZP1_CODIGO = ZP4_CODUSR AND %ZP1.NOTDEL% "
		cQuery += " 		INNER JOIN %SA3.SQLNAME% ON "
		cQuery += "  			%SA3.XFILIAL% AND A3_COD = ZP1_CODVEN AND %SA3.NOTDEL% "
		cQuery += " 	WHERE %ZP4.NOTDEL% AND ZP1_CODVEN != ' ' ) AS QRY "
		cQuery += " ORDER BY 2 " 
		
	elseIf (cEntity == "user")
		
		cQuery := " SELECT DISTINCT ZP4_CODUSR [ID], ZP1_NOME [VALUE] "
		cQuery += " FROM %ZP4.SQLNAME% "
		cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
		cQuery += "  		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP4_CODUSR AND %ZP1.NOTDEL% "
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += "  		%SA1.XFILIAL% AND A1_COD = ZP4_CODCLI AND A1_LOJA = ZP4_LOJCLI AND %SA1.NOTDEL% "
		cQuery += " WHERE %ZP4.NOTDEL% " 	
		
		if oUser:isSeller()
			cQuery += " AND A1_VEND = '" + oUser:getSeller():getId() + "' "
		endIf
		
		cQuery += " ORDER BY 2 "
		
	endIf
	
	if Empty(cQuery)
		oResponse:badRequest("Entidade invalida")
		return .F. 
	endIf
	
	oSql:newAlias(cQuery) 
	
	while oSql:notIsEof()
		
		oEntity	      := JsonObject():new()
		oEntity["id"] := oSql:getValue("ID")
		
		if (cEntity == "user")
			
			oUsrEntity 		 := oSrvUser:findById(oEntity["id"])
			cGroup	   		 := oSrvUser:getGroupDescription(oUsrEntity:getGroup())			
			oEntity["value"] := AllTrim(Capital(oUsrEntity:getName()))
			
			if (oUsrEntity:isProspect() .or. oUsrEntity:isCustomer())
				oEntity["value"] += " (" + cGroup + " - " + AllTrim(Capital(oUsrEntity:getCustomer():getName())) + ")"
			else
				oEntity["value"] += " (" + cGroup + ")"
			endIf
				
		else
		
			oEntity["value"] := oSql:getValue("AllTrim(Capital(VALUE))")
			
		endIf	
		
		aAdd(aEntities, oEntity) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oData["entities"] := aEntities
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna as Reservas do Estoque de Oportunidades
 */	
static function searchReserves(oWs)
	
	local cUserId	  := ""
	local aReserves	  := {}
	local oBody	      := JsonObject():new()
	local oData		  := JsonObject():new()
	local oUtils	  := LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oService	  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oFilter	  := CbcOpportunityBalanceReserveFilter():newCbcOpportunityBalanceReserveFilter()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	oFilter:setUserId(cUserId)
	oFilter:setStartDate(oUtils:fromJsDate(oBody["startDate"]))
	oFilter:setEndDate(oUtils:fromJsDate(oBody["endDate"]))
	oFilter:setBranch(oBody["branch"])
	oFilter:setStatus(oBody["status"])
	oFilter:setReserveId(oBody["reserveId"])
	oFilter:setCodeCustomer(oBody["customerCode"])
	oFilter:setUnitCustomer(oBody["customerUnit"])
	oFilter:setSeller(oBody["seller"])
	oFilter:setFromUser(oBody["user"])
	
	aReserves 	      := oService:findReserves(oFilter)
	oData["reserves"] := oService:getJsArray(aReserves)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Retorna os Saldos do Estoque de Oportunidades
 */	
static function searchBalances(oWs)
	
	local cUserId	  := ""
	local aBalances	  := {}
	local oBody	      := JsonObject():new()
	local oData		  := JsonObject():new()
	local oUtils	  := LibUtilsObj():newLibUtilsObj()
	local oCustomer   := CbcCustomer():newCbcCustomer()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oService	  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	oCustomer:setCode(oBody["customerCode"])
	oCustomer:setUnit(oBody["customerUnit"]) 
	oCustomer:setProspect(oBody["isProspect"])
	
	aBalances 		  := oService:findBalances(cUserId, oBody["productName"], oBody["productColor"], oBody["productBitola"], oCustomer)
	oData["balances"] := oService:getJsArray(aBalances)
	
	oResponse:send(oData:toJson())

return .T.

/**
 * Manifestação de interesse no Estoque de Oportunidades
 */	
static function interest(oWs)		
return procReserve("interest", oWs)

/**
 * Reserva de Produtos do Estoque de Oportunidades
 */	
static function reserve(oWs)
return procReserve("reserve", oWs)

/**
 * Processamento do Interesse ou Reserva de Produtos
 */
static function procReserve(cType, oWs)

	local lOk 		  := .F.
	local cUserId	  := ""
	local cReserveId  := ""
	local cMsg		  := ""
	local oBranch	  := nil
	local oCustomer	  := nil
	local oBalance	  := nil
	local oProduct	  := nil
	local oBody	      := JsonObject():new()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oService	  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oSrvProduct := CbcProductService():newCbcProductService()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	oBranch  := CbcBranch():newCbcBranch(oBody["branch"])
	oProduct := oSrvProduct:findByCode(oBody["productCode"])
	
	oCustomer := CbcCustomer():newCbcCustomer()
	oCustomer:setCode(oBody["customerCode"])
	oCustomer:setUnit(oBody["customerUnit"])	
			
	oBalance := CbcOpportunityBalance():newCbcOpportunityBalance()		
	oBalance:setBranch(oBranch)
	oBalance:setProduct(oProduct)
	oBalance:setAddress(oBody["address"])
	oBalance:setIdAddress(oBody["idAddress"])
	oBalance:setQuantity(oBody["quantity"])
	oBalance:setTotal(oBody["total"])
	
	if (cType == "interest")	
		cMsg := "Manifestação de interesse recebida com sucesso"
		lOk  := oService:interest(cUserId, oCustomer, oBalance)
	elseIf (cType == "reserve")
		cMsg := "Reserva processada com sucesso"
		lOk  := oService:reserve(cUserId, oCustomer, oBalance, @cReserveId)
	endIf	
	
	if lOk
		if (cType == "interest")
			oResponse:success(cMsg)
		elseIf (cType == "reserve")
			oResponse:send('{ "reserveId": "' + cReserveId + '", "message": "' + cMsg + '" }') 
		endIf		
	else
		oResponse:badRequest(oService:getErrorMessage())
	endIf

return lOk

/**
 * Cancelamento de uma Reserva do Estoque de Oportunidades
 */	
static function cancel(oWs)
	
	local lOk 		  := .F.
	local cUserId	  := ""	
	local oBody	      := JsonObject():new()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oService	  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
	
	if oService:cancelReserve(cUserId, oBody["branch"], oBody["reserveId"])
		lOk := .T.
		oResponse:success()
	else
		oResponse:badRequest(oService:getErrorMessage()) 
	endIf

return lOk
