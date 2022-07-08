#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcOpportunityBalanceReserve

Objeto que representa uma Reserva do Saldo do Estoque de Oportunidades da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcOpportunityBalanceReserve from LongClassName
	
	data cStatus
	data cId
	data dDate
	data cTime
	data dDateValid
	data cTimeValid
	data cUserId
	data cUserName
	data cCodeCustomer
	data cUnitCustomer
	data cNameCustomer
	data oBalance
	data cItemQuotation
	data cIdQuotation
	
	method newCbcOpportunityBalanceReserve() constructor
	
	method getStatus()
	method setStatus()
	method getId()
	method setId()	
	method getDate()
	method setDate()
	method getTime()
	method setTime()
	method getDateValid()
	method setDateValid()
	method getTimeValid()
	method setTimeValid()
	method getUserId()
	method setUserId()
	method getUserName()
	method setUserName()
	method getCodeCustomer()
	method setCodeCustomer()
	method getUnitCustomer()
	method setUnitCustomer()
	method getNameCustomer()
	method setNameCustomer()
	method getBalance()
	method setBalance()
	method getItemQuotation()
	method setItemQuotation()
	method getIdQuotation()
	method setIdQuotation()
	
	method toWsObject()
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
		
endClass


/*/{Protheus.doc} newCbcOpportunityBalanceReserve

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcOpportunityBalanceReserve() class CbcOpportunityBalanceReserve
return self


/*/{Protheus.doc} getStatus

Coleta o Status da Reserva
	
@author victorhugo
@since 05/03/2016

@return String Status da Reserva
/*/
method getStatus() class CbcOpportunityBalanceReserve
return ::cStatus


/*/{Protheus.doc} setStatus

Define o Status da Reserva
	
@author victorhugo
@since 05/03/2016

@param cStatus, String, Status da Reserva
/*/
method setStatus(cStatus) class CbcOpportunityBalanceReserve
	::cStatus := cStatus
return


/*/{Protheus.doc} getId

Coleta o ID da Reserva
	
@author victorhugo
@since 05/03/2016

@return String ID da Reserva
/*/
method getId() class CbcOpportunityBalanceReserve
return ::cId


/*/{Protheus.doc} setId

Define o ID da Reserva
	
@author victorhugo
@since 05/03/2016

@param cId, String, ID da Reserva
/*/
method setId(cId) class CbcOpportunityBalanceReserve
	::cId := cId
return


/*/{Protheus.doc} getDate

Coleta a Data da Reserva
	
@author victorhugo
@since 05/03/2016

@return Date Data da Reserva
/*/
method getDate() class CbcOpportunityBalanceReserve
return ::dDate


/*/{Protheus.doc} setDate

Define a Data da Reserva
	
@author victorhugo
@since 05/03/2016

@param dDate, Date, Data da Reserva
/*/
method setDate(dDate) class CbcOpportunityBalanceReserve
	::dDate := dDate
return


/*/{Protheus.doc} getTime

Coleta a Hora da Reserva
	
@author victorhugo
@since 05/03/2016

@return String Hora da Reserva
/*/
method getTime() class CbcOpportunityBalanceReserve
return ::cTime


/*/{Protheus.doc} setTime

Define a Hora da Reserva
	
@author victorhugo
@since 05/03/2016

@param cTime, String, Hora da Reserva
/*/
method setTime(cTime) class CbcOpportunityBalanceReserve
	::cTime := cTime
return


/*/{Protheus.doc} getDateValid

Coleta a Data de Validade da Reserva
	
@author victorhugo
@since 14/03/2016

@return Date Data de Validade da Reserva
/*/
method getDateValid() class CbcOpportunityBalanceReserve
return ::dDateValid


/*/{Protheus.doc} setDateValid

Define a Data de Validade da Reserva
	
@author victorhugo
@since 14/03/2016

@param dDateValid, Date, Data de Validade da Reserva
/*/
method setDateValid(dDateValid) class CbcOpportunityBalanceReserve
	::dDateValid := dDateValid
return


/*/{Protheus.doc} getTimeValid

Coleta a Hora de Validade da Reserva
	
@author victorhugo
@since 14/03/2016

@return String Hora de Validade da Reserva
/*/
method getTimeValid() class CbcOpportunityBalanceReserve
return ::cTimeValid


/*/{Protheus.doc} setTimeValid

Define a Hora de Validade da Reserva
	
@author victorhugo
@since 14/03/2016

