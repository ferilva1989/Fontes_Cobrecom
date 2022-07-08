#INCLUDE "TOTVS.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'
#include "TOPCONN.ch"
#include "tbiconn.ch"   
#Define linha chr(13)+chr(10)

/*/{Protheus.doc} CbcCredCliente
@author bolognesi
@since 25/04/2016
@version 1.0
@example
(Local oCredito := CbcCredCliente():newCbcCredCliente() )
@description Classe responsavel por analisar e avaliar
o credito dos clientes
/*/
class CbcCredCliente

	data oArea
	data Mercado
	data cEndUrl
	data lOk
	data cMsg

	data cCliente
	data cLoja
	data cCNPJ
	data nRecCli
	
	data cLogon
	data cPass

	method newCbcCredCliente() constructor

	method getCliente()
	method setCliente()
	method getLoja()
	method setLoja()
	method getCNPJ()
	method setCNPJ()
	method getRecCli()
	method setRecCli()
	method getLogon()
	method setLogon()
	method getPass()
	method setPass()
	method setAuth()
	
	method getUrl()
	method getCliInfo()
	method consultaCCB()
	method consultaSER()
	method trataRetXml()
	method mostraResult()
	
	method qrySerasa()  
	method credBrow()

endclass

/*/{Protheus.doc} newCbcCredCliente
@author bolognesi
@since 25/04/2016 
@version 1.0
@description Construtor da classe
/*/
method newCbcCredCliente(cCli, cLoja, nRecno) class CbcCredCliente
	Default cCli 	:= ""
	Default cLoja 	:= ""
	Default nRecno	:= 0

	::lOk := .T.
	::oArea := SigaArea():newSigaArea()
	::setCliente(cCli)
	::setLoja(cLoja)
	::setRecCli(nRecno)
	::getCliInfo()
	::setLogon()
	::setPass()

return

/*/{Protheus.doc} getCliente
@author bolognesi
@since 25/04/2016
@version undefined
@type function
/*/
method getCliente() class CbcCredCliente
return ::cCliente


/*/{Protheus.doc} setCliente
@author bolognesi
@since 25/04/2016
@version undefined
@param cCli, characters, descricao
@type function
/*/
method setCliente(cCli) class CbcCredCliente
	::cCliente := Padr(cCli,TamSx3("A1_COD") [1])
return


/*/{Protheus.doc} getLoja
@author bolognesi
@since 25/04/2016
@version undefined
@type function
/*/
method getLoja() 	class CbcCredCliente
return ::cLoja

/*/{Protheus.doc} setLoja
@author bolognesi
@since 25/04/2016
@version undefined
@param cLoja, characters, descricao
@type function
/*/
method setLoja(cLoja) 	class CbcCredCliente
	::cLoja := Padr(cLoja, 	TamSx3("A1_LOJA")[1])
return



/*/{Protheus.doc} getCNPJ
@author bolognesi
@since 25/04/2016
@version undefined
@type function
/*/
method getCNPJ()	class CbcCredCliente
return SubStr(::cCNPJ, 1,8)

/*/{Protheus.doc} setCNPJ
@author bolognesi
@since 25/04/2016
@version undefined
@param cCnpj, characters, descricao
@type function
/*/
method setCNPJ(cCnpj)	class CbcCredCliente
	::cCNPJ := Padr(cCnpj, TamSx3("A1_CGC")[1])
return

/*/{Protheus.doc} getRecCli
@author bolognesi
@since 25/04/2016
@version undefined
@type function
/*/
method getRecCli() 	class CbcCredCliente
return ::nRecCli

/*/{Protheus.doc} setRecCli
@author bolognesi
@since 25/04/2016
@version undefined
@param nRec, numeric, descricao
@type function
/*/
method setRecCli(nRec) 	class CbcCredCliente
	::nRecCli := nRec
return

/*/{Protheus.doc} getLogon
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description get propriedade cLogon
/*/              
method getLogon() class CbcCredCliente
return ::cLogon

/*/{Protheus.doc} setLogon
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description set propriedade cLogon
/*/
method setLogon(logon) class CbcCredCliente
 ::cLogon := logon	
return

/*/{Protheus.doc} getPass
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description get propriedade cPass
/*/
method getPass() class CbcCredCliente
return Lower(::cPass)

/*/{Protheus.doc} setPass
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description set propriedade cPass
/*/
method setPass(pass) class CbcCredCliente
	::cPass := pass
return

