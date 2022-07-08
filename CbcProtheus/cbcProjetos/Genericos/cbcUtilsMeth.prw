#include 'protheus.ch'


/*/{Protheus.doc} cbcAbstractErr
@author bolognesi
@since 07/12/2017
@version 1.0
@type class
@description Classe abstrata para centralizar o tratamento de erros
/*/
class cbcUtilsMeth
	data lOk
	data cErrMsg

	method newcbcUtilsMeth() constructor 
	method isOk()
	method setStatus()
	method getErrMsg()
	method ConsoleLog()
	method defFilial()

endclass


/*/{Protheus.doc} newcbcUtilsMeth
@author bolognesi
@since 07/12/2017
@version 1.0
@type method
@description Construtor da classe
/*/
method newcbcUtilsMeth() class cbcUtilsMeth

return ( self )


/*/{Protheus.doc} setStatus
@author bolognesi
@since 04/12/2017
@version 1.0
@param lSts, logical, Status a ser definido ( .T. / .F. )
@param cMsg, characters, Mensagem a respeito do status
@type method
@description Define um status e uma mensagem para controlar
os fluxos de execução.
/*/
method setStatus(lSts, cMsg) class cbcUtilsMeth
	default lSts := .T.
	default cMsg := ''
	::lOk		:= lSts
	::cErrMsg	:= cMsg
return (self)


/*/{Protheus.doc} isOk
@author bolognesi
@since 04/12/2017
@version 1.0
@type method
@description Obtem o status da execução em determinado
momento
/*/
method isOk()class cbcUtilsMeth
return(::lOk)


/*/{Protheus.doc} getErrMsg
@author bolognesi
@since 04/12/2017
@version 1.0
@type method
@description Obtem o texto referente ao erro ocorrido
/*/
method getErrMsg()class cbcUtilsMeth
return(::cErrMsg)


/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 08/05/17
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Utilizado para logar as mensagens de erro no console
/*/
method ConsoleLog(cDesc, cMsg) class cbcUtilsMeth
	default cDesc := 'ERRO'
	ConOut("[" + cDesc + " - "+DtoC(Date())+" - "+Time()+" ] "+ cMsg)
return ( self )


/*/{Protheus.doc} defFilial
@author bolognesi
@since 04/12/2017
@version 1.0
@param cCodFil, characters, Filial Desejada
@type method
@description Realiza a mudança de filial durante
o lançamento.
/*/
method defFilial(cCodFil) class cbcUtilsMeth
	local oFil 	:= Nil 
	default cCodFil := ::cFilLogon
	if cCodFil <> FwFilial()
		oFil := cbcFiliais():newcbcFiliais()
		oFil:setFilial(cCodFil)
		FreeObj(oFil)
	endif
return(self)