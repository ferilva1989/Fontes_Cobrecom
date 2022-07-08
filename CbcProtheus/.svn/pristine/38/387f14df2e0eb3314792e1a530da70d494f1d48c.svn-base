#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL DELVOL DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Ordem de Separação - Deletar Volume"
WSDATA count		AS INTEGER
WSDATA startIndex	AS INTEGER

WSMETHOD POST DESCRIPTION "Rota responsavel por receber Numero de um volume, e validar a possibilidade de exclui-lo, e excluir caso posivel" WSSYNTAX "/DELVOL"

END WSRESTFUL

WSMETHOD POST WSSERVICE DELVOL
Local lPost		:= .T.
Local oOpe		:= Nil
Local cBody		:= ""
Local cHeader	:= ""
Local cFil		:= ""
Local cMsg		:= ""
Local oRes		:= cbcResponse():newcbcResponse() 	//Modelo para  Responses
Local oVldAtt	:= cbcExisteAtt():newcbcExisteAtt() //Validar Atributos da classe
Local oFil		:= cbcFiliais():newcbcFiliais()		//Manipular as filiais
Local oTkn		:= cbcToken():newcbcToken()			//Controle dos tokens
Local oReq		:= Nil
Local aUsr		:= {}
Local nCodErro	:= 0
//Tipo do conteudo para retorno
::SetContentType("application/json")

//Obter conteudo da requisição
cBody 	:=  ::GetContent()
cHeader :=  ::GetHeader('Authorization')
cFil	:=  ::GetHeader('Filial')

//Iniciar o processo
If Empty(cHeader) .Or. Empty(cFil)
	cMsg	:= E400
	lPost 	:= .F.
	nCodErro :=400 
Else
	If Empty(cBody)
		cMsg	:= E407
		lPost 	:= .F.
		nCodErro := 407
	Else
		//Validar Token
		aUsr := oTkn:vldToken(cHeader) 
		If !aUsr[TDOK]
			cMsg	:= aUsr[MOTIVO_NAO_OK]
			lPost 	:= .F.
			nCodErro := 405
		Else
			If FWJsonDeserialize(cBody, @oReq)
				If !Empty(oVldAtt:isAtt(oReq,{'volume'}))
					cMsg	:= E402
					lPost 	:= .F.
					nCodErro := 402
				Else
					//Preparar a Filial
					If !oFil:setFilial(cFil)
						cMsg	:= E403
						lPost 	:= .F.
						nCodErro := 403
					Else
						//Negocio, envia para o proxy
						oVol := cbcProxyDelVol():newcbcProxyDelVol(FwNoAccent(Escape(oReq:VOLUME)),FwNoAccent(Escape(aUsr[COD_OP])))
						oVol:delVolInit(self, oRes)
						FreeObj(oVol)
					EndIf
				EndIf
			Else
				cMsg	:= E404
				lPost 	:= .F.
				nCodErro := 404
			EndIf
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
FreeObj(oTkn)

Return lPost