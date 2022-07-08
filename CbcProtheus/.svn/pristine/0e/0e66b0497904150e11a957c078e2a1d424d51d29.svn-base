#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)



User Function cobrarChq()   //u_cobrarChq()
	//TABELA ZAB

	//CAMPOS
	/*
	ZAB_FILIAL	C	2
	ZAB_CLIENT	C	6
	ZAB_LOJA	C	2
	ZAB_PREFIX	C	3
	ZAB_NUM		C	9
	ZAB_PARC	C	3
	ZAB_TIPO	C	3
	ZAB_NOMCLI	C	20
	ZAB_EMIT	C	60
	ZAB_NUMCHQ	C	10
	ZAB_VALOR   N	17	2
	ZAB_VENC    D	8
	ZAB_HIST    C	20
	ZAB_PRINT   C   2
	*/

	//INDICES

	//DbOrderNickName("CHAVE1")	//ORDEM 1 = ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO
	//DbORderNickName("CHQNUM") //ORDEM 2 = ZAB_FILIAL+ZAB_NUMCHQ
	Local cFiltro

	Private cAlias1		:=  "SE1"
	Private cAlias2		:=	"ZAB"
	Private cCadastro	:=  'Cobrança de cheque devolvido'
	Private oBrowse
	Private oFont 		:= TFont():New( "Arial", , -12, .T.)
	Private aRotina		:=	{}
	Private lAltera

	AAdd(aRotina, {"Pesquisar"		, "" 					, 0,1})
	AAdd(aRotina, {"Visualizar"		, "U_M3INI" 			, 0,2})
	AAdd(aRotina, {"Incluir"		, "" 					, 0,3})
	AAdd(aRotina, {"Alterar"		, "U_M3INI" 			, 0,4})
	AAdd(aRotina, {"Excluir"		, "U_M3INI" 			, 0,5})
	AAdd(aRotina, {"Imprimir"		, "U_M3PRINT" 			, 0,8})
	AAdd(aRotina, {"Debitar"		, "U_M3CT2"				, 0,3})
	AAdd(aRotina, {"Imprimir Dbt"	, "U_M3PRINT" 			, 0,8})


	DbSelectarea("ZAB")
	DbOrderNickName("CHAVE1") 	//ORDEM 1 = ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) 		//ORDEM 2 = E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTop())

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SE1')
	oBrowse:SetFontBrowser(oFont)
	oBrowse:SetDescription('Cobrança de cheque devolvido')

	cFiltro := " E1_FILIAL == " + xFilial('SE1')
	cFiltro	+= " .AND. E1_TIPO == 'CHD'"

	oBrowse:SetOnlyFields({'E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_EMISSAO','E1_VENCTO','E1_VENCREA','E1_VALOR'})
	oBrowse:SetFilterDefault( cFiltro )

	oBrowse:SetMenuDef("CHQDEV")

	oBrowse:AddLegend("SE1->E1_SALDO == 0", "BLUE", "Titulo baixado")
	oBrowse:AddLegend("SE1->(E1_ZZOK) == '01'" , "YELLOW", "Carta de cobrança já impressa")
	oBrowse:AddLegend("ZAB->( DbSeek(xFilial('SE1') + SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ,.F.) )" ,"RED", "Carta de Cobrança OK")
	oBrowse:AddLegend("ZAB->( !DbSeek(xFilial('SE1') + SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ,.F.) )" ,"GREEN", "Falta carta de cobrança")


	oBrowse:Activate()

	Return nil

	*****************************
Static Function MenuDef()
	*****************************
	//Definições de menu e funões chamadas
	Local aRotina := {}                     

	ADD OPTION aRotina TITLE 'PESQUISAR' 		ACTION 'U_M3INI("","",1)' OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'VISUALIZAR' 		ACTION 'U_M3INI("","",2)' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'INCLUIR' 			ACTION '' 				  OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'ALTERAR' 			ACTION 'U_M3INI("","",4)' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'EXCLUIR' 			ACTION 'U_M3INI("","",5)' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'IMPRIMIR' 		ACTION 'U_M3PRINT()' 	  OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'DEBITAR'			ACTION 'U_M3CT2()'		  OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'IMPRIMIR DBT'		ACTION 'U_M3PRINT()' 		OPERATION 8 ACCESS 0

	Return aRotina


	*******************************************
