#INCLUDE "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATR02                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: ROBERTO F. OLIVEIRA                Data ..: 29/09/2004   //
//                                                                          //
//   Objetivo ...: Relatório de Romaneio de Carga                           //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDFATR02()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Ordem de Compra/Ordem de Carga"
	Local cPict         := ""
	Local nLin          := 80

	Local imprime       := .T.
	Local aOrd := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "CDFATR02"
	Private nTipo       := 15
	Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "ROMAN1"
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDROMAN"
	Private _cPedido
	Private cString := "SF2"

	Private titulo     := "Ordem de Compra" //"Romaneio"
	Private Cabec1     := ""
	Private Cabec2     := ""

	dbSelectArea("SF2")
	dbSetOrder(1) // FILIAL+DOC+SERIE+CLIENTE+LOJA+FORMUL

	/*
	MV_PAR01 - Da Série
	MV_PAR02 - Até a Série
	MV_PAR03 - Do Número
	MV_PAR04 - Até o Número
	MV_PAR05 - Da Emissão
	MV_PAR06 - Até a Emissão
	*/

	ValidPerg()
	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	titulo := If(MV_PAR07==2,"Ordem de Carga","Ordem de Compra") // "Romaneio")

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


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SF2")
	DBOrderNickName("SF2CDROMA")
	//dbSetOrder(7) // F2_FILIAL+F2_CDROMA
	SetRegua(RecCount())

	SF2->(DbSeek(xFilial("SF2")+MV_PAR03,.T.))
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA <= MV_PAR04 .And. SF2->(!Eof())
		IncRegua()
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If SF2->F2_EMISSAO < MV_PAR05 .Or. SF2->F2_EMISSAO >  MV_PAR06
			SF2->(DbSkip())
			Loop
		EndIf
		//
		// Verifica se é um romaneio e se tem o nro da carga
		DbSelectArea("SF2")
		_aAreaF2 := GetArea()
		_cNumRom := SF2->F2_CDROMA
		If Empty(SF2->F2_CDCARGA)
			_cNumCar := Soma1(GETMV("MV_CDCARGA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDCARGA",.F.)
				Dbseek("  MV_CDCARGA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumCar
				SX6->(MsUnlock())
			Endif
		Else
			_cNumCar := SF2->F2_CDCARGA
		EndIf
		_lIsRom := .F.                       
		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _cNumRom .And. SF2->(!Eof())
			If Empty(SF2->F2_CDCARGA)
				RecLock("SF2",.F.)
				SF2->F2_CDCARGA := _cNumCar
				MsUnLock()
			EndIf
			If !SF2->F2_SERIE $ "UNI//1  //"
				_lIsRom := .T.
			EndIf
			SF2->(DbSkip())
		EndDo

		If !_lIsRom .And. MV_PAR07 == 1 // Não é romaneio e quero Romaneio
			Loop
		EndIf   

		RestArea(_aAreaF2)
		//
		//Posiciona cadastro de transportadoras             
		SA4->(DbSetOrder(1))
		SA4->(DbSeek(xFilial("SA4") + SF2->F2_TRANSP, .F.))

		// Posiciona Cadastro de Clientes/Fornecedores
		If SF2->F2_TIPO $ "DB" // Fornecedores
			Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"")
			_Lin1 := "Fornecedor...: " + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + " - " + SA2->A2_NOME
			_Lin2 := "Endereco.....: " + Left(SA2->A2_END,40) + "            Bairro: " + Left(SA2->A2_BAIRRO,20)
			//		_Lin3 := "Cidade.......: "  + Left(SA2->A2_MUN,30)+"             UF: " + SA2->A2_EST + "       CEP:  " + Transform(SA2->A2_CEP,"@R 99999-999") + "   Tel.: (" + SA2->A2_DDD + ") " + Left(SA2->A2_TEL,20)
			_Lin3 := "Cidade.......: "  + Left(SA2->A2_MUN,30)+"      UF: " + SA2->A2_EST + "     CEP: " + Transform(SA2->A2_CEP,"@R 99999-999") + "    Tel.: (" + SA2->A2_DDD + ") " + Left(SA2->A2_TEL,15) + "    Fax.: " + Left(SA2->A2_FAX,15)
			_Lin4 := "Representante: " + SF2->F2_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")
		Else // Clientes
			Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"")
			_Lin1 := "Cliente......: " + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + " - " + SA1->A1_NOME
			_Lin2 := "Endereco.....: " + Left(SA1->A1_END,40) + "            Bairro: " + Left(SA1->A1_BAIRRO,20)
			_Lin3 := "Cidade.......: "  + Left(SA1->A1_MUN,30)+"      UF: " + SA1->A1_EST + "     CEP: " + Transform(SA1->A1_CEP,"@R 99999-999") + "    Tel.: (" + SA1->A1_DDD + ") " + Left(SA1->A1_TEL,15) + "    Fax.: " + Left(SA1->A1_FAX,15)
			_Lin4 := "Representante: " + Left(SF2->F2_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")+Space(50),50) + ;
			"  e-Mail: " + Lower(SA1->A1_EMAILCT)
		EndIf 
		_Lin5 := "Transportador: " + Left(SA4->A4_NOME+Space(52),52) + "Ord.Carga.: " + _cNumCar

		//	_cNumRom := SF2->F2_CDROMA
		//	_cNumCar := SF2->F2_CDCARGA
		aValores := {}
		WCREDITO := 0
		aChave := {}
		aD2_Cod := {}
		aD2_UM := {}
		_aAcondic := {}
		aD2_QUANT := {}
		aD2_TOTAL := {}
		aPeso := {}
		_nPesoL := 0.00
		_nPesoB := 0.00
		_cPedido := ""
		_cOrdCpa := ""
		nValIPI := nValSubs := 0.00
		_dDtRoman := SF2->F2_EMISSAO

		u_MonteRoman()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If MV_PAR07 == 1
			titulo       := "Ordem de Compra - " + _cNumRom
		Else
			titulo       := "Ordem de Carga - " + _cNumCar
		EndIf

		ImpCab()
		nLin:=9
		If MV_PAR07 == 1	
			@ 09,00 PSAY "Condicoes de Pagamento:"
			@ 10,26 PSAY "Vencto        Valor R$.   Vencto        Valor R$.   Vencto        Valor R$.   Vencto        Valor R$."
			nLin := 11
			nCol := 26
			For i := 1 to Len(aValores)
				@ nLin,nCol PSAY aValores[i,1]
				@ nLin,nCol+12 PSAY aValores[i,2] Picture "@E 999,999.99"
				nCol +=  26
				If nCol > 104
					nCol := 26
					nLin++
				EndIf
			Next
			If nCol # 0
				nLin++
			EndIf
			@ nLin++,0 PSAY Replicate("-",limite)
		EndIf
		If MV_PAR07 == 1
			@ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant.    Vlr. Unit.       Total"
		Else
			@ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
		EndIf
		nLin++
		nTotItens := 0.00
		For _nQtdLin :=1 To Len(aChave)
			If nLin > 60
				ImpCab()
				If MV_PAR07 == 1
					@ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant.    Vlr. Unit.       Total"
				Else
					@ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
				EndIf
				nLin := 14
			EndIf
			@ nLin,000 PSAY aD2_COD[_nQtdLin] Picture PesqPict("SB1","B1_COD",TAMSX3("B1_COD")[1])
			@ nLin,017 PSAY Left(Posicione("SB1",1,xFilial("SB1")+aD2_COD[_nQtdLin],"B1_DESC"),50)
			@ nLin,069 PSAY _aAcondic[_nQtdLin]
			@ nLin,079 PSAY aD2_UM[_nQtdLin]
			@ nLin,083 PSAY aD2_QUANT[_nQtdLin] Picture "@E 999,999.99"

			If MV_PAR07 == 1
				@ nLin,095 PSAY aD2_TOTAL[_nQtdLin] / aD2_QUANT[_nQtdLin] Picture "@E 999,999.9999"
				@ nLin,109 PSAY aD2_TOTAL[_nQtdLin] Picture "@E 999,999.99"
			EndIf     
			nLin++
			nTotItens += aD2_TOTAL[_nQtdLin]
			//		nPeso += (aD2_QUANT[_nQtdLin] * aPeso[_nQtdLin])
		Next
		If nLin > 54
			ImpCab()
		EndIf
		nLin := 54  

		@ nLin++,0 PSAY Replicate("-",limite)

		@ nLin,004 PSAY "Peso Bruto:"
		@ nLin,016 PSAY _nPesoB Picture "@E 999,999.99"
		//	@ nLin,016 PSAY nPeso+_nPesoBob Picture "@E 999,999.99"

		@ nLin,032 PSAY "Peso Liquido:"
		@ nLin,046 PSAY _nPesoL Picture "@E 999,999.99"

		@ nLin,060 PSAY "Nro. O.C.:"
		@ nLin,071 PSAY _cOrdCpa

		@ nLin,078 + If(!Empty(_cOrdCpa),Len(_cOrdCpa) - 6,0) PSAY "Nro Pedido:"
		@ nLin++,Pcol()+1 PSAY _cPedido  // SC6->C6_NUM

		If MV_PAR07 == 1
			@ nLin++,000 PSAY Replicate("-",limite)
			@ nLin++,004 PSAY "Valor Merc.               IPI        Subst.Trib.          Pagto(1)          Pagto(2)          Pagto(1+2)"

			//   Valor Merc.               IPI        Subst.Trib.             Total          Creditos        Vlr. Liquido"
			//   Valor Merc.               IPI        Subst.Trib.          Pagto(1)          Pagto(2)          Pagto(1+2)"
			//   Valor Merc.               IPI        Subst.Trib.        Sub. Total          Creditos        Vlr. Liquido
			//    999,999.99        999,999.99        999,999.99         999,999.99        999,999.99          999,999.99
			//    5                 23                41                 60                78                  98

			@ nLin,005 PSAY nTotItens     Picture "@E 999,999.99"
			@ nLin,023 PSAY nValIPI       Picture "@E 999,999.99"
			@ nLin,041 PSAY nValSubs      Picture "@E 999,999.99"


			@ nLin  ,060 PSAY WCREDITO+nValIPI+nValSubs      Picture "@E 999,999.99"
			@ nLin  ,078 PSAY (nTotItens+nValIPI+nValSubs)-(WCREDITO+nValIPI+nValSubs) Picture "@E 999,999.99"
			@ nLin++,098 PSAY nTotItens+nValIPI+nValSubs     Picture "@E 999,999.99"
		EndIf
		@ nLin,000 PSAY Replicate("-",limite)
	EndDo
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

/////////////////////////
Static Function ValidPerg()
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Série                     ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Série                  ?","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Documento                 ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até o Documento              ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Da Emissão                   ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até a Emissão                ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Imprimir                     ?","mv_ch7","N",01,0,0,"C","","mv_par07","Ordem de Compra","","","","","Ordem","","","","","","","","",""})

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

Return


Static Function ImpCab()

	@ 00,0 PSAY "Data: "
	@ 00,Pcol() PSAY _dDtRoman
	@ 00,Pcol()+2 PSAY Time() Picture "99:99:99"
	If MV_PAR07 == 1
		@ 00,061 PSAY "Ordem de Compra" //"Romaneio"
		@ 00,125 PSAY  _cNumRom
	Else
		@ 00,059 PSAY "Ordem de Carga"
		@ 00,125 PSAY  _cNumCar
	EndIf
	@ 02,0 PSAY Replicate("-",limite)
	//Cabec("Romaneio - " + _cNumRom,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@ 03,0 PSAY _Lin1
	@ 04,0 PSAY _Lin2
	@ 05,0 PSAY _Lin3
	@ 06,0 PSAY _Lin4
	@ 07,0 PSAY _Lin5
	@ 08,0 PSAY Replicate("-",limite)
	Return(.T.)
	*
	**************************
User Function MonteRoman()
	**************************
	*            
	_nPesoL := 0.00
	_nPesoB := 0.00

	SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	_lPreco := .F.
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _cNumRom .And. SF2->(!Eof())
		//	If SF2->F2_SERIE == "UNI"
		If SF2->F2_SERIE $ "UNI/J  //1  //"
			nValSubs += SF2->F2_ICMSRET
		EndIf 
		_nPesoL += SF2->F2_PLIQUI
		_nPesoB += SF2->F2_PBRUTO

		//_nPesoBob := If(_nPesoBob==0.and. SF2->F2_PESOBOB > 0,SF2->F2_PESOBOB,_nPesoBob)
		//Verifica os vencimentos e valores na tabela SE1 - Contas a Receber
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL,.F.)
		Do While SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DUPL .And. SE1->(!Eof())
			If !SE1->E1_TIPO $ "NF /NFE"
				SE1->(DbSkip())
				Loop
			EndIf
			//		If SF2->F2_SERIE # "UNI" //Não são incluídos os valores das UNIs
			If !SF2->F2_SERIE $ "UNI/J  //1  //" //Não são incluídos os valores das UNIs/ Js
				// Procura em aValores se já tem um vencimento
				_cPos := aScan(aValores,{ |x| x[1] == SE1->E1_VENCTO})
				If _cPos # 0
					aValores[_cPos,2] += SE1->E1_VALOR
				Else
					AADD(aValores,{SE1->E1_VENCTO,SE1->E1_VALOR})
				EndIf
			EndIf
			SE1->(DbSkip())
		EndDo

		DbSelectArea("SD2")
		DbSetOrder(3)  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
		Do While SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA ==;
		xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA .And.	SD2->(!Eof())

			If Type("SD2->D2_TESORI") == "C"
				_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
			Else
				_cTesReal := SD2->D2_TES
			EndIf

			DbSelectArea("SF4")
			DbSeek(xFilial("SF4")+_cTesReal,.F.)

			If SF4->F4_ESTOQUE=="S" .Or. (SF4->F4_ESTOQUE=="N" .And. SF4->F4_DUPLIC == "N")  .Or. (SD2->D2_QUANT == 0.00 .And. SF4->F4_DUPLIC == "S")
				_cAcondic := "    "
				_cAcon    := " "
				If SF4->F4_ESTOQUE=="S"
					DbSelectArea("SDB")                 
					If !Empty(SD2->D2_TESORI) // Já transferido para sucata
						DbSetOrder(7) // DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID
						DbSeek(xFilial("SDB") + SD2->D2_COD + Left(SD2->D2_DOC,6) + "-" + SD2->D2_ITEM,.F.)
					Else
						DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
						DbSeek(xFilial("SDB") + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_NUMSEQ+ SD2->D2_DOC + SD2->D2_SERIE+ SD2->D2_CLIENTE + SD2->D2_LOJA,.F.)
					EndIf
					If Left(SDB->DB_LOCALIZ,1)=="R"
						_cAcondic := "ROLO"
					ElseIf Left(SDB->DB_LOCALIZ,1)=="B"
						_cAcondic := "BOB."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="M"
						_cAcondic := "CAR.MAD"
					ElseIf Left(SDB->DB_LOCALIZ,1)=="C"
						_cAcondic := "CAR."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="T"
						_cAcondic := "RET."
					EndIf
					_cAcon := Left(SDB->DB_LOCALIZ,1)
				Else
					DbSelectArea("SC6")
					DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD,.F.)
					If SC6->C6_ACONDIC=="R"
						_cAcondic := "Rolo"
					ElseIf SC6->C6_ACONDIC=="B"
						_cAcondic := "BOB."
					ElseIf SC6->C6_ACONDIC=="M"
						_cAcondic := "CAR.MAD"
					ElseIf SC6->C6_ACONDIC=="C"
						_cAcondic := "CAR"
					ElseIf SC6->C6_ACONDIC=="T"
						_cAcondic := "RET."
					ElseIf SC6->C6_ACONDIC=="L"
						_cAcondic := "BLIS"
					EndIf
					_cAcon := SC6->C6_ACONDIC
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+SD2->D2_COD,.F.)

				_nPos := Ascan(aChave,SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD+_cAcon)
				If _nPos == 0
					AADD(aChave,SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD+_cAcon)
					AADD(aD2_Cod,SD2->D2_COD)
					AADD(aD2_UM,SD2->D2_UM)
					AADD(_aAcondic,_cAcondic)
					AADD(aD2_QUANT,0.00)
					AADD(aD2_TOTAL,0.00)
					AADD(aPeso,SB1->B1_PESO)
					//				AADD(aPeso,SB1->B1_PESBRU)
					_nPos := Len(aChave)
				EndIf

				If SF4->F4_ESTOQUE=="S"
					aD2_QUANT[_nPos] += SD2->D2_QUANT
					If SF4->F4_DUPLIC == "N" // Bonificações
						aD2_TOTAL[_nPos] += SD2->D2_TOTAL
					EndIf
				EndIf
				If SF4->F4_DUPLIC =="S"
					aD2_TOTAL[_nPos] += SD2->D2_TOTAL
				EndIf
				If SF4->F4_ESTOQUE=="N" .And. SF4->F4_DUPLIC == "N"
					aD2_QUANT[_nPos] += SD2->D2_QUANT
					aD2_TOTAL[_nPos] += SD2->D2_TOTAL
				EndIf
				nValIPI += SD2->D2_VALIPI
				//			If SF2->F2_SERIE == "UNI"
				If SF2->F2_SERIE $ "UNI/J  //1  //"
					WCREDITO += SD2->D2_TOTAL
				EndIf
				If Empty(_cPedido)
					_cPedido := SD2->D2_PEDIDO
				ElseIf !(SD2->D2_PEDIDO $ _cPedido)
					_cPedido := _cPedido + ", " + SD2->D2_PEDIDO
				EndIf                   
				xocc := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_PEDCLI")
				If Empty(_cOrdCpa)
					_cOrdCpa := AllTrim(xocc)
				ElseIf !Empty(xocc) .And. !AllTrim(xocc) $ _cOrdCpa
					_cOrdCpa := _cOrdCpa + ", " + AllTrim(xocc)
				EndIf
			Else
				_lPreco := .T.
			EndIf
			SD2->(DbSkip())
		EndDo
		SF2->(DbSkip())
	EndDo
	If _lPreco // Preço Unitário está errado..... rever pelo pedido de venda
		nTamChv := Len(SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD)
		For _nPos := 1 to Len(aChave)
			SC6->(DbSeek(xFilial("SC6")+Left(aChave[_nPos],nTamChv),.F.))
			aD2_TOTAL[_nPos] := (aD2_QUANT[_nPos] * SC6->C6_PRCVEN)
		Next
	EndIf
Return(.T.)