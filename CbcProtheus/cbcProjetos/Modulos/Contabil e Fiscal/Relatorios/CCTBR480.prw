#Include "CTBR480.Ch"
#Include "PROTHEUS.Ch" 
#Include "TOPCONN.CH" 

#DEFINE TAM_VALOR	17
#DEFINE TAM_CONTA  17   

STATIC __lBlind  := IsBlind()

//AMARRACAO DE PACOTE
// 17/08/2009 -- Filial com mais de 2 caracteres

User Function CCtbr480(cItemIni, cItemFim, dDataIni, dDataFim, cMoeda, cSaldo, cBook, cContaIni,; 
			cContaFim, lCusto, cCustoIni, cCustoFim, lCLVL,	cCLVLIni, cCLVLFim,lSalLin,aSelFil)

Local aArea			:= GetArea()
Local cPerg			:= "CTR480"
Local lImpRazR4 	:= TRepInUse()
Local lExterno		:= cContaIni <> Nil
Local lOk	  		:= .T.  

Private nSldDTransp	:= 0 // Variaveis utilizadas para calcular o valor de transporte entre contas
Private nSldATransp := 0
Private NomeProg 	:= "CTBR480"
Default lCusto		:= .T.
Default lCLVL		:= .T.   
Default lSalLin		:= .T.
Default aSelFil 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Do Item Contabil                      ³
//³ mv_par02            // Ate o Item Contabil                   ³
//³ mv_par03            // da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Moeda			                     ³   
//³ mv_par06            // Saldos		                         ³   
//³ mv_par07            // Set Of Books                          ³
//³ mv_par08            // Analitico ou Resumido dia (resumo)    ³
//³ mv_par09            // Imprime conta sem movimento?          ³
//³ mv_par10            // Imprime Cod (Normal / Reduzida)       ³
//³ mv_par11            // Totaliza tb por Conta?                ³
//³ mv_par12            // Da Conta                              ³
//³ mv_par13            // Ate a Conta                           ³
//³ mv_par14            // Imprime Centro de Custo?		         ³	
//³ mv_par15            // Do Centro de Custo                    ³
//³ mv_par16            // Ate o Centro de Custo                 ³
//³ mv_par17            // Imprime Classe de Valor?              ³	
//³ mv_par18            // Da Classe de Valor                    ³
//³ mv_par19            // Ate a Classe de Valor                 ³
//³ mv_par20            // Salta folha por Item?                 ³
//³ mv_par21            // Pagina Inicial                        ³
//³ mv_par22            // Pagina Final                          ³
//³ mv_par23            // Numero da Pag p/ Reiniciar            ³	   
//³ mv_par24            // Imprime Cod. CCusto(Normal/Reduzido)  ³
//³ mv_par25            // Imprime Cod. Item (Normal/Reduzido)   ³
//³ mv_par26            // Imprime Cod. Cl.Valor(Normal/Reduzido)³	   	    
//³ mv_par27            // Imprime Valor 0.00				 	 ³	   	   
//³ mv_par28            // Salta linha            				 ³	   	   
//³ mv_par29            // Seleciona filiais ?				     ³	   	   
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	lOk := .F.
EndIf

If lOk 
	
	If !lExterno
		If ! Pergunte(cPerg, .T. )
			lOk := .F.
		Endif
		
		// Se aFil nao foi enviada, exibe tela para selecao das filiais
		If lOk .And. mv_par29 == 1 .And. Len( aSelFil ) <= 0
			aSelFil := AdmGetFil()
			If Len( aSelFil ) <= 0
				lOk := .F.
			EndIf 
		EndIf   
		
	Else
		Pergunte(cPerg, .F.)
	Endif

	If !lExterno
		lCusto	:= Iif(mv_par14 == 1,.T.,.F.)
		lCLVL	:= Iif(mv_par17 == 1,.T.,.F.)
	Else //Caso seja externo, atualiza os parametros do relatorio com os dados passados como parametros.
		mv_par01 := cItemIni
		mv_par02 := cItemFim
		mv_par03 := dDataIni
		mv_par04 := dDataFim
		mv_par05 := cMoeda
		mv_par06 := cSaldo
		mv_par07 := cBook
		mv_par12 := cContaIni
		mv_par13 := cContaFim
		mv_par14 := If(lCusto,1,2)
		mv_par15 := cCustoIni
		mv_par16 := cCustoFim
		mv_par17 := If(lClVl,1,2)
		mv_par18 := cClVlIni
		mv_par19 := cClVlFim
		MV_PAR28 := Iif(lSalLin,1,2)
		mv_par09 := 2
		
		If Empty( mv_par01 ) .And. Empty( mv_par02 )      
			Help(" ",1,"CTR480IT",,STR0040 )//"Nao ha dados a exibir, Item de - Item Ate em branco"
			lOk := .F.
		ENDIF  
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se usa Set Of Books -> Conf. da Mascara / Valores   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Ct040Valid(mv_par07)
		lOk := .F.
	EndIf
	
	If lOk
		aCtbMoeda := CtbMoeda(mv_par05)
		If Empty(aCtbMoeda[1])
			Help(" ",1,"NOMOEDA")
			lOk := .F.
		Endif
	Endif
EndIF

If lOk	
	If lImpRazR4
		U_R480R4(cPerg,lCusto, lCLVL,aCtbMoeda,aSelFil)	
	Else
		U_R480R3(cItemIni, cItemFim, dDataIni, dDataFim, cMoeda, cSaldo, cBook, cContaIni,; 
				cContaFim, lCusto, cCustoIni, cCustoFim, lCLVL,	cCLVLIni, cCLVLFim,lSalLin,aSelFil)
	EndIf
EndIf


If Select("cArqTmp") > 0
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()

	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf
EndIf	

RestArea(aArea)
Return   
           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr480R4³ Autor ³ Gustavo Henrique  	³ Data ³ 01/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao dos lanc. gerados pela rotina de apurac. c/ cta pte³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctbr480R4()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 	     ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function R480R4( cPerg,lCusto, lCLVL,aCtbMoeda,aSelFil)
