#include "rwmake.ch"
#include 'protheus.ch'

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDESTR03                           Modulo : SIGAEST      //
//                                                                          //
//                                                    Data ..: 07/04/2006   //
//                                                                          //
//   Objetivo ...: Relatório do Resumo da Programação da Produção           //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDESTR03()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2         := "de acordo com os parâmetros informados pelo usuário."
	Local cDesc3         := ""
	Local cPict          := ""

	Private Titulo       := "Resumo de Producao"
	Private Cabec1       := ""
	Private Cabec2       := ""
	Private imprime      := .T.
	Private aOrd         := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "G"
	Private nomeprog     := "CDESTR03"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDES03"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR03"
	Private cString      := "SZ9"
	nLin         := 80

	ValidPerg()
	pergunte(cPerg,.F.)

	DbSelectArea("SZ9")
	DbSetOrder(1)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	Titulo := "Resumo Producao-Semana " + Subst(MV_PAR01,5,2) +"/"+Left(MV_PAR01,4)+"-"+Right(MV_PAR01,1)
	nTipo := 18 //If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return(.T.)

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////

	/*/


	It Produto        Descrição do Produto                                                  Met.Tot."
	Pedido Cliente                     Acondic.(m)  Baixa  Bobina"
	------------------------------------------------------------------------------------------------
	99 XXX.XX.XX.X.XX xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                  99,999,999"
	999999  xxxxxxxxxxxxxxxxxxxx ???/??  999999 R x99,999 __/__
	999999 R x99,999 __/__
	999999  xxxxxxxxxxxxxxxxxxxx ???/??  999999 R x99,999 __/__
	2       3                    5       999999 R x99,999 __/__
	8       6                    7       6      7 77      8
	5      2 45      3
	/*/

	nLin := 80
	DbSelectArea("SA1")
	DbSetOrder(1) // A1_FILIAL+A1_CODIGO

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_CODIGO

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSelectArea("SC5")
	DbSetOrder(1) // C5_FILIAL+C5_NUM

	DbSelectArea("SZ9")
	DbSetOrder(3) // Z9_FILIAL+Z9_SEMANA+Z9_CODINV+Z9_LOCALIZ
	DbSeek(xFilial("SZ9")+MV_PAR01,.F.)

	_cLoop1 := 'SZ9->Z9_FILIAL ==  xFilial("SZ9") .And. SZ9->Z9_SEMANA == MV_PAR01 .And. SZ9->(!Eof())'
	_cChv1  := 'SZ9->Z9_SEMANA+Left(SZ9->Z9_CODINV,8) '
	_cLoop2 := 'SZ9->Z9_FILIAL+SZ9->Z9_SEMANA+Left(SZ9->Z9_CODINV,8) == xFilial("SZ9")+_cChvZ9 .And. SZ9->(!Eof())'
	_cChv2  := 'SZ9->Z9_SEMANA+SZ9->Z9_CODINV'
	_cLoop3 := 'SZ9->Z9_FILIAL+SZ9->Z9_SEMANA+SZ9->Z9_CODINV == xFilial("SZ9")+_cChvZ9_2 .And. SZ9->(!Eof())'

	nLin := u_ImpCorpo(1,MV_PAR02,nLin)

	If nLin # 80
		Eject
	EndIf
	///@ 0,0 Psay Chr(27) + "@"

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return(.T.)

	***********************
Static Function MyCab()
	***********************
	*
	//nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	//nLin++
	//@ nLin++,00 PSay "Numero It Seq Produto    Descrição do Produto                           Met.Tot."
	//@ nLin++,18 PSay "Pedido  Cliente                    Acondic.(m)   Baixa  Bobina"
	//@ nLin++,00 PSay Replicate("-",80)

	///@ PRow(),0 PSay Chr(27) + "P" // 10CPP
	nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	///@ nLin,0 PSay Chr(27) + "M" // 12CPP
	nLin++
	@ nLin++,00 PSay "It Produto        Descricao do Produto                                                 Mtr.Total"
	//@ nLin++,18 PSay "Pedido Item  Cliente                    Bobina Qt.Lan Acond.(mt)      "
	@ nLin++,10 PSay "Pedido It Dt.Entrega Cliente                    Bobina Qt.Lan Acond.(mt)      "
	@ nLin++,00 PSay Replicate("-",96)
Return(nLin)

/////////////////////////
Static Function ValidPerg()
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Semana Produção AAAA/SS-I      ?","mv_ch1","C",07,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Imprimir                       ?","mv_ch2","N",01,0,0,"C","","mv_par02","Tudo","","","Não Programados","","","Programados","","","","","","","",""})

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

	*
	*****************************
