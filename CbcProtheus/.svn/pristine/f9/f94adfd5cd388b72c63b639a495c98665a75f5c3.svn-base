#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcNotification

Objeto que representa uma Notificação do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcNotification from LongClassName
	
	data cId
	data cEvent
	data cEventName
	data cFromUser
	data cToUser
	data dDate
	data cTime
	data dDateDisplay
	data cTimeDisplay
	data cMessage
	data lEmail
	data dDateEmail
	data cTimeEmail
	data cIcon
	data cIconColor
	data cWhen
	
	method newCbcNotification() constructor
	
	method getId()
	method setId()
	method getEvent()
	method setEvent()
	method getEventName()
	method setEventName()
	method getFromUser()
	method setFromUser()
	method getToUser()
	method setToUser()
	method getDate()
	method setDate()
	method getTime()
	method setTime()
	method getDateDisplay()
	method setDateDisplay()
	method getTimeDisplay()
	method setTimeDisplay()
	method getMessage()
	method setMessage()
	method isEmail()
	method setEmail()
	method getDateEmail()
	method setDateEmail()
	method getTimeEmail()
	method setTimeEmail() 
	method getIcon()
	method getIconColor()
	method getWhen()
	 
	method toWsObject()
	method getHtmlMessage()
	method isDisplayed()
	method toJsonObject() 
	method toJsonString()
	 			
endClass


/*/{Protheus.doc} newCbcNotification

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcNotification() class CbcNotification
return self


/*/{Protheus.doc} getId

Coleta o ID da Notificação
	
@author victorhugo
@since 24/02/2016

@return String ID da Notificação
/*/
method getId() class CbcNotification
return ::cId


/*/{Protheus.doc} setId

Define o ID da Notificação
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Notificação
/*/
method setId(cId) class CbcNotification
	::cId := cId
return


/*/{Protheus.doc} getEvent

Coleta o Código do Evento da Notificação
	
@author victorhugo
@since 24/02/2016

@return String Código do Evento da Notificação
/*/
method getEvent() class CbcNotification
return ::cEvent


/*/{Protheus.doc} setEvent

Define o Código do Evento da Notificação
	
@author victorhugo
@since 24/02/2016

@param cEvent, String, Código do Evento da Notificação
/*/
method setEvent(cEvent) class CbcNotification
	::cEvent := cEvent
	setIcon(@self)
return


/*/{Protheus.doc} getEventName

Coleta o Nome do Evento da Notificação
	
@author victorhugo
@since 24/02/2016

@return String Nome do Evento da Notificação
/*/
method getEventName() class CbcNotification
return ::cEventName


/*/{Protheus.doc} setEventName

Define o Nome do Evento da Notificação
	
@author victorhugo
@since 24/02/2016

@param cEventName, String, Nome do Evento da Notificação
/*/
method setEventName(cEventName) class CbcNotification
	::cEventName := cEventName
return


/*/{Protheus.doc} getFromUser

Coleta o Código do Usuário que originou a Notificação
	
@author victorhugo
@since 24/02/2016

@return String Código do Usuário que originou a Notificação
/*/
method getFromUser() class CbcNotification
return ::cFromuser


/*/{Protheus.doc} setFromUser

Define o Código do Usuário que originou a Notificação
	
@author victorhugo
@since 24/02/2016

@param cFromuser, String, Código do Usuário que originou a Notificação
/*/
method setFromUser(cFromuser) class CbcNotification
	::cFromuser := cFromuser
return


/*/{Protheus.doc} getToUser

Coleta o Código do Usuário de destino da Notificação
	
@author victorhugo
@since 24/02/2016

@return typeDescription Código do Usuário de destino da Notificação
/*/
method getToUser() class CbcNotification
return ::cToUser


/*/{Protheus.doc} setToUser

Define o Código do Usuário de destino da Notificação
	
@author victorhugo
@since 24/02/2016

@param cToUser, typeDescription, Código do Usuário de destino da Notificação
/*/
method setToUser(cToUser) class CbcNotification
	::cToUser := cToUser
return


/*/{Protheus.doc} getDate

Coleta a Data de Criação da Notificação
	
@author victorhugo
@since 24/02/2016

@return Data Data de Criação da Notificação
/*/
method getDate() class CbcNotification
return ::dDate


/*/{Protheus.doc} setDate

