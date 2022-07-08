#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

//Mata103 - Rotina Documento de Entrada
*
**********************
User Function MT100LOK
	**********************
	*  
	//PE Para Validação da Linha do Acols
	Local lRet := .T.

	If Alltrim(SA2->A2_EST) == "EX"
		If Empty(GDFieldGet("D1_X_ADIC",n))
			lRet := .F.
			MsgInfo("Falta Preencher nº Adição","Dados Adicionais para NF Importação")
		ElseIf Empty(GDFieldGet("D1_X_SQADI",n))
			lRet := .F.
			MsgInfo("Falta Preencher Seq. Adicao","Dados Adicionais para NF Importação")
		ElseIf Empty(GDFieldGet("D1_X_FABR",n))
			lRet := .F.
			MsgInfo("Falta Preencher Fabricante","Dados Adicionais para NF Importação")
		ElseIf Empty(GDFieldGet("D1_X_BSII",n))
			lRet := .F.
			MsgInfo("Falta Preencher Base Calc. I.I.","Dados Adicionais para NF Importação")
		ElseIf GDFieldGet("D1_X_BSII",n) > GDFieldGet("D1_TOTAL",n)
			lRet := .F.
			MsgInfo("Base Calc. I.I. maior que o Valor Total do Item","Dados Adicionais para NF Importação")
		ElseIf Empty(GDFieldGet("D1_X_VLII",n)) .Or. GDFieldGet("D1_X_VLII",n) > ((GDFieldGet("D1_TOTAL",n) * 20) / 100)
			MsgInfo("Valor do I.I. Pode Estar Errado, CONFIRA","Dados Adicionais para NF Importação")
		ElseIf Empty(GDFieldGet("D1_X_DPAD",n))
		ElseIf Empty(GDFieldGet("D1_X_VIOF",n))
		EndIf
	EndIf

	If lRet .And. cFormul == "S" .And. cTipo == "N" // Formulário próprio -> Precisa de Autorização do SEFAZ
		_nTtLin := NoRound(GDFIELDGET("D1_VUNIT",n) * GDFIELDGET("D1_QUANT",n),2)
		If Abs(GDFIELDGET("D1_TOTAL",n) - _nTtLin) > 0.01
			// Sefaz não aceita diferenças maior que R$ 0.01
			MsgInfo("Valor Total difere do produto entre Vlr.Unit. e Quantidade." + Chr(13)+Chr(13)+;
			"Valor Total Correto R$ " + ;
			AllTrim(Transform((GDFIELDGET("D1_VUNIT",n) * GDFIELDGET("D1_QUANT",n)),"@E 99,999,999.99")) + ;
			".","Conferência Valores da Nota - Erro!")
			lRet := .F.
		Endif  
	EndIf
	Return(lRet)   
	*
	**********************
User Function MT100GE2
	**********************
	*  
	//PE executado pela rotina de classificação de NF
	//Executado apos inclusao no SE2 (titulos a pagar). Sera executado uma vez para cada parcela.
	Local _aArea    := GetArea()
	Local _aAreaSE2

	DbSelectArea("SE2")
	_aAreaSE2 := GetArea()

	If Alltrim(SE2->E2_ORIGEM) == "MATA100" .And. SE2->E2_IRRF+SE2->E2_ISS == 0

		//LEONARDO 03/07/2014 - Acertar campo E2_CLVLDB igual natureza
		SE2->(E2_CLVLDB) := SE2->(E2_NATUREZ)
		//FIM LEONARDO

		//Fev-2016 - A edição dos títulos a pagar após inclusão/classificação do Documento de Entrada foi desabilitada.
		//           Motivo: Evitar divergência de condição de pagamento entre NF x PCs (Manter integridade nas aprovações do Sistema de Alçada de Compras)
		//FA050Alter("SE2",SE2->(Recno()),4)
	EndIf     

	RestArea(_aAreaSE2)
	RestArea(_aArea)


	/*
	CD5->CD5_FILIAL
	CD5->CD5_DOC   
	CD5->CD5_SERIE
	CD5->CD5_ESPEC 
	CD5->CD5_FORNEC
	CD5->CD5_LOJA
	CD5->CD5_TPIMP   //Tipo documento importacao
	CD5->CD5_DOCIMP  //Numero doc. importacao   
	CD5->CD5_BSPIS   //Base PIS importacao
	CD5->CD5_ALPIS 
	CD5->CD5_VLPIS 
	CD5->CD5_BSCOF 
	CD5->CD5_ALCOF 
	CD5->CD5_VLCOF 
	CD5->CD5_X_DTDI  
	CD5->CD5_X_LOCD
	CD5->CD5_X_UFDE
	CD5->CD5_X_DTDE
	CD5->CD5_X_MSG 
	*/
	Return(.T.)
	*
	***********************
