#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcSalesOrderData

Orçamentos do Portal Cobrecom
    
@author victorhugo
@since 30/09/2016
/*/
class CbcSalesOrderData from LongClassName
	
	data cDeliveryType
	data dBillingDate
	data lIssueReport
	data lPallets
	data lPartialBilling
	data cCustomerSalesOrder
	data cShippingMessage
	data cInvoiceMessage
	
	method newCbcSalesOrderData() constructor
	
	method getDeliveryType()
	method setDeliveryType()
	method getBillingDate()
	method setBillingDate()
	method isIssueReport()
	method setIssueReport()
	method isPallets()
	method setPallets()
	method isPartialBilling()
	method setPartialBilling()
	method getCustomerSalesOrder()
	method setCustomerSalesOrder()
	method getShippingMessage()
	method setShippingMessage()
	method getInvoiceMessage()
	method setInvoiceMessage()
	
	method toWsObject()
	method toJsonObject()
	method toJsonString()
	method fromWsObject()
	method fromJsonObject()
	
endClass


/*/{Protheus.doc} newCbcSalesOrderData

Construtor
    
@author victorhugo
@since 10/03/2016
/*/
method newCbcSalesOrderData() class CbcSalesOrderData
return self


/**
 * Getters/Setters
 */
method getDeliveryType() class CbcSalesOrderData
return ::cDeliveryType

method setDeliveryType(cDeliveryType) class CbcSalesOrderData
	::cDeliveryType := cDeliveryType
return

method getBillingDate() class CbcSalesOrderData
return ::dBillingDate

method setBillingDate(dBillingDate) class CbcSalesOrderData
	::dBillingDate := dBillingDate
return
 
method isIssueReport() class CbcSalesOrderData
return ::lIssueReport

method setIssueReport(lIssueReport) class CbcSalesOrderData
	::lIssueReport := lIssueReport
return

method isPallets() class CbcSalesOrderData
return ::lPallets

method setPallets(lPallets) class CbcSalesOrderData
	::lPallets := lPallets
return

method isPartialBilling() class CbcSalesOrderData
return ::lPartialBilling

method setPartialBilling(lPartialBilling) class CbcSalesOrderData
	::lPartialBilling := lPartialBilling
return

method getCustomerSalesOrder() class CbcSalesOrderData
return ::cCustomerSalesOrder

method setCustomerSalesOrder(cCustomerSalesOrder) class CbcSalesOrderData
	::cCustomerSalesOrder := cCustomerSalesOrder
return

method getShippingMessage() class CbcSalesOrderData
return ::cShippingMessage

method setShippingMessage(cShippingMessage) class CbcSalesOrderData
	::cShippingMessage := cShippingMessage
return

method getInvoiceMessage() class CbcSalesOrderData
return ::cInvoiceMessage

method setInvoiceMessage(cInvoiceMessage) class CbcSalesOrderData
	::cInvoiceMessage := cInvoiceMessage
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcSalesOrderData
	
	local oWsObj := WsClassNew("WsCbcSalesOrderData")	
	
	oWsObj:deliveryType			:= ::getDeliveryType()
	oWsObj:billingDate			:= ::getBillingDate()
	oWsObj:isIssueReport 		:= ::isIssueReport()
	oWsObj:isPallets 			:= ::isPallets()
	oWsObj:isPartialBilling 	:= ::isPartialBilling()
	oWsObj:customerSalesOrder	:= ::getCustomerSalesOrder()
	oWsObj:shippingMessage 		:= ::getShippingMessage()
	oWsObj:invoiceMessage 		:= ::getInvoiceMessage()

return oWsObj


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcSalesOrderData
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	oJson["deliveryType"]		:= ::getDeliveryType()
	oJson["billingDate"]		:= oUtils:getJsDate(::getBillingDate())
	oJson["isIssueReport"] 		:= ::isIssueReport()
	oJson["isPallets"] 			:= ::isPallets()
	oJson["isPartialBilling"] 	:= ::isPartialBilling()
	oJson["customerSalesOrder"]	:= ::getCustomerSalesOrder()
	oJson["shippingMessage"] 	:= ::getShippingMessage()
	oJson["invoiceMessage"] 	:= ::getInvoiceMessage()

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcSalesOrderData	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcUser, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcSalesOrderData
	
	::setDeliveryType(oWsObj:deliveryType)
	::setBillingDate(oWsObj:billingDate)
	::setIssueReport(oWsObj:isIssueReport)
	::setPallets(oWsObj:isPallets)
	::setPartialBilling(oWsObj:isPartialBilling)
	::setCustomerSalesOrder(oWsObj:customerSalesOrder)
	::setShippingMessage(oWsObj:shippingMessage)
	::setInvoiceMessage(oWsObj:invoiceMessage)

return


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcSalesOrderData
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setDeliveryType(oJson["deliveryType"])
	::setBillingDate(oUtils:fromJsDate(oJson["billingDate"]))
	::setIssueReport(oJson["isIssueReport"])
	::setPallets(oJson["isPallets"])
	::setPartialBilling(oJson["isPartialBilling"])
	::setCustomerSalesOrder(oJson["customerSalesOrder"])
	::setShippingMessage(oJson["shippingMessage"])
	::setInvoiceMessage(oJson["invoiceMessage"])

return

