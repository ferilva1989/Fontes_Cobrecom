#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcQuotationDocument

Objeto que representa um Documento gerado a partir de um Orçamento
    
@author victorhugo
@since 01/06/2016
/*/
class CbcQuotationDocument from LongClassName
	
	data cBranchId
	data cType
	data cId
	data cSeries
	data dDate
	data cTime
	data lDeleted
	data cComments
	
	method newCbcQuotationDocument() constructor
	
	method getBranchId()
	method setBranchId()
	method getType()
	method setType()
	method getId()
	method setId()
	method getSeries()
	method setSeries()
	method getDate()
	method setDate()
	method getTime()
	method setTime()
	method isDeleted()
	method setDeleted()
	method getComments()
	method setComments()
	
	method toWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()	
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcQuotationDocument

Construtor
    
@author victorhugo
@since 01/06/2016
/*/
method newCbcQuotationDocument() class CbcQuotationDocument
return self

/**
 * Getters/Setters
 */ 
method getBranchId() class CbcQuotationDocument
return ::cBranchId

method setBranchId(cBranchId) class CbcQuotationDocument
	::cBranchId := cBranchId
return 

method getType() class CbcQuotationDocument
return ::cType

method setType(cType) class CbcQuotationDocument
	::cType := cType
return 

method getId() class CbcQuotationDocument
return ::cId

method setId(cId) class CbcQuotationDocument
	::cId := cId
return

method getSeries() class CbcQuotationDocument
return ::cSeries

method setSeries(cSeries) class CbcQuotationDocument
	::cSeries := cSeries
return

method getDate() class CbcQuotationDocument
return ::dDate

method setDate(dDate) class CbcQuotationDocument
	::dDate := dDate
return

method getTime() class CbcQuotationDocument
return ::cTime

method setTime(cTime) class CbcQuotationDocument
	::cTime := cTime
return

method isDeleted() class CbcQuotationDocument
return ::lDeleted

method setDeleted(lDeleted) class CbcQuotationDocument
	::lDeleted := lDeleted
return

method getComments() class CbcQuotationDocument
return ::cComments

method setComments(cComments) class CbcQuotationDocument
	::cComments := cComments
return


 /*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 23/05/2016

@return WsCbcQuotation Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcQuotationDocument
	
	local oWsObj  := WsClassNew("WsCbcQuotationDocument")
	
	oWsObj:branchId		:= ::getBranchId()
	oWsObj:type			:= ::getType()
	oWsObj:id			:= ::getId()
	oWsObj:series		:= ::getSeries()
	oWsObj:date			:= ::getDate()
	oWsObj:time			:= ::getTime()
	oWsObj:isDeleted	:= ::isDeleted()
	oWsObj:comments		:= ::getComments()
	
return oWsObj


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcQuotationDocument
	
	local oJson  := JsonObject():new()	
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	oJson["branchId"]	:= ::getBranchId()
	oJson["type"]		:= ::getType()
	oJson["id"]			:= ::getId()
	oJson["series"]		:= ::getSeries()
	oJson["date"]		:= oUtils:getJsDate(::getDate())
	oJson["time"]		:= ::getTime()
	oJson["isDeleted"]	:= ::isDeleted()
	oJson["comments"]	:= ::getComments()

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcQuotationDocument	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcQuotationDocument
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setBranchId(oJson["branchId"])
	::setType(oJson["type"])
	::setId(oJson["id"])
	::setSeries(oJson["series"])
	::setDate(oUtils:fromJsDate(oJson["date"]))
	::setTime(oJson["time"])
	::setDeleted(oJson["isDeleted"])
	::setComments(oJson["comments"])
	
return


/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcQuotationDocument
	
	local oJson	:= nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setBranchId(oJson:cBranchId)
	::setType(oJson:cType)
	::setId(oJson:cId)
	::setSeries(oJson:cSeries)
	::setDate(oJson:dDate)
	::setTime(oJson:cTime)
	::setDeleted(oJson:lDeleted)
	::setComments(oJson:cComments)
	
return
