#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcQuotationItem

Itens dos Orçamentos do Portal Cobrecom
    
@author victorhugo
@since 23/05/2016
/*/
class CbcQuotationItem from LongClassName
	
	data cItem
	data cName
	data cCodeName
	data cBitola
	data cCodeBitola
	data cPackage
	data cIdPackage
	data nAmountPackage
	data lSpecificPackageAmount
	data cSpecialty	
	data cDescription
	data nQuantity
	data cIdListPrice
	data nListPrice
	data nCashPaymentDiscount
	data nFreightDiscount
	data nMinPrice
	data nMinTotal
	data nMinRg
	data nSugPrice
	data nSugTotal
	data nSugCommission
	data nSugRg
	data nAppPrice
	data nAppTotal
	data nAppCommission
	data nAppRg
	data lAppAuto
	data lFixedCommission
	data nPriceDiff		
	data aColors
	data cBranchReserve
	data cIdReserve
	data cCustomerSalesOrder
	data cItemCustomerSalesOrder
	data cDefDiscount
	data cSugDiscount
	data cAppDiscount
	data lFlex25
	data cDescSpecialty
	
	method newCbcQuotationItem() constructor
	
	method getItem()
	method setItem()
	method getName()
	method setName()
	method getCodeName()
	method setCodeName()
	method getBitola()
	method setBitola()
	method getCodeBitola()
	method setCodeBitola()
	method getPackage()
	method setPackage()
	method getIdPackage()
	method setIdPackage() 
	method getAmountPackage()
	method setAmountPackage()
	method isSpecificPackageAmount()
	method setSpecificPackageAmount()
	method getSpecialty()
	method setSpecialty()
	method getDescription()
	method setDescription()
	method getQuantity()
	method setQuantity()
	method getIdListPrice()
	method setIdListPrice()
	method getListPrice()
	method setListPrice()
	method getCashPaymentDiscount()
	method setCashPaymentDiscount()
	method getFreightDiscount()
	method setFreightDiscount()
	method getMinPrice()
	method setMinPrice()
	method getMinTotal()
	method setMinTotal()
	method getMinRg()
	method setMinRg()
	method getSugPrice()
	method setSugPrice()
	method getSugTotal()
	method setSugTotal()
	method getSugCommission()
	method setSugCommission()
	method getSugRg()
	method setSugRg()
	method getAppPrice()
	method setAppPrice()
	method getAppTotal()
	method setAppTotal()
	method getAppCommission()
	method setAppCommission()
	method getAppRg()
	method setAppRg()
	method isAppAuto()
	method setAppAuto()
	method isFixedCommission()
	method setFixedCommission()
	method getPriceDiff()
	method setPriceDiff()	
	method getColors()
	method setColors()
	method getBranchReserve()
	method setBranchReserve()
	method getIdReserve()
	method setIdReserve()
	method getCustomerSalesOrder()
	method setCustomerSalesOrder()
	method getItemCustomerSalesOrder()
	method setItemCustomerSalesOrder()
	method getDefDiscount()
	method setDefDiscount()
	method getSugDiscount()
	method setSugDiscount()
	method getAppDiscount()
	method setAppDiscount()
	method isFlex25()
	method setFlex25()
	method getDescSpecialty()
	method setDescSpecialty() 
	
	method toWsObject()
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()	
	method fromJsonLegacy()
	
endClass


/*/{Protheus.doc} newCbcQuotationItem

Construtor
    
@author victorhugo
@since 23/05/2016
/*/
method newCbcQuotationItem() class CbcQuotationItem
return self


/**
 * Getters/Setter
 */
method getItem() class CbcQuotationItem
return ::cItem

method setItem(cItem) class CbcQuotationItem
	::cItem := cItem
return

method getName() class CbcQuotationItem
return ::cName

method setName(cName) class CbcQuotationItem
	::cName := cName
return

method getCodeName() class CbcQuotationItem
return ::cCodeName

method setCodeName(cCodeName) class CbcQuotationItem
	::cCodeName := cCodeName
return

method getBitola() class CbcQuotationItem
return ::cBitola

method setBitola(cBitola) class CbcQuotationItem
	::cBitola := cBitola
return

method getCodeBitola() class CbcQuotationItem
return ::cCodeBitola

method setCodeBitola(cCodeBitola) class CbcQuotationItem
	::cCodeBitola := cCodeBitola
