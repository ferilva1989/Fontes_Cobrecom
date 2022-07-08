#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR15  º Autor ³ AP6 IDE            º Data ³  28/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR15()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatório Vendas/Fatur./Produção"
	Local cPict          := ""
	Local titulo       := "Relatório Vendas/Fatur./Produção"
	Local nLin         := 80
	Local Cabec1       := "                                                                   Li   Venda                Produção             Faturamento"
	Local Cabec2       := "Produto        Descrição                                          nha   Quant.      Peso     Quant.      Peso     Quant.      Peso"
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "CDESTR15" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDESTR15" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SD2"

	cPerg := "CDES15"
	ValidPerg()

	dbSelectArea("SD2")
	dbSetOrder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	titulo := "Relatório Vendas/Fatur./Produção de " + Dtoc(MV_PAR01) + " ate "  + Dtoc(MV_PAR02)

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	aStru := {}
	aAdd(aStru,{"CODIGO","C",TamSX3("B1_COD")[1],0})
	aAdd(aStru,{"DESC"  ,"C",50,0})
	aAdd(aStru,{"LINHA" ,"C",1,0}) // linha de produto
	aAdd(aStru,{"QTDVEN","N",15,2})
	aAdd(aStru,{"PESVEN","N",15,2})
	aAdd(aStru,{"QTDPRO","N",15,2})
	aAdd(aStru,{"PESPRO","N",15,2})
	aAdd(aStru,{"QTDFAT","N",15,2})
	aAdd(aStru,{"PESFAT","N",15,2})

	If Select("TRB") # 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIF

	cArq := CriaTrab(aStru,.T.)
	dbUseArea(.T.,,cArq,"TRB",.T.)
	cInd := CriaTrab(NIL,.F.)
	IndRegua("TRB",cInd,"LINHA+CODIGO",,,"Selecionando Registros...")

	Processa( {|| CdEs15a() },"Processando Dados de Vendas....")
	Processa( {|| CdEs15b() },"Processando Dados de Produção....")
	Processa( {|| CdEs15c() },"Processando Dados de Faturamento....")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	DbSelectArea("TRB")
	DbCloseArea("TRB")
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  28/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	dbSelectArea("TRB")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(RecCount())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
	//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
	//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
	//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
	//³                                                                     ³
	//³ dbSeek(xFilial())                                                   ³
	//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbGoTop()

	_cLinAtu := TRB->LINHA
	_nTtLin1 := 0
	_nTtLin2 := 0
	_nTtLin3 := 0
	Do While !EOF()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If TRB->LINHA # _cLinAtu 
			//  Imprimitr o total da linha
			@ nLin,015 PSAY "Total da Linha " + _cLinAtu
			@ nLin,081 PSAY Int(_nTtLin1) Picture "@E 9,999,999"
			@ nLin,102 PSAY Int(_nTtLin2) Picture "@E 9,999,999"
			@ nLin++,123 PSAY Int(_nTtLin3) Picture "@E 9,999,999"
			_cLinAtu := TRB->LINHA
			_nTtLin1 := 0
			_nTtLin2 := 0
			_nTtLin3 := 0
		EndIf
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
		Endif

		@ nLin,000 PSAY TRB->CODIGO
		@ nLin,015 PSAY TRB->DESC
		@ nLin,068 PSAY TRB->LINHA
		@ nLin,071 PSAY Int(TRB->QTDVEN) Picture "@E 9,999,999"
		@ nLin,081 PSAY Int(TRB->PESVEN) Picture "@E 9,999,999"
		@ nLin,092 PSAY Int(TRB->QTDPRO) Picture "@E 9,999,999"
		@ nLin,102 PSAY Int(TRB->PESPRO) Picture "@E 9,999,999"
		@ nLin,113 PSAY Int(TRB->QTDFAT) Picture "@E 9,999,999"
		@ nLin,123 PSAY Int(TRB->PESFAT) Picture "@E 9,999,999"
		_nTtLin1 := _nTtLin1+TRB->PESVEN
		_nTtLin2 := _nTtLin2+TRB->PESPRO
		_nTtLin3 := _nTtLin3+TRB->PESFAT
		nLin := nLin + 1 // Avanca a linha de impressao

		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo
	If _nTtLin1+_nTtLin2+_nTtLin3 > 0
		@ nLin,015 PSAY "Total da Linha " + _cLinAtu
		@ nLin,081 PSAY Int(_nTtLin1) Picture "@E 9,999,999"
		@ nLin,102 PSAY Int(_nTtLin2) Picture "@E 9,999,999"
		@ nLin,123 PSAY Int(_nTtLin3) Picture "@E 9,999,999"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return
	*
	*************************
