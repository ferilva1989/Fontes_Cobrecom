#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcCustomersApi

API Rest para manuten��o de clientes do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcCustomersApi DESCRIPTION "API Rest para manuten��o de clientes do Portal Cobrecom"
		
	wsData prospect	
		
	wsMethod GET description "Rotas GET: /customers/:id/:unit  /cities/:state  /segments  /open-receivables/:id/:unit"
	wsMethod POST description "Rotas POST: /create  /search"
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcCustomersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "customers")
		
		lOk := getByCodeOrCnpj(self)
		
	elseIf (cRoute == "cities")
	
		lOk := getCities(self)
	
	elseIf (cRoute == "segments")
	
		lOk := getSegments(self)
	
	elseIf (cRoute == "open-receivables")
	
		lOk := getOpenReceivables(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk


/*/{Protheus.doc} POST

Rotas POST
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod POST wsService CbcCustomersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "create")
		
		lOk := create(self)
				
	elseIf (cRoute == "search")
		
		lOk := search(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna cliente pelo Codigo/Loja ou pelo CNPJ
 */
static function getByCodeOrCnpj(oWs)
	
	local lOk		:= .F.	
	local lProspect	:= .F.
	local cCode		:= ""
	local cUnit		:= ""
	local cCnpj		:= ""
	local cUserId	:= ""
	local oCustomer	:= nil
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oService	:= CbcCustomerService():newCbcCustomerService()
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf

	if !Empty(oWs:prospect)
		lProspect := (oWs:prospect == "true")
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cCode := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cUnit := oWs:aURLParms[3]
	endIf
	
	if (Len(cCode) > 6)
		cCnpj := cCode
	endIf
	
	if Empty(cCode) .and. Empty(cCnpj)
		oResponse:badRequest("Forneca o codigo/loja ou o CNPJ do cliente")
		return .F.
	endIf
	
	if Empty(cCode) .and. Empty(cUnit)
		oResponse:badRequest("Forneca o codigo e a loja do cliente")
		return .F.
	endIf
	
	if !Empty(cCnpj)
		oCustomer := oService:findByCnpj(cCnpj, cUserId)		
	else
		oCustomer := oService:findByCode(cCode, cUnit, lProspect, cUserId)
	endIf
	
	if oUtils:isNull(oCustomer)
		oResponse:notFound("Cliente nao encontrado")
	else
		lOk := .T.
		oResponse:send(oCustomer:toJsonString())
	endIf	
	
return lOk

/**
 * Retorna as Cidades de um Estado
 */
static function getCities(oWs)
	
	local lOk		:= .F.		
	local cState	:= ""	
	local oData		:= nil
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)	
	
	if (Len(oWs:aURLParms) >= 2)
		cState := oWs:aURLParms[2]
	endIf	
	
	if Empty(cState)
		oResponse:badRequest("Forneca o estado")
		return .F.
	endIf
	
	oData 			:= JsonObject():new()
	oData["cities"]	:= getJsCities(cState)
	
	if (Len(oData["cities"]) == 0)
		oResponse:badRequest("Estado invalido")
	else
		lOk := .T.
		oResponse:send(oData:toJson())
	endIf	
	
return lOk

/**
 * Retorna as Cidades de um Estado em JSON
 */
static function getJsCities(cState)
	
	local oCity 	:= nil
	local aCities   := {}
	local oSql 	    := LibSqlObj():newLibSqlObj()
	
	cState := Upper(AllTrim(cState))
	
	oSql:newTable("CC2", "CC2_CODMUN ID, CC2_MUN NAME", "%CC2.XFILIAL% AND CC2_EST = '"+cState+"'", nil, "CC2_MUN")
	
	while oSql:notIsEof()
		
		oCity 		   := JsonObject():new()
		oCity["state"] := cState
		oCity["id"]    := oSql:getValue("ID")
		oCity["name"]  := oSql:getValue("AllTrim(Capital(NAME))")
		
		aAdd(aCities, oCity)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aCities

/**
 * Retorna os Segmentos dos Clientes
 */
static function getSegments(oWs)
			
	local oData		:= nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	oData 			  := JsonObject():new()
	oData["segments"] := getJsSegments()
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna os Segmentos dos Clientes em JSON
 */
static function getJsSegments()
	
	local cQuery    := ""
	local oSegment 	:= nil
	local aSegments := {}
	local oSql 	    := LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT X5_CHAVE [ID], X5_DESCRI [NAME] "
	cQuery += " FROM %SX5.SQLNAME% "
	cQuery += " WHERE %SX5.XFILIAL% AND X5_TABELA = 'ZK' AND %SX5.NOTDEL% " 	
	cQuery += " ORDER BY 2 "
	
	oSql:newAlias(cQuery)		
		
	while oSql:notIsEof()
	
		oSegment         := JsonObject():new()
		oSegment["id"]   := oSql:getValue("AllTrim(ID)")
		oSegment["name"] := oSql:getValue("AllTrim(Capital(NAME))")	
	
		aAdd(aSegments, oSegment)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aSegments

/**
 * Retorna os Titulos em Aberto de um cliente
 */