User Function ImpCorpo(_nRot,_nTudo,nlin)
	*****************************
	*

	// Conteudo das variáveis
	//_cLoop1 := 'SZ9->Z9_FILIAL ==  xFilial("SZ9") .And. SZ9->Z9_SEMANA == MV_PAR01 .And. SZ9->(!Eof())'
	//_cChv1  := 'SZ9->Z9_SEMANA+Left(SZ9->Z9_CODINV,8) '
	//_cLoop2 := 'SZ9->Z9_FILIAL+SZ9->Z9_SEMANA+Left(SZ9->Z9_CODINV,8) == xFilial("SZ9")+_cChvZ9 .And. SZ9->(!Eof())'
	//_cChv2  := 'SZ9->Z9_SEMANA+SZ9->Z9_CODINV'
	//_cLoop3 := 'SZ9->Z9_FILIAL+SZ9->Z9_SEMANA+SZ9->Z9_CODINV == xFilial("SZ9")+_cChvZ9_2 .And. SZ9->(!Eof())'
	// ou
	//_cLoop1 := 'SZ9->Z9_FILIAL ==  xFilial("SZ9") .And. SZ9->Z9_PROGR == _cProgr .And. SZ9->(!Eof())'
	//_cChv1 := 'SZ9->Z9_PROGR+Left(SZ9->Z9_CODINV,8) '
	//_cLoop2 := 'SZ9->Z9_FILIAL+SZ9->Z9_PROGR+Left(SZ9->Z9_CODINV,8) == xFilial("SZ9")+_cChvZ9 .And. SZ9->(!Eof())'
	//_cChv2 := 'SZ9->Z9_PROGR+SZ9->Z9_CODINV'
	//_cLoop3 := 'SZ9->Z9_FILIAL+SZ9->Z9_PROGR+SZ9->Z9_CODINV == xFilial("SZ9")+_cChvZ9_2 .And. SZ9->(!Eof())'
	//OU
	//_cLoop1 := ;
	//_cLoop2 := ;
	//_cLoop3 := 'SZ9->Z9_FILIAL ==  xFilial("SZ9") .And. SZ9->Z9_PROGR == _cProgr .And. SZ9->Z9_PRODUTO ==  _cProd .And. SZ9->(!Eof())'
	//_cChv1 := ;
	//_cChv2 := '.T.'

	_aAreaC6 := SC6->(GetArea())
	SC6->(DbSetOrder(1))

	_aEmpenhos := {} // Produto/Descricao/Quantidade

	If _nRot # 1 //
		///	@ nLin,0 PSay Chr(27) + "M" // 12CPP
		@ nLin,0 PSay " "
	EndIf


	Do While &_cLoop1.
		//_cLoop1 := 'SZ9->Z9_FILIAL ==  xFilial("SZ9") .And. SZ9->Z9_PROGR == _cProgr .And. SZ9->(!Eof())'
		If _nRot # 1 .And. _nRot # 3
			If 	Left(SZ9->Z9_CODINV,8) # Left(_cMateri,8)  // TRB->MATERI é o produto sem a distinção de cor
				SZ9->(DbSkip())
				Loop
			EndIf
		EndIf
		If Empty(SZ9->Z9_SEMANA) // Não imprime dados da montagem do RG das bobinas
			If _nRot == 3 // Impressão das OPs
				If Left(_cCarProd,1) == "Q" .And. !Empty(SZ9->Z9_DISTCAR)
					MonteCarga()
				EndIf
			EndIf
			SZ9->(DbSkip())
			Loop
		EndIf

		_cChvZ9 := &_cChv1.
		//_cChv1 := 'SZ9->Z9_PROGR+Left(SZ9->Z9_CODINV,8) '
		_nTotChv := 0.00
		_TemMais := .T.
		Do While &_cLoop2.
			//_cLoop2 := 'SZ9->Z9_FILIAL+SZ9->Z9_PROGR+Left(SZ9->Z9_CODINV,8) == xFilial("SZ9")+_cChvZ9 .And.
			//            SZ9->(!Eof())'
			If (_nTudo == 2  .And. !Empty(SZ9->Z9_PROGR)) .Or.;
			(_nTudo == 3  .And.  Empty(SZ9->Z9_PROGR))
				SZ9->(DbSkip())
				Loop
			EndIf

			If Empty(SZ9->Z9_SEMANA) // Não imprime dados da montagem do RG das bobinas
				If _nRot == 3 // Impressão das OPs
					If Left(_cCarProd,1) == "Q" .And. !Empty(SZ9->Z9_DISTCAR)
						MonteCarga()
					EndIf
				EndIf
				SZ9->(DbSkip())
				Loop
			ElseIf SZ9->Z9_NUM == "000000"
				SZ9->(DbSkip())
				Loop
			EndIf

			If SC2->(DbSeek(xFilial("SC2")+SZ9->Z9_NUM+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN,.F.))
				CalcEmp()
			EndIf

			If ++nLin > If(_nRot # 3,60,29)
				If _nRot == 1
					nLin := MyCab()
				Else
					///				@ PRow(),0 PSay Chr(27) + "P" // 10CPP
					nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					///				@ nLin++,0 PSay Chr(27) + "M" // 12CPP
				EndIf
			Endif
			SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO,.F.))

			If _nRot == 1
				_cLinOP := (SC2->C2_ITEM+" "+Transform(SC2->C2_PRODUTO,"@R XXX.XX.XX.X.XX")+" "+AllTrim(SC2->C2_DESCRI))
			Else
				_cLinOP := (SC2->C2_NUM + "-" + SC2->C2_ITEM+" "+Transform(SC2->C2_PRODUTO,"@R XXX.XX.XX.X.XX")+" "+AllTrim(SC2->C2_DESCRI))
			EndIf
			_TemMais := (Len(_cLinOP) > 85)
			@ nLin,00 PSay _cLinOP
			cPontos := (86-Len(_cLinOP))
			If _TemMais
				@ nLin,86 PSay SC2->C2_QUANT Picture "@E 99,999,999"
			EndIf

			_cChvZ9_2 := &_cChv2.
			//_cChv2 := 'SZ9->Z9_PROGR+SZ9->Z9_CODINV'
			_nTotChv  += SC2->C2_QUANT
			_nRolos := 0
			_aAcond := {}
			_cOpAtu := SZ9->Z9_NUM+SZ9->Z9_ITEM

			Do While &_cLoop3.
				//_cLoop3 := 'SZ9->Z9_FILIAL+SZ9->Z9_PROGR+SZ9->Z9_CODINV == xFilial("SZ9")+_cChvZ9_2 .And.
				//            SZ9->(!Eof())'

				If !Empty(SZ9->Z9_SEMANA) // Não imprime dados da montagem do RG das bobinas
					_TpBob := "      "
					If SZ9->Z9_ACONDIC == "R" .And. SZ9->Z9_METRAGE == 100
						_nRolos += SZ9->Z9_LANCES // aqui
					Else
						If !_TemMais
							@ nLin,Len(_cLinOP) PSay Replicate(".",cPontos+(10-Len(AllTrim(Transform(SC2->C2_QUANT,"@E 99,999,999")))))+;
							AllTrim(Transform(SC2->C2_QUANT,"@E 99,999,999"))
							_TemMais := .T.
						EndIf
						If SZ9->Z9_ACONDIC # "B"
							_cPos := 0
							For _nCtd := 1 to Len(_aAcond)
								If _aAcond[_nCtd,1] == SZ9->Z9_ACONDIC .And. _aAcond[_nCtd,2] == SZ9->Z9_METRAGE
									_cPos := _nCtd
									Exit
								EndIf
							Next
							If _cPos == 0
								AADD(_aAcond,{SZ9->Z9_ACONDIC,SZ9->Z9_METRAGE,SZ9->Z9_LANCES})
							Else
								_aAcond[_nCtd,3] += SZ9->Z9_LANCES
							EndIf
							If SZ9->Z9_ACONDIC $ "MC"
								_cAcon := Left(SZ9->Z9_ACONDIC + Space(30),Len(SB1->B1_COD))
								_nPosi  := aScan(_aEmpenhos, {|x|x[1]==_cAcon})
								If _nPosi == 0
									AADD(_aEmpenhos,{_cAcon,If(SZ9->Z9_ACONDIC=="M","Carretel de Madeira","Carretel N8"),0.00})
									_nPosi := Len(_aEmpenhos)
								EndIf
								_aEmpenhos[_nPosi,3] += SZ9->Z9_LANCES
							EndIf
						Else
							SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
							SC6->(DbSeek(xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.))
							SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
							If ++nLin > If(_nRot # 3,60,29)
								If _nRot == 1
									nLin := MyCab()
								Else
									///								@ PRow(),0 PSay Chr(27) + "P" // 10CPP
									nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
									///								@ nLin++,0 PSay Chr(27) + "M" // 12CPP
								EndIf
							Endif
							_TpBob := "      "
							If SZ9->Z9_ACONDIC == "B"
								If SC5->C5_EMISSAO <= Ctod("06/05/2017")
									_TpBob  := u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE)[1] //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
								Else
									_TpBob  := u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE,,SC5->C5_CLIENTE,SC5->C5_LOJACLI)[1] //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
								EndIf
								If Val(_TpBob) < 100 // Para que a bobina 65/25 seja listada antes da 100/60
									_TpBob := " " + _TpBob
								EndIf
								_cTpBob := 	Left(_TpBob+Space(30),Len(SB1->B1_COD))
								_nPosi  := aScan(_aEmpenhos, {|x|x[1]==_cTpBob})
								If _nPosi == 0
									AADD(_aEmpenhos,{_cTpBob,"Bobina de Madeira",0.00})
									_nPosi := Len(_aEmpenhos)
								EndIf
								_aEmpenhos[_nPosi,3] += SZ9->Z9_LANCES
							EndIf
							@ nLin,10 PSay SZ9->Z9_PEDIDO
							@ nLin,17 PSay SZ9->Z9_ITEMPV
							@ nLin,20 PSay SC6->C6_ENTREG
							@ nLin,31 PSay Left(SA1->A1_NOME,20)
							@ nLin,58 PSay _TpBob
							@ nLin,70 PSay SZ9->Z9_LANCES PICTURE "999999"
							@ nLin,77 PSay SZ9->Z9_ACONDIC + " x"
							@ nLin,80 PSay SZ9->Z9_METRAGE PICTURE "@E 99,999"
							//		@ nLin,83 PSay "__/__"
						EndIf
					EndIf
				EndIf
				If _nRot == 3 // Impressão das OPs
					If Left(_cCarProd,1) == "Q" .And. !Empty(SZ9->Z9_DISTCAR)
						MonteCarga()
					EndIf
				EndIf
				SZ9->(DbSkip())
			EndDo
			For _nCtd := 1 to Len(_aAcond)
				If ++nLin > If(_nRot # 3,60,29)
					If _nRot == 1
						nLin := MyCab()
					Else
						///					@ PRow(),0 PSay Chr(27) + "P" // 10CPP
						nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						@ nLin++,0 PSay Chr(27) + "M" // 12CPP
					EndIf
				Endif
				@ nLin,70 PSay _aAcond[_nCtd,3] PICTURE "999999" // Quantidade de Lances
				@ nLin,77 PSay _aAcond[_nCtd,1] + " x" // Acondicionamento
				@ nLin,80 PSay _aAcond[_nCtd,2] PICTURE "@E 99,999" // Metragem
			Next
			If _nRolos > 0
				If  !_TemMais
					@ nLin,Len(_cLinOP) PSay Replicate(".",(70-Len(_cLinOP))+(6-Len(AllTrim(Transform(_nRolos,"999999")))))+;
					AllTrim(Transform(_nRolos,"999999"))
					@ nLin,77 PSay "R x"
					@ nLin,80 PSay 100 PICTURE "@E 99,999"
					//				@ nLin,83 PSay "__/__"
					@ nLin,88 PSay SC2->C2_QUANT Picture "@E  9999,999"
				Else
					nLin++
					@ nLin,70 PSay _nRolos PICTURE "999999"
					@ nLin,77 PSay "R x"
					@ nLin,80 PSay 100 PICTURE "@E 99,999"
					//				@ nLin,83 PSay "__/__"
				EndIf
			EndIf
		EndDo

		If _nTotChv # 0.00
			nLin++
			@ nLin,85 PSay Transform(_nTotChv,"@E 999,999,999")
			///		@ nLin,85 PSay Chr(27)+"E"+Transform(_nTotChv,"@E 999,999,999")+CHR(27)+"F"
			///		@ nLin,0 PSay Chr(27) + "M"
			nLin++
			@ nLin,00 PSay Replicate("-",96)
		EndIf
	EndDo


	If Len(_aEmpenhos) > 0  .And. _nRot == 1

		Asort(_aEmpenhos,,,{|X,Y| X[1]<Y[1]})

		nLin := 85
		For _nEmp := 1 to Len(_aEmpenhos)
			If ++nLin > If(_nRot # 3,60,29)
				////			@ PRow(),0 PSay Chr(27) + "P" // 10CPP
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				///			@ nLin++,0 PSay Chr(27) + "M" // 12CPP
				nLin++
				@ nLin++,00 PSay "   EMPENHO DE MATERIAS-PRIMA / BOBINAS DE MADEIRA"
				nLin++
				@ nLin++,00 PSay "   Produto           Descricao do Produto                                          Quantidade"
				nLin++
			Endif
			@ nLin  ,03 PSay _aEmpenhos[_nEmp,1]
			@ nLin  ,21 PSay _aEmpenhos[_nEmp,2]
			@ nLin++,83 PSay _aEmpenhos[_nEmp,3] Picture "@E 999,999.99"
		Next
	EndIf
	RestArea(_aAreaC6)
	//@ nLin,0 PSay Chr(27) + "P" // aqui saiu com lin = 31
	///@ PRow(),0 PSay Chr(27) + "P" // aqui saiu com lin = 31
	Return(nLin)
*
******************************************************************
User Function CalcBob(_cProdB,_nMetrB, lTpRet, _cCodCli, _cLojCli)
******************************************************************
*
/*/
	Função para calcular qual bobina deve ser usada para a metragem 
/*/
Local _aFatPad, _aFatCli, _lForma
DEFAULT lTpRet   := .F.
DEFAULT _cCodCli := Left(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]))
DEFAULT _cLojCli := Substring(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1])

