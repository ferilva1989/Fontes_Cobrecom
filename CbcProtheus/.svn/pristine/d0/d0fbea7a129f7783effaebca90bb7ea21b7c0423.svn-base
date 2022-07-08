#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} CDFATR04
//TODO Relatório de Resumo de bitolas.
@author Roberto Oliveira
@since 04/04/2007
@version undefined

@type function
/*/
User Function CDFATR04()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Resumo de Bitolas"
	Local cPict          := ""
	Local titulo         := "Resumo de Bitolas"
	Local nLin           := 80
	Local Cabec1         := "Codigo Descricao                                  Quantidade   Vlr. de Venda Cobre Kg  PVC  Kg Total Kg"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := Space(10)
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDFATR04"
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDFTR4"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDFATR04"
	Private _cNomArq 		:= ""                               // Arquivo Temporario
	Private cString 		:= "SD2"
	Private _lTriang		:= .F.
	Private _lTrTL		:= .F.
	Private _lTudo		:= .T.

	dbSelectArea("SD2")
	dbSetOrder(5) // D2_FILIAL+ DTOS(D2_EMISSAO)+D2_NUMSEQ

	ValidPerg()
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)
	_nTotRel := 0.00

	If MV_PAR05 == 5
		If MsgBox("Retorno de Industrialização é TRIANGULAÇÃO ?","Confirma?","YesNo")
			_lTriang := .T.
		Else
			_lTriang := .F.
		EndIf
	EndIf

	If (MV_PAR05 == 1).and.(FWCodFil() == "02")
		If MsgBox("Considera separar Faturamento de Industrialização?","Confirma?","YesNo")
			_lTudo := .F.
			If MsgBox("Considera apenas Armazem 10 (INDUSTRIALIZ.)","Confirma?","YesNo")
				_lTrTL := .T.
			Else
				_lTrTL := .F.
			EndIf
		Else
			_lTudo := .T.
		EndIf
	EndIf

	Processa( {|| CriaTrb() },"Selecionando Registros...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo         := "Resumo de Bitolas de " + Dtoc(mv_par01) + " a " + Dtoc(mv_par02)


	If MV_PAR06 == 1 // Formato Fechamento
		Cabec1       := "Codigo Descricao                                  Quantidade     Vlr. de Venda     Cobre Kg       PVC  Kg       Total Kg"
	Else  // Formato Análise
		Cabec1       := "Codigo Descricao                                Vlr. Venda     Quant. (m)   Cobre Kg Vr.Medio(m)  Vr.Medio(Kg)   Cst.Esq.   % Lucro    Ranking"
	EndIf

	If MV_PAR05==1
		titulo := titulo + "-(Fat)"
	ElseIf  MV_PAR05==2
		titulo := titulo + "-(Bon)"
	ElseIf  MV_PAR05==3
		titulo := titulo + "-(FEF)"
	ElseIf  MV_PAR05==4
		titulo := titulo + "-(REF)"
	ElseIf  MV_PAR05 == 5 .and. !_lTriang
		titulo := titulo + "-(RET)"
	ElseIf  (MV_PAR05 == 5 .and. _lTriang)
		titulo := titulo + "-(TRI)"
	EndIf


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return(.T.)

/*/{Protheus.doc} RunReport
//TODO Descrição auto-gerada.
@author juliana.leme
@since 02/06/2017
@version undefined
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local aColun	:= {}
	Local aTablePed	:= {}
	Local aWstPed	:= {}
	Local xPar      := {}
	Local aDadCon	:= {}
	Local n1			:= 1
	
	DbSelectArea("TRB")
	SetRegua(RecCount())
	DbGoTop()
	_cNome := Left(TRB->CODIGO,3)

	_nTot1Qt := 0.0000
	_nTot1Vl := 0.0000
	_nTot1CU := 0.0000
	_nTot1PV := 0.0000

	_nTot2Qt := 0.0000
	_nTot2Vl := 0.0000
	_nTot2CU := 0.0000
	_nTot2PV := 0.0000

	Do While TRB->(!Eof()) .And. !lAbortPrint
		IncRegua()

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
			If Left(TRB->CODIGO,3) # _cNome
				@ nLin,07 PSAY "Total do Item:"
				If MV_PAR06 == 1 // Formato Fechamento
					@ nLin,48 PSAY _nTot1Qt Picture "@E 999,999,999"
					@ nLin,63 PSAY _nTot1Vl Picture  "@E 999,999,999.99"
					@ nLin,82 PSAY _nTot1CU Picture "@E 999,999.99"
					@ nLin,97 PSAY _nTot1PV Picture "@E 999,999.99"
					@ nLin,112 PSAY _nTot1CU+_nTot1PV Picture "@E 999,999.99"
				Else
					@ nLin,048 PSAY _nTot1Vl Picture  "@E 999999999.9999"
					@ nLin,059 PSAY _nTot1Qt Picture "@E 999999999.9999"
					@ nLin,072 PSAY _nTot1CU Picture "@E 999999999.9999"
					@ nLin,081 PSAY _nTot1Vl/_nTot1Qt Picture "@E 999999999.9999"
					@ nLin,094 PSAY _nTot1Vl/TRB->COBRE Picture "@E 999999999.9999"
					@ nLin,106 PSAY 99 Picture "@E 999.9999" // Custo do estoque
					@ nLin,115 PSAY (((_nTot1Vl/_nTot1CU)-99) / 99)*100 Picture "@E 999999999.9999"
					@ nLin,125 PSAY (_nTot1Vl/_nTotRel)*100 Picture "@E 999999999.9999"
					//
				EndIf

				nLin := nLin + 1
				@ nLin,00 PSAY Replicate("-",limite)
				_cNome := Left(TRB->CODIGO,3)
				_nTot1Qt := 0.0000
				_nTot1Vl := 0.0000
				_nTot1CU := 0.0000
				_nTot1PV := 0.0000
			EndIf
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
		ElseIf Left(TRB->CODIGO,3) # _cNome
			If MV_PAR06 == 1 // Formato Fechamento
				@ nLin,07 PSAY "Total do Item:"
				@ nLin,48 PSAY _nTot1Qt Picture "@E 999,999,999"
				@ nLin,63 PSAY _nTot1Vl Picture  "@E 999,999,999.99"
				@ nLin,82 PSAY _nTot1CU Picture "@E 999,999.99"
				@ nLin,97 PSAY _nTot1PV Picture "@E 999,999.99"
				@ nLin,112 PSAY _nTot1CU+_nTot1PV Picture "@E 999,999.99"
			Else
				@ nLin,048 PSAY _nTot1Vl Picture "@E 999999,9999"
				@ nLin,059 PSAY _nTot1Qt Picture "@E 9999,999,9999"
				@ nLin,072 PSAY _nTot1CU Picture "@E 9999,9999"
				@ nLin,081 PSAY _nTot1Vl/_nTot1Qt Picture "@E 9,999.9999"
				@ nLin,094 PSAY _nTot1Vl/TRB->COBRE Picture "@E 9,999.9999"
				@ nLin,106 PSAY 99 Picture "@E 999.9999" // Custo do estoque
				@ nLin,115 PSAY (((_nTot1Vl/_nTot1CU)-99) / 99)*100 Picture "@E 9999.9999"
				@ nLin,125 PSAY (_nTot1Vl/_nTotRel)*100 Picture "@E 9999.9999"
			EndIf
			nLin++
			@ nLin,00 PSAY Replicate("-",limite)
			nLin++
			_cNome := Left(TRB->CODIGO,3)
			_nTot1Qt := 0.0000
			_nTot1Vl := 0.0000
			_nTot1CU := 0.0000
			_nTot1Pv := 0.0000
		Endif
		@ nLin,00 PSAY TRB->CODIGO
		@ nLin,07 PSAY TRB->DESCR

		If MV_PAR06 == 1 // Formato Fechamento
			@ nLin,048 PSAY TRB->QUANT Picture "@E 999,999,999"
			@ nLin,063 PSAY TRB->VALOR Picture  "@E 999,999,999.99"
			@ nLin,082 PSAY TRB->COBRE Picture "@E 999,999.99"
			@ nLin,097 PSAY TRB->PVC   Picture "@E 999,999.99"
			@ nLin,112 PSAY TRB->COBRE+TRB->PVC Picture "@E 999,999.99"
		Else //  Formato análise
			@ nLin,048 PSAY TRB->VALOR Picture "@E 999999,9999"
			@ nLin,059 PSAY TRB->QUANT Picture "@E 9999,999,999"
			@ nLin,072 PSAY TRB->COBRE Picture "@E 9999,9999"
			@ nLin,081 PSAY TRB->VALOR/TRB->QUANT Picture "@E 9,999.9999"
			@ nLin,094 PSAY TRB->VALOR/TRB->COBRE Picture "@E 9,999.9999"
			@ nLin,106 PSAY 99 Picture "@E 999.9999" // Custo do estoque
			@ nLin,115 PSAY (((TRB->VALOR/TRB->COBRE)-99) / 99)*100 Picture "@E 9999.9999"
			@ nLin,125 PSAY (TRB->VALOR/_nTotRel)*100 Picture "@E 9999.9999"
		EndIf
		_nTot1Qt += TRB->QUANT
		_nTot1Vl += TRB->VALOR
		_nTot1CU += TRB->COBRE
		_nTot1PV += TRB->PVC

		_nTot2Qt += TRB->QUANT
		_nTot2Vl += TRB->VALOR
		_nTot2CU += TRB->COBRE
		_nTot2PV += TRB->PVC
		nLin := nLin + 1
		TRB->(DbSkip())
	EndDo
	If nLin # 80
		If MV_PAR06 == 1 // Formato Fechamento
			@ nLin,07 PSAY "Total do Item:"
			@ nLin,48 PSAY _nTot1Qt Picture "@E 999,999,999"
			@ nLin,63 PSAY _nTot1Vl Picture  "@E 999,999,999.99"
			@ nLin,82 PSAY _nTot1CU Picture "@E 99,999,999.99"
			@ nLin,97 PSAY _nTot1PV Picture "@E 99,999,999.99"
			@ nLin,112 PSAY _nTot1CU+_nTot1PV Picture "@E 99,999,999.99"
			nLin++
			@ nLin,00 PSAY Replicate("-",limite)
			nLin++
			@ nLin,07 PSAY "Total do Relatório:"
			@ nLin,48 PSAY _nTot2Qt Picture "@E 999,999,999"
			@ nLin,63 PSAY _nTot2Vl Picture  "@E 999,999,999.99"
			@ nLin,82 PSAY _nTot2CU Picture "@E 99,999,999.99"
			@ nLin,97 PSAY _nTot2PV Picture "@E 99,999,999.99"
			@ nLin,112 PSAY _nTot2CU+_nTot2PV Picture "@E 99,999,999.99"
		Else
			@ nLin,07 PSAY "Total do Item:"
			@ nLin,048 PSAY _nTot1Vl Picture "@E 999999,9999"
			@ nLin,059 PSAY _nTot1Qt Picture "@E 9999,999,9999"
			@ nLin,072 PSAY _nTot1CU Picture "@E 9999,9999"
			@ nLin,081 PSAY _nTot1Vl/_nTot1Qt Picture "@E 9,999.9999"
			@ nLin,094 PSAY _nTot1Vl/TRB->COBRE Picture "@E 9,999.9999"
			@ nLin,106 PSAY 99 Picture "@E 999.9999" // Custo do estoque
			@ nLin,115 PSAY (((_nTot1Vl/_nTot1CU)-99) / 99)*100 Picture "@E 9999.9999"
			@ nLin,125 PSAY (_nTot1Vl/_nTotRel)*100 Picture "@E 9999.9999"
			nLin++
			@ nLin,00 PSAY Replicate("-",limite)
			nLin++
			@ nLin,07 PSAY "Total do Relatório:"
			@ nLin,048 PSAY _nTot2Vl Picture "@E 9999999,9999"
			@ nLin,059 PSAY _nTot2Qt Picture "@E 9999,999,9999"
			@ nLin,072 PSAY _nTot2CU Picture "@E 9999,9999"
			@ nLin,081 PSAY _nTot2Vl/_nTot1Qt Picture "@E 9,999.9999"
			@ nLin,094 PSAY _nTot2Vl/TRB->COBRE Picture "@E 9,999.9999"
			@ nLin,106 PSAY 99 Picture "@E 999.9999" // Custo do estoque
			@ nLin,115 PSAY (((_nTot2Vl/_nTot2CU)-99) / 99)*100 Picture "@E 9999.9999"
			@ nLin,125 PSAY (_nTot2Vl/_nTotRel)*100 Picture "@E 9999.9999"
		EndIf
		nLin := nLin + 1
		@ nLin,00 PSAY Replicate("-",limite)
	EndIf

	DbSelectArea("SD2")
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

	//Exporta Excel
	DbSelectArea("TRB")

	TRB->(DbGoTop())
	
	aStru := TRB->(DbStruct())
	
	While ! TRB->(EOF())
	 	Aadd(xPar,Array(Len(aStru)))
	 	For i := 1 to Len(aStru)
	 		xPar[Len(xPar),i] := &(aStru[i,1])
	 	Next
	 	TRB->(DbSkip())
	EndDo
	
	Aadd(aTablePed,{"Res.Bitolas"})
	Aadd(aWstPed,{"Res.Bitolas"})
	Aadd(aColun,{"Codigo","Descricao","Quantidade","Vlr.Venda","Cobre Kg","PVC Kg"})
	Aadd(aDadCon,xPar)
	
	lRet := U_TExcArr(aDadCon,aColun,aWstPed,aTablePed)

	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Descrição auto-gerada.
