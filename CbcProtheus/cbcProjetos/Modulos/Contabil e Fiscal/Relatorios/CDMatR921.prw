#INCLUDE "rwmake.ch"

User FUNCTION CDMatR920()
//旼컴컴컴컴컴컴컴컴커
//? Define Variaveis ?
//읕컴컴컴컴컴컴컴컴켸
wnRel:="MATR920"
Titulo:= "Listagem para escrituracao manual"
cDesc1:= "Emissao de listagem de movimenta뇇es de notas fiscais de entradas e"
cDesc2:= "saidas para transcricao em livros fiscais de escrituracao manual."
cDesc3:= "Ir? imprimir os lancamentos fiscais conforme os par긩etros informados."
aReturn:= { "Zebrado", 1,"Administra뇙o", 2, 2, 1, "",1 } //###
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
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Variaveis utilizadas no cabecalho     ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
aMeses	:={"JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"}
cNomEmp	:=Trim(SM0->M0_NOMECOM)
cNomFil :=Trim(SM0->M0_FILIAL)

	AjustaSx1()
	Pergunte(cPerg,.F.)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Envia controle para a funcao SETPRINT ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//? Executa relatorio                                            ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	RptStatus({|lEnd| R920Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

	If aReturn[5]==1
		Set Printer To
		ourspool(wnrel)
	Endif
	MS_FLUSH()

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R920Imp  ? Autor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime Relatorio                                          낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R920Imp(lEnd,wnRel,cString,Tamanho)
LOCAL 	lMatr921:=(existblock("MATR921"))
Local	cIndxSF3	:=""
Local	cChave		:=""
Local	aRegSF3     :={}
Private cArqSF3		:=""
PRIVATE lAbortPrint:=.F.
PRIVATE cTitLivro:=NIL
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Recebe valores dos Parametros ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
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
//旼컴컴컴컴컴컴컴컴컴?
//? Recebe parametros ?
//읕컴컴컴컴컴컴컴컴컴?
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Limite da pagina em linhas?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴?
PRIVATE nLimPag:=64,nLinNec:=0
PRIVATE lAglutina:=.F.
PRIVATE lNFInutil:= (mv_par17==1)
PRIVATE lEmiteCiap :=.T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Armazena maior tamanho das notas (em linhas)?
//? [1]=Maior Nota da Pagina                    ?
//? [2]=Maior Totalizacao de Transporte         ?
//? [3]=Maior Totalizacao do Dia                ?
//? [4]=Maior Totalizacao de Periodo ICM        ?
//? [5]=Maior Totalizacao de Periodo IPI        ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
PRIVATE nTamNota	:=0,;
nTamTransp	:=0,;
nTamPerICM	:=0,;
nTamPerIPI	:=0,;
aTamNotas	:={0,0,0,0,0}
//旼컴컴컴컴컴컴컴컴컴컴커
//? Define Totalizadores ?
//읕컴컴컴컴컴컴컴컴컴컴켸
PRIVATE	aTotDia:=NIL,;		// Totalizador diario
aTotPerICM:=NIL,;	// Totalizador de periodos de apuracao de ICMS
aTotPerIPI:=NIL,;	// Totalizador de periodos de apuracao de IPI
aTransp:=NIL,;		// Totalizador de transporte de pagina
aTotMes:=NIL,;		// Totalizador Mensal
aResumo:=NIL,;		// Totalizador para resumo final
aResCFO:=NIL		// Totalizador para resumo por CFO

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//? Cria Arquivo Temporario para Controle de Contribuintes e Nao Contribuintes ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑uncao    쿌justaSX1 ? Autor 쿘icrosiga              ? Data ? 09/05/08 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escricao 쿌certa o arquivo de perguntas                               낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇쿝etorno   쿙enhum                                                      낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
/*/
Static Function AjustaSx1()
Local aArea		:= GetArea()
Local aHelpP	:= {}
Local aHelpS	:= {}
Local aHelpE	:= {}

//旼컴컴컴컴?
//쿛ortugues?
//읕컴컴컴컴?
	Aadd( aHelpP, "Na obriga豫o da escriturac?o do livro ")
	Aadd( aHelpP, "de acordo com o Mapa Resumo.  ")
	Aadd( aHelpP, "Somente tem validade esta pergunta, se  ")
	Aadd( aHelpP, "o par?metro MV_LJLVFIS for igual a 2. ")

	//旼컴컴컴커
	//쿐spanhol?
	//읕컴컴컴켸
	Aadd( aHelpS, "En la obrigaci?n de la escrituraci?n del libro ")
	Aadd( aHelpS, "de acuerdo con el Mapa Resumo.  ")
	Aadd( aHelpS, "Solamente tienda validad la pregunta,  ")
	Aadd( aHelpS, "con el parametro MV_LJLVFIS iqual a 2. ")

	//旼컴컴커
	//쿔ngles?
	//읕컴컴켸
	Aadd( aHelpE, "In the obligation of the bookkeeping of the book ")
	Aadd( aHelpE, "in accordance with the Map Summary. ")
	Aadd( aHelpE, "This question only has validity, if ")
	Aadd( aHelpE, "equal parameter MV_LJLVFIS the 2. ")

	PutSx1("MTR920","14","Imprime Mapa Resumo ?","Emite Mapa Resumo ?","Printed Map Summary ?","mv_che","N",01,0,2,"C","MatxRValPer(mv_par14)","","","","mv_par14","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

	aHelpP 	:= {}
	aHelpE 	:= {}
	aHelpS	:= {}

	//旼컴컴컴컴?
	//쿛ortugues?
	//읕컴컴컴컴?
	Aadd( aHelpP, "Escolha 'Sim' para a impress?o de NFs de")
	Aadd( aHelpP, "Entrada, quando o movimento for de Sa?- ")
	Aadd( aHelpP, "das, ou escolha 'N?o' caso contr?rio.   ")

	//旼컴컴컴커
	//쿐spanhol?
	//읕컴컴컴켸
	Aadd( aHelpS, "Elija la opcion 'Si' para la impresion  ")
	Aadd( aHelpS, "de las fac. de entrada, cuando el mov.  ")
	Aadd( aHelpS, "sea de salidas, o en caso contrario,    ")
	Aadd( aHelpS, "elija 'No'.                             ")

	//旼컴컴커
	//쿔ngles?
	//읕컴컴켸
	Aadd( aHelpE, "Choose 'Yes' to print the inflow invoices")
	Aadd( aHelpE, "when the moviment is an outflow one. On ")
	Aadd( aHelpE, "the contrary, choose 'No'.              ")

	PutSx1("MTR920","15","Impr. NF de Entrada ?","Impr. Fac.de Entrada ?","Print inflow invoice ?","mv_chf","N",01,0,2,"C","","","","","mv_par15","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpE,aHelpS)

	//旼컴컴컴컴?
	//쿛ortugues?
	//읕컴컴컴컴?
	aHelpP 	:= {}
	Aadd( aHelpP, "Indica se o relatorio deve listar ")
	Aadd( aHelpP, "opera寤es com isen豫o de ICMS  ")

	PutSx1("MTR920","16","Impr. Opera寤es isentas ?","Impr. Opera寤es isentas ?","Impr. Opera寤es isentas ?","mv_chg","N",01,0,2,"C","","","","","mv_par16","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP,aHelpP,aHelpP)

	//Impr. NF Inutil.
	aHelpPor	:=	{}
	aHelpEng	:=	{}
	aHelpSpa	:=	{}

	Aadd(aHelpPor,"Conforme indicado pelo RICMS de seu     ")
	Aadd(aHelpPor,"estado, informe se as notas fiscais     ")
	Aadd(aHelpPor,"inutilizadas deverao ser impressas.     ")

	aHelpSpa := aHelpEng := aHelpPor
	PutSx1("MTR920","17","Impr. NF Inutil. ?","Impr. NF Inutil. ?","Impr. NF Inutil. ?","mv_chh","N",1,0,0,"C","","","","","mv_par17","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	If SX1->(dbSeek (Padr("MTR920",Len(SX1->X1_GRUPO)) + '03')) .And. SX1->X1_DEF02 $ Padr("Sa?das",Len(SX1->X1_DEF02))
		RecLock('SX1',.F.)
		SX1->X1_DEF02	:=	"Sa?das"
		MsUnLock()
	Endif

	aHelpP	:=	{}

	aHelpP:= {'Aglutina a impress?o do relatorio por ' ,;
			    'CNPJ+IE respeitando a sele豫o de filiais ' ,;
			    'realizada pelo usuario. Este tratamento'   ,;
			    'somente sera realizado quando utilizada'   ,;
			    'a pergunta de sele豫o de filiais.'         ,;
			    'Tratamento disponivel somente para '       ,;
			    'ambientes DBAccess.'         				}
	PutSx1("MTR920","18","Aglutina Por Cnpj + IE?","Aglutina Por Cnpj + IE?","Aglutina Por Cnpj + IE?","mv_chi","N",01,0,2,"C","","","","","MV_PAR18","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpP)

	RestArea(aArea)
Return

/*/{Protheus.doc} CDMat921
//TODO Descri豫o auto-gerada.
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//? Inicializa Variaveis            ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
Private lEnd:=.F.

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Largura do campo de observacoes ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	nLargObs:=IIf(nTipoMov==2,28,24)//42/30
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Largura do campo de cod.emitente?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	nLargEmi:=45
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//? Pictures de campos numericos ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cPictVl:="@E 999,999,999,999.99"	// Colunas Valores
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Recebe layout do modelo escolhido ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
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

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿙ome da filial a ser impressa no cabecalho do relatorio.?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cNomEmp	:=Trim(SM0->M0_NOMECOM)
			cNomFil :=Trim(SM0->M0_FILIAL)

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//? Cria Arquivo a ser Impresso com um indice de mesmo nome            ?
			//? Ordem (1) = F3_FILIAL+DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_CFO  ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cArqTemp:=EmiteLivro(If(nTipoMov==1,"E","S"),dDtIni,dDtFim,lLacuna,lServico,lDesconto,cNrLivro,cFilterUser,,2,MV_PAR04,2,cFilAnt,cFilAnt,NIL,"MATR921",MVIsento)

		   	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//? Salva periodos de Apuracao ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			nSvApurICM:=DefPeriodo(F3_ENTRADA,nApurICM)
			nSvApurIPI:=DefPeriodo(F3_ENTRADA,nApurIPI)
			If !lAbortPrint
				R921Listagem()
			Endif
			//旼컴컴컴컴컴컴컴?
			//? Restaura area ?
			//읕컴컴컴컴컴컴컴?
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컴컴컫컴컴컫컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    쿝921Listagem   쿌utor? Juan Jose Pereira  ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컨컴컴컨컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o 쿔mprime Listagem de Entradas/Saidas                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Avalia filtro do usuario                        ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿛ara nota fiscal de retorno de Remessao em poder de terceiros o       ?
		//퀆alor contabil deve ser zerado, foi incluido este tratamento para que ?
		//퀃anto na impressao da nota fiscal quanto nos totalizadores o sistema  ?
		//퀊ere o valor contabil quando a nota fiscal for referente a um retorno ?
		//쿭e remessa. (O tratamento foi copiado do relatorio MATR930)           ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	    If GetNewPar("MV_ESTADO","")=="SP" .And. Alltrim((cArqTemp)->F3_CFO) $ "1904/2904"
		    lRemMerc := .T.
	    Else
		    lRemMerc := .F.
	    EndIf

		If ! Eval(bFiltro)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//쿔mprime os periodos sem movimento?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
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
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//쿔mprime os periodos sem movimento?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			If SEMMOV
				dDia:=F3_ENTRADA
				R921Cabec(dDia)
				FmtLin({"*** NAO HOUVE MOVIMENTO ***"},aL[10],,,@nLin)
				nLin	:=	99
				dbSkip()
				dDia:=F3_ENTRADA
				Loop
			Endif

			//旼컴컴컴컴컴?
			//? Cabecalho ?
			//읕컴컴컴컴컴?
			If nLin>nLimPag .Or. (Month(dDiaAnt)<>Month(dDia) .Or. Year(dDiaAnt)<>Year(dDia))
				If nLin<60 .And. !(Month(dDiaAnt)<>Month(dDia) .Or. Year(dDiaAnt)<>Year(dDia))
					FmtLin(,aL[01],,,@nLin)
				Endif
				R921Cabec()
			Endif
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//? Contador de Tamanho de nota ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			nTamNota:=nLin
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//? Posiciona nos cadastros de Clientes/Fornecedores?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

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
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//? Cria Array com mensagens a serem impressas na coluna de Observacao ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//? Imprime Linhas de detalhe              ?
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				R921ImpGrade()
			Endif

			nPosObs:=Ascan(aObs,{|x|x[2]})
			While nPosObs>0
				R921LoadObs()
				If nPosObs>0
					FmtLin(@aDados,aL[9],cPictVl,,@nLin)
				Endif
			End
			//旼컴컴컴컴컴컴컴컴?
			//? Acumula valores ?
			//읕컴컴컴컴컴컴컴컴?
			nLinNec:=nLin-nTamNota
			aTamNotas[1]:=Max(aTamNotas[1],nLinNec)

			dDiaAnt:=F3_ENTRADA
			dbSelectArea(cArqTemp)
			dbSkip()
			If Empty(F3_ENTRADA)
			   dDiaAnt := dDia
			Endif
			dDia:=F3_ENTRADA
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			//? Imprime Totais e finaliza relatorio ?
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
			R921Totais(lRemMerc)
		Endif
	End

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿜uando mudar a filial, reinicia os totalizadores?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aTotDia    := NIL
	aTotPerICM := NIL
	aTotPerIPI := NIL
	aTotMes    := NIL
	aTransp    := NIL
	aResumo    := NIL
	aResCFO    := NIL

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921Cabec 쿌utor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Impressao de Cabecalho                                     낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921Cabec

	cPeriodo:=""
	If !Empty(dDiaAnt) .Or. !Empty(dDia)
		cPeriodo:=aMeses[Month(IIf(Empty(dDia),dDiaAnt,dDia))]+" / "+Str(Year(IIf(Empty(dDia),dDiaAnt,dDia)),4)
	Endif
	cPagina :=StrZero(nPagina++,6)
	cTitulo:=If(nTipoMov==1,"ENTRASAS","SAIDAS") //"ENTRADAS"###"SAIDAS"
	//旼컴컴컴컴컴컴컴컴컴커
	//? Imprime Cabecalho  ?
	//읕컴컴컴컴컴컴컴컴컴켸
	nLin:=0
	FmtLin(,AvalImp(nLargMax),,,@nLin)
	FmtLin({cNomEmp+" - " + "Filial : " + cFilAnt+" "+cNomFil,cTitulo,cPagina},aL[1],,,@nLin) //
	FmtLin(,aL[2],,,@nLin)
	FmtLin({cPeriodo},aL[3],,,@nLin)
	FmtLin(,{aL[4],aL[5],aL[6],aL[7],aL[8]},,,@nLin)

	Return
	/*
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
	굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
	굇쿑un뇚o    ? R921LayOut쿌utor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
	굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
	굇쿏escri뇚o ? Layout da Listagem                                         낢?
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921Transp쿌utor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime linhas de transporte                               낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//? Imprime Linhas de detalhe              ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921Totdia쿌utor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime total do dia                                       낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//? Imprime Linhas de detalhe              ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921TotMes쿌utor ? Juan Jose Pereira     ? Data ? 18.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime total do Mes                                       낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//? Imprime Linhas de detalhe              ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921TotPer쿌utor ? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime total do periodo de apuracao                       낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
			//旼컴컴컴컴컴컴컴커
			//? Colunas de ICMS?
			//읕컴컴컴컴컴컴컴켸
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
			//旼컴컴컴컴컴컴컴?
			//? Colunas de IPI?
			//읕컴컴컴컴컴컴컴?
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
			//旼컴컴컴컴컴컴컴컴컴컴커
			//? Coluna de Observacoes?
			//읕컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921ResCfo쿌utor ? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Resumo por CFO                                             낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921ResCfo(lRemMerc)
Local i	:=0

	If !Eof().or.Len(aResCFO)==0
		Return
	Endif
	//旼컴컴컴컴컴커
	//? Ordena CFOs?
	//읕컴컴컴컴컴켸
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

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//? Imprime Linhas de detalhe              ?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    ? R921ResEst쿌utor ? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Resumo por Estado                                          낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921ResEst(lRemMerc)
Local i :=0
Local j	:=0
	If !Eof().or.Len(aResumo)==0
		Return
	Endif

	nLin:=80
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//? Arranja o resumo em ordem de CFO e Estado?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    쿝921LoadObs쿌utor ? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Carrega observacao para ser impressa                       낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921LoadObs

	nPosObs:=Ascan(aObs,{|x|x[2]})
	If nPosObs>0
		aDados[16]:=aObs[nPosObs,1]
		aObs[nPosObs,2]:=.F.
	Endif

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    쿝921Totais 쿌utor ? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Aciona funcoes de totalizacao                              낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921Totais(lRemMerc)
	R921Transp(lRemMerc)
	R921TotDia(lRemMerc)
	R921TotPer(lRemMerc)
	R921TotMes(lRemMerc)
	//旼컴컴컴컴컴컴컴컴컴컴컴커
	//? Imprime Resumo por CFO ?
	//읕컴컴컴컴컴컴컴컴컴컴컴켸
	R921ResCfo(lRemMerc)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Imprime Resumo por Estado ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴?
	R921ResEst(lRemMerc)

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    쿝921IniGrade쿌utor? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Inicializa array aGrade do registro de entradas            낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
*/
STATIC FUNCTION R921IniGrade
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Monta grade de impressao            ?
	//? [1]=Codigo de Operacao              ?
	//? [2]=Base / Isentas / Outras         ?
	//? [3]=Valor do imposto                ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	aGrade:=Array(6)
	aGrade[1]:={"1",0,0} //
	aGrade[2]:={"2",0,0} // ICMS
	aGrade[3]:={"3",0,0} //
	aGrade[4]:={"1",0,0} //
	aGrade[5]:={"2",0,0} // IPI
	aGrade[6]:={"3",0,0} //

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇쿑un뇚o    쿝921ImpGrade쿌utor? Juan Jose Pereira     ? Data ? 23.12.96 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇쿏escri뇚o ? Imprime aGrade do registro de entradas                     낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇?
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽?
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
		MAKEDIR("C:\INTEGRA") //  --> Num?rico
	EndIf

	If File("C:\INTEGRA\CDFATR04.DTC")
		FErase("C:\INTEGRA\FECHBIT.DTC") // Apagar Arquivo de Consolidacao Anterior Se Existir
	Endif

	_cNomArq := _cNomArq+".DTC"
	CPYS2T(_cNomArq,"C:\INTEGRA",.F.)

	If !ApOleClient("MsExcel")
		MsgBox("Microsoft Excel N?o Instalado nesta M?quina !!!", "Aten豫o !!!", "INFO")
	Else
		_cNomArq := "C:\INTEGRA\" + _cNomArq
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(_cNomArq)
		oExcelApp:SetVisible(.T.)
	EndIf

Return()