User Function M3INI(cAlias,nRecno,nOpc)
	*******************************************
	Local 	i 				:= 0
	Local   cLinOK			:= "AllwaysTrue"
	Local	cTudoOK			:= "U_M3TudoOK"
	Local	nOpcE			:= nOpc
	Local	nOpcG			:= nOpc
	Local	cFieldOK		:= "AllwaysTrue"
	Local 	lVirtual    	:= .T.
	Local 	nLinhas			:= 99
	Local 	nFreeze			:= 0
	Local	lRet			:= .T.

	Private aCols			:= {}
	Private	aHeader			:= {}
	Private aCpoEnchoice	:= {}
	Private aAltEnchoice	:= {}
	Private aAlt			:= {}

	RegToMemory(cAlias1, (nOpc==3) )
	RegToMemory(cAlias2, (nOpc==3) )

	CriaHeader()
	CriaCols(nOpc)

	lRet := Modelo3(	cCadastro , cAlias1, cAlias2, aCpoEnchoice, cLinOK, cTudoOK, nOpcE, ;
	nOpcG, cFieldOK, lVirtual,nLinhas, aAltEnchoice, nFreeze )

	If lRet

		If nOpc == 3

			If MsgYesNo("Confirma alteracao dos dados?", cCadastro)
				Processa({|| GrvDados() }, cCadastro, "Alterando os dados, aguarde...")
			EndIF

		ElseIf nOpc == 4

			If MsgYesNo("Confirma alteracao dos dados?", cCadastro)
				Processa({|| GrvDados() }, cCadastro, "Alterando os dados, aguarde...")
			EndIF

		ElseIf nOpc == 5

			If MsgYesNo("Confirma alteracao dos dados?", cCadastro)
				Processa({|| GrvDados() }, cCadastro, "Alterando os dados, aguarde...")
			EndIF
		EndIf

	Else
		RollBackSX8()
	EndIF

	Return Nil

	*********************************
Static Function GrvDados()
	*********************************
	Local i			:= 0
	Local y			:= 0
	Local nItem		:= 0

	ProcRegua(Len(aCols) + FCount() )

	DbSelectArea(cAlias2)
	DbOrderNickName("CHAVE1")
	nItem := Len(aAlt) + 1

	For i := 1 To Len(aCols)
		IncProc()


		If i <= Len(aAlt)

			DbGoTo(aAlt[i])
			RecLock(cAlias2, .F.)

			If aCols[i][Len(aHeader)+1]
				DbDelete()
			Else
				For y := 1 To Len(aHeader)
					FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
				Next
			EndIf
			MsUnlock()
		Else

			If !aCols[i][Len(aHeader)+1] //Linha não esta deletada
				RecLock(cAlias2, .T.)

				ZAB->ZAB_FILIAL 	:= SE1->E1_FILIAL
				ZAB->ZAB_CLIENT		:= SE1->E1_CLIENTE
				ZAB->ZAB_LOJA		:= SE1->E1_LOJA
				ZAB->ZAB_PREFIX 	:= SE1->E1_PREFIXO
				ZAB->ZAB_NUM		:= SE1->E1_NUM
				ZAB->ZAB_PARC		:= Alltrim(SE1->E1_PARCELA)
				ZAB->ZAB_TIPO		:= SE1->E1_TIPO
				ZAB->ZAB_NOMCLI     := SE1->E1_NOMCLI

				For y := 1 To Len(aHeader)
					FieldPut(FieldPos(Trim(aHeader[y][2])) , aCols[i][y]) 
				Next

				MsUnlock()
				nItem++
			EndIF

		EndIf

	Next

	Return Nil


	//GRAVA E GERA O CONTA_CORRENTE
	*********************************
