#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcDashboardWs

Web Service do Dashboard do Portal Cobrecom
	
@author victorhugo
@since 11/10/2017
/*/
wsService CbcDashboardWs description "Web Service do Dashboard do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcdashboardws.apw"

	wsData requestQuotationStatus as WsCbcRequestQuotationStatus
	wsData responseQuotationStatus as WsCbcResponseQuotationStatus
	wsData requestConfirmedQuotations as WsCbcRequestConfirmedQuotations
	wsData responseConfirmedQuotations as WsCbcResponseConfirmedQuotations
	wsData requestBillingValue as WsCbcRequestBillingValue
	wsData responseBillingValue as WsCbcResponseBillingValue
	
	wsMethod getQuotationStatus description "Retorna os Status dos Orçamentos"
	wsMethod getConfirmedQuotations description "Retorna os Orçamentos Confirmados"
	wsMethod getBillingValue description "Retorna Totais de Faturamento por Mês"

endWsService


/*/{Protheus.doc} getQuotationStatus

Retorna os Status dos Orçamentos
	
@author victorhugo
@since 11/10/2017
/*/
wsMethod getQuotationStatus wsReceive requestQuotationStatus wsSend responseQuotationStatus wsService CbcDashboardWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestQuotationStatus
	local oService	:= CbcDashboardService():newCbcDashboardService()
	local aData		:= oService:getQuotationStatus(oRequest:userId)	
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"
	
	::responseQuotationStatus:status := oStatus
	::responseQuotationStatus:data 	 := aData 
	
return .T.


/*/{Protheus.doc} getConfirmedQuotations

Retorna os Orçamentos Confirmados
	
@author victorhugo
@since 11/10/2017
/*/
wsMethod getConfirmedQuotations wsReceive requestConfirmedQuotations wsSend responseConfirmedQuotations wsService CbcDashboardWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestConfirmedQuotations
	local oService	:= CbcDashboardService():newCbcDashboardService()
	local aData		:= oService:getConfirmedQuotations(oRequest:userId)	
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"
	
	::responseConfirmedQuotations:status := oStatus
	::responseConfirmedQuotations:data 	 := aData 
	
return .T.


/*/{Protheus.doc} getBillingValue

Retorna Totais de Faturamento por Mês
	
@author victorhugo
@since 11/10/2017
/*/
wsMethod getBillingValue wsReceive requestBillingValue wsSend responseBillingValue wsService CbcDashboardWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oRequest 	:= ::requestBillingValue
	local oService	:= CbcDashboardService():newCbcDashboardService()
	local aData		:= oService:getBillingValue(oRequest:userId)	
	
	oStatus:success := .T.
	oStatus:message := "Dados fornecidos com sucesso"
	
	::responseBillingValue:status := oStatus
	::responseBillingValue:data   := aData 
	
return .T.