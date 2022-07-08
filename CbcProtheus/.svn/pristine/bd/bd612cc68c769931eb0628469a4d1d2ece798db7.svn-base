#include 'protheus.ch'
#include 'fileio.ch'

#define PATH	'\cad_generico_json\'
#define EXT		'.json'

/*/{Protheus.doc} jsonCrud
@author bolognesi
@since 12/01/2017
@version 1.0
@type class
@description Classe que disponibiliza a possibilidade de criar um arquivo em texto json
que será manipulado como um arquivo de dados. diponibiliza uma tela para manutenção
destes registro e tambem os metodos para utilizar em programas 
/*/
class jsonCrud  from errLog
	data oJson 			//Objeto json principal
	data cPath 			//Diretorio e nome do arquivo de trabalho formato json
	data cStrJson		//Conteudo em texto do arquivo JSON, lido do disco
	data oLerArquivo	//Objeto FWFileReader() responsavel por operações de leituras no arquivo em disco
	data cToJson		//Nova string que deverá ser gravada em disco serialização da classe oJson
	data oDlg

	method newjsonCrud() constructor 

	method getPath()
	method setPath() 
	method getStrJson()
	method setStrJson()
	method getJson()
	method setJson()

	method loadJson()
	method saveJson() 
	method addReg()
	method remReg()
	method existe()

	method showDialog()

endclass

/*/{Protheus.doc} newjsonCrud
@author bolognesi
@since 12/01/2017
@version 1.0
@param cDir, characters, Diretorio e nome do arquivo json (Não obrigatorio)
@type method
/*/
method newjsonCrud(cPath, lView) class jsonCrud
	default cPath 	:= ""
	default lView	:= .F.
	checkDir()
	/* 
	//Herança classe errLog
	::getMsgLog() = Obter MsgErro  
	::setStatus(lSts, cCodMsg, cMsg) = Definir Status ( .T./ .F. ), codErro e MsgErro 
	::itsOk() Verifica se esta tudo Ok
	::clearStatus() = Limpar status de erro
	*/
	::newerrLog('JSON CRUD')
	If Empty(cPath)
		::setStatus( .F. ,'CBC700' ,'Parametro cPath obrigatorio')
	Else
		If lView
			If ::setPath(cPath):itsOk()
				::loadJson()
			EndIf
			::oDlg := nil
		Else
			If MayIUseCode( cPath , UsrRetName() )
				If ::setPath(cPath):itsOk()
					::loadJson()
				EndIf
				::oDlg := nil
			Else
				::setStatus( .F. ,'CBC701' ,'Outro usuario está utilizando a rotina')
			EndIf
		EndIf
	EndIf

return(self)

/********************************  INICIO - GET/SET *************************************/

//cPath
method getPath() class jsonCrud
return( lower(::cPath) )
method setPath(cPath) class jsonCrud
	Default cPath := ""
	If !Empty(cPath)
		cPath := (PATH + Alltrim(cPath) + EXT)
		If !FILE(cPath)
			novoArq(self, cPath)
		EndIf
	EndIf
	::cPath := cPath
return (self)

//cStrJson
method getStrJson() class jsonCrud
return(::cStrJson)
method setStrJson(cStr) class jsonCrud
	Default cStr := ""
	::cStrJson := cStr
	::setJson()
return(self)

//oJson
method getJson(cProp) class jsonCrud
	Local aTemp		:= {}
	Local nPos		:= 0
	Local xRet		:=Nil 
	Default cProp 	:=""
	xRet := ::oJson

	If !Empty(cProp)
		If !AttIsMemberOf(::oJSon,cProp)
			::setStatus( .F. ,'CBC702' ,'jsonCrud():getJson() propriedade ' + Alltrim(cProp) + ' não existe no objeto json')	
		Else
			aTemp := ClassDataArr(::oJson)
			nPos := AScan(aTemp,{|a| Alltrim(a[1]) == Alltrim(cProp) })
			If nPos > 0
				xRet := aTemp[nPos][2]
			EndIF
		EndIf
	EndIf

return(xRet)
method setJson() class jsonCrud
	Local oRet := Nil
	If !Empty(::getStrJson())
		If ! FWJsonDeserialize(::getStrJson(), @oRet   )
			::setStatus( .F. ,'CBC703' ,'jsonCrud():setJson() Json não foi serializado')	
		Else
			::oJson := oRet
			vldStruct(self)
		EndIf
	EndIf
return(self)

/********************************  FIM    - GET/SET *************************************/

/*/{Protheus.doc} loadJson
@author bolognesi
@since 12/01/2017
@version 1.0
@type method
@description Realiza a leitura do arquivo em disco trazendo-o para memoria como objeto
/*/
method loadJson() class jsonCrud
	If Empty(::getPath())
		::setStatus( .F. ,'CBC704' ,'jsonCrud():loadJson() faltando parametro obrigatorio')
	Else
		lerArquivo(Self)
	EndIf
