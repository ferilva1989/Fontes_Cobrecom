#INCLUDE "TOTVS.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'
#include "TOPCONN.ch"
#include "tbiconn.ch" 

/*/{Protheus.doc} OpenFire
(long_description)
@author bolognesi
@since 04/07/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class OpenFire 
data data
data hora
data tempo
data msgUsr
data msgBody
data url
data aHeader
data lRetMsg
method newOpenFire() constructor 
method setRetMsg()
method isRetMsg()
method getData() 
method setData()
method getHora()
method setHora()
method getTempo()
method setTempo()
method getMsgUsr()
method setMsgUsr()
method getMsgBody()
method setMsgBody()
method getUrl()
method setUrl()
method getHeader()
method setHeader()
method sendSpark()
method sendEmail()
method montaTela()
endclass

/*/{Protheus.doc} newOpenFire
Metodo construtor
@author bolognesi
@since 04/07/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method newOpenFire(cData, cHora, cTempo, cMsg, lRetMsg) class OpenFire
Default cData 	:= DtoC(Date())
Default cHora	:= Time()
Default cTempo 	:= '10 MINUTOS'
Default cMsg	:= 'Compilar Rotinas'
Default lRetMsg	:= .F.

	::setData(cData)
	::setHora(cHora)
	::setTempo(cTempo)
	::setMsgUsr('')
	::setMsgBody(cMsg)
	::setRetMsg(lRetMsg)
	::setHeader({})

return

//MENSAGEM DE RETORNO
method setRetMsg(isRet) class OpenFire
	::lRetMsg := isRet
return

method isRetMsg() class OpenFire
return ::lRetMsg

//DATA PARADA
method getData() class OpenFire
return ::Data

method setData(dData) class OpenFire
	::data = dData
return

//HORA DA PARADA
method getHora() class OpenFire
return ::Hora

method setHora(cHora) class OpenFire
	::hora = cHora
return

//TEMPO PARADA
method getTempo() class OpenFire
return ::Tempo

method setTempo(cTempo) class OpenFire
	::tempo = cTempo
return

//MENSAGEM-ASSUNTO
method getMsgUsr() class OpenFire
Local msg := ''

If Empty(::msgUsr)

	//MODIFICA DE ACORDO COM OBJETIVO DA MENASGEM (PARADA OU RETORNO)
	If ::isRetMsg()
		::msgUsr := '[PARADA SISTEMA] DATA: ' + ::getData() + ' SISTEMA LIBERADO ' 
	Else
		::msgUsr := '[PARADA SISTEMA] DATA: ' + ::getData() + ' HORÁRIO: ' + ::getHora() + ' APROXIMADAMENTE: ' + ::getTempo() 
 	EndIf

EndIf

return ::msgUsr

method setMsgUsr(msgUsr) class OpenFire
	::msgUsr = msgUsr
return

//MENSAGEM-CORPO
method getMsgBody() class OpenFire
return ::msgBody

method setMsgBody(cBody) class OpenFire
	::msgBody := cBody
return

//URL
method getUrl() class OpenFire
local cUrlSpark	:= GetNewPar('XX_SPRKURL','' )	
	if Empty(::Url)
		::url := cUrlSpark 
	EndIf
return ::url

method setUrl(cUrl) class OpenFire
	Default cUrl := ''
	::url := cUrl
return

//HEADER
method getHeader() class OpenFire
local cKeySpark	:= GetNewPar('XX_SPRKAUT','' )	
	If Empty(::aheader)
		AAdd(::aheader, cKeySpark )
		AAdd(::aheader, 'Content-Type: application/xml')
	Endif
return ::aheader

method setHeader(aHeader) class OpenFire
	::aheader = aHeader
return

method sendSpark() class OpenFire

	Local cRet
	Local nTimeOut	:= 120
	Local cHeadRet	:= ""
	Local msg		:= ""
	Local aHeader	:= ::getHeader()
	Local cUrl		:= Alltrim(::getUrl())

	msg += '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
	msg += '<message>'
	msg += '<body>' 
	
	msg += Alltrim(::getMsgUsr())
	
	If Empty(::getMsgBody() ) 
		 msg += 'Mensagem: ' +  Alltrim(::getMsgBody())
	EndIf
	
	msg += '</body>'
	msg += '</message>'
	
	msg := Alltrim(EncodeUTF8(msg))
	
	cRet := HttpPost(cUrl,"",msg, nTimeOut, aHeader, @cHeadRet)
	::sendEmail()
return

method sendEmail() class OpenFire
local aHead 	:= {}
local msg		:=""
local cMsgUsr	:= ::getMsgUsr()
local cDest		:= GetNewPar('XX_STPEML','everycobre@cobrecom.com.br;treslagoas@cobrecom.com.br' )
local cGrpTi	:= GetNewPar('MV_EMGRPTI','wfti@cobrecom.com.br' )
	
	If Empty(::getMsgBody())
		aHead 	:= {""}
		msg 	:= ""
	Else
		aHead 	:= {"Mensagem"}
		msg 	:= ::getMsgBody()
	EndIf
	//Compilar os fontes que enviam email
	u_envmail({cGrpTi}, cMsgUsr, aHead,{{msg}},,,cDest )
return

/*TELA PARA INTERAGIR COM A CLASSE OpenFire */
User Function avisaParada(cAuth)
	Local aPBox 	:= {}
	Local aRet 		:= {}
	Local oSpark
	Local nTipo
	Local cData
	Local cHora
	Local cTempo
	Local aAuth 	:= {}
	Local cMsg
	Local cUsr
	Local cSenha
	Local lRetMsg	:= .F.
	Default cAuth 	:= ''
	
	If !Empty(cAuth)
		aAuth 	:= StrTokArr(cAuth, ',')
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' USER aAuth[1] PASSWORD aAuth[2]  MODULO 'FAT'
	EndIf
	/*MONTAR TELA PARAMBOX*/
	aAdd(aPBox ,{3,"Tipo Aviso",'PARADA', {"PARADA", "VOLTA"}, 50,'.T.',.T.})   
	aAdd(aPBox,{1,"Data Parada"  ,Ctod(Dtoc(Date())),"","","","",50,.T.})
	aAdd(aPBox,{1,"Hora Parada"  ,StrTran(Substr(Time(),1,5),':','H'),"99H99","","","",50,.T.})
	aAdd(aPBox,{2,"Tempo Parada",'10-MINUTOS',{'5-MINUTOS','10-MINUTOS','20-MINUTOS','30-MINUTOS','60-MINUTOS'},50,"",.T.})
	aAdd(aPBox,{11,"Informe o motivo","  ",".T.",".T.",.F.})
	/*EXIBIR A TELA*/
	If ParamBox(aPBox,"Aviso de Paradas no Sistema",@aRet)
		nTipo 	:= 	aRet[1]
		cData	:=	Dtoc(aRet[2])
		cHora	:= 	aRet[3]
		cTempo	:= 	aRet[4]
		cMsg	:=  aRet[5]
		/*MENSAGEM ESPECIFICA PARA VOLTA DO SISTEMA*/
		If nTipo == 2
			cMsg 	:= 'SISTEMA LIBERADO'
			cTempo	:= ''
			lRetMsg	:= .T.
		EndIf
		/*INICIAR A CLASSE*/
		oSpark := OpenFire():newOpenFire(cData, cHora, cTempo, cMsg, lRetMsg)
		/*ENVIAR MENSAGEM*/
		oSpark:sendSpark()
	Endif      
	If !Empty(cAuth)
		RESET ENVIRONMENT
	EndIf
Return nil
