#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcCustomer

Objeto que representa um Cliente da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcCustomer from LongClassName
	
	data cCode
	data cUnit
	data cName
	data cShortName
	data cIe
	data cCnpj
	data cAddress
	data cCity
	data cState
	data cCityCode
	data cZipCode
	data cBillAddress
	data cBillCity
	data cBillState
	data cBillZipCode
	data cEmail
	data cDDD
	data cPhone
	data lProspect
	data lBlocked
	data cBillBranch
	data cPaymentCondition
	data cDescPayment
	data cIssueReport
	data oSeller
	data cCnae
	data cSegment
	data cPerson
	data cType
	data cTaxPayer
	data cNationalSimple
	data cSuframa
	data cSpecialTax
	data lRetail
	data dLastPurchase
	data cDistrict
	data cBillDistrict
	data cContact
	data cMailContact
	data cMailFinance
	data nRecno
	
	method newCbcCustomer() constructor
	
	method getCode()
	method setCode()
	method getUnit()
	method setUnit()
	method getName()
	method setName()
	method getShortName()
	method setShortName()
	method getIe()
	method setIe()
	method getCnpj()
	method setCnpj()
	method getAddress()
	method setAddress()
	method getCity()
	method setCity()
	method getState()
	method setState()
	method getCityCode()
	method setCityCode()
	method getZipCode()
	method setZipCode()
	method getBillAddress()
	method setBillAddress()
	method getBillCity()
	method setBillCity()
	method getBillState()
	method setBillState()
	method getBillZipCode()
	method setBillZipCode()
	method getEmail()
	method setEmail()
	method getDDD()
	method setDDD()
	method getPhone()
	method setPhone()
	method isProspect()
	method setProspect()
	method isBlocked()
	method setBlocked()
	method getBillBranch()
	method getPaymentCondition()
	method setPaymentCondition()
	method getDescPayment()
	method setDescPayment()
	method getSeller()
	method setSeller() 
	method getIssueReport()
	method setIssueReport()
	method getCnae()
	method setCnae()
	method getSegment()
	method setSegment()
	method getPerson()
	method setPerson()
	method getType()
	method setType()
	method getTaxPayer()
	method setTaxPayer()
	method getNationalSimple()
	method setNationalSimple()
	method getSuframa()
	method setSuframa()
	method getSpecialTax()
	method setSpecialTax()
	method isRetail()
	method setRetail()
	method getLastPurchase()
	method setLastPurchase()
	method getDistrict()
	method setDistrict()
	method getBillDistrict()
	method setBillDistrict()
	method getContact()
	method setContact()
	method getMailContact()
	method setMailContact()
	method getMailFinance()
	method setMailFinance()	
	method getRecno()
	method setRecno()	
	
	method toWsObject()
	method fromWsObject() 
	method toJsonObject()
	method fromJsonObject()
	method toJsonString()
	
endClass


/*/{Protheus.doc} newCbcCustomer

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcCustomer() class CbcCustomer
return self

/**
 * Getters/Setters
 */
method getCode() class CbcCustomer
return ::cCode

method setCode(cCode) class CbcCustomer
	::cCode := cCode
	setBillBranch(@self)
return

method getUnit() class CbcCustomer
return ::cUnit

method setUnit(cUnit) class CbcCustomer
	::cUnit := cUnit
	setBillBranch(@self)
return

method getName() class CbcCustomer
return ::cName

method setName(cName) class CbcCustomer
	::cName := cName
	if !Empty(cName)
		::cName := StrTran(cName, "'", "")
	endIf
return

method getShortName() class CbcCustomer
return ::cShortName

method setShortName(cShortName) class CbcCustomer
	::cShortName := cShortName 
	if !Empty(cShortName)
		::cShortName := StrTran(cShortName, "'", "")
	endIf
return

method getCnpj() class CbcCustomer
return ::cCnpj

method setCnpj(cCnpj) class CbcCustomer
	::cCnpj := cCnpj
return

method getIe() class CbcCustomer
return ::cIe

method setIe(cIe) class CbcCustomer
	::cIe := cIe
return

method getAddress() class CbcCustomer
return ::cAddress

