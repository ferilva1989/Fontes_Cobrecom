#include "protheus.ch"

*
***************************
User Function CDFINRSP(cNroBor)
	***************************
	*

	Local oReport
	Local cPerg 	:= "RELBORSP"
	Local oFonteRel := TFont():New( "Arial", , 08, .T.)
	Local aBox		:={}
	Local aRet		:={}
	Private lSP		:= .F.
	Private cBord

	//Verifica se a Lib suporta o recurso Treport
	//If TRepInUse() N¬O FUNCIONA NA FILIAL

	//CHAMADA AUTOMATICA OU COM PARAMETRO

	If Empty(cNroBor)
		//Pergunta para obter os paramtros
		CriaSX1(cPerg)
		Pergunte(cPerg, .T.)

		cBord := mv_Par01

	Else
		cBord := cNroBor

	EndIf

	//S¬O PAULO PRECISA FILTRAR TITULOS DO BORDERO QUE AINDA N¬O EST¬O EM BANCO (E1_NUMBOR VAZIO e E1_PORTADO VAZIO)
	If U_vlsUsrSP()

		aAdd(aBox,{3,"Imprimir somente titulos que N¬O est„o em banco?",1,{"Sim","N„o"},50,"",.T.})
		// Tipo 3 -> Radio
		//           [2]-Descricao
		//           [3]-Numerico contendo a opcao inicial do Radio
		//           [4]-Array contendo as opcoes do Radio
		//           [5]-Tamanho do Radio
		//           [6]-Validacao
		//           [7]-Flag .T./.F. Parametro Obrigatorio ? 

		If ParamBox(aBox,"Filtrar titulo que n„o est„o em banco...",@aRet)

			//RADIO SELECIONADO » SIM
			If aRet[1] == 1

				lSP := .T.

			EndIF

		EndIf

	EndIf

	//Cria o objeto relatorio
	oReport := ReportDef()

	//ConfiguraÁıes do relatorio
	oReport:OFONTBODY 	:= oFonteRel 	//Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 08 			//Tamanho da Fonte
	oReport:NLINEHEIGHT := 40 			//Altura da linha
	oReport:SetPortrait()				//OrientaÁ„o da paginas
	oReport:SetTotalInLine(.F.)

	oReport:SetTotalText("Qtd Titulos / Valor Total")		//Definir a string que ser· mostrada no total
	oReport:PrintDialog()									//Tela para configura√ß√£o de impress√£o
	//EndIf
	Return


	*
	***************************
Static Function ReportDef()
	***************************
	*

	Local oReport
	Local oSection1
	Local oSection2

	oReport := TReport():New("Bordero SP","Bordero de TItulos SP - N.  " + AllTrim(cBord) ,"RELBORDSP",{|oReport| PrintReport(oReport)},"Bordero de Titulos")

	//Defini as sess√µes que teremos no relatorio
	oSection1 := TRSection():New(oReport,"Titulos" 			,"SE1")
	oSection2 := TRSection():New(oReport,"De" 				,"SE1")


	//TRCell():New(oSection1,"MOVIM_01" ,"" ,/*Titulo*/ ,"@E 99,999,999.99"/*Picture*/,14/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/,"RIGHT",,"RIGHT")

	//Tipo de dados para a Sess„01 na tela com base no SX3
	TRCell():New(oSection1,"E1_PREFIXO"			,"SE1","NUM")
	TRCell():New(oSection1,"E1_NUM"				,"SE1","DUPLIC")
	TRCell():New(oSection1,"E1_PARCELA"			,"SE1","PRC")
	TRCell():New(oSection1,"E1_EMISSAO"			,"SE1","EMISSAO")
	TRCell():New(oSection1,"E1_CLIENTE"			,"SE1","CODIGO")
	TRCell():New(oSection1,"A1_NOME"			,"SA1","RAZAO SOCIAL",,,,,,.T.) //Para quebra de linha automatica
	TRCell():New(oSection1,"E1_VENCTO"			,"SE1","VENCTO")
	TRCell():New(oSection1,"E1_VALOR"			,"SE1","VALOR",,,,,"RIGHT",.T.,"RIGHT")

	//Tipo de dados para a Sess√£o02 criada com os parametros sem dicioanario
	TRCell():New(oSection2,"De" 				,"" ,"" ,"@!"/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"LEFT",.T.,"LEFT")

	/*
	TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)

	Onde:
	lEndSection Imprime o totalizador na quebra de sess„oo se .T.
	lEndReport   Imprime o totalizador no final do relatÛrio se .T.
	lEndPage     Imprime o totalizador no final de cada pagina se .T.

	*/
	//Cria as fun√ß√µes utilizadas no caso a conta dos registros e a soma do valor total
	TRFunction():New(oSection1:Cell("E1_VALOR"),NIL,"COUNT"	,NIL,"                       Quantidade de Titulos........."	,NIL,NIL,.F.,.T.,.F.)
	TRFunction():New(oSection1:Cell("E1_VALOR"),NIL,"SUM"	,NIL,"                       Valor Total dos Titulos......."	,NIL,NIL,.F.,.T.,.F.)

	//Devolve o relatorio com estrutura de dados formada
	Return oReport

	**************************************
