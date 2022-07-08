#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcBranch

Filial Cobrecom
    
@author victorhugo
@since 10/03/2016
/*/
class CbcBranch
	
	data cId
	data cName
	
	method newCbcBranch() constructor
	
	method getId()
	method setId()
	method getName()
	method setName()
	
	method toWsObject()
	method fromWsObject() 
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()	
	
endClass


/*/{Protheus.doc} newCbcBranch

Construtor
    
@author victorhugo
@since 10/03/2016

@param cId, String, ID da Filial
/*/
method newCbcBranch(cId) class CbcBranch
	
	::setId(cId)
	
return self


/*/{Protheus.doc} getId

Coleta String ID da Filial
	
@author victorhugo
@since 10/03/2016

@return String ID da Filial
/*/
method getId() class CbcBranch
return ::cId


/*/{Protheus.doc} setId

Define String ID da Filial
	
@author victorhugo
@since 10/03/2016

@param cId, String, ID da Filial
/*/
method setId(cId) class CbcBranch	
	
	::cId := cId
	
	if Empty(cId)
		return
	endIf
	
	if (cId == BRANCH_ITU)
		::setName("Itu")
	elseIf (cId == BRANCH_TRES_LAGOAS)
		::setName("Três Lagoas") 
	endIf
	
return


/*/{Protheus.doc} getName

Coleta o Nome da Filial
	
@author victorhugo
@since 10/03/2016

@return String Nome da Filial
/*/
method getName() class CbcBranch
return ::cName


/*/{Protheus.doc} setName

Define o Nome da Filial
	
@author victorhugo
@since 10/03/2016

@param cName, String, Nome da Filial
/*/
method setName(cName) class CbcBranch
	::cName := cName
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcBranch
	
	local oWsObj := WsClassNew("WsCbcBranch")	
	
	oWsObj:id 	:= ::getId()
	oWsObj:name := ::getName()

return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcUser, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcBranch
	
	::setId(oWsObj:id)
	::setName(oWsObj:name)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcBranch
	
	local oJson := JsonObject():new()
	
	oJson["id"]   := ::getId()
	oJson["name"] := ::getName()	

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcBranch	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcBranch
	
	local oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson["id"])
	::setName(oJson["name"])

return


