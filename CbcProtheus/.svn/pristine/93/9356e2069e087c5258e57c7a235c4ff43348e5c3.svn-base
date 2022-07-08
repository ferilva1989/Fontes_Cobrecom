#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcQuotationRevision

Objeto que representa uma Revisão de um Orçamento
    
@author victorhugo
@since 04/08/2016
/*/
class CbcQuotationRevision from LongClassName
	
	data cRevision
	data cEvent
	data cIdUser
	data cNameUser
	data dDate
	data cTime
	data cJson
	
	method newCbcQuotationRevision() constructor
	
	method getRevision()
	method setRevision()
	method getEvent()
	method setEvent()
	method getIdUser()
	method setIdUser()
	method getNameUser()
	method setNameUser()
	method getDate()
	method setDate()
	method getTime()
	method setTime()
	method getJson()
	method setJson()
	
	method toWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcQuotationRevision

Construtor
    
@author victorhugo
@since 04/08/2016
/*/
method newCbcQuotationRevision() class CbcQuotationRevision
return self


/**
 * Getters/Setters
 */
method getRevision() class CbcQuotationRevision
return ::cRevision

method setRevision(cRevision) class CbcQuotationRevision
	::cRevision := cRevision
return

method getEvent() class CbcQuotationRevision
return ::cEvent

method setEvent(cEvent) class CbcQuotationRevision
	::cEvent := cEvent
return

method getIdUser() class CbcQuotationRevision
return ::cIdUser

method setIdUser(cIdUser) class CbcQuotationRevision
	::cIdUser := cIdUser
return

method getNameUser() class CbcQuotationRevision
return ::cNameUser

method setNameUser(cNameUser) class CbcQuotationRevision
	::cNameUser := cNameUser
return

method getDate() class CbcQuotationRevision
return ::dDate

method setDate(dDate) class CbcQuotationRevision
	::dDate := dDate
return

method getTime() class CbcQuotationRevision
return ::cTime

method setTime(cTime) class CbcQuotationRevision
	::cTime := cTime
return

method getJson() class CbcQuotationRevision
return ::cJson

method setJson(cJson) class CbcQuotationRevision
	::cJson := cJson
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 23/05/2016

@return WsCbcQuotation Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcQuotationRevision
	
	local oWsObj  := WsClassNew("WsCbcQuotationRevision")
	
	oWsObj:revision	 := ::getRevision()
	oWsObj:event	 := ::getEvent()
	oWsObj:idUser	 := ::getIdUser()
	oWsObj:nameUser	 := ::getNameUser()
	oWsObj:date		 := ::getDate()	
	oWsObj:time		 := ::getTime()
	
return oWsObj


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcQuotationRevision
	
	local cDescEvt := ""
	local cEvent   := ::getEvent()	
	local oJson    := JsonObject():new()	
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	
	oJson["revision"]  := ::getRevision()
	oJson["event"]	   := cEvent
	oJson["idUser"]	   := ::getIdUser()
	oJson["nameUser"]  := ::getNameUser()
	oJson["date"]	   := oUtils:getJsDate(::getDate())	
	oJson["time"]	   := ::getTime()
	
	if (cEvent == QUOTATION_REVISION_CREATE)
		cDescEvt := "Criação"
	elseIf (cEvent == QUOTATION_REVISION_UPDATE)
		cDescEvt := "Alteração"
	elseIf (cEvent == QUOTATION_REVISION_APPROVE)
		cDescEvt := "Aprovação"
	elseIf (cEvent == QUOTATION_REVISION_REJECTION)
		cDescEvt := "Não aprovação"
	elseIf (cEvent == QUOTATION_REVISION_GIVE_UP_APPROVAL)
		cDescEvt := "Desistência da aprovação"
	elseIf (cEvent == QUOTATION_REVISION_TECNICAL_APPROVAL)
		cDescEvt := "Aprovação Tecnica"
	elseIf (cEvent == QUOTATION_REVISION_TECNICAL_REJECT)
		cDescEvt := "Rejeição Tecnica"
	endIf
	
	oJson["eventDescription"] := cDescEvt

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcQuotationRevision	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcQuotationRevision
	
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	private oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf	
	
	oJson["revision"]  := ::getRevision()
	oJson["idUser"]	   := ::getIdUser()
	oJson["nameUser"]  := ::getNameUser()
	oJson["date"]	   := oUtils:fromJsDate(::getDate())	
	oJson["time"]	   := ::getTime()
	
	if (Type("oJson['event']") != "U")	
		::setEvent(oJson["event"])
	else
		::setEvent("")
	endIf
	
return


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcQuotationRevision
	
	private oJson := nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setRevision(oJson:cRevision)	
	::setIdUser(oJson:cIdUser)
	::setNameUser(oJson:cNameUser)
	::setDate(oJson:dDate)
	::setTime(oJson:cTime)
	
	if (Type("oJson:cEvent") != "U")	
		::setEvent(oJson:cEvent)
	else
		::setEvent("")
	endIf
	
return
