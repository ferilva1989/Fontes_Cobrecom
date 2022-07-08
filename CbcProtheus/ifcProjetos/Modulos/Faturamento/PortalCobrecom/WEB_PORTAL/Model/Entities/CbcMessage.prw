#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcMessage

Objeto que representa uma Mensagem do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcMessage from LongClassName
	
	data cId
	data cFromUser
	data cNameFromUser
	data cToUser
	data cNameToUser
	data dDate
	data cTime
	data cSubject
	data dDateDisplay
	data cTimeDisplay
	data cText
	data dDateEmail
	data cTimeEmail
	data cWhen
	data lFiled
	data cQuotationId
	
	method newCbcMessage() constructor
	
	method getId()
	method setId()
	method getFromUser()
	method setFromUser()
	method getNameFromUser()
	method setNameFromUser()
	method getToUser()
	method setToUser()
	method getNameToUser()
	method setNameToUser() 
	method getDate()
	method setDate()
	method getTime()
	method setTime()
	method getSubject()
	method setSubject()
	method getDateDisplay()
	method setDateDisplay()
	method getTimeDisplay()
	method setTimeDisplay()
	method getText()
	method setText()
	method getDateEmail()
	method setDateEmail()
	method getTimeEmail()
	method setTimeEmail() 
	method getWhen()
	method isFiled()
	method setFiled()
	method getQuotationId()
	method setQuotationId()
	 
	method toWsObject() 
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	method fromJsonLegacy()
	 			
endClass


/*/{Protheus.doc} newCbcMessage

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcMessage() class CbcMessage
return self


/*/{Protheus.doc} getId

Coleta o ID da Mensagem
	
@author victorhugo
@since 24/02/2016

@return String ID da Mensagem
/*/
method getId() class CbcMessage
return ::cId


/*/{Protheus.doc} setId

Define o ID da Mensagem
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Mensagem
/*/
method setId(cId) class CbcMessage
	::cId := cId
return


/*/{Protheus.doc} getFromUser

Coleta o Código do Usuário que enviou a Mensagem
	
@author victorhugo
@since 24/02/2016

@return String Código do Usuário que enviou a Mensagem
/*/
method getFromUser() class CbcMessage
return ::cFromuser


/*/{Protheus.doc} setFromUser

Define o Código do Usuário que enviou a Mensagem
	
@author victorhugo
@since 24/02/2016

@param cFromuser, String, Código do Usuário que enviou a Mensagem
/*/
method setFromUser(cFromuser) class CbcMessage
	::cFromuser := cFromuser
return


/*/{Protheus.doc} getNameFromUser

Coleta o Nome do Usuário que enviou a Mensagem
	
@author victorhugo
@since 12/05/2016

@return String Nome do Usuário que enviou a Mensagem
/*/
method getNameFromUser() class CbcMessage
return ::cNameFromUser


/*/{Protheus.doc} setNameFromUser

Define o Nome do Usuário que enviou a Mensagem
	
@author victorhugo
@since 12/05/2016

@param cNameFromUser, String, Nome do Usuário que enviou a Mensagem
/*/
method setNameFromUser(cNameFromUser) class CbcMessage
	::cNameFromUser := cNameFromUser
return


/*/{Protheus.doc} getToUser

Coleta o Código do Usuário de destino da Mensagem
	
@author victorhugo
@since 24/02/2016

@return typeDescription Código do Usuário de destino da Mensagem
/*/
method getToUser() class CbcMessage
return ::cToUser


/*/{Protheus.doc} setToUser

Define o Código do Usuário de destino da Mensagem
	
@author victorhugo
@since 24/02/2016

@param cToUser, typeDescription, Código do Usuário de destino da Mensagem
/*/
method setToUser(cToUser) class CbcMessage
	::cToUser := cToUser
return


/*/{Protheus.doc} getNameToUser

Coleta o Nome do Usuário de destino na Mensagem
	
@author victorhugo
@since 12/05/2016

@return String Nome do Usuário de destino na Mensagem
/*/
method getNameToUser() class CbcMessage
return ::cNameToUser


/*/{Protheus.doc} setNameToUser

Define o Nome do Usuário de destino na Mensagem
	
@author victorhugo
@since 12/05/2016

@param cNameToUser, String, Nome do Usuário de destino na Mensagem
/*/
method setNameToUser(cNameToUser) class CbcMessage
	::cNameToUser := cNameToUser
return


/*/{Protheus.doc} getDate

Coleta a Data de Criação da Mensagem
	
@author victorhugo
@since 24/02/2016

@return Data Data de Criação da Mensagem
/*/
method getDate() class CbcMessage
return ::dDate


/*/{Protheus.doc} setDate

Define a Data de Criação da Mensagem
	
@author victorhugo
@since 24/02/2016