method setAddress(cAddress) class CbcCustomer
	::cAddress := cAddress
	if !Empty(cAddress)
		::cAddress := StrTran(cAddress, "'", "")
	endIf
return

method getCity() class CbcCustomer
return ::cCity

method setCity(cCity) class CbcCustomer
	::cCity := cCity
	if !Empty(cCity)
		::cCity := StrTran(cCity, "'", "")
	endIf
return

method getState() class CbcCustomer
return ::cState

method setState(cState) class CbcCustomer
	::cState := cState
return

method getCityCode() class CbcCustomer
return ::cCityCode

method setCityCode(cCityCode) class CbcCustomer
	
	local oSql  := LibSqlObj():newLibSqlObj()
	
	::cCityCode := cCityCode
	
	if Empty(::cCityCode) .or. Empty(::cState) .or. !Empty(::cCity)
		return
	endIf
	
	::cCity := oSql:getFieldValue("CC2", "CC2_MUN", "%CC2.XFILIAL% AND CC2_EST = '"+::cState+"' AND CC2_CODMUN = '"+::cCityCode+"'")
	
return

method getZipCode() class CbcCustomer
return ::cZipCode

method setZipCode(cZipCode) class CbcCustomer
	::cZipCode := cZipCode
return

method getBillAddress() class CbcCustomer
return ::cBillAddress

method setBillAddress(cBillAddress) class CbcCustomer
	::cBillAddress := cBillAddress
	if !Empty(cBillAddress)
		::cBillAddress := StrTran(cBillAddress, "'", "")
	endIf
return

method getBillCity() class CbcCustomer
return ::cBillCity

method setBillCity(cBillCity) class CbcCustomer
	::cBillCity := cBillCity
	if !Empty(cBillCity)
		::cBillCity := StrTran(cBillCity, "'", "")
	endIf
return

method getBillState() class CbcCustomer
return ::cBillState

method setBillState(cBillState) class CbcCustomer
	::cBillState := cBillState
return

method getBillZipCode() class CbcCustomer
return ::cBillZipCode

method setBillZipCode(cBillZipCode) class CbcCustomer
	::cBillZipCode := cBillZipCode
return

method getEmail() class CbcCustomer
return ::cEmail

method setEmail(cEmail) class CbcCustomer
	::cEmail := cEmail
return

method getDDD() class CbcCustomer
return ::cDDD

method setDDD(cDDD) class CbcCustomer
	::cDDD := cDDD
return

method getPhone() class CbcCustomer
return ::cPhone

method setPhone(cPhone) class CbcCustomer
	::cPhone := cPhone
return

method isProspect() class CbcCustomer
return ::lProspect

method setProspect(lProspect) class CbcCustomer
	::lProspect := lProspect
	setBillBranch(@self)
return

method isBlocked() class CbcCustomer
return ::lBlocked

method setBlocked(lBlocked) class CbcCustomer
	::lBlocked := lBlocked
return

method getBillBranch() class CbcCustomer
return ::cBillBranch

method getCnae() class CbcCustomer
return ::cCnae

method setCnae(cCnae) class CbcCustomer
	::cCnae := cCnae
return

method getSegment() class CbcCustomer
return ::cSegment

method setSegment(cSegment) class CbcCustomer
	::cSegment := cSegment
return

method getPerson() class CbcCustomer
return ::cPerson

method setPerson(cPerson) class CbcCustomer
	::cPerson := cPerson
return

method getType() class CbcCustomer
return ::cType

method setType(cType) class CbcCustomer
	::cType := cType
return

method getTaxPayer() class CbcCustomer
return ::cTaxPayer

method setTaxPayer(cTaxPayer) class CbcCustomer
	::cTaxPayer := cTaxPayer
return

method getNationalSimple() class CbcCustomer
return ::cNationalSimple

method setNationalSimple(cNationalSimple) class CbcCustomer
	::cNationalSimple := cNationalSimple
return

method getSuframa() class CbcCustomer
return ::cSuframa

method setSuframa(cSuframa) class CbcCustomer
	::cSuframa := cSuframa
return

method getSpecialTax() class CbcCustomer
return ::cSpecialTax