_cPdCodCli := Left(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]))
_cPdLojCli := Substring(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1])

If Empty(_cCodCli) .Or. Empty(_cLojCli)
	_cCodCli := _cPdCodCli
	_cLojCli := _cPdLojCli
EndIf

// Calculo do Fator

// Redondo  -> B1_DIAMETR > 0
//			-> (Diametro)^2              * Metragem

// Torcido  -> (B1_EIXOME * 2) == B1_EIXOMA
//			-> Raiz(((E+)^2  - (E-)^2))  * Metragem * 0.95


// Chato    -> ((E+ + E-)/2)^2           * Metragem * 0.95

// Cálculo do Raio Mínimo de Curvatura
// Diâmetro * Fator do Raio

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+AllTrim(_cProdB),.F.))
_cProdB := SB1->B1_COD // Estou reassumindo o código porque o portal manda somente os 5 primeiros dígitos do código do produto (produto + bitola)

_TpBob := {"","",.F.}
_lFataInfo := If(!Empty(SB1->B1_DIAMETR),.F.,If((SB1->B1_EIXOME>0.And.SB1->B1_EIXOMA>0),.F.,.T.))
// Esta Variável indica que não tem informações suficientes para cálculo da bobina

If !Empty(SB1->B1_DIAMETR)
	// Redondo  -> B1_DIAMETR > 0
	//			-> (Diametro)^2              * Metragem
	_nFator1 := ((SB1->B1_DIAMETR ** 2)) * _nMetrB
	_nFator2 := SB1->B1_DIAMETR * SB1->B1_RAIO
