#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch" 


/*/{Protheus.doc} CbcCustomerWs

Web Service de Manutenção de Clientes do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcCustomerWs description "Web Service de Manutenção de Clientes do Portal Cobrecom" namespace "http://cobrecom.com.br/cbccustomerws.apw"
	
	wsData requestCustomerByCode as WsCbcRequestCustomerByCode
	wsData responseCustomerByCode as WsCbcResponseCustomerByCode		
	wsData requestCustomerByCnpj as WsCbcRequestCustomerByCnpj
	wsData responseCustomerByCnpj as WsCbcResponseCustomerByCnpj
	wsData requestCreateProspect as WsCbcRequestCreateProspect
	wsData responseCreateProspect as WsCbcResponseCreateProspect
	wsData requestStateCities as WsCbcRequestStateCities
	wsData responseStateCities as WsCbcResponseStateCities
	wsData requestSearchCustomers as WsCbcRequestSearchCustomers
	wsData responseSearchCustomers as WsCbcResponseSearchCustomers
	wsData requestSegments as WsCbcRequestCustomerSegments
	wsData responseSegments as WsCbcResponseCustomerSegments
		
	wsMethod findCustomerByCode description "Retorna um Cliente pelo Código e Loja"
	wsMethod findCustomerByCnpj description "Retorna um Cliente pelo CNPJ"
	wsMethod createProspect description "Criação de Prospects"
	wsMethod getStateCities description "Retorna as Cidades de um Estado"
	wsMethod searchCustomers description "Pesquisa Clientes"  
	wsMethod getSegments description "Retorna os Segmentos dos Clientes"
	
endWsService


/*/{Protheus.doc} findCustomerByCode

Retorna um Cliente pelo Código e Loja
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findCustomerByCode wsReceive requestCustomerByCode wsSend responseCustomerByCode wsService CbcCustomerWs
	
	findCustomer("byCode", ::requestCustomerByCode, @::responseCustomerByCode) 
	
return .T.


/*/{Protheus.doc} findCustomerByCnpj

Retorna um Cliente pelo CNPJ
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findCustomerByCnpj wsReceive requestCustomerByCnpj wsSend responseCustomerByCnpj wsService CbcCustomerWs	
	
	findCustomer("byCnpj", ::requestCustomerByCnpj, @::responseCustomerByCnpj) 
	
return .T.

/**
 * Retorno de Clientes pelo Código e Loja ou pelo CNPJ
 */
static function findCustomer(cOption, oRequest, oResponse)
	
	local oCustomer		:= nil
	local oWsCustomer	:= nil
	local oStatus   	:= WsClassNew("WsCbcResponseStatus")
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oService		:= CbcCustomerService():newCbcCustomerService()	
	
	if (cOption == "byCode")
		oCustomer := oService:findByCode(oRequest:code, oRequest:unit, oRequest:isProspect, oRequest:userId)
	elseIf (cOption == "byCnpj")
		oCustomer := oService:findByCnpj(oRequest:cnpj, oRequest:userId)
	endIf
	
	if oUtils:isNull(oCustomer)
		oStatus:success := .F.
		oStatus:message := "Cliente não encontrado" 
	else
		oStatus:success := .T.
		oStatus:message := "Cliente fornecido com sucesso"
		oWsCustomer		:= oCustomer:toWsObject() 		 
	endIf
	
	oResponse:status   := oStatus
	oResponse:customer := oWsCustomer 
	
return


/*/{Protheus.doc} createProspect

Criação de Prospects
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod createProspect wsReceive requestCreateProspect wsSend responseCreateProspect wsService CbcCustomerWs
	
	local cCode		   := ""
	local cUnit		   := "" 
	local oEvent	   := nil
	local oStatus      := WsClassNew("WsCbcResponseStatus")
	local oWsCustomer  := ::requestCreateProspect:prospect
	local oCustomer	   := CbcCustomer():newCbcCustomer() 
	local oSrvCustomer := CbcCustomerService():newCbcCustomerService()
	local oSrvEvent	   := CbcEventService():newCbcEventService()
	
	oCustomer:fromWsObject(oWsCustomer)
	
	if oSrvCustomer:createProspect(oCustomer, @cCode, @cUnit)
		oStatus:success := .T.
		oStatus:message := "Prospect criado com sucesso"
		oEvent			:= CbcEvent():newCbcEvent(EVENT_PROSPECT_CREATE, nil, "Prospect "+AllTrim(oCustomer:getName())+" criado via Portal")
		oSrvEvent:check(oEvent) 		
	else
		oStatus:success := .F.
		oStatus:message := oSrvCustomer:getErrorMessage()		 		
	endIf
	
	::responseCreateProspect:status := oStatus
	::responseCreateProspect:code 	:= cCode
	::responseCreateProspect:unit 	:= cUnit
	
return .T.


/*/{Protheus.doc} getStateCities

