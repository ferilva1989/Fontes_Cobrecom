#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL GETOS DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Ordem de Separação - Obter Conteudo"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD GET DESCRIPTION "Retorna objeto contendo os itens de uma ordem de separação Sempre" WSSYNTAX "/GETOS/{nrOs}"
 
END WSRESTFUL

WSMETHOD GET WSSERVICE GETOS
Local cOs		:= ""
Local lGet		:= .T.
Local cHeader	:= ""
Local cFil		:= ""
Local oRes		:= cbcResponse():newcbcResponse()
Local oTkn		:= cbcToken():newcbcToken()
Local oFil		:= cbcFiliais():newcbcFiliais()//Todos devem conter
Local oOs		:= nil
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
				cOs := FwNoAccent(Escape(::aURLParms[1]))
				oOs := cbcProxyOs():newcbcProxyOs(cOs,FwNoAccent(Escape(aUsr[COD_OP])))
				oOs:getOsInit(self, oRes)
				FreeObj(oOs)
			EndIf
		EndIf
	EndIf
EndIf

FreeObj(oRes)
FreeObj(oTkn)
FreeObj(oFil)

Return lGet