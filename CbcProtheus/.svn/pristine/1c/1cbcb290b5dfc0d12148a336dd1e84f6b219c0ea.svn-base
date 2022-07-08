#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR10  º Autor ³ Roberto Oliveira   º Data ³  04/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Resumo de bitolas PELO Inventário             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico ITF.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR13()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Saldos por Bitolas"
	Local cPict          := ""
	Local titulo         := "Saldos por Bitolas"
	Local nLin           := 80
	Local Cabec1         := "Codigo Descricao                          Qtd.Mt. Kg.Cobr Kg. PVC Kg.Tot. N.Rolo"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "CDESTR13" 
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDESRC"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR13" 

	Private cString := "SB7"

	dbSelectArea("SB7")
	dbSetOrder(1) //B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE

	ValidPerg()
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	Processa( {|| CriaTrb() },"Selecionando Registros...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo         := "Inventário p/Bitolas de " + Dtoc(mv_par01)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  04/04/07   º±±
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
	//Codigo Descricao                          Qtd.Mt. Kg.Cobr Kg. PVC Kg.Tot. Ft.Cob"
	//999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9999,999 999,999 999,999 999,999 999.99"
	//0      7                                 41       50      58      66      74
	_lSX1 := .T.
	DbSelectArea("TRB")
	SetRegua(RecCount())
	DbGoTop()
	_cNome := Left(TRB->CODIGO,3)
	_nSTot1 := 0.00
	_nSTot2 := 0.00
	_nSTot3 := 0.00
	_nSTot4 := 0.00
	_nTot1 := 0.00
	_nTot2 := 0.00
	_nTot3 := 0.00
	_nTot4 := 0.00
	Do While TRB->(!Eof()) .And. !lAbortPrint
		IncRegua()

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
			If Left(TRB->CODIGO,3) # _cNome
				@ nLin,07 PSAY "Total do Produto:"
				@ nLin,41 PSAY _nSTot1  Picture "@E 9999,999"
				@ nLin,50 PSAY _nSTot2 Picture "@E 999,999"
				@ nLin,59 PSAY _nSTot3 Picture "@E 999,999"
				@ nLin,66 PSAY _nSTot2+_nSTot3 Picture "@E 999,999"
				//	@ nLin,74 PSAY _nSTot4/_nSTot2 Picture "@E 999.99"
				_nSTot1 := 0.00
				_nSTot2 := 0.00
				_nSTot3 := 0.00
				_nSTot4 := 0.00
				nLin++
				@ nLin,00 PSAY Replicate("-",limite)
				_cNome := Left(TRB->CODIGO,3)
			EndIf
			nLin := Cabec(Titulo ,Cabec1 ,Cabec2 ,NomeProg,Tamanho ,nTipo,, _lSX1)
			_lSX1 := .F.
			nLin++
		ElseIf Left(TRB->CODIGO,3) # _cNome
			@ nLin,07 PSAY "Total do Produto:"
			@ nLin,41 PSAY _nSTot1  Picture "@E 9999,999"
			@ nLin,50 PSAY _nSTot2 Picture "@E 999,999"
			@ nLin,58 PSAY _nSTot3 Picture "@E 999,999"
			@ nLin,66 PSAY _nSTot2+_nSTot3 Picture "@E 999,999"
			//@ nLin,74 PSAY _nSTot4/_nSTot2 Picture "@E 999.99"
			_nSTot1 := 0.00
			_nSTot2 := 0.00
			_nSTot3 := 0.00
			_nSTot4 := 0.00
			nLin++
			@ nLin,00 PSAY Replicate("-",limite)
			nLin++
			_cNome := Left(TRB->CODIGO,3)
		Endif
		@ nLin,00 PSAY TRB->CODIGO Picture "@R 999.99.99"
		@ nLin,10 PSAY TRB->DESCR
		@ nLin,41 PSAY TRB->QUANT  Picture "@E 9999,999"
		@ nLin,50 PSAY TRB->QTDCOB Picture "@E 999,999"
		@ nLin,58 PSAY TRB->QTDPVC Picture "@E 999,999"
		@ nLin,66 PSAY TRB->QTDCOB+TRB->QTDPVC Picture "@E 999,999"
		@ nLin,74 PSAY TRB->QUANT/100 Picture "@E 9999.9"
		// nLin,74 PSAY TRB->VALOR/TRB->QTDCOB Picture "@E 999.99"

		_nSTot1 += TRB->QUANT
		_nSTot2 += TRB->QTDCOB
		_nSTot3 += TRB->QTDPVC
		_nSTot4 += TRB->VALOR

		_nTot1 += TRB->QUANT
		_nTot2 += TRB->QTDCOB
		_nTot3 += TRB->QTDPVC
		_nTot4 += TRB->VALOR

		nLin := nLin + 1
		TRB->(DbSkip())
	EndDo
	If nLin # 80                  
		If _nSTot1 > 0
			@ nLin,00 PSAY Replicate("-",limite)
			nLin := nLin + 1
			@ nLin,07 PSAY "Total do Produto:"
			@ nLin,41 PSAY _nSTot1  Picture "@E 9999,999"
			@ nLin,50 PSAY _nSTot2 Picture "@E 999,999"
			@ nLin,58 PSAY _nSTot3 Picture "@E 999,999"
			@ nLin,66 PSAY _nSTot2+_nSTot3 Picture "@E 999,999"
			//		@ nLin,74 PSAY _nSTot4/_nSTot2 Picture "@E 999.99"
			nLin++
		EndIf
		@ nLin,00 PSAY Replicate("-",limite)
		nLin := nLin + 1
		@ nLin,07 PSAY "Total do Relatorio:"
		@ nLin,41 PSAY _nTot1  Picture "@E 9999,999"
		@ nLin,50 PSAY _nTot2 Picture "@E 999,999"
		@ nLin,58 PSAY _nTot3 Picture "@E 999,999"
		@ nLin,66 PSAY _nTot2+_nTot3 Picture "@E 999,999"
		//		@ nLin,74 PSAY _nTot4/_nTot2 Picture "@E 999.99"
		nLin := nLin + 1
		@ nLin,00 PSAY Replicate("-",limite)
	EndIf

	DbSelectArea("TRB")
	DbCloseArea()
	DbSelectArea("SB7")
	DbSetOrder(1)
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
	aAdd(aRegs,{cPerg,"01","Data do Inventário           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Do Produto                   ?","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Até o Produto                ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Do Local                     ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Até o Local                  ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Da Localização               ?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SBE"})
	aAdd(aRegs,{cPerg,"07","Até a Localização            ?","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SBE"})
	aAdd(aRegs,{cPerg,"08","Inclui Retalhos              ?","mv_ch8","N",01,0,0,"C","","mv_par08","Sim","","","Não","","","","","","","","","","",""})
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


	**************************
Static Function CriaTrb()
	**************************

	Private __cNomArq := ""                               // Arquivo Temporario
	Private _aCampos := {}

	aAdd(_aCampos, {"CODIGO", "C", 07, 0})
	aAdd(_aCampos, {"DESCR" , "C", 30, 0})
	aAdd(_aCampos, {"QUANT" , "N", 10, 0})
	aAdd(_aCampos, {"QTDCOB", "N", 12, 2})
	aAdd(_aCampos, {"QTDPVC", "N", 12, 2})
	aAdd(_aCampos, {"VALOR" , "N", 13, 2})

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

	Private _cInd := CriaTrab(Nil, .F.)
	IndRegua("TRB", _cInd, "CODIGO",,, "Selecionando Registros...")
	DbSetIndex(_cInd + OrdBagExt())

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SZ1")
	DbSetOrder(1)

	DbSelectArea("SZ2")
	DbSetOrder(1)

	dbSelectArea("SB7")
	dbSetOrder(1) //B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+AllTrim(MV_PAR02),.T.)
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
		IncProc()            

		If SB7->B7_COD     < MV_PAR02 .Or. SB7->B7_COD     > MV_PAR03 .Or. ;
		SB7->B7_LOCAL   < MV_PAR04 .Or. SB7->B7_LOCAL   > MV_PAR05 .Or. ;
		SB7->B7_LOCALIZ < MV_PAR06 .Or. SB7->B7_LOCALIZ > MV_PAR07 
			SB7->(DbSkip())
			Loop
		EndIf

		If Left(SB7->B7_LOCALIZ,1) =="T" .And. MV_PAR08 == 2 // Se é Retalho e Não imprime retalhos
			SB7->(DbSkip())
			Loop
		EndIf        

		//	If Left(SB7->B7_LOCALIZ,1) # "B"
		//		SB7->(DbSkip())
		//		Loop
		//	EndIf

		_B7_COD := If(Left(SB7->B7_COD,1) == "Q",Substr(SB7->B7_COD,2,Len(SB7->B7_COD)),SB7->B7_COD)

		SB1->(DbSeek(xFilial("SB1")+_B7_COD,.F.))

		If !TRB->(DbSeek(Left(_B7_COD,5)+Substr(_B7_COD,9,2),.F.))
			SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
			SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
			RecLock("TRB",.T.)
			TRB->CODIGO  := Left(_B7_COD,5)+Substr(_B7_COD,9,2)
			TRB->DESCR   := AllTrim(SZ1->Z1_DESC) + " " + SZ2->Z2_DESC
		Else
			RecLock("TRB",.F.)
		EndIf
		TRB->QUANT  += SB7->B7_QUANT
		TRB->QTDCOB += (SB7->B7_QUANT * SB1->B1_PESCOB)
		TRB->QTDPVC += (SB7->B7_QUANT * SB1->B1_PESPVC)
		TRB->(MsUnLock())

		DbSelectArea("SB7")
		SB7->(DbSkip())
	EndDo
Return(.T.)