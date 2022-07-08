#include 'protheus.ch'

/*/{Protheus.doc} cbcRGValues
(long_description)
@author bolognesi
@since 09/12/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class cbcRGValues FROM errLog

	data nFromAppTotal
	data nFromSugTotal
	data nFromMinTotal

	method newcbcRGValues() constructor 

	method setStatus()
	method getMsgLog()
	method getFromAppTotal()
	method setFromAppTotal()
	method getFromSugTotal()
	method setFromSugTotal()
	method getFromMinTotal()
	method setFromMinTotal()

endclass

/*/{Protheus.doc} new
Metodo construtor
@author bolognesi
@since 09/12/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method newcbcRGValues() class cbcRGValues
	/*HERANÇA - errLog() 
		::getMsgLog() = Obter MsgErro  
		::setStatus(lSts, cCodMsg, cMsg) = Definir Status ( .T./ .F. ), CodErro e MsgErro 
		::itsOk() Verifica se esta tudo Ok
		::clearStatus() = Limpar status de erro
	*/
	::newerrLog('RgValues')
	::nFromAppTotal := 0
	::nFromSugTotal := 0
	::nFromMinTotal := 0

return

method getFromAppTotal() class cbcRGValues
return(::nFromAppTotal)
method setFromAppTotal(nValue) class cbcRGValues
	Default nValue := ""
	If ! ValType(nValue) == 'N'
		::setStatus( .F.,'CBC400' ,'setFromAppTotal(nValue) - parametro numerico é obrigatorio')
	Else
		::nFromAppTotal := nValue
	EndIf
return(self)

method getFromSugTotal() class cbcRGValues
return(::nFromSugTotal)
method setFromSugTotal(nValue) class cbcRGValues
	Default nValue := ""
	If ! ValType(nValue) == 'N'
		::setStatus( .F. ,'CBC4001','setFromSugTotal(nValue) - parametro numerico é obrigatorio')
	Else
		::nFromSugTotal := nValue
	EndIf
return(self)

method getFromMinTotal() class cbcRGValues
return(::nFromMinTotal)
method setFromMinTotal(nValue) class cbcRGValues
	Default nValue := ""
	If ! ValType(nValue) == 'N'
		::setStatus( .F.,'CBC402' ,'setFromMinTotal(nValue) - parametro numerico é obrigatorio')
	Else
		::nFromMinTotal := nValue
	EndIf
return(self)