Local oReport
	oReport := ReportDef( cPerg, lCusto, lCLVL, aCtbMoeda, aSelFil )
	oReport:PrintDialog()
	oReport := Nil
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Gustavo Henrique      ³ Data ³01/09/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo usuario.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef( cPerg, lCusto, lCLVL, aCtbMoeda, aSelFil )

	Local oBreak
	Local oDifLanc   
	Local oLote    
	Local oReport
	
	Local aSetOfBook := CTBSetOf(mv_par07)// Set Of Books	
	
	Local cPicture 		:= aSetOfBook[4]
	Local cDescMoeda 	:= aCtbMoeda[2]
	Local cSayCusto		:= CtbSayApro("CTT")
	Local cSayItem		:= CtbSayApro("CTD")
	Local cSayClVl		:= CtbSayApro("CTH")
	Local cTitulo		:= STR0006 + Alltrim(cSayItem)	//"Emissao do Razao Contabil por Item"
	Local cDescricao	:= ""
	
	Local aTamItem  	:= TamSX3("CTD_ITEM")
	Local aTamConta		:= TamSX3("CT1_CONTA")
	Local aTamDCon		:= TamSX3("CT1_DESC01")
	Local nTamCusto		:= Len(CriaVar("CT3_CUSTO"))
	Local nTamConta		:= Len(CriaVar("CT1_CONTA"))
	Local nTamItem 		:= 10//Len(CriaVar("CTD->CTD_DESC"+mv_par05))
	Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par05)// Moeda
	Local nTamHist		:= 25//Len(CriaVar("CT2_HIST"))
	Local nTamCLVL		:= Len(CriaVar("CTH_CLVL"))
	Local nSepMasc 		:= 0 // separador da mascara (".")
	
	Local lAnalitico	:= Iif(mv_par08==1,.T.,.F.)// Analitico ou Resumido dia (resumo)
	Local lSaltaPg		:= Iif(mv_par20==1,.T.,.F.)// Salto de pagina por Item
	Local lPrintZero	:= IIf(mv_par27==1,.T.,.F.)// Imprime valor 0.00    ?   
	
	Local nTamTransp    := 0
	
	If nTamHist > 40   
		//se ultrapassar 40 posicoes define o tamanho como 40 posicoes 
		// para nao truncar informacoes como contra-partida / debito / cred/ etc
		nTamHist := 40
	EndIf
	
	cDescricao := STR0001+AllTrim(cSayItem)		//"Este programa ira imprimir o Razao por "
	cDescricao += STR0002						//"de acordo com os parametros sugeridos pelo usuario. "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport :=	TReport():New( NomeProg, cTitulo,cPerg ,;
				{ |oReport|	ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,;
							nTamConta,lAnalitico,lCusto,lCLVL,cSayItem,aSelFil) }, cDescricao )
	
	oReport:SetTotalInLine(.F.)
	oReport:EndPage(.T.)
	
	// Tratativa para acrescentar separadores de mascara da CTM no tamanho da célula "ITEM CONTA"
	If !Empty(aSetOfBook[7]) 
		DbSelectArea("CTM")
		DbSetOrder(1)
		If MsSeek(xFilial("CTM")+aSetOfBook[7])
			While CTM->(!EOF() .And. CTM_FILIAL+CTM_CODIGO == xFilial("CTM")+aSetOfBook[7])
				If !Empty(CTM->CTM_SEPARA)
					nSepMasc += 1 // tamanho do CTM_SEPARA
				EndIf
				CTM->(DbSkip())
			EndDo
		EndIf
	EndIf
	
	If nSepMasc > 0
		aTamItem[1] += nSepMasc // atualiza tamanho do campo
	EndIf
	
	If lAnalitico
		oReport:DisableOrientation()
		oReport:SetLandScape(.T.)
	Else
		oReport:SetPortrait(.T.)
	EndIf

	oLancto := TRSection():New( oReport, STR0029, {"cArqTmp","CT2"},, .F., .F. )	//"Lançamentos Contábeis"
	oLancto:SetTotalInLine(.F.)

	if MV_PAR28 == 2  .Or. MV_PAR28 == 1
		oLancto:SetLinesBefore(0)
	Endif 
	TRCell():New(oLancto, "CONTAP"			, ""			, Upper("CONTA")/*Titulo*/	,/*Picture*/,aTamConta[1]	/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
	TRCell():New(oLancto, "ITEM"				, "cArqTmp"	, Upper(cSayItem)/*Titulo*/	,/*Picture*/,aTamItem[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
	TRCell():New(oLancto, "DESCIT"			, ""       		, STR0039					,/*Picture*/,IIF(lAnalitico,nTamHist+46,39)+aTamConta[1]+nTamCusto+nTamCLVL+TAM_VALOR,/*lPixel*/,/*{|| }*/)	//"DESCRICAO"
	TRCell():New(oLancto, "DESANT"			, ""       		, STR0027					,/*Picture*/,Len(STR0027)	,/*lPixel*/,{||STR0027}/*{|| }*/)
	TRCell():New(oLancto, "TPSLDANT"		, ""       		, STR0027					,/*Picture*/,TAM_VALOR	,/*lPixel*/,/*{|| }*/,/*"RIGHT"*/,,"CENTER")
	TRCell():New(oLancto, "DATAL"			, "cArqTmp", STR0030			,/*Picture*/,IIF (lAnalitico, 10, 24)	,/*lPixel*/	,/*{|| }*/)// "DATA"		
	TRCell():New(oLancto, "DOCUMENTO"	,""        		, STR0031			,/*Picture*/,18							,/*lPixel*/	,{|| cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA })// "LOTE/SUB/DOC/LINHA"
	TRCell():New(oLancto, "HISTORICO"		,"cArqTmp" , STR0032			,/*Picture*/,nTamHist   				,/*lPixel*/	,{|| cArqTmp->HISTORICO })// "Historico"
	TRCell():New(oLancto, "XPARTIDA"		,"cArqTmp" , STR0033			,/*Picture*/,aTamConta[1]				,/*lPixel*/	,/*{|| }*/)// "XPARTIDA"
	TRCell():New(oLancto, "CUSTO"	  		,"cArqTmp" , Upper(cSayCusto)	,/*Picture*/,nTamCusto					,/*lPixel*/	,/*{|| }*/)// Item Contabil
	TRCell():New(oLancto, "CLVL"				,"cArqTmp" , Upper(cSayClVl) 	,/*Picture*/,nTamCLVL					,/*lPixel*/	,/*{|| }*/)// Classe de Valor
	TRCell():New(oLancto, "LANCDEB"		,"cArqTmp" , STR0034			,/*Picture*/,TAM_VALOR					,/*lPixel*/	,{|| ValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"CENTER")// "DEBITO"
	TRCell():New(oLancto, "LANCCRD"		,"cArqTmp" , STR0035			,/*Picture*/,TAM_VALOR					,/*lPixel*/	,{|| ValorCTB(cArqTmp->LANCCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },/*"RIGHT"*/,,"CENTER")// "CREDITO"
	TRCell():New(oLancto, "TPSLDATU"		,"cArqTmp" , STR0036			,/*Picture*/,TAM_VALOR				,/*lPixel*/	,/*{|| }*/,/*"RIGHT"*/,,"CENTER")// "SALDO ATUAL"
	
	oLancto:Cell("HISTORICO"):SetLineBreak()
	oLancto:SetHeaderPage()
	
	oLancto:SetEdit(.T.)//Inibido as celulas para não possibilitar personalização	

	If lAnalitico 
		If !lCusto
			oLancto:Cell("CUSTO" ):SetBlock({|| "" })
			oLancto:Cell("CUSTO" ):Hide()
			oLancto:Cell("CUSTO" ):HideHeader() 
		EndIf
		If !lCLVL
			oLancto:Cell("CLVL"	):SetBlock({|| "" })
			oLancto:Cell("CLVL"	):Hide()
			oLancto:Cell("CLVL"	):HideHeader() 
		EndIf
	Else // Resumido
		oLancto:Cell("CUSTO"):SetBlock({|| "" })
		oLancto:Cell("CUSTO"):Hide()
		oLancto:Cell("CUSTO"):HideHeader() 
		oLancto:Cell("CLVL"	):SetBlock({|| "" })
		oLancto:Cell("CLVL"	):Hide()
		oLancto:Cell("CLVL"	):HideHeader() 

		oLancto:Cell("HISTORICO"):Disable()
		oLancto:Cell("DOCUMENTO"):Hide()
		oLancto:Cell("DOCUMENTO"):HideHeader()
		oLancto:Cell("XPARTIDA"	):Hide()
		oLancto:Cell("XPARTIDA"	):HideHeader() 
	EndIf
                       
	If lAnalitico
		nTamTransp := oLancto:Cell("DATAL"):GetSize()     + oLancto:Cell("DOCUMENTO"):GetSize();
		            + oLancto:Cell("HISTORICO"):GetSize() + oLancto:Cell("XPARTIDA"):GetSize();  
		            + oLancto:Cell("CUSTO"):GetSize()     + oLancto:Cell("CLVL"):GetSize() + 5	              
	Else 
		nTamTransp := oLancto:Cell("DATAL"):GetSize()     + oLancto:Cell("DOCUMENTO"):GetSize();
		            + oLancto:Cell("HISTORICO"):GetSize() + oLancto:Cell("XPARTIDA"):GetSize();  
		            + oLancto:Cell("CUSTO"):GetSize()     + oLancto:Cell("CLVL"):GetSize() - 56	  
	Endif     
	
oReport:ParamReadOnly()

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Gustavo Henrique      ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,;
				nDecimais,nTamConta,lAnalitico,lCusto,lCLVL,cSayItem,aSelFil )
                          
Local oLancto  		:= oReport:Section(1)
                                      
Local cMascara1		:= ""
Local cMascara2		:= ""
Local cMascara3		:= ""
Local cMascara4		:= ""
Local cItemAnt		:= ""
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cArqTmp		:= ""               
Local cFiltro		:= ""
Local cContaAnt		:= ""
Local cResCusto		:= ""
Local cResClVl		:= ""
Local cItem			:= ""
Local cNormal		:= ""
Local cSaldo		:= mv_par06
Local cItemIni		:= mv_par01
Local cItemFim		:= mv_par02
Local cMoeda		:= mv_par05
Local cContaIni		:= mv_par12
Local cContaFIm		:= mv_par13
Local cCustoIni		:= mv_par15
Local cCustoFim		:= mv_par16
Local cCLVLIni		:= mv_par18
Local cCLVLFim		:= mv_par19
Local cFilCCIni		:= Space( TamSX3("CTT_CUSTO")[1] )
Local cFilCCFim		:= Repl('Z',Len(CTT->CTT_CUSTO))

Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04
Local dDataAnt		:= CtoD("  /  /  ")

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.) // Imprime conta sem movimento?           
Local lSaltaPg		:= Iif(mv_par20==1,.T.,.F.)// Salto de pagina por Item
Local lPrintZero	:= Iif(mv_par27==1,.T.,.F.) // Imprime valor 0.00    ?

Local nTamItem 		:= Len(CriaVar("CTD->CTD_DESC"+mv_par05))

Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotCtaDeb	:= 0
Local nTotCtaCrd	:= 0
Local cFilOld := cFilAnt
Local nX
Local cFil := ""  
Local oMeter   
Local oText
Local oDlg   
Local lEnd

cFiltro	:= oLancto:GetAdvplExp()

If Type("NewHead")== "U"
	Titulo	:=	STR0007	+ Upper(Alltrim(cSayItem))//"RAZAO POR ITEM  "
	IF lAnalitico
		Titulo	+= STR0008		//"ANALITICO EM"
	Else
		Titulo	+=	STR0021		//" SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + space(01)+STR0009 + space(01)+DTOC(dDataIni) +;	// "DE"
					space(01)+STR0010 + space(01)+DTOC(dDataFim)						// "ATE"
	
	If mv_par06 > "1"
		Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
	EndIf
Else
	Titulo := NewHead
EndIf

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascara3 := GetMv("MV_MASCCTD")
Else
	cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
EndIf

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 	:= GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf
 
// Mascara do Centro de Custo
If lCusto
	If Empty(aSetOfBook[6])
		cMascara2 	:= GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                
Endif 

// Mascara da Classe de Valor
If lCLVL
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

oReport:SetTitle(Titulo)
oReport:SetPageNumber(mv_par21) //mv_par21	-	Pagina Inicial
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,oReport:Title(),,,,,oReport) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    


If  __lBlind 

	lExterno := .T.   
	
	CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,.t.,"3",lAnalitico,,,cFiltro,,aSelFil,lExterno)
Else

	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,.t.,"3",lAnalitico,,,cFiltro,,aSelFil)},;
				STR0018,;		// "Criando Arquivo Temporario..."
				STR0006+(Alltrim(cSayItem)))	// "Emissao do Razao"  
