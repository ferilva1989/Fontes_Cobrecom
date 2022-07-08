#include "totvs.ch"
#include "restful.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcSalesOrdersApi

API Rest para manutenção dos Pedidos de Vendas do Portal Cobrecom
	
@author victorhugo
@since 08/10/2018
/*/
wsRestful CbcSalesOrdersApi DESCRIPTION "API Rest para manutenção dos Pedidos de Vendas do Portal Cobrecom"

	wsData startDate
	wsData endDate
	
	wsMethod GET description "Rotas GET:  /orders/:branch/:id  /customer-orders/:code/:unit"			
	
end wsRestful


/*/{Protheus.doc} GET

Rotas GET
	
@author victorhugo
@since 08/10/2018
/*/
wsMethod GET wsService CbcSalesOrdersApi
	
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	if (cRoute == "orders")
		
		lOk := getOrderById(self)
		
	elseIf (cRoute == "customer-orders")	
		
		lOk := getCustomerOrders(self)		
	
	else
		
		oResponse:notFound("Rota invalida")
				
	endIf

return lOk

/**
 * Retorna um pedido pelo numero
 */
static function getOrderById(oWs)
	
	local lOk			:= .F.
	local lDetails		:= .T.
	local cBranch		:= ""
	local cId			:= ""
	local oData			:= nil
	local oOrderList	:= nil
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
	
	oOrderList := oCbcQry:orderDet(cBranch, cId)
	
	if (Len(oOrderList:oReturn) > 0)
		lOk   := .T.
		oData := createOrder(oOrderList:oReturn[1], lDetails)
		oResponse:send(oData:toJson())
	else	
		oResponse:notFound()
	endIf
	
return lOk

/**
 * Retorna os pedidos de um cliente
 */
static function getCustomerOrders(oWs)

	local nI			:= 0
	local cCustomer		:= ""
	local cUnit			:= ""
	local dStartDate	:= CtoD("")
	local dEndDate		:= CtoD("")
	local aOrders		:= {}		
	local oOrderList	:= nil
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
	
	oOrderList 	    := oCbcQry:clientOrderList(cCustomer, cUnit, dStartDate, dEndDate)
	aOrders	 	    := oOrderList:oReturn	
	oData["orders"] := {}
	
	for nI := 1 to Len(aOrders)					
		aAdd(oData["orders"], createOrder(aOrders[nI]))	
	next nI
	
	oResponse:send(oData:toJson())
	
return .T.

/**
 * Cria um pedido
 */
static function createOrder(oObj, lDetails)
	
	local oItem	     := nil
	local oOrder     := JsonObject():new()
	local oUtils     := LibUtilsObj():newLibUtilsObj()
	default lDetails := .F.
	
	oOrder["branch"] 		  := oObj:cBranch
	oOrder["id"] 			  := oObj:cOrderNum
	oOrder["date"]   		  := oUtils:getJsDate(StoD(oObj:dIssueDate))
	oOrder["nameCustomer"] 	  := oObj:cNameClient
	oOrder["colorStatus"] 	  := oObj:cColor
	oOrder["iconStatus"] 	  := oObj:cIcon
	oOrder["status"] 		  := oObj:cStatus
	oOrder["total"] 		  := oObj:nTotal	
	oOrder["items"]			  := {}
	oOrder["deliveryDate"] 	  := oUtils:getJsDate(StoD(oObj:dDeliveryDate))
	oOrder["quotationId"]	  := AllTrim(oObj:cQuotationId)
	oOrder["dateQuotation"]	  := oUtils:getJsDate(StoD(oObj:dDateQuotation))
	oOrder["dtProcQuotation"] := oUtils:getJsDate(StoD(oObj:dDtProcQuotation))
	
	if !lDetails
		return oOrder
	endIf
	
	for nI := 1 to Len(oObj:aItem)	
		
		oItem						:= JsonObject():new()							
		oItem["item"]				:= oObj:aItem[nI]:cItem
		oItem["description"]		:= oObj:aItem[nI]:cDescription
		oItem["fullDescription"]	:= oObj:aItem[nI]:cFullDescription
		oItem["package"]			:= oObj:aItem[nI]:cPackage
		oItem["product"]			:= oObj:aItem[nI]:cProduct
		oItem["quantity"]			:= oObj:aItem[nI]:nSalesQuant
		oItem["invoiceQuantity"]	:= oObj:aItem[nI]:nInvoiceQuant
		oItem["lances"]				:= oObj:aItem[nI]:nLances	
		oItem["meters"]				:= oObj:aItem[nI]:nMetrage
		oItem["price"]				:= oObj:aItem[nI]:nSalesPrice	
		oItem["total"]				:= oObj:aItem[nI]:nValue
		oItem["colorStatus"]		:= oObj:aItem[nI]:cItmColor
		oItem["iconStatus"]			:= oObj:aItem[nI]:cItmIcon
		oItem["status"]				:= oObj:aItem[nI]:cItmStatus
		
		aAdd(oOrder["items"], oItem)
	
	next nI

return oOrder


