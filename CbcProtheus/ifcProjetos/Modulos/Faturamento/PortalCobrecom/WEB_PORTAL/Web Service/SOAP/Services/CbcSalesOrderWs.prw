#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcSalesOrderWs

Web Service de Manutenção de Pedidos de Vendas do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsService CbcSalesOrderWs description "Web Service de Manutenção de Pedidos de Vendas do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcsalesorderws.apw"
	
	wsData requestCustomerOrders as WsCbcRequestCustomerSalesOrders
	wsData responseCustomerOrders as WsCbcResponseCustomerSalesOrders
	wsData requestById as WsCbcRequestSalesOrderById
	wsData responseById as WsCbcResponseSalesOrderById	
	
	wsMethod getCustomerOrders description "Retorna os Pedidos de Vendas de um cliente"
	wsMethod getById description "Retorna um Pedido de Vendas pelo número"	
	
endWsService


/*/{Protheus.doc} getCustomerOrders

Retorna os Pedidos de Vendas de um cliente
	
@author victorhugo
@since 25/10/2017
/*/
wsMethod getCustomerOrders wsReceive requestCustomerOrders wsSend responseCustomerOrders wsService CbcSalesOrderWs
	
	local nI				:= 0
	local cCustomer			:= ::requestCustomerOrders:codeCustomer
	local cUnit				:= ::requestCustomerOrders:unitCustomer
	local dStartDate		:= ::requestCustomerOrders:startDate
	local dEndDate			:= ::requestCustomerOrders:endDate
	local aWsList			:= {}
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oCbcQry 			:= CbcPortalQueries():newCbcPortalQueries()	
	local oOrderList		:= oCbcQry:clientOrderList(cCustomer, cUnit, dStartDate, dEndDate)	
	local aSalesOrders		:= oOrderList:oReturn
	
	for nI := 1 to Len(aSalesOrders)					
		aAdd(aWsList, createWsSalesOrder(aSalesOrders[nI]))	
	next nI
	
	if (Len(aWsList) > 0)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"
	endIf	
	
	::responseCustomerOrders:status := oStatus
	::responseCustomerOrders:orders := aWsList
	
return .T.


/*/{Protheus.doc} getById

Retorna um Pedido de Vendas pelo número
	
@author victorhugo
@since 25/10/2017
/*/
wsMethod getById wsReceive requestById wsSend responseById wsService CbcSalesOrderWs
	
	local lDetails			:= .T.
	local cBranch			:= ::requestById:branch
	local cSalesOrderId		:= ::requestById:salesOrderId
	local oWsSalesOrder		:= nil
	local oStatus   		:= WsClassNew("WsCbcResponseStatus")
	local oCbcQry 			:= CbcPortalQueries():newCbcPortalQueries()	
	local oOrderList		:= oCbcQry:orderDet(cBranch, cSalesOrderId)
	
	if (Len(oOrderList:oReturn) > 0)		
		oWsSalesOrder 	:= createWsSalesOrder(oOrderList:oReturn[1], lDetails)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
	else
		oStatus:success := .F.
		oStatus:message := "Pedido não encontrado"
	endIf
	
	::responseById:status 	  := oStatus
	::responseById:salesOrder := oWsSalesOrder
	
return .T.

/**
 * Cria um Pedido de Vendas para o WS
 */
static function createWsSalesOrder(oObj, lDetails)
	
	local nI			:= 0
	local oWsItem		:= nil
	local oItem			:= nil
	local oWsSalesOrder := WsClassNew("WsCbcSalesOrder")
	default lDetails	:= .F.
			
	oWsSalesOrder:branch 		  := oObj:cBranch
	oWsSalesOrder:id 			  := oObj:cOrderNum
	oWsSalesOrder:date   		  := StoD(oObj:dIssueDate)
	oWsSalesOrder:nameCustomer 	  := oObj:cNameClient
	oWsSalesOrder:colorStatus 	  := oObj:cColor
	oWsSalesOrder:iconStatus 	  := oObj:cIcon
	oWsSalesOrder:status 		  := oObj:cStatus
	oWsSalesOrder:total 		  := oObj:nTotal	
	oWsSalesOrder:items			  := {}
	oWsSalesOrder:deliveryDate 	  := StoD(oObj:dDeliveryDate)
	oWsSalesOrder:quotationId	  := AllTrim(oObj:cQuotationId)
	oWsSalesOrder:dateQuotation	  := StoD(oObj:dDateQuotation)
	oWsSalesOrder:dtProcQuotation := StoD(oObj:dDtProcQuotation)
	
	if !lDetails
		return oWsSalesOrder
	endIf		
	
	for nI := 1 to Len(oObj:aItem)
	
		oItem := oObj:aItem[nI]
		
		oWsItem := WsClassNew("WsCbcSalesOrderItem")
		oWsItem:item				:= oItem:cItem
		oWsItem:description			:= oItem:cDescription
		oWsItem:fullDescription		:= oItem:cFullDescription
		oWsItem:package				:= oItem:cPackage
		oWsItem:product				:= oItem:cProduct
		oWsItem:quantity			:= oItem:nSalesQuant
		oWsItem:invoiceQuantity		:= oItem:nInvoiceQuant
		oWsItem:lances				:= oItem:nLances	
		oWsItem:meters				:= oItem:nMetrage
		oWsItem:price				:= oItem:nSalesPrice	
		oWsItem:total				:= oItem:nValue
		oWsItem:colorStatus			:= oItem:cItmColor
		oWsItem:iconStatus			:= oItem:cItmIcon
		oWsItem:status				:= oItem:cItmStatus	
		
		aAdd(oWsSalesOrder:items, oWsItem)
	
	next nI
	
return oWsSalesOrder

