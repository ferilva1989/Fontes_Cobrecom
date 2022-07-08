#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCDFINR01  บ Autor ณ Roberto Oliveira   บ Data ณ  21/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Emissใo de Border๔ (Padrใo nใo atende)                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Condusul - Financeiro                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CDFINR01()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Bordero de Titulos"
	Local cPict         := ""
	Local titulo        := "Border๔ de Titulos"
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Local aSize    := {}
	Private _dDtCaixa := dDataBase
	//Private _dDtDepos := Ctod("  /  /  ")
	Private cComple01 := Space(63)
	Private cComple02 := Space(63)
	Private cComple03 := Space(63)
	Private cComple04 := Space(63)
	Private cComple05 := Space(63)
	Private cComple06 := Space(63)
	Private cComple07 := Space(63)
	Private cComple08 := Space(63)
	Private cComple09 := Space(63)
	Private cComple10 := Space(63)
	Private nComple01 := 0.00     
	Private nComple02 := 0.00
	Private nComple03 := 0.00
	Private nComple04 := 0.00
	Private nComple05 := 0.00
	Private nComple06 := 0.00
	Private nComple07 := 0.00
	Private nComple08 := 0.00
	Private nComple09 := 0.00
	Private nComple10 := 0.00
	Private cEstorn01 := "N"
	Private cEstorn02 := "N"
	Private cEstorn03 := "N"
	Private cEstorn04 := "N"
	Private cEstorn05 := "N"
	Private cEstorn06 := "N"
	Private cEstorn07 := "N"
	Private cEstorn08 := "N"
	Private cEstorn09 := "N"
	Private cEstorn10 := "N"
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "P"
	Private nomeprog    := "CDFINR01" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	//Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private aReturn     := {"Especial", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CDFINR01" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private nLin        := 80
	Private cString     := "SEA"

	aSize := MsAdvSize()

	dbSelectArea("SEA")
	dbSetOrder(1)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a interface padrao com o usuario...                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cPerg := "CDFI01"
	ValidPerg()
	Pergunte(cPerg, .F.)
	//
	//wnRel := SetPrint(cString, wnRel, cPerg, @Titulo,cDesc1,cDesc2,cDesc3, .F.,, .F., Tamanho)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1 .And. Limite > 80,15,18)

	DbSelectArea("SZM")
	DbSetOrder(1)
	DbSeek(xFilial("SZM")+MV_PAR01,.T.)

	MV_PAR03 := If(MV_PAR03==1,"R","P")

	_lNewMod := (SZM->ZM_NUMCX<=MV_PAR02 .And. MV_PAR03 == "P") // Modelo Novo no Contas a Pagar

	If MV_PAR03 == "P" .And. !_lNewMod 
		nOpca := 0       

		//	_nSize7 := Int(aSize[7] * 41 / 100)
		//	_nSize6 := Int(aSize[6] * 41 / 100)
		//	_nSize5 := Int(aSize[5] * 67 / 100)

		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Mensagem Complementar") From aSize[7],0 to aSize[6]-100,aSize[5]-500 of oMainWnd PIXEL
		//	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Mensagem Complementar") From aSize[7]-_nSize7,0 to aSize[6]-_nSize6,aSize[5]-_nSize5 of oMainWnd PIXEL
		//	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Mensagem Complementar") FROM  92,70 TO 221,463 // of oMainWnd PIXEL
		//	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Mensagem Complementar") FROM  n1,n2 TO n3,n4 // of oMainWnd PIXEL
		@  09, 02 SAY "Dep๓sito dia" SIZE 30, 7 //OF oDlg PIXEL      
		@  09,255 SAY "Estorno? S/N" SIZE 40, 7
		//	@  09,162 SAY "Deposito Dia" SIZE 30, 7 //OF oDlg PIXEL
		@  24, 02 SAY "Linha  1" SIZE 24, 7 //OF oDlg PIXEL
		@  39, 02 SAY "Linha  2" SIZE 24, 7 //OF oDlg PIXEL
		@  54, 02 SAY "Linha  3" SIZE 24, 7 //OF oDlg PIXEL
		@  69, 02 SAY "Linha  4" SIZE 24, 7 //OF oDlg PIXEL
		@  84, 02 SAY "Linha  5" SIZE 24, 7 //OF oDlg PIXEL
		@  99, 02 SAY "Linha  6" SIZE 24, 7 //OF oDlg PIXEL
		@ 114, 02 SAY "Linha  7" SIZE 24, 7 //OF oDlg PIXEL
		@ 129, 02 SAY "Linha  8" SIZE 24, 7 //OF oDlg PIXEL
		@ 144, 02 SAY "Linha  9" SIZE 24, 7 //OF oDlg PIXEL
		@ 166, 03 SAY "Linha 10" SIZE 24, 7 //OF oDlg PIXEL

		@  07, 40 GET _dDtCaixa SIZE 50, 10 //Valid _dDtCaixa >= Date()
		//	@  07,200 GET _dDtDepos SIZE 50, 10 Valid _dDtDepos >= Date()
		@  22, 31 GET cComple01 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  22,200 GET nComple01 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  22,255 GET cEstorn01 Picture "@!" Valid cEstorn01$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@  37, 31 GET cComple02 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  37,200 GET nComple02 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  37,255 GET cEstorn02 Picture "@!" Valid cEstorn02$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@  52, 31 GET cComple03 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  52,200 GET nComple03 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  52,255 GET cEstorn03 Picture "@!" Valid cEstorn03$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@  67, 31 GET cComple04 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  67,200 GET nComple04 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  67,255 GET cEstorn04 Picture "@!" Valid cEstorn04$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@  82, 31 GET cComple05 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  82,200 GET nComple05 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  82,255 GET cEstorn05 Picture "@!" Valid cEstorn05$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@  97, 31 GET cComple06 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@  97,200 GET nComple06 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@  97,255 GET cEstorn06 Picture "@!" Valid cEstorn06$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@ 112, 31 GET cComple07 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@ 112,200 GET nComple07 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@ 112,255 GET cEstorn07 Picture "@!" Valid cEstorn07$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@ 127, 31 GET cComple08 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@ 127,200 GET nComple08 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@ 127,255 GET cEstorn08 Picture "@!" Valid cEstorn08$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@ 142, 31 GET cComple09 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@ 142,200 GET nComple09 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@ 142,255 GET cEstorn09 Picture "@!" Valid cEstorn09$"SN" SIZE  05, 10 //OF oDlg PIXEL
		@ 164, 31 GET cComple10 Picture "@S48" SIZE 163, 10 //OF oDlg PIXEL
		@ 164,200 GET nComple10 Picture "@E 99,999,999.99" SIZE  50, 10 //OF oDlg PIXEL
		@ 164,255 GET cEstorn10 Picture "@!" Valid cEstorn10$"SN" SIZE  05, 10 //OF oDlg PIXEL



		DEFINE SBUTTON FROM 177, 139 TYPE 1 ENABLE OF oDlg ACTION (nOpca:=1,oDlg:End())
		DEFINE SBUTTON FROM 177, 167 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

		ACTIVATE MSDIALOG oDlg CENTERED
		If nOpca#1
			cComple01 := ""
			cComple02 := ""
			cComple03 := ""
			cComple04 := ""
			cComple05 := ""
			cComple06 := ""
			cComple07 := ""
			cComple08 := ""
			cComple09 := ""
			cComple10 := ""
		EndIf
	EndIf

	If _lNewMod
		RptStatus({|| RunRep2(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Else
		RptStatus({|| RunRep1(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  21/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRep1(Cabec1,Cabec2,Titulo,nLin)



	DbSelectArea("SED") 
	DbSetOrder(1) //ED_FILIAL+ED_CODIGO   

	DbSelectArea("SE1") 
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	DbSelectArea("SE2")
	DbSetOrder(1)  // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	DbSelectArea("SA1")
	DbSetOrder(1)  

	DbSelectArea("SEV")
	DbSetOrder(1)  //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ

	DbSelectArea("SA2")
	DbSetOrder(1)  

	DbSelectArea("SA6")
	DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	DbSelectArea("SZM")
	DbSetOrder(1) // ZM_FILIAL+ZM_NUMCX+ZM_PREFIXO+ZM_NUMERO+ZM_PARCELA+ZM_TIPO+ZM_FORNEC+ZM_LOJA

	_cNumAtu := "      "
	_nQtdBor := _nTotBor := 0.00
	_lMultNat := .F.
	_lFirst := .T.

	dbSelectArea(cString)
	dbSetOrder(1) // EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA

	SetRegua(RecCount())
	SetPrc(0,0)  

	DbSeek(xFilial("SEA")+MV_PAR01,.T.)
	Do While SEA->EA_FILIAL == xFilial("SEA") .And. SEA->EA_NUMBOR <= MV_PAR02 .And. SEA->(!EOF())
		IncRegua()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If SEA->EA_CART # MV_PAR03
			SEA->(DbSkip())
			Loop
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If nLin > 55 .Or. _cNumAtu # SEA->EA_NUMBOR // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			If _cNumAtu # SEA->EA_NUMBOR
				If nLin # 80
					// Fechar a Pแgina Anterior
					FechePag(nLin)
				EndIf
				DbSelectArea("SA6")
				DbSeek(xFilial("SA6")+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON,.F.)
				_cNumAtu := SEA->EA_NUMBOR
				_nQtdBor := _nTotBor := 0.00
				m_pag := 1
			ElseIf nLin # 80
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
			EndIf        
			If SEA->EA_CART == "R"
				titulo        := "Bordero de Titulos - N. " + SEA->EA_NUMBOR
			Else
				titulo        := "Requisicao p/ Caixa  N. " + SEA->EA_NUMBOR
			EndIf
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
			If m_pag == 2
				@ nLin++,1 Psay "Ao " + SA6->A6_NOME
				@ nLin++,1 Psay "Agencia " + SA6->A6_AGENCIA + "   C/C " + SA6->A6_NUMCON
				If SEA->EA_CART == "R"
					@ nLin++,1 Psay "Solicitamos proceder o recebimento das duplicatas abaixo relacionadas"
					@ nLin++,1 Psay "CREDITANDO-NOS os valores correspondentes."
				EndIf
				If "JACKSON" $ SA6->A6_NOME
					@ nLin++,1 Psay "DE: RAFAEL/GUSTAVO"
					@ nLin++,1 Psay "PARA: JACKSON"
					@ nLin++,1 Psay "ASSUNTO: " + If(SEA->EA_CART == "R","DUPLICATAS","Depositar Dia " + DtoC(_dDtCaixa))
				EndIf
				nLin++                           
			EndIf
			If SEA->EA_CART == "R"
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				@ nLin++,0 Psay "|NUM DUPLIC    |PRC|EMISSAO |CODIGO|R A Z A O  S O C I A L| VENCTO |     VALOR |"
				@ nLin++,0 Psay "|--------------|---|--------|------|----------------------|--------|-----------|"
			Else
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
				@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
			EndIf
		Endif
		If SEA->EA_CART == "R"
			SE1->(DbSeek(xFilial("SE1")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO,.F.))
			SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
			@ nLin,00 Psay "|"
			@ nLin,01 Psay SEA->EA_PREFIXO
			@ nLin,05 Psay SEA->EA_NUM
			@ nLin,15 Psay "|"
			@ nLin,16 Psay SEA->EA_PARCELA
			@ nLin,19 Psay "|"
			@ nLin,20 Psay If(SEA->EA_CART == "R",SE1->E1_EMISSAO,SE2->E2_EMISSAO)
			@ nLin,28 Psay "|"
			@ nLin,29 Psay If(SEA->EA_CART == "R",SE1->E1_CLIENTE,SE2->E2_FORNECE)
			@ nLin,35 Psay "|"        
			@ nLin,36 Psay Left(If(SEA->EA_CART == "R",SA1->A1_NOME,SA2->A2_NOME),22)
			@ nLin,58 Psay "|"
			@ nLin,59 Psay If(SEA->EA_CART == "R",SE1->E1_VENCTO,SE2->E2_VENCTO)
			@ nLin,67 Psay "|"        
			@ nLin,68 Psay If(SEA->EA_CART == "R",SE1->E1_SALDO,SE2->E2_VALOR) Picture "@E 9999,999.99"
			@ nLin,79 Psay "|"
		Else
			If _lFirst // Imprime tudo que estorno = S
				_lFirst := .F.                        
				If _lNewMod
					DbSelectArea("SZM")
					DbSetOrder(1)
					DbSeek(xFilial("SZM") + MV_PAR01,.F.)
					Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX <= MV_PAR02 .And. SZM->(!Eof())
						If SZM->ZM_TPDADO == "E" // Estorno
							If nLin > 55
								nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin++
							EndIf
							@ nLin,00 Psay "|"
							@ nLin,02 Psay SZM->ZM_HIST
							@ nLin,63 Psay "|"        
							@ nLin,64 Psay (SZM->ZM_VALOR*-1) Picture "@E( 9999,999.99"
							@ nLin++,79 Psay "|"
							_nTotBor += (SZM->ZM_VALOR*-1)
						EndIf
						SZM->(DbSkip())
					EndDo
				Else
					For nNumLi := 1 to 10
						_cVari1 := "cComple"+StrZero(nNumLi,2)
						_cVari2 := "nComple"+StrZero(nNumLi,2)
						_cVari3 := "cEstorn"+StrZero(nNumLi,2)
						If !Empty(&(_cVari1)) .And. &(_cVari3) == "S"
							@ nLin,00 Psay "|"
							@ nLin,02 Psay &(_cVari1)
							@ nLin,65 Psay "|"        
							@ nLin,66 Psay &(_cVari2)*-1 Picture "@E( 9999,999.99"
							@ nLin++,79 Psay "|"
							_nTotBor += (&(_cVari2)*-1)
						EndIf
					Next
				EndIf
			EndIf	                                                       
			If !_lMultNat                             
				SE2->(DbSeek(xFilial("SE2")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA,.F.))
				SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,.F.))
				SED->(DbSeek(xFilial("SED")+SE2->E2_NATUREZ,.F.))
				_lMultNat := (SE2->E2_MULTNAT == "1")
				If !_lNewMod
					nVlAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
					If SE2->E2_SALDO # SE2->E2_VALOR .And. nVlAbat > 0.00
						nVlAbat := Round(nVlAbat / SE2->E2_VALOR * SE2->E2_SALDO,2)
					EndIf
				EndIf
				If _lMultNat
					DbSelectArea("SEV")
					DbSeek(xFilial("SEV")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA,.F.)
				EndIf
			EndIf
			If _lMultNat
				SED->(DbSeek(xFilial("SED")+SEV->EV_NATUREZ,.F.))
			EndIf
			If _lNewMod
				SZM->(DbSeek(xFilial("SZM")+SEA->EA_NUMBOR+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA,.F.))
			EndIf

			_CmpDesc := ""
			If SED->ED_DESCR == "F"
				_CmpDesc := Alltrim(SA2->A2_NOME)
			ElseIf SED->ED_DESCR == "H"
				If SZM->(Found())
					_CmpDesc := Alltrim(SZM->ZM_HIST)
				Else
					_CmpDesc := Alltrim(SE2->E2_HIST)
				EndIf
			EndIf
			@ nLin,00 Psay "|"
			@ nLin,02 Psay Left(Alltrim(SED->ED_DESCRIC) + " / " + _CmpDesc,61)
			@ nLin,63 Psay "|"        

			If !_lMultNat
				If !_lNewMod
					@ nLin,64 Psay SE2->E2_SALDO-nVlAbat Picture "@E 99,999,999.99"
				Else 
					@ nLin,64 Psay SZM->ZM_VALOR Picture "@E 99,999,999.99"
				EndIf
			Else
				If nVlAbat > 0.00
					nVlrMnor := Round(nVlAbat / SE2->E2_VALOR * SEV->EV_VALOR,2)
				Else
					nVlrMnor := 0.00
				EndIf
				@ nLin,64 Psay SEV->EV_VALOR-nVlrMnor Picture "@E 99,999,999.99"
			EndIf
			@ nLin,79 Psay "|"
		EndIf
		_nQtdBor++
		_nTotBor += If(_lMultNat,(SEV->EV_VALOR-nVlrMnor),If(SEA->EA_CART == "R",SE1->E1_SALDO,If(_lNewMod,SZM->ZM_VALOR,(SE2->E2_VALOR-nVlAbat))))
		If _lMultNat
			SEV->(DbSkip())                                                      
			_lMultNat := (SEV->EV_FILIAL+SEV->EV_PREFIXO+SEV->EV_NUM+SEV->EV_PARCELA+SEV->EV_TIPO+SEV->EV_CLIFOR+SEV->EV_LOJA == ;
			xFilial("SEV")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+SEA->EA_LOJA .And. SEV->(!Eof()))
		EndIf
		If !_lMultNat
			SEA->(DbSkip()) // Avanca o ponteiro do registro no arquivo
		EndIf

		nLin := nLin + 1 // Avanca a linha de impressao

	EndDo       
	If nLin # 80
		// Fechar a Pแgina Anterior
		FechePag(nLin)
		nLin += 3
	EndIf

	If MV_PAR03 == "P"
		_nSoma := 0.00
		If _lNewMod
			DbSelectArea("SZM")
			DbSetOrder(1)
			DbSeek(xFilial("SZM") + MV_PAR01,.F.)
			Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX <= MV_PAR02 .And. SZM->(!Eof())
				If SZM->ZM_TPDADO == "V" // Venda a Vista
					If nLin > 55
						nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin++
						@ nLin++,0 Psay " ------------------------------------------------------------------------------"
						@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
						@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
					EndIf
					@ nLin,00 Psay "|"
					@ nLin,02 Psay SZM->ZM_HIST
					@ nLin,63 Psay "|"        
					@ nLin,64 Psay (SZM->ZM_VALOR*-1) Picture "@E( 9999,999.99"
					@ nLin++,79 Psay "|"
					_nSoma += SZM->ZM_VALOR
				EndIf
				SZM->(DbSkip())
			EndDo
		Else
			For nNumLi := 1 to 10
				_cVari1 := "cComple"+StrZero(nNumLi,2)
				_cVari2 := "nComple"+StrZero(nNumLi,2)
				_cVari3 := "cEstorn"+StrZero(nNumLi,2)
				If !Empty(&(_cVari1)) .And. &(_cVari3) == "N"
					If nLin > 55 
						@ nLin++,0 Psay " ------------------------------------------------------------------------------"
						nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin++
						@ nLin++,0 Psay " ------------------------------------------------------------------------------"
						@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
						@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
					EndIf
					@ nLin,0 Psay "|"
					@ nLin  ,01 Psay &(_cVari1)
					@ nLin,63 Psay "|"
					@ nLin,64 Psay &(_cVari2) Picture "@E 9999,999.99"
					@ nLin++,79 Psay "|"
					_nSoma += &(_cVari2)
				EndIf
			Next
		EndIf
		If _nSoma > 0.00
			If nLin > 55
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
			EndIf
			@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
			@ nLin  ,0 Psay "| Soma                                                            |"     
			@ nLin  ,68 Psay _nSoma Picture "@E 9999,999.99"
			@ nLin++,79 Psay "|"      

			If nLin > 55
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
			EndIf
			@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
			@ nLin  ,0 Psay "| Total para Depositar                                            |"     
			@ nLin  ,64 Psay _nTotBor-_nSoma Picture "@E 9999,999.99"
			@ nLin++,79 Psay "|"      

			@ nLin++,0 Psay " ------------------------------------------------------------------------------"
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	SET DEVICE TO SCREEN

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(.T.)


/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Border๔                   ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","At้ o Border๔                ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Carteira                     ?","mv_ch3","N",01,0,0,"C","","mv_par03","Receber","","","Pagar","","","","","","","","","","",""})

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next

	RestArea(_aArea)

	Return(.T.)
	//
	**************************
Static Function FechePag(nLin)
	**************************
	//
	@ nLin++,0 Psay "|------------------------------------------------------------------------------|"
	If MV_PAR03=="R"
		@ nLin  ,0 Psay "|                                   Quantidade de Titulos      |"
		@ nLin  ,72 Psay _nQtdBor Picture "@E 999,999"
		@ nLin++,79 Psay "|"
		@ nLin  ,0 Psay "|                                 Valor Total dos Titulos      |"
	Else
		@ nLin  ,0 Psay "| Valor Total do Caixa                                         |"
	EndIf
	@ nLin  ,64 Psay _nTotBor Picture "@E 99,999,999.99"
	@ nLin++,79 Psay "|"
	If MV_PAR03=="R"
		@ nLin++,0 Psay " ------------------------------------------------------------------------------"
	EndIf
Return(nLin)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  21/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunRep2(Cabec1,Cabec2,Titulo,nLin)



	DbSelectArea("SED") 
	DbSetOrder(1) //ED_FILIAL+ED_CODIGO   

	DbSelectArea("SE2")
	DbSetOrder(1)  // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	DbSelectArea("SEV")
	DbSetOrder(1)  //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ

	DbSelectArea("SA2")
	DbSetOrder(1)  

	DbSelectArea("SA6")
	DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	DbSelectArea("SZM")
	DbSetOrder(1) // ZM_FILIAL+ZM_NUMCX+ZM_PREFIXO+ZM_NUMERO+ZM_PARCELA+ZM_TIPO+ZM_FORNEC+ZM_LOJA

	_cNumAtu := "      "
	_nTotBor := 0.00
	_lMultNat := .F.

	SetRegua(RecCount())
	SetPrc(0,0)  


	// este aqui

	DbSeek(xFilial("SZM")+MV_PAR01,.T.)
	Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX <= MV_PAR02 .And. SZM->(!EOF())
		IncRegua()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If _cNumAtu # SZM->ZM_NUMCX // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
			If _cNumAtu # SZM->ZM_NUMCX
				//			DbSelectArea("SA6")               
				//			DbSeek(xFilial("SA6")+SZM->ZM_PORTADO+SZM->ZM_AGEDEP+SZM->ZM_NUMCON,.F.)
				_cNumAtu := SZM->ZM_NUMCX
				_nTotBor := 0.00
				m_pag := 1
			EndIf        
			titulo        := "Requisicao p/ Caixa  N. " + SZM->ZM_NUMCX
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
			If m_pag == 2
				//			@ nLin++,1 Psay "Ao " + SA6->A6_NOME
				//			@ nLin++,1 Psay "Agencia " + SA6->A6_AGENCIA + "   C/C " + SA6->A6_NUMCON
				//			If "JACKSON" $ SA6->A6_NOME
				@ nLin++,1 Psay "DE: RAFAEL/GUSTAVO"
				@ nLin++,1 Psay "PARA: JACKSON"
				@ nLin++,1 Psay "ASSUNTO:  Depositar Dia " + DtoC(SZM->ZM_DATA)
				//			EndIf
				nLin++                           
			EndIf
			@ nLin++,0 Psay " ------------------------------------------------------------------------------"
			@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
			@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
		Endif

		// Imprime Primeiro os estornos
		DbSelectArea("SZM")
		DbSetOrder(1)
		DbSeek(xFilial("SZM") + _cNumAtu,.F.)
		Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _cNumAtu .And. SZM->(!Eof())
			If SZM->ZM_TPDADO == "E" // Estorno
				If nLin > 55
					nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin++
					@ nLin++,0 Psay " ------------------------------------------------------------------------------"
					@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
					@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
				EndIf
				@ nLin,00 Psay "|"
				@ nLin,02 Psay SZM->ZM_HIST
				@ nLin,63 Psay "|"        
				@ nLin,64 Psay (SZM->ZM_VALOR*-1) Picture "@E( 9999,999.99"
				@ nLin++,79 Psay "|"
				_nTotBor += (SZM->ZM_VALOR*-1)
			EndIf
			SZM->(DbSkip())
		EndDo  

		// Imprime os registros de caixa
		DbSelectArea("SZM")
		DbSetOrder(1)
		DbSeek(xFilial("SZM") + _cNumAtu,.F.)
		Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _cNumAtu .And. SZM->(!Eof())
			If SZM->ZM_TPDADO == "C" // Caixa
				If nLin > 55
					@ nLin++,0 Psay " ------------------------------------------------------------------------------"
					nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin++
					@ nLin++,0 Psay " ------------------------------------------------------------------------------"
					@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
					@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
				EndIf
				//			SE2->(DbSeek(xFilial("SE2")+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA,.F.))
				SED->(DbSeek(xFilial("SED")+SZM->ZM_NATUREZ,.F.))

				_CmpDesc := ""
				If SED->ED_DESCR == "F"
					SA2->(DbSeek(xFilial("SA2")+SZM->ZM_FORNEC+SZM->ZM_LOJA,.F.))
					_CmpDesc := Alltrim(SA2->A2_NOME)
				ElseIf SED->ED_DESCR == "H"
					_CmpDesc := Alltrim(SZM->ZM_HIST)
				EndIf
				@ nLin,00 Psay "|"
				@ nLin,02 Psay Left(Alltrim(SED->ED_DESCRIC) + " / " + _CmpDesc,61)
				@ nLin,63 Psay "|"        

				@ nLin,64 Psay SZM->ZM_VALOR Picture "@E 99,999,999.99"
				@ nLin,79 Psay "|"

				_nTotBor += SZM->ZM_VALOR

				nLin := nLin + 1 // Avanca a linha de impressao
			EndIf
			SZM->(DbSkip()) // Avanca o ponteiro do registro no arquivo
		EndDo

		// Fechar a Pแgina Anterior
		nLin := FechePag(nLin)

		_nSoma := 0.00
		DbSelectArea("SZM")
		DbSetOrder(1)
		DbSeek(xFilial("SZM") + _cNumAtu,.F.)
		Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _cNumAtu .And. SZM->(!Eof())
			If SZM->ZM_TPDADO == "V" // Venda a Vista
				If nLin > 55 
					If _nSoma # 0.00
						@ nLin++,0 Psay " ------------------------------------------------------------------------------"
					EndIf
					nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin++
					@ nLin++,0 Psay " ------------------------------------------------------------------------------"
					@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
					@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
				EndIf
				@ nLin,00 Psay "|"
				@ nLin,02 Psay SZM->ZM_HIST
				@ nLin,63 Psay "|"        
				@ nLin,64 Psay (SZM->ZM_VALOR*-1) Picture "@E( 99,999,999.99"
				@ nLin++,79 Psay "|"
				_nSoma += SZM->ZM_VALOR
			EndIf
			SZM->(DbSkip())
		EndDo
		If _nSoma > 0.00
			If nLin > 55
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++
				@ nLin++,0 Psay " ------------------------------------------------------------------------------"
				@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
			EndIf
			@ nLin++,0 Psay "|-----------------------------------------------------------------|------------|"
			@ nLin  ,0 Psay "| Soma                                                        |"     
			@ nLin  ,68 Psay _nSoma Picture "@E 99,999,999.99"
			@ nLin++,79 Psay "|"      
		EndIf
		If nLin > 55
			@ nLin++,0 Psay " ------------------------------------------------------------------------------"
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
			@ nLin++,0 Psay " ------------------------------------------------------------------------------"
			@ nLin++,0 Psay "|Despesa / Fornecedor                                             |      VALOR |"
		EndIf
		@ nLin++,0 Psay "|-------------------------------------------------------------|------------|"
		@ nLin  ,0 Psay "| Total para Depositar                                        |"     
		@ nLin  ,64 Psay _nTotBor-_nSoma Picture "@E 99,999,999.99"
		@ nLin++,79 Psay "|"      
		@ nLin++,0 Psay " ------------------------------------------------------------------------------"
	EndDo       


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	SET DEVICE TO SCREEN

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(.T.)