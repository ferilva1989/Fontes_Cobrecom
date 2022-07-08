#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcInvoiceWs

Web Service de Manutenção de Notas Fiscais do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsService CbcInvoiceWs description "Web Service de Manutenção de Notas Fiscais do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcinvoicews.apw"
	
	wsData requestCustomerInvoices as WsCbcRequestCustomerInvoices
	wsData responseCustomerInvoices as WsCbcResponseCustomerInvoices
	wsData requestById as WsCbcRequestInvoiceById
	wsData responseById as WsCbcResponseInvoiceById	
	wsData requestOrderInvoices as WsCbcRequestOrderInvoices
	wsData responseOrderInvoices as WsCbcResponseOrderInvoices
	
	wsMethod getCustomerInvoices description "Retorna as Notas Fiscais de um cliente"
	wsMethod getById description "Retorna uma Nota Fiscal pelo número e série"
	wsMethod getOrderInvoices description "Retorna as Notas Fiscais de um Pedido de Vendas"	
	
endWsService


/*/{Protheus.doc} getCustomerInvoices

Retorna as Notas Fiscais de um cliente
	
@author victorhugo
@since 25/10/2017
/*/
wsMethod getCustomerInvoices wsReceive requestCustomerInvoices wsSend responseCustomerInvoices wsService CbcInvoiceWs
	
	local nI				:= 0
	local cCustomer			:= ::requestCustomerInvoices:codeCustomer
	local cUnit				:= ::requestCustomerInvoices:unitCustomer
	local dStartDate		:= ::requestCustomerInvoices:startDate
	local dEndDate			:= ::requestCustomerInvoices:endDate
	local aWsList			:= {}
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oCbcQry 			:= CbcPortalQueries():newCbcPortalQueries()	
	local oInvoiceList		:= oCbcQry:clientInvoiceList(cCustomer, cUnit, dStartDate, dEndDate)				
	local aInvoices			:= oInvoiceList:oReturn
	
	for nI := 1 to Len(aInvoices)					
		aAdd(aWsList, createWsInvoice(aInvoices[nI]))	
	next nI
	
	if (Len(aWsList) > 0)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf	
	
	::responseCustomerInvoices:status   := oStatus
	::responseCustomerInvoices:invoices := aWsList
		
return .T.


/*/{Protheus.doc} getById

Retorna uma Nota Fiscal pelo número
	
@author victorhugo
@since 25/10/2017
/*/
wsMethod getById wsReceive requestById wsSend responseById wsService CbcInvoiceWs
	
	local lDetails			:= .T.
	local cBranch			:= ::requestById:branch
	local cInvoiceNumber	:= ::requestById:invoiceNumber
	local cSeries			:= ::requestById:series
	local oWsInvoice		:= nil
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oCbcQry 			:= CbcPortalQueries():newCbcPortalQueries()	
	local oInvoiceList		:= oCbcQry:invoiceDetail(cBranch, cInvoiceNumber, cSeries)	
	
	if (Len(oInvoiceList:oReturn) > 0)		
		oWsInvoice 		:= createWsInvoice(oInvoiceList:oReturn[1], lDetails)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Pedido não encontrado"
	endIf
	
	::responseById:status  := oStatus
	::responseById:invoice := oWsInvoice
		
return .T.

/**
 * Cria uma Nota Fiscal para o WS
 */
static function createWsInvoice(oObj, lDetails)
	
	local nI		 := 0
	local oWsItem	 := nil
	local oItem		 := nil
	local oWsInvoice := WsClassNew("WsCbcInvoice")
	default lDetails := .F.
			
	oWsInvoice:branch 			:= oObj:cBranch
	oWsInvoice:number 			:= oObj:cInvoiceNumber
	oWsInvoice:series 			:= oObj:cSerie
	oWsInvoice:date		   		:= StoD(oObj:dIssueData)
	oWsInvoice:deliveryDate		:= StoD(oObj:dDelivery)
	oWsInvoice:codeCustomer 	:= oObj:cCustomer
	oWsInvoice:unitCustomer 	:= oObj:cCustUnit
	oWsInvoice:nameCustomer 	:= oObj:cCustName
	oWsInvoice:carrier			:= oObj:cTransp 
	oWsInvoice:total			:= oObj:nTotal
	oWsInvoice:items			:= {}
	
	if !lDetails
		return oWsInvoice
	endIf
	
	for nI := 1 to Len(oObj:aItem)
	
		oItem := oObj:aItem[nI]	
		
		oWsItem := WsClassNew("WsCbcInvoiceItem")					
		oWsItem:item			:= oItem:cItemInv
		oWsItem:description		:= oItem:cProductDesc
		oWsItem:orderItem		:= oItem:cItemPv
		oWsItem:salesOrderId	:= oItem:cOrder
		oWsItem:quantity		:= oItem:nSalesQtd
		oWsItem:price			:= oItem:nSalesPrice
		oWsItem:total			:= oItem:nTotalItm
		
		aAdd(oWsInvoice:items, oWsItem)
	
	next nI
	
return oWsInvoice
	

/*/{Protheus.doc} getOrderInvoices

Retorna as Notas Fiscais de um Pedido de Vendas
	
@author victorhugo
@since 25/10/2017
/*/
wsMethod getOrderInvoices wsReceive requestOrderInvoices wsSend responseOrderInvoices wsService CbcInvoiceWs
	
	local nI				:= 0
	local cBranch			:= ::requestOrderInvoices:branch
	local cSalesOrderId		:= ::requestOrderInvoices:salesOrderId
	local aWsList			:= {}
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oCbcQry 			:= CbcPortalQueries():newCbcPortalQueries()	
	local oInvoiceList		:= oCbcQry:orderInvoiceList(cBranch, cSalesOrderId)				
	local aInvoices			:= oInvoiceList:oReturn
	
	for nI := 1 to Len(aInvoices)					
		aAdd(aWsList, createWsInvoice(aInvoices[nI]))	
	next nI
	
	if (Len(aWsList) > 0)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf	
	
	::responseOrderInvoices:status   := oStatus
	::responseOrderInvoices:invoices := aWsList
		
return .T.