return

method getPackage() class CbcQuotationItem
return ::cPackage

method setPackage(cPackage) class CbcQuotationItem
	::cPackage := cPackage
return

method getIdPackage() class CbcQuotationItem
return ::cIdPackage

method setIdPackage(cIdPackage) class CbcQuotationItem
	
	local oSrvProduct := CbcProductService():newCbcProductService()
	
	::cIdPackage := cIdPackage
	::cPackage   := oSrvProduct:getPackageDescription(cIdPackage)
	
return

method getAmountPackage() class CbcQuotationItem
return ::nAmountPackage

method setAmountPackage(nAmountPackage) class CbcQuotationItem
	::nAmountPackage := nAmountPackage
return

method isSpecificPackageAmount() class CbcQuotationItem
return ::lSpecificPackageAmount

method setSpecificPackageAmount(lSpecificPackageAmount) class CbcQuotationItem
	::lSpecificPackageAmount := lSpecificPackageAmount
return

method getSpecialty() class CbcQuotationItem
return ::cSpecialty

method setSpecialty(cSpecialty) class CbcQuotationItem
	::cSpecialty := cSpecialty
return

method getDescription() class CbcQuotationItem
return ::cDescription

method setDescription(cDescription) class CbcQuotationItem
	::cDescription := cDescription
return

method getQuantity() class CbcQuotationItem
return ::nQuantity

method setQuantity(nQuantity) class CbcQuotationItem
	::nQuantity := nQuantity
return

method getIdListPrice() class CbcQuotationItem
return ::cIdListPrice

method setIdListPrice(cIdListPrice) class CbcQuotationItem
	::cIdListPrice := cIdListPrice
return

method getListPrice() class CbcQuotationItem
return ::nListPrice

method setListPrice(nListPrice) class CbcQuotationItem
	::nListPrice := nListPrice
return

method getCashPaymentDiscount() class CbcQuotationItem
return ::nCashPaymentDiscount

method setCashPaymentDiscount(nCashPaymentDiscount) class CbcQuotationItem
	::nCashPaymentDiscount := nCashPaymentDiscount
return

method getFreightDiscount() class CbcQuotationItem
return ::nFreightDiscount

method setFreightDiscount(nFreightDiscount) class CbcQuotationItem
	::nFreightDiscount := nFreightDiscount
return

method getMinPrice() class CbcQuotationItem
return ::nMinPrice

method setMinPrice(nMinPrice) class CbcQuotationItem
	::nMinPrice := nMinPrice
return

method getMinTotal() class CbcQuotationItem
return ::nMinTotal

method setMinTotal(nMinTotal) class CbcQuotationItem
	::nMinTotal := nMinTotal
return

method getMinRg() class CbcQuotationItem
return ::nMinRg

method setMinRg(nMinRg) class CbcQuotationItem
	::nMinRg := nMinRg
return

method getSugPrice() class CbcQuotationItem
return ::nSugPrice

method setSugPrice(nSugPrice) class CbcQuotationItem
	::nSugPrice := nSugPrice
return

method getSugTotal() class CbcQuotationItem
return ::nSugTotal

method setSugTotal(nSugTotal) class CbcQuotationItem
	::nSugTotal := nSugTotal
return

method getSugCommission() class CbcQuotationItem
return ::nSugCommission

method setSugCommission(nSugCommission) class CbcQuotationItem
	::nSugCommission := nSugCommission
return

method getSugRg() class CbcQuotationItem
return ::nSugRg

method setSugRg(nSugRg) class CbcQuotationItem
	::nSugRg := nSugRg
return	

method getAppPrice() class CbcQuotationItem
return ::nAppPrice

method setAppPrice(nAppPrice) class CbcQuotationItem
	::nAppPrice := nAppPrice
return

method getAppTotal() class CbcQuotationItem
return ::nAppTotal

method setAppTotal(nAppTotal) class CbcQuotationItem
	::nAppTotal := nAppTotal
return

method getAppCommission() class CbcQuotationItem
return ::nAppCommission

method setAppCommission(nAppCommission) class CbcQuotationItem
	::nAppCommission := nAppCommission
return

method getAppRg() class CbcQuotationItem
return ::nAppRg

method setAppRg(nAppRg) class CbcQuotationItem
	::nAppRg := nAppRg
return

method isAppAuto() class CbcQuotationItem
return ::lAppAuto