ElseIf ((SB1->B1_EIXOME * 2) == SB1->B1_EIXOMA)
	// Torcido  -> (B1_EIXOME * 2) == B1_EIXOMA
	//			-> Raiz(((E+)^2  - (E-)^2))  * Metragem * 0.95
	_nFator1 := ((SB1->B1_EIXOME ** 2) - (SB1->B1_EIXOMA ** 2))
	_nFator1 := Sqrt(_nFator1)
	_nFator1 := _nFator1 * _nMetrB * 0.95
	_nFator2 := 0
Else // Suponho que é do tipo Chato
	// Chato    -> ((E+ + E-)/2)^2           * Metragem * 0.95
	_nFator1 := (SB1->B1_EIXOMA+SB1->B1_EIXOME)/2
	_nFator1 := (_nFator1 ** 2)
	_nFator1 := _nFator1 * _nMetrB * 0.95
	_nFator2 := 0
EndIf

// eMail do Mauro (CQ) solicitando considerar o peso do produto na bobina.
// ZA_PESO - Peso Suportado
_nPesoPrd := (_nMetrB * SB1->B1_PESBRU)

// Alteração efetuada em 04/05/17 para atender o campo CLIENTE/LOJA NA TABELA SZA
DbSelectArea("SZA")
DbSetOrder(2) //ZA_FILIAL+STRZERO(ZA_FATOR,8,0)