@param dDate, Data, Data de Criação da Mensagem
/*/
method setDate(dDate) class CbcMessage
	::dDate := dDate
	setWhen(@self)
return


/*/{Protheus.doc} getTime

Coleta a Hora de Criação da Mensagem
	
@author victorhugo
@since 24/02/2016

@return typeDescription Hora de Criação da Mensagem
/*/
method getTime() class CbcMessage
return ::cTime


/*/{Protheus.doc} setTime

Define a Hora de Criação da Mensagem
	
@author victorhugo
@since 24/02/2016

@param cTime, typeDescription, Hora de Criação da Mensagem
/*/
method setTime(cTime) class CbcMessage
	::cTime := cTime
	setWhen(@self)
return


/*/{Protheus.doc} getSubject

Coleta o Assunto da Mensagem
	
@author victorhugo
@since 11/04/2016

@return String Assunto da Mensagem
/*/
method getSubject() class CbcMessage
return ::cSubject


/*/{Protheus.doc} setSubject

Define o Assunto da Mensagem
	
@author victorhugo
@since 11/04/2016

@param cSubject, String, Assunto da Mensagem
/*/
method setSubject(cSubject) class CbcMessage
	::cSubject := cSubject
return


/*/{Protheus.doc} getDateDisplay

Coleta a Data em que a Mensagem foi visualizada
	
@author victorhugo
@since 24/02/2016

@return Data Data em que a Mensagem foi visualizada
/*/
method getDateDisplay() class CbcMessage
return ::dDateDisplay


/*/{Protheus.doc} setDateDisplay

Define a Data em que a Mensagem foi visualizada
	
@author victorhugo
@since 24/02/2016

@param dDataDisplay, Data, Data em que a Mensagem foi visualizada
/*/
method setDateDisplay(dDateDisplay) class CbcMessage
	::dDateDisplay := dDateDisplay
return


/*/{Protheus.doc} getTimeDisplay

Coleta a Hora em que a Mensagem foi visualizada
	
@author victorhugo
@since 24/02/2016

@return String Hora em que a Mensagem foi visualizada
/*/
method getTimeDisplay() class CbcMessage
return ::cTimeDisplay


/*/{Protheus.doc} setTimeDisplay

Define a Hora em que a Mensagem foi visualizada
	
@author victorhugo
@since 24/02/2016

@param cTimeDisplay, String, Hora em que a Mensagem foi visualizada
/*/
method setTimeDisplay(cTimeDisplay) class CbcMessage
	::cTimeDisplay := cTimeDisplay
return


/*/{Protheus.doc} getText

Coleta o Texto da Mensagem
	
@author victorhugo
@since 11/04/2016

@return String Texto da Mensagem
/*/
method getText() class CbcMessage
return ::cText


/*/{Protheus.doc} setText

Define o Texto da Mensagem
	
@author victorhugo
@since 11/04/2016

@param cText, String, Texto da Mensagem
/*/
method setText(cText) class CbcMessage
	::cText := cText
return


/*/{Protheus.doc} getDateEmail

Coleta a Data de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@return Data Data de Envio do E-mail
/*/
method getDateEmail() class CbcMessage
return ::dDateEmail


/*/{Protheus.doc} setDateEmail

Define a Data de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@param dDateEmail, Data, Data de Envio do E-mail
/*/
method setDateEmail(dDateEmail) class CbcMessage
	::dDateEmail := dDateEmail
return


/*/{Protheus.doc} getTimeEmail

Coleta a Hora de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@return String Hora de Envio do E-mail
/*/
method getTimeEmail() class CbcMessage
return ::cTimeEmail


/*/{Protheus.doc} setTimeEmail

Define a Hora de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@param cTimeEmail, String, Hora de Envio do E-mail
/*/
method setTimeEmail(cTimeEmail) class CbcMessage
	::cTimeEmail := cTimeEmail
return


/*/{Protheus.doc} getWhen

Coleta o Texto sobre quando ocorreu a Mensagem
	
@author victorhugo
@since 06/04/2016

@return String Texto sobre quando ocorreu a Mensagem
/*/
method getWhen() class CbcMessage
return ::cWhen

/**
 * Define o Texto sobre quando a Mensagem foi enviada
 */
static function setWhen(oSelf)
	
	local dDate  := oSelf:getDate()
	local cTime  := oSelf:getTime()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	if (!Empty(dDate) .and. !Empty(cTime))
		oSelf:cWhen := oUtils:getWhenMessage(dDate, cTime)
	endIf
	
return


/*/{Protheus.doc} isFiled

Indica se a Mensagem foi arquivada
	
@author victorhugo
@since 18/05/2016

@return Logico Mensagem foi arquivada
/*/
method isFiled() class CbcMessage
return ::lFiled