/*/{Protheus.doc} setAuth
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description busca logon e senha do serasa na tabela SX5 Z8
definindo as propriedades cLogon cPass
/*/                    
method setAuth() class CbcCredCliente
Local aRet := {}
Local lRet := .F.	

	cUsrInfo := Posicione("SX5",1,xFilial("SX5")+"Z8"+Alltrim(__CUSERID),"X5_DESCRI" )
	If Empty(cUsrInfo)
	   	::setPass("")
	    ::setLogon("")
	Else
		aRet := StrTokArr(cUsrInfo, ";")
		If Len(aRet) == 2 
			::setLogon(aRet[1])
			::setPass(aRet[2])
			lRet := .T.
		Else
			::setPass("")
			::setLogon("")
		
		EndIf 
	Endif
return lRet

/*/{Protheus.doc} getUrl
@author bolognesi
@since 25/04/2016
@version 1.0
@type method
@param lTipo, String, Defini o tipo de url para consulta XML/LINK
@description Obtem a url completa com todos os parametros
para realizar a chamada, caso não tenha CNPJ informado
define propriedad lOk como .F. e atribui uma mensagem 
na propriedade cMsg
/*/
method getUrl(lTipo) class CbcCredCliente

	Local cUrlXml := "http://www.ccb.inf.br/Conveniado/Consulta/ConsXML.asp?"
	Local cUrlLnk := "http://www.ccb.inf.br/Conveniado/Consulta/ConsFicha.asp?"
	Local cEmail	:= "andrei@cobrecom.com.br" //TODO Colocar parametro e permitir Financeiro Gerenciar
	Local cSenha	:= "dr1089" //TODO Colocar parametro e permitir Financeiro Gerenciar
	Local Mercado	:= "N"
	Local cParam	:= "Email=" + cEmail + "&Senha=" + cSenha + "&CNPJ=" + ::getCNPJ() + "&Mercado=N"
	Local cEndUrl	:= ""

	::cEndUrl := ""

	If Empty(::getCNPJ())
		::lOk 	:= .F.
		::cMsg 	:= "[ERRO-CCB] - CNPJ não informado"
	Else

		If lTipo == 'XML'
			::cEndUrl := cUrlXml + cParam
		ElseIf lTipo == 'LINK'
			::cEndUrl := cUrlLnk + cParam
		Else
			::lOk 	:= .F.
			::cMsg 	:= "[ERRO-CCB] - Tipo do link para conculta não informado"
		EndIf

	EndIf
return Alltrim(::cEndUrl)

/*/{Protheus.doc} getCliInfo
@author bolognesi
@since 25/04/2016
@version undefined
@type function
/*/
method getCliInfo() class CbcCredCliente
	Local cCli 	:= ::getCliente()
	Local cLoja := ::getLoja()

	If !Empty(cCli) .And. !Empty(cLoja)

		::oArea:saveArea( {'SA1'} )
		DbSelectarea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		if SA1->(DbSeek(xFilial("SA1") + cCli + cLoja, .F.) )

			::setCNPJ(SA1->(A1_CGC))

		Else
			::lOk := .F.
			::cMsg := "[ERRO] - Chave cliente: " + cCli + " / Loja: " + cLoja + " não encontrado"
		EndIf
		::oArea:backArea()

	ElseIf nRecno > 0

	Else

	EndIf

return

/*/{Protheus.doc} consultaCCB
@author bolognesi
@since 25/04/2016
@version undefined
@type function
@param lTipo, String, Recebe XML ou LINK
@description Metodo que realiza a consulta
seu parametro lTipo defini a forma de realizar a 
consulta, sendo LINK=apenas exibir a consulta
(Analise visual) e XML=Objeto acessivel (Analise
automatica) aplica regras do sistema
/*/
method consultaCCB(lTipo) class CbcCredCliente
	Local cGetRet 	:= ""
	Local oXml			:= NIL
	Local cErro 		:= ""
	Local cAviso 		:= ""
	Default lTipo		:= "XML"

	cGetRet 	:= HttpGet(::getUrl(lTipo),"")
	If !Empty(cGetRet)
		cGetRet	:=STRTRAN(Alltrim(cGetRet),chr(13)+chr(10),'')

		If lTipo == "XML"
			oXml 	:= XmlParser(cGetRet,"_",@cErro,@cAviso)
			::trataRetXml(oXml, 'CCB')

		ElseIf lTipo == "LINK"
			//TODO Estruturar consultas salvas em Tabelas
			::mostraResult(cGetRet)
		EndIf


	EndIf
return     

/*/{Protheus.doc} consultaSER
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description Metodo que realiza a consulta
a consulta no SERASA, utilizando APIREST interna
/*/
method consultaSER() class CbcCredCliente
	If ::setAuth()
		::qrySerasa()
	Else
		MessageBox("[AVISO] - Verifique se usuario possui Logon e Senha para utilizar o SERASA", "Aviso",48) 
	EndIf
