#include "rwmake.ch"
#include "protheus.ch"

#define GRP_EXPED_ITU '000043'

static lNewRg	:= GetNewPar('ZZ_LOOKM2', .T.)
//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//   Programa ...: CDFATR01                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 24/09/2004   //
//                                                                          //
//   Objetivo ...: Relat?rio de Pedidos de Venda e Ordens de Separa??o      //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
********************************
User Function CDFATR01(_cPedido)
********************************

Local cDesc1        := "Este programa tem como objetivo imprimir relat?rio "
Local cDesc2        := "de Pedido de Venda ou Ordem de Separa??o de acordo "
Local cDesc3        := "com os par?metros informados pelo usu?rio."
Local cPict         := ""
Local titulo        := "Pedido de Venda / Ordem de Separa??o"
Local nLin          := 80

Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "CDFATR01"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "CDFT01"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "CDFATR01"
Private lImpCb      := .F.
Private _aItens
Private _lGpo		:= (Ascan(USRRETGRP(),"000002") > 0)

cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

Private cString     := "SC5"

DbSelectArea("SC5")
DbSetOrder(1)

ValidPerg(cPerg)

If Valtype(_cPedido) # "U"
	Pergunte(cPerg,.F.)
	MV_PAR01 := 2
	MV_PAR02 := _cPedido
	MV_PAR03 := _cPedido
	MV_PAR13 := "4"

	DbSelectArea("SX1")
	If DbSeek(cPerg+"01",.F.)
		RecLock("SX1",.F.)
		SX1->X1_PRESEL := 2
		MsUnLock()
	EndIf
	If DbSeek(cPerg+"02",.F.)
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := _cPedido
		MsUnLock()
	EndIf
	If DbSeek(cPerg+"03",.F.)
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := _cPedido
		MsUnLock()
	EndIf
	If DbSeek(cPerg+"13",.F.)
		RecLock("SX1",.F.)
		SX1->X1_CNT01 := "4"
		MsUnLock()
	EndIf

EndIf

Pergunte(cPerg,.T.)

DbSelectArea("SC5")
DbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If MV_PAR01 == 1
	limite      := 220 //132
	tamanho     := "G" // "M"
EndIf

If nLastKey == 27
	Return
Endif

If MV_PAR01 == 1
	limite      := 220
	tamanho     := "G"
	aReturn[4]  := 1
	//	MV_PAR12    := 1
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

if ((val(Mv_Par03) - val(Mv_Par02)) >= GetNewPar('ZZ_LCDFATR', 100))
	Alert('Limite de ' + cValToChar(GetNewPar('ZZ_LCDFATR', 100)) + ' pedidos para emissao do relat?rio!')
else
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
endif

