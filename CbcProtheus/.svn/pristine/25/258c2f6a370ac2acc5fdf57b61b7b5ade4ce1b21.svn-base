#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcProduct

Produtos do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcProduct
	
	wsData code as string
	wsData description as string
	wsData name as string
	wsData codeName as string
	wsData bitola as string
	wsData codeBitola as string
	wsData color as string
	wsData codeColor as string
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductByCode

Requisição de um Produto pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductByCode	
	
	wsData code as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductByCode

Retorno de um Produto pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductByCode	
	
	wsData status as WsCbcResponseStatus
	wsData product as WsCbcProduct optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductProperties

Requisição de Lista de Valores dos Atributos dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductProperties	
	
	wsData property as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductProperties

Retorno de Lista de Valores dos Atributos dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductProperties	
	
	wsData status as WsCbcResponseStatus
	wsData values as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductColors

Requisição de Lista de Cores dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductColors	
	
	wsData name as string
	wsData bitola as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductColors

Retorno da Lista de Cores dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductColors	
	
	wsData status as WsCbcResponseStatus
	wsData colors as array of WsCbcGenericObject optional
	
endWsStruct

