#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR17  º Autor ³ Roberto Oliveira   º Data ³  04/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Resumo de bitolas PELO pedido                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico ITF.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR17()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Pedidos por Bitolas"
	Local cPict          := ""
	Local titulo         := "Pedidos por Bitolas"
	Local nLin           := 80
	//Local Cabec1         := "Codigo  Descricao                           Qt.P.V.  Qt.Estq.  CB.P.V.  CB.Estq  CB.Falt  CB.Exc.      %"
	//Local Cabec2         := "                                            (Mt)     (Mt)      (Kg)     (Kg)     (Kg)     (Kg)          "
	Local Cabec1         := "Codigo  Descricao                           Qt.P.V.  Qt.P.V.   CB.P.V.  CB.P.V.  CB.Falt  CB.Exc.  Exc. 3L.    "
	Local Cabec2         := "                                            (Mt)     em Est(m)   (Kg)   em Est(k)  (Kg)     (Kg)     (Kg)      "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDESTR17" 
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDESRB"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR17" 
	Private cString      := "SC6"
	Private _cNomArq1    := ""
	Private _cNomArq2    := ""
	Private _cInd1       := ""
	Private _cInd2       := ""

	dbSelectArea("SC6")
	dbSetOrder(1) // C6_FILIAL+C6_NUM
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
	Titulo         := "Pedidos por Bitolas - De "+DToC(Mv_Par03)+" Ate "+DToC(Mv_Par04)

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
	//DbGoTop()           
	DbSeek(cFilAnt,.F.)
	_cNome := Left(TRB->CODIGO,3)
	_nSTot1 := 0.00
	_nSTot2 := 0.00
	_nSTot3 := 0.00
	_nSTot4 := 0.00
	_nSTot5 := 0.00
	_nSTot6 := 0.00
	_nSTot7 := 0.00
	_nTot1 := 0.00
	_nTot2 := 0.00
	_nTot3 := 0.00
	_nTot4 := 0.00
	_nTot5 := 0.00
	_nTot6 := 0.00
	_nTot7 := 0.00
	Do While TRB->FILIAL == cFilAnt .And. TRB->(!Eof()) .And. !lAbortPrint
		IncRegua()

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
			If Left(TRB->CODIGO,3) # _cNome
				@ nLin,07 PSAY "Total do Produto:"
				@ nLin,43 PSAY _nSTot1 Picture "@E 9999,999"
				@ nLin,53 PSAY _nSTot2 Picture "@E 9999,999"
				@ nLin,63 PSAY _nSTot3 Picture "@E 999,999"
				@ nLin,72 PSAY _nSTot4 Picture "@E 999,999"
				@ nLin,81 PSAY _nSTot5 Picture "@E 999,999"
				@ nLin,90 PSAY _nSTot6 Picture "@E 999,999"
				@ nLin,99 PSAY _nSTot7 Picture "@E 9999,999"
				_nSTot1 := 0.00
				_nSTot2 := 0.00
				_nSTot3 := 0.00
				_nSTot4 := 0.00
				_nSTot5 := 0.00
				_nSTot6 := 0.00
				_nSTot7 := 0.00
				nLin++
				@ nLin,00 PSAY Replicate("-",limite)
				_cNome := Left(TRB->CODIGO,3)
			EndIf                                         
			nLin := Cabec(Titulo ,Cabec1 ,Cabec2 ,NomeProg,Tamanho ,nTipo,, _lSX1)
			_lSX1 := .F.
			nLin++
		ElseIf Left(TRB->CODIGO,3) # _cNome
			@ nLin,07 PSAY "Total do Produto:"
			@ nLin,43 PSAY _nSTot1 Picture "@E 9999,999"
			@ nLin,53 PSAY _nSTot2 Picture "@E 9999,999"
			@ nLin,63 PSAY _nSTot3 Picture "@E 999,999"
			@ nLin,72 PSAY _nSTot4 Picture "@E 999,999"
			@ nLin,81 PSAY _nSTot5 Picture "@E 999,999"
			@ nLin,90 PSAY _nSTot6 Picture "@E 999,999"
			@ nLin,99 PSAY _nSTot7 Picture "@E 9999,999"
			_nSTot1 := 0.00
			_nSTot2 := 0.00
			_nSTot3 := 0.00
			_nSTot4 := 0.00
			_nSTot5 := 0.00
			_nSTot6 := 0.00
			_nSTot7 := 0.00
			nLin++
			@ nLin,00 PSAY Replicate("-",limite)
			nLin++
			_cNome := Left(TRB->CODIGO,3)
		Endif

		DbSelectArea("TRB1")
		DbSeek(cFilAnt+TRB->CODIGO,.F.)
		_nQtEst    := 0.00
		_nCobEst   := 0.00
		_nCobFal   := 0.00
		_nCobExc   := 0.00
		_nCobExc3L := 0.00
		Do While TRB1->FILIAL == cFilAnt .And. Left(TRB1->CODIGO,5) == TRB->CODIGO .And. TRB1->(!Eof())
			If TRB1->ESTOQ <= TRB1->QTDPV
				If TRB1->ESTOQ < TRB1->QTDPV
					_nCobFal += ((TRB1->QTDPV - TRB1->ESTOQ) * TRB1->FATORCB)
				EndIf
				_nQtEst  += TRB1->ESTOQ 
				_nCobEst += (TRB1->ESTOQ * TRB1->FATORCB)
			Else
				_nQtEst  += TRB1->QTDPV
				_nCobEst += (TRB1->QTDPV * TRB1->FATORCB)
				_nCobExc += ((TRB1->ESTOQ-TRB1->QTDPV) * TRB1->FATORCB)
			EndIf                                                      
			_nCobExc3L += (TRB1->SOBRA * TRB1->FATORCB)
			TRB1->(DbSkip())
		EndDo

		@ nLin,00 PSAY TRB->CODIGO Picture "@R 999.99"
		@ nLin,08 PSAY TRB->DESCR
		@ nLin,43 PSAY TRB->QUANT  Picture "@E 9999,999"
		@ nLin,53 PSAY _nQtEst     Picture "@E 9999,999"
		@ nLin,63 PSAY TRB->COBPV  Picture "@E 999,999"
		@ nLin,72 PSAY _nCobEst    Picture "@E 999,999"
		@ nLin,81 PSAY _nCobFal    Picture "@E 999,999"
		@ nLin,90 PSAY _nCobExc    Picture "@E 999,999"
		@ nLin,99 PSAY _nCobExc3L  Picture "@E 9999,999"

		_nSTot1 += TRB->QUANT
		_nSTot2 += _nQtEst
		_nSTot3 += TRB->COBPV
		_nSTot4 += _nCobEst
		_nSTot5 += _nCobFal
		_nSTot6 += _nCobExc
		_nSTot7 += _nCobExc3L

		_nTot1 += TRB->QUANT
		_nTot2 += _nQtEst
		_nTot3 += TRB->COBPV
		_nTot4 += _nCobEst
		_nTot5 += _nCobFal
		_nTot6 += _nCobExc
		_nTot7 += _nCobExc3L    

		nLin := nLin + 1
		TRB->(DbSkip())
	EndDo
	If nLin # 80                  
		If _nSTot1 > 0
			@ nLin,00 PSAY Replicate("-",limite)
			nLin := nLin + 1
			@ nLin,07 PSAY "Total do Produto:"
			@ nLin,43 PSAY _nSTot1 Picture "@E 9999,999"
			@ nLin,53 PSAY _nSTot2 Picture "@E 9999,999"
			@ nLin,63 PSAY _nSTot3 Picture "@E 999,999"
			@ nLin,72 PSAY _nSTot4 Picture "@E 999,999"
			@ nLin,81 PSAY _nSTot5 Picture "@E 999,999"
			@ nLin,90 PSAY _nSTot6 Picture "@E 999,999"
			@ nLin,99 PSAY _nSTot7 Picture "@E 9999,999"
			nLin++
		EndIf
		@ nLin,00 PSAY Replicate("-",limite)
		nLin := nLin + 1
		@ nLin,07 PSAY "Total do Relatorio:"
		@ nLin,43 PSAY _nTot1 Picture "@E 9999,999"
		@ nLin,53 PSAY _nTot2 Picture "@E 9999,999"
		@ nLin,63 PSAY _nTot3 Picture "@E 999,999"
		@ nLin,72 PSAY _nTot4 Picture "@E 999,999"
		@ nLin,81 PSAY _nTot5 Picture "@E 999,999"
		@ nLin,90 PSAY _nTot6 Picture "@E 999,999"
		@ nLin,99 PSAY _nTot7 Picture "@E 9999,999"
		nLin := nLin + 1
		@ nLin,00 PSAY Replicate("-",limite)
	EndIf

	_cNomArq1:= _cNomArq1+".DTC"
	_cNomArq2:= _cNomArq2+".DTC"

	u_Excel(_cNomArq2)

	DbSelectArea("TRB1")
	DbCloseArea()
	DbSelectArea("TRB")
	DbCloseArea()
	DbSelectArea("SD2")
	DbSetOrder(1)
	FErase(_cNomArq1) 
	FErase(_cNomArq2)
	FErase(_cInd1 + OrdBagExt())
	FErase(_cInd2 + OrdBagExt())
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
	aAdd(aRegs,{cPerg,"01","Do Pedido                    ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SC5"})
	aAdd(aRegs,{cPerg,"02","Até o Pedido                 ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SC5"})
	aAdd(aRegs,{cPerg,"03","Da Emissao                   ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate a Emissao                ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Da Dt.Entrega                ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até a Dt. Entrega            ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Considera em Resumo          ?","mv_ch7","N",01,0,0,"C","","mv_par07","Não","","","Sim","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Considera Separados          ?","mv_ch8","N",01,0,0,"C","","mv_par08","Não","","","Sim","","","","","","","","","","",""})

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

	Private _aCampos := {}
	Private _TESFech := "501//505//809//810//838//521//522//530//527//876//921//930/933/506//600"
	// Importante: O TES das notas série U podem ser alterados conforme o envio para sucata, então, adicionar a variável _TESFech os TES
	// F4_TES_U de cada um deles
	_TESFech := u_VejaTESu(_TESFech)

	// Criando primeiro TRB
	aAdd(_aCampos, {"FILIAL", "C", TamSX3("B1_FILIAL")[1], 0})
	aAdd(_aCampos, {"CODIGO", "C", 05, 0})
	aAdd(_aCampos, {"DESCR" , "C", 33, 0})
	aAdd(_aCampos, {"QUANT" , "N", 10, 0})
	aAdd(_aCampos, {"COBPV" , "N", 12, 2})
	aAdd(_aCampos, {"VALOR" , "N", 12, 2})
	aAdd(_aCampos, {"SOBRA", "N", 10, 0})

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq1 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq1, "TRB", .T., .F.)

	_cInd1 := CriaTrab(Nil, .F.)
	IndRegua("TRB", _cInd1, "FILIAL+CODIGO",,, "Selecionando Registros...")
	DbSetIndex(_cInd1 + OrdBagExt())

	// Criando Segundo TRB
	_aCampos := {}
	aAdd(_aCampos, {"FILIAL", "C", TamSX3("B1_FILIAL")[1], 0})
	aAdd(_aCampos, {"CODIGO" , "C", TamSX3("B1_COD")[1], 0})
	aAdd(_aCampos, {"LOCALIZ", "C", TamSX3("BE_LOCALIZ")[1], 0})
	aAdd(_aCampos, {"QTDPV"  , "N", 10, 0})
	aAdd(_aCampos, {"ESTOQ"  , "N", 10, 0})
	aAdd(_aCampos, {"FATORCB", "N", 08, 4})
	aAdd(_aCampos, {"SOBRA", "N", 10, 0})

	If Select("TRB1") > 0
		DbSelectArea("TRB1")
		DbCloseArea()
	EndIf

	_cNomArq2 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq2, "TRB1", .T., .F.)

	_cInd2 := CriaTrab(Nil, .F.)
	IndRegua("TRB1", _cInd2, "FILIAL+CODIGO+LOCALIZ",,, "Selecionando Registros...")
	DbSetIndex(_cInd2 + OrdBagExt())


	DbSelectArea("SM0")
	DbSetOrder(1)    
	aOutras := {}
	cMyEmp := cNumEmp
	cMyFil := cFilAnt
	DbSeek(cEmpAnt,.f.)
	Do While FWCodEmp() == cEmpAnt .And. !SM0->(Eof())
		If FWCodFil() # cMyFil
			AADD(aOutras,FWCodFil())
		EndIf
		cFilAnt := FWCodFil()

		DbSelectArea("SB1")
		DbSetOrder(1)

		DbSelectArea("SZ1")
		DbSetOrder(1)

		DbSelectArea("SZ2")
		DbSetOrder(1)

		DbSelectArea("SF4")
		DbSetOrder(1)

		dbSelectArea("SC6")                                      
		dbSetOrder(1) // C6_FILIAL+C6_NUM

		dbSelectArea("SC5")
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		ProcRegua(LastRec())
		DbSeek(xFilial("SC5")+MV_PAR01,.T.)
		Do While SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_NUM  <= MV_PAR02 .And. SC5->(!Eof())
			IncProc()            

			If SC5->C5_EMISSAO < MV_PAR03 .Or. SC5->C5_EMISSAO > MV_PAR04 .Or. SC5->C5_ENTREG < MV_PAR05 .Or. SC5->C5_ENTREG > MV_PAR06
				SC5->(DbSkip())
				Loop
			ElseIf MV_PAR07 == 1 .And. !Empty(SC5->C5_SEMANA) // MV_PAR07 == 1 -> Não considera o que está em resumo
				SC5->(DbSkip())
				Loop
			EndIf

			DbSelectArea("SC6")
			DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				If SC6->C6_BLQ == "R " // "R" - Residuo eliminado
					SC6->(DbSkip())
					Loop
				EndIf          
				_nQtdSC6 := SC6->C6_QTDVEN-SC6->C6_QTDENT
				_nQtdSC9 := 0.00
				If MV_PAR08 == 1 // Não Considera os separados
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC6->C6_NUM .And. SC9->C9_ITEM == SC6->C6_ITEM .And. SC9->(!Eof())
						If Empty(SC9->C9_BLEST+SC9->C9_BLCRED) // Liberado
							_nQtdSC9 += SC9->C9_QTDLIB
						EndIf                         
						SC9->(DbSkip())
					EndDo
				EndIf
				_nQtdSC6 -= _nQtdSC9
				SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
				If _nQtdSC6 > 0 .And. SF4->F4_ESTOQUE == "S"
					_Localiz := Left(SC6->C6_ACONDIC + StrZero(SC6->C6_METRAGE,5) + Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))

					SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))

					If !TRB1->(DbSeek(cFilAnt+SC6->C6_PRODUTO+_Localiz,.F.))
						DbSelectArea("SBF")
						DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
						DbSeek(xFilial("SBF")+"01"+_Localiz+SC6->C6_PRODUTO,.F.)
						RecLock("TRB1",.T.)   
						TRB1->FILIAL   := cFilAnt
						TRB1->CODIGO   := SC6->C6_PRODUTO
						TRB1->LOCALIZ  := _Localiz
						TRB1->ESTOQ    := SBF->BF_QUANT
						TRB1->FATORCB  := SB1->B1_PESCOB
					Else
						RecLock("TRB1",.F.)
					EndIf
					TRB1->QTDPV += _nQtdSC6
					MsUnLock()

					If !TRB->(DbSeek(cFilAnt+Left(SC6->C6_PRODUTO,5),.F.))
						SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
						SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
						RecLock("TRB",.T.)
						TRB->FILIAL  := cFilAnt
						TRB->CODIGO  := Left(SC6->C6_PRODUTO,5)
						TRB->DESCR   := AllTrim(SZ1->Z1_DESC) + " " + SZ2->Z2_DESC
					Else
						RecLock("TRB",.F.)
					EndIf
					TRB->QUANT  += _nQtdSC6
					TRB->COBPV += (_nQtdSC6 * SB1->B1_PESCOB)
					TRB->VALOR  += (_nQtdSC6 * SC6->C6_PRCVEN)
					TRB->(MsUnLock())
				EndIf
				SC6->(DbSkip())
			EndDo
			SC5->(DbSkip())
		EndDo            

		// Busca Salto em estoque dos produtos que não tem pedido de venda
		DbSelectArea("SBF")
		DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		ProcRegua(LastRec())
		DbSeek(xFilial("SBF")+"01",.F.)
		Do While SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_LOCAL == "01"  .And. SBF->(!Eof())
			IncProc()                          
			If SBF->BF_QUANT > 0.00 .And. Left(SBF->BF_LOCALIZ,1) # "T" // não inclui retalhos
				If !TRB1->(DbSeek(cFilAnt+SBF->BF_PRODUTO+SBF->BF_LOCALIZ,.F.))
					SB1->(DbSeek(xFilial("SB1")+SBF->BF_PRODUTO,.F.))
					RecLock("TRB1",.T.)
					TRB1->FILIAL   := cFilAnt
					TRB1->CODIGO   := SBF->BF_PRODUTO
					TRB1->LOCALIZ  := SBF->BF_LOCALIZ
					TRB1->ESTOQ    := SBF->BF_QUANT
					TRB1->FATORCB  := SB1->B1_PESCOB
					TRB1->(MsUnLock())
				EndIf
				If !TRB->(DbSeek(cFilAnt+Left(SBF->BF_PRODUTO,5),.F.))
					SB1->(DbSeek(xFilial("SB1")+SBF->BF_PRODUTO,.F.))
					SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
					SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
					RecLock("TRB",.T.)
					TRB->FILIAL  := cFilAnt
					TRB->CODIGO  := Left(SBF->BF_PRODUTO,5)
					TRB->DESCR   := AllTrim(SZ1->Z1_DESC) + " " + SZ2->Z2_DESC
					TRB->(MsUnLock())
				EndIf
			EndIf
			SBF->(DbSkip())
		EndDo
		DbSelectArea("SM0")
		DbSkip()
	EndDo      
	DbSelectArea("SM0")
	DbSetOrder(1)                     
	cNumEmp := cMyEmp
	cFilAnt := cMyFil
	DbSeek(cNumEmp,.F.)

	DbSelectArea("SBF")
	DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	// AVALIAR A SOBRA NO TRB1 GRAVANDO TB NO TRB
	dBSelectArea("TRB1")
	DbSeek(cFilAnt,.F.)
	Do While TRB1->FILIAL == cFilAnt .And. !TRB1->(Eof())

		_RegAtu := TRB1->(Recno())
		_nQtdSobra := 0
		cChave := TRB1->CODIGO + TRB1->LOCALIZ
		cChaveBF := "01"+TRB1->LOCALIZ+TRB1->CODIGO

		For _nFil := 1 to Len(aOutras)       
			_nMyEstq   := 0
			_nMyQtdEmp := 0  
			_lTemTRB1 := .F.
			If TRB1->(DbSeek(aOutras[_nFil] + cChave,.F.))
				_lTemTRB1 := .T.
				If TRB1->ESTOQ-TRB1->QTDPV > 0
					_nMyEstq   := TRB1->ESTOQ
					_nMyQtdEmp := TRB1->QTDPV
					//				_nQtdSobra += (TRB1->ESTOQ-TRB1->QTDPV)
				EndIf
			EndIf
			DbSelectArea("SBF")
			//DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If DbSeek(aOutras[_nFil] + cChaveBF,.F.)
				If ((SBF->BF_QUANT - SBF->BF_EMPENHO) < (_nMyEstq-_nMyQtdEmp) .And.	;
				_lTemTRB1 .And. SBF->BF_EMPENHO >= 0) .Or. !_lTemTRB1
					_nMyEstq   := SBF->BF_QUANT
					_nMyQtdEmp := SBF->BF_EMPENHO
					//			_nQtdSobra += (SBF->BF_QUANT - SBF->BF_EMPENHO)
				EndIf                                
			EndIf                                
			_nQtdSobra += (_nMyEstq-_nMyQtdEmp)
		Next
		DbSelectArea("TRB1")
		TRB1->(DbGoTo(_RegAtu))
		RecLock("TRB1",.F.)
		TRB1->SOBRA := _nQtdSobra
		MsUnLock()

		// Procurar o trb da filial e somar
		DbSelectArea("TRB")
		If DbSeek(cFilAnt+Left(cChave,5),.F.)
			RecLock("TRB",.F.)
			TRB->SOBRA += _nQtdSobra
			MsUnLock()  
		EndIf

		TRB1->(DbSkip())
	EndDo
Return(.T.)