Return(.T.)

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////
	local aGrp1		:= {}
	local nPos1		:= 0
	local oPedMdl	:= nil
	Local _nPosFisRet	:= 0
	Local aDadInd 		:= {}
	local nTotPvc		:= 0
	local aInfAcond		:= {}
	local _nFator		:= 0, _nFator2 := 0
	Private _nLi 		:= 80
	Private _nTotGSit 	:= 0
	Private _cProduto 	:= Space(15)
	Private _nTotMt 	:= 0
	Private _nValTot	:= 0
	Private _nValTab	:= 0
	

	_cStatus := Str(MV_PAR13-1,1)

	DbSelectArea("SF4")
	DbSetOrder(1)  // F4_FILIAL+F4_CODIGO

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SA2") // SE FOR PEDIDO DE DEVOLU??O
	DbSetOrder(1)  //A2_FILIAL+A2_COD+A2_LOJA

	DbSelectArea("SC6")
	DBOrderNickName("SC6NUM")
	//DbSetOrder(9)  //C6_FILIAL+C6_NUM+C6_PRODUTO+C6_ITEM

	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM
	_nVias := Max(1,If(Mv_Par01==1,1,MV_PAR05))
	For _xVias := 1 To _nVias
		m_pag    := 01
		_nLi     := 80
		_nTotMt  := 0
		_nValTot := 0
		_nValTab := 0
		SetRegua(RecCount())
		DbSeek(xFilial("SC5")+Mv_Par02,.T.)
		Do While SC5->C5_NUM <= Mv_Par03 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())
			oPedMdl :=  cbcModOrder():newcbcModOrder(SC5->(C5_NUM), , ,FwFilial(),)
			IncRegua()

			If lAbortPrint
				@ _nLi,00 PSay "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If SC5->C5_EMISSAO < Mv_Par06 .Or. SC5->C5_EMISSAO > Mv_Par07 .Or. SC5->C5_CLIENTE < Mv_Par08 .Or. SC5->C5_CLIENTE > Mv_Par10 .Or. SC5->C5_LOJACLI < Mv_Par09 .Or. SC5->C5_LOJACLI > Mv_Par11

				DbSelectArea("SC5")
				DbSkip()
				Loop
			EndIf

			If cModulo == "EST" .And. SC5->C5_ZSTATUS # _cStatus .And. _cStatus < "3"
				// 0=Normal;1=Em Separac?o;2=Em Faturamento
				If FWCodEmp()+FWCodFil() == "0101"
					aGrp1 := FWSFUsrGrps(RetCodUsr())
					nPos1 := AScan(aGrp1,{|a| a == GRP_EXPED_ITU })
					If nPos1 > 0
						RecLock("SC5",.F.)
						SC5->C5_ZSTATUS := _cStatus
						MsUnLock()
					EndIf
				Else
					RecLock("SC5",.F.)
					SC5->C5_ZSTATUS := _cStatus
					MsUnLock()
				EndIf
			EndIf

			If MV_PAR01 == 1
				_nPosFisRet := 0
				MaFisSave()
				MaFisEnd()

				MaFisIni(SC5->C5_CLIENTE,;			// 1-Codigo Cliente/Fornecedor
				SC5->C5_LOJACLI,;	    			// 2-Loja do Cliente/Fornecedor
				IIf(SC5->C5_TIPO $ "DB","F","C"),;	// 3-C:Cliente , F:Fornecedor
				SC5->C5_TIPO,;						// 4-Tipo da NF
				SC5->C5_TIPOCLI,;					// 5-Tipo do Cliente/Fornecedor
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				"MATA461")
			EndIf

			// Vamos fazer leituras em tabelas diferentes.... conforme o teor do relat?rio MV_PAR04
			// INICIO

			If MV_PAR01 == 2 .And. (MV_PAR04 == 3 .Or. MV_PAR04 == 4)   // Se for Ordens de Separa?ao E (Separados - Lemos a tabela SDC ou Faturados - Lemos a tabela SD2)
				If MV_PAR04 == 3 // Separados
					DbSelectArea("SDC")
					DBOrderNickName("SDCPED") // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
					DbSeek(xFilial("SDC")+SC5->C5_NUM,.F.)
					_Loop1 := 'SDC->DC_FILIAL+SDC->DC_PEDIDO == xFilial("SDC")+SC5->C5_NUM .And. SDC->(!Eof())'
				Else //MV_PAR04 == 4 - Faturados
					DbSelectArea("SDB")
					DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM

					DbSelectArea("SD2")
					DbSetOrder(8) // D2_FILIAL+D2_PEDIDO+D2_ITEMPV
					DbSeek(xFilial("SD2")+SC5->C5_NUM,.F.)
					Do While SD2->D2_FILIAL+SD2->D2_PEDIDO == xFilial("SD2")+SC5->C5_NUM .And. SD2->(!Eof())

						// Inclu?da esta vari?vel em virtude da rotina de envio para sucata das tabelas C,D e Z.
						If Type("SD2->D2_TESORI") == "C"
							_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
						Else
							_cTesReal := SD2->D2_TES
						EndIf

						If Posicione("SF4",1,xFilial("SF4")+_cTesReal,"F4_ESTOQUE") == "S"
							Exit
						EndIf
						SD2->(DbSkip())
					EndDo
					_Loop1 := 'SD2->D2_FILIAL+SD2->D2_PEDIDO == xFilial("SD2")+SC5->C5_NUM .And. SD2->(!Eof())'
				EndIf

				_nTotVen := 0.00
				_nTotCus := 0.00
				_nTotPes := 0.00
				nTotPvc	 := 0.00

				If Eof() // Pode ser EOF do SDC ou do SD2 ->Verificar se n?o tem nada no SC9
					// Verificar se n?o tem no SC9 produtos que estejam liberados mas n?o tem controle de localiza??o
					If MV_PAR01 == 2 .And. MV_PAR04 == 3  // Se for Ordens de Separa?ao E Separados - Lemos a tabela SC9 dos que n?o controla localiza??o
						DbSelectArea("SC6")
						DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

						DbSelectArea("SB1")
						DbSetOrder(1) // B1_FILIAL+B1_COD

						DbSelectArea("SC9")
						DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
						DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.)
						_lTem := .F.
						Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
							If Empty(SC9->C9_BLCRED+SC9->C9_BLEST)
								SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO,.F.))
								If SB1->B1_LOCALIZ # "S"
									_cTES := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
									If Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_ESTOQUE") == "S"
										_lTem := .T.
										Exit
									EndIf
								EndIf
							EndIf
							SC9->(DbSkip())
						EndDo
						If !_lTem
							DbSelectArea("SC5")
							DbSkip()
							Loop                               `
						EndIf
					Else
						DbSelectArea("SC5")
						DbSkip()
						Loop                               `
					EndIf
				EndIf

				If _nLi > 60
					Titulo := getTit()
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					_nLi := 7
					//ImprCabec()
					u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
				Endif

				_aItens := {}	// {1-Produto   ,2-localiz,3-quant                     ,4-VALOR TOTAL,
				//  5-peso cobre,6-???    ,7-ITEM DO PEDIDO DE VENDA   ,8-Tipo da Bobina,
				//  9-Num.Da Bobina   10-Peso da Bobina 11-Quant.Caixas,12-Local
				//			_cPedsIt :=""
				Do While &_Loop1. // Pode ser no SD2 ou no SDC
					//_Loop1 := 'SD2->D2_FILIAL+SD2->D2_PEDIDO == xFilial("SD2")+SC5->C5_NUM .And. SD2->(!Eof())'
					//_Loop1 := 'SDC->DC_FILIAL+SDC->DC_PEDIDO == xFilial("SDC")+SC5->C5_NUM .And. SDC->(!Eof())'

					If MV_PAR04 == 4
						// Inclu?da esta vari?vel em virtude da rotina de envio para sucata das tabelas C,D e Z.
						If Type("SD2->D2_TESORI") == "C"
							_cTesReal := PadR(AllTrim(SD2->D2_TESORI+SD2->D2_TES),Len(SD2->D2_TES))
						Else
							_cTesReal := SD2->D2_TES
						EndIf

						If Posicione("SF4",1,xFilial("SF4")+_cTesReal,"F4_ESTOQUE") # "S"
							SD2->(DbSkip())
							Loop
						EndIf

						// Incluida nova pesquisa no SDB em virtude dos envios para sucata
						For _nVez := 1 to 2
							DbSelectArea("SDB")
							If _nVez == 1
								DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
								DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE,.F.)
								_cLoopDB := 'SDB->(DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE) == xFilial("SDB")+SD2->(D2_COD+D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE) .And. SDB->(!Eof())'
							Else
								DbSetOrder(7) // DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID
								_DocSuc := "RM"+SD2->D2_NUMSEQ
								DbSeek(xFilial("SDB")+SD2->D2_COD+_DocSuc,.F.)
								_cLoopDB := 'SDB->(DB_FILIAL+DB_PRODUTO+Left(DB_DOC,8))== xFilial("SDB")+SD2->D2_COD+_DocSuc .And. SDB->(!Eof())'
							EndIf
							Do While &_cLoopDB.
								nPos :=  aScan(_aItens,{|x| x[1]+x[2]+x[7]+x[12]==SDB->DB_PRODUTO+SDB->DB_LOCALIZ+SD2->D2_ITEMPV+SDB->DB_LOCAL})
								If nPos == 0
									Aadd(_aItens,{SDB->DB_PRODUTO,SDB->DB_LOCALIZ,0.0,0.00,0.00,0.00,SD2->D2_ITEMPV,"","",0,0,SDB->DB_LOCAL})
									nPos :=  Len(_aItens)
								EndIf
								_aItens[nPos,3] += SDB->DB_QUANT
								_aItens[nPos,4] += (SDB->DB_QUANT * SD2->D2_PRCVEN)
								_aItens[nPos,5] += SDB->DB_QUANT * Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO,"B1_PESCOB")
								SDB->(DbSkip())
							EndDo
						Next
						SD2->(DbSkip())
					Else
						If SDC->DC_ORIGEM # "SC6"
							SDC->(DbSkip())
							Loop
						EndIf

						//Filtra Armaz?m  ... OK
						If cModulo == "EST" .And. ;
						(;
						(MV_PAR14=="10".And.SDC->DC_LOCAL#"10").Or.;
						(MV_PAR14#"10".And.SDC->DC_LOCAL=="10");
						)

							SDC->(DbSkip())
							Loop
						EndIf
						// Se for Bobina, Buscar o peso no SZE
						_nTotEmb:= 0
						_nQtCxa   := 0
						_cTpBob := ""
						_aNumBob := {} // {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se j? usado}
						_nQtdLc := SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,15))

						//If Left(SDC->DC_LOCALIZ,1) == "B" .And. !(SDC->DC_PEDIDO+SDC->DC_PEDIDO+SDC->DC_ITEM $ _cPedsIt)
						If Left(SDC->DC_LOCALIZ,1) == "B"
							// _cPedsIt := _cPedsIt  + "/" + SDC->DC_PEDIDO+SDC->DC_PEDIDO+SDC->DC_ITEM
							// Como estou olhando bobinas e o loop principal ? pelo SDC, pode ocorrer de ter mais de
							// um SDC para a mesma chave FILIAL+PEDIDO+ITEM e ai dar inconsist?ncia no relat?rio, ainda mais,
							// podemos ter bobinas diferentes para o mesmo item.
							// Assim sendo, como a chave do SDC ? espec?fica DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
							// (nickname SDCPED) vou fazer outro loop no SDC agora incluindo o campo DC_LOCALIZ
							//
							SC9->(DbSetOrder(1))  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

							_nQtdLc := 0 // Aqui eu Zero pois vou fazer um loop no SDC
							_nUltReg := SDC->(Recno())
							_cChvSDC := SDC->DC_PEDIDO+SDC->DC_ITEM
							_aDadSDC := {} // {Acondic,Quantidade,QtdLance}
							Do While SDC->DC_FILIAL == xFilial("SDC") .And. Left(SDC->DC_LOCALIZ,1) == "B" .And. ;
							SDC->DC_PEDIDO+SDC->DC_ITEM == _cChvSDC .And. SDC->(!Eof())
								_nUltReg := SDC->(Recno())
								If SDC->DC_ORIGEM == "SC6" // Somente os liberados para faturamento
									//								SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO,.F.))
									//								If SC9->C6_CTRLE ==
									nPos :=  aScan(_aDadSDC,{|x| x[1]==SDC->DC_LOCALIZ})
									If nPos == 0
										Aadd(_aDadSDC,{SDC->DC_LOCALIZ,0,0}) // {Acondic,Quantidade,QtdLance}
										nPos := Len(_aDadSDC)
									EndIf
									_aDadSDC[nPos,2] += SDC->DC_QUANT
									_aDadSDC[nPos,3] += (SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,15)))
								EndIf
								SDC->(DbSkip())
							EndDo
							SDC->(DbGoTo(_nUltReg)) // Sai do poss?vel EOF e vai pro ultimo registro desse PEDIDO+ITEM

							DbSelectArea("SZE")
							SZE->(DbSetOrder(3)) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
							DbSeek(xFilial("SZE")+"E"+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.) // Bobinas empenhadas nesse pedido
							Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->(!Eof()) .And.;
							SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM == "E"+SDC->DC_PEDIDO+SDC->DC_ITEM

								// Verificar se ? do mesmo controle
								_nTotEmb += (SZE->ZE_TARA+SZE->ZE_PLIQ)
								// Elementos da _aNumBob
								// {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se j? usado}

								Aadd(_aNumBob,{PadR("B"+StrZero(SZE->ZE_QUANT,5),Len(SDC->DC_LOCALIZ)),;
								SZE->ZE_NUMBOB,;
								(SZE->ZE_TARA+SZE->ZE_PLIQ),;
								SZE->ZE_TPBOB,;
								" "}) // {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se j? usado}
								If !SZE->ZE_TPBOB $ _cTpBob
									_cTpBob := _cTpBob + SZE->ZE_TPBOB
								EndIf
								SZE->(DbSkip())
							EndDo

							// Aten??o: Outros lugares tamb?m fazem o mesmo c?lculo

						ElseIf AllTrim(SDC->DC_LOCALIZ) == "R00015" // Rolo de 15 metros
							// Se for rolo de 15 Encartelado
							_nRolCx := 0
							If Left(SDC->DC_PRODUTO,3) == "115"  // Cabo Flexicom
								If Substr(SDC->DC_PRODUTO,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 v?o 10 rolos por caixa
									_nRolCx := 10
								ElseIf Substr(SDC->DC_PRODUTO,4,2) $ "06/07" //Se for cabo flex 4 ou 6     v?o 08 rolos por caixa
									_nRolCx := 8
								ElseIf Substr(SDC->DC_PRODUTO,4,2) == "08" //Se for cabo flex 10         v?o 06 rolos por caixa
									_nRolCx := 6
								EndIf
							ElseIf Left(SDC->DC_PRODUTO,3) == "120"  .And. Substr(SDC->DC_PRODUTO,4,2) $ "04/05"// Cord?o Paralelo 1,5 ou 2,5
								_nRolCx := 8
							EndIf
							_nQtCxa   := Int(_nQtdLc/_nRolCx)
							_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unit?rio do conjunto de ilh?s em gramas
							_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unit?rio do saco plastico     em gramas
							_nCart    := (_nQtdLc*8.5232)/1000        // Peso unit?rio da cartela de papel  em gramas
							_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unit?rio da caixa de papel?o  em kilos
							_nTotEmb  := (_nIlhos+_nSaco+_nCart+_nCaixa)
						ElseIf Left(SDC->DC_LOCALIZ,1) == "L" // Blister
							aInfAcondi := u_cbcAcInf(Alltrim(SDC->DC_PRODUTO), AllTrim(SDC->DC_LOCALIZ), , _nQtdLc, , .T., .F.,.T.)
							_nQtCxa	   := aInfAcondi[3,1]
							_nTotEmb   := aInfAcondi[2,2]
						ElseIf Left(SDC->DC_LOCALIZ,1) == "M" // Carretel
							_nTotEmb := (_nQtdLc*1.45)
						ElseIf Left(SDC->DC_LOCALIZ,1) == "C" // Carretel
							_nTotEmb := (_nQtdLc*2.00)
						EndIf

						_nVlrUnit := Posicione("SC6",1,xFilial("SC6")+SDC->DC_PEDIDO+SDC->DC_ITEM,"C6_PRCVEN")

						If Left(SDC->DC_LOCALIZ,1) == "B"
							// Adicionar as bobinas uma a uma observando se n?o tem bobina suficiente ou
							// se tem mais bobinas que a qtd de lances

							For _nLoop1 := 1 to Len(_aDadSDC) // _aDadSDC -> {Acondic,Quantidade,QtdLance}

								// Elementos de _aDadSDC
								// {1 Acondic,   2-Quantidade, 3-QtdLance}
								For _nLoop2 := 1 To _aDadSDC[_nLoop1,3]
									// Elementos de _aItens
									// {1-Produto,   2-localiz,3-quant,                  4-VALOR TOTAL,
									//  5-peso cobre,6-???,    7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina}
									// Aten??o: Para bobinas ainda em mais elementos
									//  9-Num.Da Bobina   10-Peso da Bobina 11-Quant.Caixas

									_nQtItem := (_aDadSDC[_nLoop1,2]/_aDadSDC[_nLoop1,3])
									Aadd(_aItens,{	SDC->DC_PRODUTO,_aDadSDC[_nLoop1,1],_nQtItem,(_nQtItem*_nVlrUnit),;
									(_nQtItem*Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")),;
									0.00,SDC->DC_ITEM," ","BOB.NAO LOCALIZ",0,0,SDC->DC_LOCALIZ})

									// Atrelar uma bobina ao Item
									// Elementos da _aNumBob
									// {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se j? usado}
									For _nLoop3 := 1 To Len(_aNumBob)
										If _aNumBob[_nLoop3,1] == _aItens[Len(_aItens),2] .And. Empty(_aNumBob[_nLoop3,5])
											// Mesmo acondicionamento?
											_aItens[Len(_aItens),08] := _aNumBob[_nLoop3,4] // Tipo da Bobina
											_aItens[Len(_aItens),09] := _aNumBob[_nLoop3,2] // Numero da Bobina
											_aItens[Len(_aItens),10] := _aNumBob[_nLoop3,3] // Peso da bobina
											_aNumBob[_nLoop3,5]      := "X"
											Exit
										EndIf
									Next
								Next
							Next
						Else

							nPos :=  aScan(_aItens,{|x| x[1]+x[2]+x[7]+x[12]==SDC->DC_PRODUTO+SDC->DC_LOCALIZ+SDC->DC_ITEM+SDC->DC_LOCAL})
							If nPos == 0
								Aadd(_aItens,{SDC->DC_PRODUTO,SDC->DC_LOCALIZ,0.0,0.00,0.00,;
								0.00,SDC->DC_ITEM,"","",0,0,SDC->DC_LOCAL})
								nPos :=  Len(_aItens)
							EndIf
							_aItens[nPos,3] += SDC->DC_QUANT
							_aItens[nPos,4] += (SDC->DC_QUANT * _nVlrUnit)
							_aItens[nPos,5] += SDC->DC_QUANT * Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")
							_aItens[nPos,6] += _nTotEmb
							_aItens[nPos,11] += _nQtCxa // Quantidade de caixas

							If !Empty(_cTpBob)
								_cTpBob += _aItens[nPos,8]
								_aItens[nPos,8] := ""
								For _x1 := 1 to 7
									_cx1 := Str(_x1,1)
									If _cx1 $ _cTpBob
										_aItens[nPos,8] += _cx1
									EndIf
								Next
							EndIf
						EndIf
					EndIf
					SDC->(DbSkip())
				EndDo

				// Verificar se n?o tem no SC9 produtos que estejam liberados mas n?o tem controle de localiza??o
				If MV_PAR01 == 2 .And. MV_PAR04 == 3    // Se for Ordens de Separa?ao E Separados - Lemos a tabela SC9 dos que n?o controla localiza??o
					DbSelectArea("SC6")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

					DbSelectArea("SB1")
					DbSetOrder(1) // B1_FILIAL+B1_COD

					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())

						//Filtra Armaz?m      OK
						If cModulo == "EST" .And. ;
						(;
						(MV_PAR14=="10".And.SC9->C9_LOCAL#"10").Or.;
						(MV_PAR14#"10".And.SC9->C9_LOCAL=="10");
						)

							SC9->(DbSkip())
							Loop
						EndIf

						If Empty(SC9->C9_BLCRED+SC9->C9_BLEST)
							SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO,.F.))
							If SB1->B1_LOCALIZ # "S"
								_cTES := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
								If Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_ESTOQUE") == "S"
									nPos :=  aScan(_aItens,{|x| x[1]+x[2]+x[7]+x[12]==SC9->C9_PRODUTO+Space(Len(SDC->DC_LOCALIZ))+SC9->C9_ITEM+SC9->C9_LOCAL})
									If nPos == 0
										Aadd(_aItens,{SC9->C9_PRODUTO,Space(Len(SDC->DC_LOCALIZ)),0.0,;
										0.00,0.00,0.00,SC9->C9_ITEM,"","",0,0,SC9->C9_LOCAL})
										nPos :=  Len(_aItens)
									EndIf
									_nVlrUnit := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_PRCVEN")
									_aItens[nPos,3] += SC9->C9_QTDLIB
									_aItens[nPos,4] += (SC9->C9_QTDLIB * _nVlrUnit)
									_aItens[nPos,5] += SC9->C9_QTDLIB * SB1->B1_PESCOB
								EndIf
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo
				EndIf

				_nValTot  := 0
				_nValTab  := 0
				_nPesoTot := 0
				_nTotPes  := 0
				nTotPvc	  := 0
				_nTotVen  := 0

				aSort(_aItens,,,{|x,y| x[1]+x[2]+x[12]<y[1]+y[2]+y[12]})
				For _nx := 1 to Len(_aItens)

					If !Empty(_cProduto) .And. Left(_cProduto,5) # Left(_aItens[_nx,1],5)
						If _nTotMt > 0 .And. Mv_Par01 == 2
							@ _nLi,043 PSay "Soma de Rolos ->"
							@ _nLi++,062 PSay _nTotMt	Picture "@E 99,999,999"
							_nTotMt := 0
						EndIf
						If !lImpCb
							@ _nLi,000 PSay Replicate("-",limite)
							_nLi++
						Else
							lImpCb := .F.
						EndIf
						_cProduto := _aItens[_nx,1]
					Else
						_cProduto := _aItens[_nx,1]
					EndIf

					@ _nLi,000 PSay _aItens[_nx,7]
					@ _nLi,005 PSay _aItens[_nx,1] 		Picture "@R XXX.XX.XX.X.XX"
					@ _nLi,020 PSay Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_DESC")),42)

					If lImpCb
						lImpCb := .F.
					EndIf

					_cAcondic := " "
					If Left(_aItens[_nx,2],1)=="R"
						_cAcondic := If(Mv_Par01 == 1," ","Rolo")
					ElseIf Left(_aItens[_nx,2],1)=="B"
						_cAcondic := "Bobina"
					ElseIf Left(_aItens[_nx,2],1)=="M"
						_cAcondic := "Carretel Mad."
					ElseIf Left(_aItens[_nx,2],1)=="C"
						_cAcondic := "Carretel N8"
					ElseIf Left(_aItens[_nx,2],1)=="T"
						_cAcondic := "Retalho"
					ElseIf Left(_aItens[_nx,2],1)=="L"
						_cAcondic := "Blister"
					EndIf

					_nMetrage := Val(Alltrim(Substr(_aItens[_nx,2],2,20)))
					_nQtLance := Max(Int(Round((_aItens[_nx,3] / _nMetrage),0)),1)

					@ _nLi,063 PSay _aItens[_nx,3]		Picture "@E 9,999,999"
					@ _nLi,073 PSay _nQtLance			Picture "@E 999999"
					@ _nLi,080 PSay "X"
					@ _nLi,083 PSay _nMetrage	 		Picture "@E 99999"
					@ _nLi,089 PSay _cAcondic

					_nPesoInd := (_aItens[_nx,3]* Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_PESO"))
					//				_nPesoInd := Int((_aItens[_nx,3]* Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_PESO")))
					//				_nPesoInd := Int((_aItens[_nx,3]* Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_PESCOB")))

					If MV_PAR04 == 3 // Separados
						If Left(_aItens[_nx,2],1)=="B" // Se for Bobina, o peso no array 6 ? total
							_nPesoInd := _aItens[_nx,10]
						Else // Sen?o, se tiver peso no array 6, somar ao peso j? calculado
							_nPesoInd += _aItens[_nx,6]
						EndIf
					EndIf

					@ _nLi,102 PSay _nPesoInd Picture "@E 999999.99"

					If cModulo == "EST" .And. MV_PAR04 == 3 // Separados
						If _aItens[_nX,11] > 0 // Quantidade de Caixas
							@ _nli,112 PSay _aItens[_nx,11] Picture "@E 999"
							@ _nli,116 PSay "Caixa"+If(_aItens[_nx,11]>1,"s","")
						Else
							@ _nli,115 PSay  _aItens[_nx,8]
							If Left(_aItens[_nx,2],1)=="B" // Se for Bobina, o peso no array 6 ? total
								If Len(AllTrim(_aItens[_nx,9])) > 7
									@ _nli,116 PSay  _aItens[_nx,9]
								Else
									@ _nli,123 PSay  _aItens[_nx,9]
								EndIf
							EndIf
						EndIf
					ElseIf cModulo == "EST"
						@ _nLi,128 PSay _aItens[_nx,12] Picture "XX"
					ElseIf cModulo == "FAT" .Or. _lGpo
						@ _nLi,112 PSay _aItens[_nx,4] Picture "@E 9,999,999.99"
						@ _nLi,128 PSay _aItens[_nx,12] Picture "XX"
					EndIf
					_nPesoTot += _nPesoInd

					_nFator := _aItens[_nx,4] / _aItens[_nx,5]
					_nTotPes += _aItens[_nx,5]
					_nTotVen += _aItens[_nx,4]

					If Left(_aItens[_nx,2],1)=="R"
						_nTotMt += _aItens[_nx,3]
					EndIf

					_nLi++

					If _nLi > 60
						Titulo := getTit()
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 7
						u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
					Endif
				Next

				_cProduto := Space(15)

				@ _nLi,000 PSay Replicate("-",limite)
				_nLi++

				If _nTotMt > 0
					@ _nLi,043 PSay "Soma de Rolos ->"
					@ _nLi,062 PSay _nTotMt	Picture "@E 99,999,999"
					_nTotMt := 0
				EndIf
				@ _nLi,082 PSay "PESO TOTAL (Kg)"
				@ _nLi,098 PSay _nPesoTot   Picture "@E 999,999.99"

				_nFator := _nTotVen / _nTotPes
				If cModulo == "FAT" .Or. _lGpo
					@ _nLi,110 PSay  _nTotVen Picture "@E 9999,999.99"
				Endif

				//@ _nLi,123 PSay  _nFator Picture "@E 999.99"

				If AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
					@ ++_nLi,082 PSay "VALOR TOTAL R$)"
					@ _nLi,098 PSay _nTotVen   Picture "@E 999,999.99"
				EndIf                                              R

				_nLi+=2

				@ _nLi,00 PSay "Cadastro Original: "+SC5->C5_USERINC
				@ _nLi,35 PSay "Cadastro Alterado: "+SC5->C5_USERALT

				_nLi++

				@ _nLi,00 PSay DToC(SC5->C5_DTINC)
				@ _nLi,35 PSay DToC(SC5->C5_DTALT)
				_nLi+=2

				If Mv_Par01 == 1
					@ _nLi,00 PSay "Conferido: __________________________________"
					@ _nLi,50 PSay "Data: ______/______/________"
				EndIf

				If Mv_Par01 == 2  //Ordem de Separa??o
					If _nLi > 55
						Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 7
						//ImprCabec()
						u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
					EndIf
					_nLi := 59
					@ _nLi++,01 PSay Replicate("-",130)
					@ _nLi++,01 PSay "|       EMISSAO            |       SEPARADO POR        |       ENSACADO POR      |     CONFERIDO POR     |    NOME MOTORISTA     |"
					@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
					@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
					@ _nLi++,01 PSay "|   _____/______/______    |    _____/______/______    |   _____/______/______   |  _____/______/______  |  _____/______/______  |"
					@ _nLi++,01 PSay Replicate("-",130)

					If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))
						Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 9
						u_ChkLstHWEI() // Se tiver laudo para HUAWEI esta fun??o tbm imprime
					ElseIf SC5->C5_LAUDO == "S"
						u_ChkLstLaud()
					EndIf
				EndIf
				_nLi+=60
			ElseIf MV_PAR01 == 1 .Or. MV_PAR04 == 1 .Or. MV_PAR04 == 2  // Se for pedido de Vendas ou Ord.Sep. por saldo ou n?o separados
				// Preciso saber se o pedido est? na situa??o do MV_PAR04
				_TemMov := .T.
				_nTotVen := 0.00
				_nTotCus := 0.00
				_nTotPes := 0.00
				nTotPvc	 := 0.00
				_nTotCom := 0.00
				If MV_PAR01 == 2 //.And. MV_PAR04 # 1
					_TemMov := .F.
					DbSelectArea("SC9")
					DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9") + SC5->C5_NUM,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof()) .And. !_TemMov

						If SC9->C9_FILIAL # "02" .Or. ;
						(SC9->C9_FILIAL == "02" .And. ;
						(;
						(MV_PAR14 #  "10" .And. SC9->C9_LOCAL == "10") .Or. ;
						(MV_PAR14 == "10" .And. SC9->C9_LOCAL #  "10") ;
						);
						)

							If MV_PAR04 == 1 .And. SC9->C9_BLEST # "10"       	// Saldo a Faturar
								_TemMov := .T.
							ElseIf MV_PAR04 == 2 .And. SC9->C9_BLEST == "02"       	// N?o Separados
								_TemMov := .T.
							ElseIf MV_PAR04 == 3  .And. Empty(SC9->C9_BLEST)   	// Separados
								_TemMov := .T.
							ElseIf MV_PAR04 == 4 .And. !Empty(SC9->C9_NFISCAL) 	// Faturados
								If Posicione("SF4",1,xFilial("SF4")+SC9->C9_TES,"F4_ESTOQUE") == "S" .Or. Empty(SC9->C9_TES)
									_TemMov := .T.
								EndIf
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo
				EndIf

				If !_TemMov
					DbSelectArea("SC5")
					DbSkip()
					Loop
				EndIf

				_nValTot  := 0
				_nValTab  := 0
				_nPesoTot := 0
				_nVal2_5  := 0
				_nTotPV   := 0
				_nComis   := 0
				_nIndCsMp := 0.00 // Somente custo do Cobre + PVC
				_nTotMet := 0


				DbSelectArea("SC6")
				DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
				Do While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
					_nTotPV += SC6->C6_VALOR
					SC6->(dbSkip())
				EndDo

				If _nLi > 60
					Titulo := getTit()
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					_nLi := 7
					//ImprCabec() //1RA VEZ
					u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
				Endif

				DbSelectArea("SC6")
				DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
				Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM .And. SC6->(!Eof())
					_TemMov := .T.
					If MV_PAR01 == 2
						//			If MV_PAR04 == 1
						//				_nQtdSit := SC6->C6_QTDVEN
						//			Else
						_nQtdSit := 0
						_TemMov := .F.
						DbSelectArea("SC9")
						DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
						DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ,.F.)
						Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And.;
						SC9->C9_ITEM == SC6->C6_ITEM .And. SC9->(!Eof())

							If SC9->C9_FILIAL # "02" .Or.;
							( ;
							SC9->C9_FILIAL == "02" .And.;
							(;
							(MV_PAR14 #  "10" .And. SC9->C9_LOCAL == "10") .Or.;
							(MV_PAR14 == "10" .And. SC9->C9_LOCAL #  "10");
							);
							)

								If MV_PAR04 == 1 .And. SC9->C9_BLEST #  "10"       // Saldo do Pedido
									_TemMov := .T.
									_nQtdSit += SC9->C9_QTDLIB
								ElseIf MV_PAR04 == 2 .And. SC9->C9_BLEST == "02"       // N?o Separados
									_TemMov := .T.
									_nQtdSit += SC9->C9_QTDLIB
								ElseIf MV_PAR04 == 3  .And. Empty(SC9->C9_BLEST)   // Separados
									_TemMov := .T.
									_nQtdSit += SC9->C9_QTDLIB
								ElseIf MV_PAR04 == 4 .And. !Empty(SC9->C9_NFISCAL) // Faturados
									If Posicione("SF4",1,xFilial("SF4")+SC9->C9_TES,"F4_ESTOQUE") == "S" .Or. Empty(SC9->C9_TES)
										_TemMov := .T.
										_nQtdSit += SC9->C9_QTDLIB
									EndIf
								EndIf
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf

					If !_TemMov
						DbSelectArea("SC6")
						DbSkip()
						Loop
					EndIf

					If !Empty(_cProduto) .And. Left(_cProduto,5) # Left(SC6->C6_PRODUTO,5)
						If _nTotMt > 0 .And. Mv_Par01 == 2
							@ _nLi,043 PSay "Soma de Rolos ->"
							@ _nLi++,062 PSay _nTotMt	Picture "@E 99,999,999"
							_nTotMt := 0
						EndIf
						If !lImpCb
							@ _nLi,000 PSay Replicate("-",limite)
							_nLi++
						Else
							lImpCb := .F.
						EndIf
						_cProduto := SC6->C6_PRODUTO
					Else
						_cProduto := SC6->C6_PRODUTO
					EndIf

					If MV_PAR01 == 2
						@ _nLi,000 PSay SC6->C6_ITEM
						@ _nLi,005 PSay SC6->C6_PRODUTO 		Picture "@R XXX.XX.XX.X.XX"
						@ _nLi,020 PSay Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")),42)
					Else
						@ _nLi,000 PSay SC6->C6_PRODUTO 		Picture "@R XXX.XX.XX.X.XX"
						@ _nLi,015 PSay Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")),42)
					Endif

					If lImpCb
						lImpCb := .F.
					EndIf

					_cAcondic := Transform(SC6->C6_LANCES,"@E 9,999") + " x " +SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)
					If Mv_Par01 == 1
						@ _nLi,058 PSay SC6->C6_QTDVEN  		Picture "@E 9,999,999"
						@ _nLi,068 PSay SC6->C6_PRCVEN  		Picture "@E 9999.9999"

						If Mv_Par12 == 1
							// Posiciona SB1
							SB1->(DbSetOrder(1))
							SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))

							// Recalcula o LB/TGT/RG rsrs ? tudo a mesma coisa
							If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
								_nCustd   := SB1->B1_CUSTD3L
							Else
								_nCustd   := SB1->B1_CUSTD
							EndIf

							_nPescob  := SB1->B1_PESCOB * SC6->C6_QTDVEN
							nTotPvc	  += SC6->(C6_XFTPVC) * SC6->(C6_QTDVEN)
							_nFator  := (SC6->C6_QTDVEN * SC6->C6_PRCVEN) / _nPescob //ESTE AQUI
							_nLUCROBR := Round(If(_nCustd==0,0,(((SC6->C6_PRCVEN*100)/_nCustd)-100)),2)
							_nTotVen += SC6->C6_QTDVEN * SC6->C6_PRCVEN
							_nTotCus += SC6->C6_QTDVEN * _nCustd
							_nTotCom += Round(((SC6->C6_QTDVEN * SC6->C6_PRCVEN) * SC6->C6_COMIS1) /100,2)
							_nTotPes += _nPescob
							_nTotMet += SC6->C6_QTDVEN

							_nIndice := SC6->C6_QTDVEN * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item

							// Verifica se o valor do cobre+pcv ? maior que 75% do valor do item
							_nVaric  := Round(((_nIndice / 75) * 100),2) //
							If _nVaric > SC6->C6_VALOR
								_nVaric := (_nVaric - SC6->C6_VALOR)
								_nVaric := Round(((_nVaric / SC6->C6_VALOR) * 100),2) // % a acrescentar no valor de venda para poder chegar a 75%
							Else
								_nVaric  := 0.00
							EndIf

							_nIndCsMp += _nIndice // Acumula o valor do Cobre e do PVC
							_nIndice := Round((_nIndice / SC6->C6_VALOR) * 100,2) // Calcula em Percentual
							// @ _nLi,078 PSay _nLUCROBR+GetMv("MV_X_TGT")		Picture "@E 9999.99"
							
							if lNewRg
								@ _nLi,078 PSay Round(oPedMdl:getRgItem(,SC6->(C6_ITEM)),2) Picture "@E 9999.99"
							else
								@ _nLi,078 PSay _nLUCROBR		Picture "@E 9999.99"
							endif
						
						EndIf

						@ _nLi,086 PSay SC6->C6_VALOR  		Picture "@E 999,999.99"
						@ _nLi,099 PSay _cAcondic

						_nPesoTot += SC6->C6_QTDVEN * Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PESO")
						If Left(SC6->C6_PRODUTO,5) $ "10105//11505" // Fio ou Flex 2,5mm
							_nVal2_5  += SC6->C6_VALOR
						EndIf

						If Mv_Par12 == 1
							@ _nli,114 PSay SC6->C6_COMIS1 Picture "@E 999.99"
							@ _nLi,121 PSay SC6->C6_TES
						EndIf

						_nPrcUnit := u_TabBruto(SC5->C5_TABELA,_cProduto,SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5))

						If _nPrcUnit == 0
							@ _nLi,126 PSay "??.??"
						Else
							_cDescs := u_ClcDesc(SC5->C5_TABELA,SC5->C5_VEND1,_cProduto,SC6->C6_PRCVEN,_nPrcUnit,Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_AVISTA"))
							////u_ClcDesc(	SC5->C5_TABELA	-> Tabela de Pre?os
							//				SC5->C5_VEND1	-> C?d do vendedor
							//				_cProduto		-> C?digo do Produto
							//				SC6->C6_PRCVEN	-> Pre?o de venda
							//				_nPrcUnit		-> Pre?o de Tabela / Bruto)
							// A fun??o ClcDesc retorna:
							// {1-Desc.Efetivo,2-Desc.Padr?o,3-% Comiss?o,4-% Min. Comiss?o,5-(*)Valor Minimo      }
							_cDescs := _cDescs[1]
							@ _nLi,125 PSay _cDescs
						EndIf

						If Mv_Par12 == 1
							//Imprimir o indice e a varia??o
							// @ _nLi,161 PSay _nIndice Picture "@E 9999.99"

							@ _nLi,155 PSay If(SC6->C6_PRCVEN<u_DescCasc(_nPrcUnit,StrTokArr(AllTrim(SC5->C5_DESCPAD),"+",.F.),TamSX3("CK_PRCVEN" )[2]),;
							"Desc.Maior"," ")


							@ _nLi,169 PSay _nVaric  Picture "@E 9999.99"
						EndIf

						If MV_PAR01 == 1
							// Calcula o ICM do item do pedido
							SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))

							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)

							_B1_ORIGEM := SB1->B1_ORIGEM
							If SB1->B1_ORIGEM # Left(SC6->C6_CLASFIS,1)
								RecLock("SB1",.F.)
								SB1->B1_ORIGEM := Left(SC6->C6_CLASFIS,1)
								MsUnLock()
							EndIf

							MaFisAdd(SC6->C6_PRODUTO,;	// 1-Codigo do Produto ( Obrigatorio )
							SC6->C6_TES,;	   			// 2-Codigo do TES ( Opcional )
							SC6->C6_QTDVEN,;		    // 3-Quantidade ( Obrigatorio )
							SC6->C6_PRCVEN,;   			// 4-Preco Unitario ( Obrigatorio )
							0,;                         // 5-Valor do Desconto ( Opcional )
							"",;	   				    // 6-Numero da NF Original ( Devolucao/Benef )
							"",;					    // 7-Serie da NF Original ( Devolucao/Benef )
							0,;     				    // 8-RecNo da NF Original no arq SD1/SD2
							0,;					 		// 9-Valor do Frete do Item ( Opcional )
							0,;					   		// 10-Valor da Despesa do item ( Opcional )
							0,;					 	    // 11-Valor do Seguro do item ( Opcional )
							0,;					    	// 12-Valor do Frete Autonomo ( Opcional )
							SC6->C6_VALOR,;  			// 13-Valor da Mercadoria ( Obrigatorio )
							0)						    // 14-Valor da Embalagem ( Opiconal )

							_nPosFisRet++  //Obrigatorio, pois deve se manter a estrutura do array no mafisadd

							_BaseIcm := MaFisRet(_nPosFisRet, "IT_BASEICM")
							_ValIcm  := MaFisRet(_nPosFisRet, "IT_VALICM")

							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)

							If SB1->B1_ORIGEM # _B1_ORIGEM
								RecLock("SB1",.F.)
								SB1->B1_ORIGEM := _B1_ORIGEM
								MsUnLock()
							EndIf

							_nPcIcm := (_ValIcm / _BaseIcm)*100
							@ _nLi,180 PSay _nPcIcm Picture "999"
							@ _nLi,186 PSay SC6->C6_LOCAL Picture "XX"
							//Altera??o Juliana Leme 20/10/2015
							@ _nLi,192 PSay SC6->C6_PEDCLI Picture "XXXXXXXXXXXXX"
							@ _nLi,208 PSay SC6->C6_ITPDCLI Picture "XXXXXXXX"
							@ _nLi,212 PSay SC6->C6_POSHPHU Picture "XXX"
						EndIf
					Else
						_nPescob  := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_PESCOB") * _nQtdSit
						nTotPvc	  += SC6->(C6_XFTPVC) * _nQtdSit
						_nFator   := (_nQtdSit * SC6->C6_PRCVEN) / _nPescob
						_nTotPes  += _nPescob
						_nTotVen  += (_nQtdSit * SC6->C6_PRCVEN)
						_nTotGSit += (_nQtdSit * SC6->C6_PRCVEN)
						_nTotSit  := (_nQtdSit * SC6->C6_PRCVEN)
						_nTotCom += Round(((_nQtdSit * SC6->C6_PRCVEN) * SC6->C6_COMIS1) /100,2)

						//@ _nLi,066 PSay SC6->C6_QTDVEN  		Picture "@E 99,999"
						_nQtLance  := Max(Int(Round((_nQtdSit / SC6->C6_METRAGE),0)),1)

						@ _nLi,063 PSay _nQtdSit		  		Picture "@E 9,999,999"
						@ _nLi,073 PSay If(SC6->C6_ACONDIC=="R",_nQtLance,SC6->C6_LANCES)  Picture "@E 999999"


						@ _nLi,080 PSay "X"
						@ _nLi,083 PSay SC6->C6_METRAGE 		Picture "@E 99999"
						@ _nLi,089 PSay _cAcondic

						_nPesoInd := (_nQtdSit*Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_PESO"))
						@ _nLi,102 PSay Int(_nPesoInd) Picture "@E 999999"

						_nPesoTot += _nPesoInd

						//###
						If MV_PAR01 == 2
							If cModulo == "FAT" .Or. _lGpo
								@ _nLi,108 PSay _nTotSit Picture "@E 9,999,999.99"
								@ _nLi,128 PSay SC6->C6_LOCAL Picture "XX"
							ElseIf cModulo == "EST" .And. MV_PAR04 # 3
								@ _nLi,128 PSay SC6->C6_LOCAL Picture "XX"
							Endif
						Endif

						//@ _nli,121 PSay  _nFator Picture "@E 999.99"

						If SC6->C6_ACONDIC=="R"
							_nTotMt += _nQtdSit
						EndIf
						//			@ _nLi,125 PSay _nQtdSit Picture "@EZ 99,999"
					EndIf

					_nValTot += SC6->C6_VALOR

					_nPrcUnit := u_TabBruto(SC5->C5_TABELA,_cProduto,SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5))

					If _nPrcUnit == 0
						_nValTab += (SC6->C6_QTDVEN * SC6->C6_PRUNIT)
					Else
						_nValTab += (SC6->C6_QTDVEN * _nPrcUnit)
					EndIf

					_nLi++

					If _nLi > 60
						Titulo := getTit()
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 7
						u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
					Endif

					DbSelectArea("SC6")
					DbSkip()
					//nTotGSit := 0
				EndDo

				_cProduto := Space(15)
				@ _nLi,000 PSay Replicate("-",limite)
				_nLi++

				If Mv_Par01 == 1
					If Mv_Par12==1 // N?o usar a clausula .AND. neste IF, para n?o afetar o ELSE abaixo
						_nIndice := Round(((_nIndCsMp / _nValTot) * 100),2)
						_nVaric  := Round(((_nIndCsMp / 75) * 100),2)
						If _nVaric > _nValTot
							_nVaric  := (_nVaric - _nValTot)
							_nVaric  := Round(((_nVaric / _nValTot) * 100),2)
						Else
							_nVaric  := 0.00
						EndIf

						@ _nLi,000 PSay "Fios/Flex 2,5: "
						@ _nLi,015 PSay Round((_nVal2_5/_nValTot) * 100,2) Picture "@E 999.99"
						@ _nLi,021 PSay "%"
						@ _nLi,026 PSay "Peso Total(PVC+Cob):"
						@ _nLi,047 PSay Transform(Int(_nPesoTot),"@E 999,999") + " kg"
						@ _nLi,081 PSay _nValTot  		Picture "@E 999,999,999.99"
						@ _nLi,099 PSay "Desc.Medio:"
						@ _nLi,111 PSay Round((((_nValTab - _nValTot) / _nValTab) * 100),2) Picture "@E 999.99"

						_nLi++
						_nKgKm := Round(((_nTotPes/_nTotMet)*1000),2)
					Else
						@ _nLi,085 PSay _nValTot  		Picture "@E 999,999.99"
						_nLi++
					EndIf
				Else
					If _nTotMt > 0
						@ _nLi,043 PSay "Soma de Rolos ->"
						@ _nLi,062 PSay _nTotMt	Picture "@E 99,999,999"
						_nTotMt := 0
					EndIf
					@ _nLi,077 PSay "Peso Total(PVC+Cob):"
					@ _nLi,098 PSay Transform(Int(_nPesoTot),"@E 9999,999") + " kg"

					_nFator := _nTotVen/_nTotPes
					If cModulo == "FAT" .Or. _lGpo
						@ _nLi,110 PSay _nTotGSit Picture "@E 99999,999.99"
					Endif
					_nLi++
				EndIf
				
				_nLi++

				@ _nLi,00 PSay "Cadastro Original: "+SC5->C5_USERINC
				@ _nLi,35 PSay "Cadastro Alterado: "+SC5->C5_USERALT
				If Mv_Par01 == 1 .And. Mv_Par12 == 1
					_nLUCROBR := Round((((_nTotVen/_nTotCus)*100)-100),2)

					if lNewRg
						@ _nLi,76 PSay "  RG = "+ Transform(Round(oPedMdl:getRgTotal(),2),"@E 9999.99")
					else
						@ _nLi,76 PSay "  RG = " + Transform(_nLUCROBR,"@E 9999.99")
					endif
					
					/* [LEO]- 01/02/17 - pedido Rafael/Jeferson ( Mudar forma de calculo fator PV ) */
					if empty( SC5->(C5_XFTCOBR) )
						_nFator2 := 0
					else
						_nFator2 := (( ( (_nTotPes * SC5->(C5_XFTCOBR) ) + nTotPvc ) / _nTotVen) * 100) // ESTE AQUI
					endif
					/*[LEO]- FIM*/
				
					@ _nLi,095 PSay "IMP: " + Transform(_nFator2,"@E 999.99") // ESTE AQUI

					_nPerCom := Round((_nTotCom/_nTotVen) * 100,2)
					@ _nLi,113 PSay "%Med.Com: " + Transform(_nPerCom,"@E 999.99")
					_nFator := _nTotVen/_nTotPes
					@ _nLi,140 PSay "Fator: " + Transform(_nFator,"@E 999.99")
				EndIf
				_nLi++

				@ _nLi,00 PSay DToC(SC5->C5_DTINC)
				@ _nLi,35 PSay DToC(SC5->C5_DTALT)
				_nLi+=2

				If Mv_Par01 == 1
					@ _nLi,00 PSay "Conferido: __________________________________"
					@ _nLi,50 PSay "Data: ______/______/________"
				EndIf

				//Coloca Observa??o no Laudo
				If SC5->C5_LAUDO == "S"
					_nLi++
					@ _nLi,00 PSay Replicate("-",limite)
					@ ++_nLi,000 PSay "ORIENTACOES: "
					@ ++_nLi,000 PSay "ATEN??O! NECESSARIO ENVIO DE LAUDO, FAVOR VERIFICAR! "
				EndIf

				//Inicializa a matriz com 30 posi??es
				aDadInd := Array(1,30)
				aDadInd := u_InfTrian(xFilial("SC5"),SC5->C5_NUM,"CDFATR01")

				If Len(aDadInd) = 0
					//Caso variavel esteja nula, esta com 30 posi??es
					aDadInd := Array(1,30)
				EndIf

				//Altera??o Juliana 20/07/2016
				_LocEnt := ""
				If !Empty(Alltrim(SC5->C5_ENDENT1))
					If Empty(Alltrim(aDadInd[1,16]))
						_LocEnt := AllTrim(SC5->C5_ENDENT1)+" "+AllTrim(SC5->C5_ENDENT2)
					Else
						_LocEnt := Alltrim(aDadInd[1,16])
					EndIf
				Else
					DbSelectArea("SA1")
					DbSetOrder(1)
					If Empty(Alltrim(aDadInd[1,23]))
						If DBSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
							_LocEnt := Alltrim(SA1->A1_END)
							_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
							_LocEnt += "   " + Alltrim(SA1->A1_MUN)
							_LocEnt += " - " + Upper(SA1->A1_EST)
						EndIf
					Else
						If DBSeek(xFilial("SA1")+aDadInd[1,23])
							_LocEnt := Alltrim(SA1->A1_END)
							_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
							_LocEnt += "   " + Alltrim(SA1->A1_MUN)
							_LocEnt += " - " + Upper(SA1->A1_EST)
						EndIf
					EndIf
				EndIf

				_nLi++
				@ _nLi,00 PSay "LOC.ENTREGA: " + _LocEnt

				_nLi++
				@ _nLi,00 PSay Replicate("-",limite)
				_nLi++


				If Mv_Par01 == 2  //Ordem de Separa??o
					If _nLi > 55
						Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 7
						//ImprCabec()
						u_ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12) // Esta fun??o ? tamb?m usada no fonte CDFATR01A
					EndIf
					_nLi := 59
					@ _nLi++,01 PSay Replicate("-",130)
					@ _nLi++,01 PSay "|       EMISSAO            |       SEPARADO POR        |       ENSACADO POR      |     CONFERIDO POR     |    NOME MOTORISTA     |"
					@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
					@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
					@ _nLi++,01 PSay "|   _____/______/______    |    _____/______/______    |   _____/______/______   |  _____/______/______  |  _____/______/______  |"
					@ _nLi++,01 PSay Replicate("-",130)

					If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))
						Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						_nLi := 9
						u_ChkLstHWEI() // Se tiver laudo para HUAWEI esta fun??o tbm imprime
					ElseIf SC5->C5_LAUDO == "S"
						u_ChkLstLaud()
					EndIf
				EndIf

				_nLi+=60
			EndIf

			DbSelectArea("SC5")
			DbSkip()
			_nTotGSit := 0
			_nTotVen := 0
		
		FreeObj(oPedMdl)
		EndDo
	Next
	If MV_PAR01 == 1 .And. _nLi # 80 // Imprimiu algo
		MaFisEnd()
		MaFisRestore()
	EndIf

	Set Device To Screen
	If aReturn[5]==1
		DbCommitAll()
		Set Printer To
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(.T.)
*
**************************
User Function ImpCBFtr01(Mv_Par01,MV_PAR04,Mv_Par12)
**************************

