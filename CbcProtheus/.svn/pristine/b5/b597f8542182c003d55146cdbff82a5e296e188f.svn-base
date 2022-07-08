#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL LOGINACD DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Login"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD POST DESCRIPTION "Validar o Operador retornando token de acesso" WSSYNTAX "/LOGINACD"
 
END WSRESTFUL

WSMETHOD POST WSSERVICE LOGINACD
Local lPost		:= .T.
Local oOpe		:= Nil
Local cBody		:= ""
Local cHeader	:= ""
Local cFil		:= ""
Local cMsg		:= ""
Local oRes		:= cbcResponse():newcbcResponse() //Modelo para  Responses
Local oVldAtt	:= cbcExisteAtt():newcbcExisteAtt() //Validar Atributos da classe
Local oFil		:= cbcFiliais():newcbcFiliais()//Todos devem conter
Local oReq		:= Nil
Local nCodErro	:= 0

//Tipo do conteudo para retorno
::SetContentType("application/json")

//Obter conteudo da requisição
cBody 	:=  ::GetContent()
cFil	:=  ::GetHeader('Filial')

//Iniciar o processo
If Empty(cFil)
	cMsg		:= E400
	lPost 		:= .F.
	nCodErro	:= 400
Else
	If Empty(cBody)
		cMsg		:= E401
		lPost 		:= .F.
		nCodErro	:= 401
	Else
		If FWJsonDeserialize(cBody, @oReq)
			If !Empty(oVldAtt:isAtt(oReq,{'cod','senha'}))
				cMsg		:= E402
				lPost 		:= .F.
				nCodErro	:= 402
			Else
				//NEGOCIO
				//Preparar a Filial
				If !oFil:setFilial(cFil)
					cMsg		:= E403
					lPost 		:= .F.
					nCodErro	:= 403
				Else
					oOpe := cbcLogin():newcbcLogin(oReq:cod, oReq:senha)
					oOpe:vldOperador(self,oRes)
					FreeObj(oOpe)
				EndIf
			EndIf
		Else
			cMsg		:= E404
			lPost 		:= .F.
			nCodErro	:= 404
		EndIf
	EndIf
EndIf

//Devolve mensagem de erro
If !lPost
	SetRestFault(nCodErro,cMsg)
EndIf

FreeObj(oRes)
FreeObj(oVldAtt)
FreeObj(oFil)

Return lPost