@param cTimeValid, String, Hora de Validade da Reserva
/*/
method setTimeValid(cTimeValid) class CbcOpportunityBalanceReserve
	::cTimeValid := cTimeValid
return


/*/{Protheus.doc} getUserId

Coleta o ID do Usuário que fez a Reserva
	
@author victorhugo
@since 05/03/2016

@return String ID do Usuário que fez a Reserva
/*/
method getUserId() class CbcOpportunityBalanceReserve
return ::cUserId


/*/{Protheus.doc} setUserId

Define o ID do Usuário que fez a Reserva
	
@author victorhugo
@since 05/03/2016

@param cUserId, String, ID do Usuário que fez a Reserva
/*/
method setUserId(cUserId) class CbcOpportunityBalanceReserve
	::cUserId := cUserId
return


/*/{Protheus.doc} getUserName

Coleta o Nome do Usuário
	
@author victorhugo
@since 07/05/2016

@return String Nome do Usuário
/*/
method getUserName() class CbcOpportunityBalanceReserve
return ::cUserName


/*/{Protheus.doc} setUserName

Define o Nome do Usuário
	
@author victorhugo
@since 07/05/2016

@param cUserName, String, Nome do Usuário
/*/
method setUserName(cUserName) class CbcOpportunityBalanceReserve
	::cUserName := cUserName
return


/*/{Protheus.doc} getCodeCustomer

Coleta o Código do Cliente ou Prospect
	
@author victorhugo
@since 29/03/2016

@return String Código do Cliente ou Prospect
/*/
method getCodeCustomer() class CbcOpportunityBalanceReserve
return ::cCodeCustomer


/*/{Protheus.doc} setCodeCustomer

Define o Código do Cliente ou Prospect
	
@author victorhugo
@since 29/03/2016

@param cCodeCustomer, String, Código do Cliente ou Prospect
/*/
method setCodeCustomer(cCodeCustomer) class CbcOpportunityBalanceReserve
	::cCodeCustomer := cCodeCustomer
return


/*/{Protheus.doc} getUnitCustomer

Coleta a Loja do Cliente ou Prospect
	
@author victorhugo
@since 29/03/2016

@return String Loja do Cliente ou Prospect
/*/
method getUnitCustomer() class CbcOpportunityBalanceReserve
return ::cUnitCustomer


/*/{Protheus.doc} setUnitCustomer

Define a Loja do Cliente ou Prospect
	
@author victorhugo
@since 29/03/2016

@param cUnitCustomer, String, Loja do Cliente ou Prospect
/*/
method setUnitCustomer(cUnitCustomer) class CbcOpportunityBalanceReserve
	::cUnitCustomer := cUnitCustomer
return


/*/{Protheus.doc} getNameCustomer

Coleta o Nome do Cliente
	
@author victorhugo
@since 07/05/2016

@return String Nome do Cliente
/*/
method getNameCustomer() class CbcOpportunityBalanceReserve
return ::cNameCustomer


/*/{Protheus.doc} setNameCustomer

Define o Nome do Cliente
	
@author victorhugo
@since 07/05/2016

@param cNameCustomer, String, Nome do Cliente
/*/
method setNameCustomer(cNameCustomer) class CbcOpportunityBalanceReserve
	::cNameCustomer := cNameCustomer
return


/*/{Protheus.doc} getBalance

Coleta o Saldo Reservado
	
@author victorhugo
@since 05/03/2016

@return CbcOpportunityBalance Saldo Reservado
/*/
method getBalance() class CbcOpportunityBalanceReserve
return ::oBalance


/*/{Protheus.doc} setBalance

Define o Saldo Reservado
	
@author victorhugo
@since 05/03/2016