/////////////////////////
//Static Function ImprCabec()
/////////////////////////

// Esta fun??o foi trocada de ImprCabec() pela u_ImpCBFtr01() que ? usada tanto neste como  no CDFATR01A fun??o CDFTR01A
// Roberto/Juliana 19/07/2016 09:11h


	Local cNomeCli, cPVCli
	Local aDadInd := {}
	Local aDtasFx := {} // Datas fixas no SC5
	Private _lGpo		:= (Ascan(USRRETGRP(),"000002") > 0)

	_cDatasPrg := ""
	If Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_TIPO") == "9"
		DbSelectArea("SX3")
		_aAreaX3 := GetArea()

		DbSetOrder(2) // X3_CAMPO
		DbSeek("C5_DATA",.F.)
		Do While Left(SX3->X3_CAMPO,7) == "C5_DATA" .And. SX3->(!Eof())
			_cVarX3a := SX3->X3_CAMPO
			If Len(AllTrim(_cVarX3a)) == 8
				_cVarX3b := Left("C5_PARC" + Substr(_cVarX3a,8,1) + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO))
				If DbSeek(_cVarX3b,.F.) // Tem campo C5_PARCX
					Aadd(aDtasFx,{"SC5->"+AllTrim(_cVarX3a)})
				EndIf
				DbSeek(_cVarX3a,.F.)
			EndIf
			DbSkip()
		EndDo
		RestArea(_aAreaX3)

		For _nDta := 1 to Len(aDtasFx)
			If !Empty(&(aDtasFx[_nDta,1]))
				_cDatasPrg := _cDatasPrg + Dtoc(&(aDtasFx[_nDta,1])) + " - "
			EndIf
		Next
	EndIf

	//Inicializa o Array com 30 posi??es
	aDadInd := Array(1,30)
	aDadInd := u_InfTrian(xFilial("SC5"),SC5->C5_NUM,"CDFATR01")

	If Len(aDadInd) = 0
		aDadInd := Array(1,30)
	EndIf

	If SC5->C5_TIPO $ "DB" // Devolu??o de compras ou Envio para beneficiamento
		DbSelectArea("SA2")
		DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
	Else
		DbSelectArea("SA1")
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
	EndIf

	If Mv_Par01 == 2
		_nLi--
		If MV_PAR04 == 1     // Saldo do Pedido
			@ _nLi,100 PSay "SITUA??O: SALDO PV"
		ElseIf MV_PAR04 == 2     // N?o Separados
			@ _nLi,100 PSay "SITUA??O: N/SEPAR."
		ElseIf MV_PAR04 == 3 // Separados
			@ _nLi,100 PSay "SITUA??O: SEPARADO"
		ElseIf MV_PAR04 == 4 // Faturados
			@ _nLi,100 PSay "SITUA??O: FATURADO"
		EndIf
		_nLi++
	EndIf

	If Mv_Par01 == 1 .And. !SC5->C5_TIPO $ "DB"
		@ _nLi,00 PSay "DATA DO PEDIDO: "+ IIf(!Empty(aDadInd[1,13]),DtoC(StoD(aDadInd[1,13])),DToC(SC5->C5_EMISSAO))
		@ _nLi,70 PSay "CIDADE: "+IIf(!Empty(aDadInd[1,4]),Alltrim(aDadInd[1,4]),Left(SA1->A1_MUN,25))
		@ _nLi,105 PSay "UF: "+IIf(!Empty(aDadInd[1,5]),Alltrim(aDadInd[1,5]),SA1->A1_EST)
		@ _nLi,150 PSay "***********************   A T E N ? ? O   ************************"
		_nLi++
	EndIf

	If SC5->C5_TIPO $ "DB" // Devolu??o de compras ou Envio para beneficiamento
		@ _nLi,00 PSay "FORNECEDOR: "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+SA2->A2_NOME
	Else
		// 21/08/15 - Jeferson Gardezani
		// Altera??o: Impress?o dos dados do cliente do pedido que originou a opera??o de triangula??o (industrializa??o)
		// C?digo Anterior
		//@ _nLi,00 PSay "CLIENTE: "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+SA1->A1_NOME
		// C?digo Novo
		If ! Empty(Alltrim(aDadInd[1,2]))
			@ _nLi,00 PSay "CLIENTE : "+Alltrim(aDadInd[1,2])+" (Ped.:"+aDadInd[1,1]+")"
		Else
			@ _nLi,00 PSay "CLIENTE : "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+Alltrim(SA1->A1_NOME) + " " +;
			 U_RetPedOri551(xFilial("SC5"),SC5->C5_NUM)
			 //U_RetZZPvOri(xFilial("SC5"),SC5->C5_NUM) +

		EndIf
		// Fim C?digo Novo
	EndIf

	If Mv_Par01 == 1
		_cMyTpCli := "?????"
		If Empty(aDadInd[1,8])
			If SC5->C5_TIPOCLI == "S"
				_cMyTpCli := "SOLIDARIO"
			ElseIf SC5->C5_TIPOCLI == "F"
				_cMyTpCli := "CONS.FINAL"
			ElseIf SC5->C5_TIPOCLI == "R"
				_cMyTpCli := "REVENDEDOR"
			ElseIf SC5->C5_TIPOCLI == "L"
				_cMyTpCli := "PROD.RURAL"
			ElseIf SC5->C5_TIPOCLI == "X"
				_cMyTpCli := "EXPORTACAO"
			EndIf
		Else
			If aDadInd[1,8] == "S"
				_cMyTpCli := "SOLIDARIO"
			ElseIf aDadInd[1,8] == "F"
				_cMyTpCli := "CONS.FINAL"
			ElseIf aDadInd[1,8] == "R"
				_cMyTpCli := "REVENDEDOR"
			ElseIf aDadInd[1,8] == "L"
				_cMyTpCli := "PROD.RURAL"
			ElseIf aDadInd[1,8] == "X"
				_cMyTpCli := "EXPORTACAO"
			EndIf
		Endif

		If SC5->C5_TIPO $ "DB" // Devolu??o de compras ou E]nvio para beneficiamento
			@ _nLi,105 PSay "TP.PEDIDO.: " + If(SC5->C5_TIPO=="D","Dev.Compras","Envio p/Benef.")
			_nLi++
			@ _nLi,00 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA2->A2_CGC))==11,;
			Transform(SA2->A2_CGC,"@R 999.999.999-99"),;
			Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"))
			@ _nLi,70 PSay "FONE: "+SA2->A2_TEL
			@ _nLi,105 PSay "TABELA : "+SC5->C5_TABELA
		Else
			_txtMoeda := ''
			if lNewRg
				if SC5->(C5_MOEDA) <> 1
					if SC5->(C5_MOEDA) == 2
						_txtMoeda += ' ( * DOLAR  '
					elseif SC5->(C5_MOEDA) == 3
						_txtMoeda += ' ( * EURO   '
					endif
					_txtMoeda += ' TAXA: ' + cValToChar(SC5->(C5_TXMOEDA)) + ' * )'
				endif
			endif
			@ _nLi,105 PSay "TP.CLI.: "+_cMyTpCli
			@ _nLi,150 PSay "*   1) DESC. PADR?O = " + Alltrim(SC5->C5_DESCPAD) + _txtMoeda
			@ _nLi,215 PSay "*"
			_nLi++
			/*
			Inclus?o para trazer Cliente do Processo de Industrializa??o
			Juliana Leme 16/09/2015
			*/
			If !Empty(aDadInd[1,6])
				@ _nLi,00 PSay "CNPJ/CPF: "+If(Len(AllTrim(aDadInd[1,6]))==11,;
				Transform(aDadInd[1,6],"@R 999.999.999-99"),;
				Transform(aDadInd[1,6],"@R 99.999.999/9999-99"))
				@ _nLi,70 PSay "FONE: "+Alltrim(aDadInd[1,7])
				@ _nLi,105 PSay "TABELA : "+SC5->C5_TABELA
				@ _nLi,150 PSay "*   2) FIOS/FLEX 2,5 N?O PODE PASSAR DE 30% DO PEDIDO            *"
			Else
				@ _nLi,00 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA1->A1_CGC))==11,;
				Transform(SA1->A1_CGC,"@R 999.999.999-99"),;
				Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))
				@ _nLi,70 PSay "FONE: "+SA1->A1_TEL
				@ _nLi,105 PSay "TABELA : "+SC5->C5_TABELA
				@ _nLi,150 PSay "*   2) FIOS/FLEX 2,5 N?O PODE PASSAR DE 30% DO PEDIDO            *"
			EndIf
		EndIf

		_nLi++
		If Mv_Par01 == 1 .And. !SC5->C5_TIPO $ "DB"
			@ _nLi,150 PSay "******************************************************************"
		EndIf
	Else
		If SC5->C5_TIPO $ "DB" // Devolu??o de compras ou Envio para beneficiamento
			@ _nLi,100 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA2->A2_CGC))==11,;
			Transform(SA2->A2_CGC,"@R 999.999.999-99"),;
			Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"))
		Else
			If !Empty(aDadInd[1,6])
				@ _nLi,100 PSay "CNPJ/CPF: "+If(Len(AllTrim(aDadInd[1,6]))==11,;
				Transform(aDadInd[1,6],"@R 999.999.999-99"),;
				Transform(aDadInd[1,6],"@R 99.999.999/9999-99"))
			Else
				@ _nLi,100 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA1->A1_CGC))==11,;
				Transform(SA1->A1_CGC,"@R 999.999.999-99"),;
				Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))
			EndIf
		EndIf
		_nLi++
	EndIf

	If !SC5->C5_TIPO $ "DB" // Devolu??o de compras ou Envio para beneficiamento
		_cGerSup := Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_SUPER")
		If Empty(_cGerSup)
			_cGerSup := Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_GEREN")
		EndIf
		@ _nLi,00 PSay "VENDEDOR: "+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22])+" - "+Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_NOME")
		@ _nLi,100 PSay "STATUS: " + If(SC5->C5_ZSTATUS < "1","Normal",If(SC5->C5_ZSTATUS==Padr('1',TamSX3("C5_ZSTATUS")[1]),"Em Separac?o","Em Faturamento"))
		_nLi++
		@ _nLi,00 PSay "GER./SUP: "+_cGerSup+" - "+Posicione("SA3",1,xFilial("SA3")+_cGerSup,"A3_NOME")
	EndIf

	_nLi++

	@ _nLi,00 PSay "DATA ENTR.: "+ IIf(Empty(aDadInd[1,12]),DToC(SC5->C5_ENTREG),DtoC(StoD(aDadInd[1,12])))

	If !Empty(SC5->C5_DTENTR)
		@ _nLi,23 PSay "NEG."
	EndIf
	If SC5->C5_DIASNEG > 0
		@ _nLi,29 PSay "PRZ: "
		@ _nLi,34 PSay SC5->C5_DIASNEG Picture "999"
	EndIf

	If Mv_Par01 # 1
		@ _nLi,70 PSay "CIDADE: " + IIf(!Empty(aDadInd[1,4]),Alltrim(aDadInd[1,4]),Left(If(SC5->C5_TIPO $ "DB",SA2->A2_MUN,SA1->A1_MUN),25))
		@ _nLi,105 PSay "UF: " + IIf(!Empty(aDadInd[1,5]),Alltrim(aDadInd[1,5]),If(SC5->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST))

	ElseIf Mv_Par01 == 1
		@ _nLi,70 PSay "ORDEM DE COMPRA:"
		@ _nLi,90 PSay IIf(Empty(Alltrim(aDadInd[1,15])),SC5->C5_PEDCLI,Alltrim(aDadInd[1,15]))

		//Altera??o Juliana 20/07/2016
		_LocEnt := ""
		If ! Empty(Alltrim(SC5->C5_ENDENT1))
			If Empty(Alltrim(aDadInd[1,16]))
				_LocEnt := AllTrim(SC5->C5_ENDENT1)+" "+AllTrim(SC5->C5_ENDENT2)
			Else
				_LocEnt := Alltrim(aDadInd[1,16])
			EndIf
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DBSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
				_LocEnt := Alltrim(SA1->A1_END)
				_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
				_LocEnt += "   " + Alltrim(SA1->A1_MUN)
				_LocEnt += " - " + Upper(SA1->A1_EST)
			EndIf
		EndIf
		//Fim Altera??o Juliana 20/07/2016

		@ _nLi,105 PSay "LOC.ENTREGA: " + _LocEnt
		//	@ _nLi,150 PSay "******************************************************************" //??
	EndIf

	//Altera??o Juliana 20/07/2016
	_LocEnt := ""
	If !Empty(Alltrim(SC5->C5_ENDENT1))
		If Empty(Alltrim(aDadInd[1,16]))
			_LocEnt := AllTrim(SC5->C5_ENDENT1)+" "+AllTrim(SC5->C5_ENDENT2)
		Else
			_LocEnt := Alltrim(aDadInd[1,16])
		EndIf
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		If Empty(Alltrim(aDadInd[1,23]))
			If DBSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
				_LocEnt := Alltrim(SA1->A1_END)
				_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
				_LocEnt += "   " + Alltrim(SA1->A1_MUN)
				_LocEnt += " - " + Upper(SA1->A1_EST)
			EndIf
		Else
			If DBSeek(xFilial("SA1")+aDadInd[1,23])
				_LocEnt := Alltrim(SA1->A1_END)
				_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
				_LocEnt += "   " + Alltrim(SA1->A1_MUN)
				_LocEnt += " - " + Upper(SA1->A1_EST)
			EndIf
		EndIf
	EndIf
	//Fim Altera??o Juliana 20/07/2016
	If !Empty(_LocEnt)
		@ ++_nLi,000 PSay "LOC.ENTREGA: " + _LocEnt
	EndIf

	_nLi++
	@ _nLi,00 PSay "COND.PAGTO.: "+ IIF(Empty(aDadInd[1,9]),AllTrim(SC5->C5_CONDPAG),Alltrim(aDadInd[1,9]));
	+ "  -  " + Posicione("SE4",1,xFilial("SE4")+IIF(Empty(aDadInd[1,9]),AllTrim(SC5->C5_CONDPAG),Alltrim(aDadInd[1,9])),"E4_DESCRI")

	If Mv_Par01 == 1
		// Inicio By Roberto Oliveira - 14/09/16 - Solicita??o Juliana - vendas.
		@ _nLi,70 PSay "PRZ. MEDIO:"
		@ _nLi,83 PSay Int(Val(Posicione("SE4",1,xFilial("SE4")+IIF(Empty(aDadInd[1,9]),AllTrim(SC5->C5_CONDPAG),Alltrim(aDadInd[1,9])),"E4_ZMEDPAG"))) Picture "@E 999"
		// Fim By Roberto Oliveira - 14/09/16 - Solicita??o Juliana - vendas.
	EndIf

	//#Leonardo 21/02/2014 inclus?o das proximas 9 linhas
			// By Roberto Oliveira 14/09/16 - Devido a inclus?o do PRAZO M?DIO,
			// estou alterando o posicionamento da DRC de 70 para 100 e de PRODUZ? de 100 -> 150
	@ _nLi,100 PSay "N? DRC: " + If(SC5->C5_DRC==0," ",AllTrim(Str(SC5->C5_DRC)))

	If Mv_Par01 == 1
		@ _nLi,150 PSay "PRODUZ ? " + IIf (SC5->C5_DRCPROD=="N"," NAO "," SIM ")
	EndIf

	//#
	If Mv_Par01 == 1 .And. !Empty(_cDatasPrg)
		_nLi++
		@ _nLi,00 PSay "Vencto.Fixo para : " + _cDatasPrg
	EndIf


	_nLi++
	_cTransp := Iif(Empty(Alltrim(aDadInd[1,19])),SC5->C5_TRANSP,Alltrim(aDadInd[1,19]))
	@ _nLi,00 PSay "TRANSP.: " + _cTransp + " " + If(! Empty(_cTransp),Posicione("SA4",1,xFilial("SA4")+_cTransp,"A4_NOME"),"")

	_cMyTpFrete := "????"
	If SC5->C5_TPFRETE == "C"
		_cMyTpFrete := "CIF"
	ElseIf SC5->C5_TPFRETE == "F"
		_cMyTpFrete := "FOB"
	EndIf
	@ _nLi,70 PSay "TIPO FRETE : " + _cMyTpFrete

	If Empty(Alltrim(aDadInd[1,24]))
		@ _nLi,100 PSay "PALETIZAR ? " + IIf (SC5->C5_PALLET =="S"," SIM "," N?O ")
	Else
		@ _nLi,100 PSay "PALETIZAR ? " + IIf (Alltrim(aDadInd[1,24])=="S"," SIM "," N?O ")
	EndIf

	If Mv_Par01 == 1
		@ _nLi,150 PSay "BLQ.FATUR.? " + IIf (SC5->C5_ZZBLVEN=="S"," SIM "," N?O ")
	EndIf

	//Mensagem para NF
	@ ++_nLi,000 PSay "INF.TRANSP: " + Iif(Empty(Alltrim(aDadInd[1,25])),AllTrim(SC5->C5_XTELENT),Alltrim(aDadInd[1,25]))

	//Envio de Laudo
	If Empty(Alltrim(aDadInd[1,26]))
		@ _nLi,100 PSay "ENVIA LAUDO ?" + IIf(SC5->C5_LAUDO == "S", " SIM ", " NAO ")
	Else
		@ _nLi,100 PSay "ENVIA LAUDO ?" + IIf(Alltrim(aDadInd[1,26]) == "S", " SIM ", " NAO ")
	EndIf

	// [LEO]- 06/04/17 - ( Aceita Fat. Parcial )
	If Mv_Par01 == 1
		@ _nLi,150 PSay "FAT. PARCIAL ?" + if( SC5->(C5_PARCIAL) == "S", " SIM ", " NAO ")
	else
		@ _nLi,120 PSay "PARCIAL ?" + if( SC5->(C5_PARCIAL) == "S", " SIM", " NAO")
	endif
	
	//Mensagem para Nota
	_cMsgNota := Iif(Empty(Alltrim(aDadInd[1,27])),AllTrim(SC5->C5_MENNOTA),Alltrim(aDadInd[1,27]))
	If Len(_cMsgNota) <= 85
		@ ++_nLi,000 PSay "MSG NOTA: " + _cMsgNota
		//Agendar Entrega
		If Empty(Alltrim(aDadInd[1,26]))
			@ _nLi,100 PSay "AGENDAR ENTREGA? "+ IIF(SA1->A1_XAGENTR == "S"," SIM ", " NAO ")
		Else
			@ _nLi,100 PSay "AGENDAR ENTREGA? "+ IIF(Alltrim(aDadInd[1,28]) == "S"," SIM ", " NAO ")
		EndIf
	Else
		@ ++_nLi,000 PSay "MSG NOTA: " + SubStr(AllTrim(_cMsgNota),1,85)
		//Agendar Entrega
		@ _nLi,100 PSay "AGENDAR ENTREGA? "+ IIF(SA1->A1_XAGENTR == "S"," SIM ", " NAO ")
		If Len(_cMsgNota)-86 <= 85
			@ ++_nLi,000 PSay "MSG NOTA(Cont): " + SubStr(AllTrim(_cMsgNota),86,Len(_cMsgNota))
		Else
			@ ++_nLi,000 PSay "MSG NOTA(Cont): " + SubStr(AllTrim(_cMsgNota),86,110)
			@ ++_nLi,000 PSay "MSG NOTA(Cont2): " + SubStr(AllTrim(_cMsgNota),196,Len(_cMsgNota))
		EndIf
	EndIf

	_nLi++
	If Mv_Par01 == 1
		_cDtFatura := Iif(Empty(Alltrim(aDadInd[1,29])),SA1->A1_ZZPRFAT,Alltrim(aDadInd[1,29]))
		@ _nLi,100 PSay "DT.LIBER.FATUR.: " + IIf(Empty(_cDtFatura),"QUALQUER DATA DISPONIVEL",_cDtFatura)
	EndIf

	@ _nLi,00 PSay "OBSERVACOES: "+ IIF(Empty(Alltrim(aDadInd[1,10])),SC5->C5_OBS,Alltrim(aDadInd[1,10]))

	_nLi++

	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++
	If Mv_Par01 == 1 //pedido de venda
		//	@ _nLi,00 PSay "Produto        Descricao                                         Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"    LB %      ",Space(14))+"Total"+If(Mv_Par12 == 1,"       Lances      Fator","") + "  TES"//EDVAR
		//	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"    LB %      ",Space(14))+"Total"+If(Mv_Par12 == 1,"       Lances      Fator","       Lances"+Space(11)) + " TES   %(>)"
		//	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"    LB %      ",Space(14))+"Total       Lances      " + If(Mv_Par12==1,"%Com. TES","         ") + "   Desc.Aplicado                      Indice  Variac.  % ICMS"
		//	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"    LB %      ",Space(14))+"Total       Lances      " + If(Mv_Par12==1,"%Com. TES","         ") + "   Desc.Aplicado                      Indice  Variac.  % ICMS"
		//  @ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"    TGT       ",Space(14))+"Total       Lances      " + If(Mv_Par12==1,"%Com. TES","         ") + "   Desc.Aplicado                              Variac.  % ICMS"
		@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit."+If(Mv_Par12==1,"     RG       ",Space(14))+"Total       Lances      " + If(Mv_Par12==1,"%Com. TES","         ") + "   Desc.Aplicado                      Indice  Variac.  % ICMS Local Ped.Cliente  It.Cli. PO.Shp."
		//roduto        Descricao                                         Qtd.(m) Vr. Unit.    LB %      Total                   Fator
		//99.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 9999.9999 9999.99 999,999.99                  999.99
	Else // Ordem de separa??o
		If cModulo == "FAT" .Or. _lGpo
		//	@ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso     Valor    Fator"
			@ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso     Valor      Local"
		ElseIf cModulo == "EST" .And. MV_PAR04 # 3 // Separados
			@ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso                Local"
		Else
			// 		@ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso              Fator"
		//  @ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso              Tp.Bob."
			@ _nLi,00 PSay "Item Produto        Descricao                                      Qtd.(m) Lances / Metrag Acondic.       Peso  Tp.Bob.  Nro.Bobina"
		Endif
		//	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Lances / Metrag Acondic.       Peso  Situacao   Fator"
		//	@ _nLi,00 PSay "Produto        Descricao                                         Qtd.(m) Lances/Metragem Acondic.       Peso  Situacao    Quant.Sit."
		/*/
		Produto        Descricao                                         Qtd.(m) Lances/Metragem Acondic.       Peso  Situacao    Quant.Sit."
		Produto        Descricao                                         Qtd.(m) Lances/Metragem Acondic.       Peso  Situacao    Quant.Sit."
		------------------------------------------------------------------------------------------------------------------------------------
		999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  Tudo           99,999     999,99
		999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  N/Separ.
		999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  Separado
		999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  Faturado
		/*/
	EndIf
	_nLi++
	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++
	lImpCb := .T.