Define a Data de Criação da Notificação
	
@author victorhugo
@since 24/02/2016

@param dDate, Data, Data de Criação da Notificação
/*/
method setDate(dDate) class CbcNotification
	::dDate := dDate
	setWhen(@self)
return


/*/{Protheus.doc} getTime

Coleta a Hora de Criação da Notificação
	
@author victorhugo
@since 24/02/2016

@return typeDescription Hora de Criação da Notificação
/*/
method getTime() class CbcNotification
return ::cTime


/*/{Protheus.doc} setTime

Define a Hora de Criação da Notificação
	
@author victorhugo
@since 24/02/2016

@param cTime, typeDescription, Hora de Criação da Notificação
/*/
method setTime(cTime) class CbcNotification
	::cTime := cTime
	setWhen(@self)
return


/*/{Protheus.doc} getDateDisplay

Coleta a Data em que a Notificação foi visualizada
	
@author victorhugo
@since 24/02/2016

@return Data Data em que a Notificação foi visualizada
/*/
method getDateDisplay() class CbcNotification
return ::dDateDisplay


/*/{Protheus.doc} setDateDisplay

Define a Data em que a Notificação foi visualizada
	
@author victorhugo
@since 24/02/2016

@param dDataDisplay, Data, Data em que a Notificação foi visualizada
/*/
method setDateDisplay(dDateDisplay) class CbcNotification
	::dDateDisplay := dDateDisplay
return


/*/{Protheus.doc} getTimeDisplay

Coleta a Hora em que a Notificação foi visualizada
	
@author victorhugo
@since 24/02/2016

@return String Hora em que a Notificação foi visualizada
/*/
method getTimeDisplay() class CbcNotification
return ::cTimeDisplay


/*/{Protheus.doc} setTimeDisplay

Define a Hora em que a Notificação foi visualizada
	
@author victorhugo
@since 24/02/2016

@param cTimeDisplay, String, Hora em que a Notificação foi visualizada
/*/
method setTimeDisplay(cTimeDisplay) class CbcNotification
	::cTimeDisplay := cTimeDisplay
return


/*/{Protheus.doc} getMessage

Coleta a Mensagem da Notificação
	
@author victorhugo
@since 24/02/2016

@return String Mensagem da Notificação
/*/
method getMessage() class CbcNotification
return ::cMessage


/*/{Protheus.doc} setMessage

Define a Mensagem da Notificação
	
@author victorhugo
@since 24/02/2016

@param cMessage, String, Mensagem da Notificação
/*/
method setMessage(cMessage) class CbcNotification
	::cMessage := cMessage
return


/*/{Protheus.doc} isEmail

Indica se deve enviar a Notificação por E-mail
	
@author victorhugo
@since 29/02/2016

@return Logico deve enviar a Notificação por E-mail
/*/
method isEmail() class CbcNotification
return ::lEmail


/*/{Protheus.doc} setEmail

Define se deve enviar a Notificação por E-mail
	
@author victorhugo
@since 29/02/2016

@param lEmail, Logico, deve enviar a Notificação por E-mail
/*/
method setEmail(lEmail) class CbcNotification
	::lEmail := lEmail
return


/*/{Protheus.doc} getDateEmail

Coleta a Data de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@return Data Data de Envio do E-mail
/*/
method getDateEmail() class CbcNotification
return ::dDateEmail


/*/{Protheus.doc} setDateEmail

Define a Data de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@param dDateEmail, Data, Data de Envio do E-mail
/*/
method setDateEmail(dDateEmail) class CbcNotification
	::dDateEmail := dDateEmail
return


/*/{Protheus.doc} getTimeEmail

Coleta a Hora de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@return String Hora de Envio do E-mail
/*/
method getTimeEmail() class CbcNotification
return ::cTimeEmail


/*/{Protheus.doc} setTimeEmail

Define a Hora de Envio do E-mail
	
@author victorhugo
@since 29/02/2016

@param cTimeEmail, String, Hora de Envio do E-mail
/*/
method setTimeEmail(cTimeEmail) class CbcNotification
	::cTimeEmail := cTimeEmail
return


/*/{Protheus.doc} getIcon

Coleta o Icone do Evento para exibição no Portal
	
