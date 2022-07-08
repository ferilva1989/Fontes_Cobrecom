#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcApproverProfile

Perfil dos Aprovadores
    
@author victorhugo
@since 22/07/2016
/*/
class CbcApproverProfile from LongClassName
	
	data nMinValue
	data nMaxValue
	data nMinRg
	data nMaxRg
	data nMinDiscount
	data nMaxDiscount
	data nMinCommission
	data nMaxCommission
	data lCanStealApproval
	data lCanApproveBonus
	
	method newCbcApproverProfile() constructor
	
	method getMinValue()
	method setMinValue()
	method getMaxValue()
	method setMaxValue()
	method getMinRg()
	method setMinRg()
	method getMaxRg()
	method setMaxRg()
	method getMinDiscount()
	method setMinDiscount()
	method getMaxDiscount()
	method setMaxDiscount()
	method getMaxCommission()
	method setMaxCommission()
	method getMinCommission()
	method setMinCommission()
	method canStealApproval()
	method setCanStealApproval()
	method canApproveBonus()
	method setCanApproveBonus()
	
	method toWsObject()
	method toJsonObject()
	method toJsonString()
	
endClass


/*/{Protheus.doc} newCbcApproverProfile

Construtor
    
@author victorhugo
@since 22/07/2016
/*/
method newCbcApproverProfile() class CbcApproverProfile
return self


/**
 * Getters/Setters
 */
method getMinValue() class CbcApproverProfile
return ::nMinValue

method setMinValue(nMinValue) class CbcApproverProfile
	::nMinValue := nMinValue
return

method getMaxValue() class CbcApproverProfile
return ::nMaxValue

method setMaxValue(nMaxValue) class CbcApproverProfile
	::nMaxValue := nMaxValue
return

method getMinRg() class CbcApproverProfile
return ::nMinRg

method setMinRg(nMinRg) class CbcApproverProfile
	::nMinRg := nMinRg
return

method getMaxRg() class CbcApproverProfile
return ::nMaxRg

method setMaxRg(nMaxRg) class CbcApproverProfile
	::nMaxRg := nMaxRg
return

method getMinDiscount() class CbcApproverProfile
return ::nMinDiscount

method setMinDiscount(nMinDiscount) class CbcApproverProfile
	::nMinDiscount := nMinDiscount
return

method getMaxDiscount() class CbcApproverProfile
return ::nMaxDiscount

method setMaxDiscount(nMaxDiscount) class CbcApproverProfile
	::nMaxDiscount := nMaxDiscount
return

method getMinCommission() class CbcApproverProfile
return ::nMinCommission

method setMinCommission(nMinCommission) class CbcApproverProfile
	::nMinCommission := nMinCommission
return

method getMaxCommission() class CbcApproverProfile
return ::nMaxCommission

method setMaxCommission(nMaxCommission) class CbcApproverProfile
	::nMaxCommission := nMaxCommission
return

method canStealApproval() class CbcApproverProfile
return ::lCanStealApproval

method setCanStealApproval(lCanStealApproval) class CbcApproverProfile
	::lCanStealApproval := lCanStealApproval
return

method canApproveBonus() class CbcApproverProfile
return ::lCanApproveBonus

method setCanApproveBonus(lCanApproveBonus) class CbcApproverProfile
	::lCanApproveBonus := lCanApproveBonus
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcApproverProfile
	
	local oWsObj 	:= WsClassNew("WsCbcApproverProfile")	
	
	oWsObj:minValue 	 	:= ::getMinValue()
	oWsObj:maxValue 	 	:= ::getMaxValue()
	oWsObj:minRg    	 	:= ::getMinRg()
	oWsObj:maxRg    	 	:= ::getMaxRg()
	oWsObj:minDiscount	 	:= ::getMinDiscount()
	oWsObj:maxDiscount	 	:= ::getMaxDiscount()
	oWsObj:minCommission 	:= ::getMinCommission()
	oWsObj:maxCommission    := ::getMaxCommission()
	oWsObj:canStealApproval := ::canStealApproval()
	oWsObj:canApproveBonus  := ::canApproveBonus()
	
return oWsObj


/*/{Protheus.doc} toJson

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcApproverProfile
	
	local oJson := JsonObject():new()
	
	oJson["minValue"] 	 		:= ::getMinValue()
	oJson["maxValue"] 	 		:= ::getMaxValue()
	oJson["minRg"]    	 		:= ::getMinRg()
	oJson["maxRg"]    	 		:= ::getMaxRg()
	oJson["minDiscount"]		:= ::getMinDiscount()
	oJson["maxDiscount"]		:= ::getMaxDiscount()
	oJson["minCommission"] 		:= ::getMinCommission()
	oJson["maxCommission"]  	:= ::getMaxCommission()
	oJson["canStealApproval"] 	:= ::canStealApproval()
	oJson["canApproveBonus"]    := ::canApproveBonus()

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcApproverProfile	
return ::toJsonObject():toJson()