return(self)

/*/{Protheus.doc} saveJson
@author bolognesi
@since 12/01/2017
@version 1.0
@type method
@description Salvar o arquivo Json da memoria para o disco 
sempre no mesmo diretorio de onde foi carregado
/*/
method saveJson() class jsonCrud
	If ::itsOk()
		If ValType(::oJson) == 'O'
			::cToJson := FWJsonSerialize(::oJson,.F.,.T. )
			If Empty(::cToJson)
				::setStatus( .F. ,'CBC705' ,'jsonCrud():saveJson() Objeto não serializado')
			Else
				saveArq(self)
				If ::itsOk()
					::loadJson()
				EndIF
			EndIF
		EndIF
	EndIF
return(self)

/*/{Protheus.doc} addReg
@author bolognesi
@since 13/01/2017
@version 1.0
@param xVlr, , Conteudo a ser acrescentado ao array de registros
@type method
@description Adiciona conteudo não repetido ao array de registros 
/*/
method addReg(xVlr) class jsonCrud
	Local nPos		:= 0
	default xVlr	:= ""
	If Empty(xVlr)
		::setStatus( .F. ,'CBC706' ,'jsonCrud():addReg() Parametro xVlr obrigatorio')
	Else
		If ::itsOk()
			If ValType(::oJson) != 'O'
				::setStatus( .F. ,'CBC707' ,'jsonCrud():addReg() objeto json não carregado, utilize :loadJson(cNome)')
			Else
				If AttIsMemberOf(::oJSon,'AREGISTROS')
					nPos := AScan( ::oJson:AREGISTROS ,{|a| Alltrim(a) == Alltrim(xVlr) })
					//TODO Verificar o tipo de dado

					//Adicionar quando não repetido
					If nPos == 0
						aadd( ::oJson:AREGISTROS, Alltrim(xVlr)  )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
return(self)

/*/{Protheus.doc} remReg
@author bolognesi
@since 13/01/2017
@version 1.0
@param xVlr, , Conteudo a ser removido ao array de registros
@type method
@description Remove conteudodo array de registros 
/*/
method remReg(xVlr) class jsonCrud
	Local nPos		:= 0
	Local nNovo		:= 0
	default xVlr	:= ""
	If Empty(xVlr)
		::setStatus( .F. ,'CBC708' ,'jsonCrud():remReg() Parametro xVlr obrigatorio')
	Else
		If ::itsOk()
			If ValType(::oJson) != 'O'
				::setStatus( .F. ,'CBC709' ,'jsonCrud():remReg() objeto json não carregado, utilize :loadJson(cNome)')
			Else
				If AttIsMemberOf(::oJSon,'AREGISTROS')
					nPos := AScan( ::oJson:AREGISTROS ,{|a| Alltrim(a) == Alltrim(xVlr) })
					If nPos > 0
						nNovo := (Len(::oJson:AREGISTROS) - 1)
						Adel(::oJson:AREGISTROS,nPos )
						ASize(::oJson:AREGISTROS,nNovo)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
return(self)

/*/{Protheus.doc} existe
@author bolognesi
@since 13/01/2017
@version 1.0
@param xBusca, , Conteudo a ser pesquisado nos registros
@type method
@description Verificar se um conteudo existe nos registros 
/*/
method existe(xBusca) class jsonCrud
	Local nPos		:= 0
	Local lRet		:= .F.
	default xBusca	:= ""
	If Empty(xBusca)
		::setStatus( .F. ,'CBC710' ,'jsonCrud():existe() Parametro xBusca obrigatorio')
	Else
		If ::itsOk()
			If ValType(::oJson) != 'O'
				::setStatus( .F. ,'CBC711' ,'jsonCrud():existe() objeto json não carregado, utilize :loadJson(cNome)')
			Else	
				If AttIsMemberOf(::oJSon,'AREGISTROS')
					nPos := AScan( ::oJson:AREGISTROS ,{|a| Alltrim(a) == Alltrim(xBusca) })
					If nPos > 0
						lRet := .T.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
return(lRet)

/************************************************  Funções estaticas ***********************************/
/* Salvar/Criar Novo/Validar Estrutura/ler um novo arquivo*/
Static function saveArq(oself)
	Local cCont		:= ""
	Local cNome 	:= ""
	Local nHandle 
	cCont := oself:cToJson
	cNome := oself:getPath()

	If !Empty(cNome) .And. !Empty(cCont)
		If FERASE(cNome) == -1
			oSelf:setStatus( .F. ,'CBC712' ,'jsonCrud():saveArq() Problemas ao deletar arquivo antes de salvar ')
		Else
			nHandle := FCREATE(Alltrim(cNome))

			If nHandle = -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
				oSelf:setStatus( .F. ,'CBC713' ,'jsonCrud():saveArq() Problemas ao salvar arquivo ' + Str(Ferror())  )
			Else
				FWrite(nHandle,cCont)
				FClose(nHandle)
			EndIf
		EndIF
	EndIF