User Function M3CT2()
	*********************************
	Local aArea		:= GetArea()
	Local cSql		:= ''
	Local nRelat    := GetSXENum("ZAB","ZAB_RELAT","01ZAB010")
	Local nTotCt2	:= 0
	Local aItens	:= {}
	Local aCab		:= {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.


	DbSelectarea("ZAB")
	DbOrderNickName("CHAVE1") 	//ORDEM 1 = ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) 		//ORDEM 2 = E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	//REALIZA O LANÇAMENTO NO CT2 DE TODOS OS TITULOS CHD QUE TENHA REGISTRO NO ZAB E O CAMPO ZAB_RELAT ESTEJA VAZIO
	//AO GERAR O CT2, DEVE-SE ADICIONAR O NUMERO SEQUENCIAL DO REL. CHEQUE DEVE SER SEQUENCIAL DO CAMPO ZAB_RELAT


	//Fechar e excluir arquivo de trabalho
	If Select( "SE1CHD") > 0
		SE1CHD->(dbcloseArea())
		FErase( "SE1CHD" + GetDbExtension())
	End If

	cSQL := "AND SE1.E1_TIPO = 'CHD'"
	cSQL += "AND ZAB.ZAB_RELAT = ''"
	cSQL := "%"+cSQL+"%"

	//Consulta no banco
	//Selecionar os titulos no SE1 que tenham registro no ZAB (INNER JOIN) e que o tipo seja CHD
	BeginSQL Alias "SE1CHD"

	SELECT DISTINCT(SE1.R_E_C_N_O_), SE1.E1_VALOR

	FROM %Table:SE1% SE1

	INNER JOIN %Table:ZAB% ZAB ON	SE1.E1_FILIAL		= ZAB.ZAB_FILIAL
	AND SE1.E1_CLIENTE	= ZAB.ZAB_CLIENT
	AND SE1.E1_LOJA		= ZAB.ZAB_LOJA
	AND SE1.E1_PREFIXO	=  ZAB.ZAB_PREFIX
	AND SE1.E1_NUM		= ZAB.ZAB_NUM
	AND SE1.E1_PARCELA	= ZAB.ZAB_PARC
	AND SE1.E1_TIPO		= ZAB.ZAB_TIPO

	WHERE SE1.%NotDel% %Exp:cSQL%

	EndSql

	DbSelectArea("SE1CHD")
	SE1CHD->(DbGotop())

	//Retorna quando nenhum titulo SE1 tiver correspondente no ZAB, com ZAB_RELAT vazio
	If SE1CHD->(eof())
		RollbackSX8()
		MessageBox("Nenhum titulo de cheque devolvido encontrado","Aviso",48)
		Return nil
	EndIf

	Begin Transaction

		While SE1CHD->(!Eof())

			//Posiciona no registro
			SE1->( dbgoto( SE1CHD->(R_E_C_N_O_)  ) )

			//Procura correspondente no ZAB
			If ZAB->( DbSeek(xFilial('SE1') + SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ,.F.) )

				//Altera o campo fixando o numero do relatorio, que será lançado no conta-corrente
				While ZAB->(ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO) == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

					reclock("ZAB", .F.)
					ZAB->ZAB_RELAT 	:= nRelat
					ZAB->(msunlock())
					ZAB->(DbSkip())

				EndDo

				nTotCt2 += SE1->E1_VALOR //TOTALIZAR VALOR PARA C/C

			EndIf

			SE1CHD->(DbSkip())

		EndDo

		//REALIZAR LANÇAMENTO CONTA_CORRENTE

		//Cria o cabeçalho para o lançamento
		aCab := { 	{'DDATALANC' 	,dDataBase 	,NIL},;
		{'CLOTE' 		,"028850" 	,NIL},;
		{'CSUBLOTE' 	,'001' 		,NIL},;
		{'CDOC' 		, nRelat 	,NIL},;
		{'CPADRAO' 		,'' 		,NIL},;
		{'NTOTINF' 		,0 			,NIL},;
		{'NTOTINFLOT' 	,0 			,NIL} }

		//Adiciona os Iitens no array para lançamento

		aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")				, NIL},;
		{'CT2_LINHA'  	, StrZero(1,3) 				, NIL},;
		{'CT2_MOEDLC'  	,'01'   					, NIL},;
		{'CT2_DC'   	,'3'   						, NIL},;
		{'CT2_DEBITO'  	,'DEB' 						, NIL},;
		{'CT2_CREDIT'  	,'CRE' 						, NIL},;
		{'CT2_VALOR'  	, nTotCt2  					, NIL},;
		{'CT2_ORIGEM' 	,'CTBBORDRECEBER'			, NIL},;
		{'CT2_HP'   	,''   						, NIL},;
		{'CT2_EMPORI'   ,'01'   					, NIL},;
		{'CT2_FILORI'   ,XFilial("SE1")   			, NIL},;
		{'CT2_TPSALD'   ,'6'   						, NIL},;
		{'CT2_CLVLCR'   ,'1101'   					, NIL},; 
		{'CT2_HIST'   	,'CHEQUE DEVOLVIDO.NRO ' + nRelat    , NIL} } )

		//terceiro parametro do CTBAL102
		//1=Pesquisa
		//2=Visualização
		//3=Inclusão
		//4=Alteração
		//5=Exclusão

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
            
		If lMsErroAuto  
			DisarmTransaction()
			RollbackSX8()
			MOSTRAERRO()
		EndIf
	
	End Transaction

	//Confirma o numero sequencial
	confirmSx8()
	ApMsgInfo( 'Relatorio de cheques devolvidos  Nro. ' + nRelat + ' gerado com sucesso!.' )

	//Finaliza o arquivo de trabalho utilizado
	SE1CHD->(dbcloseArea())
	FErase( "SE1CHD" + GetDbExtension())

	RestArea(aArea)
	Return Nil

	//##############################################ROTINAS DE RELATORIOS

	*********************************