method setAppAuto(lAppAuto) class CbcQuotationItem
	::lAppAuto := lAppAuto
return

method isFixedCommission() class CbcQuotationItem
return ::lFixedCommission

method setFixedCommission(lFixedCommission) class CbcQuotationItem
	::lFixedCommission := lFixedCommission
return

method getPriceDiff() class CbcQuotationItem
return ::nPriceDiff

method setPriceDiff(nPriceDiff) class CbcQuotationItem
	::nPriceDiff := nPriceDiff
return

method getColors() class CbcQuotationItem
return ::aColors

method setColors(aColors) class CbcQuotationItem
	::aColors := aColors
return

method getBranchReserve() class CbcQuotationItem
return ::cBranchReserve

method setBranchReserve(cBranchReserve) class CbcQuotationItem
	::cBranchReserve := cBranchReserve
return

method getIdReserve() class CbcQuotationItem
return ::cIdReserve

method setIdReserve(cIdReserve) class CbcQuotationItem
	::cIdReserve := cIdReserve
return

method getCustomerSalesOrder() class CbcQuotationItem
return ::cCustomerSalesOrder

method setCustomerSalesOrder(cCustomerSalesOrder) class CbcQuotationItem
	::cCustomerSalesOrder := cCustomerSalesOrder
return

method getItemCustomerSalesOrder() class CbcQuotationItem
return ::cItemCustomerSalesOrder

method setItemCustomerSalesOrder(cItemCustomerSalesOrder) class CbcQuotationItem
	::cItemCustomerSalesOrder := cItemCustomerSalesOrder
return

method getDefDiscount() class CbcQuotationItem
return ::cDefDiscount

method setDefDiscount(cDefDiscount) class CbcQuotationItem
	::cDefDiscount := cDefDiscount
return

method getSugDiscount() class CbcQuotationItem
return ::cSugDiscount

method setSugDiscount(cSugDiscount) class CbcQuotationItem
	::cSugDiscount := cSugDiscount
return

method getAppDiscount() class CbcQuotationItem
return ::cAppDiscount

method setAppDiscount(cAppDiscount) class CbcQuotationItem
	::cAppDiscount := cAppDiscount
return

method isFlex25() class CbcQuotationItem
return ::lFlex25

method setFlex25(lFlex25) class CbcQuotationItem
	::lFlex25 := lFlex25
return

method getDescSpecialty() class CbcQuotationItem
return ::cDescSpecialty

method setDescSpecialty(cDescSpecialty) class CbcQuotationItem
	::cDescSpecialty := cDescSpecialty
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 23/05/2016

@return WsCbcQuotation Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcQuotationItem
	
	local oWsObj   := WsClassNew("WsCbcQuotationItem")
	local aColors  := ::getColors()
	
	oWsObj:item 					:= ::getItem()
	oWsObj:name 					:= ::getName()
	oWsObj:codeName 				:= ::getCodeName()
	oWsObj:bitola 					:= ::getBitola()
	oWsObj:codeBitola 				:= ::getCodeBitola()
	oWsObj:package 					:= ::getPackage()
	oWsObj:idPackage 				:= ::getIdPackage()
	oWsObj:amountPackage 			:= ::getAmountPackage()
	oWsObj:isSpecificPackageAmount	:= ::isSpecificPackageAmount()
	oWsObj:specialty				:= ::getSpecialty()
	oWsObj:description 				:= ::getDescription()
	oWsObj:quantity 				:= ::getQuantity()
	oWsObj:idListPrice 				:= ::getIdListPrice()
	oWsObj:listPrice 				:= ::getListPrice()
	oWsObj:cashPaymentDiscount 		:= ::getCashPaymentDiscount()
	oWsObj:freightDiscount 			:= ::getFreightDiscount()
	oWsObj:minPrice 				:= ::getMinPrice()
	oWsObj:minTotal 				:= ::getMinTotal()
	oWsObj:minRg 					:= ::getMinRg()
	oWsObj:sugPrice 				:= ::getSugPrice()
	oWsObj:sugTotal 				:= ::getSugTotal()
	oWsObj:sugCommission 			:= ::getSugCommission()
	oWsObj:sugRg 					:= ::getSugRg()
	oWsObj:appPrice 				:= ::getAppPrice()
	oWsObj:appTotal 				:= ::getAppTotal()
	oWsObj:appCommission 			:= ::getAppCommission()
	oWsObj:appRg 					:= ::getAppRg()
	oWsObj:isAppAuto 				:= ::isAppAuto()
	oWsObj:isFixedCommission 		:= ::isFixedCommission()
	oWsObj:priceDiff 				:= ::getPriceDiff()	
	oWsObj:branchReserve			:= ::getBranchReserve()
	oWsObj:idReserve				:= ::getIdReserve()
	oWsObj:customerSalesOrder		:= ::getCustomerSalesOrder()
	oWsObj:itemCustomerSalesOrder	:= ::getItemCustomerSalesOrder()
	oWsObj:defDiscount				:= ::getDefDiscount()
	oWsObj:sugDiscount				:= ::getSugDiscount()
	oWsObj:appDiscount				:= ::getAppDiscount()
	oWsObj:isFlex25 				:= ::isFlex25()
	oWsObj:descSpecialty			:= ::getDescSpecialty()
	oWsObj:colors					:= {}	
	
	if (ValType(aColors) == "A")
		for nI := 1 to Len(aColors)
			aAdd(oWsObj:colors, aColors[nI]:toWsObject())
		next nI	
	endIf
	