@author victorhugo
@since 06/04/2016

@return String Icone do Evento para exibição no Portal
/*/
method getIcon() class CbcNotification
return ::cIcon


/*/{Protheus.doc} getIconColor

Coleta a Cor do Icone do Evento
	
@author victorhugo
@since 06/04/2016

@return String Cor do Icone do Evento
/*/
method getIconColor() class CbcNotification
return ::cIconColor

/**
 * Define o Icone a partir do Evento
 */
static function setIcon(oSelf)
	
	local nScan  := 0
	local aIcons := {}
	
	aAdd(aIcons, {EVENT_USER_CREATE							, "user-plus"			, "info"})
	aAdd(aIcons, {EVENT_USER_UPDATE							, "pencil-square-o"		, "info"})
	aAdd(aIcons, {EVENT_PROSPECT_CREATE						, "user-plus"			, "info"})
	aAdd(aIcons, {EVENT_USER_GROUP_CHANGE					, "users"				, "info"})
	aAdd(aIcons, {EVENT_USER_WELCOME						, "info-circle"			, "info"})
	aAdd(aIcons, {EVENT_PORTAL_LOGIN						, "sign-in"				, "info"})	
	aAdd(aIcons, {EVENT_PORTAL_LOGOUT						, "sign-out"			, "info"})
		
	aAdd(aIcons, {EVENT_QUOTATION_CREATE					, "plus-square"			, "success"})
	aAdd(aIcons, {EVENT_QUOTATION_UPDATE					, "pencil-square"		, "info"})
	aAdd(aIcons, {EVENT_QUOTATION_DELETE					, "trash"				, "danger"})
	aAdd(aIcons, {EVENT_QUOTATION_CANCEL					, "times-circle"		, "danger"})
	aAdd(aIcons, {EVENT_FINISH_QUOTATION_MAINTENANCE		, "check-square-o"		, "success"})
	aAdd(aIcons, {EVENT_SEND_QUOTATION_FOR_APPROVAL			, "share"				, "info"})	
	aAdd(aIcons, {EVENT_ASSUME_QUOTATION_APPROVAL			, "magic"				, "info"})
	aAdd(aIcons, {EVENT_QUOTATION_APPROVAL					, "thumbs-o-up"			, "success"})
	aAdd(aIcons, {EVENT_QUOTATION_REJECTION					, "thumbs-o-down"  		, "danger"})
	aAdd(aIcons, {EVENT_UNDO_QUOTATION_APPROVAL				, "undo"				, "warning"})
	aAdd(aIcons, {EVENT_LOCK_QUOTATION_UPDATE				, "lock"				, "warning"})
	aAdd(aIcons, {EVENT_UNLOCK_QUOTATION_UPDATE				, "unlock-alt"			, "info"})
	aAdd(aIcons, {EVENT_GIVE_UP_QUOTATION_APPROVAL			, "undo"				, "warning"})
	aAdd(aIcons, {EVENT_QUOTATION_TEC_APPROVAL				, "check-circle-o"		, "success"})
	aAdd(aIcons, {EVENT_QUOTATION_TEC_REJECTION				, "times-circle-o"		, "danger"})	
	aAdd(aIcons, {EVENT_CONFIRM_QUOTATION					, "check"				, "success"})
	aAdd(aIcons, {EVENT_CREATE_QUOTATION_INVOICE			, "dollar"				, "success"})
	aAdd(aIcons, {EVENT_ERROR_PROCESSING_QUOTATION			, "exclamation-circle"	, "danger"})
	
	aAdd(aIcons, {EVENT_PRODUCT_BALANCE_INTEREST			, "thumbs-o-up"			, "success"})
	aAdd(aIcons, {EVENT_PRODUCT_BALANCE_RESERVE				, "lock"				, "success"})
	aAdd(aIcons, {EVENT_CANCEL_PRODUCT_BALANCE_RESERVE		, "times"				, "danger"})
	aAdd(aIcons, {EVENT_PRODUCT_BALANCE_RESERVE_EXPIRED 	, "exclamation-circle"	, "warning"})
	aAdd(aIcons, {EVENT_PRODUCT_BALANCE_RESERVE_CONFIRMED	, "check"				, "success"})
	aAdd(aIcons, {EVENT_PRODUCT_BALANCE_RESERVE_UNDO_CONFIRM, "undo"				, "danger"})
	aAdd(aIcons, {EVENT_USE_TERMS_ACCEPT					, "check-square-o"		, "success"})
	aAdd(aIcons, {EVENT_USE_TERMS_REJECT					, "times-circle-o"		, "danger"})
	
	nScan := aScan(aIcons, { |x| x[1] == oSelf:cEvent })
	
	if (nScan > 0)
		oSelf:cIcon      := aIcons[nScan,2]
		oSelf:cIconColor := aIcons[nScan,3]
	else
		oSelf:cIcon 	 := "info-circle"
		oSelf:cIconColor := "info"	
 	endIf
	