method setSpecialTax(cSpecialTax) class CbcCustomer
	::cSpecialTax := cSpecialTax
return


/**
 * Define a Filial de Faturamento do Cliente
 */
static function setBillBranch(oSelf)
	
	local oCbcInd 		:= nil
	local cSalesOrder	:= ""
	local cCode   		:= oSelf:cCode
	local cUnit	  		:= oSelf:cUnit
	local lProspect		:= oSelf:lProspect	
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	
	if (Empty(cCode) .or. Empty(cUnit) .or. oUtils:isNull(lProspect))  
		return
	endIf
	
	oCbcInd 	  	  := CbcIndRules():newCbcIndRules(cCode, cUnit, cSalesOrder, lProspect)
	oSelf:cBillBranch := oCbcInd:billingBranch()
	
return

method getPaymentCondition() class CbcCustomer
return ::cPaymentCondition

method setPaymentCondition(cPaymentCondition) class CbcCustomer
	::cPaymentCondition := cPaymentCondition
return

method getDescPayment() class CbcCustomer
return ::cDescPayment

method setDescPayment(cDescPayment) class CbcCustomer
	::cDescPayment := cDescPayment
return

method getSeller() class CbcCustomer
return ::oSeller

method setSeller(oSeller) class CbcCustomer
	::oSeller := oSeller
return

method getIssueReport() class CbcCustomer
return ::cIssueReport

method setIssueReport(cIssueReport) class CbcCustomer
	::cIssueReport := cIssueReport
return

method isRetail() class CbcCustomer
return ::lRetail

method setRetail(lRetail) class CbcCustomer
	::lRetail := lRetail
return

method getLastPurchase() class CbcCustomer
return ::dLastPurchase

method setLastPurchase(dLastPurchase) class CbcCustomer
	::dLastPurchase := dLastPurchase
return

method getDistrict() class CbcCustomer
return ::cDistrict

method setDistrict(cDistrict) class CbcCustomer
	::cDistrict := cDistrict
return

method getBillDistrict() class CbcCustomer
return ::cBillDistrict

method setBillDistrict(cBillDistrict) class CbcCustomer
	::cBillDistrict := cBillDistrict
return

method getContact() class CbcCustomer
return ::cContact

method setContact(cContact) class CbcCustomer
	::cContact := cContact
return

method getMailContact() class CbcCustomer
return ::cMailContact

method setMailContact(cMailContact) class CbcCustomer
	::cMailContact := cMailContact
return

method getMailFinance() class CbcCustomer
return ::cMailFinance

method setMailFinance(cMailFinance) class CbcCustomer
	::cMailFinance := cMailFinance
return

method getRecno() class CbcCustomer
return ::nRecno

method setRecno(nRec) class CbcCustomer
	::nRecno := nRec
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcCustomer Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcCustomer
	
	local oWsObj 	:= WsClassNew("WsCbcCustomer")
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSeller	:= ::getSeller()
	
	oWsObj:code 			:= ::getCode()
	oWsObj:unit 			:= ::getUnit()
	oWsObj:name 			:= ::getName()
	oWsObj:shortName 		:= ::getShortName()
	oWsObj:cnpj 			:= ::getCnpj()
	oWsObj:ie				:= ::getIe()
	oWsObj:address 			:= ::getAddress()
	oWsObj:city 			:= ::getCity()
	oWsObj:state 			:= ::getState()
	oWsObj:cityCode 		:= ::getCityCode()
	oWsObj:zipCode 			:= ::getZipCode()
	oWsObj:billAddress 		:= ::getBillAddress()
	oWsObj:billCity 		:= ::getBillCity()
	oWsObj:billState		:= ::getBillState()
	oWsObj:billZipCode 		:= ::getBillZipCode()
	oWsObj:email 			:= ::getEmail()
	oWsObj:ddd 				:= ::getDDD()
	oWsObj:phone  			:= ::getPhone()
	oWsObj:isProspect 		:= ::isProspect()
	oWsObj:isBlocked 		:= ::isBlocked() 
	oWsObj:billBranch		:= ::getBillBranch()
	oWsObj:paymentCondition	:= ::getPaymentCondition()
	oWsObj:descPayment		:= ::getDescPayment()
	oWsObj:issueReport 		:= ::getIssueReport() 	
	oWsObj:cnae				:= ::getCnae()
	oWsObj:segment			:= ::getSegment()	
	oWsObj:person			:= ::getPerson()
	oWsObj:type				:= ::getType()
	oWsObj:taxPayer			:= ::getTaxPayer()
	oWsObj:nationalSimple 	:= ::getNationalSimple()
	oWsObj:suframa			:= ::getSuframa()
	oWsObj:specialTax		:= ::getSpecialTax()
	oWsObj:isRetail			:= ::isRetail()
	oWsObj:lastPurchase		:= ::getLastPurchase()
	oWsObj:district			:= ::getDistrict()
	oWsObj:billDistrict		:= ::getBillDistrict()
	oWsObj:contact			:= ::getContact()
	oWsObj:mailContact		:= ::getMailContact()
	oWsObj:mailFinance		:= ::getMailFinance()	
	oWsObj:recno			:= ::getRecno()
	
	if oUtils:isNotNull(oSeller)
		oWsObj:seller := oSeller:toWsObject() 
	endIf

