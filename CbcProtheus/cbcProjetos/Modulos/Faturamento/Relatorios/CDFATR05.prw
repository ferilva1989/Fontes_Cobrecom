#INCLUDE "rwmake.ch"

/*/{Protheus.doc} CDFATR05
//TODO Relatório de Relacão de Faturamento .
@author Roberto Oliveira
@since 04/04/2007
@version undefined

@type function
/*/
User Function CDFATR05()
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relacao de Faturamento"
	Local cPict          := ""
	Local titulo         := "Relacao de Faturamento"
	Local nLin           := 80
	Local Cabec1         := "Data       Cliente/Lj  Nome Cliente                    Vendedor                Docto.   tipo         Valor Merc.      Valor Faturado"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDFATR05" 
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0   
	Private cPerg        := "CDFTR5"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDFATR05" 

	Private cString := "SF2"

	dbSelectArea("SF2")
	dbSetOrder(1) 

	ValidPerg()
	pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	Processa( {|| CriaTrb() },"Selecionando Registros...")

	DbSelectArea("SF2")
	RetIndex("SF2")

	titulo         := "Relacao de Faturamento " + Dtoc(mv_par01) + " a " + Dtoc(mv_par02)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(.T.)

/*/{Protheus.doc} RunReport
//TODO Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
		monta a janela com a regua de processamento.
@author zzz
@since 01/06/2017
@version undefined
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	/*
	************************************************************************************************************************************
	Data       Cliente/Lj  Nome Cliente                    Vendedor                Docto.   tipo         Valor Merc.      Valor Faturado
	99/99/9999 999999  99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXX 999999   999999    999,999,999.99      999,999,999.99
	*/

	DbSelectArea("SA1")
	DbSetOrder(1)

	DbSelectArea("SA3")
	DbSetOrder(1)

	DbSelectArea("TRB")
	SetRegua(RecCount())
	DbGoTop()
	_nTot1 := 0.00
	_nTot2 := 0.00
	Do While TRB->(!Eof()) .And. !lAbortPrint
		IncRegua()

		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 60 // Salto de Página. Neste caso o formulario tem 60 linhas...
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
		Endif

		SA1->(DbSeek(xFilial("SA1")+TRB->CLIENTE+TRB->LOJA,.F.))
		SA3->(DbSeek(xFilial("SA3")+TRB->VENDE,.F.))

		@ nLin,000 PSAY TRB->EMISS
		@ nLin,011 PSAY TRB->CLIENTE
		@ nLin,019 PSAY TRB->LOJA
		@ nLin,023 PSAY Left(SA1->A1_NOME,30)             
		If Type("SA3->A3_CONTAT") == "C"
			@ nLin,055 PSAY TRB->VENDE+"-"+Left(SA3->A3_CONTAT,16)
		Else
			@ nLin,055 PSAY TRB->VENDE+"-"+Left(SA3->A3_NREDUZ,16)
		EndIf
		@ nLin,079 PSAY TRB->DOC
		@ nLin,089 PSAY TRB->TIPO
		@ nLin,098 PSAY TRB->TOTNF  Picture "@E 999,999,999.99"
		@ nLin,118 PSAY TRB->TOTFAT Picture "@E 999,999,999.99"
		_nTot1 += TRB->TOTNF
		_nTot2 += TRB->TOTFAT
		nLin := nLin + 1
		TRB->(DbSkip())
	EndDo

	If nLin # 80
		nLin := nLin + 1
		@ nLin,062 PSAY "Total do Relatório:"
		@ nLin,098 PSAY _nTot1  Picture "@E 999,999,999.99"
		@ nLin,118 PSAY _nTot2 Picture "@E 999,999,999.99"
	EndIf

	DbSelectArea("TRB")
	DbCloseArea()                                                                

	DbSelectArea("SF2")
	RetIndex("SF2")

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Valida Perguntas.
@author Roberto Oliveira
@since 01/04/2007
@version undefined