User Function M3PRINT()
	*********************************
	Local oReport
	Local oFonteRel := TFont():New( "Arial", , 08, .T.)
	Local aBox		:={}
	Local aRet		:={}
	Private cRelat	:= ""
	Private lCob	:= .F.

	DbSelectarea("ZAB")
	DbOrderNickName("CHAVE1") 	//ORDEM 1 = ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO

	aAdd(aBox,{3,"Informe o tipo do relatorio",1,{"Cobrança","BxDbt"},50,"",.T.})
	// Tipo 3 -> Radio
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do Radio
	//           [4]-Array contendo as opcoes do Radio
	//           [5]-Tamanho do Radio
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	If ParamBox(aBox,"Tipo do relatorio...",@aRet)

		//RADIO SELECIONADO È COBRANÇA
		If aRet[1] == 1

			lCob := .T.

		EndIF

	EndIf

	//Se não for relatorio de cobrança, pede numero relatorio cheque devolvido
	If !lCob
		//zera para um novo parambox
		aBox 	:= {}
		aRet	:={}

		aAdd(aBox,{1,"Nro. Relatorio"  ,Space(6),"","","","",50,.T.}) 

		If ParamBox(aBox,"Numero Relatorio...",@aRet)

			cRelat := aRet[1]

		EndIf
	EndIf

	//Cria o objeto relatorio
	oReport := ReportDef()

	//Configurações do relatorio
	oReport:OFONTBODY 	:= oFonteRel 	//Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 08 			//Tamanho da Fonte
	oReport:NLINEHEIGHT := 40 			//Altura da linha
	oReport:SetLandScape()				//Orientação da paginas
	//oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	oReport:SetTotalText("Valor Total")						//Definir a string que será mostrada no total
	oReport:PrintDialog()									//Tela para configuração de impressão

	Return Nil


	*
	***************************