return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcCustomer, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcCustomer
	
	local oSeller	:= nil
	local oUtils    := LibUtilsObj():newLibUtilsObj()
	
	::setCode(oWsObj:code)
	::setUnit(oWsObj:unit)
	::setName(oWsObj:name)
	::setShortName(oWsObj:shortName)
	::setCnpj(oWsObj:cnpj)
	::setIe(oWsObj:ie)
	::setAddress(oWsObj:address)
	::setCity(oWsObj:city)
	::setState(oWsObj:state)
	::setCityCode(oWsObj:cityCode)
	::setZipCode(oWsObj:zipCode)
	::setBillAddress(oWsObj:billAddress)
	::setBillCity(oWsObj:billCity)
	::setBillState(oWsObj:billState)
	::setBillZipCode(oWsObj:billZipCode)	
	::setEmail(oWsObj:email)
	::setDDD(oWsObj:ddd)
	::setPhone(oWsObj:phone)
	::setProspect(oWsObj:isProspect)
	::setBlocked(oWsObj:isBlocked)
	::setPaymentCondition(oWsObj:paymentCondition)
	::setDescPayment(oWsObj:descPayment)
	::setIssueReport(oWsObj:issueReport)
	::setCnae(oWsObj:cnae)
	::setSegment(oWsObj:segment)	
	::setPerson(oWsObj:person)
	::setType(oWsObj:type)
	::setTaxPayer(oWsObj:taxPayer)
	::setNationalSimple(oWsObj:nationalSimple)
	::setSuframa(oWsObj:suframa)
	::setSpecialTax(oWsObj:specialTax)
	::setRetail(oWsObj:isRetail)
	::setLastPurchase(oWsObj:lastPurchase)
	::setDistrict(oWsObj:district)
	::setBillDistrict(oWsObj:billDistrict)
	::setContact(oWsObj:contact)
	::setMailContact(oWsObj:mailContact)
	::setMailFinance(oWsObj:mailFinance)
	::setRecno(oWsObj:recno)
	
	::cBillBranch := oWsObj:billBranch

	if oUtils:isNotNull(oWsObj:seller)
		 oSeller := CbcSeller():newCbcSeller()
		 oSeller:fromWsObject(oWsObj:seller) 
	endIf 
	
	::setSeller(oSeller)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcCustomer
	
	local oJson   := JsonObject():new()
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	local oSeller := ::getSeller()
	
	oJson["code"] 				:= ::getCode()
	oJson["unit"] 				:= ::getUnit()
	oJson["name"] 				:= ::getName()
	oJson["shortName"] 			:= ::getShortName()
	oJson["cnpj"] 				:= ::getCnpj()
	oJson["formatCnpj"] 		:= oUtils:formatCgc(oJson["cnpj"])
	oJson["ie"]					:= ::getIe()
	oJson["address"] 			:= ::getAddress()
	oJson["city"] 				:= ::getCity()
	oJson["state"] 				:= ::getState()
	oJson["cityCode"] 			:= ::getCityCode()
	oJson["zipCode"] 			:= ::getZipCode()
	oJson["billAddress"] 		:= ::getBillAddress()
	oJson["billCity"] 			:= ::getBillCity()
	oJson["billState"]			:= ::getBillState()
	oJson["billZipCode"] 		:= ::getBillZipCode()
	oJson["email"] 				:= ::getEmail()
	oJson["ddd"] 				:= ::getDDD()
	oJson["phone"]  			:= ::getPhone()
	oJson["isProspect"] 		:= ::isProspect()
	oJson["isBlocked"] 			:= ::isBlocked() 
	oJson["billBranch"]			:= ::getBillBranch()
	oJson["paymentCondition"]	:= ::getPaymentCondition()
	oJson["descPayment"]		:= ::getDescPayment()
	oJson["issueReport"] 		:= ::getIssueReport() 	
	oJson["cnae"]				:= ::getCnae()
	oJson["segment"]			:= ::getSegment()	
	oJson["person"]				:= ::getPerson()
	oJson["type"]				:= ::getType()
	oJson["taxPayer"]			:= ::getTaxPayer()
	oJson["nationalSimple"] 	:= ::getNationalSimple()
	oJson["suframa"]			:= ::getSuframa()
	oJson["specialTax"]			:= ::getSpecialTax()
	oJson["isRetail"]			:= ::isRetail()
	oJson["lastPurchase"]		:= ::getLastPurchase()
	oJson["district"]			:= ::getDistrict()
	oJson["billDistrict"]		:= ::getBillDistrict()
	oJson["contact"]			:= ::getContact()
	oJson["mailContact"]		:= ::getMailContact()
	oJson["mailFinance"]		:= ::getMailFinance()	
	oJson["recno"]				:= ::getRecno()
	
	if oUtils:isNotNull(oSeller)
		oJson["seller"] := oSeller:toJsonObject() 
	endIf