@type function
/*/
Static Function ValidPerg

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta					  /Variavel/Tipo/Tam/Dec/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Emissao                   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Emissao                ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

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
//TODO Criação Tabela Temporaria.
@author zzz
@since 01/04/2007
@version undefined

@type function
/*/
Static Function CriaTrb()
	Local oStatic    := IfcXFun():newIfcXFun()
	Private __cNomArq := ""// Arquivo Temporario
	Private _aCampos := {}
	Private _TESFech := oStatic:sP(1):callStatic('CDFATR04', 'RelBitoIni', 1)
	//"501//505//809//810//838//521//522//530//527//876//921//930/933/506//600//560//563//562//851" 
	//					"501//505//809//810//838//521//522//530//527//876//921//930/933/506//600//560//846//851//"
	// Importante: O TES das notas série U podem ser alterados conforme o envio para sucata, então, adicionar a variável _TESFech os TES
	// F4_TES_U de cada um deles
	_TESFech := u_VejaTESu(_TESFech)

	DbSelectArea("SF2")
	nIndSF2 := RetIndex("SF2")
	cIndSF2 := CriaTrab(NIL,.F.)
	IndRegua("SF2",cIndSF2,"F2_FILIAL+DtoS(F2_EMISORI)+F2_CDROMA")
	#IFNDEF TOP
	dbSetIndex(cIndSF2+OrdBagExt())
	#ENDIF
	dbSelectArea("SF2")
	dbSetOrder(nIndSF2+1)

	aAdd(_aCampos, {"EMISS"   , "D", 08, 0})
	aAdd(_aCampos, {"DOC"     , "C", Len(SF2->F2_DOC), 0})
	aAdd(_aCampos, {"TIPO"    , "C", 01, 0})
	aAdd(_aCampos, {"CLIENTE" , "C", TamSX3("A1_COD")[1], 0})
	aAdd(_aCampos, {"LOJA"    , "C", TamSX3("A1_LOJA")[1], 0})
	aAdd(_aCampos, {"VENDE"   , "C", TamSX3("A3_COD")[1], 2})
	aAdd(_aCampos, {"TOTNF"   , "N", 12, 2})
	aAdd(_aCampos, {"TOTFAT"  , "N", 12, 2})

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)
	Private _cInd := CriaTrab(Nil, .F.)
	IndRegua("TRB", _cInd, "DtoS(EMISS)+TIPO+DOC",,, "Selecionando Registros...")
	DbSetIndex(_cInd + OrdBagExt())

	/*
	IndRegua("SF2",cIndSF2,"F2_FILIAL+DtoS(F2_EMISORI)+F2_CDROMA")

	************************************************************************************************************************************
	Data       Cliente/Lj  Nome Cliente                    Vendedor                Docto.   tipo         Valor Merc.      Valor Faturado
	99/99/9999 999999  99  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  999999-XXXXXXXXXXXXXXXX 999999   999999    999,999,999.99      999,999,999.99
	*/
	dbSelectArea("SD2")                                      
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	dbSelectArea("SF2")                                      
	ProcRegua(LastRec())

	SF2->(DbSetOrder(3))
	DbSeek(xFilial("SF2")+' '+Dtos(MV_PAR01),.T.)
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_EMISORI <= MV_PAR02 .And. SF2->(!Eof())
		_lNF := .T.
		_cRoman   := SF2->F2_CDROMA
		_dData    := SF2->F2_EMISORI
		_nReg := SF2->(Recno())
		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_EMISORI == _dData .And. SF2->F2_CDROMA == _cRoman .And. SF2->(!Eof())

			SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			// Incluída esta variável em virtude da rotina de envio para sucata das tabelas C,D e Z.
			If Type("SD2->D2_TESORI") == "C"
				_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
			Else
				_cTesReal := SD2->D2_TES
			EndIf

			If _lNF .And. SF2->F2_SERIE == "U  " .And. SF2->F2_TIPO == "N" .And. _cTesReal $ _TESFech // É somente uma referência do que deve ser listado
				_lNF := .F. 
				Exit
			EndIf
			SF2->(DbSkip())
		EndDo
		SF2->(DbGoTo(_nReg))
		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_EMISORI == _dData .And. SF2->F2_CDROMA == _cRoman .And. SF2->(!Eof())

			SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))

			// Incluída esta variável em virtude da rotina de envio para sucata das tabelas C,D e Z.
			If Type("SD2->D2_TESORI") == "C"
				_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
			Else
				_cTesReal := SD2->D2_TES
			EndIf

			If SF2->F2_TIPO == "N" .And. _cTesReal $ _TESFech // É somente uma referência do que deve ser listado
				IncProc()                          
				If _lNF
					_cChave := DtoS(SF2->F2_EMISORI) + "N" + SF2->F2_DOC
				Else
					_cChave := DtoS(SF2->F2_EMISORI) + "R" + SF2->F2_CDROMA
				EndIf
				If !TRB->(DbSeek(_cChave))
					RecLock("TRB",.T.)
					TRB->EMISS     := SF2->F2_EMISORI
					TRB->DOC      := If(_lNF,SF2->F2_DOC,SF2->F2_CDROMA)
					TRB->TIPO     := If(_lNF,"N","R")
					TRB->CLIENTE  := SF2->F2_CLIENTE
					TRB->LOJA     := SF2->F2_LOJA
					TRB->VENDE    := SF2->F2_VEND1
				Else
					RecLock("TRB",.F.)
				EndIf
				TRB->TOTNF    += SF2->F2_VALMERC
				TRB->TOTFAT   += SF2->F2_VALFAT
				TRB->(MsUnLock())
			EndIf
			SF2->(DbSkip())
		EndDo
	EndDo                                       
Return(.T.)
