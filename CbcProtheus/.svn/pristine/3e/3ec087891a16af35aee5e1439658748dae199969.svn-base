#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcQuotationItemColor

Objeto que representa uma Cor dos Itens dos Orçamentos
    
@author victorhugo
@since 01/06/2016
/*/
class CbcQuotationItemColor from LongClassName
	
	data cColorId
	data cColorName
	data cPoShip
	data nQuantity
	data nTotal
	data lRequireApproval
	
	method newCbcQuotationItemColor() constructor
	
	method getColorId()
	method setColorId()
	method getColorName()
	method setColorName()
	method getQuantity()
	method setQuantity()
	method getTotal()
	method setTotal()
	method requireApproval()
	method setRequireApproval()
	method getPoShip()
	method setPoShip()
	
	method toWsObject()
	method fromWsObject() 
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcQuotationItemColor

Construtor
    
@author victorhugo
@since 01/06/2016
/*/
method newCbcQuotationItemColor() class CbcQuotationItemColor
return self


/**
 * Getters/Setter
 */
method getColorId() class CbcQuotationItemColor
return ::cColorId

method setColorId(cColorId) class CbcQuotationItemColor
	::cColorId := cColorId
return

method getColorName() class CbcQuotationItemColor
return ::cColorName

method setColorName(cColorName) class CbcQuotationItemColor
	::cColorName := cColorName
return

method getQuantity() class CbcQuotationItemColor
return ::nQuantity

method setQuantity(nQuantity) class CbcQuotationItemColor
	::nQuantity := nQuantity
return

method getTotal() class CbcQuotationItemColor
return ::nTotal

method setTotal(nTotal) class CbcQuotationItemColor
	::nTotal := nTotal
return

method requireApproval() class CbcQuotationItemColor
return ::lRequireApproval

method setRequireApproval(lRequireApproval) class CbcQuotationItemColor
	::lRequireApproval := lRequireApproval
return


 /*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 23/05/2016

@return WsCbcQuotation Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcQuotationItemColor
	
	local oWsObj  := WsClassNew("WsCbcQuotationItemColor")
	
	oWsObj:colorId			:= ::getColorId()
	oWsObj:colorName		:= AllTrim(::getColorName())
	oWsObj:quantity			:= ::getQuantity()
	oWsObj:total			:= ::getTotal()
	oWsObj:requireApproval	:= ::requireApproval()
	oWsObj:cPoShip			:= ::getPoShip()
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 23/05/2016

@param oWsObj, WsCbcQuotationItemColor, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcQuotationItemColor
	
	::setColorId(oWsObj:colorId)
	::setColorName(oWsObj:colorName)
	::setQuantity(oWsObj:quantity)
	::setTotal(oWsObj:total)
	::setRequireApproval(oWsObj:requireApproval)
	::setPoShip(oWsObj:poShip)
	
return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcQuotationItemColor
	
	local oJson := JsonObject():new()	
	
	oJson["colorId"]		 := ::getColorId()
	oJson["colorName"]		 := ::getColorName()
	oJson["quantity"]		 := ::getQuantity()
	oJson["total"]			 := ::getTotal()
	oJson["requireApproval"] := ::requireApproval()
	oJson["poShip"]			 := ::getPoShip()

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcQuotationItemColor	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcQuotationItemColor
	
	private oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setColorId(oJson["colorId"])
	::setColorName(oJson["colorName"])
	::setQuantity(oJson["quantity"]) 
	::setTotal(oJson["total"])
	::setPoShip(oJson['poShip'])
	
	if (Type("oJson['requireApproval']") == "L")
		::setRequireApproval(oJson["requireApproval"])
	else
		::setRequireApproval(.F.)
	endIf
	
return

/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcQuotationItemColor
	
	private oJson := nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setColorId(oJson:cColorId)
	::setColorName(oJson:cColorName)
	::setQuantity(oJson:nQuantity) 
	::setTotal(oJson:nTotal)
	::setPoShip(oJson:nPoShip)
	
	if (Type("oJson:lRequireApproval") == "L")
		::setRequireApproval(oJson:lRequireApproval)
	else
		::setRequireApproval(.F.)
	endIf
	
return

method getPoShip() class CbcQuotationItemColor
return ::cPoShip

method setPoShip(nPoShip) class CbcQuotationItemColor
	::cPoShip := cValToChar(nPoShip)
return