return oJson


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcCustomer
	
	local oSeller := nil
	local oJson   := JsonObject():new()
	local oUtils  := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setCode(oJson["code"])
	::setUnit(oJson["unit"])
	::setName(oJson["name"])
	::setShortName(oJson["shortName"])
	::setCnpj(oJson["cnpj"])
	::setIe(oJson["ie"])
	::setAddress(oJson["address"])
	::setCity(oJson["city"])
	::setState(oJson["state"])
	::setCityCode(oJson["cityCode"])
	::setZipCode(oJson["zipCode"])
	::setBillAddress(oJson["billAddress"])
	::setBillCity(oJson["billCity"])
	::setBillState(oJson["billState"])
	::setBillZipCode(oJson["billZipCode"])
	::setEmail(oJson["email"])
	::setDDD(oJson["ddd"])
	::setPhone(oJson["phone"])
	::setProspect(oJson["isProspect"])
	::setBlocked(oJson["isBlocked"]) 
	::setPaymentCondition(oJson["paymentCondition"])
	::setDescPayment(oJson["descPayment"])
	::setIssueReport(oJson["issueReport"]) 	
	::setCnae(oJson["cnae"])
	::setSegment(oJson["segment"])	
	::setPerson(oJson["person"])
	::setType(oJson["type"])
	::setTaxPayer(oJson["taxPayer"])
	::setNationalSimple(oJson["nationalSimple"])
	::setSuframa(oJson["suframa"])
	::setSpecialTax(oJson["specialTax"])
	::setRetail(oJson["isRetail"])
	::setLastPurchase(oJson["lastPurchase"])
	::setDistrict(oJson["district"])
	::setBillDistrict(oJson["billDistrict"])
	::setContact(oJson["contact"])
	::setMailContact(oJson["mailContact"])
	::setMailFinance(oJson["mailFinance"])
	::setRecno(oJson["recno"])
	
	::cBillBranch := oJson["billBranch"]

	if oUtils:isNotNull(oJson["seller"])
		 oSeller := CbcSeller():newCbcSeller()
		 oSeller:fromJsonObject(oJson["seller"]) 
	endIf 
	
	::setSeller(oSeller)

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcCustomer
return ::toJsonObject():toJson()
