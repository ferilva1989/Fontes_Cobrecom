#include 'protheus.ch'

/*/{Protheus.doc} cbcRetPortalQueries
@author bolognesi
@since 18/10/2017
@version 1.0
@type class
@description Classe utilizda para o retorno de objeto ao portal
essa classe conta com o metodo toJson() para serializar o retorno
caso necessario.
/*/
class cbcRetPortalQueries 
	data lStatus
	data cMsgStatus
	data oReturn

	method newcbcRetPortalQueries() constructor 
	method setStatus()
	method getStatus()
	method getErrMsg()
	method setReturn()
	method getReturn()
	method toJson()
endclass

method newcbcRetPortalQueries() class cbcRetPortalQueries
	::setStatus(.T., '')
return (self)

method setStatus(lStatus, cMsg) class cbcRetPortalQueries
	::lStatus 		:= lStatus
	::cMsgStatus 	:= cMsg
return (self)

method getStatus() class cbcRetPortalQueries
return (::lStatus )

method getErrMsg() class cbcRetPortalQueries
return (::cMsgStatus)

method setReturn(oRet)class cbcRetPortalQueries
	::oReturn := oRet
return (self)

method getReturn()class cbcRetPortalQueries
return (::oReturn)

method toJson() class cbcRetPortalQueries
	local oJson := jsonTypes():newjsonTypes()
	local cJson := ''
	cJson := oJson:toJson(self) 
	freeObj(oJson)
return (cJson)