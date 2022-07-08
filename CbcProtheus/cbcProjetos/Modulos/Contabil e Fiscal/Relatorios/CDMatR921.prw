#INCLUDE "rwmake.ch"

User FUNCTION CDMatR920()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnRel:="MATR920"
Titulo:= "Listagem para escrituracao manual"
cDesc1:= "Emissao de listagem de movimenta‡oes de notas fiscais de entradas e"
cDesc2:= "saidas para transcricao em livros fiscais de escrituracao manual."
cDesc3:= "Ir  imprimir os lancamentos fiscais conforme os parƒmetros informados."
aReturn:= { "Zebrado", 1,"Administra‡„o", 2, 2, 1, "",1 } //###
nomeprog:="MATR920"
cPerg:= "MTR920"
cString:="SF3"
nPagina:=0
nLin:=80
nLargMax:=220
Tamanho:="G"
cArqTemp:=""
aSvArea:={Alias(),IndexOrd(),Recno()}
nPosObs:=0
lConsUF:=.F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas no cabecalho     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMeses	:={"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
cNomEmp	:=Trim(SM0->M0_NOMECOM)
cNomFil :=Trim(SM0->M0_FILIAL)

	AjustaSx1()
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLastKey:=0
	wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.T.)
	If nLastKey==27
		dbClearFilter()
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey==27
		dbClearFilter()
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa relatorio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|lEnd| R920Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

	If aReturn[5]==1
		Set Printer To
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R920Imp  ³ Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Relatorio                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R920Imp(lEnd,wnRel,cString,Tamanho)
LOCAL 	lMatr921:=(existblock("MATR921"))
Local	cIndxSF3	:=""
Local	cChave		:=""
Local	aRegSF3     :={}
Private cArqSF3		:=""
PRIVATE lAbortPrint:=.F.
PRIVATE cTitLivro:=NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe valores dos Parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE dDtIni	:=mv_par01,;
dDtFim		:= mv_par02,;
nTipoMov	:= mv_par03,;
lLacuna 	:= (mv_par04==1 .Or. mv_par04==3),;
nApurICM	:= mv_par05,;
nApurIPI	:= mv_par06,;
cNrLivro	:= mv_par07,;
lServico	:= (mv_par08==1),;
lDesconto	:= (mv_par09==1),;
lImpZer		:= (mv_par10==1),;
nCodigo		:= mv_par11,;
lListaNFO 	:= (mv_par12==1),;
nModelo 	:= Iif (mv_par03==1, 1, 3),;
lEntrada 	:= (mv_par15==1)

PRIVATE	nPagina:=1,cFilterUser:=aReturn[7]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cMV_ESTADO:=SuperGetMv("MV_ESTADO"),;
cContaContab:=NIL
mv_par27 :=2
If nTipoMov==1
	cContaContab:=Alltrim(SuperGetMV("MV_CTALFE"))
	// Retira ref. ao Alias SF3 //
	cContaContab:=StrTran(cContaContab,"SF3->",)
Else
	cContaContab:=Alltrim(SuperGetMV("MV_CTALFS"))
	// Retira ref. ao Alias SF3 //
	cContaContab:=StrTran(cContaContab,"SF3->",)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limite da pagina em linhas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nLimPag:=64,nLinNec:=0
PRIVATE lAglutina:=.F.
PRIVATE lNFInutil:= (mv_par17==1)
PRIVATE lEmiteCiap :=.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena maior tamanho das notas (em linhas)³
//³ [1]=Maior Nota da Pagina                    ³
//³ [2]=Maior Totalizacao de Transporte         ³
//³ [3]=Maior Totalizacao do Dia                ³
//³ [4]=Maior Totalizacao de Periodo ICM        ³
//³ [5]=Maior Totalizacao de Periodo IPI        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nTamNota	:=0,;
nTamTransp	:=0,;
nTamPerICM	:=0,;
nTamPerIPI	:=0,;
aTamNotas	:={0,0,0,0,0}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Totalizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE	aTotDia:=NIL,;		// Totalizador diario
aTotPerICM:=NIL,;	// Totalizador de periodos de apuracao de ICMS
aTotPerIPI:=NIL,;	// Totalizador de periodos de apuracao de IPI
aTransp:=NIL,;		// Totalizador de transporte de pagina
aTotMes:=NIL,;		// Totalizador Mensal
aResumo:=NIL,;		// Totalizador para resumo final
aResCFO:=NIL		// Totalizador para resumo por CFO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para Controle de Contribuintes e Nao Contribuintes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aRegSF3,{"CHAVE"	,"C",100,0})
AADD(aRegSF3,{"CONTR"	,"C",01,0})
AADD(aRegSF3,{"FILIAL"	,"C",02,0})
AADD(aRegSF3,{"MES"		,"C",02,0})
AADD(aRegSF3,{"ANO"		,"C",02,0})
cArqSF3  :=CriaTrab(aRegSF3)
dbUseArea(.T.,,cArqSF3,cArqSF3,.T.,.F.)
cIndxSF3 :=Substr(CriaTrab(NIL,.F.),1,7)+"A"
cChave:="CONTR+CHAVE"
IndRegua(cArqSF3,cIndxSF3,cChave,,,"Criando Controles")

If lMatr921
	U_CDMat921()
	//ExecBlock("MATR921",.F.,.F.)
Else
	U_CDMat921()
	//Matr921()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³Microsiga              ³ Data ³ 09/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Acerta o arquivo de perguntas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSx1()
Local aArea		:= GetArea()
Local aHelpP	:= {}
Local aHelpS	:= {}
Local aHelpE	:= {}