Static Function ReportDef()
	***************************
	*
	Local oReport
	Local oSection1
	Local oSection2
	Local oSection3

	//RELATORIO DE COBRANÇA
	If lCob


		oReport := TReport():New("Cheques Devolvidos","Carta Cobranca Cheques devolvidos " + AllTrim(SE1->E1_NUM) 	,"CHQDEVOLV",{|oReport| PrintReport(oReport)},"Cheques Devolvidos")

	Else

		oReport := TReport():New("Cheques Devolvidos","Relatorio Nr." + cRelat 					,"CHQDEVOLV",{|oReport| PrintReport(oReport)},"Cheques Devolvidos")


	EndIF

	//Defini as sessões que teremos no relatorio
	oSection1 := TRSection():New(oReport,"Cheques" 			,"ZAB")
	oSection2 := TRSection():New(oReport,"Msg" 				,"ZAB")
	oSection3 := TRSection():New(oReport,"Msg1" 			,"ZAB")

	//Tipo de dados para a Sessão1 na tela com base no SX3
	TRCell():New(oSection1,"ZAB_NOMCLI"			,"ZAB","CLIENTE")
	TRCell():New(oSection1,"ZAB_EMIT"			,"ZAB","EMITENTE")
	TRCell():New(oSection1,"ZAB_BANCO"			,"ZAB","BANCO")
	TRCell():New(oSection1,"ZAB_NUMCHQ"			,"ZAB","Nro.CHEQUE")
	TRCell():New(oSection1,"ZAB_VALOR"			,"ZAB","VALOR")
	TRCell():New(oSection1,"ZAB_VENC"			,"ZAB","VENC")


	//Tipo de dados para a Sessao02 criada com os parametros sem dicioanario
	TRCell():New(oSection2,"Msg" 				,"" ,"" ,"@!"/*Picture*/,80/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"LEFT",.T.,"LEFT")
	//Tipo de dados para a Sessão03 criada com os parametros sem dicioanario
	TRCell():New(oSection3,"Msg1" 				,"" ,"" ,"@!"/*Picture*/,80/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"LEFT",.T.,"LEFT")

	//Cria as funçõees utilizadas no caso a conta dos registros e a soma do valor total
	TRFunction():New(oSection1:Cell("ZAB_VALOR"),NIL,"SUM"	,NIL,"                       Valor Total dos Titulos......."	,NIL,NIL,.F.,.T.,.F.)

	TRFunction():SetEndSection(.T.)

	//Devolve o relatorio com estrutura de dados formada
	Return oReport


	**************************************