return

/*/{Protheus.doc} qrySerasa
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description Realiza chamada POST no server para gerar
uma nova consulta SERASA 
/*/
method qrySerasa() class CbcCredCliente
	Local cUrl		:= AllTrim(GetMV('MV_APISERA')) + "/api/serasa"
	Local nTimeOut	:= 120
	Local aHeadOut	:= {}
	Local cHeadRet	:= ""
	Local cRet		:= ""
	Local oRelato	:= nil
	Local cCnpj		:= ::getCNPJ()
	Local oConsult	:= Nil
	
	Local cLogon	:= ::getLogon()
	Local cPass		:= ::getPass()
	
	cCnpj := Substr(cCnpj,1,8)

	AAdd(aHeadOut, 'User-agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
	AAdd(aHeadOut, 'Content-Type: application/x-www-form-urlencoded')
	cRet := HttpPost(cUrl, ,"logon=" + cLogon + "&senha=" + cPass + "&cnpj=" + cCnpj, nTImeOut,aHeadOut, @cHeadRet)
	If !Empty(cRet)
	    //Deserializar o retorno
		//FWJsonDeserialize(cRet, @oConsult)
	 	//oConsult:FAULT
		::credBrow(cCnpj+'/'+cLogon)
	Else
		Alert("ERRO")
	EndIf
Return Nil

/*/{Protheus.doc} credBrow
@author bolognesi
@since 06/07/2016
@version 1.0
@type method
@description Abre o browser do cliente para visualizar
a consulta salva 
/*/
method credBrow(cParam) class CbcCredCliente 
	Local aBrowser 	:= {} 
	Local cApiUrl	:= AllTrim(GetMV('MV_APISERA')) + "/#/consulta/"
	Local cFirefox	:= "%PROGRAMFILES%\Mozilla Firefox\firefox.exe"
	Local cChrome 	:= "%PROGRAMFILES%\Google\Chrome\Application\chrome.exe" 
	Local cIE		:= "%PROGRAMFILES%\Internet Explorer\iexplore.exe"                     
	Local nX		:= 0
	Local lOk		:= .F.
	Local nRet		:= 0

	AAdd(aBrowser,{cChrome,cFirefox,cIE} )

	For nX := 1 To Len(aBrowser[1])
		nRet := ShellExecute("Open", aBrowser[1,nX] ,cApiUrl+cParam, "C:\",1)  	
		If nRet <> 2
			lOk := .T.
			Exit  
		EndIf
	Next nX

	If !lOk
		MessageBox("Nenhum navegador encontrado", "AVISO", 48 )
	EndIf
Return

/*/{Protheus.doc} trataRetXml
@author bolognesi
@since 25/04/2016
@version undefined
@param oXml, object, descricao
@param cWho, characters, descricao
@type function
/*/
method trataRetXml(oXml, cWho) class CbcCredCliente

	If cWho == 'CCB'
		alert('REALIZAR-ANALISE CRÈDITO AUTOMATICA')
	EndIf

return

/*/{Protheus.doc} mostraResult
@author bolognesi
@since 25/04/2016
@version 1.0
@param cContent, string, string html que será exibida
@type method
@description Metodo que exibe em tela a conteudo HTML
/*/
method mostraResult(cContent) class CbcCredCliente
	Local nHandle
	Default cContent  := ""

	If Empty(cContent)
		::lOk := .F.
		::cMsg := "[ERRO] - Nenhum conteudo para ser exibido"
	Else

		nHandle := FCREATE("\consulta.html")
		If nHandle = -1
			conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			::lOk := .F.
			::cMsg := "[ERRO] - Criação de arquivo consulta (CCB/SERASA) " + Str(Ferror())
		Else
			FWrite(nHandle, cContent)
			FClose(nHandle)
			CpyS2T("\consulta.html","c:\temp\",.T.)
			SHELLEXECUTE("Open","C:\temp\consulta.html","","",3)
		EndIf

	EndIf

return

/* PE_MATA450A   FUNÇÂO M450AROT() */
User function tstCredCli(cCli, cLoja, cDest)
	Local oCredito := Nil	
	If Empty(cCli) .Or. Empty(cLoja)
		MessageBox("Selecione ao menos um cliente para consulta", "AVISO", 48)     
	Else
		oCredito := CbcCredCliente():newCbcCredCliente(cCli, cLoja, 0)
		if cDest == 'CCB'
			oCredito:consultaCCB("LINK")
		ElseIf cDest == 'SER'
			oCredito:consultaSER()
		Endif
	EndIf
return