Endif

dbSelectArea("cArqTmp")
dbGoTop()

oReport:SetMeter(RecCount())
oReport:NoUserFilter()

oLancto:Init()

If !(cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5]))
	Do While cArqTmp->( ! EoF() ) .And. !oReport:Cancel()
	
	    cFilAnt := cArqTmp->FILORI
	    
	    If oReport:Cancel()
	    	Exit
	    EndIf        
		
		// Se imprime centro de custo, ira considerar o filtro do centro de custo para calculo do saldo ant. 
		cItem := cArqTmp->ITEM
		
		If lCusto 	
			aSaldoAnt	:= SaldTotCT4(cItem,cItem,cCustoIni,cCustoFim,cContaIni,cContaFim,dDataIni,cMoeda,cSaldo,aSelFil)
			aSaldo		:= SaldTotCT4(cItem,cItem,cCustoIni,cCustoFim,cContaIni,cContaFim,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		Else		
			aSaldoAnt	:= SaldTotCT4(cItem,cItem,cFilCCIni,cFilCCFim,cContaIni,cContaFim,dDataIni,cMoeda,cSaldo,aSelFil)
			aSaldo 		:= SaldTotCT4(cItem,cItem,cFilCCIni,cFilCCFim,cContaIni,cContaFim,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		EndIf

		If Ctbr480Fil(lNoMov,aSaldo,dDataIni)
			cArqTmp->(dbSkip())
			Loop
		EndIf
                                        
		nTotDeb		:= 0
		nTotCrd		:= 0                              
		nSaldoAtu	:= 0

		oLancto:Cell("ITEM"):SetTitle( Upper(AllTrim(cSayItem)) )	//"ITEM"
	
		CTD->(dbSetOrder(1))
		CTD->(MsSeek(xFilial()+cArqTMP->ITEM))

		If mv_par25 == 1 //Se imprime cod. normal item
			oLancto:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp->ITEM,0,0,nTamItem,.F.,cMascara3,cSepara3,,,,,.F.) } )
		Else
			cResItem := CTD->CTD_RES
			oLancto:Cell("ITEM"):SetBlock( { || EntidadeCTB(cResItem,0,0,Len(cResItem),.F.,cMascara3,cSepara3,,,,,.F.)	 } )
		Endif
	
		oLancto:Cell("DESCIT"):SetBlock( { || " - " + CtbDescMoeda("CTD->CTD_DESC"+cMoeda) } )
	                                                      
		oLancto:Cell("TPSLDANT"):SetBlock( { || ValorCTB(aSaldoAnt[6],,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
		

		oLancto:PrintLine()    //Imprime o Saldo anterior         
		
		nSaldoAtu := aSaldoAnt[6]

		cItemAnt := cArqTmp->ITEM

		Do While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt .And. !oReport:Cancel()
		                                        
		   	If oReport:Cancel()
		   		Exit
		   	EndIf
		   
			cContaAnt	:= cArqTmp->CONTA
			dDataAnt	:= cArqTmp->DATAL		

			If lAnalitico
				
				nTotCtaDeb  := 0
				nTotCtaCrd	:= 0
				
				If ! Empty(cArqTmp->CONTA)
				
					cConta := " "
					cContaDesc := " "
				
					CT1->(dbSetOrder(1))
					CT1->(MsSeek(xFilial()+cArqTmp->CONTA))
					
					cCodRes := CT1->CT1_RES
					cNormal := CT1->CT1_NORMAL
			
					If mv_par10 == 1 // Imprime Cod Normal
						cConta := cArqTmp->CONTA
					Else
						cConta := cCodRes
					EndIf
	
					cContaDesc := CtbDescMoeda("CT1->CT1_DESC"+cMoeda)
					               
					If mv_par11 == 1 // Totaliza tb por conta ?	
						oReport:SkipLine()
					EndIf	     
					
					If oReport:Printing() .and. MV_PAR28 == 1 .And. mv_par11 == 2
						oReport:SkipLine()                                                                                        
					EndIf

					//oReport:PrintText(cConta)	 //Imprime a Conta
				Endif

				oLancto:Init()

				Do While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt .And. cArqTmp->CONTA == cContaAnt .And. !oReport:Cancel()
				
					If oReport:Cancel()
						Exit
					EndIf	
				     
					oReport:IncMeter() 

   					nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotCtaDeb	+= cArqTmp->LANCDEB
					nTotCtaCrd	+= cArqTmp->LANCCRD			
					
					oLancto:Cell("CONTAP"):SetBlock( { || cConta } )
					             
					If dDataAnt <> cArqTmp->DATAL 
						oLancto:Cell("DATAL"):SetBlock( { || cArqTmp->DATAL } )
						dDataAnt := cArqTmp->DATAL    
					Else
						oLancto:Cell("DATAL"):SetBlock( { || dDataAnt } )
					EndIf	
					                   
					CT1->(dbSetOrder(1))
					CT1->(MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA))
						
					cCodRes := CT1->CT1_RES
											
					If mv_par10 == 1 // Impr Cod (Normal/Reduzida/Cod.Impress)
						oLancto:Cell("XPARTIDA"):SetBlock( { || cArqTmp->XPARTIDA } )
					Else
						oLancto:Cell("XPARTIDA"):SetBlock( { || cCodRes } )
					Endif
					
					If lCusto	//Se imprime custo
						If mv_par25 == 1 //Imprime Codigo Normal centro de custo
							oLancto:Cell("CUSTO"):SetBlock( { || EntidadeCTB(cArqTmp->CCUSTO,0,0,TAM_CONTA,.F.,cMascara2,cSepara2,,,,,.F.) } )
						Else
							CTT->(dbSetOrder(1))
							CTT->(MsSeek(xFilial("CTT")+cArqTmp->CCUSTO))
							cResCusto := CTT->CTT_RES
							oLancto:Cell("CUSTO"):SetBlock( { || EntidadeCTB(cResCusto,0,0,TAM_CONTA,.F.,cMascara2,cSepara2,,,,,.F.) } )
						Endif
					Endif
                                                                                            
					If lCLVL //Se imprime classe de valor
						If mv_par26 == 1 //Imprime Cod. Normal Classe de Valor
							oLancto:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp->CLVL,0,0,TAM_CONTA,.F.,cMascara4,cSepara4,,,,,.F.) } )
						Else
							CTH->(dbSetOrder(1))
							CTH->(MsSeek(xFilial("CTH")+cArqTmp->CLVL))
							cResClVl := CTH->CTH_RES
							oLancto:Cell("CLVL"):SetBlock( { || EntidadeCTB(cResClVl,0,0,TAM_CONTA,.F.,cMascara4,cSepara4,,,,,.F.) } )
						EndIf
					Endif
                            
					nSldATransp := nSaldoAtu // Valor a Transportar - 1
                                                                       
					// Sinal do Saldo Atual => Consulta Razao
					oLancto:Cell("TPSLDATU"):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) })

					oLancto:PrintLine()  //Imprime as Datas

					nSldDTransp := nSaldoAtu // Valor de Transporte - 2

					//ImpCompl(oReport)

				    lTotConta	:= ! Empty(cArqTmp->CONTA)
					dDataAnt	:= cArqTmp->DATAL		

					cArqTmp->(dbSkip())
				
				EndDo
				
			Else
				
				oLancto:Init()    
			
				If ! Empty(cArqTmp->CONTA)
					CT1->(dbSetOrder(1))
					CT1->(dbSeek(xFilial()+cArqTmp->CONTA))
					cCodRes := CT1->CT1_RES
					cNormal := CT1->CT1_NORMAL
				Else
					cNormal := ""
				Endif
						
				Do While cArqTmp->( ! EoF() .And. dDataAnt == cArqTmp->DATAL .And. cItemAnt == cArqTmp->ITEM ) .And. !oReport:Cancel()
					If oReport:Cancel()
						Exit
					EndIf					
					oReport:IncMeter() 
					nVlrDeb	+= cArqTmp->LANCDEB		                                         
					nVlrCrd	+= cArqTmp->LANCCRD		                                         
					cArqTmp->(dbSkip())
				EndDo		   
				
				nSaldoAtu := nSaldoAtu - nVlrDeb + nVlrCrd
				
				oLancto:Cell("DATAL"):SetBlock( { || dDataAnt } )
				oLancto:Cell("LANCDEB"	):SetBlock( { || ValorCTB(nVlrDeb,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) })// Debito
				oLancto:Cell("LANCCRD"	):SetBlock( { || ValorCTB(nVlrCrd,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) })// Credito
				oLancto:Cell("TPSLDATU"	):SetBlock( { || ValorCTB(nSaldoAtu,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) })// Sinal do Saldo Atual => Consulta Razao

				nSldATransp := nSaldoAtu // Valor a Transportar  (nSld-A-Transp)

				oLancto:PrintLine()
				
				nSldDTransp := nSaldoAtu // Valor de Transporte (nSld-D-Transp)

				nTotDeb	+= nVlrDeb
				nTotCrd	+= nVlrCrd         
				nVlrDeb	:= 0
				nVlrCrd	:= 0
				
			EndIf

		EndDo      

		oLancto:Finish()

		// Inicio da 3a secao - Totais da Conta 
		cItem := "( "
		If mv_par24 == 1 // Se imprime cod. normal de Centro de Custo
			cItem += EntidadeCTB(cItemAnt,0,0,nTamItem,.F.,cMascara3,cSepara3,,,,,.F.)
		Else
			CTD->(dbSetOrder(1))
			CTD->(MsSeek(xFilial()+cItemAnt))
			cResItem := CTD->CTD_RES
			cItem += EntidadeCTB(cResItem,0,0,nTamItem,.F.,cMascara3,cSepara3,,,,,.F.)
		Endif
		cItem +=" )"
			
		oReport:SkipLine()
		If lSaltaPg             // Salta Pagina Por Item
			oReport:EndPage()
		Endif
	EndDo
	
