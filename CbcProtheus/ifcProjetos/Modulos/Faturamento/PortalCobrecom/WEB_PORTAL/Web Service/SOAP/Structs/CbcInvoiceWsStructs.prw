#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcInvoice

Nota Fiscal do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcInvoice
	
	wsData branch as string optional	
	wsData number as string optional
	wsData series as string optional
	wsData date as date optional  
	wsData deliveryDate as date optional	
	wsData codeCustomer as string optional
	wsData unitCustomer as string optional
	wsData nameCustomer as string optional
	wsData carrier as string optional
	wsData total as float optional
	wsData items as array of WsCbcInvoiceItem optional
	
endWsStruct


/*/{Protheus.doc} WsCbcInvoiceItem

Itens das Notas Fiscais do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcInvoiceItem
	
	wsData item as string optional
	wsData description as string optional
	wsData orderItem as string optional
	wsData salesOrderId as string optional	
	wsData quantity as float optional
	wsData price as float optional
	wsData total as float optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCustomerInvoices

Requisição das Notas Fiscais de um cliente
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcRequestCustomerInvoices	
	
	wsData userId as string
	wsData codeCustomer as string
	wsData unitCustomer as string
	wsData startDate as date
	wsData endDate as date	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCustomerInvoices

Retorno das Notas Fiscais de um cliente
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcResponseCustomerInvoices	
	
	wsData status as WsCbcResponseStatus
	wsData invoices as array of WsCbcInvoice optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestInvoiceById

Requisição dos detalhes de uma Nota Fiscal
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcRequestInvoiceById	
	
	wsData userId as string
	wsData branch as string
	wsData invoiceNumber as string
	wsData series as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseInvoiceById

Retorno dos detalhes de uma Nota Fiscal
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcResponseInvoiceById	
	
	wsData status as WsCbcResponseStatus
	wsData invoice as WsCbcInvoice optional	
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestOrderInvoices

Requisição das Notas Fiscais de um Pedido
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcRequestOrderInvoices	
	
	wsData userId as string
	wsData branch as string
	wsData salesOrderId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseOrderInvoices

Retorno das Notas Fiscais de um Pedido
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcResponseOrderInvoices	
	
	wsData status as WsCbcResponseStatus
	wsData invoices as array of WsCbcInvoice optional	
	
endWsStruct