#INCLUDE "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATR11                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: EDVAR W. VASSAITIS                 Data ..: 20/01/2011   //
//                                                                          //
//   Objetivo ...: Relatório de ORDEM DE COMPRA                             //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDFATR11()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Ordem de Compra"
	Local cPict         := ""
	Local nLin          := 80

	Local imprime       := .T.
	Local aOrd := {}
	Private Lend        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "CDFATR11"
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

	Private titulo     := "Ordem de Compra"
	Private Cabec1     := ""
	Private Cabec2     := ""

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1)) // FILIAL+DOC+SERIE+CLIENTE+LOJA+FORMUL

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

	titulo := If(MV_PAR07==2,"Ordem de Carga","Ordem de Compra")

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
		_aAreaF2 := SF2->(GetArea())
		_cNumRom := SF2->F2_CDROMA
		_nPesoB  := 0
		_nPesoL  := 0

		If Empty(SF2->F2_CDCARGA)
			_cNumCar := Soma1(GETMV("MV_CDCARGA"))
			DbSelectArea("SX6")
			If !DbSeek(FWCodFil()+"MV_CDCARGA",.F.)
				DbSeek("  MV_CDCARGA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumCar
				SX6->(MsUnlock())
			Endif
		Else
			_cNumCar := SF2->F2_CDCARGA
		EndIf
		_lIsRom   := .F.
		_lIsSoRom := .T.
		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _cNumRom .And. SF2->(!Eof())
			If Empty(SF2->F2_CDCARGA)
				RecLock("SF2",.F.)
				SF2->F2_CDCARGA := _cNumCar
				MsUnLock()
			EndIf
			If !SF2->F2_SERIE $ "UNI//1  //"
				_lIsRom   := .T.
				_lIsSoRom := .F.
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
		SA4->(DbSeek(xFilial("SA4") + SF2->F2_TRANSP,.F.))

		// Posiciona Cadastro de Clientes/Fornecedores
		_Lin6 := ""
		If SF2->F2_TIPO $ "DB" // Fornecedores
			Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"")
			_Lin1 := "Fornecedor...: " + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + " - " + SA2->A2_NOME
			_Lin2 := "Endereco.....: " + Left(SA2->A2_END,40) + "            Bairro: " + Left(SA2->A2_BAIRRO,20)
			//		_Lin3 := "Cidade.......: "  + Left(SA2->A2_MUN,30)+"             UF: " + SA2->A2_EST + "       CEP:  " + Transform(SA2->A2_CEP,"@R 99999-999") + "   Tel.: (" + SA2->A2_DDD + ") " + Left(SA2->A2_TEL,20)
			_Lin3 := "Cidade.......: "  + Left(SA2->A2_MUN,30)+"      UF: " + SA2->A2_EST + "     CEP: " + Transform(SA2->A2_CEP,"@R 99999-999") + "    Tel.: (" + SA2->A2_DDD + ") " + Left(SA2->A2_TEL,15) + "    Fax.: " + Left(SA2->A2_FAX,15)
			_Lin4 := "Representante: " + SF2->F2_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")
		Else // Clientes
			Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"")
			//		_Lin1 := "Cliente......: " + SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + " - " + SA1->A1_NOME
			_Lin1 := "Cliente......: " + SA1->A1_NOME
			_Lin2 := "Endereco.....: " + Left(SA1->A1_END,40) + "            Bairro: " + Left(SA1->A1_BAIRRO,20)
			_Lin3 := "Cidade.......: "  + Left(SA1->A1_MUN,30)+"      UF: " + SA1->A1_EST + "     CEP: " + Transform(SA1->A1_CEP,"@R 99999-999") + "    Tel.: (" + SA1->A1_DDD + ") " + Left(SA1->A1_TEL,15) + "    Fax.: " + Left(SA1->A1_FAX,15)
			_Lin4 := "Representante: " + Left(SF2->F2_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+SF2->F2_VEND1,"A3_NOME")+Space(50),50) + ;
			"  e-Mail: " + Lower(SA1->A1_EMAILCT)
		EndIf
		_cNomTrp := If("PROPRIO"$SA4->A4_NOME,"PROPRIO",SA4->A4_NOME)
		_Lin5 := "Transportador: " + Left(_cNomTrp+Space(52),52) + "Posicionamento.: " + _cNumCar

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
		_nPesoBob := 0.00
		_cPedido := ""
		_cOrdCpa := ""
		nValIPI := nValSubs := 0.00
		_dDtRoman := SF2->F2_EMISSAO

		u_MonteRoman()

		cFilAux := ""
		/*/
		By Roberto Oliveira 16/03/16
		Ao efetuar manutenção neste proframa, vi a sequencia abaixo. Não entendi ainda do que se trata,
		mas não pude deixar de reparar os erros:
		1 - DbSeek em SA1 com xFilial("SC5") - SA1 é compartilhado e SC5 exclusivo;
		2 - Não está usando a loja para busca no SA1;
		3 - Pega o registro atual do SM0 para nRegSM0 e não reposiciona após a consulta;
		4 - Verifica TODO o SM0 e não só os registros da mesma empresa


		IF MV_PAR07 == 2
		SA1->(DbSeek(xFilial("SC5") + SC5->C5_CLIENTE))
		nRegSM0 := SM0->(RECNO())
		SM0->(DBGOTOP())
		DO WHILE !SM0->(EOF())
		IF SM0->M0_CGC  == SA1->A1_CGC
		cFilAux :=FWCodEmp()+FWCodFil()
		ENDIF
		SM0->(DBSKIP())
		ENDDO
		ENDIF

		Fim By Roberto Oliveira 16/03/16
		/*/

		If MV_PAR07 == 2
			SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)) ;SA1->(DbSetOrder(1))
			nRegSM0 := SM0->(Recno())
			SM0->(DbGoTop())
			Do While !SM0->(Eof())
				If FWCodEmp() == cEmpAnt .And. SM0->M0_CGC == SA1->A1_CGC
					cFilAux := FWCodEmp() + FWCodFil()
					Exit // achou -> cai fora
				EndIf
				SM0->(DbSkip())
			EndDo
			SM0->(DbGoTo(nRegSM0))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If MV_PAR07 == 2
			titulo       := "Ordem de Compra - " + _cNumRom
			If _lIsSoRom .And. Len(_cPedido) == 6 // Somente 1 pedido
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+_cPedido,.F.))
					//Alteração Juliana 20/07/2016
					_cLcEnt := ""
					If !Empty(Alltrim(SC5->C5_ENDENT1))
						_cLcEnt := AllTrim(SC5->C5_ENDENT1)+" "+AllTrim(SC5->C5_ENDENT2)
					Else
						DbSelectArea("SA1")
						DbSetOrder(1)
						If DBSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
							_cLcEnt := Alltrim(SA1->A1_END)
							_cLcEnt += " - " + Alltrim(SA1->A1_BAIRRO)
							_cLcEnt += "   " + Alltrim(SA1->A1_MUN)
							_cLcEnt += " - " + Upper(SA1->A1_EST)
							//AllTrim(SC5->C5_ENDENT1)+" "+AllTrim(SC5->C5_ENDENT2)
						EndIf
					EndIf
					//Fim Alteração Juliana 20/07/2016
					If !Empty(_cLcEnt)
						_Lin6 := "Local Entr.: " + Left(_cLcEnt,(limite-25))
					EndIf
				EndIf
			EndIf
		Else
			titulo       := "Ordem de Carga - " + _cNumCar
		EndIf

		nLin:=ImpCab()
		If MV_PAR07 == 1
			nTotDup := 0
			For i := 1 to Len(aValores)
				nTotDup += aValores[i,2]
			Next
			@ nLin,000 PSAY "Disparo de Producao:"
			@ nLin,026 PSAY DtoC(_dDtRoman)
			@ nLin,038 PSAY WCREDITO+nValIPI Picture "@E 999,999.99"
			@ nLin,052 PSAY "F.INC."
			@ nLin,059 PSAY nValSubs Picture "@E 999,999.99"
			@ nLin++,117 PSAY nTotDup Picture "@E 999,999.99"
			@ nLin++,000 PSAY Replicate("-",limite)
			@ nLin++,026 PSAY "Vencto        Valor R$.   Vencto        Valor R$.   Vencto        Valor R$.   Vencto        Valor R$."
			//		nLin := 11
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
			If nCol # 26
				nLin++
			EndIf
			@ nLin++,0 PSAY Replicate("-",limite)
		EndIf
		If MV_PAR07 == 1
			//		@ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant.    Vlr. Unit.       Total"
			@ nLin++,0 PSAY "Produto                                                              Acondic.  UM      Quant.    Vlr. Unit.       Total"
		Else
			IF !Empty(cFilAux) .AND. cFilAux <> cNumEmp
				//		   @ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant. Filial Destino Pedido Destino Item Destino"
				@ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
			ELSE
				@ nLin++,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
			ENDIF
		EndIf
		nLin++
		nPeso := nTotItens := 0.00
		_cBobsOk := ""

		IF MV_PAR07 == 2 .AND. !Empty(cFilAux) .AND. cFilAux <> cNumEmp  // PAULO INGLES

			aLista := {}
			lRisca := .F.

			For _nQtdLin :=1 To Len(aChave)

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aD2_COD[_nQtdLin],.F.))
				If SB1->B1_NOME # Left(aD2_COD[_nQtdLin],3) // Não é fios ou cabos
					_cProd := SB1->B1_DESC
					_cBitol:=" "
					_cCor  :=" "
				Else
					_cProd :=Alltrim(Posicione("SZ1",1,xFilial("SZ1")+Left(aD2_COD[_nQtdLin],3),"Z1_APELIDO"))
					_cBitol:=" "+Alltrim(Posicione("SZ2",1,xFilial("SZ2")+Substr(aD2_COD[_nQtdLin],4,2),"Z2_DESC"))
					_cCor  :=" "+Alltrim(Posicione("SZ3",1,xFilial("SZ3")+Substr(aD2_COD[_nQtdLin],6,2),"Z3_DESC"))
					If !Empty(SB1->B1_CLASENC) .And. SB1->B1_ESPECIA # "00" .And. SB1->B1_ESPECIA # "01"  //Especial
						_cCor += " (E)"
					EndIf
				EndIf

				SC6->(DbSeek(xFilial("SC6") + SUBSTR(aChave[_nQtdLin],1,23)))

				AADD(aLista, { aD2_COD[_nQtdLin],;
				Left(_cProd+_cBitol+_cCor,50),;
				_aAcondic[_nQtdLin],;
				aD2_UM[_nQtdLin],;
				aD2_QUANT[_nQtdLin],;
				SC6->C6_X_FLDES,;
				SC6->C6_X_PVDES,;
				SC6->C6_X_ITDES })

			Next

			aSort(aLista,,,{|x,y| x[6]+x[1]<y[6]+y[1]})

			For _nQtdLin :=1 To Len(aLista)

				If nLin > 60
					ImpCab()
					If MV_PAR07 == 1
						// @ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant.    Vlr. Unit.       Total"
						@ 12,0 PSAY "Produto                                                              Acondic.  UM      Quant.    Vlr. Unit.       Total"
					Else
						@ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
					EndIf
					nLin := 14
				EndIf
				If MV_PAR07 # 1
					//			 @ nLin,000 PSAY aD2_COD[_nQtdLin] Picture PesqPict("SB1","B1_COD",TAMSX3("B1_COD")[1])
				EndIf
				//@ nLin,017 PSAY Left(Posicione("SB1",1,xFilial("SB1")+aD2_COD[_nQtdLin],"B1_DESC"),50)

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aD2_COD[_nQtdLin],.F.))
				If SB1->B1_NOME # Left(aD2_COD[_nQtdLin],3) // Não é fios ou cabos
					_cProd := SB1->B1_DESC
					_cBitol:=" "
					_cCor  :=" "
				Else
					_cProd :=Alltrim(Posicione("SZ1",1,xFilial("SZ1")+Left(aD2_COD[_nQtdLin],3),"Z1_APELIDO"))
					_cBitol:=" "+Alltrim(Posicione("SZ2",1,xFilial("SZ2")+Substr(aD2_COD[_nQtdLin],4,2),"Z2_DESC"))
					_cCor  :=" "+Alltrim(Posicione("SZ3",1,xFilial("SZ3")+Substr(aD2_COD[_nQtdLin],6,2),"Z3_DESC"))
					If !Empty(SB1->B1_CLASENC) .And. SB1->B1_ESPECIA # "00" .And. SB1->B1_ESPECIA # "01"  //Especial
						_cCor += " (E)"
					EndIf
				EndIf

				@ nLin,000 PSAY Left(aLista[_nQtdLin,1],If(Empty(SB1->B1_NOME),Len(SB1->B1_COD),10))
				@ nLin,If(MV_PAR07==1,000,017) PSAY aLista[_nQtdLin,2]
				@ nLin,069 PSAY aLista[_nQtdLin,3]
				@ nLin,079 PSAY aLista[_nQtdLin,4]
				@ nLin,083 PSAY aLista[_nQtdLin,5] Picture "@E 999,999.99"

				//          SC6->(DbSeek(xFilial("SC6") + SUBSTR(aChave[_nQtdLin],1,23)))
				@ nLin,100 PSAY aLista[_nQtdLin,6]
				@ nLin,112 PSAY aLista[_nQtdLin,7]
				@ nLin,128 PSAY aLista[_nQtdLin,8]

				nLin++

				IF _nQtdLin <> Len(aLista) .AND. !Empty(aLista[_nQtdLin + 1,6]) .AND. !lRisca
					nLin++
					//	         @ nLin,0 PSAY "PRODUTOS PARA ATENDER PEDIDOS DE ORIGEM"
					@ nLin,0 PSAY "PRODUTOS PARA ATENDER PEDIDOS DE ORIGEM                                                       Filial Destino Pedido Destino Item Destino"
					nLin++
					@ nLin,0 PSAY Replicate("-",limite)
					nLin++
					lRisca := .T.
				ENDIF

			Next

			nLin++
			@ nLin,0 PSAY Replicate("-",limite)

		ELSE

			For _nQtdLin :=1 To Len(aChave)
				If nLin > 60
					ImpCab()
					If MV_PAR07 == 1
						// @ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant.    Vlr. Unit.       Total"
						@ 12,0 PSAY "Produto                                                              Acondic.  UM      Quant.    Vlr. Unit.       Total"
					Else
						@ 12,0 PSAY "Codigo           Descricao                                           Acondic.  UM      Quant."
					EndIf
					nLin := 14
				EndIf

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aD2_COD[_nQtdLin],.F.))

				If MV_PAR07 # 1
					@ nLin,000 PSAY Left(aD2_COD[_nQtdLin],If(Empty(SB1->B1_NOME),TamSX3("B1_COD")[1],10)) Picture PesqPict("SB1","B1_COD",TAMSX3("B1_COD")[1])
				EndIf
				//@ nLin,017 PSAY Left(Posicione("SB1",1,xFilial("SB1")+aD2_COD[_nQtdLin],"B1_DESC"),50)


				If SB1->B1_NOME # Left(aD2_COD[_nQtdLin],3) // Não é fios ou cabos
					_cProd := SB1->B1_DESC
					_cBitol:=" "
					_cCor  :=" "
				Else
					_cProd :=Alltrim(Posicione("SZ1",1,xFilial("SZ1")+Left(aD2_COD[_nQtdLin],3),"Z1_APELIDO"))
					_cBitol:=" "+Alltrim(Posicione("SZ2",1,xFilial("SZ2")+Substr(aD2_COD[_nQtdLin],4,2),"Z2_DESC"))
					_cCor  :=" "+Alltrim(Posicione("SZ3",1,xFilial("SZ3")+Substr(aD2_COD[_nQtdLin],6,2),"Z3_DESC"))
					If !Empty(SB1->B1_CLASENC) .And. SB1->B1_ESPECIA # "00" .And. SB1->B1_ESPECIA # "01"  //Especial
						_cCor += " (E)"
					EndIf
				EndIf

				@ nLin,If(MV_PAR07==1,000,017) PSAY Left(_cProd+_cBitol+_cCor,50)
				@ nLin,069 PSAY _aAcondic[_nQtdLin]
				@ nLin,079 PSAY aD2_UM[_nQtdLin]
				@ nLin,083 PSAY aD2_QUANT[_nQtdLin] Picture "@E 999,999.99"

				If MV_PAR07 == 1
					@ nLin,095 PSAY aD2_TOTAL[_nQtdLin] / aD2_QUANT[_nQtdLin] Picture "@E 999,999.9999"
					@ nLin,109 PSAY aD2_TOTAL[_nQtdLin] Picture "@E 999,999.99"
				EndIf
				nLin++
				nTotItens += aD2_TOTAL[_nQtdLin]

				//nPeso += (aD2_QUANT[_nQtdLin] * aPeso[_nQtdLin])  Comentado Edvar
			Next


		ENDIF

		If nLin > 54
			ImpCab()
		EndIf
		nLin := 54

		@ nLin++,0 PSAY Replicate("-",limite)

		@ nLin,004 PSAY "Peso Bruto:"
		@ nLin,016 PSAY _nPesoB Picture "@E 999,999.99"

		@ nLin,032 PSAY "Peso Liquido:"
		@ nLin,046 PSAY _nPesoL Picture "@E 999,999.99"

		@ nLin,060 PSAY "Nro.O.C.C:"
		@ nLin,071 PSAY _cOrdCpa

		@ nLin,078 + If(!Empty(_cOrdCpa),Len(_cOrdCpa) - 6,0) PSAY "Nro Orcamento:"
		@ nLin,Pcol()+1 PSAY _cPedido  // SC6->C6_NUM

		@ nLin,Pcol()+2 PSAY "Total:"
		@ nLin++,Pcol()+1 PSAY nTotItens+nValSubs Picture "@E 999,999.99"

		/*
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
		*/
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
Static Function ValidPerg
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
	aAdd(aRegs,{cPerg,"07","Imprimir                     ?","mv_ch7","N",01,0,0,"C","","mv_par07","Romaneio","","","","","Ordem","","","","","","","","",""})

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
		@ 00,061 PSAY "Ordem de Compra"
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
	// @ 06,0 PSAY _Lin4 // Rafael solicitou não imprimir a linha do representante
	@ 06,0 PSAY _Lin5
	If Empty(_Lin6)
		@ 07,0 PSAY Replicate("-",limite)
	Else
		@ 07,0 PSAY _Lin6
		@ 08,0 PSAY Replicate("-",limite)
	EndIf
Return(If(Empty(_Lin6),8,9))