@param oBalance, CbcOpportunityBalance, Saldo Reservado
/*/
method setBalance(oBalance) class CbcOpportunityBalanceReserve
	::oBalance := oBalance
return	


method getItemQuotation() class CbcOpportunityBalanceReserve
return ::cItemQuotation

method setItemQuotation(cItemQuotation) class CbcOpportunityBalanceReserve
	::cItemQuotation := cItemQuotation
return

method getIdQuotation() class CbcOpportunityBalanceReserve
return ::cIdQuotation

method setIdQuotation(cIdQuotation) class CbcOpportunityBalanceReserve
	::cIdQuotation := cIdQuotation
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcOpportunityBalanceReserve
	
	local oWsObj 	:= WsClassNew("WsCbcOpportunityBalanceReserve")
	local oUtils 	:= LibUtilsObj():newLibUtilsObj() 
	local oBalance	:= ::getBalance() 
	
	oWsObj:status		 := ::getStatus()	
	oWsObj:id			 := ::getId()
	oWsObj:date			 := ::getDate()
	oWsObj:time			 := ::getTime()
	oWsObj:dateValid	 := ::getDateValid()
	oWsObj:timeValid	 := ::getTimeValid()
	oWsObj:userId		 := ::getUserId()
	oWsObj:userName		 := ::getUserName()
	oWsObj:customerCode  := ::getCodeCustomer()
	oWsObj:customerUnit  := ::getUnitCustomer()
	oWsObj:customerName	 := ::getNameCustomer()
	oWsObj:itemQuotation := ::getItemQuotation()
	oWsObj:idQuotation   := ::getIdQuotation() 
	
	if oUtils:isNotNull(oBalance)
		oWsObj:balance := oBalance:toWsObject() 
	endIf
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcCustomer, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcOpportunityBalanceReserve
	
	local oBalance := nil
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	
	::setStatus(oWsObj:status)	
	::setId(oWsObj:id)
	::setDate(oWsObj:date)
	::setTime(oWsObj:time)
	::setDateValid(oWsObj:dateValid)
	::setTimeValid(oWsObj:timeValid)
	::setUserId(oWsObj:userId)
	::setUserName(oWsObj:userName)
	::setCodeCustomer(oWsObj:customerCode)
	::setUnitCustomer(oWsObj:customerUnit)
	::setNameCustomer(oWsObj:customerName)
	::setItemQuotation(oWsObj:itemQuotation)
	::setIdQuotation(oWsObj:idQuotation)
	
	if oUtils:isNotNull(oWsObj:balance)
		oBalance := CbcOpportunityBalance():newCbcOpportunityBalance()
		oBalance:fromWsObject(oWsObj:balance)		
	endIf
	
	::setBalance(oBalance)
	
return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcOpportunityBalanceReserve
	
	local oJson     := JsonObject():new()
	local oUtils 	:= LibUtilsObj():newLibUtilsObj() 
	local oBalance	:= ::getBalance() 
	
	oJson["status"]		   := ::getStatus()	
	oJson["id"]			   := ::getId()
	oJson["date"]		   := oUtils:getJsDate(::getDate())
	oJson["time"]		   := ::getTime()
	oJson["dateValid"]	   := oUtils:getJsDate(::getDateValid())
	oJson["timeValid"]	   := ::getTimeValid()
	oJson["userId"]		   := ::getUserId()
	oJson["userName"]	   := ::getUserName()
	oJson["customerCode"]  := ::getCodeCustomer()
	oJson["customerUnit"]  := ::getUnitCustomer()
	oJson["customerName"]  := ::getNameCustomer()
	oJson["itemQuotation"] := AllTrim(::getItemQuotation())
	oJson["idQuotation"]   := AllTrim(::getIdQuotation())	
	oJson["isWaiting"]	   := (::getStatus() == RESERVE_STATUS_WAITING)
	oJson["isConfirmed"]   := (::getStatus() == RESERVE_STATUS_CONFIRMED)
	oJson["isExpired"]	   := (::getStatus() == RESERVE_STATUS_EXPIRED)
	oJson["isCanceled"]	   := (::getStatus() == RESERVE_STATUS_CANCELED)
	
	if oUtils:isNotNull(oBalance)
		oJson["balance"] := oBalance:toJsonObject() 
	endIf	

return oJson


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcOpportunityBalanceReserve
		
	local oBalance := nil
	local oJson    := JsonObject():new()
	local oUtils   := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setStatus(oJson["status"])	
	::setId(oJson["id"])
	::setDate(oUtils:fromJsDate(oJson["date"]))
	::setTime(oJson["time"])
	::setDateValid(oUtils:fromJsDate(oJson["dateValid"]))
	::setTimeValid(oJson["timeValid"])
	::setUserId(oJson["userId"])
	::setUserName(oJson["userName"])
	::setCodeCustomer(oJson["customerCode"])
	::setUnitCustomer(oJson["customerUnit"])
	::setNameCustomer(oJson["customerName"])
	::setItemQuotation(oJson["itemQuotation"])
	::setIdQuotation(oJson["idQuotation"]) 
	
	if oUtils:isNotNull(oJson["balance"])
		oBalance := CbcOpportunityBalance():newCbcOpportunityBalance()
		oBalance:fromJsonObject(oJson["balance"])		
	endIf
	
	::setBalance(oBalance)	

return


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcOpportunityBalanceReserve	
return ::toJsonObject():toJson()

