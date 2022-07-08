#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"

WSRESTFUL VLDFIL DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Validar Filial Informada"
WSDATA count		AS INTEGER
WSDATA startIndex	AS INTEGER

WSMETHOD GET DESCRIPTION "Retorna se uma filial informada existe no sistema" WSSYNTAX "/VLDFIL/{nrFil}"

END WSRESTFUL

WSMETHOD GET WSSERVICE VLDFIL
	Local lGet		:= .T.
	Local cHeader	:= ""
	Local cFil		:= ""
	Local oRes		:= cbcResponse():newcbcResponse()
	Local oFil		:= cbcFiliais():newcbcFiliais()//Todos devem conter
	Local aUsr		:= {}
	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Iniciar o processo
	If Len(::aURLParms) == 0
		SetRestFault(406,E406)
		lGet := .F.
	Else
		If !FWFilExist('01', ::aURLParms[PARAM1] )
			SetRestFault(403,E403)
			lGet := .F.
		Else
			oRes:sucesso 	:= .T.
			oRes:msg		:= EncodeUTF8(Alltrim(FWFilialName('01',::aURLParms[PARAM1])))
			oRes:body		:= ''		
			::SetResponse(oRes:toJson())
		EndIf
	EndIf
	FreeObj(oRes)
	FreeObj(oFil)
Return lGet