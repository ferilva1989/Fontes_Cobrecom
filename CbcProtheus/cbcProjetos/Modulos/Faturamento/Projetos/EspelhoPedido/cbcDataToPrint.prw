#include 'protheus.ch'

#define NOME		1
#define END_EMAIL	2

/*/{Protheus.doc} cbcDataToPrint
(long_description)
@author bolognesi
@since 29/09/2016
@version 1.0
/*/
class cbcDataToPrint 
	data aItens
	data oHead
	data aTotais
	data cEmailTo
	data aOtherMails
	data cNroDoc
	data lOk
	data cMsg

	method newcbcDataToPrint() constructor 
	method getItens()
	method setItens()
	method getHead()
	method setHead()
	method setTotals()
	method getTotals()
	method getEmailTo()
	method setEmailTo()
	method getOtherMails()
	method setOtherMails()
	method getNroDoc()
	method setNroDoc()

endclass

/*/{Protheus.doc} new
Metodo construtor
@author bolognesi
@since 29/09/2016 
@version 1.0
/*/
method newcbcDataToPrint() class cbcDataToPrint
	::aItens 		:= {}
	::oHead 		:= {}
	::aOtherMails	:= {}
	::cEmailTo		:= ""

return(self)

/*/{Protheus.doc} getItens
@author bolognesi
@since 04/01/2017
@version 1.0
@type method
@description Metodo para obter o conteudo da propriedade AItens
/*/
method getItens() class cbcDataToPrint
return ::AItens

/*/{Protheus.doc} getTotals
@author bolognesi
@since 04/01/2017
@version 1.0
@type method
@description Metodo para obter o conteudo da propriedade aTotais
/*/
method getTotals() class cbcDataToPrint
return ::aTotais

/*/{Protheus.doc} setTotals
@author bolognesi
@since 04/01/2017
@version undefined
@param oTotais, object, objeto a ser definido como Propriedade aTotais
@type method
@description Definir o valor da propriedade aTotais
/*/
method setTotals(oTotais) class cbcDataToPrint
	Default oTotais	:= ""
	::lOk 			:= .T.
	::cMsg			:= ""
	If Empty(oTotais) 
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametros obrigatorios, setTotals(oTotais)!"
	Else
		::aTotais	:= oTotais
	EndIf
return (self)

/*/{Protheus.doc} setItens
@author bolognesi
@since 04/01/2017
@version undefined
@param oItem, object, objeto a ser definido como Propriedade aItens
@type method
@description Definir o valor da propriedade aItens
/*/
method setItens(oItem) class cbcDataToPrint
	Default oItem 	:= ""
	::lOk 			:= .T.
	::cMsg			:= ""
	If Empty(oItem) 
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametros obrigatorios, setItens(oItem)!"
	Else
		::aItens 	:= oItem
	EndIf
return (self)

/*/{Protheus.doc} getHead
@author bolognesi
@since 04/01/2017
@version undefined
@type method
@description Metodo para definir o conteudo da propriedade oHead
/*/
method getHead() class cbcDataToPrint
return ::oHead

/*/{Protheus.doc} setHead
@author bolognesi
@since 04/01/2017
@version 1.0
@param oHeader, object, descricao
@type method
@description Receber objeto oHeader e extrair dele 
email do cliente do representante e do assistente, bem como
a propriedade oHead
/*/
method setHead(oHeader) class cbcDataToPrint
	Local oLblSay 		:= Nil
	Default oHeader 	:= ""
	::lOk 	:= .T.
	::cMsg	:= ""
	If Empty(oHeader)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametros obrigatorios! setHead(oHeader)"
	Else
		::oHead := oHeader[1]
		::setEmailTo(	Alltrim(::oHead:EMAIL_CLI) )
		::setOtherMails( {'REPRESENTANTE'	, Alltrim(::oHead:EMAIL_REPRES)} )
		::setOtherMails( {'ASSISTENTE'		, Alltrim(::oHead:EMAIL_ATENDENTE)} )
	EndIf
return (self)

/*/{Protheus.doc} getEmailTo
@author bolognesi
@since 04/01/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade cEmailTo
que contem o endereço do cliente a ser enviado o espelho
caso necessario parar de enviar email ao cliente e enviar
somente interno descomentar o trecho abaixo
/*/
method getEmailTo() class cbcDataToPrint
	/*
	If ::CEmailTo !=  'wfti@cobrecom.com.br' 
		::CEmailTo := "leonardo@cobrecom.com.br"
	EndIf
	*/
return ::CEmailTo

/*/{Protheus.doc} setEmailTo
@author bolognesi
@since 04/01/2017
@version 1.0
@param cEmail, characters, String com os endereços de email do cliente (SA1.A1_EMAILCT)
@type method
@description definir o conteudo da propriedade cEmailTo. 
/*/
method setEmailTo(cEmail) class cbcDataToPrint
	Default cEmail 	:= ""

	If Empty(cEmail)
		::cEmailTo := 'wfti@cobrecom.com.br'
	Else
		cEmail := Alltrim(cEmail)
		If !U_vldEmail(cEmail)
			::cEmailTo := 'wfti@cobrecom.com.br'
		Else
			::cEmailTo = cEmail
		EndIF
	EndIf