/*/{Protheus.doc} setFiled

Define se a Mensagem foi arquivada
	
@author victorhugo
@since 18/05/2016

@param lFiled, Logico, Mensagem foi arquivada
/*/
method setFiled(lFiled) class CbcMessage
	::lFiled := lFiled
return


method getQuotationId() class CbcMessage
return ::cQuotationId

method setQuotationId(cQuotationId) class CbcMessage
	::cQuotationId := cQuotationId
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcMessage
	
	local oWsObj := WsClassNew("WsCbcMessage")
	
	oWsObj:id 			:= ::getId()
	oWsObj:fromUser 	:= ::getFromUser()
	oWsObj:fromUserName := ::getNameFromUser()
	oWsObj:toUser 		:= ::getToUser()
	oWsObj:toUserName 	:= ::getNameToUser()
	oWsObj:date 		:= ::getDate()
	oWsObj:time 		:= ::getTime()
	oWsObj:subject 		:= ::getSubject()
	oWsObj:dateDisplay 	:= ::getDateDisplay()
	oWsObj:timeDisplay  := ::getTimeDisplay()
	oWsObj:text 		:= StrTran(::getText(), CRLF, "<br/>")
	oWsObj:dateEmail 	:= ::getDateEmail()
	oWsObj:timeEmail 	:= ::getTimeEmail()
	oWsObj:when			:= ::getWhen()
	oWsObj:isFiled		:= ::isFiled()
	oWsObj:quotationId	:= ::getQuotationId()
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 23/05/2016

@param oWsObj, WsCbcQuotation, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcMessage
	
	::setId(oWsObj:id)
	::setFromUser(oWsObj:fromUser)
	::setNameFromUser(oWsObj:fromUserName)
	::setToUser(oWsObj:toUser)
	::setNameToUser(oWsObj:toUserName)
	::setDate(oWsObj:date)
	::setTime(oWsObj:time)
	::setSubject(oWsObj:subject)
	::setDateDisplay(oWsObj:dateDisplay)
	::setTimeDisplay(oWsObj:timeDisplay)
	::setText(oWsObj:text)
	::setDateEmail(oWsObj:dateEmail)
	::setTimeEmail(oWsObj:timeEmail)
	::setFiled(oWsObj:isFiled)
	::setQuotationId(oWsObj:quotationId)
	
return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcMessage
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	oJson["id"] 			:= ::getId()
	oJson["fromUser"] 		:= ::getFromUser()
	oJson["fromUserName"] 	:= ::getNameFromUser()
	oJson["toUser"] 		:= ::getToUser()
	oJson["toUserName"] 	:= ::getNameToUser()
	oJson["date"] 			:= oUtils:getJsDate(::getDate())
	oJson["time"] 			:= ::getTime()
	oJson["subject"] 		:= ::getSubject()
	oJson["dateDisplay"] 	:= oUtils:getJsDate(::getDateDisplay())
	oJson["timeDisplay"]  	:= ::getTimeDisplay()
	oJson["text"] 			:= StrTran(::getText(), CRLF, "<br/>")
	oJson["dateEmail"] 		:= oUtils:getJsDate(::getDateEmail())
	oJson["timeEmail"] 		:= ::getTimeEmail()
	oJson["when"]			:= ::getWhen()
	oJson["isFiled"]		:= ::isFiled()
	oJson["quotationId"]	:= ::getQuotationId()	

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcMessage
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcMessage
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson["id"])
	::setFromUser(oJson["fromUser"])
	::setNameFromUser(oJson["fromUserName"])
	::setToUser(oJson["toUser"])
	::setNameToUser(oJson["toUserName"])
	::setDate(oUtils:fromJsDate(oJson["date"]))
	::setTime(oJson["time"])
	::setSubject(oJson["subject"])
	::setDateDisplay(oUtils:fromJsDate(oJson["dateDisplay"]))
	::setTimeDisplay(oJson["timeDisplay"])
	::setText(oJson["text"])
	::setDateEmail(oUtils:fromJsDate(oJson["dateEmail"]))
	::setTimeEmail(oJson["timeEmail"] )
	::setFiled(oJson["isFiled"])
	::setQuotationId(oJson["quotationId"])
	
return


/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcMessage
	
	local oJson	:= nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson:cId)
	::setFromUser(oJson:cFromUser)
	::setNameFromUser(oJson:cNameFromUser)
	::setToUser(oJson:cToUser)
	::setNameToUser(oJson:cNameToUser)
	::setDate(oJson:dDate)
	::setTime(oJson:cTime)
	::setSubject(oJson:cSubject)
	::setDateDisplay(oJson:dDateDisplay)
	::setTimeDisplay(oJson:cTimeDisplay)
	::setText(oJson:cText)
	::setDateEmail(oJson:dDateEmail)
	::setTimeEmail(oJson:cTimeEmail)
	::setFiled(oJson:lFiled)
	::setQuotationId(oJson:cQuotationId)
	
return