Static Function PrintReport(oReport)
	**************************************

	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)
	Local cFiltro   	:= ""
	Local cSQL			:= ""
	Local cCabec		:= ""
	Local cCabec1		:= ""
	Local nSizeLin 		:= 180

	Local cFunc 		:= Space(20) 	+ Padr(Alltrim(Upper(cUserName)),30)
	Local cDir 			:= Space(15)  	+ "RAFAEL V. RUAS / GUSTAVO V. RUAS" 
	Local cCoord		:= Space(20)	+ "(CONFERIDO)-BRUNO H. BITTAR" 

	Local cLinAssi		:= Space(10) + Padr("",40,"_")

	Local cDeptFun    	:= Space(20) + "DEPTO.COBRANCA" 	  + Space(20) 		 
	Local cDeptDir		:= Space(20) + "DIRETORIA " 		  + Space(20)		 
	Local cDeptCoord  	:= Space(20) + "COORD. FINANCEIRO   " + Space(20)


	//Relatorio não cobrança, filtro pelo numero ZAB_RELAT
	If !Empty(cRelat)  .AND. !lCob

		cSQL += " AND ZAB.ZAB_RELAT 		=  '" + cRelat 		+ "' "


	Else

		//Where do select com base nos parametros
		cSQL += " AND ZAB.ZAB_FILIAL 	=  '" + AllTrim(SE1->E1_FILIAL) 	+ "' "
		cSQL += " AND ZAB.ZAB_CLIENT 	=  '" + AllTrim(SE1->E1_CLIENTE) 	+ "' "
		cSQL += " AND ZAB.ZAB_LOJA 		=  '" + AllTrim(SE1->E1_LOJA) 		+ "' "
		cSQL += " AND ZAB.ZAB_PREFIX 	=  '" + AllTrim(SE1->E1_PREFIXO) 	+ "' "
		cSQL += " AND ZAB.ZAB_NUM 		=  '" + AllTrim(SE1->E1_NUM) 		+ "' "
		cSQL += " AND ZAB.ZAB_PARC 		=  '" + AllTrim(SE1->E1_PARCELA) 	+ "' "
		cSQL += " AND ZAB.ZAB_TIPO 		=  '" + AllTrim(SE1->E1_TIPO) 		+ "' "

	EndIF

	//Cria a variavel da clausula where
	cSQL := "%"+cSQL+"%"

	//Realiza a query para obter as informações do relatorio
	oSection1:BeginQuery()

	BeginSql alias "QRYCHQ"

	SELECT	ZAB.ZAB_NOMCLI, ZAB.ZAB_EMIT, ZAB.ZAB_BANCO, ZAB.ZAB_NUMCHQ,
	ZAB.ZAB_VALOR, ZAB.ZAB_VENC
	FROM %table:ZAB% ZAB
	WHERE ZAB.%NotDel% %Exp:cSQL%
	ORDER BY ZAB.ZAB_VENC
	EndSql


	//RELATROIO COBRANÇA
	If lCob
		cCabec = 	"ITU, " + cValToChar(Day(Date())) + " de "  + Upper(MesExtenso()) + " de " + cValToChar(Year(Date()) ) + "                                        "
		cCabec +=	"A " + AllTrim(SE1->(E1_NOMCLI))

		//Utilizado para legendar os que foram impressos primeira vez
		reclock("SE1", .F.)
		SE1->E1_ZZOK := "01" //Marca para filtro amarelo
		SE1->(Msunlock())
		SE1->(DbSkip())

	EndIF

	oSection1:EndQuery()

	//RELATORIO DE COBRANÇA
	If lCob

		//Preencher as informaçõeses na sessão 02 do relatorio
		oSection2:Init()
		oSection2:ACELL[1]:UVALUE := cCabec
		oSection2:ACELL[1]:LBOLD := .T.
		oSection2:ACELL[1]:LCELLBREAK := .T.
		oSection2:PrintLine()
		oSection2:Finish()

	EndIF

	//RELATORIO DE COBRANÇA
	oSection1:Print()

	oSection3:Init()

	If lCob

		oSection3:ACELL[1]:LCELLBREAK := .T.	

		cCabec1 +=	"                                                                                "
		cCabec1 = 	"Favor providenciar o recebimento do(s) cheque(s) acima com a maxima urgência.   "
		cCabec1 +=	"Sem mais, agradecemos                                                           "
		cCabec1 +=	"                                                                                "
		cCabec1 +=  "ATENCIOSAMENTE                                                                  "
		cCabec1 +=	"                                                                                "
		cCabec1 +=  "DENISE AP PEREIRA BONANNI                                                       "
		cCabec1 +=  "Depto Cobrança                                                                  "

	Else                                                                  	  
		oSection3:ACELL[1]:LCELLBREAK 	:= .F. 
		oSection3:ACELL[1]:NSIZE		:= nSizeLin

		cCabec1 += CRLF+CRLF
		//cCabec1 += CRLF+CRLF
		cCabec1 += cLinAssi + cLinAssi 	+ cLinAssi  	+ CRLF
		cCabec1 += cFunc 	+ cDir 		+ cCoord 		+ CRLF
		cCabec1 += cDeptFun + cDeptDir 	+ cDeptCoord 	+ CRLF

	EndIf	

	oSection3:ACELL[1]:UVALUE := cCabec1
	oSection3:ACELL[1]:LBOLD := .T.
	oSection3:PrintLine()
	oSection3:Finish()


	Return

	*********************************