Static Function PrintReport(oReport)
	**************************************

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local cFiltro   	:= ""
	Local cSQL			:= ""
	Local cCabec		:= ""

	//VERIFICA SE DEVE IMPRIMIR SOMENTE TITULOS DO BORDERO QUE N¬O ESTAO EM BANCO OU TODOS DO BORDERO
	If lSP

		cSQL += " AND SE1.E1_ZZBOR1  =  '" + AllTrim(cBord) + "' "
		cSQL += " AND SE1.E1_NUMBOR  = ''  	"
		cSQL += " AND SE1.E1_PORTADO = '' 	"

	Else

		//Where do select com base nos parametros
		cSQL += " AND SE1.E1_ZZBOR1 =  '" + AllTrim(cBord) + "' "

	EndIF

	//Cria a variavel da clausula where
	cSQL := "%"+cSQL+"%"

	//Realiza a query para obter as informaÁıes do relatorio
	oSection1:BeginQuery()

	BeginSql alias "QRYBORDSP"

	SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_EMISSAO,
	SE1.E1_CLIENTE, SA1.A1_NOME, SE1.E1_VENCTO, SE1.E1_VALOR,
	SE1.E1_ZZBOR1
	FROM %table:SE1% SE1
	INNER JOIN %table:SA1% SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA
	WHERE SE1.E1_FILIAL = %xFilial:SE1% AND SE1.%NotDel% AND SA1.%NotDel% %Exp:cSQL%
	ORDER BY SE1.E1_VENCTO
	EndSql


	cCabec = 		"DE: RAFAEL/GUSTAVO                                                    "
	cCabec +=		"PARA: JACKSON                                                         "
	cCabec +=		"ASSUNTO: DUPLICATAS                                                   "
	cCabec +=		"Solicitamos proceder o recebimento das duplicatas abaixo relacionadas "
	cCabec += 		"CREDITANDO-NOS os valores correspondentes.                            "

	If lSP

		cCabec += 	"                                                                      "
		cCabec += 	"SOMENTE OS TITULOS QUE N¬O EST¬O EM BANCO                             "

	EndIf

	oSection1:EndQuery()

	//Preencher as informaÁıeses na sess„o 02 do relatorio
	oSection2:Init()
	oSection2:ACELL[1]:UVALUE := cCabec
	oSection2:ACELL[1]:LBOLD := .T.
	oSection2:ACELL[1]:LCELLBREAK := .T.
	oSection2:PrintLine()
	oSection2:Finish()

	//oSection2:SetParentQuery()
	//oSection2:SetParentFilter({|cParam| QRYSA3->A1_VEND >= cParam .and. QRYSA3->A1_VEND <= cParam},{|| QRYSA3->A3_COD})
	oSection1:Print()

	Return

	//FunÁ„oo para Criar as perguntas
	****************************************************************
Static Function CriaSX1(cPerg)
	****************************************************************

	Local aHelp :={}

	AAdd(aHelp, { {"Informe o numero inicial do Bordero SP"}, {""},{""} }  )
	//AAdd(aHelp, { {"Informe o numero final do Bordero SP"}, {""},{""} }  )

	PutSX1(cPerg,"01","Numero do Bordero              ?","","","mv_ch1","C",06,00,00,"G","","","","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	//PutSX1(cPerg,"02","At√© o Border√¥                ?","","","mv_ch2","C",06,00,00,"G","","","","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

Return