Static Function CdEs15a()
	*************************
	*
	*
	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SF4")
	DbSetOrder(1) //F4_FILIAL+F4_CODIGO

	DbSelectArea("SC6")
	DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SC5")
	DbSetOrder(2) //C5_FILIAL+ DTOS(C5_EMISSAO)+C5_NUM

	ProcRegua(LastRec())
	DbSeek(xFilial("SC5")+Dtos(MV_PAR01),.T.)

	Do While SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_EMISSAO <= MV_PAR02 .And. SC5->(!Eof())
		IncProc()
		If SC5->C5_TIPO == "N"
			DbSelectArea("SC6")
			DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				SF4->(DbSeek(xFilial("SF4")+SC6->C6_TESORI,.F.))
				If SF4->F4_ESTOQUE == "S"
					GrvTrb("V",SC6->C6_PRODUTO)
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf
		SC5->(DbSkip())
	EndDo
	Return(.T.)
	*
	*************************
Static Function CdEs15b()
	*************************
	*
	*
	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SZB")
	DbSetOrder(1) //ZB_FILIAL+ DTOS(ZB_DATA)+ZB_NUM

	ProcRegua(LastRec())
	DbSeek(xFilial("SZB")+Dtos(MV_PAR01),.T.)

	Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_DATA <= MV_PAR02 .And. SZB->(!Eof())
		IncProc()
		If SZB->ZB_STATUS $ "SN"
			GrvTrb("P",SZB->ZB_PRODUTO)
		EndIf
		SZB->(DbSkip())
	EndDo
	Return(.T.)
	*
	*************************
Static Function CdEs15c()
	*************************
	*
	*
	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SF4")
	DbSetOrder(1) //F4_FILIAL+F4_CODIGO

	DbSelectArea("SD2")
	DbSetOrder(5) //D2_FILIAL+ DTOS(D2_EMISSAO)+D2_NUMSEQ

	ProcRegua(LastRec())
	DbSeek(xFilial("SD2")+Dtos(MV_PAR01),.T.)

	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_EMISSAO <= MV_PAR02 .And. SD2->(!Eof())
		IncProc()
		If SD2->D2_TIPO == "N"
			SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.))
			If SF4->F4_ESTOQUE == "S"
				GrvTrb("F",SD2->D2_COD)
			EndIf
		EndIf
		SD2->(DbSkip())
	EndDo
	Return(.T.)
	*
	**********************************
Static Function GrvTrb(cRoti,cCod)
	**********************************
	*
	SB1->(DbSeek(xFilial("SB1")+cCod,.F.))
	DbSelectArea("TRB")
	If !DbSeek(SB1->B1_LINHA+cCod,.F.)
		RecLock("TRB",.T.)
		TRB->CODIGO := cCod
		TRB->DESC   := SB1->B1_DESC
		TRB->LINHA  := SB1->B1_LINHA
	Else
		RecLock("TRB",.F.)
	EndIf
	If cRoti == "V" // Vendas -> Tabela SC6
		TRB->QTDVEN += SC6->C6_QTDVEN
		TRB->PESVEN += (SC6->C6_QTDVEN * SB1->B1_PESCOB)
	ElseIf cRoti == "P" // Produção -> Tabela SZB
		TRB->QTDPRO += SZB->ZB_QUANT
		TRB->PESPRO += (SZB->ZB_QUANT * SB1->B1_PESCOB)
	ElseIf cRoti == "F" // Faturamento -> Tabela SD2
		TRB->QTDFAT += SD2->D2_QUANT
		TRB->PESFAT += (SD2->D2_QUANT * SB1->B1_PESCOB)
	EndIf
	MsUnLock()
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
	aAdd(aRegs,{cPerg,"01","Da Data                      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Data                   ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

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
		EndIf
	Next
	RestArea(_aArea)
Return(.T.)