return (self)

/*/{Protheus.doc} getOtherMails
@author bolognesi
@since 04/01/2017
@version 1.0
@param cBusca, characters, String contendo grupos do endereço de email
@type method
@description Etrair da propriedade AOtherMails os emails dos grupos
contidos em cBusca
/*/
method getOtherMails(cBusca) class cbcDataToPrint
	Local nX		:= 0
	Local nTam		:= 0
	Local xRet		:= ""
	Default cBusca 	:= ""

	nTam := Len(::AOtherMails)
	If !Empty(cBusca) 
		If nTam > 1
			For nX := 1 To nTam
				If ::AOtherMails[nX][NOME] == cBusca
					xRet += ::AOtherMails[nX][END_EMAIL]
				EndIf
			Next nX
		Else
			xRet := ::AOtherMails[nTam][END_EMAIL]
		EndIf
	Else
		xRet := ::AOtherMails
	EndIF
return xRet

/*/{Protheus.doc} setOtherMails
@author bolognesi
@since 04/01/2017
@version 1.0
@param aEmail, array, array com os email que devem ser atribuidos
a propriedade AOtherMails
@type method
@description Atribuir valores a propriedade aOtherMails 
/*/
method setOtherMails(aEmail) class cbcDataToPrint
	Local aSepEmail	:= {}
	Default aEmail 	:= ""
	If !Empty(aEmail)
		aEmail[END_EMAIL] := StrTran(aEmail[END_EMAIL],',',';')
		If ';' $ aEmail[END_EMAIL]		
			aSepEmail := StrTokArr(aEmail[END_EMAIL],';')
			aEmail[END_EMAIL] := aSepEmail[1]	 
		EndIf		
		Aadd(::aOtherMails , aEmail)
	EndIF
return (self)

/*/{Protheus.doc} getNroDoc
@author bolognesi
@since 04/01/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade cNroDoc
/*/
method getNroDoc() class cbcDataToPrint
return ::cNroDoc

/*/{Protheus.doc} setNroDoc
@author bolognesi
@since 04/01/2017
@version undefined
@param cNum, characters, String com valor a ser atribuido
a propriedade cNroDoc 
@type method
@description Definir o conteudo da propriedade cNroDoc 
/*/
method setNroDoc(cNum) class cbcDataToPrint
	Default cNum 	:= ""
	::lOk 			:= .T.
	::cMsg			:= ""

	If Empty(cNum)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametro obrigatorio, cbcDataToPrint():getNroDoc(cNum)!"
	Else
		::cNroDoc := cNum
	EndIf

return (self)

User Function contaChar(cTxt, cBusca)
	Local nQtd 	:= 0
	Local nPos	:= 0
	Local nNext	:= 0
	nPos := At(cBusca, cTXt) 
	If nPos > 0
		While nPos   != 0
			nQtd++
			nNext := (nPos + 1)
			nPos := At(cBusca, cTXt, nNext) 
		EndDo
	EndIf	
return (nQtd)

User Function vldEmail(cEmail) 
//U_vldEmail('teste@cobrecom.com.br') -> ( .T. )
//U_vldEmail('teste@cobrecom.com.br;teste1@cobrecom.com.br') ->( .T. )
//U_vldEmail('invalido') -> ( .F. )
//U_vldEmail('teste@cobrecom.com.br,teste1@cobrecom.com.br') -> ( .T. )
//U_vldEmail('teste@cobrecom.com.br;') -> ( .F. )
//U_vldEmail('teste@cobrecom.com.br,') -> ( .F. )
//U_vldEmail('teste@cobrecom.com.br;teste1@cobrecom.com.br;teste3@cobrecom.com.br;teste4@cobrecom.com.br;') -> ( .F. )
//U_vldEmail('teste@cobrecom.com.br;teste1@cobrecom.com.br;teste3@cobrecom.com.br;teste4@cobrecom.com.br') -> ( .T. )
	Local lRet		:= .T.
	Local nAt		:= 0
	Local nDotSlsh	:= 0
	Default cEmail	:= ""

	If Empty(cEmail)
		lRet		:= .F.
	Else
		cEmail := StrTran(cEmail,',',';')
		nAt 		:= U_contaChar(cEmail, '@')
		nDotSlsh 	:= U_contaChar(cEmail, ';')
		//Erro não tem nenhuma @
		If nAt == 0
			lRet := .F.
		//Somente um email
		ElseIf nAt == 1 .And. nDotSlsh == 0 
			lRet := .T.
		ElseIf nAt > 1 .And. (nDotSlsh == (nAt - 1))
		//Mais de um e-mail formatado ok
			lRet := .T.
		//Errado
		Else
			lRet := .F.
		EndIF
	EndIf
Return (lRet)