_aFatCli := {}
_lForma := .F. // Calculo da forma antiga

//	por enquanto não fazer da forma nova até eu testar com dados da Andra
If (_cPdCodCli+_cPdLojCli) # (_cCodCli+_cLojCli) // Cliente não é o padrão
	cQuery := "SELECT ZA_CODIGO,ZA_TIPO,ZA_DIALAT,ZA_DIACUB,ZA_LARGINT,ZA_PESO,ZA_FATOR,ZA_PRODUTO, ZA_CLIENTE,ZA_LOJA"
	cQuery += " FROM "+RetSqlName("SZA") + " SZA"
	cQuery += " WHERE ZA_FILIAL  = '"+xFilial("SZA")+"'"
	cQuery += " AND ZA_CLIENTE = '" + _cCodCli + "'"
	cQuery += " AND ZA_LOJA = '" + _cLojCli + "'"
	cQuery += " AND D_E_L_E_T_ = ''"
	_aFatCli := u_QryArr(cQuery)
	_lForma := (Len(_aFatCli) > 0) // Calculo da forma nova
EndIf


If _lForma
	// Monto array que contenham as informações válidas para o cliente,
	// usando o registro próprio do cliente ou o registro do cliente padrão.
	
	_aFatPad := {}
	
	// Selecionar os dados do cliente padrão
	cQuery := "SELECT ZA_CODIGO,ZA_TIPO,ZA_DIALAT,ZA_DIACUB,ZA_LARGINT,ZA_PESO,ZA_FATOR,ZA_PRODUTO, ZA_CLIENTE,ZA_LOJA"
	cQuery += " FROM "+RetSqlName("SZA") + " SZA"
	cQuery += " WHERE ZA_FILIAL  = '"+xFilial("SZA")+"'"
	cQuery += " AND ZA_CLIENTE = '" + _cPdCodCli + "'"
	cQuery += " AND ZA_LOJA = '" + _cPdLojCli + "'"
	cQuery += " AND D_E_L_E_T_ = ''"
	_aFatPad := u_QryArr(cQuery)
	
	// Transfere os dados que não tem no _aFatCli do _aFatPad
	// _aFatCli e _aFatPad {1-ZA_CODIGO, 2-ZA_TIPO, 3-ZA_DIALAT, 4-ZA_DIACUB, 5-ZA_LARGINT, 6-ZA_PESO, 7-ZA_FATOR, 8-ZA_PRODUTO, 9-ZA_CLIENTE, 10-ZA_LOJA}
	
	For _nFat := 1 to Len(_aFatPad)
		If aScan(_aFatCli, {|x|x[1]==_aFatPad[_nFat,1]}) == 0 // Não tem no _aFatCli -> adicionar
			AADD(_aFatCli,Array(Len(_aFatPad[_nFat])))
			For _nFat1 := 1 to Len(_aFatPad[_nFat])
				_aFatCli[Len(_aFatCli),_nFat1] := _aFatPad[_nFat,_nFat1]
			Next
		EndIf
	Next
	
	// Ordena por Fator
	aSort(_aFatCli,,,{|X,Y| X[7]<Y[7]})
	For _nFat := 1 to Len(_aFatCli)
		If (_aFatCli[_nFat,7] < _nFator1 .Or. _aFatCli[_nFat,4] < _nFator2 .Or. _aFatCli[_nFat,6] < _nPesoPrd)
			Loop
		Else
			Exit
		EndIf
	Next //{1-ZA_CODIGO, 2-ZA_TIPO, 3-ZA_DIALAT, 4-ZA_DIACUB, 5-ZA_LARGINT, 6-ZA_PESO, 7-ZA_FATOR, 8-ZA_PRODUTO, 9-ZA_CLIENTE, 10-ZA_LOJA}
	If _nFat > Len(_aFatCli)
		_TpBob := {"???/??",Space(Len(SZA->ZA_PRODUTO)),_lFataInfo}
	ElseIf _aFatCli[_nFat,7] >= _nFator1 .And. _aFatCli[_nFat,4] >= _nFator2 .And. _aFatCli[_nFat,6] >= _nPesoPrd
		_TpBob := {_aFatCli[_nFat,2],_aFatCli[_nFat,8],_lFataInfo}
	Else
		_TpBob := {"???/??",Space(Len(SZA->ZA_PRODUTO)),_lFataInfo}
	EndIf
