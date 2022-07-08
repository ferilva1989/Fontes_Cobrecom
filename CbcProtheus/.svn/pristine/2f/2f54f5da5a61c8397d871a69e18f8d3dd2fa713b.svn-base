#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL IMPVOL DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Ordem de Separação - Imprimir um volume"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD GET DESCRIPTION "Rota responsavel por receber Numero de um volume, e caso exista realiza a impressão" WSSYNTAX "/IMPVOL/{nrVol}"
END WSRESTFUL

WSMETHOD GET WSSERVICE IMPVOL
Local cVol		:= ""
Local lGet		:= .T.
Local cHeader	:= ""
Local cFil		:= ""
Local oRes		:= cbcResponse():newcbcResponse()
Local oTkn		:= cbcToken():newcbcToken()
Local oFil		:= cbcFiliais():newcbcFiliais()//Todos devem conter
Local oVol		:= nil
Local aUsr		:= {}
//Tipo do conteudo para retorno
::SetContentType("application/json")

//Obter conteudo da requisição
cHeader := ::GetHeader('Authorization')
cFil	:= ::GetHeader('Filial')

//Iniciar o processo
If Len(::aURLParms) == 0
	SetRestFault(406,E406)
	lGet := .F.
Else
	If Empty(cHeader) .Or. Empty(cFil)
		SetRestFault(400,E400)
		lGet := .F.
	Else
		aUsr := oTkn:vldToken(cHeader) 
		If !aUsr[TDOK]
			SetRestFault(405,aUsr[MOTIVO_NAO_OK])
			lGet := .F.
		Else
			//Preparar a Filial
			If !oFil:setFilial(cFil)
				SetRestFault(403,E403)
				lGet := .F.
			Else
				cVol := FwNoAccent(Escape(::aURLParms[1]))
				oVol := cbcProxyImpVol():newcbcProxyImpVol(cVol,FwNoAccent(Escape(aUsr[COD_OP])))
				oVol:impVolInit(self, oRes)
				FreeObj(oVol)
			EndIf
		EndIf
	EndIf
EndIf

FreeObj(oRes)
FreeObj(oTkn)
FreeObj(oFil)

Return lGet