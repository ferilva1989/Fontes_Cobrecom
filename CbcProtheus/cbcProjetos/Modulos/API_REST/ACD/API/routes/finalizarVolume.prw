#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL FINVOL DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Finalizar Volume"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD POST DESCRIPTION "Receber dados coletados, com a intencao de gerar um volume para uma Ordem de Separacao" WSSYNTAX "/FINVOL"
 
END WSRESTFUL

WSMETHOD POST WSSERVICE FINVOL
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
				If !Empty(oVldAtt:isAtt(oReq,{'ordem','Itens','header'}))
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
						cFinVol := cbcProxyFinVol():newcbcProxyFinVol(FwNoAccent(Escape(oReq:ORDEM)),FwNoAccent(Escape(aUsr[COD_OP])))
						cFinVol:FinVolInit(self, oRes, oReq:HEADER, oReq:ITENS)
						FreeObj(cFinVol)
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