User Function M3TudoOK()
	*********************************
	//Validações Loop no aCols Verificar total cheque maior que titulo
	Local lRet 	:= .T.
	Local nSoma := 0

	For i := 1 To Len(aCols)
		If !aCols[i][Len(aHeader)+1] //Linha não esta deletada

			For y := 1 To Len(aHeader)

				IF Trim(aHeader[y][2]) == "ZAB_VALOR"

					nSoma += aCols[i][y]

				EndIf

			Next y
		EndIf

	Next i

	If nSoma > SE1->(E1_VALOR)

		MessageBox("AVISO","VALOR TOTAL DOS CHEQUES R$" + cValToChar(nSoma) + CRLF +;
		"NÂO PODE SER MAIOR QUE O TOTAL DO TITULO R$ " + cValToChar(SE1->E1_VALOR),48)
		lRet := .F.

	ElseIf nSoma < SE1->(E1_VALOR)

		lRet := ApMsgYesNo("SOMA DOS CHEQUES È MENOR QUE O VALOR DO TITULO, DESEJA CONTINUAR?")

	EndIf

	Return lRet

	****************************************
Static Function CriaHeader()
	****************************************

	aHeader:= {}
	aCpoEnchoice := {}
	aAltEnchoice :={}

	dbselectarea("SX3")

	dbsetorder(1)

	dbseek(cAlias2)

	while !eof() .and. x3_arquivo == cAlias2

		if x3uso(x3_usado) .and. cnivel >= x3_nivel

			aAdd(aHeader,{trim(x3_titulo),;
			x3_campo,;
			x3_picture,;
			x3_tamanho,;
			x3_decimal,;
			x3_valid,;
			x3_usado,;
			x3_tipo,;
			x3_arquivo,;
			x3_context} )

		endif

		dbskip()

	enddo

	dbseek(cAlias1)

	while !eof() .and. x3_arquivo == cAlias1

		if x3uso(x3_usado) .and. cnivel >= x3_nivel

			aAdd(aCpoEnchoice,x3_campo)

			aAdd(aAltEnchoice,x3_campo)

		endif

		dbskip()

	enddo

	return


	****************************************
Static function CriaCols(nOpc)
	****************************************

	Local nQtdcpo := 0
	Local i:= 0
	Local nCols := 0

	nQtdcpo := len(aHeader)
	aCols:= {}
	aAlt := {}

	if nOpc == 3

		aAdd(aCols,array(nQtdcpo+1))

		for i := 1 to nQtdcpo

			aCols[1,i] := Criavar(aHeader[i,2])

		next i

		aCols[1,nQtdcpo+1] := .F.

	else

		dbselectarea(cAlias2)		//DbSelectarea("ZAB")
		DbOrderNickName("CHAVE1") 	//ORDEM 1 = ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO


		//cAlias1	=  "SE1"
		//cAlias2	= "ZAB"
		//ORDEM SE1 = E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		dbseek((cAlias1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), .F. )

		while .not. eof() .and. (cAlias2)->(ZAB_FILIAL+ZAB_CLIENT+ZAB_LOJA+ZAB_PREFIX+ZAB_NUM+ZAB_PARC+ZAB_TIPO)  ==  (cAlias1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

			aAdd(aCols,array(nQtdcpo+1))

			nCols++

			for i:= 1 to nQtdcpo

				if aHeader[i,10] <> "V"

					aCols[nCols,i] := Fieldget(Fieldpos(aHeader[i,2]))

				else

					aCols[nCols,i] := Criavar(aHeader[i,2],.T.)

				endif

			next i

			aCols[nCols,nQtdcpo+1] := .F.

			aAdd(aAlt,Recno())

			dbselectarea(cAlias2)

			dbskip()

		enddo

	endif

return