return(nil)

Static function novoArq(oSelf, cNome)
	Local nHandle
	Local cCont		:= ""
	Default cNome 	:= ""
	If !Empty(cNome)
		cCont := '{"CTABELA" : "","CDESC"   : "Cadastro Generico","AREGISTROS":[]}'
		nHandle := FCREATE(Alltrim(cNome))
		If nHandle = -1
			oSelf:setStatus( .F. ,'CBC714' ,'jsonCrud():novoArq() Problemas ao criar novo arquivo ' + Str(Ferror())  )
		Else
			FWrite(nHandle,cCont)
			FClose(nHandle)
		EndIf
	EndIF
return(nil)

Static function vldStruct(oSelf)
	Local lRet 	:= .T.
	Local aCmp	:= {}
	Local nX	:= 0

	AAdd(aCmp,{'CTABELA'	,'C'})
	AAdd(aCmp,{'CDESC'		,'C'})
	AAdd(aCmp,{'AREGISTROS'	,'A'})

	For nX := 1 To Len(aCmp)
		If !AttIsMemberOf(oSelf:getJSon(),aCmp[nX][1] )
			lRet := .F.
			oSelf:setStatus( .F. ,'CBC715' ,'jsonCrud() Static vldStruct() Verifique estrutura json')
			exit	
		EndIf
	Next nX
Return(lRet)


Static function lerArquivo(oSelf)
	Local oFile 	:= Nil
	Local cConteudo := ""
	Local cPath		:= oSelf:getPath()

	oFile := FWFileReader():new(cPath)

	If !(oFile:Open())
		oSelf:setStatus( .F. ,'CBC716' ,'jsonCrud() Static lerArquivo() não foi possivel abrir o arquivo solicitado')
	Else
		cConteudo := oFile:fullread()
		oFile:close()
	EndIf
	If oSelf:itsOk()
		If Empty(cConteudo)
			oSelf:setStatus( .F. ,'CBC717' ,'jsonCrud() Static lerArquivo() arquivo foi lido, mas esta em branco')
		Else
			oSelf:setStrJson(cConteudo)
		EndIF
	EndIf
	FreeObj(oFile)
return (cConteudo)


/************************************* Montagem das Telas ******************************************/
/*/{Protheus.doc} showDialog
@author bolognesi
@since 12/01/2017
@version 1.0
@type method
@description mostra a tela para escolher as opções do CRUD
/*/
method showDialog() class jsonCrud
	Local oStepWiz 	:= nil
	Local aItm		:= {}
	If ::itsOk()		
		If ValType(::oJson) != 'O'
			::setStatus( .F. ,'CBC718' ,'jsonCrud():showDialog() objeto json não carregado, utilize :loadJson(cNome)')
		Else

			If !AttIsMemberOf(::oJSon,'AREGISTROS')
				::setStatus( .F. ,'CBC719' ,'jsonCrud():showDialog() Objeto Json não possue itens verifique estrutura')
			Else
				aItm :=  ::getJson('AREGISTROS')
				//Instancia a classe FWWizard
				oStepWiz:= FWWizardControl():New()
				oStepWiz:SetSize({600,960})
				oStepWiz:ActiveUISteps()

				//----------------------
				// Pagina 1
				//----------------------
				oNewPag := oStepWiz:AddStep("1")
				//Altera a descrição do step
				oNewPag:SetStepDescription(::getJson('CDESC'))
				//Define o bloco de construção
				oNewPag:SetConstruction({|Panel|cria_pg1(Panel, @aItm)})
				//Define o bloco ao clicar no botão Próximo
				oNewPag:SetNextAction({||finaliza(self, @aItm)})
				//Define o bloco ao clicar no botão Cancelar
				oNewPag:SetCancelAction({||oStepWiz:Destroy(), .T.})

				oStepWiz:Activate()
			EndIF
		EndIf
	EndIf
return(self)