EndIf

cFilAnt := cFilOld
oLancto:Finish()   

// Inicializa PageFooter e OnPageBreak para evitar quebra de pagina desnecessaria
oReport:SetPageFooter(0,{||.T.})
oReport:OnPageBreak({||.T.})

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()

If Select("cArqTmp") = 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf	

dbselectArea("CT2")

Return

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCompl  ºAutor  ³Gustavo Henrique    º Data ³  12/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Retorna a descricao, da conta contabil, item, centro de     º±±
±±º          ³custo ou classe valor                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPO1 - Objeto do relatorio TReport.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR390                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCompl(oReport)
	
Local oCompl := oReport:Section(4)

oCompl:Cell("COMP"):SetBlock({|| Space(15)+CT2->CT2_LINHA,Subs(CT2->CT2_HIST,1,40) } )

// Procura pelo complemento de historico
dbSelectArea("CT2")
dbSetOrder(10)
If MsSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
	//MsSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN),.F.)
	dbSkip()
	If CT2->CT2_DC == "4"			//// TRATAMENTO PARA IMPRESSAO DAS CONTINUACOES DE HISTORICO
		oCompl:Init()
		Do While !	CT2->(Eof()) .And.;
					CT2->CT2_FILIAL == xFilial("CT2") 		.And.;
					CT2->CT2_LOTE   == cArqTMP->LOTE		.And.;
					CT2->CT2_SBLOTE == cArqTMP->SUBLOTE		.And.;
					CT2->CT2_DOC    == cArqTmp->DOC 		.And.;
					CT2->CT2_SEQLAN == cArqTmp->SEQLAN	 	.And.;
					CT2->CT2_EMPORI == cArqTmp->EMPORI		.And.;
					CT2->CT2_FILORI == cArqTmp->FILORI 		.And.;
					CT2->CT2_DC     == "4" 					.And.;
				 	DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)
			oCompl:Printline()
			CT2->(dbSkip())
		EndDo
		oCompl:Finish()
	EndIf
