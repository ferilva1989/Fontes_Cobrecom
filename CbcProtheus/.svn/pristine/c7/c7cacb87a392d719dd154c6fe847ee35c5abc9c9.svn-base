#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcOpportunityBalance

Estoque de Oportunidades do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcOpportunityBalance
	
	wsData branch as WsCbcBranch
	wsData product as WsCbcProduct
	wsData address as string
	wsData idAddress as string
	wsData quantity as float
	wsData total as float
	
endWsStruct


/*/{Protheus.doc} WsCbcOpportunityBalanceReserve

Reserva do Estoque de Oportunidades do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcOpportunityBalanceReserve
	
	wsData status as string
	wsData id as string
	wsData date as date
	wsData time as string
	wsData dateValid as date
	wsData timeValid as string
	wsData userId as string
	wsData userName as string
	wsData customerCode as string
	wsData customerUnit as string
	wsData customerName as string
	wsData balance as WsCbcOpportunityBalance
	wsData itemQuotation as string optional
	wsData idQuotation as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductPropertyList

Requisição de Lista de Valores dos Atributos dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductPropertyList	
	
	wsData property as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductPropertyList

Retorno de Lista de Valores dos Atributos dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductPropertyList	
	
	wsData status as WsCbcResponseStatus
	wsData values as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestReservesEntityList

Requisição de Lista de Entidades relacionadas as Reservas de Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestReservesEntityList	
	
	wsData userId as string
	wsData entity as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseReservesEntityList

Retorno de Lista de Entidades relacionadas as Reservas de Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseReservesEntityList	
	
	wsData status as WsCbcResponseStatus
	wsData values as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestOpportunityBalances

Requisição de Saldos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestOpportunityBalances	
	
	wsData userId as string
	wsData productName as string
	wsData productBitola as string
	wsData productColor as string optional
	wsData customerCode as string optional
	wsData customerUnit as string optional
	wsData customerIsProspect as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseOpportunityBalances

Retorno de Saldos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseOpportunityBalances	
	
	wsData status as WsCbcResponseStatus
	wsData balances as array of WsCbcOpportunityBalance optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCreateOpportunityBalanceReserve

Requisição de Criação de Reserva de Produtos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCreateOpportunityBalanceReserve	
	
	wsData userId as string
	wsData branch as string
	wsData productCode as string
	wsData address as string
	wsData idAddress as string
	wsData quantity as float
	wsData total as float
	wsData customerCode as string optional
	wsData customerUnit as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCreateOpportunityBalanceReserve

Retorno de Criação de Reserva de Produtos do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCreateOpportunityBalanceReserve	
	
	wsData status as WsCbcResponseStatus
	wsData reserveId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestOpportunityBalanceCancelReserve

Requisição de Cancelamento de uma Reserva do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestOpportunityBalanceCancelReserve	
	
	wsData userId as string
	wsData branch as string
	wsData reserveId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseOpportunityBalanceCancelReserve

Requisição de Cancelamento de uma Reserva do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseOpportunityBalanceCancelReserve	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct

				  
/*/{Protheus.doc} WsCbcRequestOpportunityBalanceReserves

Requisição de Reservas do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/	 	 
wsStruct WsCbcRequestOpportunityBalanceReserves
	
	wsData startDate as date optional
	wsData endDate as date optional
	wsData userId as string optional
	wsData branch as string optional
	wsData status as string optional
	wsData reserveId as string optional
	wsData customerCode as string optional
	wsData customerUnit as string optional
	wsData seller as string optional
	wsData fromUser as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseOpportunityBalanceReserves

Retorno de Reservas do Estoque de Oportunidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseOpportunityBalanceReserves	
	
	wsData status as WsCbcResponseStatus
	wsData reserves as array of WsCbcOpportunityBalanceReserve optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestOpportunityBalanceReserveById

Requisição de Reservas do Estoque de Oportunidades pelo ID
	
@author victorhugo
@since 24/02/2016
/*/	 	 
wsStruct WsCbcRequestOpportunityBalanceReserveById
	
	wsData branch as string
	wsData reserveId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseOpportunityBalanceReserveById

Retorno de Reservas do Estoque de Oportunidades pelo ID
	
@author victorhugo
@since 24/02/2016
/*/	 	 
wsStruct WsCbcResponseOpportunityBalanceReserveById
	
	wsData status as WsCbcResponseStatus
	wsData reserve as WsCbcOpportunityBalanceReserve optional
	
endWsStruct
