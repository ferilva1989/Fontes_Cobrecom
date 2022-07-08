#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CBCREST.ch"

WSRESTFUL LOGINREST DESCRIPTION "Cobrecom - API REST - Login"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	WSMETHOD POST DESCRIPTION "Validar login retornando token de acesso" WSSYNTAX "/LOGINREST"
END WSRESTFUL

WSMETHOD POST WSSERVICE LOGINREST
Local lPost		:= .T.
Local oLogin	:= Nil
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
					oLogin := cbcRestLogin():newcbcRestLogin(oReq:cod, oReq:senha)
					oLogin:vldLogin(self,oRes)
					FreeObj(oLogin)
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