EndIf

dbSelectArea("cArqTmp")
    
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f440Fil   ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR440                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctbr480Fil(lNoMov,aSaldo,dDataIni)

Local lOk := .F.

If !lNoMov //Se imprime conta sem movimento
	If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		lOk := .T.
	Endif	
Endif             

If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
	If CtbExDtFim("CTD")
		CTD->(dbSetOrder(1))
		If CTD->(MsSeek(xFilial()+cArqTmp->ITEM))
			lOk := !CtbVlDtFim("CTD",dDataIni)
	    EndIf
	EndIf
EndIf

Return( lOk )

/*------------------------------------------------------- RELEASE 3 -----------------------------------------------------------*/



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR480R3³ Autor ³ Simone Mie Sato       ³ Data ³ 02.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Razao por Item Contabil                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBR480                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function R480R3(cItemIni, cItemFim, dDataIni, dDataFim, cMoeda, cSaldo,;
			cBook, cContaIni, cContaFim, lCusto, cCustoIni, cCustoFim, lCLVL,;
			cCLVLIni, cCLVLFim,lSalLin,aSelFil)

Local aSetOfBook 	:= CTBSetOf(mv_par07)// Set Of Books	
Local aCtbMoeda 	:= CtbMoeda(mv_par05)
Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")
Local cDesc1		:= STR0001 + Alltrim(cSayItem)	//"Este programa ira imprimir o Razao por "
Local cDesc2		:= STR0002	//" de acordo com os parametros sugeridos pelo usuario. "
Local cString		:= "CT2"
Local titulo		:= STR0006 + Alltrim(cSayItem)	//"Emissao do Razao Contabil por Item"
Local lRet			:= .T.
Local lExterno		:= .F.
Local nTamLinha		:= 220
Local WnRel			:= ""  

Default lCusto		:= .T.
Default lCLVL		:= .T.
Default lSalLin		:= .T.
Default aSelFil		:= {}  

Private aReturn		:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private aLinha		:= {}
Private nLastKey	:= 0
Private Tamanho		:= "G"    
Private lSaltLin	:=.T.
Private NomeProg 	:= "CTBR480"

lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico .and. (lCusto .or. lClvl), Tamanho, "M")
nTamLinha	:= If( lAnalitico .and. (lCusto .or. lClvl), 220, 132)

WnRel := "CTBR480" 
wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,,.F.,"",,Tamanho)

lSaltLin	:= If(MV_PAR28==1,.T.,.F.)

lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
Tamanho		:= If( lAnalitico .and. (lCusto .or. lClvl), Tamanho, "M")
nTamLinha	:= If( lAnalitico .and. (lCusto .or. lClvl), 220, 132)
If aReturn[4] == 2		/// Se forçar formato paisagem
	Tamanho		:= "G"
	nTamLinha	:= 220
EndIf	

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| U_CCTR480Imp(@lEnd,wnRel,cString,aSetOfBook,lCusto,lCLVL,;
		lAnalitico,Titulo,nTamlinha,aCtbMoeda,cSayCusto,cSayItem,cSayClVl,aSelFil,lExterno)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTR480Imp ³ Autor ³ Simone Mie Sato       ³ Data ³ 02/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Razao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Ctr480Imp(lEnd,wnRel,cString,aSetOfBook,lCusto,;            ³±±
±±³           ³          lCLVL,lAnalitico,Titulo,nTamLinha,aCtbMoeda)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd       - A‡ao do Codeblock                             ³±±
±±³           ³ wnRel      - Nome do Relatorio                             ³±±
±±³           ³ cString    - Mensagem                                      ³±±
±±³           ³ aSetOfBook - Array de configuracao set of book             ³±±
±±³           ³ lCusto     - Imprime Centro de Custo?                      ³±±
±±³           ³ lCLVL      - Imprime Classe de Valor?                      ³±±
±±³           ³ lAnalitico - Imprime Analitico ou Sintetico?               ³±±
±±³           ³ Titulo     - Titulo do Relatorio                           ³±±
±±³           ³ nTamLinha  - Tamanho da linha                              ³±±
±±³           ³ aCtbMoeda  -  Array da Moeda                               ³±±
±±³           ³ cSayCusto  - Nomenclatura utilizada para o Centro de Custo ³±±
±±³           ³ cSayItem   - Nomenclatura utilizada para o Item            ³±±
±±³           ³ cSayClVl   - Nomenclatura utilizada para a Classe de valor ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CCTR480Imp(lEnd,WnRel,cString,aSetOfBook,lCusto,lCLVL,lAnalitico,Titulo,;
				   nTamlinha,aCtbMoeda,cSayCusto,cSayItem,cSayClvl,aSelFil,lExterno)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""

