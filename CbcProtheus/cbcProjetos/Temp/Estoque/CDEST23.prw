#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//
//   Programa ...: CDEST23()                          Modulo : SIGAEST
//
//   Autor ......: Roberto Oliveira                   Data ..: 13/07/2010
//
//   Objetivo ...: Função para avaliação de possibilidade de corte de bobinas
//                 em estoque com pedidos de vendas.
//
//   Uso ........: Especifico da Condusul
//
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDEST23()
	***********************
	*
	*
	_nRet:= 0
	cCadastro := "Avaliação: Bobinas X Pedidos de Vendas"
	aRotina := {{ "Pesquisar"   , "AxPesqui"    , 0 , 1	},;
				{ "Visualizar"  , "AxVisual"    , 0 , 2	},;
				{ "Processar"   , "u_CDEST23P()", 0 , 4	}} //,;
	DbSelectArea("SZE")
	DbSeek(xFilial("SZE"),.T.)
	//
	mBrowse(001,040,200,390,"SZE",,,,,,)
	//
	Return(.T.)
	*
	************************
User Function CDEST23P()
	************************
	*
	Private _ZE_STATUS
	//Solicita Parâmetros
	cPerg := "CDEST23"
	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf

	// Cria TRB das bobinas
	_aCampos:={}
	aAdd(_aCampos, {"PRODUTO", "C", TamSX3("C9_PRODUTO")[1], 0})
	aAdd(_aCampos, {"DESCRI" , "C", 45, 0})
	aAdd(_aCampos, {"NUMBOB" , "C", TamSX3("ZE_NUMBOB")[1], 0})
	aAdd(_aCampos, {"LANCE"  , "C", 05, 0})

	If Select("TRB_SZE") > 0
		DbSelectArea("TRB_SZE")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	//DbUseArea(lNovo, cDriver, cArquivo, cAlias, lComparilhado,lSoLeitura)
	DbUseArea(.T.,, _cNomArq, "TRB_SZE", .F., .F.) // abre o arquivo exclusivo
	DbSelectArea("TRB_SZE")

	_cInd := CriaTrab(Nil, .F.)
	IndRegua("TRB_SZE", _cInd, "PRODUTO+LANCE",,, "Selecionando Registros...")
	DbSetIndex(_cInd + OrdBagExt())


	// Cria TRB dos itens dos pedidos de venda
	_aCampos:={}
	aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C9_PEDIDO" )[1], 0})
	aAdd(_aCampos, {"ITEM"   , "C", TamSX3("C9_ITEM"   )[1], 0})
	aAdd(_aCampos, {"SEQUEN" , "C", TamSX3("C9_SEQUEN" )[1], 0})
	aAdd(_aCampos, {"PRODUTO", "C", TamSX3("C9_PRODUTO")[1], 0})
	aAdd(_aCampos, {"ACOND"  , "C", 01, 0})
	aAdd(_aCampos, {"LANCE"  , "C", 05, 0})
	aAdd(_aCampos, {"ENTREGA", "D", 08, 0}) // data de entrega
	aAdd(_aCampos, {"CLIENTE", "C", TamSX3("C9_CLIENTE")[1], 0})
	aAdd(_aCampos, {"LOJA"   , "C", TamSX3("C9_LOJA")[1], 0})
	aAdd(_aCampos, {"NOME"   , "C", TamSX3("A1_NOME")[1], 0})
	aAdd(_aCampos, {"NUMREC" , "N", 12, 0}) // trata este campo como se fosse o nro do registro para facilitar o posicionamento

	If Select("TRB_SC9") > 0
		DbSelectArea("TRB_SC9")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	//DbUseArea(lNovo, cDriver, cArquivo, cAlias, lComparilhado,lSoLeitura)
	DbUseArea(.T.,, _cNomArq, "TRB_SC9", .F., .F.) // abre o arquivo exclusivo
	DbSelectArea("TRB_SC9")

	_cInd1 := CriaTrab(Nil, .F.)
	IndRegua("TRB_SC9", _cInd1, "PRODUTO+LANCE+Dtos(ENTREGA)+PEDIDO+ITEM",,, "Selecionando Registros...")

	_cInd2 := CriaTrab(Nil, .F.)
	IndRegua("TRB_SC9", _cInd2, "NUMREC",,, "Selecionando Registros...")

	_cInd1 := _cInd1+OrdBagExt()
	_cInd2 := _cInd2+OrdBagExt()
	Set Index to &(_cInd1),&(_cInd2)
	DbSetOrder(1)

	DbSelectAreA("SF4")
	DbSetOrder(1)

	DbSelectArea("SC9")
	//DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	Set Filter to C9_BLCRED == "  " .And. C9_BLEST == "02"
	DbSetOrder(7) //C9_FILIAL+C9_PRODUTO+C9_LOCAL+C9_NUMSEQ

	DbSelectArea("SC6")
	DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SZE")
	DbSetOrder(4) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
	//
	// Alteração realizada em 15/02/11
	// Colocar a rotina dentro de um FOR/NEXT onde primeiro será avaliado as bobinas que possivelmente possuam saldo
	// de retrabalho e depois as disponíveis em estoque
	// Somente efetuar a gravação das tabelas SZE e SZR se ao final do processo de cada bobina o status dela
	// ainda estiver sem alteração.
	//
	For _nVerStat := 1 to 2
		If _nVerStat == 1
			_ZE_STATUS := "N" // primeiro veremos as com status de reserva confirmada
		Else
			_ZE_STATUS := "T" // Depois veremos as com status de EM ESTOQUE
		EndIf

		DbSeek(xFilial("SZE")+_ZE_STATUS,.F.) // Bobinas disponíveis no estoque
		Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_STATUS == _ZE_STATUS .And. SZE->(!Eof())
			If SZE->ZE_PRODUTO < MV_PAR01 .Or. SZE->ZE_PRODUTO > MV_PAR02 // Está fora do parametro produto
				SZE->(DbSkip())
				Loop
			EndIf

			If _nRet == 3
				If SZE->ZE_PRODUTO == _ZE_PRODUTO
					SZE->(DbSkip())
					Loop
				EndIf
			EndIf

			_nRet:= 0

			_ZE_PRODUTO := SZE->ZE_PRODUTO
			DbSelectArea("TRB_SC9")
			Zap

			DbSelectArea("TRB_SZE")
			Zap

			// DbSelectArea("SZR")
			SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB

			_nMaiorLc := 0
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_STATUS == _ZE_STATUS .And. SZE->ZE_PRODUTO == _ZE_PRODUTO .And. SZE->(!Eof())

				// Verificar se já tem resevas para esta bobina e calcular o saldo dela
				_nQtdSZR := 0
				SZR->(DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.))
				Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
					_nQtdSZR += SZR->ZR_METRAGE
					SZR->(DbSkip())
				EndDo

				RecLock("TRB_SZE",.T.)
				TRB_SZE->PRODUTO := SZE->ZE_PRODUTO
				TRB_SZE->DESCRI  := SZE->ZE_DESCPRO
				TRB_SZE->NUMBOB  := SZE->ZE_NUMBOB
				TRB_SZE->LANCE   := StrZero((SZE->ZE_QUANT-_nQtdSZR),5)
				MsUnLock()
				_nMaiorLc := Max(_nMaiorLc,(SZE->ZE_QUANT-_nQtdSZR))

				SZE->(DbSkip())
			EndDo

			_cProxZe := SZE->ZE_FILIAL+SZE->ZE_STATUS+SZE->ZE_PRODUTO
			DbSelectArea("SC9") // Filtro -> C9_BLCRED == "  " .And. C9_BLEST == "02"
			SC9->(DbSetOrder(7)) //C9_FILIAL+C9_PRODUTO+C9_LOCAL+C9_NUMSEQ

			DbSeek(xFilial("SC9")+_ZE_PRODUTO,.F.)
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PRODUTO == _ZE_PRODUTO .And. SC9->(!Eof())

				If SC9->C9_CLIENTE+SC9->C9_LOJA >= MV_PAR03+MV_PAR04 .And. ;
				SC9->C9_CLIENTE+SC9->C9_LOJA <= MV_PAR05+MV_PAR06 .And. ;
				SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "02"

					If SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)) // DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
						SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
						If SC6->C6_ENTREG >= Mv_Par07 .And. SC6->C6_ENTREG <= Mv_Par08 .And. SF4->F4_ESTOQUE == "S"

							If (SC6->C6_ACONDIC # "R" .Or. SC6->C6_METRAGE # 100) .And.;
							SC6->C6_METRAGE <= _nMaiorLc .And. Empty(SC6->C6_SEMANA)

								// se não for rolo de 100 e
								// se o lance não é maior que a minha maior bobina e
								// ... faz a comparação
								// Gravo lance a lance para poder trabalhar
								_nQtdLances := Int((SC9->C9_QTDLIB/SC6->C6_METRAGE))
								For _nQtdGrv := 1 to _nQtdLances
									RecLock("TRB_SC9",.T.)
									TRB_SC9->PEDIDO  := SC9->C9_PEDIDO
									TRB_SC9->ITEM    := SC9->C9_ITEM
									TRB_SC9->SEQUEN  := SC9->C9_SEQUEN
									TRB_SC9->PRODUTO := SC9->C9_PRODUTO
									TRB_SC9->ACOND   := SC6->C6_ACONDIC
									TRB_SC9->LANCE   := StrZero(SC6->C6_METRAGE,5)
									TRB_SC9->ENTREGA := SC6->C6_ENTREG
									TRB_SC9->CLIENTE := SC9->C9_CLIENTE
									TRB_SC9->LOJA    := SC9->C9_LOJA
									TRB_SC9->NOME    := Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_NOME")
									MsUnLock()
								Next
							EndIf
						EndIf
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo

			DbSelectArea("TRB_SZE")
			DbGoTop()
			Do While TRB_SZE->(!Eof()) .And. LastRec("TRB_SC9") > 0

				// Gravo o "nro dos registros"
				_nReg := 1
				DbSelectArea("TRB_SC9")
				DbSetOrder(1)
				DbGoTop()
				Do While TRB_SC9->(!Eof())
					RecLock("TRB_SC9",.F.)
					TRB_SC9->NUMREC  := _nReg++
					MsUnLock()
					TRB_SC9->(DbSkip())
				EndDo

				// Mudo a ordem para poder posicionar nos registros
				DbSelectArea("TRB_SC9")
				DbSetOrder(2) // NUMREC

				_nQtdSC9  := 0
				_nGoodLnc := 999999999999 // Começo com um número alto para poder comparar depois
				_nGoodQtd := 999999999
				_cGoodCpo := ""
				_nQtdElem := (_nReg-1) // Quantidade de itens do TRB_SC9
				_cCampo  := ""
				_nQtdDot := 0
				Do While _cCampo # Replicate(".",_nQtdElem)
					_cCampo  := Replicate(".",_nQtdDot++) + "X"
					_cCpoTRB := Left(_cCampo + Space(_nQtdElem),_nQtdElem)
					_nPontos := 0
					_nXis    := 1

					DbSelectArea("TRB_SC9")
					DbSetOrder(2) // NUMREC

					//			_nExato := 0
					Do While Right(_cCpoTRB,1) # "."
						_lMaior := .F.
						_nExato := 0
						_nQtdSC9 := 0
						For _nAtu := 1 To Len(AllTrim(_cCpoTRB))
							If Substr(_cCpoTRB,_nAtu,1) == "X"
								TRB_SC9->(DbSeek(_nAtu,.F.))
								If (_nQtdSC9 + Val(TRB_SC9->LANCE)) > Val(TRB_SZE->LANCE)
									_lMaior := .T.
									Exit
								Else
									_nQtdSC9 +=  Val(TRB_SC9->LANCE)
									_nExato++ // Quantidade de lances somados
								EndIf
							EndIf
						Next

						If !_lMaior
							// Verifico se este é o melhor lance
							_nResult := (Val(TRB_SZE->LANCE) - _nQtdSC9)
							If _nResult < _nGoodLnc
								_nGoodLnc := _nResult
								_cGoodCpo := _cCpoTRB
								_nGoodQtd := _nExato  // Quantidade de lances somados
							ElseIf _nResult == _nGoodLnc .And. _nExato < _nGoodQtd // Se é a mesma quantidade mas em menos lances
								_nGoodLnc := _nResult
								_cGoodCpo := _cCpoTRB
								_nGoodQtd := _nExato  // Quantidade de lances somados
							EndIf
						EndIf

						If _cCampo == Replicate(".",_nQtdElem-1) + "X"
							// Este foi o ultimo Cara
							_cCampo  := Replicate(".",_nQtdElem)
							_cCpoTRB := Replicate(".",_nQtdElem)
						Else
							If Right(_cCpoTRB,1) == "X"
								_nXis    := 1
								_nPontos++
							EndIf
							_cCpoTRB := Left(_cCampo + Replicate(".",_nPontos) + Replicate("X",_nXis++) + Space(_nQtdElem),_nQtdElem)
						EndIf
					EndDo
				EndDo

				If _nGoodLnc # 999999999999 // Começo com um número alto para poder comparar depois
					DbSelectArea("SZE")
					SZE->(DbsetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
					If DbSeek(xFilial("SZE")+TRB_SZE->NUMBOB,.F.)
						If RecLock("SZE",.F.)
							If SZE->ZE_STATUS == _ZE_STATUS
								MostreCorte()
								DbSelectArea("SZE")
								SZE->(DbsetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
								DbSeek(xFilial("SZE")+TRB_SZE->NUMBOB,.F.)
							EndIf
							MsUnLock()
						EndIf
					EndIf
				EndIf


				If _nRet == 2 .Or. _nRet == 3
					Exit
				EndIf

				DbSelectArea("TRB_SZE")
				TRB_SZE->(DbSkip())
			EndDo
			If _nRet == 2
				Exit
			EndIf

			// Raposiciono o SZE pois pode ser que eu tenha gravado o campo STATUS e ai muda
			DbSelectArea("SZE")
			DbSetOrder(4) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
			If SZE->ZE_FILIAL+SZE->ZE_STATUS+SZE->ZE_PRODUTO # _cProxZe
				DbSeek(_cProxZe,.F.) //  _cProxZe := SZE->ZE_FILIAL+SZE->ZE_STATUS+SZE->ZE_PRODUTO
			EndIf
		EndDo
		If _nRet == 2
			Exit
		EndIf
	Next
	Return(.T.)
	*
	*****************************
Static Function MostreCorte()
	*****************************
	*
	*
	nOpcE:=3
	nOpcG:=3
	inclui := .T.
	altera := .F.
	exclui := .F.

	aAltEnchoice :={}
	_cProdEch := TRB_SZE->PRODUTO
	_cDescEch := TRB_SZE->DESCRI
	_cBobiEch := TRB_SZE->NUMBOB
	_cLancEch := Val(TRB_SZE->LANCE)
	_nQuanEch := _cLancEch-_nGoodLnc // Somar quanto estiver montando o acols
	_nSobrEch := _nGoodLnc // Sobra
	_cObsvEch := Space(TamSX3("ZR_OBS")[1]);_aDest := { "Retorna Estoque", "Sucateia"};_nDest := 1

	// Adiciona as bobinas seguintes do mesmo produto
	DbSelectArea("TRB_SZE")
	_aArea := GetArea()
	_nPrxBob1 := _nPrxBob2 := _nPrxBob3 := _nPrxBob4 := _nPrxBob5 := _nPrxBob6 := _nPrxBob7 := 0

	For _nVari := 1 TO 7
		TRB_SZE->(DbSkip())
		If TRB_SZE->(Eof())
			Exit
		EndIf
		_cVari   := "_nPrxBob" + StrZero(_nVari,1)
		&_cVari. := Val(TRB_SZE->(LANCE))
	Next

	RestArea(_aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	dbSelectArea("SX3")
	DbSetOrder(2)
	aHeader:={}
	For _nx := 1 to 10
		nUsado:=nUsado+1
		Aadd(aHeader,{" "," "," ",0,0," "," "," "," "," "} )
		If _nx == 1
			aHeader[_nx,1] := "Pedido"
			aHeader[_nx,2] := "C9_PEDIDO"
		ElseIf _nx == 2
			aHeader[_nx,1] := "Item"
			aHeader[_nx,2] := "C9_ITEM"
		ElseIf _nx == 3
			aHeader[_nx,1] := "Sequenc."
			aHeader[_nx,2] := "C9_SEQUEN"
		ElseIf _nx == 4
			aHeader[_nx,1] := "Cliente"
			aHeader[_nx,2] := "C9_CLIENTE"
		ElseIf _nx == 5
			aHeader[_nx,1] := "Loja"
			aHeader[_nx,2] := "C9_LOJA"
		ElseIf _nx == 6
			aHeader[_nx,1] := "Nome Cliente"
			aHeader[_nx,2] := "C9_DESCRI"
		ElseIf _nx == 7                                       '
			aHeader[_nx,1] := "Acondic."
			aHeader[_nx,2] := "C9_BLOQUEI"
		ElseIf _nx == 8
			aHeader[_nx,1] := "Tam.Lance"
			aHeader[_nx,2] := "C9_QTDORI"
		ElseIf _nx == 9
			aHeader[_nx,1] := "Dt.Entrega"
			aHeader[_nx,2] := "C9_DATALIB"
		ElseIf _nx == 10
			aHeader[_nx,1] := "Quant.Utilizada"
			aHeader[_nx,2] := "C9_QTDLIB"
		EndIf
		DbSeek(aHeader[_nx,2],.F.)
		aHeader[_nx,03] := SX3->X3_PICTURE
		aHeader[_nx,04] := SX3->X3_TAMANHO
		aHeader[_nx,05] := SX3->X3_DECIMAL
		If _nx == 10  // Permite alterar a quantidade sem questionar a soma dos itens
			aHeader[_nx,06] := "Positivo() .And. u_ValLinha()"
		Else
			aHeader[_nx,06] := ".F." //SX3->X3_VLDUSER // "AllwaysTrue()"
		EndIf
		aHeader[_nx,07] := SX3->X3_USADO
		aHeader[_nx,08] := SX3->X3_TIPO
		aHeader[_nx,09] := SX3->X3_ARQUIVO
		aHeader[_nx,10] := SX3->X3_CONTEXT
	Next

	aCols:={}
	MonteAcols()
	If Len(aCols) == 0
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.
	EndIf

	_nRet:= 0
	aButtons := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := "Avaliação Bobinas X Pedidos de Vendas"
	cAliasEnchoice := ""
	cAliasGetD     := "SC9"
	cLinOk         := "u_SomaLinhas()" //"AllwaysTrue()"
	cTudOk         := "u_SomaTd()" //"u_ValTd()" //
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}

	_nRet:=u_JanEst23(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
	If _nRet == 1 // Confirmou a operação -> gravar os dados
		Processa( {|| CD23Grave() },"Gravando Reservas...")
	EndIf
	Return(.T.)
	*
*
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function JanEst23(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
	Local aSize := {}
	Local aPosObj := {}
	Local aObjects := {}
	Local aInfo := {}

	aSize := MsAdvSize()
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 015, .t., .f. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
	//                                            {15,2,40,355}  45,2,190,355
	nGetLin := aPosObj[3,1]

	_aDest := { "Retorna Estoque", "Sucateia"}
	_nDest := 1

	Private oDlg,oGetDados
	Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,999,nLinhas)


	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	@ 015,005 Say "Produto:"                                    Size  45,10
	@ 015,055 Get _cProdEch Picture "@R 999.99.99.999" When .F. Size  60,10
	@ 015,130 Say "Descrição:"                                  Size  45,10
	@ 015,170 Get _cDescEch                          When .F.   Size 290,10


	@ 030,005 Say "Nro. Bobina.:"                              Size 45,10
	@ 030,055 Get _cBobiEch                          When .F.  Size 60,10

	@ 030,130 Say "Quant.Bobina:"                              Size 45,10
	@ 030,170 Get _cLancEch  Picture "@E 999,999"    When .F.  Size 60,10

	@ 030,245 Say "Quant.Util.:"                               Size 45,10
	@ 030,285 Get _nQuanEch  Picture "@E 999,999"    When .F.  Size 60,10 Object o_nQuanEch

	@ 030,360 Say "Sobra (m):"                         Size 45,10
	@ 030,400 Get _nSobrEch  Picture "@E 999,999"    When .F. Size 60,10 Object o_nSobrEch

	@ 045,005 Say "Observação :"                          Size 45,10
	@ 045,055 Get _cObsvEch                               Size 150,10

	@ 045,360 Say "Destino Sobra:"                        Size 45,10
	@ 045,400 COMBOBOX _nDest ITEMS  _aDest Size 60,10

	//@ nLinha,nColuna COMBOBOX VARIAVEL ITEMS AITENS SIZE nLargura,nAltura UNIDADE OF oObjetoRef

	@ 060,005 Say "Proxs.Bobs.:"                          Size 45,10
	@ 063,045 Say "1 - "                                  Size 10,10
	@ 060,055 Get _nPrxBob1 Picture "@E 999,999" When .F. Size 40,10
	@ 063,107 Say "2 - "                                  Size 10,10
	@ 060,117 Get _nPrxBob2 Picture "@E 999,999" When .F. Size 40,10
	@ 063,168 Say "3 - "                                  Size 10,10
	@ 060,178 Get _nPrxBob3 Picture "@E 999,999" When .F. Size 40,10
	@ 063,229 Say "4 - "                                  Size 10,10
	@ 060,239 Get _nPrxBob4 Picture "@E 999,999" When .F. Size 40,10
	@ 063,289 Say "5 - "                                  Size 10,10
	@ 060,299 Get _nPrxBob5 Picture "@E 999,999" When .F. Size 40,10
	@ 063,350 Say "6 - "                                  Size 10,10
	@ 060,360 Get _nPrxBob6 Picture "@E 999,999" When .F. Size 40,10
	@ 063,410 Say "7 - "                                  Size 10,10
	@ 060,420 Get _nPrxBob7 Picture "@E 999,999" When .F. Size 40,10


	//@ 045,130 Say "Vlr. Tot.PVC :"                          Size 45,10
	//@ 045,170 Get _nTotPvc Picture "@E 999,999.99" When .F. Size 60,10 Object _O_nTotPvc
	//@ 045,245 Say "Vlr. Tot. MO :"                          Size 45,10
	//@ 045,285 Get _nTotMO  Picture "@E 999,999.99" When .F. Size 60,10 Object _O_nTotMO
	//@ 045,360 Say "Peso Tot. PVC:"                          Size 45,10
	//@ 045,400 Get _nPesPvc Picture "@E 999,999.99" When .F. Size 60,10 Object _O_nPesPvc

	oGetDados := MsGetDados():New(75,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_RefEst23()}

	// Corrigir os Botões
	aAdd(aButtons,{"SVM"     ,{|| FecheOdlg(2)}, "Cancela e para o processamento"})
	aAdd(aButtons,{"PMSRRFSH",{|| FecheOdlg(3)}, "Cancela e pula produto"})
	aAdd(aButtons,{"HISTORIC",{|| VejaEstoq() }, "Mostra Estoques"})
	_nFechou := 0
	//aAdd(aButtons,{"S4WB005N",{|| LibMult() }  , "Liberação Múltipla"})

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

	If _nFechou # 0
		_nRet := _nFechou
	Else
		_nRet := nOpca
	EndIf
	Return(_nRet)
	*
	**********************
User Function RefEst23()
	**********************
	*
	o_nQuanEch:Refresh()
	o_nSobrEch:Refresh()
	//_O_nTotCob:Refresh()
	//_O_nTotPvc:Refresh()
	//_O_nTotMO:Refresh()
	//oGetDados:Refresh()
	Return(.T.)
	*
	****************************
Static Function MonteAcols()
	****************************
	*
	DbSelectArea("TRB_SC9")
	DbGoTop()
	Do While TRB_SC9->(!Eof())
		AADD(aCols,Array(Len(aHeader)+1))
		_nCol := Len(aCols)
		aCols[_nCol,Len(aHeader)+1]:=.F.

		GDFieldPut("C9_PEDIDO" ,TRB_SC9->PEDIDO ,_nCol)
		GDFieldPut("C9_ITEM"   ,TRB_SC9->ITEM   ,_nCol)
		GDFieldPut("C9_SEQUEN" ,TRB_SC9->SEQUEN ,_nCol)
		GDFieldPut("C9_CLIENTE",TRB_SC9->CLIENTE,_nCol)
		GDFieldPut("C9_LOJA"   ,TRB_SC9->LOJA   ,_nCol)
		GDFieldPut("C9_DESCRI" ,TRB_SC9->NOME   ,_nCol) // Nome do cliente
		GDFieldPut("C9_BLOQUEI",TRB_SC9->ACOND  ,_nCol) // Acondicionamento
		GDFieldPut("C9_QTDORI" ,Val(TRB_SC9->LANCE)  ,_nCol) // Tamanho do Lance
		GDFieldPut("C9_DATALIB",TRB_SC9->ENTREGA,_nCol) // Data da Entrega
		GDFieldPut("C9_QTDLIB" ,0.00            ,_nCol) // Quant. Util
		If TRB_SC9->NUMREC <= Len(_cGoodCpo)
			If Substr(_cGoodCpo,TRB_SC9->NUMREC,1)=="X"
				GDFieldPut("C9_QTDLIB" ,Val(TRB_SC9->LANCE),_nCol) // Quant. Util
			EndIf
		EndIf
		TRB_SC9->(DbSkip())
	EndDo
	Return(.T.)
	*
	************************
User Function ValLinha()
	************************
	*
	If GDFieldGet("C9_QTDORI",n) # M->C9_QTDLIB .And. M->C9_QTDLIB # 0
		Return(.F.)
	EndIf
	u_SomaLinhas()
	Return(.T.)
	*
	**************************
User Function SomaLinhas()
	**************************
	*
	_nQuanEch := 0
	For _nLinhas := 1 to Len(aCols)
		_nQuanEch += GDFieldGet("C9_QTDLIB",_nLinhas)
	Next
	_nSobrEch := _cLancEch - _nQuanEch
	u_RefEst23()
	Return(.t.)
	*
	*************************
Static Function ValidPerg
	*************************
	*
	*
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Produto                   ?","mv_ch1","C",TamSX3("B1_COD")[1] ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Até o Produto                ?","mv_ch2","C",TamSX3("B1_COD")[1] ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Do Cliente                   ?","mv_ch3","C",TamSX3("A1_COD")[1] ,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"04","Da Loja                      ?","mv_ch4","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Até o Clinte                 ?","mv_ch5","C",TamSX3("A1_COD")[1] ,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Até a Loja                   ?","mv_ch6","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Da Dt.Entrega                ?","mv_ch7","D",08                  ,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Até a Dt. Entrega            ?","mv_ch8","D",08                  ,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})

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
	*
	*********************************
Static Function FecheOdlg(nForma)
	*********************************
	*
	_nFechou := nForma
	Close(oDlg)
	Return(.T.)
	*
	***************************
Static Function CD23Grave()
	***************************
	*

	// Na entrada desta função, o SZE já tem que estar POSICIONADO E TRAVADO e na ordem 1
	// DbSelectArea("SZE")
	// SZE->(DbsetOrder(1)) // ZE_FILIAL+ZE_NUMBOB

	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectARea("SZR")
	DbSetOrder(3) // ZR_FILIAL+ZR_NUMBMM+ZR_NUMBOB+ZR_PEDIDO+ZR_ITEMPV
	For _n := 1 to Len(acols)
		If !GDDeleted(_n) .And. GDFieldGet("C9_QTDLIB" ,_n) > 0.00

			//		SZE->(DbSeek(xFilial("SZE")+_cBobiEch,.F.)) // Vide obs. acima

			If SC6->(DbSeek(xFilial("SC6") + GDFieldGet("C9_PEDIDO" ,_n) + GDFieldGet("C9_ITEM" ,_n),.F.))
				If RecLock("SC6",.F.)
					If Empty(SC6->C6_SEMANA)
						SC6->C6_SEMANA  := "RESERVA"
					EndIf
					SC6->C6_QTDRES  := SC6->C6_QTDRES+GDFieldGet("C9_QTDLIB" ,_n)
					MsUnLock()

					//				RecLock("SZE",.F.) // Vide obs. acima
					SZE->ZE_STATUS := "N" //I=Import..;C=Canc.;R=Recebida;P=A Liberar;E=Empenh.;F=Faturada;T=Estoque;
					//A=Adiantada;X=Expedida;D=Devolv.;V=Reserv.;N=Res.Conf.
					MsUnLock()

					If !SZR->(DbSeek(xFilial("SZR") + Replicate("@",Len(SZR->ZR_NUMBMM)) + _cBobiEch +  GDFieldGet("C9_PEDIDO" ,_n) + GDFieldGet("C9_ITEM" ,_n),.F.))
						RecLock("SZR",.T.)
						SZR->ZR_NUMBMM  := Replicate("@",Len(SZR->ZR_NUMBMM)) // Gravo com @@@@@@ para que a expedição ainda nao veja esta reserva
						SZR->ZR_FILIAL  := xFilial("SZR")
						SZR->ZR_NUMBOB  := _cBobiEch
						SZR->ZR_TAMBOB  := _cLancEch
						SZR->ZR_DATA    := dDataBase
						SZR->ZR_PRODUTO := SZE->ZE_PRODUTO
						SZR->ZR_DESCR   := SZE->ZE_DESCPRO
						SZR->ZR_PEDIDO  := GDFieldGet("C9_PEDIDO" ,_n)
						SZR->ZR_ITEMPV  := GDFieldGet("C9_ITEM" ,_n)
						SZR->ZR_CODCLI  := GDFieldGet("C9_CLIENTE",_n)
						SZR->ZR_LOJA    := GDFieldGet("C9_LOJA"   ,_n)
						SZR->ZR_NOMCLI  := GDFieldGet("C9_DESCRI",_n)
						SZR->ZR_RESP    := cUserName
						SZR->ZR_OBS     := _cObsvEch
						SZR->ZR_ACONDIC := AllTrim(GDFieldGet("C9_BLOQUEI",_n))
						SZR->ZR_METRAGE := GDFieldGet("C9_QTDORI",_n)
					Else
						RecLock("SZR",.F.)
					EndIf
					SZR->ZR_QTDPV   += GDFieldGet("C9_QTDLIB" ,_n)
					SZR->ZR_LANCES  := SZR->ZR_QTDPV/SZR->ZR_METRAGE
					MsUnLock()

					DbSelectArea("TRB_SC9")
					DbGoTo(_n)
					RecLock("TRB_SC9",.F.)
					DbDelete()
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Next

	// Disponibiliza as reservas para a expedição providenciar os trabalhos
	DbSelectARea("SZR")
	DbSetOrder(3) // ZR_FILIAL+ZR_NUMBMM+ZR_NUMBOB+ZR_PEDIDO+ZR_ITEMPV
	Do While DbSeek(xFilial("SZR") + Replicate("@",Len(SZR->ZR_NUMBMM)),.F.)
		RecLock("SZR",.F.)
		SZR->ZR_NUMBMM  := Space(Len(SZR->ZR_NUMBMM))
		MsUnLock()
	EndDo

	DbSelectArea("TRB_SC9")
	Pack

	Return(.T.)
	*
	**********************
User Function SomaTd()
	**********************
	*
	_nQtdVal := 0
	For _nLinhas := 1 to Len(aCols)
		_nQtdVal += GDFieldGet("C9_QTDLIB",_nLinhas)
	Next
	If _nQtdVal > _cLancEch
		Alert("Opção Inválida -> Soma dos cortes maior que o lance da bobina")
		Return(.F.)
	EndIf
	Return(.T.)
	*
	***************************
Static Function VejaEstoq()
	***************************
	*
	_cProds := Left(_cProdEch,7) // 3-Produto + 2-Bitola + 2 Cor
	If Left(_cProds,3) == "113" // Se for Cobrenax Flex, mostrar também HEPR
		_cProds := _cProds + "114" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "132" // Se for PP 2C, mostrar também Multinax 2C
		_cProds := _cProds + "142" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "133" // Se for PP 3C, mostrar também Multinax 3C
		_cProds := _cProds + "143" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "134" // Se for PP 4C, mostrar também Multinax 4C
		_cProds := _cProds + "144" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "142" // Se for Multinax 2C, mostrar também PP 2C
		_cProds := _cProds + "132" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "143" // Se for Multinax 3C, mostrar também PP 3C
		_cProds := _cProds + "133" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "144" // Se for Multinax 4C, mostrar também PP 4C
		_cProds := _cProds + "134" + Substr(_cProdEch,4,4)
	ElseIf Left(_cProds,3) == "110" // Se for Cabo Plasticom, mostrar também Cabo Cobrenax Rigido
		_cProds := _cProds + "112" + Substr(_cProdEch,4,4)
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SBF")
	DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	aMyCols2 := {}
	Do While Len(_cProds) > 0
		DbSeek(xFilial("SBF")+Left(_cProds,7),.F.)
		Do While SBF->BF_FILIAL == xFilial("SBF") .And. Left(SBF->BF_PRODUTO,7) == Left(_cProds,7) .And. SBF->(!Eof())
			If SBF->BF_LOCAL == "01" .And. Left(SBF->BF_LOCALIZ,1) # "B" .And.;
			(SBF->BF_QUANT-SBF->BF_EMPENHO) > 0  .And. SBF->BF_EMPENHO >=0

				SB1->(DbSeek(xFilial("SB1") + SBF->BF_PRODUTO,.F.))
				AADD(aMyCols2,{Left(SBF->BF_PRODUTO,10),SB1->B1_DESC,Left(SBF->BF_LOCALIZ,6),SBF->BF_QUANT,;
				SBF->BF_EMPENHO,(SBF->BF_QUANT-SBF->BF_EMPENHO),.F.})
			EndIf
			DbSkip()
		EndDo
		If Len(_cProds) > 7
			_cProds := Right(_cProds,7)
		Else
			_cProds := ""
		EndIf
	EndDo

	If Len(aMyCols2) ==0
		Alert("Não há Disponibilidades para esse Produto")
		Return(.T.)
	EndIf

	aSort(aMyCols2,,,{|x,y| x[1]+x[3]<y[1]+y[3]}) // Ordena do menor para o maior

	// Fazer uma cópia do aHeader
	aHeadBK2 := {}
	For _nHead1 := 1 To Len(aHeader)
		aAdd(aHeadBK2,Array(Len(aHeader[_nHead1])))
		For _nHead2 := 1 To Len(aHeader[_nHead1])
			aHeadBK2[_nHead1,_nHead2] := aHeader[_nHead1,_nHead2]
		Next
	Next

	// Fazer uma Cópia do aCols
	aColsBK2 := {}
	For _nCols1 := 1 To Len(aCols)
		aAdd(aColsBK2,Array(nUsado+1))
		For _nCols2 := 1 To Len(aCols[_nCols1])
			aColsBK2[_nCols1,_nCols2] := aCols[_nCols1,_nCols2]
		Next
	Next

	//Guardar o conteudo de da variável n
	_nBKn := n

	// Guardar o conteudo de nUsado
	_nBKUsado := nUsado

	// Criar aHeader para a nova janela
	aHeader   := {}
	Aadd(aHeader,{"Produto"       ,"PRODU","XXXXXXXXXX"                    ,10,0,".F.","","C","","V"})
	Aadd(aHeader,{"Descrição"     ,"DESCR","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",30,0,".F.","","C","","V"})
	Aadd(aHeader,{"Acondic."      ,"ACOND","XXXXXX"                        ,06,0,".F.","","C","","V"})
	Aadd(aHeader,{"Qtd.Estq."     ,"QUANT","@E 9,999,999.99"               ,10,0,".F.","","N","","V"})
	Aadd(aHeader,{"Qtd.Empenho"   ,"EMPEN","@E 9,999,999.99"               ,10,0,".F.","","N","","V"})
	Aadd(aHeader,{"Sld.Disponível","DISPO" ,"@E 9,999,999.99"              ,10,0,".F.","","N","","V"})
	nUsado:=Len(aHeader)

	// Transferir dados do aMyCols2 para o acols
	aCols := {}
	For _nCols1 := 1 To Len(aMyCols2)
		aAdd(aCols,Array(7))
		aCols[_nCols1,1] := aMyCols2[_nCols1,1]
		aCols[_nCols1,2] := aMyCols2[_nCols1,2]
		aCols[_nCols1,3] := aMyCols2[_nCols1,3]
		aCols[_nCols1,4] := aMyCols2[_nCols1,4]
		aCols[_nCols1,5] := aMyCols2[_nCols1,5]
		aCols[_nCols1,6] := aMyCols2[_nCols1,6]
		aCols[_nCols1,7] := .F.
	Next

	// Guardar o conteudo de cCadastro
	_BkCad := cCadastro

	// Montar DialogBox para mostrar os dados
	cCadastro := OemToAnsi("Saldos Disponíveis")
	ntamaCols := Len(aCols)

	_x1 := 330 // LINHA FINAL
	_x2 := 678 // COLUNA FINAL
	_x3 := 160 // LINHA FINAL
	_x4 := 335 // COLUNA FINAL

	@ 000,000 TO _x1,_x2 DIALOG oDlgSld TITLE cCadastro
	//@ 004,005 TO 100,230 MULTILINE MODIFY DELETE  OBJECT oMultiline VALID u_SomePar() //LineOk() FREEZE 1
	@ 004,005 TO _x3,_x4 MULTILINE OBJECT oMultSld
	ACTIVATE DIALOG oDlgSld CENTERED

	// Retornar o aHeader da cópia
	aHeader := {}
	For _nHead1 := 1 To Len(aHeadBK2)
		aAdd(aHeader,Array(Len(aHeadBK2[_nHead1])))
		For _nHead2 := 1 To Len(aHeadBK2[_nHead1])
			aHeader[_nHead1,_nHead2] := aHeadBK2[_nHead1,_nHead2]
		Next
	Next

	// Voltar o conteudo de nUsado
	nUsado := _nBKUsado

	// Voltar o conteudo de da variável n
	n := _nBKn

	// Voltar o conteudo de cCadastro
	cCadastro := _BkCad

	// Retornar o aCols da cópia
	aCols := {}
	For _nCols1 := 1 To Len(aColsBK2)
		aAdd(aCols,Array(nUsado+1))
		For _nCols2 := 1 To Len(aColsBK2[_nCols1])
			aCols[_nCols1,_nCols2] := aColsBK2[_nCols1,_nCols2]
		Next
	Next
Return(.T.)