Else
	DbSelectArea("SZA")
	DbSetOrder(2) //ZA_FILIAL+STRZERO(ZA_FATOR,8,0)
	Set Filter to ZA_CLIENTE == _cPdCodCli
	DbSeek(xFilial("SZA")+STRZERO(_nFator1,8,0),.T.)
	If Eof()
		_TpBob := {"???/??",Space(Len(SZA->ZA_PRODUTO)),_lFataInfo}
	Else
		//Do While (SZA->ZA_FATOR < _nFator1 .Or. SZA->ZA_DIACUB < _nFator2) .And. SZA->(!Eof())
		// Solicitação do Mauro para considerar peso suportado pela bobina
		Do While (SZA->ZA_FATOR < _nFator1 .Or. SZA->ZA_DIACUB < _nFator2 .Or. SZA->ZA_PESO < _nPesoPrd) .And. SZA->(!Eof())
			SZA->(DbSkip())
		EndDo
		// If SZA->ZA_FATOR >= _nFator1 .And. SZA->ZA_DIACUB >= _nFator2 .And. SZA->(!Eof())
		If SZA->ZA_FATOR >= _nFator1 .And. SZA->ZA_DIACUB >= _nFator2 .And. SZA->ZA_PESO >= _nPesoPrd .And. SZA->(!Eof())
			_TpBob := {SZA->ZA_TIPO,SZA->ZA_PRODUTO,_lFataInfo}
		Else
			_TpBob := {"???/??",Space(Len(SZA->ZA_PRODUTO)),_lFataInfo}
		EndIf
	EndIf
	Set Filter to