return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 23/05/2016

@param oWsObj, WsCbcQuotation, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcQuotationItem
	
	local nI         := 0
	local oColor     := nil
	local aColors    := {}
	local aWsColors  := oWsObj:colors
	
	::setItem(oWsObj:item)
	::setName(oWsObj:name)
	::setCodeName(oWsObj:codeName)
	::setBitola(oWsObj:bitola)
	::setCodeBitola(oWsObj:codeBitola)
	::setPackage(oWsObj:Package)
	::setIdPackage(oWsObj:idPackage)
	::setAmountPackage(oWsObj:amountPackage)
	::setSpecificPackageAmount(oWsObj:isSpecificPackageAmount)
	::setSpecialty(oWsObj:specialty)
	::setDescription(oWsObj:description)
	::setQuantity(oWsObj:quantity)
	::setIdListPrice(oWsObj:idListPrice)
	::setListPrice(oWsObj:listPrice)
	::setCashPaymentDiscount(oWsObj:cashPaymentDiscount)
	::setFreightDiscount(oWsObj:freightDiscount)
	::setMinPrice(oWsObj:minPrice)
	::setMinTotal(oWsObj:minTotal)
	::setMinRg(oWsObj:minRg)
	::setSugPrice(oWsObj:sugPrice)
	::setSugTotal(oWsObj:sugTotal)
	::setSugCommission(oWsObj:sugCommission)
	::setSugRg(oWsObj:sugRg)
	::setAppPrice(oWsObj:appPrice)
	::setAppTotal(oWsObj:appTotal)
	::setAppCommission(oWsObj:appCommission)
	::setAppRg(oWsObj:appRg)
	::setAppAuto(oWsObj:isAppAuto)
	::setFixedCommission(oWsObj:isFixedCommission)
	::setPriceDiff(oWsObj:priceDiff)	
	::setBranchReserve(oWsObj:branchReserve)
	::setIdReserve(oWsObj:idReserve)
	::setCustomerSalesOrder(oWsObj:customerSalesOrder)
	::setItemCustomerSalesOrder(oWsObj:itemCustomerSalesOrder)
	::setDefDiscount(oWsObj:defDiscount)
	::setSugDiscount(oWsObj:sugDiscount)
	::setAppDiscount(oWsObj:appDiscount)
	::setFlex25(oWsObj:isFlex25)
	::setDescSpecialty(oWsObj:descSpecialty)
	
	if (ValType(aWsColors) == "A")
		for nI := 1 to Len(aWsColors)
			oColor := CbcQuotationItemColor():newCbcQuotationItemColor()
			oColor:fromWsObject(aWsColors[nI])
			aAdd(aColors, oColor)
		next nI
	endIf
	
	::setColors(aColors)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcQuotationItem
	
	local oJson   := JsonObject():new()
	local aColors := ::getColors()
	
	oJson["item"] 					 := ::getItem()
	oJson["name"] 					 := AllTrim(::getName())
	oJson["codeName"] 				 := ::getCodeName()
	oJson["bitola"] 				 := ::getBitola()
	oJson["codeBitola"] 			 := ::getCodeBitola()
	oJson["package"] 				 := ::getPackage()
	oJson["idPackage"] 				 := ::getIdPackage()
	oJson["amountPackage"] 			 := ::getAmountPackage()
	oJson["isSpecificPackageAmount"] := ::isSpecificPackageAmount()
	oJson["specialty"]				 := ::getSpecialty()
	oJson["description"] 			 := AllTrim(::getDescription())
	oJson["quantity"] 				 := ::getQuantity()
	oJson["idListPrice"] 			 := ::getIdListPrice()
	oJson["listPrice"] 				 := ::getListPrice()
	oJson["cashPaymentDiscount"] 	 := ::getCashPaymentDiscount()
	oJson["freightDiscount"] 		 := ::getFreightDiscount()
	oJson["minPrice"] 				 := ::getMinPrice()
	oJson["minTotal"] 				 := ::getMinTotal()
	oJson["minRg"] 					 := ::getMinRg()
	oJson["sugPrice"] 				 := ::getSugPrice()
	oJson["sugTotal"] 				 := ::getSugTotal()
	oJson["sugCommission"] 			 := ::getSugCommission()
	oJson["sugRg"] 					 := ::getSugRg()
	oJson["appPrice"] 				 := ::getAppPrice()
	oJson["appTotal"] 				 := ::getAppTotal()
	oJson["appCommission"] 			 := ::getAppCommission()
	oJson["appRg"] 					 := ::getAppRg()
	oJson["isAppAuto"] 				 := ::isAppAuto()
	oJson["isFixedCommission"] 		 := ::isFixedCommission()
	oJson["priceDiff"] 				 := ::getPriceDiff()	
	oJson["branchReserve"]			 := AllTrim(::getBranchReserve())
	oJson["idReserve"]				 := AllTrim(::getIdReserve())
	oJson["customerSalesOrder"]		 := ::getCustomerSalesOrder()
	oJson["itemCustomerSalesOrder"]	 := ::getItemCustomerSalesOrder()
	oJson["defDiscount"]			 := AllTrim(::getDefDiscount())
	oJson["sugDiscount"]			 := AllTrim(::getSugDiscount())
	oJson["appDiscount"]			 := AllTrim(::getAppDiscount())
	oJson["isFlex25"] 				 := ::isFlex25()
	oJson["descSpecialty"]			 := ::getDescSpecialty()
	oJson["colors"]					 := {}
	
	if (ValType(aColors) == "A")
		for nI := 1 to Len(aColors)
			aAdd(oJson["colors"], aColors[nI]:toJsonObject())
		next nI	
	endIf	