Retorna as Cidades de um Estado
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getStateCities wsReceive requestStateCities wsSend responseStateCities wsService CbcCustomerWs
		
	local oStatus  := WsClassNew("WsCbcResponseStatus")
	local cState   := ::requestStateCities:state
	local aCities  := getWsCities(cState)
		
	if (Len(aCities) > 0)
		oStatus:success := .T.
		oStatus:message := "Cidades fornecidas com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Estado inválido"
	endIf
	
	::responseStateCities:status := oStatus
	::responseStateCities:cities := aCities

return .T.

/**
 * Retorna as Cidades de um Estado
 */
static function getWsCities(cState)
	
	local oWsCity := nil
	local aCities := {}
	local oSql 	  := LibSqlObj():newLibSqlObj()
	
	cState := Upper(AllTrim(cState))
	
	oSql:newTable("CC2", "CC2_CODMUN ID, CC2_MUN NAME", "%CC2.XFILIAL% AND CC2_EST = '"+cState+"'", nil, "CC2_MUN")
	
	while oSql:notIsEof()
		
		oWsCity := WsClassNew("WsCbcCity")
		oWsCity:state := cState
		oWsCity:id    := oSql:getValue("ID")
		oWsCity:name  := oSql:getValue("Capital(NAME)")
		
		aAdd(aCities, oWsCity)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aCities


/*/{Protheus.doc} searchCustomers

Pesquisa Clientes
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod searchCustomers wsReceive requestSearchCustomers wsSend responseSearchCustomers wsService CbcCustomerWs
		
	local oStatus  	 	:= WsClassNew("WsCbcResponseStatus")
	local cUserId  	 	:= ::requestSearchCustomers:userId
	local cKeyWord 	 	:= ::requestSearchCustomers:keyWord
	local cSegment 	 	:= ::requestSearchCustomers:segment
	local lShowBlocked	:= ::requestSearchCustomers:showBlocked
	local oService 	 	:= CbcCustomerService():newCbcCustomerService()
	local aCustomers 	:= oService:search(cUserId, cKeyWord, lShowBlocked, cSegment)		
		
	if (Len(aCustomers) > 0)
		oService:setWsArray(@aCustomers) 
		oStatus:success := .T.
		oStatus:message := "Clientes fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := oService:getErrorMessage() 
	endIf
	
	::responseSearchCustomers:status    := oStatus
	::responseSearchCustomers:customers := aCustomers

return .T.


/*/{Protheus.doc} getSegments

Retorna os Segmentos dos Clientes
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getSegments wsReceive requestSegments wsSend responseSegments wsService CbcCustomerWs
	
	local cQuery 	 := ""	
	local aSegments  := {}	
	local oWsObj	 := nil
	local oStatus  	 := WsClassNew("WsCbcResponseStatus")
	local oSql		 := LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT X5_CHAVE [ID], X5_DESCRI [VALUE] "
	cQuery += " FROM %SX5.SQLNAME% "
	cQuery += " WHERE %SX5.XFILIAL% AND X5_TABELA = 'ZK' AND %SX5.NOTDEL% " 	
	cQuery += " ORDER BY 2 "
	
	oSql:newAlias(cQuery)		
		
	while oSql:notIsEof()
	
		oWsObj       := WsClassNew("WsCbcGenericObject")
		oWsObj:id    := oSql:getValue("AllTrim(ID)")
		oWsObj:value := oSql:getValue("AllTrim(Capital(VALUE))")	
	
		aAdd(aSegments, oWsObj)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
	oStatus:success := .T.
	oStatus:message := "Segmentos fornecidos com sucesso"
	
	::responseSegments:status   := oStatus
	::responseSegments:segments := aSegments

return .T.