EndIf

if lTpRet
	If Alltrim(_TpBob[1]) = "65/25"
		_TpBob[1] := "1"
	ElseIf Alltrim(_TpBob[1]) = "65/45"
		_TpBob[1] := "2"
	ElseIf Alltrim(_TpBob[1]) = "80/45"
		_TpBob[1] := "3"
	ElseIf Alltrim(_TpBob[1]) = "100/60"
		_TpBob[1] := "4"
	ElseIf Alltrim(_TpBob[1]) = "125/70"
		_TpBob[1] := "5"
	ElseIf Alltrim(_TpBob[1]) = "150/80"
		_TpBob[1] := "6"
	ElseIf Alltrim(_TpBob[1]) = "170/80"
		_TpBob[1] := "7"
	ElseIf Alltrim(_TpBob[1]) = "???/??"
		_TpBob[1] := ""
	EndIf
endif
Return(_TpBob)
*
*
*************************
Static Function CalcEmp()
*************************
*
// A partir de 26/10/10 os empenhos serão calculados pela estrutura do produto
// e não pais pelo SD4.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	A função ESTRUT2 é utilizada para realizar a explosão de uma estrutura cadastrada no SG1      ³
//³	é necessária a criação de uma variável PRIVATE nEstru com valor 0 antes da chamada da função  ³
//³	Antes de finalizar o programa, deve-se executar a função FIMESTRUT2 para apagar os arquivos.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE nEstru := 0

DbSelectArea("SG1")
DbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

_cNomeArq := u_cbcStrut2(SC2->C2_PRODUTO,SC2->C2_QUANT,"ESTRUT",,.T.)

DbSelectArea("ESTRUT")
DbGoTop()
Do While ESTRUT->(!Eof())
	SB1->(DbSeek(xFilial("SB1")+ESTRUT->COMP,.F.))
	If SB1->B1_TIPO == "MP"
		_nPosi := aScan(_aEmpenhos, {|x|x[1]==ESTRUT->COMP})
		If _nPosi == 0
			AADD(_aEmpenhos,{ESTRUT->COMP,SB1->B1_DESC,0.00})
			_nPosi := Len(_aEmpenhos)
		EndIf
		_aEmpenhos[_nPosi,3] += ESTRUT->QUANT
	EndIf
	ESTRUT->(DbSkip())
EndDo
FIMESTRUT2("ESTRUT")
_cNomeArq := _cNomeArq + ".*"
DELETE FILE &_cNomeArq.
Return(.T.)
*
****************************
Static Function MonteCarga()
****************************
*
// Acumula dados para a impressão das cargas --- _nRot == 3 // Impressão das OPs
_xDistCar := AllTrim(SZ9->Z9_DISTCAR)
_cDistCar := ""
For _nDistCar := 1 to Len(_xDistCar)
	If Substr(_xDistCar,_nDistCar,1) == "&"
		_cNunCar := Left(_cDistCar,2)
		_nQtdCar := Val(AllTrim(Substr(_cDistCar,3,50)))
		// Procura se tem um elemento com a mesma chave
		_nElem := 0
		_Z9_ACONDIC := If(AllTrim(SZ9->Z9_LOCALIZ) == "ES","B",SZ9->Z9_ACONDIC)
		For _nXx := 1 to Len(_aCargas)
			If 	_aCargas[_nXx,1] == _cNunCar        .And.; // 01-Nro da Carga
				_aCargas[_nXx,2] == SZ9->Z9_PEDIDO  .And.; // 02-Nro do Pedido de Venda
				_aCargas[_nXx,3] == SZ9->Z9_ITEMPV  .And.; // 03-Item do Pedido de Venda
				_aCargas[_nXx,5] == SZ9->Z9_NUM     .And.; // 05-Nro da OP
				_aCargas[_nXx,6] == SZ9->Z9_ITEM    .And.; // 06-Item da OP
				_aCargas[_nXx,7] == _TpBob          .And.; // 07-Tipo da Bobina
				_aCargas[_nXx,8] == _Z9_ACONDIC     .And.; // 08-Acondicionamento
				_aCargas[_nXx,9] == SZ9->Z9_METRAGE         // 09-Tamanho do lance
				_nElem := _nXx
				Exit
			EndIf
		Next
		If _nElem == 0
			_cNomCli := Left(If(AllTrim(SZ9->Z9_LOCALIZ) == "ES","Enviar para ESA","")+Space(20),20)
			If !Empty(SZ9->Z9_PEDIDO)
				DbSelectAre("SC5")
				DbSetOrder(1)
				If DbSeeK(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.)
					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
					_cNomCli := Left(SA1->A1_NOME,20)
				EndIf
			EndIf
			aAdd(_aCargas,{_cNunCar,SZ9->Z9_PEDIDO,SZ9->Z9_ITEMPV,_cNomCli,;
			SZ9->Z9_NUM,SZ9->Z9_ITEM,_TpBob,SZ9->Z9_ACONDIC,SZ9->Z9_METRAGE,;
			0,0,SC6->C6_ENTREG,SZ9->Z9_PRODUTO,u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SZ9->Z9_PRODUTO,"B1_DESC"))})
			// 01-Nro da Carga    // 02-Nro do Pedido de Venda // 03-Item do Pedido de Venda
			// 04-Nome do Cliente // 05-Nro da OP              // 06-Item da OP
			// 07-Tipo da Bobina  // 08-Acondicionamento       // 09-Tamanho do lance
			// 10-Quant.de Lances // 11-Quantidade da carga    // 12-Data da Entrega
			// 13-Cód.Produto     // 14-Descrição do Produto
			_nElem := Len(_aCargas)
		EndIf
		_aCargas[_nElem,11] += _nQtdCar
		_aCargas[_nElem,10] := _aCargas[_nElem,11]/_aCargas[_nElem,09]
		_cDistCar := ""
	Else
		_cDistCar := _cDistCar + Substr(_xDistCar,_nDistCar,1)
	EndIf