return oJson


/*/{Protheus.doc} fromJsonObject

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonObject(xJson) class CbcQuotationItem
	
	local nI         := 0
	local oColor     := nil
	local aColors    := {}
	local aJsColors  := {}
	private oJson	 := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf	
	
	::setItem(oJson["item"])
	::setName(oJson["name"])
	::setCodeName(oJson["codeName"])
	::setBitola(oJson["bitola"])
	::setCodeBitola(oJson["codeBitola"])
	::setPackage(oJson["package"])
	::setIdPackage(oJson["idPackage"])
	::setAmountPackage(oJson["amountPackage"])
	::setSpecificPackageAmount(oJson["isSpecificPackageAmount"])
	::setSpecialty(oJson["specialty"])
	::setDescription(oJson["description"])
	::setQuantity(oJson["quantity"])
	::setIdListPrice(oJson["idListPrice"])
	::setListPrice(oJson["listPrice"])
	::setCashPaymentDiscount(oJson["cashPaymentDiscount"])
	::setFreightDiscount(oJson["freightDiscount"])
	::setMinPrice(oJson["minPrice"])
	::setMinTotal(oJson["minTotal"])
	::setMinRg(oJson["minRg"])
	::setSugPrice(oJson["sugPrice"])
	::setSugTotal(oJson["sugTotal"])
	::setSugCommission(oJson["sugCommission"])
	::setSugRg(oJson["sugRg"])
	::setAppPrice(oJson["appPrice"])
	::setAppTotal(oJson["appTotal"])
	::setAppCommission(oJson["appCommission"])
	::setAppRg(oJson["appRg"])
	::setAppAuto(oJson["isAppAuto"])
	::setPriceDiff(oJson["priceDiff"])
	::setBranchReserve(oJson["branchReserve"])
	::setIdReserve(oJson["idReserve"])
	::setCustomerSalesOrder(oJson["customerSalesOrder"])
	::setItemCustomerSalesOrder(oJson["itemCustomerSalesOrder"])
	::setDefDiscount(oJson["defDiscount"])
	::setSugDiscount(oJson["sugDiscount"])
	::setAppDiscount(oJson["appDiscount"])
	::setFixedCommission(oJson["isFixedCommission"])
	::setFlex25(oJson["isFlex25"])
	::setDescSpecialty(oJson["descSpecialty"])
	
	aJsColors := oJson["colors"]
	
	if (ValType(aJsColors) == "A")
		for nI := 1 to Len(aJsColors)
			oColor := CbcQuotationItemColor():newCbcQuotationItemColor()
			oColor:fromJsonObject(aJsColors[nI])
			aAdd(aColors, oColor)
		next nI
	endIf
	
	::setColors(aColors)
	
return


/*/{Protheus.doc} fromJsonLegacy

