#include "protheus.ch"
#include "apwebsrv.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcProductWs

Web Service de Manutenção de Produtos do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsService CbcProductWs description "Web Service de Manutenção de Produtos do Portal Cobrecom" namespace "http://cobrecom.com.br/cbcproductws.apw"
	
	wsData requestByCode as WsCbcRequestProductByCode
	wsData responseByCode as WsCbcResponseProductByCode
	wsData requestProperties as WsCbcRequestProductProperties
	wsData responseProperties as WsCbcResponseProductProperties
	wsData requestColors as WsCbcRequestProductColors
	wsData responseColors as WsCbcResponseProductColors
	
	wsMethod findByCode description "Retorna um Produto pelo Código"
	wsMethod getProperties description "Retorna as Propriedades dos Produtos (Nomes, Bitolas ou Cores)"
	wsMethod getColors description "Retorna as Cores dos Produtos de acordo com o Nome e a Bitola"
	
endWsService


/*/{Protheus.doc} findByCode

Retorna um Produto pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod findByCode wsReceive requestByCode wsSend responseByCode wsService CbcProductWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSrvProd	:= CbcProductService():newCbcProductService()
	local oProduct	:= oSrvProd:findByCode(::requestByCode:code)	
	
	if oUtils:isNotNull(oProduct)		
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso"
		::responseByCode:product := oProduct:toWsObject() 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"   		 
	endIf
	
	::responseByCode:status := oStatus
	
return .T.


/*/{Protheus.doc} getProperties

Retorna as Propriedades dos Produtos (Nomes, Bitolas ou Cores)
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getProperties wsReceive requestProperties wsSend responseProperties wsService CbcProductWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oSrvProd	:= CbcProductService():newCbcProductService()
	local aValues	:= oSrvProd:getProperties(::requestProperties:property)	
	
	if (Len(aValues) > 0)
		oSrvProd:setWsArray(@aValues)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso" 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"   		 
	endIf
	
	::responseProperties:status := oStatus
	::responseProperties:values := aValues
	
return .T.


/*/{Protheus.doc} getColors

Retorna as Cores dos Produtos de acordo com o Nome e a Bitola
	
@author victorhugo
@since 24/02/2016
/*/
wsMethod getColors wsReceive requestColors wsSend responseColors wsService CbcProductWs
	
	local oStatus   := WsClassNew("WsCbcResponseStatus")
	local oSrvProd	:= CbcProductService():newCbcProductService()
	local aColors	:= oSrvProd:getColors(::requestColors:name, ::requestColors:bitola)	
	
	if (Len(aColors) > 0)
		oSrvProd:setWsArray(@aColors)
		oStatus:success := .T.
		oStatus:message := "Dados fornecidos com sucesso" 
	else
		oStatus:success := .F.
		oStatus:message := "Nenhum registro encontrado"   		 
	endIf
	
	::responseColors:status := oStatus
	::responseColors:colors := aColors
	
return .T.