static function getOpenReceivables(oWs)
			
	local cCode		:= ""
	local cUnit		:= ""
	local oData		:= nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cCode := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cUnit := oWs:aURLParms[3]
	endIf
	
	if Empty(cCode) .or. Empty(cUnit)
		oResponse:badRequest("Forne�a o codigo e a loja do cliente")
		return .F.
	endIf
	
	oData 			     := JsonObject():new()
	oData["receivables"] := getJsOpenReceivables(cCode, cUnit)
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 *  Retorna os Titulos em Aberto de um cliente em JSON
 */
static function getJsOpenReceivables(cCode, cUnit)
	
	local cQuery    	:= ""
	local oReceivable 	:= nil
	local aReceivables 	:= {}
	local oSql 	    	:= LibSqlObj():newLibSqlObj()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	
	cQuery := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_VALOR, SE1.R_E_C_N_O_ RECNO "
	cQuery += " FROM %SE1.SQLNAME% "
	cQuery += " WHERE E1_FILIAL IN ('01','02', '03') AND E1_CLIENTE = '" + cCode + "' AND E1_LOJA = '" + cUnit + "' AND "
	cQuery += "	      E1_PREFIXO = '1' AND E1_TIPO = 'NF' AND E1_SALDO > 0 AND %SE1.NOTDEL% "  	
	cQuery += " ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VENCREA "
	
	oSql:newAlias(cQuery)		
		
	while oSql:notIsEof()
	
		oReceivable         		:= JsonObject():new()
		oReceivable["prefix"]   	:= oSql:getValue("AllTrim(E1_PREFIXO)")
		oReceivable["id"] 			:= oSql:getValue("AllTrim(E1_NUM)")
		oReceivable["installment"] 	:= oSql:getValue("AllTrim(E1_PARCELA)")
		oReceivable["date"] 		:= oUtils:getJsDate(oSql:getValue("StoD(E1_EMISSAO)"))
		oReceivable["maturityDate"] := oUtils:getJsDate(oSql:getValue("StoD(E1_VENCTO)"))
		oReceivable["realMaturity"] := oUtils:getJsDate(oSql:getValue("StoD(E1_VENCREA)"))
		oReceivable["value"] 		:= oSql:getValue("E1_VALOR")
		oReceivable["expired"] 		:= (oSql:getValue("E1_VENCREA") < DtoS(Date())) 
		oReceivable["recno"] 		:= (oSql:getValue("RECNO")) 		
	
		aAdd(aReceivables, oReceivable)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aReceivables


/**
 * Cria��o de clientes (propspects)
 */
static function create(oWs)
	
	local lOk		   := .F.
	local cCode		   := ""
	local cUnit		   := ""
	local oEvent	   := nil
	local oCustomer	   := CbcCustomer():newCbcCustomer() 
	local oSrvCustomer := CbcCustomerService():newCbcCustomerService()
	local oSrvEvent	   := CbcEventService():newCbcEventService()		
	local oResponse    := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	oCustomer:fromJsonObject(oWs:getContent())
	
	if oSrvCustomer:createProspect(oCustomer, @cCode, @cUnit)
		lOk    := .T.
		oEvent := CbcEvent():newCbcEvent(EVENT_PROSPECT_CREATE, nil, "Prospect " + AllTrim(oCustomer:getName()) + " criado via Portal")
		oSrvEvent:check(oEvent)
		oResponse:send('{ "code": "' + cCode + '", "unit": "' + cUnit + '" }')
	else
		oResponse:badRequest(oSrvCustomer:getErrorMessage()) 		  		
	endIf
	
return lOk

/**
 * Pesquisa Clientes
 */
static function search(oWs)
		
	local nI			:= 0
	local cUserId		:= ""	
	local aCustomers	:= {}
	local oData			:= nil
	local oCustomer	    := nil
	local oBody			:= JsonObject():new()
	local oUtils  		:= LibUtilsObj():newLibUtilsObj()
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oService 		:= CbcCustomerService():newCbcCustomerService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oBody:fromJson(oWs:getContent())
		
	aCustomers 		   := oService:search(cUserId, oBody["keyWord"], oBody["showBlocked"], oBody["segment"])
	oData	   		   := JsonObject():new()
	oData["customers"] := {}
	
	for nI := 1 to Len(aCustomers)
		
		oCustomer 					      := JsonObject():new()
		oCustomer["code"] 			  := aCustomers[nI]:getCode()
		oCustomer["unit"] 			  := aCustomers[nI]:getUnit()
		oCustomer["name"] 			  := aCustomers[nI]:getName()
		oCustomer["formatCnpj"]	  := oUtils:formatCgc(aCustomers[nI]:getCnpj())
		oCustomer["address"] 		  := aCustomers[nI]:getAddress()
		oCustomer["city"] 			  := aCustomers[nI]:getCity()
		oCustomer["state"] 			  := aCustomers[nI]:getState()
    oCustomer["zipCode"] 			:= aCustomers[nI]:getZipCode()
		oCustomer["segment"] 		  := aCustomers[nI]:getSegment()
		oCustomer["lastPurchase"]	:= aCustomers[nI]:getLastPurchase()
		oCustomer["isBlocked"] 		:= aCustomers[nI]:isBlocked()
		oCustomer["recno"]	:= aCustomers[nI]:getRecno()
	
		aAdd(oData["customers"], oCustomer)
		
	next nI
	
	oResponse:send(oData:toJson())		
	
return .T.