@author juliana.leme
@since 02/06/2017
@version undefined

@type function
/*/
Static Function ValidPerg

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Emissao                   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Emissao                ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Produto                   ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate o Produto                ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Tipo do Relatório            ?","mv_ch5","N",01,0,0,"C","","mv_par05","Faturamento"    ,"","","Bonificação"    ,"","","Fat.Entr.Fut."  ,"","","Rem.Entr.Fut."  ,"","","Ret.Industrial.","","","Proc.Triangul.","",""})
	aAdd(aRegs,{cPerg,"06","Formato                      ?","mv_ch6","N",01,0,0,"C","","mv_par06","Fechamento","","","Análise","","","","","","","","","","",""})

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


/*/{Protheus.doc} CriaTrb
//TODO Descrição auto-gerada.
@author juliana.leme
@since 02/06/2017
@version undefined

@type function
/*/
Static Function CriaTrb()
	private cThisTes := RelBitoIni(MV_PAR05)
	Private _aCampos := {}
	
	aAdd(_aCampos, {"CODIGO", "C", 05, 0})
	aAdd(_aCampos, {"DESCR" , "C", 40, 0})
	aAdd(_aCampos, {"QUANT" , "N", 20, 0})
	aAdd(_aCampos, {"VALOR" , "N", 30, 4})
	aAdd(_aCampos, {"COBRE" , "N", 30, 4})
	aAdd(_aCampos, {"PVC"   , "N", 30, 4})

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

	DbSelectArea("SF4")
	DbSetOrder(1)

	dbSelectArea("SD2")
	ProcRegua(LastRec())

	dbSetOrder(5) // D2_FILIAL+ DTOS(D2_EMISSAO)+D2_NUMSEQ
	DbSeek(xFilial("SD2")+Dtos(MV_PAR01),.T.)


	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_EMISSAO <= MV_PAR02 .And. SD2->(!Eof())
		IncProc()

		If SD2->D2_COD < MV_PAR03 .Or. SD2->D2_COD > MV_PAR04
			SD2->(DbSkip())
			Loop
		EndIf

		// Incluída esta variável em virtude da rotina de envio para sucata das tabelas C,D e Z.
		If Type("SD2->D2_TESORI") == "C"
			_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
		Else
			_cTesReal := SD2->D2_TES
		EndIf

		SF4->(DbSeek(xFilial("SF4")+_cTesReal,.F.))

		If !(_cTesReal $ cThisTes)
			SD2->(DbSkip())
			Loop
		EndIf


		If !_lTudo
			If (_lTrTL .and. SD2->D2_LOCAL <> "10") .or. (!_lTrTL .and. SD2->D2_LOCAL == "10")
				SD2->(DbSkip())
				Loop
			EndIf
		EndIf

		SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD,.F.))

		If MV_PAR05==5 .Or. SF4->F4_ESTOQUE == "S" .Or. SF4->F4_DUPLIC == "S" .Or. _cTesReal == "854"
			If !TRB->(DbSeek(Left(SD2->D2_COD,5),.F.))
				SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
				SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
				RecLock("TRB",.T.)
				TRB->CODIGO  := Left(SD2->D2_COD,5)
				CONOUT(TRB->CODIGO)
				If SZ1->(Eof()) .Or. SZ2->(Eof())
					TRB->DESCR   := SB1->B1_DESC
				Else
					TRB->DESCR   := AllTrim(SZ1->Z1_DESC) + " " + SZ2->Z2_DESC
				EndIf

			Else
				RecLock("TRB",.F.)
			EndIf
			If SF4->F4_ESTOQUE == "S" .Or. _cTesReal == "854" .Or. MV_PAR05==5 .Or. MV_PAR05==3
				TRB->QUANT += SD2->D2_QUANT
				TRB->COBRE += SD2->D2_QUANT * SB1->B1_PESCOB
				TRB->PVC   += SD2->D2_QUANT * SB1->B1_PESPVC
			EndIf
			If SF4->F4_DUPLIC == "S"
				TRB->VALOR += SD2->D2_TOTAL
				_nTotRel   += SD2->D2_TOTAL
			EndIf
			TRB->(MsUnLock())
		EndIf
		SD2->(DbSkip())
	EndDo
Return(.T.)


static function RelBitoIni(nOpc)
	local aIni 		:= {}
	local aRet		:= {}
	local oFormulas := ctrlIniFormul():newctrlIniFormul()
	local cKey  	:= AllTrim(GetNewPar('ZZ_TESRELB', 'TES_REL_BITO'))
	local nX		:= 0
	local cTesIni	:= ''

	oFormulas:setKeyForm(cKey)
	aRet := oFormulas:getFormulas()
	for nX := 1 to len(aRet)
		aIni := &(aRet[nX,3])
		if (aIni[2] == nOpc) .and. (iif(empty(aIni[3]), .T. , &(aIni[3])))
			cTesIni += '/' + aIni[4]
		endif
	next nX
	FreeObj(oFormulas)
return(cTesIni)

/*/{Protheus.doc} VejaTESu
//TODO Traz Tes Serie U.
@author juliana.leme
@since 02/06/2017
@version undefined
@param _TESFech, , descricao
@type function
/*/
User Function VejaTESu(_TESFech)
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+"500",.T.) // Procuro o primeiro TES de saída con softseek ligado
	Do While SF4->F4_FILIAL == xFilial("SF4") .And. !SF4->(Eof())
		If SF4->F4_CODIGO $ _TESFech .And. !Empty(SF4->F4_TES_U) .And. !SF4->F4_TES_U $ _TESFech 
			_TESFech := _TESFech + "//" + SF4->F4_TES_U
		EndIf
		SF4->(DbSkip())
	EndDo
Return(_TESFech)
