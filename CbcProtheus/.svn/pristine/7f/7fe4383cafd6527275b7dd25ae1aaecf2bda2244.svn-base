#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL GETPARAM DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Ordem de Separação - Obter Conteudo de Parametro"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD GET DESCRIPTION "Recebe um parametro e devolve o seu valor" WSSYNTAX "/GETPARAM/{MV_PARAM}"
 
END WSRESTFUL

WSMETHOD GET WSSERVICE GETPARAM
Local lGet			:= .T.
Local cHeader		:= ""
Local cFil			:= ""
Local oRes			:= cbcResponse():newcbcResponse()
Local oTkn			:= cbcToken():newcbcToken()
Local oFil			:= cbcFiliais():newcbcFiliais()//Todos devem conter
Local aUsr			:= {}
Local cNomeParam	:= ""
Local cVlrParam		:= ""
Local cTpParam		:= ""
Local lSucesso		:= .F.
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
				cNomeParam 		:= FwNoAccent(Escape(::aURLParms[PARAM1]))
				cVlrParam		:= GetMv(cNomeParam,.T.,'')
				
				If !Empty(cVlrParam)
					lSucesso := .T.
					cTpParam		:= ValType(cVlrParam)	
				EndIf
				
				oRes:sucesso 			:= lSucesso
				oRes:msg				:= cNomeParam
				oRes:mvParam:Conteudo	:= cVlrParam		
				oRes:mvParam:Tipo		:= cTpParam
				
				::SetResponse(oRes:toJson())
			EndIf
		EndIf
	EndIf
EndIf

FreeObj(oRes)
FreeObj(oTkn)
FreeObj(oFil)

Return lGet