Local aSaldo		:= {} 
Local aSaldoAnt		:= {}
Local aColunas

Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cItemIni		:= mv_par01
Local cItemFim		:= mv_par02
Local cContaIni	:= mv_par12
Local cContaFIm	:= mv_par13
Local cCustoIni	:= mv_par15
Local cCustoFim	:= mv_par16
Local cCLVLIni		:= mv_par18
Local cCLVLFim		:= mv_par19
Local cContaAnt	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem 	:= ""
Local cResCLVL		:= ""		
Local cMoeda		:= mv_par05
Local cArqTmp       := ""
Local cNormal 		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04        

Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lSaltaPg		:= Iif(mv_par20==1,.T.,.F.) // Salta Pagina por Item
Local lPrintZero	:= Iif(mv_par27 == 1,.T.,.F.)
Local lTotConta

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nReinicia 	:= mv_par23
Local nPagFim		:= mv_par22
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0

Local lQbPg			:= .F.
Local l1StQb 		:= .T.
Local nPagIni		:= mv_par21
Local lFirst		:= .T.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
Local nBloco		:= 0
Local nBlCount		:= 0
Local nSpacCta		:= 70
Local nX
Local cFilOld		:= cFilAnt
Local cFil			:= ""  
Local oMeter   
Local oText
Local oDlg   

m_pag    := 1

If lEmissUnica
	CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt				:= SPACE(10)
cbcont			:= 0
li       		:= 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascara3 := GetMv("MV_MASCCTD")
Else
	cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
EndIf

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf
 
// Mascara do Centro de Custo
If lCusto
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2	:= RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                
Endif 

// Mascara da Classe de Valor
If lCLVL
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

cPicture 	:= aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")== "U"
	Titulo	:=	STR0007	+ Upper(Alltrim(cSayItem))//"RAZAO POR ITEM  "
	IF lAnalitico
		Titulo	+= STR0008		//"ANALITICO EM"
	Else
		Titulo	+=	STR0021		//" SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + space(01)+STR0009 + space(01)+DTOC(dDataIni) +;	// "DE"
					space(01)+STR0010 + space(01)+DTOC(dDataFim)						// "ATE"
	
	If mv_par06 > "1"
		Titulo += " (" + Tabela("SL", mv_par06, .F.) + ")"
	EndIf
Else
	Titulo := NewHead
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Resumido                                  						         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA                         					                                DEBITO               CREDITO            SALDO ATUAL
// XX/XX/XXXX 			                                 		     99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/SUB/DOC/LINHA H I S T O R I C O                         XPARTIDA                      DEBITO          CREDITO       SALDO ATUAL"
// XX/XX/XXXX         
// XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 9999999999999.99 9999999999999.99 9999999999999.99D
// 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabe‡alho Conta + Item + Classe de Valor											  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// DATA
// LOTE/DOC/LINHA  H I S T O R I C O                         XPARTIDA                      CENTRO DE CUSTO      CLASSE DE VALOR                     DEBITO               CREDITO           SALDO ATUAL"
// XX/XX/XXXX 
// XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXX 99,999,999,999,999.99 99,999,999,999,999.99 99,999,999,999,999.99D
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16         17        18        19        20       21        22

#DEFINE 	COL_NUMERO 				1
#DEFINE 	COL_HISTORICO			2
#DEFINE 	COL_CONTRA_PARTIDA	3
#DEFINE 	COL_CENTRO_CUSTO  	4
#DEFINE 	COL_CLASSE_VALOR  	5 
#DEFINE 	COL_VLR_DEBITO			6
#DEFINE 	COL_VLR_CREDITO		7
#DEFINE 	COL_VLR_SALDO  		8
#DEFINE 	TAMANHO_TM       		9
#DEFINE 	COL_VLR_TRANSPORTE  10

If aReturn[4] == 1 .and. !lCusto .and. !lClVl
	If mv_par10 == 2
		nSpacCta := Len(CT1->CT1_RES)+Len(ALLTRIM(cMascara1))
	Else
		nSpacCta := Len(CT1->CT1_CONTA)
	EndIf
EndIf
If ! lAnalitico
	aColunas := { 000, 019,    ,    ,    , 069, 091, 113, 18, 090 }
Else
	If lCusto .or. lClvl
		aColunas := { 000, 022, 065, 131, 152, 172, 188, 204, 14,176 }
	Else
		aColunas := { 000, 022, 065, 0  ,0   , 82 , 98 , 114, 14, 110 }		
		aColunas[6] := aColunas[3] + nSpacCta
		aColunas[7] := aColunas[6] + 16
		aColunas[8] := aColunas[7] + 16
		aColunas[10] := aColunas[7] + 12
	EndIf	
Endif

If lAnalitico					// Relatorio Analitico
	Cabec1  := STR0019			// "DATA"
	Cabec2 	:= STR0013			// "LOTE/DOC/LINHA    H I S T O R I C O                        XPARTIDA                    C.CUSTO              CLASSE DE VALOR                      DEBITO                CREDITO            SALDO ATUAL"
	If lCusto .or. lClVl
		Cabec2	+= Space(62) + Upper(cSayCusto)+Space(11)+Upper(cSayClvl)+Space(18)
	Else
		Cabec2 += Space(aColunas[6]-aColunas[3])
	EndIf
	Cabec2 	+= STR0026
Else
	lCusto := .F.
	lCLVL  := .F.
	Cabec1 := STR0025				// "DATA			                    		                   					                                               DEBITO           CREDITO       SALDO ATUAL"
EndIf	
m_pag    			:= mv_par21
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If  __lBlind 

	lExterno := .T.
	
	CTBGerRaz(oMeter,oText,oDlg,@lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,.t.,"3",lAnalitico,,,aReturn[7],,aSelFil,lExterno)
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				aSetOfBook,lNoMov,cSaldo,.t.,"3",lAnalitico,,,aReturn[7],,aSelFil)},;
				STR0018,;		// "Criando Arquivo Temporario..."
				STR0006+(Alltrim(cSayItem))) 	// "Emissao do Razao"
Endif

dbSelectArea("cArqTmp")
SetRegua(RecCount())
dbGoTop()

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If RecCount() == 0 .And. !Empty(aSetOfBook[5])                                       
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())	
	Return
Endif