//ÚÄÄÄÄÄÄÄÄÄ¿
//³Portugues³
//ÀÄÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpP, "Na obrigação da escrituracão do livro ")
	Aadd( aHelpP, "de acordo com o Mapa Resumo.  ")
	Aadd( aHelpP, "Somente tem validade esta pergunta, se  ")
	Aadd( aHelpP, "o parâmetro MV_LJLVFIS for igual a 2. ")

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Espanhol³
	//ÀÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpS, "En la obrigación de la escrituración del libro ")
	Aadd( aHelpS, "de acuerdo con el Mapa Resumo.  ")
	Aadd( aHelpS, "Solamente tienda validad la pregunta,  ")
	Aadd( aHelpS, "con el parametro MV_LJLVFIS iqual a 2. ")

	//ÚÄÄÄÄÄÄ¿
	//³Ingles³
	//ÀÄÄÄÄÄÄÙ
	Aadd( aHelpE, "In the obligation of the bookkeeping of the book ")
	Aadd( aHelpE, "in accordance with the Map Summary. ")
	Aadd( aHelpE, "This question only has validity, if ")
	Aadd( aHelpE, "equal parameter MV_LJLVFIS the 2. ")

	PutSx1("MTR920","14","Imprime Mapa Resumo ?","Emite Mapa Resumo ?","Printed Map Summary ?","mv_che","N",01,0,2,"C","MatxRValPer(mv_par14)","","","","mv_par14","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

	aHelpP 	:= {}
	aHelpE 	:= {}
	aHelpS	:= {}

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Portugues³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpP, "Escolha 'Sim' para a impressão de NFs de")
	Aadd( aHelpP, "Entrada, quando o movimento for de Saí- ")
	Aadd( aHelpP, "das, ou escolha 'Não' caso contrário.   ")

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Espanhol³
	//ÀÄÄÄÄÄÄÄÄÙ
	Aadd( aHelpS, "Elija la opcion 'Si' para la impresion  ")
	Aadd( aHelpS, "de las fac. de entrada, cuando el mov.  ")
	Aadd( aHelpS, "sea de salidas, o en caso contrario,    ")
	Aadd( aHelpS, "elija 'No'.                             ")

	//ÚÄÄÄÄÄÄ¿
	//³Ingles³
	//ÀÄÄÄÄÄÄÙ
	Aadd( aHelpE, "Choose 'Yes' to print the inflow invoices")
	Aadd( aHelpE, "when the moviment is an outflow one. On ")
	Aadd( aHelpE, "the contrary, choose 'No'.              ")

	PutSx1("MTR920","15","Impr. NF de Entrada ?","Impr. Fac.de Entrada ?","Print inflow invoice ?","mv_chf","N",01,0,2,"C","","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Portugues³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	aHelpP 	:= {}
	Aadd( aHelpP, "Indica se o relatorio deve listar ")
	Aadd( aHelpP, "operações com isenção de ICMS  ")

	PutSx1("MTR920","16","Impr. Operações isentas ?","Impr. Operações isentas ?","Impr. Operações isentas ?","mv_chg","N",01,0,2,"C","","","","","mv_par16","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpP,aHelpP)

	//Impr. NF Inutil.
	aHelpPor	:=	{}
	aHelpEng	:=	{}
	aHelpSpa	:=	{}

	Aadd(aHelpPor,"Conforme indicado pelo RICMS de seu     ")
	Aadd(aHelpPor,"estado, informe se as notas fiscais     ")
	Aadd(aHelpPor,"inutilizadas deverao ser impressas.     ")

	aHelpSpa := aHelpEng := aHelpPor
	PutSx1("MTR920","17","Impr. NF Inutil. ?","Impr. NF Inutil. ?","Impr. NF Inutil. ?","mv_chh","N",1,0,0,"C","","","","","mv_par17","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	If SX1->(dbSeek (Padr("MTR920",Len(SX1->X1_GRUPO)) + '03')) .And. SX1->X1_DEF02 $ Padr("SaÝdas",Len(SX1->X1_DEF02))
		RecLock('SX1',.F.)
		SX1->X1_DEF02	:=	"Saídas"
		MsUnLock()
	Endif

	aHelpP	:=	{}

	aHelpP:= {'Aglutina a impressão do relatorio por ' ,;
			    'CNPJ+IE respeitando a seleção de filiais ' ,;
			    'realizada pelo usuario. Este tratamento'   ,;
			    'somente sera realizado quando utilizada'   ,;
			    'a pergunta de seleção de filiais.'         ,;
			    'Tratamento disponivel somente para '       ,;
			    'ambientes DBAccess.'         				}
	PutSx1("MTR920","18","Aglutina Por Cnpj + IE?","Aglutina Por Cnpj + IE?","Aglutina Por Cnpj + IE?","mv_chi","N",01,0,2,"C","","","","","MV_PAR18","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP)

	RestArea(aArea)
Return

/*/{Protheus.doc} CDMat921
//TODO Descrição auto-gerada.
@author juliana.leme
@since 26/01/2017
@version undefined

@type function
/*/
User FUNCTION CDMat921()
// Variaveis de controle de multiplas filiais
Local aFilsCalc := {}
Local nForFilial
Local cFilBack  := cFilAnt
Local MVIsento	:= mv_par16

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Variaveis            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lEnd:=.F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Largura do campo de observacoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLargObs:=IIf(nTipoMov==2,28,24)//42/30
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Largura do campo de cod.emitente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLargEmi:=45
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pictures de campos numericos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPictVl:="@E 999,999,999,999.99"	// Colunas Valores
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe layout do modelo escolhido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aL:=NIL
	R921LayOut()

	aFilsCalc := MatFilCalc(MV_PAR13 == 1,,,MV_PAR18 == 1,,Iif(MV_PAR18 == 1,2,0))
	If Empty( aFilsCalc )
		dbSelectArea(cString)
		dbSetOrder(1)
		dbClearFilter()
		Return
	Endif

	For nForFilial := 1 to Len( aFilsCalc )
		If aFilsCalc[nForFilial][1]

			cFilAnt   := Padr(aFilsCalc[nForFilial][2], FWSizeFilial())
			nLin      := 80  // faz a quebra de pagina por filial
			SM0->(DbSeek(cEmpAnt+cFilAnt))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Nome da filial a ser impressa no cabecalho do relatorio.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNomEmp	:=Trim(SM0->M0_NOMECOM)
			cNomFil :=Trim(SM0->M0_FILIAL)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Arquivo a ser Impresso com um indice de mesmo nome            ³
			//³ Ordem (1) = F3_FILIAL+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cArqTemp:=EmiteLivro(If(nTipoMov==1,"E","S"),dDtIni,dDtFim,lLacuna,lServico,lDesconto,cNrLivro,cFilterUser,,2,MV_PAR04,2,cFilAnt,cFilAnt,NIL,"MATR921",MVIsento)

		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Salva periodos de Apuracao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSvApurICM:=DefPeriodo(F3_ENTRADA,nApurICM)
			nSvApurIPI:=DefPeriodo(F3_ENTRADA,nApurIPI)
			If !lAbortPrint
				R921Listagem()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura area ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cArqTemp)

			dbClearFilter()
			dbCloseArea()

			//Cria Planilha de relatorio Protheus
			U_CDCriaXSLArq(cArqTemp)

			Ferase(cArqTemp+GetDBExtension())
			Ferase(cArqTemp+OrdBagExt())
			dbSelectArea(aSvArea[1])
			dbSetOrder(aSvArea[2])
			dbGoto(aSvArea[3])

		EndIf
	   		If FWModeAccess("SF3",3)=="C" .And. aFilsCalc[nForFilial][1]
				Exit
		 	EndIf
	Next nForFilial

	cFilAnt := cFilBack

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R921Listagem   ³Autor³ Juan Jose Pereira  ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Listagem de Entradas/Saidas                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921Listagem

Local ncw		:=	0
Local bFiltro
Local lHistTab   := GetNewPar ("MV_HISTTAB", .F.)
Local cCGC := ""
Local cNome:= ""
Local cEspecie:= ""
Local lRemMerc  := .F.
Local lImprZero	:= GetNewPar ("MV_IMPZNFC",.F.)

	aGrade:=NIL
	dbSelectArea(cArqTemp)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avalia filtro do usuario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dDiaAnt:=F3_ENTRADA
	dDia:=dDiaAnt

	If Empty(cFilterUser)
		bFiltro := { || .T. }
	Else
		bFiltro := &("{ || " + cFilterUser+ " }")
	Endif
	SetRegua(LastRec())
	While !Eof()

		IncRegua()
		If Interrupcao(@lAbortPrint)
			Exit
		Endif

		LivrAcumula(cArqTemp,@aTotDia,@aTotPerICM,@aTotPerIPI,@aTotMes,@aTransp,@aResumo,@aResCFO,,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para nota fiscal de retorno de Remessao em poder de terceiros o       ³
		//³valor contabil deve ser zerado, foi incluido este tratamento para que ³
		//³tanto na impressao da nota fiscal quanto nos totalizadores o sistema  ³
		//³zere o valor contabil quando a nota fiscal for referente a um retorno ³
		//³de remessa. (O tratamento foi copiado do relatorio MATR930)           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If GetNewPar("MV_ESTADO","")=="SP" .And. Alltrim((cArqTemp)->F3_CFO) $ "1904/2904"
		    lRemMerc := .T.
	    Else
		    lRemMerc := .F.
	    EndIf

		If ! Eval(bFiltro)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime os periodos sem movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SEMMOV
				dDia:=F3_ENTRADA
				R921Cabec(dDia)
				FmtLin({"*** NAO HOUVE MOVIMENTO ***"},aL[10],,,@nLin)
				nLin	:=	99
				dbSkip()
				dDia:=F3_ENTRADA
				Loop
			Else
				dbSkip()
				If Eof()
					R921Totais(lRemMerc)
				Endif
				Loop
			Endif
		Else
		    If (!lLacuna .AND. !Empty(F3_DTCANC))
			   dbSelectArea(cArqTemp)
			   dbSkip()
			   If Eof()
			   	  dDia:=F3_ENTRADA
			   	  R921Totais(lRemMerc)
			   Else
				  dbSkip(-1)
			   Endif
		    Endif

			//
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime os periodos sem movimento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SEMMOV
				dDia:=F3_ENTRADA
				R921Cabec(dDia)
				FmtLin({"*** NAO HOUVE MOVIMENTO ***"},aL[10],,,@nLin)
				nLin	:=	99
				dbSkip()
				dDia:=F3_ENTRADA
				Loop
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cabecalho ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin>nLimPag .Or. (Month(dDiaAnt)<>Month(dDia) .Or. Year(dDiaAnt)<>Year(dDia))
				If nLin<60 .And. !(Month(dDiaAnt)<>Month(dDia) .Or. Year(dDiaAnt)<>Year(dDia))
					FmtLin(,aL[01],,,@nLin)
				Endif
				R921Cabec()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Contador de Tamanho de nota ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTamNota:=nLin
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona nos cadastros de Clientes/Fornecedores³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			cEmitente:=""
			cClieFor:=F3_CLIEFOR+F3_LOJA

			If nTipoMov==1
				If F3_TIPO$"DB"
					dbSelectArea("SA1")
				Else
					dbSelectArea("SA2")
				Endif
			Else
				If F3_TIPO$"DB"
					if (substr(F3_CFO,1,3)=="999".and. F3_FORMUL=="S") .Or. (substr(F3_CFO,1,1)$"123".and. F3_FORMUL=="S") // Quando a NF e cancelada, traz o CFOP preenchido e nao 999
						dbSelectArea("SA1")
					else
						dbSelectArea("SA2")
					endif
				Else
					if (substr(F3_CFO,1,3)=="999".and. F3_FORMUL=="S") .Or. (substr(F3_CFO,1,1)$"123".and. F3_FORMUL=="S") // Quando a NF e cancelada, traz o CFOP preenchido e nao 999
						dbSelectArea("SA2")
					else
						dbSelectArea("SA1")
					EndIf
				Endif
			Endif

			dbSeek(F3Filial(Alias())+cClieFor)
			If Alias()=="SA1"
				cEmitente:=If(nCodigo==1,TRIM(A1_COD),Transform(A1_CGC,PicPesFJ(RetPessoa(A1_CGC))))
				cEmitente:=cEmitente+IIf(RetPessoa(A1_CGC)=="F",Space(4),Space(0))+" - "+TRIM(A1_NOME)
			Else
				If lHistTab
					DbSelectArea("AIF")
					AIF->(DbSetOrder(1))
					AIF->(dbSeek(xFilial("AIF")+"  "+"SA2"+SA2->A2_COD+SA2->A2_LOJA+ DTOS(dDia)))
					While !AIF->(Eof()) .And. AIF_TABELA == "SA2" .And. AIF_FILTAB=="  " .And. AIF_CODIGO==SA2->A2_COD .And. AIF_LOJA==SA2->A2_LOJA .And. dDia<AIF->AIF_DATA
							If Alltrim(AIF->AIF_CAMPO)=="A2_CGC" .And. Empty(cCGC)
								cCGC := Alltrim(Transform(AIF->AIF_CONTEU,PicPesFJ(RetPessoa(AIF->AIF_CONTEU))))
							Elseif Alltrim(AIF->AIF_CAMPO)=="A2_NOME" .And. Empty(cNome)
								cNome := Alltrim(AIF->AIF_CONTEU)
							Endif
						DbSkip()
					Enddo
					If cCGC<>"" .And. cNome==""
						cEmitente:=If(nCodigo==1,TRIM(SA2->A2_COD),cCGC)
						cEmitente:=cEmitente+IIf(RetPessoa(SA2->A2_CGC)=="F",Space(4),Space(0))+" - "+TRIM(SA2->A2_NOME)
					Elseif cCGC=="" .And. cNome<>""
						cEmitente:=If(nCodigo==1,TRIM(SA2->A2_COD),Transform(SA2->A2_CGC,PicPesFJ(RetPessoa(SA2->A2_CGC))))+" - "+cNome
					Elseif cCGC<>"" .And. cNome<>""
						cEmitente:=If(nCodigo==1,TRIM(SA2->A2_COD),cCGC)+" - "+cNome
					Else
						cEmitente:=If(nCodigo==1,TRIM(SA2->A2_COD),Transform(SA2->A2_CGC,PicPesFJ(RetPessoa(SA2->A2_CGC))))
						cEmitente:=cEmitente+IIf(RetPessoa(SA2->A2_CGC)=="F",Space(4),Space(0))+" - "+TRIM(SA2->A2_NOME)
					Endif
				 	DbGotop()
				Else
					cEmitente:=Space(1)+ If(nCodigo==1,TRIM(SA2->A2_COD),Transform(SA2->A2_CGC,PicPesFJ(RetPessoa(SA2->A2_CGC))))
					cEmitente:=cEmitente+IIf(RetPessoa(A2_CGC)=="F",Space(4),Space(0))+" - "+TRIM(A2_NOME)
				Endif
				cCGC:=""
				cNome:=""
			Endif
			cEmitente:=Substr(cEmitente,1,nLargEmi)

			If ( substr((cArqTemp)->F3_CFO,1,3) == "999" ) //Notas Canceladas
				cEspecie := a460Especie((cArqTemp)->F3_SERIE)
			EndIf

			dbSelectArea(cArqTemp)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Array com mensagens a serem impressas na coluna de Observacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObs:=LivrArrayObs(nLargObs,,lListaNFO)

			R921IniGrade()

			If lImpZer.or.F3_BASEICM+F3_VALICM>0
				aGrade[1,2]:=F3_BASEICM
				aGrade[1,3]:=F3_VALICM
			Else
				aGrade[1,1]:=""
			Endif

			If lImpZer.or.F3_ISENICM>0
				ncw:=Ascan(aGrade,{|x|x[1]=="" .or. x[1]=="2"})
				aGrade[ncw,1]:="2"
				aGrade[ncw,2]:=F3_ISENICM
			Endif

			If lImpZer.or.F3_OUTRICM>0
				ncw:=Ascan(aGrade,{|x|x[1]=="".or. x[1]=="3"})
				aGrade[ncw,1]:="3"
				aGrade[ncw,2]:=F3_OUTRICM
			Endif

			aGrade[4,2]:=F3_BASEIPI
			aGrade[4,3]:=F3_VALIPI

			aGrade[5,2]:=F3_ISENIPI
			aGrade[6,2]:=F3_OUTRIPI

			aDados:=Array(16)
			aDados[1]:=If(nTipoMov==1,DTOC(F3_ENTRADA),DTOC(F3_EMISSAO))
			aDados[2]:=If(Empty(F3_ESPECIE),If((Substr(F3_CFO,2,2)$"62").OR.(Substr(F3_CFO,2,3)$"352"),"CT",Iif(!Empty(cEspecie),cEspecie,"NF")),F3_ESPECIE) //###
			aDados[3]:=F3_SERIE
			aDados[4]:=F3_NFISCAL+" A "+IF(F3_TIPO$"L",F3_DOCOR,F3_NFISCAL)
			aDados[5]:=If(nTipoMov==1,DTOC(F3_EMISSAO),)
			aDados[6]:=cEmitente
			aDados[7]:=F3_ESTADO

			If Empty(F3_DTCANC) .Or. lImprZero
				aDados[8]:=Iif(lRemMerc,0,F3_VALCONT)
				aDados[9]:=EvalMacro(cContaContabil)
				aDados[10]:=If(substr(F3_CFO,1,3)$"999#000",,Transform(F3_CFO,PESQPICT("SF3","F3_CFO")))	//F3_CFO
				aDados[14]:=Transform(F3_ALIQICM,"@ZE 99.99")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime Linhas de detalhe              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				R921ImpGrade()
			Endif

			nPosObs:=Ascan(aObs,{|x|x[2]})
			While nPosObs>0
				R921LoadObs()
				If nPosObs>0
					FmtLin(@aDados,aL[9],cPictVl,,@nLin)
				Endif
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula valores ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nLinNec:=nLin-nTamNota
			aTamNotas[1]:=Max(aTamNotas[1],nLinNec)

			dDiaAnt:=F3_ENTRADA
			dbSelectArea(cArqTemp)
			dbSkip()
			If Empty(F3_ENTRADA)
			   dDiaAnt := dDia
			Endif
			dDia:=F3_ENTRADA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Totais e finaliza relatorio ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			R921Totais(lRemMerc)
		Endif
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando mudar a filial, reinicia os totalizadores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotDia    := NIL
	aTotPerICM := NIL
	aTotPerIPI := NIL
	aTotMes    := NIL
	aTransp    := NIL
	aResumo    := NIL
	aResCFO    := NIL

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921Cabec ³Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Cabecalho                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921Cabec

	cPeriodo:=""
	If !Empty(dDiaAnt) .Or. !Empty(dDia)
		cPeriodo:=aMeses[Month(IIf(Empty(dDia),dDiaAnt,dDia))]+" / "+Str(Year(IIf(Empty(dDia),dDiaAnt,dDia)),4)
	Endif
	cPagina :=StrZero(nPagina++,6)
	cTitulo:=If(nTipoMov==1,"ENTRASAS","SAIDAS") //"ENTRADAS"###"SAIDAS"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Cabecalho  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLin:=0
	FmtLin(,AvalImp(nLargMax),,,@nLin)
	FmtLin({cNomEmp+" - " + "Filial : " + cFilAnt+" "+cNomFil,cTitulo,cPagina},aL[1],,,@nLin) //
	FmtLin(,aL[2],,,@nLin)
	FmtLin({cPeriodo},aL[3],,,@nLin)
	FmtLin(,{aL[4],aL[5],aL[6],aL[7],aL[8]},,,@nLin)

	Return
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ R921LayOut³Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Layout da Listagem                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	STATIC FUNCTION R921LayOut

	//aL[00]:=0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	//aL[00]:=01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	aL:=Array(10)

	aL[01]:="#################################################################                                    REGISTRO DE ########                                                                                      PAGINA ######"
	aL[02]:=""
	If nTipoMov==1
		aL[03]:="MES OU PERIODO/ANO: #######                                                                                                                                                               ----------- OPERACOES ------------"
		aL[04]:="                                                                                                                                                                                          (1)TRIBUTADAS (2)ISENTAS (3)OUTRAS"
		aL[05]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		aL[06]:="  DT       ESPE  SE                        DT                                                                                                  ICMS OPERACOES"
		aL[07]:="ENTRADA    CIE   RIE        NUMERO         EMISSAO                     EMITENTE                   UF     VALOR CONTABIL CONTA CONTABIL       CFO  IPI (*)    BASE DE CALCULO ALIQ    VALOR DO IMPOSTO           OBSERVACOES "
		aL[08]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	    aL[09]:="########## ##### ### ##################### ######## ############################################# ## ################## #################### ##### #### # ################## ####### ################ ######################"
		//          [1]     [2]   [3]      [4]           [5]   <------------[6]------45--------------------> [7]      [8]               [9]            [10] [11][12]       [13]         [14]         [15]        <-------------35-[16]----------->
		//       x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789
		//		 0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	Else
		aL[03]:="MES OU PERIODO/ANO: #######                                                                                                                                                               ----------- OPERACOES ------------"
		aL[04]:="                                                                                                                                                                                          (1)TRIBUTADAS (2)ISENTAS (3)OUTRAS"
		aL[05]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
		aL[06]:="  DT       ESPE  SE                                                                                                                 ICMS OPERACOES"
		aL[07]:="EMISSAO    CIE   RIE        NUMERO                              EMITENTE                   UF     VALOR CONTABIL CONTA CONTABIL       CFO  IPI (*)    BASE DE CALCULO ALIQ    VALOR DO IMPOSTO                  OBSERVACOES "
		aL[08]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	    aL[09]:="########## ##### ### ##################### # ############################################# ## ################## #################### ##### #### # ################## ####### ################ #############################"
		//          [1]     [2]   [3]       [4]      [5]<------------[6]------45--------------------> [7]      [8]               [9]            [10] [11][12]       [13]         [14]         [15]        <-------------------42-[16]------------>
		//       x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789x123456789
		//		 0         10        20        30        40        50        60        70        80        90        100       110       120       130       140       150       160       170       180       190       200       210       220
	Endif
	aL[10]:="#################################################################################"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921Transp³Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime linhas de transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921Transp(lRemMerc)

	nMaior:=0
	AEval(aTamNotas,{|x|nMaior:=Max(nMaior,x)})
	aTamNotas[2]:=nMaior

	nLinNec:=aTamNotas[2]
	lTransp:=(nLimPag<=nLin+nLinNec)

	lTransp2 := Iif((60-nLin)>8,.F.,.T.)

	If lTransp2
		nTamTransp:=nLin

		aObs:=LivrArrayObs(nLargObs,aTotMes)

		R921IniGrade()

		aGrade[1,2]:=aTransp[ColF3("F3_BASEICM")]
		aGrade[1,3]:=aTransp[ColF3("F3_VALICM")]
		aGrade[2,2]:=aTransp[ColF3("F3_ISENICM")]
		aGrade[3,2]:=aTransp[ColF3("F3_OUTRICM")]

		aGrade[4,2]:=aTransp[ColF3("F3_BASEIPI")]
		aGrade[4,3]:=aTransp[ColF3("F3_VALIPI")]
		aGrade[5,2]:=aTransp[ColF3("F3_ISENIPI")]
		aGrade[6,2]:=aTransp[ColF3("F3_OUTRIPI")]

		aDados:=Array(16)
		FmtLin(@aDados,aL[9],,,@nLin)
		aDados[6]:="A TRANSPORTAR"
		aDados[8]:=Iif(lRemMerc,0,aTransp[ColF3("F3_VALCONT")])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Linhas de detalhe              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R921ImpGrade()

		nPosObs:=Ascan(aObs,{|x|x[2]})
		While nPosObs>0
			R921LoadObs()
			If nPosObs>0
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
			Endif
		End

		nLinNec:=nLin-nTamTransp
		aTamNotas[2]:=Max(aTamNotas[2],nLinNec)

		R921Cabec()
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921Totdia³Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime total do dia                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921TotDia(lRemMerc)

	lTotDia:=(dDiaAnt!=dDia)

	If lTotDia .Or. Eof()
		aTamNotas[3]:=Max(aTamNotas[3],nLinNec)
		nLinNec:=aTamNotas[3]

		If nLimPag<=nLin+nLinNec
			R921Transp(lRemMerc)
		Endif

		nTamTotDia:=nLin
		aObs:=LivrArrayObs(nLargObs,aTotDia)

		R921IniGrade()

		If	aTotDia[ColF3("F3_BASEICM")]>0
			aGrade[1,2]:=aTotDia[ColF3("F3_BASEICM")]
		Endif
		If aTotDia[ColF3("F3_VALICM")]>0
			aGrade[1,3]:=aTotDia[ColF3("F3_VALICM")]
		Endif
		If aTotDia[ColF3("F3_ISENICM")]>0
			aGrade[2,2]:=aTotDia[ColF3("F3_ISENICM")]
		Endif
		If aTotDia[ColF3("F3_OUTRICM")]>0
			aGrade[3,2]:=aTotDia[ColF3("F3_OUTRICM")]
		Endif

		aGrade[4,2]:=aTotDia[ColF3("F3_BASEIPI")]
		aGrade[4,3]:=aTotDia[ColF3("F3_VALIPI")]
		aGrade[5,2]:=aTotDia[ColF3("F3_ISENIPI")]
		aGrade[6,2]:=aTotDia[ColF3("F3_OUTRIPI")]

		aDados:=Array(16)
		FmtLin(@aDados,aL[9],,,@nLin)
		aDados[6]:= "TOTAL DO DIA "+StrZero(Day(dDiaAnt),2)
		aDados[8]:= Iif(lRemMerc,0,aTotDia[ColF3("F3_VALCONT")])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Linhas de detalhe              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R921ImpGrade()

		nPosObs:=Ascan(aObs,{|x|x[2]})
		While nPosObs>0
			R921LoadObs()
			If nPosObs>0
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
			Endif
		End

		FmtLin(@aDados,aL[9],,,@nLin)
		nLinNec:=nLin-nTamTotDia
		aTamNotas[3]:=Max(aTamNotas[3],nLinNec)
	Endif
	If lTotDia
		Afill(aTotDia,0)
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921TotMes³Autor ³ Juan Jose Pereira     ³ Data ³ 18.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime total do Mes                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921TotMes(lRemMerc)

	lTotMes:=(Month(dDiaAnt)!=Month(dDia))

	If lTotMes .Or. Eof()
		If nLin>=nLimPag
			R921Transp(lRemMerc)
		Endif
		aObs:=LivrArrayObs(nLargObs,aTotMes)

		R921IniGrade()

		If	aTotMes[ColF3("F3_BASEICM")]>0
			aGrade[1,2]:=aTotMes[ColF3("F3_BASEICM")]
		Endif
		If aTotMes[ColF3("F3_VALICM")]>0
			aGrade[1,3]:=aTotMes[ColF3("F3_VALICM")]
		Endif
		If aTotMes[ColF3("F3_ISENICM")]>0
			aGrade[2,2]:=aTotMes[ColF3("F3_ISENICM")]
		Endif
		If aTotMes[ColF3("F3_OUTRICM")]>0
			aGrade[3,2]:=aTotMes[ColF3("F3_OUTRICM")]
		Endif

		aGrade[4,2]:=aTotMes[ColF3("F3_BASEIPI")]
		aGrade[4,3]:=aTotMes[ColF3("F3_VALIPI")]
		aGrade[5,2]:=aTotMes[ColF3("F3_ISENIPI")]
		aGrade[6,2]:=aTotMes[ColF3("F3_OUTRIPI")]

		aDados:=Array(16)
		FmtLin(@aDados,aL[9],,,@nLin)
		aDados[6]:= "TOTAL DO MES"
		aDados[8]:=Iif(lRemMerc,0,aTotMes[ColF3("F3_VALCONT")])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Linhas de detalhe              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R921ImpGrade()

		nPosObs:=Ascan(aObs,{|x|x[2]})
		While nPosObs>0
			R921LoadObs()
			If nPosObs>0
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
			Endif
		End

		FmtLin(@aDados,aL[9],,,@nLin)
	Endif
	If lTotMes .Or. Eof()
		Afill(aTransp,0)
		Afill(aTotMes,0)
		Afill(aTamNotas,0)
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921TotPer³Autor ³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime total do periodo de apuracao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921TotPer(lRemMerc)
Local nX :=0

	lTotPerICM:=(nSvApurICM!=DefPeriodo(dDia,nApurICM))
	lTotPerIPI:=(nSvApurIPI!=DefPeriodo(dDia,nApurIPI))

	nLinNec2:=0
	If lTotPerICM
		aTamNotas[4]:=Max(aTamNotas[4],nLinNec)
		nLinNec2:=nLinNec2+aTamNotas[4]
	Endif
	If lTotPerIPI
		aTamNotas[5]:=Max(aTamNotas[5],nLinNec)
		nLinNec2:=nLinNec2+aTamNotas[5]
	Endif

	If lTotPerICM.or.lTotPerIPI
		nLinNec:=nLinNec2
		If nLimPag<=nLin+nLinNec
			R921Transp(lRemMerc)
		Endif

		aObs:=LivrArrayObs(nLargObs,aTotPerICM)

		R921IniGrade()

		If lTotPerICM
			aGrade[1,2]:=aTotPerICM[ColF3("F3_BASEICM")]
			aGrade[1,3]:=aTotPerICM[ColF3("F3_VALICM")]
			aGrade[2,2]:=aTotPerICM[ColF3("F3_ISENICM")]
			aGrade[3,2]:=aTotPerICM[ColF3("F3_OUTRICM")]
		Endif
		If lTotPerIPI
			aGrade[4,2]:=aTotPerIPI[ColF3("F3_BASEIPI")]
			aGrade[4,3]:=aTotPerIPI[ColF3("F3_VALIPI")]
			aGrade[5,2]:=aTotPerIPI[ColF3("F3_ISENIPI")]
			aGrade[6,2]:=aTotPerIPI[ColF3("F3_OUTRIPI")]
		Endif
		aDados:=Array(16)

		nTamTotPer:=nLin
		cICM:="ICMS"
		cIPI:="IPI"
		nTotVContICM:=Iif(lRemMerc,0,aTotPerICM[ColF3("F3_VALCONT")])
		nTotVContIPI:=Iif(lRemMerc,0,aTotPerIPI[ColF3("F3_VALCONT")])

		lImprime:=.F.
		For nx:=1 to Len(aGrade)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Colunas de ICMS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTotPerICM.and.nx<=3
				If !lImpZer.and.aGrade[nx,2]+aGrade[nx,3]==0
					Loop
				Endif
				If !Empty(cICM)
					aDados[6]:= "TOTAL DO PERIODO"
					aDados[8]:=nTotVContICM
					aDados[11]:="ICMS"
					cICM:=""
				Endif
				aDados[12]:=aGrade[nx,1]
				aDados[13]:=aGrade[nx,2]
				aDados[15]:=aGrade[nx,3]
				lImprime:=.T.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Colunas de IPI³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTotPerIPI.and.nx>3
				If !lImpZer.and.aGrade[nx,2]+aGrade[nx,3]==0
					Loop
				Endif
				If !Empty(cIPI)
					aDados[6]:= "TOTAL DO PERIODO"
					aDados[8]:=nTotVContIPI
					aDados[11]:="IPI"
					cIPI:=""
				Endif
				aDados[12]:=aGrade[nx,1]
				aDados[13]:=aGrade[nx,2]
				aDados[15]:=aGrade[nx,3]
				lImprime:=.T.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Coluna de Observacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTotPerICM
				R921LoadObs()
			Endif
			If lImprime
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
				lImprime:=.F.
			Endif

		If lTotPerICM
			nPosObs:=Ascan(aObs,{|x|x[2]})
			While nPosObs>0
				R921LoadObs()
				If nPosObs>0
					FmtLin(@aDados,aL[9],cPictVl,,@nLin)
				Endif
			End
		Endif
		Next nx

		If lTotPerICM
			nLinNec:=nLin-nTamTotPer
			aTamNotas[4]:=Max(aTamNotas[4],nLinNec)
		Endif
		If lTotPerIPI
			nLinNec:=nLin-nTamTotPer
			aTamNotas[5]:=Max(aTamNotas[5],nLinNec)
		Endif
		FmtLin(@aDados,aL[9],,,@nLin)

		If lTotPerICM
			aFill(aTotPerICM,0)
			nSvApurICM:=DefPeriodo(dDia,nApurICM)
		Endif
		If lTotPerIPI
			aFill(aTotPerIPI,0)
			nSvApurIPI:=DefPeriodo(dDia,nApurIPI)
		Endif
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921ResCfo³Autor ³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo por CFO                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921ResCfo(lRemMerc)
Local i	:=0

	If !Eof().or.Len(aResCFO)==0
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena CFOs³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResCFO:=Asort(aResCFO,,,{|x,y|x[ColF3("F3_CFO")]<y[ColF3("F3_CFO")]})

	aCFOS:={	"1.00 ENTRADAS DO ESTADO",; //
				"2.00 ENTRADAS DE FORA DO ESTADO",; //
				"3.00 ENTRADAS DO EXTERIOR",; //
				"",;
				"5.00 SAIDAS PARA O ESTADO",; //
				"6.00 SAIDAS PARA FORA DO ESTADO",; //
				"7.00 SAIDAS PARA O EXTERIOR"} //

	cSvCFO:="X"
	nLin:=80
	For i:=1 to Len(aResCFO)
		If nLin>nLimPag .Or. nLin > 75
			R921Cabec()
		EndIf
		aObs:=LivrArrayObs(nLargObs,aResCFO[i])
		cCFO:=Trim(aResCFO[i,ColF3("F3_CFO")])

		R921IniGrade()

		If aResCFO[i,ColF3("F3_BASEICM")]>0
			aGrade[1,2]:=aResCFO[i,ColF3("F3_BASEICM")]
		Endif
		If aResCFO[i,ColF3("F3_VALICM")]>0
			aGrade[1,3]:=aResCFO[i,ColF3("F3_VALICM")]
		Endif
		If aResCFO[i,ColF3("F3_ISENICM")]>0
			aGrade[2,2]:=aResCFO[i,ColF3("F3_ISENICM")]
		Endif
		If aResCFO[i,ColF3("F3_OUTRICM")]>0
			aGrade[3,2]:=aResCFO[i,ColF3("F3_OUTRICM")]
		Endif

		aGrade[4,2]:=aResCFO[i,ColF3("F3_BASEIPI")]
		aGrade[4,3]:=aResCFO[i,ColF3("F3_VALIPI")]
		aGrade[5,2]:=aResCFO[i,ColF3("F3_ISENIPI")]
		aGrade[6,2]:=aResCFO[i,ColF3("F3_OUTRIPI")]

		aDados:=Array(16)
	    If !(Substr(cCFO,1,1)==cSvCFO).and.!(ALLTRIM(cCFO)$"TTT") .And. !Empty (cCFO)
			FmtLin(@aDados,aL[9],,,@nLin)
			cSvCFO:=Substr(cCFO,1,1)
			aDados[6]:=aCFOS[Val(cSvCFO)]
			FmtLin(@aDados,aL[9],,,@nLin)
			aDados[6]:=Replic("=",Len(aCFOS[Val(cSvCFO)]))
			FmtLin(@aDados,aL[9],,,@nLin)
		Endif
		If ("TT"$cCFO)
			FmtLin(@aDados,aL[9],,,@nLin)
	        aDados[6]:=If(ALLTRIM(cCFO)=="TTT","TOTAL GERAL","TOTAL") //###
		Else
			aDados[10]:=cCFO
		Endif
		aDados[8]:=Iif(lRemMerc, 0 ,aResCFO[i,ColF3("F3_VALCONT")])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime Linhas de detalhe              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R921ImpGrade()

		nPosObs:=Ascan(aObs,{|x|x[2]})
		While nPosObs>0
			R921LoadObs()
			If nPosObs>0
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
			Endif
		End
	Next i

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R921ResEst³Autor ³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Resumo por Estado                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921ResEst(lRemMerc)
Local i :=0
Local j	:=0
	If !Eof().or.Len(aResumo)==0
		Return
	Endif

	nLin:=80
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arranja o resumo em ordem de CFO e Estado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResumo:=ASort(aResumo,,,{|x,y|x[1]+x[2]<y[1]+y[2]})
	lFirstCO:=.T.
	lFirstNC:=.T.
	For i:=1 to Len(aResumo)
		If nLin>nLimPag
			R921Cabec()
		Endif
		aDados:=Array(16)
		If i==1
			FmtLin(@aDados,aL[9],,,@nLin)
			aDados[8]:="DEMONSTRATIVO POR ESTADO DE ORIGEM DA MERCADORIA OU DE INICIO DA PRESTACAO DE SERVICO"
			FmtLin(@aDados,aL[9],,,@nLin)
			aDados[8]:="====================================================================================="
			FmtLin(@aDados,aL[9],,,@nLin)
			FmtLin(@aDados,aL[9],,,@nLin)
		Endif
		aGrade:={}
		If aResumo[i,4]>0
			AADD(aGrade,{"1",aResumo[i,4]})
		Endif
		If aResumo[i,7]>0
			AADD(aGrade,{"2",aResumo[i,7]})
		Endif
		If aResumo[i,5]>0
			AADD(aGrade,{"3",aResumo[i,5]})
		Endif
		aDados[7]:=aResumo[i,2]
		aDados[8]:=Iif(lRemMerc,0,aResumo[i,3])
		If aResumo[i,6]>0
			aDados[16]:= "ICMS RETIDO...: " + Alltrim(Transform(aResumo[i,6],PesqPict("SF3","F3_ICMSRET"))) //
		Endif
		For j:=1 to Len(aGrade)
			aDados[12]:=aGrade[j,1]
			aDados[13]:=aGrade[j,2]
			FmtLin(@aDados,aL[9],cPictVl,,@nLin)
		Next j

	Next i

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R921LoadObs³Autor ³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega observacao para ser impressa                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921LoadObs

	nPosObs:=Ascan(aObs,{|x|x[2]})
	If nPosObs>0
		aDados[16]:=aObs[nPosObs,1]
		aObs[nPosObs,2]:=.F.
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R921Totais ³Autor ³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aciona funcoes de totalizacao                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921Totais(lRemMerc)
	R921Transp(lRemMerc)
	R921TotDia(lRemMerc)
	R921TotPer(lRemMerc)
	R921TotMes(lRemMerc)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Resumo por CFO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R921ResCfo(lRemMerc)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Resumo por Estado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	R921ResEst(lRemMerc)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R921IniGrade³Autor³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa array aGrade do registro de entradas            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921IniGrade
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta grade de impressao            ³
	//³ [1]=Codigo de Operacao              ³
	//³ [2]=Base / Isentas / Outras         ³
	//³ [3]=Valor do imposto                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aGrade:=Array(6)
	aGrade[1]:={"1",0,0} //
	aGrade[2]:={"2",0,0} // ICMS
	aGrade[3]:={"3",0,0} //
	aGrade[4]:={"1",0,0} //
	aGrade[5]:={"2",0,0} // IPI
	aGrade[6]:={"3",0,0} //

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R921ImpGrade³Autor³ Juan Jose Pereira     ³ Data ³ 23.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime aGrade do registro de entradas                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION R921ImpGrade

Local nVlrCont:=aDados[8]
Local nX :=0

	cICMS:="ICMS"
	cIPI :="IPI"
	For nx:=1 to Len(aGrade)
		If !lImpZer.and.(aGrade[nx,2]+aGrade[nx,3]+IIf(nx==1,nVlrCont,0))==0
			Loop
		Endif
		If nx<=3
			aDados[11]:=cICMS
			cICMS:=""
		Else
			aDados[11]:=cIPI
			cIPI:=""
		Endif
		aDados[12]:=aGrade[nx,1]
		aDados[13]:=aGrade[nx,2]
		aDados[15]:=aGrade[nx,3]
		R921LoadObs()
		FmtLin(@aDados,aL[9],cPictVl,,@nLin)
		//
		nPosObs:=Ascan(aObs,{|x|x[2]})
		While nPosObs>0
			R921LoadObs()
			If nPosObs>0
				FmtLin(@aDados,aL[9],cPictVl,,@nLin)
			Endif
		End
	Next nx

Return


User Function CDCriaXSLArq(_cNomArq)
Local aFiles := {}

	aFiles := ARRAY(ADIR("C:\INTEGRA\*.*"))
	ADIR("C:\INTEGRA\*.*",aFiles)

	If Len(aFiles) == 0
		MAKEDIR("C:\INTEGRA") //  --> Numérico
	EndIf

	If File("C:\INTEGRA\CDFATR04.DTC")
		FErase("C:\INTEGRA\FECHBIT.DTC") // Apagar Arquivo de Consolidacao Anterior Se Existir
	Endif

	_cNomArq := _cNomArq+".DTC"
	CPYS2T(_cNomArq,"C:\INTEGRA",.F.)

	If !ApOleClient("MsExcel")
		MsgBox("Microsoft Excel Não Instalado nesta Máquina !!!", "Atenção !!!", "INFO")
	Else
		_cNomArq := "C:\INTEGRA\" + _cNomArq
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(_cNomArq)
		oExcelApp:SetVisible(.T.)
	EndIf

Return()