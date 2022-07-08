#include 'protheus.ch'

/*/{Protheus.doc} errLog
@author bolognesi
@since 09/12/2016
@version 1.0
@description Classe para realizar o tratamento de status e mensagens de erro
/*/
class errLog 
	data lOk
	data cMsg
	data aMsg
	data aLogMsg
	data aLogStack
	data cDescRot

	method newerrLog() constructor 
	method setStatus()
	method getMsgLog() 
	method clearStatus()
	method itsOk()
endclass

/*/{Protheus.doc} newerrLog
@author bolognesi
@since 31/01/2017
@version 1.0
@param cDesRot, characters, Descrição da rotina 
que iniciou a classe.
@type method
@description Construtor da classe
/*/
method newerrLog(cDesRot) class errLog
	default cDesRot := ""
	::cDescRot := cDesRot 
	::clearStatus()
return

/*/{Protheus.doc} setStatus
@author bolognesi
@since 22/03/2017
@version 1.0
@param lSts, 	logical, 	Definir o status ( .T. = Aviso .F. =Erro)
@param cCodMsg, characters, Definição do codigo da mensagem, ajudar na localização no fonte do erro
@param cMsg, 	characters, Mensagem propriamente dita
@param lEmail, 	logical, 	Identifica se envia ou não email
@param lCodMsg, logical, 	Identifica se utiliza a mensagem simples com ( .T. ) ou ( .F. ) sem codigo de erro(default .T. = usar com codigo)
@param cStackErr,characters, Contem a stack do erro sua utilização somente no erro completo 
@type method
@description Metodo utilizado para definir status e mensagem de erro
desta forma a mensagem de erro vai para tela somente com o codigo do erro
enquanto a mensagem do erro vai para console.log ou email.
22/03-Adicionado suporte ao envio da mensagem simples sem codigo de erro.
/*/
method setStatus(lSts, cCodMsg, cMsg, lEmail, lCodMsg, cStackErr) class errLog
	local cPrefix		:= ""
	local cIdMSg		:= ""
	default lSts 		:= ""
	default cCodMsg 	:= ""
	default cMsg		:= "" 
	default lEmail		:= .T.
	default lCodMsg		:= .T.
	default cStackErr	:= ''
	cIdMSg := ' ID: ' + cValToChar(Randomize(01,90000)) + StrTran(DtoC(Date()),'/','') + StrTran(Time(),':','') + " "

	cPrefix := if(lSts,'[AVISO] - ', '[ERRO] - ')
	::lOk 	:= lSts

	if lCodMsg
		//Mensagem somente com o codigo do erro (simplificada)
		aadd(::aMsg, (cPrefix + cCodMsg + cIdMSg) )
	else
		//Somente mensagem (sem codigo)
		aadd(::aMsg, cMsg )
	endif

	//Mensagem com codigo e descrição
	aadd(::aLogMsg, (cPrefix + cCodMsg + cIdMSg + cMsg ) )

	//Mensagem completa com codigo descrição e Stack de Erro
	if !empty(cStackErr)
		aadd(::aLogStack, (cPrefix + cCodMsg + cIdMSg + cMsg + cStackErr ) )
	endif

	if !lSts
		ConLog( (cPrefix + cCodMsg + cIdMSg + cMsg ), self, lEmail, cIdMSg )
	endif
return(self)

/*/{Protheus.doc} getMsgLog
@author bolognesi
@since 31/01/2017
@version 1.0
@param lGetDesc, logical, define se obtem mensagem simplificada(somente codigo do erro)<-default
ou detalhada (lGetFull == .T. ), alem do codigo contem descrição do erro. 
@param lGetStack, logical, define se obtem a mensagem com stack do erro default(sem stack)
@type method
@description Obter a mensagem de erro em forma de string
/*/
method getMsgLog(lGetDesc,lGetStack) class errLog
	local nX 	:= 0
	local aMs	:= {}
	default lGetDesc 	:= .F.
	default lGetStack	:= .F.

	if lGetStack
		if Empty(::aLogStack)
			aMs := ::aLogMsg
		else
			aMs := ::aLogStack
		endif
	else
		if lGetDesc
			aMs := ::aLogMsg
		else
			aMs := ::aMsg
		endif
	endif

	::cMsg := ""
	For nX := 1 To Len(aMs)
		::cMsg 	+= aMs[nX] + Chr(13)
	Next nX
return(::cMsg)

method itsOk() class errLog
return(::lOk)

method clearStatus() class errLog
	::aMsg 		:= {}
	::aLogMsg	:= {}
	::aLogStack	:= {}
	::cMsg 		:= ""
	::lOk  		:= .T.
return(self)

/*/{Protheus.doc} ConLog
@author bolognesi
@since 29/11/2016
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Utilizado para logar as mensagens de erro no console
e tambem enviar por e-mail as mensagens.
/*/
static function ConLog(cInMsg, oSelf, lEmail, cIdMSg)
	local cNvl1 	:= Procname(2) 
	local cNvl2 	:= Procname(3)
	local cNvl3		:= Procname(4)
	local oSch 		:= nil
	local cAddr		:= GetNewPar('XX_ERRMAIL', 'leonardo@cobrecom.com.br')
	local cMsg		:= ""
	local cDescRot	:= if (empty(oSelf:cDescRot),"Default",oSelf:cDescRot + " "  )

	cMsg += cDescRot + chr(13) 
	cMsg += "errLog-->[" + cNvl3 + '<->' + cNvl2 + '<->' + cNvl1 + "<---->" + DtoC(Date())+" - "+Time()+" ] " + chr(13) + cInMsg
	if lEmail

		oSch := cbcSchCtrl():newcbcSchCtrl()
		oSch:setIDEnvio( Alltrim(cDescRot) )
		oSch:addEmailTo(cAddr)
		oSch:addEmailCc('leonardonhesi@gmail.com')
		oSch:setAssunto('[GERENTE DE ERROS/ALERTAS] - ' + Alltrim(cIdMSg) + ' - '  + cDescRot)
		oSch:setBody(cMsg)
		oSch:schedule()
		FreeObj(oSch)

	endif
	ConOut(cMsg)
return