User Function A100DEL()
	***********************
	*
	* Retornar .T. ou .F. se a nota pode ou não ser excluída.
	// Verificar se o título gerado pela nota de entrada  está em um caixa
	*
	_aArea := GetArea()
	_lVolta := .T.
	DbSelectArea("SE2")
	DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	DbSeek(xFilial("SE2") + SF1->F1_PREFIXO+SF1->F1_DOC,.T.)
	Do While SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_PREFIXO == SF1->F1_PREFIXO .And.;
	SE2->E2_NUM    == SF1->F1_DOC .And. SE2->(!Eof())

		If SE2->E2_TIPO == MVNOTAFIS .And. SE2->E2_FORNECE == SF1->F1_FORNECE .And. ;
		SE2->E2_LOJA == SF1->F1_LOJA .And. !Empty(SE2->E2_NUMCX)
			MsgAlert("Nota Fiscal Já Provisionada em Caixa - Solicitar o Estorno da Provisão.","Atencao!")
			_lVolta := .F.
			Exit
		EndIf
		SE2->(DbSkip())
	EndDo
	RestArea(_aArea)
	Return(_lVolta)
	*
	*************************
User Function MTA103MNU()
	*************************
	*
	*
	* Adicionar a rotina de complementos existente na rotina de NF entrada manual do módulo Fiscal
	* na Rotina de NFentrada do estoque.
	*
	lSped 	:=	AliasIndic("SFU") .And. AliasIndic("SFX") .And. AliasIndic("CD3") .And. AliasIndic("CD4") .And. ;
	AliasIndic("CD5") .And. AliasIndic("CD6") .And. AliasIndic("CD7") .And. AliasIndic("CD8") .And. ;
	AliasIndic("CD9") .And. AliasIndic("CDB") .And. AliasIndic("CDC") .And. AliasIndic("CDD") .And. ;
	AliasIndic("CDE") .And. AliasIndic("CDF") .And. AliasIndic("CDG") .And. cPaisLoc == "BRA"

	If lSped
		Aadd(aRotina,{"Complementos","u_My910Coml()",0,4,0,NIL})
	Endif
	aadd(aRotina,{ "Import.XML", "u_zCbcInXML()",0,2,0,.F.})	
	Return(.T.)
	*
	*************************
User Function My910Coml()
	*************************
	*
	// Posicionar o SD1 dessa nota
	// Esta função é usada em conjunto com a MTA103MNU()
	DbSelectArea("SD1")
	DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
	a910Compl()
	Return(.T.)


	*
	***********************
User Function ArruCD5()
	***********************
	*


	DbSelectArea("SD1")
	DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

	DbSelectArea("CD5")  
	DbSetOrder(4) // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM

	DbSeek(xFilial("CD5"),.F.)

	Do While CD5->CD5_FILIAL == xFilial("CD5") .And. CD5->(!Eof())

		SD1->(DbSeek(xFilial("SD1")+CD5->CD5_DOC+CD5->CD5_SERIE+CD5->CD5_FORNEC+CD5->CD5_LOJA,.F.))
		Do While SD1->D1_FILIAL == xFilial("SD1") .And. SD1->(!Eof()) .And.;
		SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == ;
		CD5->(CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)
			If SD1->D1_ITEM == CD5->CD5_ITEM
				Exit
			EndIf
			SD1->(DbSkip())
		EndDo

		If SD1->D1_FILIAL == xFilial("SD1") .And. SD1->(!Eof()) .And. SD1->D1_ITEM == CD5->CD5_ITEM .And.;
		SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == CD5->(CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA)

			RecLock("CD5",.F.)
			If Empty(CD5->CD5_CODEXP)
				CD5->CD5_CODEXP := SD1->D1_FORNECE+"/"+SD1->D1_LOJA
			EndIf
			If Empty(CD5->CD5_NADIC)
				CD5->CD5_NADIC := SD1->D1_X_ADIC
			EndIf
			If Empty(CD5->CD5_SQADIC)
				CD5->CD5_SQADIC := SD1->D1_X_SQADI
			EndIf
			If Empty(CD5->CD5_CODFAB)
				CD5->CD5_CODFAB := SD1->D1_X_FABR
			EndIf
			If Empty(CD5->CD5_BCIMP)
				CD5->CD5_BCIMP := If(SD1->D1_X_BSII==0.01,0.00,SD1->D1_X_BSII)
			EndIf
			If Empty(CD5->CD5_DSPAD)
				CD5->CD5_DSPAD := SD1->D1_X_DPAD
			EndIf

			If Empty(CD5->CD5_VLRIOF)
				CD5->CD5_VLRIOF := SD1->D1_X_VIOF
			EndIf

			MsUnLock()

			If Empty(SD1->D1_II)
				RecLock("SD1",.F.)
				SD1->D1_II := SD1->D1_X_VLII
				MsUnLock()
			EndIf
		EndIf
		CD5->(DbSkip())
	EndDo
Return(.T.)   


User Function MT103APV()
	Local oArea 	:= SigaArea():newSigaArea()
	Local ogroup 
	Local cGrp		:= ""

	oArea:saveArea({'SF1','SD1'})

	ogroup := groupApprovers():newgroupApprovers()
	If ogroup:haveGroup()
		cGrp := ogroup:getGrpAprov()
	Else
		cGrp := SuperGetMv("MV_NFAPROV")
	endIf

	oArea:backArea()

Return cGrp 
