#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcInvoicesApi

API Rest para manutenção das Notas Fiscais do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcInvoicesApi DESCRIPTION "API Rest para manutenção das Notas Fiscais do Portal Cobrecom"

	wsData startDate
	wsData endDate
	
	wsMethod GET description "Rotas GET:  /invoices/:branch/:id/:series  /customer-invoices/:code/:unit  /order-invoices/:branch/:id"			
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcInvoicesApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "invoices")
		
		lOk := getInvoiceById(self)
		
	elseIf (cRoute == "customer-invoices")	
		
		lOk := getCustomerInvoices(self)
	
	elseIf (cRoute == "order-invoices")	
		
		lOk := getOrderInvoices(self)			
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna uma NF pelo numero e serie
 */
static function getInvoiceById(oWs)
	
	local lOk			:= .F.
	local lDetails		:= .T.
	local cBranch		:= ""
	local cId			:= ""
	local cSeries		:= ""	
	local oData			:= nil
	local oInvoiceList	:= nil
	local oCbcQry 		:= CbcPortalQueries():newCbcPortalQueries()	
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)
		cBranch := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)
		cId := oWs:aURLParms[3]
	endIf
	
	if (Len(oWs:aURLParms) >= 4)
		cSeries := oWs:aURLParms[4]
	endIf
	
	if Empty(cBranch) .or. Empty(cId) .or. Empty(cSeries) 
		oResponse:badRequest("Informe a filial, o numero e a serie da nf")
		return .F.
	endIf
	
	oInvoiceList := oCbcQry:invoiceDetail(cBranch, cId, cSeries)
	
	if (Len(oInvoiceList:oReturn) > 0)
		lOk   := .T.
		oData := createInvoice(oInvoiceList:oReturn[1], lDetails)
		oResponse:send(oData:toJson())
	else	
		oResponse:notFound()
	endIf
	
return lOk

/**
 * Retorna as Notas Fiscais de um cliente
 */
static function getCustomerInvoices(oWs)

	local nI			:= 0
	local cCustomer		:= ""
	local cUnit			:= ""
	local dStartDate	:= CtoD("")
	local dEndDate		:= CtoD("")
	local aInvoices		:= {}		
	local aJsInvoices	:= {}
	local oInvoiceList	:= nil
	local oData			:= JsonObject():new()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oCbcQry 		:= CbcPortalQueries():newCbcPortalQueries()	
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	if !oAuthSrv:validToken(oWs)
		return .F.
	endIf
	
	if (Len(oWs:aURLParms) >= 2)		
		cCustomer := oWs:aURLParms[2]
	endIf
	
	if (Len(oWs:aURLParms) >= 3)		
		cUnit := oWs:aURLParms[3]
	endIf
	
	if !Empty(oWs:startDate)
		dStartDate := oUtils:fromJsDate(oWs:startDate)
	endIf
	
	if !Empty(oWs:endDate)
		dEndDate := oUtils:fromJsDate(oWs:endDate)
	endIf
	
	if Empty(cCustomer) .or. Empty(cUnit) .or. Empty(dStartDate) .or. Empty(dEndDate)
		oResponse:badRequest("Informe o codigo, a loja do cliente e o intervalo de datas")
		return .F.
	endIf	
	
	oInvoiceList 	  := oCbcQry:clientInvoiceList(cCustomer, cUnit, dStartDate, dEndDate)
	aInvoices	 	  := oInvoiceList:oReturn		
	
	for nI := 1 to Len(aInvoices)					
		aAdd(aJsInvoices, createInvoice(aInvoices[nI]))	
	next nI
	
	oData["invoices"] := aJsInvoices
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Retorna as Notas Fiscais de um Pedido de Vendas
 */
static function getOrderInvoices(oWs)

	local nI			:= 0
	local cBranch		:= ""
	local cId			:= ""
	local aInvoices		:= {}		
	local oInvoiceList	:= nil
	local oData			:= JsonObject():new()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oCbcQry 		:= CbcPortalQueries():newCbcPortalQueries()	
	local oAuthSrv		:= CbcAuthService():newCbcAuthService()
	local oResponse 	:= LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
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
		oResponse:badRequest("Informe a filial e o numero do pedido")
		return .F.
	endIf
	
	oInvoiceList 	  := oCbcQry:orderInvoiceList(cBranch, cId)
	aInvoices	 	  := oInvoiceList:oReturn	
	oData["invoices"] := {}
	
	for nI := 1 to Len(aInvoices)					
		aAdd(oData["invoices"], createInvoice(aInvoices[nI]))	
	next nI
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Cria uma NF
 */
static function createInvoice(oObj, lDetails)
	
	local oItem	     := nil
	local oInvoice   := JsonObject():new()
	local oUtils     := LibUtilsObj():newLibUtilsObj()
	default lDetails := .F.
	
	oInvoice["branch"] 		 := oObj:cBranch
	oInvoice["number"] 		 := oObj:cInvoiceNumber
	oInvoice["series"] 	     := oObj:cSerie
	oInvoice["date"]		 := oUtils:getJsDate(StoD(oObj:dIssueData))
	oInvoice["deliveryDate"] := oUtils:getJsDate(StoD(oObj:dDelivery))
	oInvoice["codeCustomer"] := oObj:cCustomer
	oInvoice["unitCustomer"] := oObj:cCustUnit
	oInvoice["nameCustomer"] := oObj:cCustName
	oInvoice["carrier"]		 := oObj:cTransp 
	oInvoice["total"]		 := oObj:nTotal
	oInvoice["items"]		 := {}
	
	if !lDetails
		return oInvoice
	endIf
	
	for nI := 1 to Len(oObj:aItem)	
		
		oItem					:= JsonObject():new()					
		oItem["item"]			:= oObj:aItem[nI]:cItemInv
		oItem["description"]	:= oObj:aItem[nI]:cProductDesc
		oItem["orderItem"]		:= oObj:aItem[nI]:cItemPv
		oItem["salesOrderId"]	:= oObj:aItem[nI]:cOrder
		oItem["quantity"]		:= oObj:aItem[nI]:nSalesQtd
		oItem["price"]			:= oObj:aItem[nI]:nSalesPrice
		oItem["total"]			:= oObj:aItem[nI]:nTotalItm
		
		aAdd(oInvoice["items"], oItem)
	
	next nI

return oInvoice