Next
Return(.T.)
*
*********************************************************
User Function CalcMet(_cProdB, _cBob, _cCodCli, _cLojCli)  // u_CalcMet("11411", "3","001347","03")
*********************************************************
*
/*/
	Função para calcular a metragem máxima para a bobina.
/*/
// Calculo da Metragem
//
// Redondo  -> B1_DIAMETR > 0
//			-> FATOR / ((Diametro)^2)
//
// Torcido  -> (B1_EIXOME * 2) == B1_EIXOMA
//			-> FATOR / (((E+)^2)-((E-)^2))
//
// Chato    -> FATOR / (Raiz((((E+) + (E-)) / 2)))

DEFAULT _cCodCli := Left(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]))
DEFAULT _cLojCli := Substring(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1])

_cBob := Left("B-"+StrZero(Val(_cBob),2) + Space(Len(SZA->ZA_CODIGO)),Len(SZA->ZA_CODIGO))
_cPdCodCli := Left(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]))
_cPdLojCli := Substring(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1])

If Empty(_cCodCli) .Or. Empty(_cLojCli)
	_cCodCli := _cPdCodCli
	_cLojCli := _cPdLojCli
EndIf
   
_nMetros := 0

SB1->(DbSetOrder(1))
If SB1->(DbSeek(xFilial("SB1")+AllTrim(_cProdB),.F.))
	DbSelectArea("SZA")
	DbSetOrder(1) //ZA_FILIAL+ZA_CLIENTE+ZA_LOJA+ZA_CODIGO
	
	If !(DbSeek(xFilial("SZA")+_cCodCli +_cLojCli  +_cBob,.F.)) // Procuro a bobina do cliente específico
		 DbSeek(xFilial("SZA")+_cPdCodCli+_cPdLojCli+_cBob,.F.)  // Procuro a bobina do cliente padrão
	EndIf
	If !Eof()
		If !Empty(SB1->B1_DIAMETR)
			// Redondo  -> B1_DIAMETR > 0
			//			-> FATOR / ((Diametro)^2)
			_nMetros := (SZA->ZA_FATOR / (SB1->B1_DIAMETR ** 2))
		ElseIf ((SB1->B1_EIXOME * 2) == SB1->B1_EIXOMA)
			// Torcido  -> (B1_EIXOME * 2) == B1_EIXOMA
			//			-> FATOR / (((E+)^2)-((E-)^2))
			_nMetros := (SZA->ZA_FATOR / ((SB1->B1_EIXOMA ** 2) - (SB1->B1_EIXOME ** 2)))
		Else // Suponho que é do tipo Chato
			// Chato    -> FATOR / (Raiz((((E+) + (E-)) / 2)))
			_nMetros :=	(SZA->ZA_FATOR / (((SB1->B1_EIXOMA+SB1->B1_EIXOME)/2)**2))
		EndIf
		_nMetros  := Int((_nMetros * 0.95))
		_nPesoPrd := (_nMetros * SB1->B1_PESBRU)
		If _nPesoPrd > SZA->ZA_PESO // Peso maior que o suportado pela bobina
			_nMetros := Int((SZA->ZA_PESO / SB1->B1_PESBRU))
		EndIf
	EndIf
EndIf
Return(_nMetros)
