#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcCustomer

Clientes Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcCustomer
	
	wsData code as string optional
	wsData unit as string optional
	wsData name as string optional
	wsData shortName as string optional
	wsData ie as string optional
	wsData cnpj as string optional
	wsData address as string optional
	wsData city as string optional
	wsData state as string optional
	wsData cityCode as string optional
	wsData zipCode as string optional
	wsData billAddress as string optional
	wsData billCity as string optional
	wsData billState as string optional
	wsData billZipCode as string optional
	wsData email as string optional
	wsData ddd as string optional
	wsData phone  as string optional
	wsData isProspect as boolean optional
	wsData isBlocked as boolean optional
	wsData billBranch as string optional
	wsData paymentCondition as string optional
	wsData descPayment as string optional
	wsData issueReport as string optional
	wsData seller as WsCbcSeller optional	
	wsData cnae as string optional
	wsData segment as string optional
	wsData person as string optional
	wsData type as string optional
	wsData taxPayer as string optional
	wsData nationalSimple as string optional
	wsData suframa as string optional
	wsData specialTax as string optional
	wsData isRetail as boolean optional
	wsData lastPurchase as string optional
	wsData district as string optional
	wsData billDistrict as string optional
	wsData contact as string optional
	wsData mailContact as string optional
	wsData mailFinance as string optional
	wsData recno as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcCity

Cidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcCity
	
	wsData state as string
	wsData id as string
	wsData name as string
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCustomerByCode

Requisição de Clientes pelo Código e Loja
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCustomerByCode
	
	wsData code as string
	wsData unit as string
	wsData isProspect as boolean optional
	wsData userId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCustomerByCode

Retorno de Clientes pelo Código e Loja
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCustomerByCode
	
	wsData status as WsCbcResponseStatus
	wsData customer as WsCbcCustomer optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCustomerByCnpj

Requisição de Clientes pelo CNPJ
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCustomerByCnpj
	
	wsData cnpj as string
	wsData userId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCustomerByCnpj

Retorno de Clientes pelo CNPJ
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCustomerByCnpj
	
	wsData status as WsCbcResponseStatus
	wsData customer as WsCbcCustomer optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCreateProspect

Requisição de criação de Prospects
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCreateProspect
	
	wsData prospect as WsCbcCustomer
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCreateProspect

Retorno de criação de Prospects
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCreateProspect
	
	wsData status as WsCbcResponseStatus
	wsData code as string optional
	wsData unit as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestStateCities

Requisição de Cidades de um Estado
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestStateCities
	
	wsData state as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseStateCities

Retorno de Cidades de um Estado
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseStateCities
	
	wsData status as WsCbcResponseStatus
	wsData cities as array of WsCbcCity optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestSearchCustomers

Requisição de Pesquisa de Clientes
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestSearchCustomers
	
	wsData userId as string
	wsData keyWord as string optional
	wsData segment as string optional
	wsData showBlocked as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseSearchCustomers

Retorno de Pesquisa de Clientes
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseSearchCustomers
	
	wsData status as WsCbcResponseStatus
	wsData customers as array of WsCbcCustomer optional 
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCustomerSegments

Requisição de Segmentos dos Clientes
	
@author victorhugo
@since 09/10/2017
/*/
wsStruct WsCbcRequestCustomerSegments
	
	wsData userId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCustomerSegments

Retorno de Segmentos dos Clientes
	
@author victorhugo
@since 09/10/2017
/*/
wsStruct WsCbcResponseCustomerSegments
	
	wsData status as WsCbcResponseStatus
	wsData segments as array of WsCbcGenericObject optional
	
endWsStruct
