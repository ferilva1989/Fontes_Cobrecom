#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  10/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR23()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "BMM de Retrabalho"
	Local cPict        := ""
	Local titulo       := "BMM de Retrabalho"
	Local nLin         := 80

	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd         := {}
	Private lEnd       := .F.
	Private lAbortPrint  := .F.
	Private CbTxt      := ""
	Private limite     := 80
	Private tamanho    := "P"
	Private nomeprog   := "CDESTR23"
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDESTR23"
	Private cString := "SZR"

	cPerg := "CDESTR23"

	ValidPerg()
	Pergunte(cPerg, .F.)

	dbSelectArea("SZR")
	dbSetOrder(3) // ZR_FILIAL+ZR_NUMBMM+ZR_NUMBOB+ZR_PEDIDO+ZR_ITEMPV


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
	Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  10/03/10   º±±
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
	Local nOrdem 
	Local nVias := mv_par03
	DbSelectArea("SZE")
	DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB

	DbSelectArea("SZB")
	DbSetOrder(1) // ZB_FILIAL+ZB_NUM

	DbSelectArea("SZR")
	DbSetOrder(3) // ZR_FILIAL+ZR_NUMBMM+ZR_NUMBOB+ZR_PEDIDO+ZR_ITEMPV
	SetRegua(RecCount())

	For nI:= 1 to nVias
		nJ := 0

		DbSeek(xFilial("SZR")+MV_PAR01,.T.)
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBMM <= MV_PAR02 .And. SZR->(!Eof())

			If Empty(SZR->ZR_NUMBMM) .Or. SZR->ZR_NUMBMM == Replicate("@",Len(SZR->ZR_NUMBMM))
				// Reserva não confirmada ou confirmando agora
				SZR->(DbSkip())
				IncRegua()
				Loop
			EndIf

			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			SZB->(DbSeek(xFilial("SZB")+SZR->ZR_NUMBMM,.F.))
			_cBmmAtu := SZR->ZR_NUMBMM
			_cBobAtu := ":::::::::"  
			_lImpTXT := .T.
			Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBMM == _cBmmAtu .And. SZR->(!Eof())

				If lAbortPrint
					@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
					Exit
				Endif

				SZE->(DbSeek(xFilial("SZE")+SZR->ZR_NUMBOB,.F.))

				If (nLin > 55 .And. SZR->ZR_NUMBOB # _cBobAtu) .Or. _lImpTXT

					nJ := 0
					//nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					_lImpTXT := .F.
					nLin := If(nLin > 31,0,33)

					If nI # nVias .Or. nVias == 1
						//É a primeira via ou Não é a Ultima Via -> Imprimir relatório
						@ nLin,026 PSAY "BMM de Retrabalho - Reservas"

						nLin++
						nLin++

						@ nLin,000 PSAY "Nro. do BMM.:"
						@ nLin,015 PSAY SZR->ZR_NUMBMM //No relatório não imprimir o item no cabeçalho -> Imprimir a cada item + SZR->ZR_ITBMM
						@ nLin,029 PSAY "Data de Emissao.:"
						@ nLin,047 PSAY SZB->ZB_DATA
						nLin++
					EndIf
					nLin++                      

				EndIf

				If 	SZR->ZR_NUMBOB # _cBobAtu

					If nI == nVias .And. nVias # 1
						// Não é a Primeira via E é a Ultima via -> Imprimir "tiras"

						nLin++
						@ nLin,000 PSAY "---"
						@ nLin,077 PSAY "---"
						nLin++
						@ nLin,000 PSAY "Nro. do BMM.:"
						@ nLin,015 PSAY SZR->ZR_NUMBMM + "-" + SZR->ZR_ITBMM
						@ nLin,029 PSAY "Data de Emissao.:"
						@ nLin,047 PSAY SZB->ZB_DATA
						nLin++
					EndIf

					@ nLin,000 PSAY "--------------------------------------------------------------------------------"
					nLin++

					If nI # nVias .Or. nVias == 1
						//É a primeira via ou Não é a Ultima Via -> Imprimir relatório

						// Item: 999 Nr.Bob: 9999999 Tp.Bob:  65x25 Qt.Mt: 999,999 Nome: xxxxxxxxxxxxxxxxxx

						@ nLin,000 PSAY "Item:"
						@ nLin,006 PSAY SZR->ZR_ITBMM
						@ nLin,010 PSAY "Nr.Bob:"
						@ nLin,019 PSAY SZR->ZR_NUMBOB
						@ nLin,026 PSAY "Tp.Bob:"
						@ nLin,034 PSAY Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(SZE->ZE_TPBOB)*7)-6)-1,6)
						@ nLin,041 PSAY "Qt.Mt:"
						@ nLin,048 PSAY SZE->ZE_QUANT  Picture "@E 999,999"
						@ nLin,056 PSAY "Nome:"
						@ nLin,061 PSAY Left(SZE->ZE_NOMCLI,18)


					Else

						// Nro.Bob.: 9999999 Tp.Bob.:  65x25 Qt.Mt.: 999,999 Nome Ant.: xxxxxxxxxxxxxxxxxxx

						@ nLin,000 PSAY "Nro.Bob.:"
						@ nLin,010 PSAY SZR->ZR_NUMBOB
						@ nLin,018 PSAY "Tp.Bob.:"
						@ nLin,027 PSAY Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(SZE->ZE_TPBOB)*7)-6)-1,6)
						@ nLin,034 PSAY "Qt.Mt.:"
						@ nLin,042 PSAY SZE->ZE_QUANT  Picture "@E 999,999"
						@ nLin,050 PSAY "Nome Ant.:"
						@ nLin,061 PSAY Left(SZE->ZE_NOMCLI,19)
					EndIf
					nLin++

					@ nLin,000 PSAY "Produto....:"
					@ nLin,013 PSAY SZR->ZR_PRODUTO
					@ nLin,029 PSAY "Descricao..:"
					@ nLin,042 PSAY Left(SZR->ZR_DESCR,38)
					nLin++

					If nI # nVias .And. nVias # 1
						@ nLin,000 PSAY "Cliente....:"
						@ nLin,013 PSAY SZR->ZR_CODCLI
						@ nLin,020 PSAY "Lj.:"
						@ nLin,025 PSAY SZR->ZR_LOJA
						@ nLin,029 PSAY "Nome.......:"
						@ nLin,042 PSAY Left(SZR->ZR_NOMCLI,38)
						nLin++
						nLin++
					EndIf
					@ nLin,000 PSAY "Pedido It Qtd.Lc.  Acond.  Qtd.Total  Fitilho Bobina Observacao"
					nLin++

					@ nLin,000 PSAY "--------------------------------------------------------------------------------"
					nLin++
					_cBobAtu := SZR->ZR_NUMBOB
				Endif

				cFitilho := Posicione("SA1",1,xFilial("SA1")+SZR->ZR_CODCLI+SZR->ZR_LOJA,"A1_FITILHO")
				cFitilho := IIf(cFitilho=="S","SIM","NÃO")

				_aArea   := GetArea()
				
				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+SZR->ZR_PEDIDO,.F.))
				If SC5->C5_EMISSAO <= Ctod("06/05/2017") // Pedidos incluidos até dia 6 tem que calcular da forma antiga
					cTipoBob := Alltrim( u_CalcBob(SZR->ZR_PRODUTO,SZR->ZR_METRAGE)[1]) //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				Else
					cTipoBob := Alltrim( u_CalcBob(SZR->ZR_PRODUTO,SZR->ZR_METRAGE,,SZR->ZR_CODCLI,SZR->ZR_LOJA)[1]) //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				EndIf
				
				RestArea(_aArea)

				@ nLin,000 PSAY SZR->ZR_PEDIDO
				@ nLin,007 PSAY SZR->ZR_ITEMPV
				@ nLin,010 PSAY SZR->ZR_LANCES Picture "@E 999,999"
				@ nLin,019 PSAY SZR->ZR_ACONDIC+StrZero(SZR->ZR_METRAGE,5)
				@ nLin,026 PSAY SZR->ZR_QTDPV Picture "@E 999,999"
				@ nLin,038 PSAY cFitilho
				@ nLin,047 PSAY cTipoBob			
				@ nLin,054 PSAY Left(SZR->ZR_OBS,24)
				nLin++                              

				SZR->(DbSkip())	

				If nI == nVias .And. nVias # 1 .And. SZR->ZR_NUMBOB # _cBobAtu
					nJ++
					nLin := 16*nJ
				EndIf
			EndDo
			@ If(nLin < 31,31,64),000 PSAY "--------------------------------------------------------------------------------"
		EndDo
	Next	
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
	aAdd(aRegs,{cPerg,"01","Do BMM Numero                ?","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o BMM Numero             ?","mv_ch2","C",6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Nro.de Vias                  ?","mv_ch3","N",2,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})

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
/*

Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBMM <= MV_PAR02 .And. SZR->(!Eof())

If Empty(SZR->ZR_NUMBMM)                    
SZR->(DbSkip())
IncRegua()
Loop
EndIf

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif
SZB->(DbSeek(xFilial("SZB")+SZR->ZR_NUMBMM,.F.))
_cBmmAtu := SZR->ZR_NUMBMM
_cBobAtu := ":::::::::"  
_lImpTXT := .T.
Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBMM == _cBmmAtu .And. SZR->(!Eof())

If lAbortPrint
@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
Exit
Endif

SZE->(DbSeek(xFilial("SZE")+SZR->ZR_NUMBOB,.F.))

If nLin > 55 .Or. _lImpTXT

//nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
_lImpTXT := .F.
nLin := If(nLin > 31,0,33)

@ nLin,026 PSAY "BMM de Retrabalho - Reservas"

nLin++
nLin++

@ nLin,000 PSAY "Nro. do BMM.:"
@ nLin,015 PSAY SZR->ZR_NUMBMM + "-" + SZR->ZR_ITBMM
@ nLin,029 PSAY "Data de Emissao.:"
@ nLin,047 PSAY SZB->ZB_DATA
nLin++
nLin++

@ nLin,000 PSAY "Nro.Bob.:"
@ nLin,010 PSAY SZR->ZR_NUMBOB
@ nLin,018 PSAY "Tp.Bob.:"
@ nLin,027 PSAY Substr(" 65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(SZE->ZE_TPBOB)*7)-6)-1,6)
@ nLin,034 PSAY "Qt.Mt.:"
@ nLin,042 PSAY SZE->ZE_QUANT  Picture "@E 999,999"
@ nLin,050 PSAY "Nome Ant.:"
@ nLin,061 PSAY Left(SZE->ZE_NOMCLI,19)

nLin++

@ nLin,000 PSAY "Produto....:"
@ nLin,013 PSAY SZR->ZR_PRODUTO
@ nLin,029 PSAY "Descricao..:"
@ nLin,042 PSAY Left(SZR->ZR_DESCR,38)
nLin++

@ nLin,000 PSAY "Cliente....:"
@ nLin,013 PSAY SZR->ZR_CODCLI
@ nLin,020 PSAY "Lj.:"
@ nLin,025 PSAY SZR->ZR_LOJA
@ nLin,029 PSAY "Nome.......:"
@ nLin,042 PSAY Left(SZR->ZR_NOMCLI,38)
nLin++
nLin++
@ nLin,000 PSAY "Pedido It Qtd.Lc.  Acond.  Qtd.Total  Observacao"
nLin++
@ nLin,000 PSAY "--------------------------------------------------------------------------------"
nLin++
_cBobAtu := SZR->ZR_NUMBOB

ElseIf 	SZR->ZR_NUMBOB # _cBobAtu
@ nLin,000 PSAY "--------------------------------------------------------------------------------"
nLin++

@ nLin,000 PSAY "Nro.Bob.:"
@ nLin,010 PSAY SZR->ZR_NUMBOB
@ nLin,018 PSAY "Tp.Bob.:"
@ nLin,027 PSAY Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(SZE->ZE_TPBOB)*7)-6)-1,6)
@ nLin,034 PSAY "Qt.Mt.:"
@ nLin,042 PSAY SZE->ZE_QUANT  Picture "@E 999,999"
@ nLin,050 PSAY "Nome Ant.:"
@ nLin,061 PSAY Left(SZE->ZE_NOMCLI,19)

nLin++

@ nLin,000 PSAY "Produto....:"
@ nLin,013 PSAY SZR->ZR_PRODUTO
@ nLin,029 PSAY "Descricao..:"
@ nLin,042 PSAY Left(SZR->ZR_DESCR,38)
nLin++

@ nLin,000 PSAY "Cliente....:"
@ nLin,013 PSAY SZR->ZR_CODCLI
@ nLin,020 PSAY "Lj.:"
@ nLin,025 PSAY SZR->ZR_LOJA
@ nLin,029 PSAY "Nome.......:"
@ nLin,042 PSAY Left(SZR->ZR_NOMCLI,38)
nLin++
nLin++
@ nLin,000 PSAY "Pedido It Qtd.Lc.  Acond.  Qtd.Total  Observacao"
nLin++
@ nLin,000 PSAY "--------------------------------------------------------------------------------"
nLin++
_cBobAtu := SZR->ZR_NUMBOB
Endif

@ nLin,000 PSAY SZR->ZR_PEDIDO
@ nLin,007 PSAY SZR->ZR_ITEMPV
@ nLin,010 PSAY SZR->ZR_LANCES Picture "@E 999,999"
@ nLin,019 PSAY SZR->ZR_ACONDIC+StrZero(SZR->ZR_METRAGE,5)
@ nLin,026 PSAY SZR->ZR_QTDPV Picture "@E 999,999"
@ nLin,038 PSAY Left(SZR->ZR_OBS,40)
nLin++
SZR->(DbSkip())
EndDo
@ If(nLin < 31,31,64),000 PSAY "--------------------------------------------------------------------------------"
EndDo
*/