#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcOpportunityBalance

Objeto que representa um Saldo do Estoque de Oportunidades da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcOpportunityBalance from LongClassName
	
	data oBranch
	data oProduct
	data cAddress
	data cIdAddress
	data nQuantity
	data nTotal
	
	method newCbcOpportunityBalance() constructor
	
	method getBranch()
	method setBranch()
	method getProduct()
	method setProduct()
	method getAddress()
	method setAddress()
	method getIdAddress()
	method setIdAddress()
	method getQuantity()
	method setQuantity()
	method getTotal()
	method setTotal()
	
	method toWsObject()
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
		
endClass


/*/{Protheus.doc} newCbcOpportunityBalance

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcOpportunityBalance() class CbcOpportunityBalance
return self


/*/{Protheus.doc} getBranch

Coleta a Filial do Saldo
	
@author victorhugo
@since 10/03/2016

@return CbcBranch Filial do Saldo
/*/
method getBranch() class CbcOpportunityBalance
return ::oBranch


/*/{Protheus.doc} setBranch

Define a Filial do Saldo
	
@author victorhugo
@since 10/03/2016

@param oBranch, CbcBranch, Filial do Saldo
/*/
method setBranch(oBranch) class CbcOpportunityBalance
	::oBranch := oBranch
return


/*/{Protheus.doc} getProduct

Coleta o Produto do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@return CbcProduct Produto do Estoque de Oportunidade
/*/
method getProduct() class CbcOpportunityBalance
return ::oProduct


/*/{Protheus.doc} setProduct

Define o Produto do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@param oProduct, CbcProduct, Produto do Estoque de Oportunidade
/*/
method setProduct(oProduct) class CbcOpportunityBalance
	::oProduct := oProduct
return


/*/{Protheus.doc} getAddress

Coleta o Endereço do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@return String Endereço do Estoque de Oportunidade
/*/
method getAddress() class CbcOpportunityBalance
return ::cAddress


/*/{Protheus.doc} setAddress

Define o Endereço do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@param cAddress, String, Endereço do Estoque de Oportunidade
/*/
method setAddress(cAddress) class CbcOpportunityBalance
	::cAddress := cAddress
return


/*/{Protheus.doc} getIdAddress

Coleta o ID do Endereço
	
@author victorhugo
@since 08/03/2016

@return String ID do Endereço
/*/
method getIdAddress() class CbcOpportunityBalance
return ::cIdAddress


/*/{Protheus.doc} setIdAddress

Define o ID do Endereço
	
@author victorhugo
@since 08/03/2016

@param cIdAddress, String, ID do Endereço
/*/
method setIdAddress(cIdAddress) class CbcOpportunityBalance
	::cIdAddress := cIdAddress
return 


/*/{Protheus.doc} getQuantity

Coleta a Quantidade do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@return Numerico Quantidade do Estoque de Oportunidade
/*/
method getQuantity() class CbcOpportunityBalance
return ::nQuantity


/*/{Protheus.doc} setQuantity

Define a Quantidade do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@param nQuantity, Numerico, Quantidade do Estoque de Oportunidade
/*/
method setQuantity(nQuantity) class CbcOpportunityBalance
	::nQuantity := nQuantity
return


/*/{Protheus.doc} getTotal

Coleta a Quantidade Total do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@return Numerico Quantidade Total do Estoque de Oportunidade
/*/
method getTotal() class CbcOpportunityBalance
return ::nTotal


/*/{Protheus.doc} setTotal

Define a Quantidade Total do Estoque de Oportunidade
	
@author victorhugo
@since 24/02/2016

@param nTotal, Numerico, Quantidade Total do Estoque de Oportunidade
/*/
method setTotal(nTotal) class CbcOpportunityBalance
	::nTotal := nTotal
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcOpportunityBalance
	
	local oWsObj 	:= WsClassNew("WsCbcOpportunityBalance")
	local oUtils 	:= LibUtilsObj():newLibUtilsObj()
	local oBranch	:= ::getBranch() 
	local oProduct	:= ::getProduct() 
	
	oWsObj:branch 		:= ::getBranch() 
	oWsObj:address 		:= ::getAddress()
	oWsObj:idAddress 	:= ::getIdAddress()
	oWsObj:quantity 	:= ::getQuantity()
	oWsObj:total 		:= ::getTotal()
	
	if oUtils:isNotNull(oProduct)
		oWsObj:product := oProduct:toWsObject() 
	endIf
	
	if oUtils:isNotNull(oBranch)
		oWsObj:branch := oBranch:toWsObject() 
	endIf
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcCustomer, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcOpportunityBalance
	
	local oBranch  := nil
	local oProduct := nil
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	
	::setBranch(oWsObj:branch) 
	::setAddress(oWsObj:address)
	::setIdAddress(oWsObj:idAddress)
	::setQuantity(oWsObj:quantity)
	::setTotal(oWsObj:total)
	
	if oUtils:isNotNull(oWsObj:branch)
		oBranch := CbcBranch():newCbcBranch()
		oBranch:fromWsObject(oWsObj:branch)		
	endIf
	
	::setBranch(oBranch)
	
	if oUtils:isNotNull(oWsObj:product)
		oProduct := CbcProduct():newCbcProduct()
		oProduct:fromWsObject(oWsObj:product)		
	endIf
	
	::setProduct(oProduct)
	
return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcOpportunityBalance
	
	local oJson 	:= JsonObject():new()	
	local oUtils 	:= LibUtilsObj():newLibUtilsObj()
	local oBranch	:= ::getBranch() 
	local oProduct	:= ::getProduct() 
	
	oJson["address"] 	:= ::getAddress()
	oJson["idAddress"] 	:= ::getIdAddress()
	oJson["quantity"] 	:= ::getQuantity()
	oJson["total"] 		:= ::getTotal()
	
	if oUtils:isNotNull(oProduct)
		oJson["product"] := oProduct:toJsonObject() 
	endIf
	
	if oUtils:isNotNull(oBranch)
		oJson["branch"] := oBranch:toJsonObject() 
	endIf

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcOpportunityBalance	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcOpportunityBalance
	
	local oJson    := JsonObject():new()
	local oBranch  := nil
	local oProduct := nil
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setBranch(oJson["branch"]) 
	::setAddress(oJson["address"])
	::setIdAddress(oJson["idAddress"])
	::setQuantity(oJson["quantity"])
	::setTotal(oJson["total"])
	
	if oUtils:isNotNull(oJson["branch"])
		oBranch := CbcBranch():newCbcBranch()
		oBranch:fromJsonObject(oJson["branch"])		
	endIf
	
	::setBranch(oBranch)
	
	if oUtils:isNotNull(oJson["product"])
		oProduct := CbcProduct():newCbcProduct()
		oProduct:fromJsonObject(oJson["product"])		
	endIf
	
	::setProduct(oProduct)	

return
