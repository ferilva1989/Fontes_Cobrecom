#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcDashboardApi

API Rest para manutenção do dashboard do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcDashboardApi DESCRIPTION "API Rest para manutenção do dashboard do Portal Cobrecom"
		
	wsMethod GET description "Rotas GET: /quotation-status   /confirmed-quotations  /billing-value  /quotations-waiting-confirmation"
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcDashboardApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "quotation-status")
		
		lOk := getQuotationStatus(self)
		
	elseIf (cRoute == "confirmed-quotations")
	
		lOk := getConfirmedQuotations(self)
	
	elseIf (cRoute == "billing-value")	
	
		lOk := getBillingValue(self)
		
	elseIf (cRoute == "quotations-waiting-confirmation")	
	
		lOk := getWaitingConfirmation(self)
				
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna os Status dos Orçamentos
 */
static function getQuotationStatus(oWs)
	
	local nI		:= 0	
	local aStatus	:= {}			
	local cUserId	:= ""
	local oData		:= nil
	local oStatus   := nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oService	:= CbcDashboardService():newCbcDashboardService()	
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oData   		:= JsonObject():new()
	oData["status"] := {}
	
	aStatus := oService:getQuotationStatus(cUserId)
	
	for nI := 1 to Len(aStatus)
	
		oStatus 	  		   := JsonObject():new()
		oStatus["id"] 	       := aStatus[nI]:statusId
		oStatus["value"] 	   := aStatus[nI]:value
		oStatus["quantity"]    := aStatus[nI]:quantity
		
		aAdd(oData["status"], oStatus)
	
	next nI	
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna os Orçamentos Confirmados
 */
static function getConfirmedQuotations(oWs)
	
	local nI		:= 0	
	local aMonths	:= {}			
	local cUserId	:= ""
	local oData		:= nil
	local oMonth    := nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oService	:= CbcDashboardService():newCbcDashboardService()	
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oData   		:= JsonObject():new()
	oData["months"] := {}
	
	aMonths := oService:getConfirmedQuotations(cUserId)
	
	for nI := 1 to Len(aMonths)
	
		oMonth 	  			:= JsonObject():new()
		oMonth["label"] 	:= aMonths[nI]:month
		oMonth["value"] 	:= aMonths[nI]:value
		oMonth["quantity"] 	:= aMonths[nI]:quantity
		
		aAdd(oData["months"], oMonth)
	
	next nI
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna Totais de Faturamento por Mês
 */
static function getBillingValue(oWs)
	
	local nI		:= 0	
	local aMonths	:= {}			
	local cUserId	:= ""
	local oData		:= nil
	local oMonth    := nil
	local oAuthSrv	:= CbcAuthService():newCbcAuthService()
	local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oService	:= CbcDashboardService():newCbcDashboardService()	
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oData   		:= JsonObject():new()
	oData["months"] := {}
	
	aMonths := oService:getBillingValue(cUserId)
	
	for nI := 1 to Len(aMonths)
	
		oMonth 	  		:= JsonObject():new()
		oMonth["label"] := aMonths[nI]:month
		oMonth["value"] := aMonths[nI]:value
		
		aAdd(oData["months"], oMonth)
	
	next nI
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna Orçamentos aguardando confirmação
 */
static function getWaitingConfirmation(oWs)
	
	local nI		  := 0	
	local aQuotations := {}			
	local cUserId	  := ""
	local oData		  := nil
	local oQuotation  := nil
	local oUtils	  := LibUtilsObj():newLibUtilsObj()
	local oAuthSrv	  := CbcAuthService():newCbcAuthService()
	local oResponse   := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	local oService	  := CbcQuotationService():newCbcQuotationService()	
	
	if !oAuthSrv:validToken(oWs, @cUserId)
		return .F.
	endIf
	
	oData   		    := JsonObject():new()
	oData["quotations"] := {}
	
	aQuotations := oService:getWaitingQuotations(cUserId)
	
	for nI := 1 to Len(aQuotations)
	
		oQuotation 	        		:= JsonObject():new()
		oQuotation["id"]			:= aQuotations[nI]:getId()
		oQuotation["date"]			:= oUtils:getJsDate(aQuotations[nI]:getDate())
		oQuotation["customerName"]	:= aQuotations[nI]:getNameCustomer()
		oQuotation["userName"]		:= aQuotations[nI]:getNameUser()
		oQuotation["sugTotal"]		:= aQuotations[nI]:getSugTotal()
		oQuotation["appTotal"]		:= aQuotations[nI]:getAppTotal()
		
		aAdd(oData["quotations"], oQuotation)
	
	next nI
	
	oResponse:send(oData:toJson())
	
return .T.

