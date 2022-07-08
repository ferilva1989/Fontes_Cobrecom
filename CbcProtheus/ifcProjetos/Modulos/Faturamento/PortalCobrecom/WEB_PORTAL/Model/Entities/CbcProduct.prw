#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcProduct

Objeto que representa um Produto da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcProduct from LongClassName
	
	data cCode
	data cDescription
	data cName
	data cCodeName
	data cBitola
	data cCodeBitola
	data cColor
	data cCodeColor
	
	method newCbcProduct() constructor
	
	method getCode()
	method setCode()
	method getDescription()
	method setDescription()
	method getName()
	method setName()
	method getCodeName()
	method setCodeName()	
	method getBitola()
	method setBitola()
	method getCodeBitola()
	method setCodeBitola()
	method getColor()
	method setColor()
	method getCodeColor()
	method setCodeColor()
	
	method toWsObject()
	method fromWsObject() 
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
		
endClass


/*/{Protheus.doc} newCbcProduct

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcProduct() class CbcProduct
return self


/*/{Protheus.doc} getCode

Coleta o Código do Produto
	
@author victorhugo
@since 24/02/2016

@return String Código do Produto
/*/
method getCode() class CbcProduct
return ::cCode


/*/{Protheus.doc} setCode

Define o Código do Produto
	
@author victorhugo
@since 24/02/2016

@param cCode, String, Código do Produto
/*/
method setCode(cCode) class CbcProduct
	::cCode := cCode
return


/*/{Protheus.doc} getDescription

Coleta a Descrição do Produto
	
@author victorhugo
@since 24/02/2016

@return String Descrição do Produto
/*/
method getDescription() class CbcProduct
return ::cDescription


/*/{Protheus.doc} setDescription

Define a Descrição do Produto
	
@author victorhugo
@since 24/02/2016

@param cDescription, String, Descrição do Produto
/*/
method setDescription(cDescription) class CbcProduct
	::cDescription := cDescription
return


/*/{Protheus.doc} getName

Coleta o Nome do Produto
	
@author victorhugo
@since 29/02/2016

@return String Nome do Produto
/*/
method getName() class CbcProduct
return ::cName


/*/{Protheus.doc} setName

Define o Nome do Produto
	
@author victorhugo
@since 29/02/2016

@param cName, String, Nome do Produto
/*/
method setName(cName) class CbcProduct
	::cName := cName
return


/*/{Protheus.doc} getCodeName

Coleta o Código do Nome do Produto
	
@author victorhugo
@since 29/02/2016

@return String Código do Nome do Produto
/*/
method getCodeName() class CbcProduct
return ::cCodeName


/*/{Protheus.doc} setCodeName

Define o Código do Nome do Produto
	
@author victorhugo
@since 29/02/2016

@param cCodeName, String, Código do Nome do Produto
/*/
method setCodeName(cCodeName) class CbcProduct
	::cCodeName := cCodeName
return


/*/{Protheus.doc} getBitola

Coleta a Descrição da Bitola do Produto
	
@author victorhugo
@since 24/02/2016

@return String Descrição da Bitola do Produto
/*/
method getBitola() class CbcProduct
return ::cBitola


/*/{Protheus.doc} setBitola

Define a Descrição da Bitola do Produto
	
@author victorhugo
@since 24/02/2016

@param cBitola, String, Descrição da Bitola do Produto
/*/
method setBitola(cBitola) class CbcProduct
	::cBitola := cBitola
return


/*/{Protheus.doc} getCodeBitola

Coleta o Código da Bitola do Produto
	
@author victorhugo
@since 24/02/2016

@return String Código da Bitola do Produto
/*/
method getCodeBitola() class CbcProduct
return ::cCodeBitola


/*/{Protheus.doc} setCodeBitola

Define o Código da Bitola do Produto
	
@author victorhugo
@since 24/02/2016

@param cCodeBitola, String, Código da Bitola do Produto
/*/
method setCodeBitola(cCodeBitola) class CbcProduct
	::cCodeBitola := cCodeBitola
return


/*/{Protheus.doc} getColor

Coleta a Descrição da Cor do Produto
	
@author victorhugo
@since 24/02/2016

@return String Descrição da Cor do Produto
/*/
method getColor() class CbcProduct
return ::cColor


/*/{Protheus.doc} setColor

Define a Descrição da Cor do Produto
	
@author victorhugo
@since 24/02/2016

@param cColor, String, Descrição da Cor do Produto
/*/
method setColor(cColor) class CbcProduct
	::cColor := cColor
return


/*/{Protheus.doc} getCodeColor

Coleta o Código da Cor do Produto
	
@author victorhugo
@since 24/02/2016

@return String Código da Cor do Produto
/*/
method getCodeColor() class CbcProduct
return ::cCodeColor


/*/{Protheus.doc} setCodeColor

Define o Código da Cor do Produto
	
@author victorhugo
@since 24/02/2016

@param cCodeColor, String, Código da Cor do Produto
/*/
method setCodeColor(cCodeColor) class CbcProduct
	::cCodeColor := cCodeColor
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcProduct
	
	local oWsObj := WsClassNew("WsCbcProduct")
	
	oWsObj:code 		:= ::getCode()
	oWsObj:description 	:= ::getDescription()
	oWsObj:name 		:= ::getName()
	oWsObj:codeName 	:= ::getCodeName()
	oWsObj:bitola 		:= ::getBitola()
	oWsObj:codeBitola 	:= ::getCodeBitola()
	oWsObj:color 		:= ::getColor()
	oWsObj:codeColor 	:= ::getCodeColor()
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcCustomer, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcProduct
	
	::setCode(oWsObj:code)
	::setDescription(oWsObj:description)
	::setName(oWsObj:name)
	::setCodeName(oWsObj:codeName)
	::setBitola(oWsObj:bitola)
	::setCodeBitola(oWsObj:codeBitola)
	::setColor(oWsObj:color)
	::setCodeColor(oWsObj:codeColor)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcProduct
	
	local oJson := JsonObject():new()	
	
	oJson["code"] 		 := ::getCode()
	oJson["description"] := ::getDescription()
	oJson["name"] 		 := ::getName()
	oJson["codeName"] 	 := ::getCodeName()
	oJson["bitola"] 	 := ::getBitola()
	oJson["codeBitola"]  := ::getCodeBitola()
	oJson["color"] 		 := ::getColor()
	oJson["codeColor"] 	 := ::getCodeColor()

return oJson


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcProduct
	
	local oJson := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setCode(oJson["code"])
	::setDescription(oJson["description"])
	::setName(oJson["name"])
	::setCodeName(oJson["codeName"])
	::setBitola(oJson["bitola"])
	::setCodeBitola(oJson["codeBitola"])
	::setColor(oJson["color"])
	::setCodeColor(oJson["codeColor"])

return


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcProduct	
return ::toJsonObject():toJson()