Popula as propriedades do objeto conforme a respectiva instancia da classe JSON (Legado)
	
@author victorhugo
@since 23/05/2016

@param xJson, String/Object, JSON do Objeto
/*/
method fromJsonLegacy(xJson) class CbcQuotationItem
	
	local nI         := 0
	local oColor     := nil
	local aColors    := {}
	local aJsColors  := {}
	private oJson	:= nil
	
	if (ValType(xJson) == "C")
		FwJsonDeserialize(xJson, @oJson)
	else
		oJson := xJson
	endIf
	
	::setItem(oJson:cItem)
	::setName(oJson:cName)
	::setCodeName(oJson:cCodeName)
	::setBitola(oJson:cBitola)
	::setCodeBitola(oJson:cCodeBitola)
	::setPackage(oJson:cPackage)
	::setIdPackage(oJson:cIdPackage)
	::setAmountPackage(oJson:nAmountPackage)
	::setSpecificPackageAmount(oJson:lSpecificPackageAmount)
	::setSpecialty(oJson:cSpecialty)
	::setDescription(oJson:cDescription)
	::setQuantity(oJson:nQuantity)
	::setIdListPrice(oJson:cIdListPrice)
	::setListPrice(oJson:nListPrice)
	::setCashPaymentDiscount(oJson:nCashPaymentDiscount)
	::setFreightDiscount(oJson:nFreightDiscount)
	::setMinPrice(oJson:nMinPrice)
	::setMinTotal(oJson:nMinTotal)
	::setMinRg(oJson:nMinRg)
	::setSugPrice(oJson:nSugPrice)
	::setSugTotal(oJson:nSugTotal)
	::setSugCommission(oJson:nSugCommission)
	::setSugRg(oJson:nSugRg)
	::setAppPrice(oJson:nAppPrice)
	::setAppTotal(oJson:nAppTotal)
	::setAppCommission(oJson:nAppCommission)
	::setAppRg(oJson:nAppRg)
	::setAppAuto(oJson:lAppAuto)
	::setPriceDiff(oJson:nPriceDiff)	
	::setBranchReserve(oJson:cBranchReserve)
	::setIdReserve(oJson:cIdReserve)
	::setCustomerSalesOrder(oJson:cCustomerSalesOrder)
	::setItemCustomerSalesOrder(oJson:cItemCustomerSalesOrder)
	::setDefDiscount(oJson:cDefDiscount)
	::setSugDiscount(oJson:cSugDiscount)
	::setAppDiscount(oJson:cAppDiscount)
	
	if (Type("oJson:lFixedCommission") != "U")
		::setFixedCommission(oJson:lFixedCommission)
	else	
		::setFixedCommission(.F.)
	endIf
	
	if (Type("oJson:lFlex25") != "U")
		::setFlex25(oJson:lFlex25)
	endIf
	
	if (Type("oJson:cDescSpecialty") != "U")
		::setDescSpecialty(oJson:cDescSpecialty)
	else
		::setDescSpecialty("")
	endIf
	
	aJsColors := oJson:aColors
	
	if (ValType(aJsColors) == "A")
		for nI := 1 to Len(aJsColors)
			oColor := CbcQuotationItemColor():newCbcQuotationItemColor()
			oColor:fromJsonLegacy(aJsColors[nI])
			aAdd(aColors, oColor)
		next nI
	endIf
	
	::setColors(aColors)
	
return



/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcQuotationItem	
return ::toJsonObject():toJson()