While !Eof()
	
	cFilAnt := cArqTmp->FILORI

	IF lEnd
		@Prow()+1,0 PSAY STR0015  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	//Se imprime centro de custo, ira considerar o filtro do centro de custo para calculo do saldo ant. 
	If lCusto 	
		aSaldoAnt := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,cCustoIni,cCustoFim,cContaIni,cContaFim,;
		dDataIni,cMoeda,cSaldo,aSelFil)
	
		aSaldo := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,cCustoIni,cCustoFim,cContaIni,cContaFim,;
		cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
	Else		
		aSaldoAnt := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,space(Len(CTT->CTT_CUSTO)),Repl('Z',Len(CTT->CTT_CUSTO)),;
		cContaIni,cContaFim,dDataIni,cMoeda,cSaldo,aSelFil)
	
		aSaldo := SaldTotCT4(cArqTmp->ITEM,cArqTmp->ITEM,space(Len(CTT->CTT_CUSTO)),Repl('Z',Len(CTT->CTT_CUSTO)),;
		cContaIni,cContaFim,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
	EndIf
	
	If !lNoMov //Se imprime sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif	
	Endif             
	
	If lNomov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CTD") 			
			dbSelectArea("CTD") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->ITEM)
				If !CtbVlDtFim("CTD",dDataIni) 		
					dbSelectArea("cArqTmp")
					dbSkip()
					Loop								
	            EndIf
		    EndIf
		    dbSelectArea("cArqTmp")
		EndIf
	EndIf
	
         
	If li > 56 .Or. lSaltaPg              
		If lEmissUnica	
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
		Else
			If m_pag > nPagFim
				If lNewPAGFIM
					nPagFim := m_pag+nPagFim		
					If l1StQb							//// SE FOR A 1ª QUEBRA
						m_pag := nReinicia
						l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
					Endif
				Else
					m_pag := nReinicia
				Endif
			EndIf	
		Endif

		CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
		If !lFirst		
			lQbPg	:= .T.
		Else
			lFirst := .F.
		Endif

	EndIf

	nSaldoAtu	:= 0
	nTotDeb		:= 0
	nTotCrd		:= 0

	@li,011 PSAY Upper(cSayItem) + " - " 		//"ITEM  - "		

	dbSelectArea("CTD")
	dbSetOrder(1)
	dbSeek(xFilial()+cArqTMP->ITEM)  
	cResItem := CTD->CTD_RES		
	If mv_par25 == 1 //Se imprime cod. normal item
		EntidadeCTB(cArqTmp->ITEM,li,pcol()+2,20,.F.,cMascara3,cSepara3)	
	Else
		EntidadeCTB(cResItem,li,pcol()+2,20,.F.,cMascara3,cSepara3)		
	Endif

	@ li, pCol()+2 PSAY "- " + CtbDescMoeda("CTD->CTD_DESC"+cMoeda)                 	
	                                                                                    
	If lAnalitico
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0027) - 1;
			 PSAY STR0027	//"SALDO ANTERIOR: "		
	Else
		@li,aColunas[COL_VLR_CREDITO]  PSAY STR0027	//"SALDO ANTERIOR: "
	EndIf	
	// Impressao do Saldo Anterior do Item.
	ValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
							         .T.,cPicture)

	nSaldoAtu := aSaldoAnt[6]
    If lSaltLin
	  li += 2  
	Else         
		li += 1      
	EndIf
	dbSelectArea("cArqTmp")
	
	cItemAnt := cArqTmp->ITEM
	While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt

		lQbPg	:= .T.
		cContaAnt	:= cArqTmp->CONTA
		dDataAnt	:= cArqTmp->DATAL                      
		If lAnalitico
			nTotCtaDeb  := 0
			nTotCtaCrd	:= 0
		
			If ! Empty(cArqTmp->CONTA)

				@li,000 PSAY STR0024				// "CONTA - "
			
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->CONTA)
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
		
				If mv_par10 == 1							// Imprime Cod Normal
					EntidadeCTB(cArqTmp->CONTA,li,pcol()+2,nSpacCta,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,pcol()+2,20,.F.,cMascara1,cSepara1)
				EndIf

				@ li, pCol()+2 PSAY CtbDescMoeda("CT1->CT1_DESC"+cMoeda)
				li++

			Endif

			If lQbPg
				@li,000 PSAY cArqTmp->DATAL
				lQbPg := .F.
			EndIf
			If ! Empty(cArqTmp->CONTA)
				li++
			Endif
					
			lTotConta := .F.
			While cArqTmp->(!Eof()) .And. cArqTmp->ITEM == cItemAnt .And. cArqTmp->CONTA == cContaAnt
		
				If li > 56  
					If lSaltLin
			   			li++
					EndIf
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
								 PSAY STR0022	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    .T.,cPicture,cNormal)
					If lEmissUnica
						CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
					Else
						If m_pag > nPagFim
							If lNewPAGFIM
								nPagFim := m_pag+nPagFim		
								If l1StQb							//// SE FOR A 1ª QUEBRA
									m_pag := nReinicia
									l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
								Endif
							Else
								m_pag := nReinicia
							Endif
						EndIf						
					EndIf
					CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
					lQbPg := .T.
			
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
								 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    .T.,cPicture,cNormal)
					li++
				EndIf            
				nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
				nTotDeb		+= cArqTmp->LANCDEB
				nTotCrd		+= cArqTmp->LANCCRD
				nTotCtaDeb  += cArqTmp->LANCDEB
				nTotCtaCrd  += cArqTmp->LANCCRD
	
				// Imprime os lancamentos para a conta 
				If dDataAnt != cArqTmp->DATAL
					@li,000 PSAY cArqTmp->DATAL
					dDataAnt := cArqTmp->DATAL
					li++
				ElseIf lQbPg
					@li,000 PSAY dDataAnt
					lQbPg := .F.
					li++
				EndIf
			
				@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+;
											   cArqTmp->DOC+cArqTmp->LINHA
				@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40) 
				
				cHistComp := Subs(cArqTmp->HISTORICO,41)
                        
				dbSelectArea("CT1")
				dbSetOrder(1)
				dbSeek(xFilial()+cArqTmp->XPARTIDA)
				cCodRes := CT1->CT1_RES

				If mv_par10 == 1
					EntidadeCTB(cArqTmp->XPARTIDA,li,aColunas[COL_CONTRA_PARTIDA],;
					nSpacCta,.F.,cMascara1,cSepara1)
				Else
					EntidadeCTB(cCodRes,li,aColunas[COL_CONTRA_PARTIDA],20,.F.,;
								cMascara1,cSepara1)				
				Endif                              

				If lCusto 				//Se imprime centro de custo
					If mv_par24 == 1 	//Se imprime cod. normal centro de custo
						EntidadeCTB(cArqTmp->CCUSTO,li,aColunas[COL_CENTRO_CUSTO],20,.F.,cMascara2,cSepara2)
					Else
						dbSelectArea("CTT")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTMP->CCUSTO)  
						cResCC := CTT->CTT_RES
						EntidadeCTB(cResCC,li,aColunas[COL_CENTRO_CUSTO],20,.F.,cMascara2,cSepara2)
					Endif
				Endif
				
				If lCLVL						//Se imprime classe de valor
					If mv_par26 == 1
						EntidadeCTB(cArqTmp->CLVL,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Else
						dbSelectArea("CTH")
						dbSetOrder(1)
						dbSeek(xFilial()+cArqTmp->CLVL)				
						cResClVl := CTH->CTH_RES						
						EntidadeCTB(cResClVl,li,aColunas[COL_CLASSE_VALOR],20,.F.,cMascara4,cSepara4)
					Endif					
				Endif
				
				ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLR_DEBITO],;
											  aColunas[TAMANHO_TM],nDecimais,.F.,;
											  cPicture,"1",,,,,,lPrintZero)
				ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLR_CREDITO],;
											  aColunas[TAMANHO_TM],nDecimais,.F.,;
											  cPicture,"2",,,,,,lPrintZero)
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
									   aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero)

				While ! Empty( ALLTRIM( cHistComp ) )
					li++
					@li,aColunas[COL_HISTORICO] PSAY Subs(cHistComp,1,40)
					//Realiza quebra do histórico
					cHistComp := Subs(cHistComp,41)							   
				EndDo
				
				// Procura pelo complemento de historico
				dbSelectArea("CT2")
				dbSetOrder(10)
				If dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
					dbSkip()
					If CT2->CT2_DC == "4"
						While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
											CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
											CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
											CT2->CT2_DOC == cArqTmp->DOC 			.And.;
											CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
											CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
											CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
											CT2->CT2_DC == "4" 					.And.;
									   DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        
							li++
							If li > 56
								If lEmissUnica								
									CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
								Else
									If m_pag > nPagFim
										If lNewPAGFIM
											nPagFim := m_pag+nPagFim		
											If l1StQb							//// SE FOR A 1ª QUEBRA
												m_pag := nReinicia
												l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
											Endif
										Else
											m_pag := nReinicia
										Endif
									EndIf									
								EndIf
								CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
								li++
								@li,000 PSAY dDataAnt
								li++
							EndIf
							@li,aColunas[COL_NUMERO] 	 PSAY	CT2->CT2_LOTE+;
																	  	CT2->CT2_SBLOTE+;
										        						CT2->CT2_DOC+;
										        						CT2->CT2_LINHA
							@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)
							dbSkip()
						EndDo	
					EndIf	
				EndIf	
				dbSelectArea("cArqTmp")
				li++  //Utilizado no salto da proxima data da mesma conta.
			
				If li > 56
					If lSaltLin
						li++
					EndIf
					
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
								 PSAY STR0022	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    			   .T.,cPicture,cNormal)
				 	If lEmissUnica				 	
						CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
					Else
						If m_pag > nPagFim
							If lNewPAGFIM
								nPagFim := m_pag+nPagFim		
								If l1StQb							//// SE FOR A 1ª QUEBRA
									m_pag := nReinicia
									l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
								Endif
							Else
								m_pag := nReinicia
							Endif
						EndIf	
					EndIf
					
					CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
			
					@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
								 PSAY STR0023	//"A TRANSPORTAR : "
					ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
										   aColunas[TAMANHO_TM],nDecimais,;
				    	    			   .T.,cPicture,cNormal)
					li++
					@li,000 PSAY dDataAnt
					li++
					lQbPg := .F.				
	   		EndIf
         	lTotConta := ! Empty(cArqTmp->CONTA)
				dbSelectArea("cArqTmp")
				dDataAnt := cArqTmp->DATAL
      		dbSkip()
			EndDo      	
   
			If lTotConta .And. mv_par11 == 1						// Totaliza tb por Conta
				If lSaltLin
					li += 1   
				EndIf
				@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0020  //"T o t a i s  d a  C o n t a  ==> " 
				ValorCTB(nTotCtaDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
					     nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
				ValorCTB(nTotCtaCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
					     nDecimais,.F.,cPicture,"2",,,,,,lPrintZero)
			
				nTotCtaDeb := 0
				nTotCtaCrd := 0
			
				li++
				@li, 00 PSAY Replicate("-",nTamLinha)
				li++
			EndIf	
		Else					//Se for resumido
			dbSelectArea("cArqTmp")
			If ! Empty(cArqTmp->CONTA)
				CT1->(dbSeek(xFilial()+cArqTmp->CONTA))
				cCodRes := CT1->CT1_RES
				cNormal := CT1->CT1_NORMAL
			Else
				cNormal := ""
			Endif

			If li > 56
				If lSaltLin
					li++
				EndIf
					
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1 PSAY STR0022	//"A TRANSPORTAR : "
				ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO], aColunas[TAMANHO_TM],nDecimais,.T.,cPicture,cNormal)
    			If lEmissUnica	
					CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
				Else			
					If m_pag > nPagFim
						If lNewPAGFIM
							nPagFim := m_pag+nPagFim		
							If l1StQb							//// SE FOR A 1ª QUEBRA
								m_pag := nReinicia
								l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
							Endif
						Else
							m_pag := nReinicia
						Endif
					EndIf					
				EndIf					
				CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
				@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1 PSAY STR0023	//"A TRANSPORTAR : "
	 			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais, .T.,cPicture,cNormal)
				li++
			EndIf
	
			@li,000 PSAY cArqTmp->DATAL
			While  dDataAnt == cArqTmp->DATAL .And. cItemAnt == cArqTmp->ITEM
				nVlrDeb	+= cArqTmp->LANCDEB		                                         
				nVlrCrd	+= cArqTmp->LANCCRD		                                         
				dbSkip()                                                                    				
			End		   
			
			nSaldoAtu	:= nSaldoAtu - nVlrDeb + nVlrCrd
			ValorCTB(nVlrDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
					 nDecimais,.F.,cPicture,"1",,,,,,lPrintZero)
			ValorCTB(nVlrCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
					 nDecimais,.F.,cPicture,"2",,,,,,lPrintZero)
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],;
					 nDecimais,.T.,cPicture,cNormal,,,,,,lPrintZero)
			nTotDeb		+= nVlrDeb
			nTotCrd		+= nVlrCrd
			nVlrDeb	:= 0
			nVlrCrd	:= 0
			li++	
		Endif				
		dbSelectArea("cArqTmp")
		if lSaltLin
			li++  //Utiliza na opção Não salta Conta
		Endif
	EndDo	
	If lSaltLin
		li += If(lAnalitico, 0, 1)
    EndIf
	
	If li > 56
		If lSaltLin
			li++
		EndIf
					
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0022) - 1;
					 PSAY STR0022	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais,;
	    	    			   .T.,cPicture,cNormal)
		If lEmissUnica          	
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
		Else
			If m_pag > nPagFim
				If lNewPAGFIM
					nPagFim := m_pag+nPagFim		
					If l1StQb							//// SE FOR A 1ª QUEBRA
						m_pag := nReinicia
						l1StQb := .F.					//// INDICA Q NÃO É MAIS A 1ª QUEBRA
					Endif
				Else
					m_pag := nReinicia
				Endif
			EndIf			
		EndIf
		CtCGCCabec(.F.,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0023) - 1;
					 PSAY STR0023	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais,;
		   	    			   .T.,cPicture,cNormal)
		li++
	EndIf
    
	

	@li,aColunas[If(lAnalitico,COL_HISTORICO,COL_NUMERO)] PSAY STR0017 + Upper(Alltrim(cSayItem)) + " ==> " //"T o t a i s   I t e m  ==> " 
    
	@li, pcol()+1 PSAY "( " 	
	
	If mv_par25 ==1 //Imprime cod. normal Item 
		EntidadeCTB(cItemAnt,li,pcol()+2,20,.F.,cMascara3,cSepara3)
	Else
		dbSelectArea("CTD")
		dbSetOrder(1)
		dbSeek(xFilial()+cItemAnt)  
		cResItem := CTD->CTD_RES
		EntidadeCTB(cResItem,li,pcol()+2,20,.F.,cMascara3,cSepara3)		
	Endif                   		
	@li, pcol()+1 PSAY " )"

	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"1", , , , , ,lPrintZero)
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture,"2", , , , , ,lPrintZero)
	ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
			 .T.,cPicture, , , , , , ,lPrintZero)

	li++
	@li, 00 PSAY Replicate("=",nTamLinha)
	If lSaltLin
	  	li += 2  
	Else         
		li += 1         
	EndIf
	dbSelectArea("cArqTmp")
EndDo	

cFilAnt := cFilOld

If li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIf

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") = 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIf	

dbselectArea("CT2")

MS_FLUSH()

Return


