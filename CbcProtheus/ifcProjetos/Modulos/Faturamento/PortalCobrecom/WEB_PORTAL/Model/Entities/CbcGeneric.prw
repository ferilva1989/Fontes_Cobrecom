#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcGeneric

Objeto Genérico
    
@author victorhugo
@since 22/06/2016
/*/
class CbcGeneric
	
	data cId
	data cValue
	
	method newCbcGeneric() constructor
	
	method getId()
	method setId()
	method getValue()
	method setValue() 
	
	method toWsObject()
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcGeneric

Construtor
    
@author victorhugo
@since 22/06/2016
/*/
method newCbcGeneric(cId, cValue) class CbcGeneric

	::setId(cId)
	::setValue(cValue)

return self


/**
 * Getters/Setter
 */
method getId() class CbcGeneric
return ::cId

method setId(cId) class CbcGeneric
	::cId := cId
return

method getValue() class CbcGeneric
return ::cValue

method setValue(cValue) class CbcGeneric
	::cValue := cValue
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcGeneric
	
	local oWsObj := WsClassNew("WsCbcGenericObject")
	
	oWsObj:id    := ::getId()
	oWsObj:value := ::getValue()	
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcCustomer, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcGeneric
	
	::setId(oWsObj:id)
	::setValue(oWsObj:value)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcGeneric
	
	local oJson := JsonObject():new()
	
	oJson["id"]    := ::getId()
	oJson["value"] := ::getValue()	

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcGeneric
return ::toJsonObject():toJson()



/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcGeneric
	
	local oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson["id"])
	::setValue(oJson["value"])
	
return


/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcGeneric
	
	local oJson := nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson:cId)
	::setValue(oJson:cValue)
	
return
