#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcSalesOrder

Pedidos de Vendas do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcSalesOrder
	
	wsData branch as string optional	
	wsData id as string optional
	wsData date as date optional  	
	wsData codeCustomer as string optional
	wsData unitCustomer as string optional
	wsData nameCustomer as string optional
	wsData colorStatus as string optional
	wsData iconStatus as string optional
	wsData status as string optional
	wsData total as float optional
	wsData deliveryDate as date optional
	wsData quotationId as string optional
	wsData dateQuotation as date optional
	wsData dtProcQuotation as date optional
	wsData items as array of WsCbcSalesOrderItem optional
	
endWsStruct


/*/{Protheus.doc} WsCbcSalesOrderItem

Itens dos Pedidos de Vendas do Portal Cobrecom
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcSalesOrderItem
	
	wsData item as string optional
	wsData description as string optional
	wsData fullDescription as string optional
	wsData package as string optional
	wsData product as string optional
	wsData quantity as float optional
	wsData invoiceQuantity as float optional
	wsData lances as float optional
	wsData meters as float optional
	wsData price as float optional
	wsData total as float optional
	wsData colorStatus as string optional
	wsData iconStatus as string optional
	wsData status as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCustomerSalesOrders

Requisição dos Pedidos de Vendas de um cliente
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcRequestCustomerSalesOrders	
	
	wsData userId as string
	wsData codeCustomer as string
	wsData unitCustomer as string
	wsData startDate as date
	wsData endDate as date	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCustomerSalesOrders

Retorno dos Pedidos de Vendas de um cliente
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcResponseCustomerSalesOrders	
	
	wsData status as WsCbcResponseStatus
	wsData orders as array of WsCbcSalesOrder optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestSalesOrderById

Requisição dos detalhes de um Pedido de Vendas
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcRequestSalesOrderById	
	
	wsData userId as string
	wsData branch as string
	wsData salesOrderId as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseSalesOrderById

Retorno dos detalhes de um Pedido de Vendas
	
@author victorhugo
@since 25/10/2017
/*/
wsStruct WsCbcResponseSalesOrderById	
	
	wsData status as WsCbcResponseStatus
	wsData salesOrder as WsCbcSalesOrder optional	
	
endWsStruct
