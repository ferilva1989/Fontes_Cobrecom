#include "protheus.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} SendMail
@type function
@author bolognesi
@since 20/03/2018
@version 1.0
@description Função proxy para suportar o envio de email legado
utilização: U_SendMail('leonardo@cobrecom.com.br','LegadoFDP','Criar codigos legiveis!!')
/*/
user Function SendMail(_cTo,_cAssunto,_cCorpo)
	local oSch 		:= nil
	local cBody		:= ''
	default _cTo      := ""
	default _cAssunto := ""
	default _cCorpo   := ""

	if ! Empty(_cTo)
		oSch 	:= cbcSchCtrl():newcbcSchCtrl()
		oSch:setIDEnvio('SendMailLeg')
		oSch:setEmailFrom( GetNewPar('MV_WFREMET', 'wf@cobrecom.com.br') )
		oSch:addEmailTo(_cTo)
		oSch:setFIXO('S')
		oSch:setAssunto(_cAssunto)
		oSch:setSimple(.T.)
		cBody    := "<HTML><BODY><FONT FACE=VERDANA SIZE=2 COLOR=BLACK>"
		cBody    += _cCorpo
		cBody    += "<br><br>"
		cBody    += "Esta é uma mensagem automática. Não responda a este e-mail."
		cBody    += "<br><br>"
		oSch:setBody(cBody)
		oSch:setBodyText('text/html')
	
		if !oSch:schedule():lThisOk
			u_autoalert(oSch:cThisMsg)
			return(.F.)
		endIf
	
		FreeObj(oSch)
	
	endif

return(.T.)