/*/{Protheus.doc} cria_pg1
@author bolognesi
@since 13/01/2017
@version 1.0
@param oPanel, object, Container da tela
@param aItm, array, Itens para edição
@type function
@description Montagem dos componentes da tela
/*/
Static Function cria_pg1(oPanel,aItm)
	Local oFont1 		:= TFont():New("Arial Narrow",,020,,.F.,,,,,.F.,.F.)
	Local oBtnIncluir	:= nil
	Local oBtnExcluir	:= nil
	Local oLstBox		:= nil
	Local nLstBox 		:= 1

	oLstBox 	:= TListBox():New(001,001,{|u|if(Pcount()>0,nLstBox:=u,nLstBox)},aItm ,227,160,{||},oPanel,,,,.T.,,,oFont1 )
	oBtnExcluir := TButton():New( 175, 136, "Excluir",oPanel ,{||delVlr(aItm, oLstBox, oPanel)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnIncluir := TButton():New( 175, 186, "Incluir",oPanel ,{||addVlr(aItm, oLstBox, oPanel)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

	//oBtnIncluir:SetCss("QPushButton { background-color: #65cea7; font-color: white; }")
	//oBtnExcluir:SetCss("QPushButton { background-color: red; }")
return(Nil)

/*/{Protheus.doc} addVlr
@author bolognesi
@since 13/01/2017
@version 1.0
@param aItm, array, Itens em edição
@param oLstBox, object, Objeto de tela interface dos itens em edição
@param oPanel, object, Painel/Container de exibição
@type function
@description adiciona elementos ao array de itens editaveis
/*/
Static function addVlr(aItm, oLstBox, oPanel)
	Local aPergs 	:= {}
	Local cCodRec	:= Space(80)
	Local aRet		:= {}
	Local nPos		:= 0
	aadd( aPergs ,{1,"Incluir : ",cCodRec,"@!",'.T.',,'.T.',80,.F.})
	If ParamBox(aPergs ,"Incluir ",@aRet)      
		If !Empty(aRet[1])
			nPos := AScan( aItm ,{|a|  lower(Alltrim(a)) == lower(Alltrim(aRet[1]))  })
			If nPos == 0
				aadd(aItm, Lower(Alltrim(aRet[1])) )
				oLstBox:SetItems(aItm)
				oPanel:Refresh()
			EndIf
		EndIf
	EndIF   
return(nil)

/*/{Protheus.doc} delVlr
@author bolognesi
@since 13/01/2017
@version 1.0
@param aItm, array, Array com os itens em edição
@param oLstBox, object, Objeto de tela (interface para aItm lista com os itens em edição)
@param oPanel, object, Painel/Container para exibição
@type function
@description Deleta valores do aItm de acordo com interação do usuario 
/*/
Static function delVlr(aItm, oLstBox, oPanel)
	Local nPos 	:= 0
	Local nNovo	:= 0
	If MsgNoYes('Deseja excluir o item: ' + oLstBox:GetSelText() )
		nPos := AScan(aItm,{|a| Alltrim(a) == Alltrim(oLstBox:GetSelText()) })
		If nPos > 0
			nNovo := (Len(aItm) - 1)
			Adel(aItm,nPos )
			ASize(aItm, nNovo)
			oLstBox:SetItems(aItm)
			oPanel:Refresh()
		EndIf
	EndIF
return(nil)

/*/{Protheus.doc} finaliza
@author bolognesi
@since 13/01/2017
@version 1.0
@param oSelf, object, Objeto da classe 
@param aItm, array, Array por referencias dos registros em edição
@type function
@description Finaliza o processo de edição, gravando o Json em disco
/*/
Static function finaliza( oSelf, aItm)
	Local lRet	 := .F.
	lRet := MsgNoYes('Deseja finalizar a manutenção?')
	If lRet
		oSelf:saveJson()
	EndIf
return(lRet)


/* TEST ZONE   -> Função utilizada como o exemplo de utilização da classe */
User Function JsonCrud(cPath) //U_JsonCrud('JSON_EMAIL')
	Local oCrud := Nil
	Local cRet	:= ""
	Local aItm	:= {}
	Default cPath := ""

	/* Exemplo do uso somente para visualizar */
	//Contrutor para visualizar (Portal)
	oCrud := jsonCrud():newjsonCrud(cPath, .T. )
	//Retorna o array com os registros
	aItm :=  oCrud:getJson('AREGISTROS')

	//Construtor para editar
	oCrud := jsonCrud():newjsonCrud(cPath) 

	If !oCrud:itsOk()
		Alert( oCrud:getMsgLog() )
	Else
		//Adicionar um item
		oCrud:addReg('outro@email.com.br')
		//Verificar se um item existe
		If oCrud:existe('outro@email.com.br')
			//Alert('Existe')
		Else
			//Alert('Não existe')
		EndIf

		//Remover um item
		oCrud:remReg('outro@email.com.br')
		If oCrud:existe('outro@email.com.br')
			//Alert('Existe')
		Else
			//Alert('Não existe')
		EndIf
		//Salvar as alterações em disco
		oCrud:saveJson()
		//Mostrar a tela de cadastro
		oCrud:showDialog()
	EndIF
return(nil)


/*/{Protheus.doc} checkDir
@author bolognesi
@since 20/09/2017
@version 1.0
@type function
@description Criar o diretorio caso não exista
/*/
static function checkDir()
	if !ExistDir( PATH )
		MakeDir( PATH)
	endif
return(nil)