#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcQuotationRule

Objeto que representa uma Regra de Negócio dos Orçamentos Cobrecom
    
@author victorhugo
@since 26/07/2016
/*/
class CbcQuotationRule from LongClassName
	
	data cType
	data cDescription
	data lOk
	data cComments
	
	method newCbcQuotationRule() constructor
	
	method getType()
	method setType()
	method getDescription()
	method setDescription()
	method isOk()
	method setOk()
	method getComments()
	method setComments()
	
	method toWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcQuotationRule

Construtor
    
@author victorhugo
@since 26/07/2016
/*/
method newCbcQuotationRule() class CbcQuotationRule
return self

/**
 * Getters/Setters
 */
method getType() class CbcQuotationRule
return ::cType

method setType(cType) class CbcQuotationRule
	::cType := cType
return

method getDescription() class CbcQuotationRule
return ::cDescription

method setDescription(cDescription) class CbcQuotationRule
	::cDescription := cDescription
return

method isOk() class CbcQuotationRule
return ::lOk

method setOk(lOk) class CbcQuotationRule
	::lOk := lOk
return

method getComments() class CbcQuotationRule
return ::cComments

method setComments(cComments) class CbcQuotationRule
	::cComments := AllTrim(cComments)
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 23/05/2016

@return WsCbcQuotation Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcQuotationRule
	
	local oWsObj  := WsClassNew("WsCbcQuotationRule")
	
	oWsObj:type			:= ::getType()
	oWsObj:description	:= ::getDescription()
	oWsObj:isOk			:= ::isOk()
	oWsObj:comments		:= ::getComments()
	
return oWsObj


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcQuotationRule
	
	local oJson := JsonObject():new()	
	
	oJson["type"]			:= ::getType()
	oJson["description"]	:= ::getDescription()
	oJson["isOk"]			:= ::isOk()
	oJson["comments"]		:= ::getComments()

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcQuotationRule	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcQuotationRule
	
	local oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setType(oJson["type"])
	::setDescription(oJson["description"])
	::setOk(oJson["isOk"])
	::setComments(oJson["comments"])
	
return


/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcQuotationRule
	
	local oJson	:= nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setType(oJson:cType)
	::setDescription(oJson:cDescription)
	::setOk(oJson:lOk)
	::setComments(oJson:cComments)
	
return