Return(.T.)

/////////////////////////
Static Function ValidPerg(cPerg)
	/////////////////////////
	//Private cPerg       := "CDFT01"

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Imprimir                     ?","mv_ch1","N",01,0,0,"C","","mv_par01","Pedido de Venda","","","Ordem de Separa??o","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Do Pedido                    ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","At? o Pedido                 ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Sit.Itens   (p/Ord.Separacao)?","mv_ch4","N",01,0,0,"C","","mv_par04","Saldo","","","N?o Separ.","","","Separado","","","Faturado","","","","",""})
	aAdd(aRegs,{cPerg,"05","Nro.de Vias (p/Ord.Separacao)?","mv_ch5","N",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Da Data de Emiss?o           ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","At? a Data de Emiss?o        ?","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Do Cliente                   ?","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"09","Da Loja                      ?","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","At? o Cliente                ?","mv_cha","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"11","At? a Loja                   ?","mv_chb","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Imprimir % de RG             ?","mv_chc","N",01,0,0,"C","","mv_par12","Sim","","","N?o","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Alt.Status para              ?","mv_chd","N",01,0,0,"C","","mv_par13","Normal","","","Em Separa??o","","","Em Faturamento","","","N?o Altera","","","","",""})
	aAdd(aRegs,{cPerg,"14","Qual Armaz?m                 ?","mv_che","C",02,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})

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
	***************************************************************************
User Function ClcDesc(_cTabela,_cVend,_cProduto,_nPrcVen,_nPrcTab,_cAvista)
	***************************************************************************
	*
	*
	// Esta fun??o tamb?m ? utilizada no portal e qualquer manuten??o requer
	// verifica??o se n?o vai interferir l?. Fun??o CBCPRODUCTVALUES.
	Private _cTabela,_cVend,_cProduto,_nPrcVen,_nPrcTab

	DEFAULT _cTabela  := ""
	DEFAULT _cVend    := ""
	DEFAULT _cProduto := ""
	DEFAULT _nPrcVen  := 0
	DEFAULT _nPrcTab  := 0
	DEFAULT Mv_Par12  := 1
	DEFAULT _cAvista  := "N" // Aplicar adicional de desconto a vista?

	_cAvista := Upper(_cAvista)

	//[LEO]-06/12/16- Se alterar a estrutura do array _aPrecos{} mudar tambem cbcProductValues.prw
	//procurar o trecho aInfoDesc[6][Len(aInfoDesc[6])][2]
	_aPrecos := {}
	//[LEO]-06/12/16
	ConOut('INICIO ' + Time())
	DbSelectArea("SZX")
	DbSetOrder(2) //ZX_FILIAL+ZX_CODTAB
	SZX->(DbSeek(xFilial("SZX")+_cTabela,.F.))

	//_cAdicDes := ""
	_aAdicDes := {}
	If !Empty(_cProduto)
		ConOut('u_CalcAdic ' + Time())
		_aAdicDes := u_CalcAdic(_cTabela,_cVend,_cProduto,.T.) // Agora retorna um array
	EndIf


	DbSelectArea("SZY")
	DbSetOrder(1) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM
	SZY->(DbSeek(xFilial("SZY")+SZX->ZX_CARTA,.F.))

	//_cAvista := "N" // At? que a Deniela altere as condi??es de pagamento a vista, n?o utilizarei este recurso. Excluir esta linha quando testado e estiver ok // Roberto 21/05/14 14:29

	//If _cAvista == "S" .And. SZY->ZY_DESCVIS > 0
	//	_cAdicDes := AllTrim(_cAdicDes) + "+" + AllTrim(Str(SZY->ZY_DESCVIS,10,2))
	//EndIf
	If Len(_aAdicDes) == 0 // N?o tem adicional
		If _cAvista == "S" .And. SZY->ZY_DESCVIS > 0
			Aadd(_aAdicDes,"+"+ AllTrim(Str(SZY->ZY_DESCVIS,10,2)))
		Else
			Aadd(_aAdicDes,"")
		EndIf
	Else
		For _nQtdAdic := 1 to Len(_aAdicDes)
			If _cAvista == "S" .And. SZY->ZY_DESCVIS > 0
				_aAdicDes[_nQtdAdic] := AllTrim(_aAdicDes[_nQtdAdic]) + AllTrim(Str(SZY->ZY_DESCVIS,10,2))
			Else // Tirar o "+" do fim sa Strind
				_aAdicDes[_nQtdAdic] := Left(_aAdicDes[_nQtdAdic],Len(_aAdicDes[_nQtdAdic])-1)
			EndIf
		Next
	EndIf
	_nMenorVlr := _nPrcTab
	Do While SZY->ZY_FILIAL == xFilial("SZY") .And. SZY->ZY_CODIGO == SZX->ZX_CARTA .And. SZY->(!Eof())
		//_ZY_DESCONT := AllTrim(SZY->ZY_DESCONT)+_cAdicDes+"Z" // Colocar o Z no final pra poder calcular o ultimo

		For _nQtdAdic := 1 to Len(_aAdicDes)
			_ZY_DESCONT := AllTrim(SZY->ZY_DESCONT)+ "+" + _aAdicDes[_nQtdAdic]+"Z" // Colocar o Z no final pra poder calcular o ultimo
			_nValLiq := _nPrcTab // _nPrcVen
			_nPerc   := ""
			_nPerc2  := ""
			For _nPrc := 1 To Len(_ZY_DESCONT)
				If Substr(_ZY_DESCONT,_nPrc,1) $ "1234567890"
					_nPerc += Substr(_ZY_DESCONT,_nPrc,1)
				ElseIf Substr(_ZY_DESCONT,_nPrc,1)  $ ".,"
					_nPerc += "."
				Else
					If Val(_nPerc) > 0

						_cPerc2 := _nPerc2
						_nValAnt  := _nValLiq

						If !Empty(_nPerc2)
							_nPerc2 := _nPerc2 + "+"
						EndIf

						_nPerc2 := _nPerc2 + _nPerc
						_nPerc := Val(_nPerc)

						_nApliPer := (_nValLiq * _nPerc) / 100 // trabalha com o n?mero absoluto
						_nValLiq  := _nValLiq - _nApliPer

						// Pra n?o encher muito o array, procuro se j? n?o existe um cara desse
						If aScan(_aPrecos,{|x| x[2]==_nPerc2}) == 0
							Aadd(_aPrecos,{Round(_nValLiq,4),_nPerc2,SZY->ZY_COMIS,;
							SZY->ZY_DESCPAD,SZY->ZY_CMMIN,_cPerc2,Round(_nValAnt,4)})
							_nMenorVlr := Min(_nMenorVlr,Round(_nValLiq,4))
						EndIf
					EndIf
					_nPerc := ""
				EndIf
			Next
		Next

		SZY->(DbSkip())
	EndDo
	aSort(_aPrecos,,,{|x,y| StrZero(x[1],10,4)+x[2]>StrZero(y[1],10,4)+y[2]}) // Ordena do maior para o menor

	_nElem := 0
	_nComNow := 0
	_nValNow := 0
	For _xEle := 1 To Len(_aPrecos)
		If _nPrcVen >= _aPrecos[_xEle,1]
			If _nValNow == 0 .Or. (_nValNow == _aPrecos[_xEle,1] .And. _aPrecos[_xEle,3] > _nComNow)
				_nElem   := _xEle
				_nValNow := _aPrecos[_xEle,1]
				_nComNow := _aPrecos[_xEle,3]
			EndIf
		EndIf
	Next

	_cDescs := ""
	_nBase  := _nPrcTab
	If Len(_aPrecos) > 0 // Tem informa??es no aPrecos?
		If _nElem == 0 // N?o achou nada
			_nElem := Len(_aPrecos) // O ?ltimo cara
			_nBase  := _aPrecos[_nElem,1]
			_cDescs := AllTrim(_aPrecos[_nElem,2])
		ElseIf _nPrcVen == _aPrecos[_nElem,1] //Achou e ? igual ?
			_nBase  := _aPrecos[_nElem,1]
			_cDescs := AllTrim(_aPrecos[_nElem,2])
		Else // Achou e ? diferente
			_nBase  := _aPrecos[_nElem,7]
			_cDescs := AllTrim(_aPrecos[_nElem,6])
		EndIf
	EndIf
	nDiferenc := (_nBase - _nPrcVen)
	If nDiferenc # 0
		_nMaisDesc := Round((nDiferenc / _nBase)*100,2)
		_nMaisDesc := AllTrim(Str(_nMaisDesc,10,2))
		If Right(_nMaisDesc,3) = ".00"
			_nMaisDesc := Left(_nMaisDesc,Len(_nMaisDesc)-3)
		EndIf
		If !Empty(_cDescs)
			_cDescs := _cDescs + "+"
		EndIf
		_cDescs := _cDescs + _nMaisDesc
	EndIf
	_cDescs := AllTrim(_cDescs)
	If Len(_cDescs) > 33 .And. Mv_Par12 # 1
		_cDescs := Left(_cDescs,30) + "..."
	EndIf

	If _nElem == 0
		// O Pre?o ? maior que a menor faixa de desconto
		_nElem := Len(_aPrecos) // Usar o ?ltimo cara
	EndIf

	If _nElem == 0 // Isto ainda pode acontecer se n?o tiver a carta de desconto cadastrada
		_aDescs := {_cDescs     ,"???"      ,0         ,0              ,0	,_aPrecos}
		// {Desc.Efetivo,Desc.Padr?o,% Comiss?o,% Min. Comiss?o,(*)Valor Minimo      }
	Else
		//Aadd(_aPrecos,{1-Round(_nValLiq,4),2-_nPerc2,3-SZY->ZY_COMIS,4-SZY->ZY_DESCPAD})
		_aDescs := {_cDescs     ,_aPrecos[_nElem,4],_aPrecos[_nElem,3],_aPrecos[_nElem,5],_nMenorVlr,_aPrecos}
		// {Desc.Efetivo,Desc.Padr?o       ,% Comiss?o        ,% Min. Comiss?o   ,(*)Valor Minimo      }
		// (*)Valor Minimo -> O Valor m?mino ? o pre?o bruto com todos os descontos possiveis e como o
		// array _aPrecos est? ordenado por valor (do menor pro maior) consequentemente o menor ? o primeiro cara.
	EndIf

	Return(_aDescs)
	*
	****************************
User Function ChkLstHWEI()
	****************************
	*
	// Esta fun??o tem a finalidade de ap?s a impress?o de cada ordem se separa??o HUAWEI
	// imprimir um Chek-Lisk no carregamento dos materiais.



	@ 09,38 PSay 'Chek-Lisk de Carregamento e Libera??o dos Materiais'
	@ 12,11 PSay 'Sr. Conferente,'
	@ 14,11 PSay 'Os itens abaixo dever?o obrigatoriamente ser vistoriados e atendidos.'
	@ 19,11 PSay '1 - Acondicionamento:'
	@ 21,11 PSay '      Tem bobina maior que 100/60 ? ........................... ( ) SIM - "Reprovado"   ( ) NAO - "Aprovado"'
	@ 23,11 PSay '      Tem material em rolos ? ................................. ( ) SIM - "Reprovado"   ( ) NAO - "Aprovado"'
	@ 27,11 PSay '2 - Visual:'
	@ 29,11 PSay '      Cada bobina cont?m 3 etiquetas Huawei ? ................. ( ) SIM - "Aprovado"    ( ) NAO - "Reprovado"'
	@ 31,11 PSay '      C?digo de barras das etiquetas Huawei est?o legiveis ? .. ( ) SIM - "Aprovado"    ( ) NAO - "Reprovado"'
	@ 35,11 PSay '3 - Transporte:'
	@ 37,11 PSay '      As bobinas est?o dispostas "em p?" no caminh?o ? ........ ( ) SIM - "Aprovado"    ( ) NAO - "Reprovado"'
	If SC5->C5_LAUDO == "S"
		@ 41,11 PSay '4 - Documenta??o:
		@ 43,11 PSay '      Os laudos de todos os produtos foram solicitados'
		@ 45,11 PSay '      para o C.Q.?............................................. ( ) SIM - "Aprovado"    ( ) NAO - "Reprovado"'
		@ 47,11 PSay '      Resp. pela solicita??o: _____________________________     Data: ____/____/____'

		@ 49,11 PSay '5 - Conclus?o:'
		@ 51,11 PSay '      Todos os itens acima est?o "Aprovados" ? ................ ( ) SIM - "Liberado para entrega"'
		@ 53,11 PSay '                                               ................ ( ) NAO - "Chamar o supervisor"'
	Else
		@ 41,11 PSay '4 - Conclus?o:'
		@ 43,11 PSay '      Todos os itens acima est?o "Aprovados" ? ................ ( ) SIM - "Liberado para entrega"'
		@ 45,11 PSay '                                               ................ ( ) NAO - "Chamar o supervisor"'
	EndIf

	_nLi := 59
	@ _nLi++,01 PSay Replicate("-",130)
	@ _nLi++,01 PSay "|       EMISSAO            |       SEPARADO POR        |       ENSACADO POR      |     CONFERIDO POR     |    NOME MOTORISTA     |"
	@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
	@ _nLi++,01 PSay "|                          |                           |                         |                       |                       |"
	@ _nLi++,01 PSay "|   _____/______/______    |    _____/______/______    |   _____/______/______   |  _____/______/______  |  _____/______/______  |"
	@ _nLi++,01 PSay Replicate("-",130)
	Return(.T.)
	*
	*********************************************
User Function DescCasc(_nValor,_aDescs,_Decs)
	*********************************************
	*
	Local _nValor,_aDescs,_nArr,nDesc
	For _nArr := 1 to Len(_aDescs)
		If ValType(_aDescs[_nArr]) # "N"
			_aDescs[_nArr] := Val(_aDescs[_nArr])
		EndIf
		nDesc := ((_nValor * _aDescs[_nArr]) / 100)
		_nValor -= nDesc
	Next
	Return(Round(_nValor,_Decs))
	*
	****************************
User Function ChkLstLaud()
	****************************
	*
	// Esta fun??o tem a finalidade de ap?s a impress?o de cada ordem de separa??o
	// imprimir um Chek-Lisk no carregamento dos materiais.

	@ 09,38 PSay 'Chek-Lisk de Carregamento e Libera??o dos Materiais'
	@ 12,11 PSay 'Sr. Conferente,'
	@ 14,11 PSay 'Os itens abaixo dever?o obrigatoriamente ser vistoriados e atendidos.'

	@ 19,11 PSay '1 - Documenta??o:
	@ 21,11 PSay '      Os laudos de todos os produtos foram solicitados'
	@ 23,11 PSay '      para o C.Q.?............................................. ( ) SIM - "Aprovado"    ( ) NAO - "Reprovado"'
	@ 25,11 PSay '      Resp. pela solicita??o: _____________________________     Data: ____/____/____'

	@ 29,11 PSay '2 - Conclus?o:'
	@ 31,11 PSay '      Todos os itens acima est?o "Aprovados" ? ................ ( ) SIM - "Liberado para entrega"'
	@ 33,11 PSay '                                               ................ ( ) NAO - "Chamar o supervisor"'
Return(.T.)

static function getTit()
	local cTitulo	:= ''

	if SC5->(C5_ZTPVEND) == 'V'
		cTitulo += '[VAREJO] - '
	endif
	
	if !empty(SC5->(C5_DOCPORT) )
		cTitulo +=	'[PORTAL] - Nro. [' + Alltrim(SC5->(C5_DOCPORT)) + '] - '
	endif
	
	if Mv_Par01 == 1
		cTitulo += "P E D I D O   D E   V E N D A S"
	else
		cTitulo += "O R D E M   DE   S E P A R A C A O"
	endif
	
	cTitulo += "  -  N. "+SC5->C5_NUM
	cTitulo +=	If(SC5->C5_CONDPAG=="000","  - B N D E S","")

return(cTitulo)