return

/*/{Protheus.doc} getWhen

Coleta o Texto sobre quando ocorreu a Notificação
	
@author victorhugo
@since 06/04/2016

@return String Texto sobre quando ocorreu a Notificação
/*/
method getWhen() class CbcNotification
return ::cWhen

/**
 * Define o Texto sobre quando ocorreu a Notificação
 */
static function setWhen(oSelf)
	
	local dDate  := oSelf:getDate()
	local cTime  := oSelf:getTime()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	if (!Empty(dDate) .and. !Empty(cTime))
		oSelf:cWhen := oUtils:getWhenMessage(dDate, cTime)
	endIf

return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcNotification
	
	local oWsObj := WsClassNew("WsCbcNotification")
	
	oWsObj:id 			:= ::getId()
	oWsObj:event 		:= ::getEvent()
	oWsObj:eventName 	:= ::getEventName()
	oWsObj:fromUser 	:= ::getFromUser()
	oWsObj:toUser 		:= ::getToUser()
	oWsObj:date 		:= ::getDate()
	oWsObj:time 		:= ::getTime()
	oWsObj:dateDisplay 	:= ::getDateDisplay()
	oWsObj:timeDisplay  := ::getTimeDisplay()
	oWsObj:message 		:= ::getHtmlMessage()
	oWsObj:email 		:= ::isEmail()
	oWsObj:dateEmail 	:= ::getDateEmail()
	oWsObj:timeEmail 	:= ::getTimeEmail()
	oWsObj:icon			:= ::getIcon()
	oWsObj:iconColor	:= ::getIconColor()
	oWsObj:when			:= ::getWhen()
	
return oWsObj


/*/{Protheus.doc} getHtmlMessage

Coleta a mensagem da Notificação em HTML
	
@author victorhugo
@since 28/04/2016
/*/
method getHtmlMessage() class CbcNotification
	
	local cBrTag := "<br/>" 
	local cMsg   := ::getMessage()

	if Empty(cMsg)
		return "" 
	endIf

	cMsg := AllTrim(cMsg)

	if !(cBrTag $ Lower(cMsg))
		cMsg := StrTran(cMsg, CRLF, cBrTag)
	endIf

return cMsg


/*/{Protheus.doc} isDisplayed

Indica se a Notificação foi visualizada
	
@author victorhugo
@since 04/05/2016
/*/
method isDisplayed() class CbcNotification	
return !Empty(::dDateDisplay)


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcNotification
	
	local oJson  := JsonObject():new()
	local oUtils := LibUtilsObj():newLibUtilsObj()
	
	oJson["id"] 			:= ::getId()
	oJson["event"] 			:= ::getEvent()
	oJson["eventName"] 		:= ::getEventName()
	oJson["fromUser"] 		:= ::getFromUser()
	oJson["toUser"] 		:= ::getToUser()
	oJson["date"] 			:= oUtils:getJsDate(::getDate())
	oJson["time"] 			:= ::getTime()
	oJson["dateDisplay"] 	:= oUtils:getJsDate(::getDateDisplay())
	oJson["timeDisplay"]  	:= ::getTimeDisplay()
	oJson["message"] 		:= ::getHtmlMessage()
	oJson["email"] 			:= ::isEmail()
	oJson["dateEmail"] 		:= oUtils:getJsDate(::getDateEmail())
	oJson["timeEmail"] 		:= ::getTimeEmail()
	oJson["icon"]			:= ::getIcon()
	oJson["iconColor"]		:= ::getIconColor()
	oJson["when"]			:= ::getWhen()	

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcNotification
return ::toJsonObject():toJson()
