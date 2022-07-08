#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR12  º Autor ³ AP6 IDE            º Data ³  23/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR12()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Comparativo de Digitação de Inventário"
	Local cPict          := ""
	Local titulo       := "Comparativo de Digitação de Inventário"
	Local nLin         := 80

	Local Cabec1       := "Codigo           Descrição                                                     Almox. Acond.   Lance   1a.Contag.(M)   2a.Contag.(M)"
	Local Cabec2       := "                 Lote 1a Cont. Quant.1a Cont.     Lote 2a Cont. Quant.2a Cont."
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "CDESTR12" 
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cPerg       := "CDES12"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDESTR12" 

	Private cString := "SZG"

	ValidPerg()
	pergunte(cPerg,.T.)

	dbSelectArea("SZG")
	dbSetOrder(1)

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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  23/08/07   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	*
	****************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	****************************************************
	*                                
	DbSelectARea("SB1")
	DbSetOrder(1)

	_TOT1 := 0.00
	_TOT2 := 0.00
	_TOT3 := 0.00
	nTotTem := 0
	dbSelectArea("SZG")
	dbSetOrder(1) // ZG_FILIAL+ DTOS(ZG_DATA)+ZG_PRODUTO+ZG_LOCAL+ZG_ACOND+ STRZERO(ZG_LANCE,5)+ZG_LOTE
	//SetRegua(RecCount())
	DbSeek(xFilial("SZG")+DTOS(MV_PAR01)+MV_PAR02+MV_PAR04,.T.)
	Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_DATA == MV_PAR01 .And. SZG->ZG_PRODUTO <= MV_PAR03 .And. SZG->(!EOF())
		If lAbortPrint
			@ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif      
		If SZG->ZG_LOCAL < MV_PAR04 .Or. SZG->ZG_LOCAL > MV_PAR05
			//		IncRegua()
			DbSkip()
			Loop
		EndIf            

		If SZG->ZG_PRODUTO == "1010601101     "
			ccc:= 1
		EndIf
		// Está atrapalhando.... se o usuário esquecer não mostra possíveis erros
		/*/
		If MV_PAR06 # SZG->ZG_ACOND .And. MV_PAR06 # "*"
		IncRegua()
		DbSkip()
		Loop
		EndIf
		/*/
		SB1->(DbSeek(xFilial("SB1")+SZG->ZG_PRODUTO,.F.))
		_cCodCon := SB1->B1_CODCON
		_cProd := SZG->ZG_PRODUTO
		_cDesc := SZG->ZG_DESC
		_cLoca := SZG->ZG_LOCAL
		_cAcon := SZG->ZG_ACOND
		_cLanc := SZG->ZG_LANCE
		_cLote := SZG->ZG_LOTE
		_aPrim := {}
		_aSegu := {}
		_nTPri := 0
		_nTSeg := 0
		_nTTer := 0
		_lTem3 := .F.
		_nREgis := Recno()

		Do While SZG->ZG_FILIAL  == xFilial("SZG") .And. SZG->ZG_DATA == MV_PAR01 .And. SZG->(!EOF()) .And.;
		SZG->ZG_PRODUTO == _cProd .And. SZG->ZG_LOCAL == _cLoca .And. SZG->ZG_ACOND == _cAcon .And.;
		SZG->ZG_LANCE   == _cLanc .And. SZG->ZG_LOTE == _cLote

			//		ProcRegua()
			If SZG->ZG_CONTAG == "1"
				AAdd(_aPrim,{SZG->ZG_QUANT,SZG->ZG_LOTE,SZG->ZG_FORMA})
				//			AAdd(_aPrim,SZG->ZG_QUANT)
				_nTPri += SZG->ZG_METROS
			ElseIf SZG->ZG_CONTAG == "2"
				AAdd(_aSegu,{SZG->ZG_QUANT,SZG->ZG_LOTE,SZG->ZG_FORMA})
				//			AAdd(_aSegu,SZG->ZG_QUANT)
				_nTSeg += SZG->ZG_METROS
			Else
				_nTTer += SZG->ZG_METROS
				_lTem3 := .T.
			EndIf  
			SZG->(DbSkip())
		EndDo             

		If _lTem3
			_TOT3 += _nTTer
			DbGoTo(_nREgis)
			Do While SZG->ZG_FILIAL  == xFilial("SZG") .And. SZG->ZG_DATA == MV_PAR01 .And. SZG->(!EOF()) .And.;
			SZG->ZG_PRODUTO == _cProd .And. SZG->ZG_LOCAL == _cLoca .And. SZG->ZG_ACOND == _cAcon .And.;
			SZG->ZG_LANCE   == _cLanc .And. SZG->ZG_LOTE == _cLote .And. _lTem3

				If SZG->ZG_CONTAG # "3"
					RecLock("SZG",.F.)
					SZG->ZG_PESCOB := -1
					MsUnLock()
				EndIf  
				SZG->(DbSkip())
			EndDo
		Else
			_TOT1 += _nTSeg
			_TOT2 += _nTPri

		EndIf

		If _nTPri == _nTSeg .Or. _lTem3
			nTotTem +=  If(_lTem3,_nTTer,_nTPri)
			Loop
		EndIf                            
		//	aSort(_aPrim,,, {|x, y| x < y})
		//	aSort(_aSegu,,, {|x, y| x < y})
		_nMax := Max(Len(_aPrim),Len(_aSegu))
		For _nLinhas := 0 to _nMax
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif
			If _nLinhas == 0
				@ nLin,000 PSAY Left(_cProd,10)
				@ nLin,017 PSAY _cDesc
				@ nLin,080 PSAY _cLoca
				@ nLin,087 PSAY _cAcon
				@ nLin,093 PSAY _cLanc Picture "@E 999,999"
				@ nLin,105 PSAY _nTPri Picture "@E 999,999,999"
				@ nLin,121 PSAY _nTSeg Picture "@E 999,999,999"
				nLin := nLin + 1 // Avanca a linha de impressao
			Else
				@ nLin,000 PSAY _cCodCon
				_cCodCon := ""
				If _nLinhas <= Len(_aPrim)
					@ nLin,017 PSAY _aPrim[_nLinhas,2]
					@ nLin,034 PSAY _aPrim[_nLinhas,1] Picture "@E 999,999,999"
					@ nLin,045 PSAY "/"+_aPrim[_nLinhas,3]
				EndIf
				If _nLinhas <= Len(_aSegu)
					@ nLin,050 PSAY _aSegu[_nLinhas,2]
					@ nLin,067 PSAY _aSegu[_nLinhas,1] Picture "@E 999,999,999"
					@ nLin,078 PSAY "/"+_aSegu[_nLinhas,3]
				EndIf                
			EndIf
			nLin := nLin + 1 // Avanca a linha de impressao
		Next      
		If nLin < 54
			@ nLin,000 PSAY Replicate("-",limite)
			nLin := nLin + 1 // Avanca a linha de impressao
		EndIf
	EndDo

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return(.T.)
	*
*
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
	Aadd(aRegs,{cPerg,"02","Do Produto                   ?","mv_ch2","C",15,0,0,"G","","Mv_Par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	Aadd(aRegs,{cPerg,"03","Ate o Produto                ?","mv_ch3","C",15,0,0,"G","","Mv_Par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
	Aadd(aRegs,{cPerg,"04","Do Armazem                   ?","mv_ch4","C",02,0,0,"G","","Mv_Par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"05","Ate o Armazem                ?","mv_ch5","C",02,0,0,"G","","Mv_Par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"06","Acondicionamento             ?","mv_ch6","C",01,0,0,"G","","Mv_Par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
