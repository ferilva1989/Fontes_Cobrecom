#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} CDFTR01B
//TODO Relatório de Ordens de Separação solicitado pelo IVO     
   (enc.exp.) e Sr. Claudemir (consultor) para mudanças no layout do      
   relatório para apresentar na seguinte ordem: Bobinas, Carretéis, Rolos-
   Retalhos e Blisters, quantidades de lances e pesos por bloco e totais.
@author ROBERTO OLIVEIRA  
@since 05/06/2016
@version 1.0
@param _cPedido, , descricao
@type function
/*/
User Function CDFTR01B(_cPedido)  //152903  U_CDFTR01B("197667")
	Local cDesc1        := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2        := "Ordem de Separação de acordo com os parâmetros"
	Local cDesc3        := "informados pelo usuário."
	Local cPict         := ""
	Private titulo      := "Ordem de Separação - Exp."
	Private nLin        := 80
	Private Cabec1      := ""
	Private Cabec2      := ""
	Private imprime     := .T.
	Private aOrd        := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog	:= "CDFTR01B"
	Private nTipo			:= 18
	Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey		:= 0
	Private cPerg			:= "CDFTR01B" // If(GetMv("MV_ZZUSAC9"),"CDFTR01B","CDFATR01B")
	Private cbtxt				:= Space(10)
	Private cbcont			:= 00
	Private CONTFL		:= 01
	Private m_pag			:= 01
	Private wnrel       		:= "CDFTR01B"
	Private lImpCb			:= .F.
	Private _aItens
	
	If xFilial("SC5") # '01'
		Alert("Rotina Disponível Somente para Itu")
		Return(.T.)
	EndIf
	
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	Private cString     := "SC5"
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("ZZO") // Volumes das O.S.
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	
	DbSelectArea("ZZR") // Log das Liberações
	DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
	
	ValidPerg(cPerg)
	
	If Valtype(_cPedido) # "U"  // .And. !GetMv("MV_ZZUSAC9") // Não trata o status no SC9
		Pergunte(cPerg,.F.)
		MV_PAR01 := _cPedido
		Mv_Par02 := _cPedido
		MV_PAR08 := "4"
	
		DbSelectArea("SX1")
		If DbSeek(cPerg+"01",.F.)
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := _cPedido
			MsUnLock()
		EndIf
		If DbSeek(cPerg+"02",.F.)
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := _cPedido
			MsUnLock()
		EndIf
		If DbSeek(cPerg+"08",.F.)
			RecLock("SX1",.F.)
			SX1->X1_CNT01 := "4"
			MsUnLock()
		EndIf
	EndIf
	
	Pergunte(cPerg,.T.)
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return(.T.)
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return(.T.)
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(.T.)


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Private _nLi := 80
	Private _cProduto := Space(15)
	Private _nTotMt   := 0
	Private _nTotPs   := 0
	Private _nValTot  := 0
	Private _nValTab  := 0
	//Private _cOrdens  := "B01,C02,M02,R03,T03,L04" // Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters)
	Private _aOrdens  := {"B","CM","R00100","RT","L"," "} // Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters)
	Private _cOrdem
	Private lRetorna	:= .T.
	
	//If GetMv("MV_ZZUSAC9") // Trata o status no SC9
		// Altera o conteúdo dos parâmetros para tratar somente de uma forma
		//MV_PAR10 := MV_PAR02	// Novo -> Sequência O.S.?
		MV_PAR10 := "  "		// Novo -> Sequência O.S.?
		MV_PAR09 := "01"		// Qual Armazém    ?
		//MV_PAR08 := MV_PAR04	// Alt.Status para ?
		MV_PAR08 := MV_PAR03	// Alt.Status para ?
		MV_PAR07 := "ZZ"		// Até a Loja      ?
		MV_PAR06 := "ZZZZZZ"	// Até o Cliente   ?
		MV_PAR05 := "  "		// Da Loja         ?
		MV_PAR04 := "      "	// Do Cliente      ?
		MV_PAR03 := MV_PAR02	// Nro.de Vias     ?
		MV_PAR02 := MV_PAR01	// Até o Pedido    ?
		MV_PAR01 := MV_PAR01	// Do Pedido       ?
	//Else
	//	MV_PAR10 := "  "		// Novo -> Sequência O.S.?
	//EndIf
	MV_PAR03 := Max(MV_PAR03,1)
	_cStatus := Str(MV_PAR08-1,1) //mv_par08","Normal","","","Em Separação","","","Em Faturamento","","","Não Altera","","","","",""})
	
	
	If _cStatus == "2" // Alterar o Status para Em Faturamento
		MV_PAR10 := "  "		// Novo -> Sequência O.S.? // A Seq.tem que estar em branco
	EndIf
	
	_lTemErro := .F.
	_NewSeq := JuntaSDC(MV_PAR01,_cStatus)
	If !_lTemErro
		If _cStatus $ "01" // "Normal","","","Em Separação"
			MV_PAR10 := "  " // 
		ElseIf _cStatus $ "23"
			MV_PAR10 := _NewSeq		// Novo -> Sequência O.S.? // A Seq.tem que estar em branco
		EndIf
		
		DbSelectArea("SF4")
		DbSetOrder(1)  // F4_FILIAL+F4_CODIGO
		
		DbSelectArea("SC9")
		DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		
		DbSelectArea("SA1")
		DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA
		
		DbSelectArea("SA2") // SE FOR PEDIDO DE DEVOLUÇÃO
		DbSetOrder(1)  //A2_FILIAL+A2_COD+A2_LOJA
		
		DbSelectArea("SC6")
		DBOrderNickName("SC6NUM")
		
		DbSelectArea("SC5")
		DbSetOrder(1)  //C5_FILIAL+C5_NUM
		DbSeek(xFilial("SC5")+MV_PAR01,.F.) // garante o posicionamento do SC5
		            
		If Empty(MV_PAR10) // Imprime da forma normal considerando SC9, SC6, SDC, SZE, ETC
			ImprSC5()
		Else
			ImprZZR()
		EndIf
	EndIf
	
		Set Device To Screen
		If aReturn[5]==1
			DbCommitAll()
			Set Printer To
			OurSpool(wnrel)
		Endif
		
		MS_FLUSH()
Return(.T.)


Static Function ImprSC5()
	Local pParada
	local aInfAcondi := {}
	
	For _xVias := 1 To Mv_Par03 // Quantidade de vias
		m_pag    := 01
		_nLi     := 80
		_nTotMt  := 0
		_nTotPs  := 0
		_nValTot := 0
		_nValTab := 0
		SetRegua(RecCount())
		DbSeek(xFilial("SC5")+Mv_Par01,.T.)
		Do While SC5->C5_NUM <= Mv_Par02 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())
	
			IncRegua()
	
			If lAbortPrint
				@ _nLi,00 PSay "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			If SC5->C5_CLIENTE < Mv_Par04 .Or. SC5->C5_CLIENTE > Mv_Par06 .Or. SC5->C5_LOJACLI < Mv_Par05 .Or. SC5->C5_LOJACLI > Mv_Par07
				DbSelectArea("SC5")
				DbSkip()
				Loop
			EndIf
			
			_nTotVen := 0.00
			_nTotCus := 0.00
			_nTotPes := 0.00
	
			DbSelectArea("SDC")
			DBOrderNickName("SDCPED") // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
			If !DbSeek(xFilial("SDC")+SC5->C5_NUM,.F.)
				// Verificar se não tem no SC9 produtos que estejam liberados mas não tem controle de localização
				DbSelectArea("SC6")
				DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
				DbSelectArea("SB1")
				DbSetOrder(1) // B1_FILIAL+B1_COD
	
				DbSelectArea("SC9")
				DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
				DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.)
				_lTem := .F.
				Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
					If Empty(SC9->C9_BLCRED+SC9->C9_BLEST) .And. SC9->C9_SEQOS == MV_PAR10
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
			EndIf
	
			_aItens := {}	// {1-Produto      ,2-localiz        ,3-quant                  ,4-VALOR TOTAL,
							//  5-peso cobre   ,6-???            ,7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina,
							//  9-Num.Da Bobina,10-Peso do Item  ,11-Quant.Volumes         ,12-Local
			//			_cPedsIt :=""
			Do While SDC->DC_FILIAL+SDC->DC_PEDIDO == xFilial("SDC")+SC5->C5_NUM .And. SDC->(!Eof())
				If SDC->DC_ORIGEM # "SC6"
					SDC->(DbSkip())
					Loop
				EndIf
	
				//Filtra Armazém  ... OK
				If (MV_PAR09=="10".And.SDC->DC_LOCAL#"10").Or.(MV_PAR09#"10".And.SDC->DC_LOCAL=="10")
					SDC->(DbSkip())
					Loop
				EndIf
				// Se for Bobina, Buscar o peso no SZE
				_nTotEmb	:= 0
				_nQtCxa   	:= 0
				_cTpBob 	:= ""
				_aNumBob 	:= {} // {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se já usado}
				_nQtdLc 	:= SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,15))
	
				//If Left(SDC->DC_LOCALIZ,1) == "B" .And. !(SDC->DC_PEDIDO+SDC->DC_PEDIDO+SDC->DC_ITEM $ _cPedsIt)
				If Left(SDC->DC_LOCALIZ,1) == "B"
					// _cPedsIt := _cPedsIt  + "/" + SDC->DC_PEDIDO+SDC->DC_PEDIDO+SDC->DC_ITEM
					// Como estou olhando bobinas e o loop principal é pelo SDC, pode ocorrer de ter mais de
					// um SDC para a mesma chave FILIAL+PEDIDO+ITEM e ai dar inconsistência no relatório, ainda mais,
					// podemos ter bobinas diferentes para o mesmo item.
					// Assim sendo, como a chave do SDC é específica DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
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
					SDC->(DbGoTo(_nUltReg)) // Sai do possível EOF e vai pro ultimo registro desse PEDIDO+ITEM
	
					DbSelectArea("SZE")
					SZE->(DbSetOrder(3)) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
					DbSeek(xFilial("SZE")+"E"+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.) // Bobinas empenhadas nesse pedido
					Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->(!Eof()) .And.;
						SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM == "E"+SDC->DC_PEDIDO+SDC->DC_ITEM
						
						If SZE->ZE_SEQOS == MV_PAR10
							// Verificar se é do mesmo controle
							_nTotEmb += (SZE->ZE_TARA+SZE->ZE_PLIQ)
							// Elementos da _aNumBob
							// {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se já usado}
		
							Aadd(_aNumBob,{PadR("B"+StrZero(SZE->ZE_QUANT,5),Len(SDC->DC_LOCALIZ)),;
							SZE->ZE_NUMBOB,;
							(SZE->ZE_TARA+SZE->ZE_PLIQ),;
							SZE->ZE_TPBOB,;
							" "}) // {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se já usado}
							If !SZE->ZE_TPBOB $ _cTpBob
								_cTpBob := _cTpBob + SZE->ZE_TPBOB
							EndIf
						EndIf
						SZE->(DbSkip())
					EndDo
	
					// Atenção: Outros lugares também fazem o mesmo cálculo
	
				ElseIf AllTrim(SDC->DC_LOCALIZ) == "R00015" // Rolo de 15 metros
					// Se for rolo de 15 Encartelado
					_nRolCx := 0
					If Left(SDC->DC_PRODUTO,3) == "115"  // Cabo Flexicom
						If Substr(SDC->DC_PRODUTO,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 vão 10 rolos por caixa
							_nRolCx := 10
						ElseIf Substr(SDC->DC_PRODUTO,4,2) $ "06/07" //Se for cabo flex 4 ou 6     vão 08 rolos por caixa
							_nRolCx := 8
						ElseIf Substr(SDC->DC_PRODUTO,4,2) == "08" //Se for cabo flex 10         vão 06 rolos por caixa
							_nRolCx := 6
						EndIf
					ElseIf Left(SDC->DC_PRODUTO,3) == "120"  .And. Substr(SDC->DC_PRODUTO,4,2) $ "04/05"// Cordão Paralelo 1,5 ou 2,5
						_nRolCx := 8
					EndIf
					_nQtCxa   := Int(_nQtdLc/_nRolCx)
					_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unitário do conjunto de ilhós em gramas
					_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unitário do saco plastico     em gramas
					_nCart    := (_nQtdLc*8.5232)/1000        // Peso unitário da cartela de papel  em gramas
					_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unitário da caixa de papelão  em kilos
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
	
				// _aOrdens  := {"B","CM","R00100","RT","L"," '} // Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters, 05-Eutros)
				//_cOrdem := Substr(_cOrdens,(At(Left(SDC->DC_LOCALIZ,1),_cOrdens)+1),2)
				For _cOrdem := 1 to Len(_aOrdens)
					If AllTrim(SDC->DC_LOCALIZ) $ _aOrdens[_cOrdem]
						Exit
					ElseIf Left(SDC->DC_LOCALIZ,1) $ _aOrdens[_cOrdem] .And. _aOrdens[_cOrdem] # "R00100"
						Exit
					EndIf
				Next
				_cOrdem := StrZero(_cOrdem,2)
	
				If Left(SDC->DC_LOCALIZ,1) == "B"
					// Adicionar as bobinas uma a uma observando se não tem bobina suficiente ou
					// se tem mais bobinas que a qtd de lances
	
					For _nLoop1 := 1 to Len(_aDadSDC) // _aDadSDC -> {Acondic,Quantidade,QtdLance}
	
						// Elementos de _aDadSDC
						// {1 Acondic,   2-Quantidade, 3-QtdLance}
						For _nLoop2 := 1 To _aDadSDC[_nLoop1,3]
							// Elementos de _aItens
							// {1-Produto,   2-localiz,3-quant,                  4-VALOR TOTAL,
							//  5-peso cobre,6-???,    7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina}
							// Atenção: Para bobinas ainda em mais elementos
							//  9-Num.Da Bobina   10-Peso da Bobina 11-Quant.Caixas 12-Ordem Impressao
	
							_nQtItem := (_aDadSDC[_nLoop1,2]/_aDadSDC[_nLoop1,3])
							Aadd(_aItens,{	SDC->DC_PRODUTO,_aDadSDC[_nLoop1,1],_nQtItem,(_nQtItem*_nVlrUnit),;
										   (_nQtItem*Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")),;
										   0.00,SDC->DC_ITEM," ","BOB.NAO LOCALIZ",0,0,_cOrdem})
	
							// Atrelar uma bobina ao Item
							// Elementos da _aNumBob
							// {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se já usado}
							For _nLoop3 := 1 To Len(_aNumBob)
								If _aNumBob[_nLoop3,1] == _aItens[Len(_aItens),2] .And. Empty(_aNumBob[_nLoop3,5])
									// Mesmo acondicionamento?
									_aItens[Len(_aItens),08] := _aNumBob[_nLoop3,4] // Tipo da Bobina
									_aItens[Len(_aItens),09] := _aNumBob[_nLoop3,2] // Numero da Bobina
									_aItens[Len(_aItens),10] := _aNumBob[_nLoop3,3] // Peso da bobina
									_aItens[Len(_aItens),12] += _aNumBob[_nLoop3,4]+Right(_aNumBob[_nLoop3,2],1) // Ordem + Tp.Bobina + Final Nro Bob. + O próprio nro da bobina
									_aNumBob[_nLoop3,5]      := "X"
									Exit
								EndIf
							Next
						Next
					Next
				Else
	
					nPos :=  aScan(_aItens,{|x| x[1]+x[2]+x[7]+x[12]==SDC->DC_PRODUTO+SDC->DC_LOCALIZ+SDC->DC_ITEM+_cOrdem}) // SDC->DC_LOCAL})
					If nPos == 0
						Aadd(_aItens,{SDC->DC_PRODUTO,SDC->DC_LOCALIZ,0.0,0.00,0.00,;
						              0.00,SDC->DC_ITEM,"","",0,0,_cOrdem}) // SDC->DC_LOCAL})
						nPos :=  Len(_aItens)
					EndIf
					_aItens[nPos,03] += SDC->DC_QUANT
					_aItens[nPos,04] := _aItens[nPos,03] * _nVlrUnit
					_aItens[nPos,05] := _aItens[nPos,03] * Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")
					_aItens[nPos,06] += _nTotEmb
					_aItens[nPos,11] += _nQtCxa // Quantidade de caixas
					_aItens[nPos,10] := (_aItens[nPos,03] * Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESO")) +_aItens[nPos,06]
					If !Empty(_cTpBob)
						_cTpBob += _aItens[nPos,08]
						_aItens[nPos,08] := ""
						For _x1 := 1 to 7
							_cx1 := Str(_x1,1)
							If _cx1 $ _cTpBob
								_aItens[nPos,08] += _cx1
							EndIf
						Next
					EndIf
				EndIf
				SDC->(DbSkip())
			EndDo
	
			// Verificar se não tem no SC9 produtos que estejam liberados mas não tem controle de localização
			DbSelectArea("SC6")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
			DbSelectArea("SB1")
			DbSetOrder(1) // B1_FILIAL+B1_COD
	
			DbSelectArea("SC9")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.)
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
	
				//Filtra Armazém      OK
				If (MV_PAR09=="10".And.SC9->C9_LOCAL#"10").Or.(MV_PAR09#"10".And.SC9->C9_LOCAL=="10")
					SC9->(DbSkip())
					Loop
				EndIf
	
				If Empty(SC9->C9_BLCRED+SC9->C9_BLEST) .And. SC9->C9_SEQOS == MV_PAR10
					SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO,.F.))
					If SB1->B1_LOCALIZ # "S"
						_cTES := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
						If Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_ESTOQUE") == "S"
							nPos :=  aScan(_aItens,{|x| x[1]+x[2]+x[7]+x[12]==SC9->C9_PRODUTO+Space(Len(SDC->DC_LOCALIZ))+SC9->C9_ITEM+"99"}) //SC9->C9_LOCAL})
							If nPos == 0
								Aadd(_aItens,{SC9->C9_PRODUTO,Space(Len(SDC->DC_LOCALIZ)),0.0,;
								              0.00,0.00,0.00,SC9->C9_ITEM,"","",0,0,"99"}) //SC9->C9_LOCAL})
								nPos :=  Len(_aItens)
							EndIf
							_nVlrUnit := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_PRCVEN")
							_aItens[nPos,03] += SC9->C9_QTDLIB
							_aItens[nPos,04] := (_aItens[nPos,03] * _nVlrUnit)
							_aItens[nPos,05] := (_aItens[nPos,03] * SB1->B1_PESCOB)
							_aItens[nPos,10] := (_aItens[nPos,03] * SB1->B1_PESO) + _aItens[nPos,06]
						EndIf
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo   
			
			ImprAItens(_aItens)
	
			DbSelectArea("SC5")
			DbSkip()
		EndDo
	Next
Return(.T.)


Static Function ImprAItens(_aItens)
	m_pag    := 01
	_nLi     := 80
	_nTotMt  := 0
	_nTotPs  := 0
	_nValTot := 0
	_nValTab := 0
	
	_nValTot  := 0
	_nValTab  := 0
	_nPesoTot := 0
	_nTotPes  := 0
	_nTotVen  := 0
	_aTotRel  := {} // {Qtd.Lances,Peso}
	Aadd(_aTotRel,{0,0}) // 1-Bobinas
	Aadd(_aTotRel,{0,0}) // 2-Carretéis
	Aadd(_aTotRel,{0,0}) // 3-Rolos de 100 metros
	Aadd(_aTotRel,{0,0}) // 4-Lances
	Aadd(_aTotRel,{0,0}) // 5-Blisters
	Aadd(_aTotRel,{0,0}) // 6-Outros
	// _aOrdens  := {"B","CM,"R00100","RT","L"} // Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters)
	
	aSort(_aItens,,,{|x,y| x[12]+x[1]+x[2]<y[12]+y[1]+y[2]})
	_cUltTot := ""
	For _nx := 1 to Len(_aItens)
		If lAbortPrint
			@ _nLi,00 PSay "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If _nLi > 60
			Titulo := "O R D E M   DE   S E P A R A C A O  -  N. " + SC5->C5_NUM + If(Empty(MV_PAR10),""," - "+MV_PAR10) + If(SC5->C5_CONDPAG=="000","  - B N D E S","")
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			_nLi := 7
			u_ImpCBFtr01(2,3,2) // Esta função está na CDFATR01 // Os parâmetros são para manter compatibilidade com a CDFATR01
		Endif
	
		If Empty(_cUltTot)
			_cUltTot := Left(_aItens[_nx,12],2)
			_cProduto := _aItens[_nx,1]
		EndIf
		If (_cUltTot == "01" .And. _cUltTot # Left(_aItens[_nx,12],2)) .Or. ;
			(_cUltTot #  "01" .And. !Empty(_cProduto) .And. Left(_cProduto,5) # Left(_aItens[_nx,1],5))
			@ _nLi,043 PSay "Quant. Metros ->"
			@ _nLi,062 PSay _nTotMt	Picture "@E 99,999,999"
			@ _nLi,093 PSay "Peso ->"
			@ _nLi++,101 PSay _nTotPs	Picture "@E 999,999.99"
			If (!lImpCb .And. Left(_aItens[_nx,12],2) # "01") .Or. _nLi == 19 // Não separar bobinas  // Acabei de imprimir o cabeçalho
				@ _nLi,000 PSay Replicate("-",limite)
				_nLi++
			Else
				lImpCb := .F.
			EndIf
			_cUltTot := Left(_aItens[_nx,12],2)
			_cProduto := _aItens[_nx,1]
			_nTotPs := 0
			_nTotMt := 0
		EndIf
		
		@ _nLi,000 PSay _aItens[_nx,7]
		@ _nLi,005 PSay _aItens[_nx,1] Picture If(Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_TIPO")=="PA","@R XXX.XX.XX.X.XX","XXXXXXXXXXXXXX")
		@ _nLi,020 PSay Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_DESC")),42)
		
		If lImpCb
			lImpCb := .F.
		EndIf
		
		_cAcondic := " "
		If Left(_aItens[_nx,2],1)=="R"
			_cAcondic := "Rolo"
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
		
		//_nPesoInd := (_aItens[_nx,3]* Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_PESO"))
		_nPesoInd := _aItens[_nx,10] /*/
		If Left(_aItens[_nx,2],1)=="B" // Se for Bobina, o peso no array 6 é total
			_nPesoInd := _aItens[_nx,10]
		Else
			_nPesoInd += _aItens[_nx,6]
		EndIf/*/
		
		@ _nLi,102 PSay _nPesoInd Picture "@E 999999.99"
		
		If _aItens[_nX,11] > 0 // Quantidade de Caixas
			@ _nli,112 PSay _aItens[_nx,11] Picture "@E 999"
			@ _nli,116 PSay "Caixa"+If(_aItens[_nx,11]>1,"s","")
		Else
			@ _nli,115 PSay  _aItens[_nx,8]
			If Left(_aItens[_nx,2],1)=="B" // Se for Bobina, o peso no array 6 é total
				If Len(AllTrim(_aItens[_nx,9])) > 7
					@ _nli,116 PSay  _aItens[_nx,9]
				Else
					@ _nli,123 PSay  _aItens[_nx,9]
				EndIf
			EndIf
		EndIf
		_nPesoTot += _nPesoInd
		
		_nTotPes += _nPesoInd
		_nTotVen += _aItens[_nx,4]
		
		_nTotMt += _aItens[_nx,3]
		_nTotPs += _nPesoInd
		
		_aTotRel[Val(Left(_aItens[_nx,12],2)),1] += If(Left(_aItens[_nx,12],2)=="05",_aItens[_nx,11],_nQtLance)	// Quant.Caixas ou Total de lances
		_aTotRel[Val(Left(_aItens[_nx,12],2)),2] += _nPesoInd 	// Total peso
		_nLi++
		
		If _nLi > 60
			//Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
			Titulo := "O R D E M   DE   S E P A R A C A O  -  N. " + SC5->C5_NUM + If(Empty(MV_PAR10),""," - "+MV_PAR10) + If(SC5->C5_CONDPAG=="000","  - B N D E S","")
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			_nLi := 7
			u_ImpCBFtr01(2,3,2) // Esta função está na CDFATR01 // Os parâmetros são para manter compatibilidade com a CDFATR01
		Endif
	Next
	
	If _nTotMt > 0 .Or. _nTotPs > 0
		@ _nLi,043 PSay "Quant. Metros ->"
		@ _nLi,062 PSay _nTotMt	Picture "@E 99,999,999"
		@ _nLi,093 PSay "Peso ->"
		@ _nLi++,101 PSay _nTotPs	Picture "@E 999,999.99"
		_nTotMt := 0
		_nTotPs := 0
	EndIf
	
	_cProduto := Space(15)
	@ _nLi++,000 PSay Replicate("-",limite)
	
	@ _nLi,082 PSay "PESO TOTAL (Kg)"
	@ _nLi,098 PSay _nPesoTot   Picture "@E 999,999.99"
	
	_nLi+=2
	@ _nLi,000 PSay "Cadastro Original: "+AllTrim(SC5->C5_USERINC) + " " + DToC(SC5->C5_DTINC) + " // " + ;
	"Cadastro Alterado: "+AllTrim(SC5->C5_USERALT) + " " + DToC(SC5->C5_DTALT)
	//Coloca Observação no Laudo
	@ ++_nLi,000 PSay "ORIENTAÇÕES: "
	
	If SC5->C5_LAUDO == "S"
		@ ++_nLi,000 PSay " *** NECESSÁRIO ENVIO DE LAUDO, FAVOR VERIFICAR! "
	EndIf
	
	If SA1->A1_XAGENTR == "S"
		@ ++_nLi,000 PSay " *** NECESSÁRIO REALIZAR AGENDAMENTO ENTREGA."
	EndIf
	_nLi++ // +=2
	If _nLi > 52
		//Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
		Titulo := "O R D E M   DE   S E P A R A C A O  -  N. " + SC5->C5_NUM + If(Empty(MV_PAR10),""," - "+MV_PAR10) + If(SC5->C5_CONDPAG=="000","  - B N D E S","")
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		_nLi := 7
		u_ImpCBFtr01(2,3,2) // Esta função está na CDFATR01 // Os parâmetros são para manter compatibilidade com a CDFATR01
		_nLi +=2
	EndIf
	
	@ ++_nLi,000 PSay " --------------------------------------------    --------------------------------------------"
	@ ++_nLi,000 PSay "| Acondic.       |Qtd.Lances/Cxs|  Peso Kg.  |  | Acondic.       |Qtd.Lances/Cxs|  Peso Kg.  |"
	@ ++_nLi,000 PSay "|----------------|--------------|------------|  |----------------|--------------|------------|"
	@ ++_nLi,000 PSay "| Bobinas        |  " + Transform(_aTotRel[1,1],"@E 9,999,999") + "   | " + Transform(_aTotRel[1,2],"@E 999,999.99") + " |  | Carreteis      |  " + Transform(_aTotRel[2,1],"@E 9,999,999") + "   | " + Transform(_aTotRel[2,2],"@E 999,999.99") + " |"
	@ ++_nLi,000 PSay "| Rolos 100m     |  " + Transform(_aTotRel[3,1],"@E 9,999,999") + "   | " + Transform(_aTotRel[3,2],"@E 999,999.99") + " |  | Lances # 100m  |  " + Transform(_aTotRel[4,1],"@E 9,999,999") + "   | " + Transform(_aTotRel[4,2],"@E 999,999.99") + " |"
	@ ++_nLi,000 PSay "| Blisters       |  " + Transform(_aTotRel[5,1],"@E 9,999,999") + " cx| " + Transform(_aTotRel[5,2],"@E 999,999.99") + " |  | Outros         |  " + Transform(_aTotRel[6,1],"@E 9,999,999") + "   | " + Transform(_aTotRel[6,2],"@E 999,999.99") + " |"
	@ ++_nLi,000 PSay " --------------------------------------------    --------------------------------------------"
	
	_aTotRel  := {} // {Qtd.Lances,Peso}
	Aadd(_aTotRel,{0,0}) // 1-Bobinas
	Aadd(_aTotRel,{0,0}) // 2-Carretéis
	Aadd(_aTotRel,{0,0}) // 3-Rolos
	Aadd(_aTotRel,{0,0}) // 4-Lances
	Aadd(_aTotRel,{0,0}) // 5-Blisters
	Aadd(_aTotRel,{0,0}) // 6-Outros
	
	_nLi := 59
	@ ++_nLi,02 PSay Replicate("-",128)
	@ ++_nLi,01 PSay "|       EMISSAO            |       SEPARADO POR        |       ENSACADO POR      |     CONFERIDO POR     |    NOME MOTORISTA     |"
	@ ++_nLi,01 PSay "|                          |                           |                         |                       |                       |"
	@ ++_nLi,01 PSay "|                          |                           |                         |                       |                       |"
	@ ++_nLi,01 PSay "|   _____/______/______    |    _____/______/______    |   _____/______/______   |  _____/______/______  |  _____/______/______  |"
	@ ++_nLi,02 PSay Replicate("-",128)
	
	If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))
		//Titulo := "O R D E M   DE   S E P A R A C A O  -  N. "+SC5->C5_NUM  + IIf(SC5->C5_CONDPAG=="000","  - B N D E S","")
		Titulo := "O R D E M   DE   S E P A R A C A O  -  N. " + SC5->C5_NUM + If(Empty(MV_PAR10),""," - "+MV_PAR10) + If(SC5->C5_CONDPAG=="000","  - B N D E S","")
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		_nLi := 9
		u_ChkLstHWEI() // Se tiver laudo para HUAWEI esta função tbm imprime
	ElseIf SC5->C5_LAUDO == "S"
		u_ChkLstLaud()
	EndIf
	_nLi+=60
	_nTotVen := 0
Return(.T.)


Static Function ValidPerg(cPerg)
	Private cPerg
	
	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	
	//If GetMv("MV_ZZUSAC9") // Trata o status no SC9
		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPerg,"01","Nro. Pedido     ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	//	aAdd(aRegs,{cPerg,"02","Sequência O.S.  ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Nro.de Vias     ?","mv_ch2","N",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Alt.Status para ?","mv_ch3","N",01,0,0,"C","","mv_par03","Normal","","","Em Separação","","","Em Faturamento","","","Não Altera","","","","",""})
	
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


Static Function JuntaSDC(_cNumPed,cStatus)
	Local _cNumPed,cStatus
	local aCanCancel := {}
	Local oStatic    := IfcXFun():newIfcXFun()
	// Esta rotina só deve ser acionada quando for alterar o Status do pedido DE/PARA Em Faturamento.
	
	// Se ocorreram liberações parciais no SC9 ou SDC, junta tudo em um único registro,
	// para gravar nas tabelas ZZR-Log das Liberações e ZZO - Volumes das Cargas.
	// Trata todos os SDCs que sejam da mesma chave FILIAL,PEDIDO,ITEM,ACONDIC
	DbSelectArea("SC5")
	DbSetOrder(1)
	If !DbSeek(xFilial("SC5")+_cNumPed,.F.)
		_lTemErro:=.T.
		Return(.T.)
	EndIf
	_cWork := "" // Não faz nada
	_C5_X_ULTOS := Space(Len(SC5->C5_X_ULTOS))
	If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) // Pedido já está EM FATURAMENTO
		If Empty(SC5->C5_X_ULTOS) .And. cStatus == '2' // Já está em faturamento e nunca houve uma liberação.
			_cWork := "N" // Cria (N)ova OS
		ElseIf cStatus $ "01" // Está tirando do FATURAMENTO
			_cWork := "E" // (E)storna a O.S.
		EndIf
	ElseIf SC5->C5_ZSTATUS # Padr('2',TamSX3("C5_ZSTATUS")[1]) // Pedido não está EM FATURAMENTO
		If cStatus == "2" // Está colocando em FATURAMENTO
			_cWork := "N" // Cria (N)ova OS
		EndIf
	EndIf
	
	If Empty(_cWork)  // Não faz nada
		If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) // Pedido já está EM FATURAMENTO
			DbSelectArea("ZZR") // Log das Liberações
			DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI
			DbSeek(xFilial("ZZR") + _cNumPed + SC5->C5_X_ULTOS,.F.)
			If ZZR->ZZR_SITUAC == "1"  .And. ZZR->(!Eof()) // Em Faturamento
				_C5_X_ULTOS := SC5->C5_X_ULTOS // Imprime o último desde que não esteja cancelado
			EndIf
		EndIf
	Else
		If _cWork == "E" // Estorna a O.S.
			aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(_cNumPed))
			if !aCanCancel[01]
				MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
					aCanCancel[02],'Bloqueado')
			else
				// Verificar se tem OS em faturamento e avisar usuário que vai cancelar a OS e os volumes
				//                                                                
				_lTemOS := .F. // Tem OS ? 
				_cOSIt  := " "
				DbSelectArea("ZZR") // Log das Liberações
				DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
				DbSeek(xFilial("ZZR") + _cNumPed,.F.)
				Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == _cNumPed .And. ZZR->(!Eof())
					If ZZR->ZZR_SITUAC == "1" // Em Faturamento
						_lTemOS := .T. // Tem OS ? 
						_cOSIt := ZZR->ZZR_PEDIDO + "-" + ZZR->ZZR_SEQOS
						Exit
					EndIf
					ZZR->(DbSkip())
				EndDo
		
				_lTemVl := .F. // Tem Volume ?
				DbSelectArea("ZZO")
				DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
				DbSeek(xFilial("ZZO") + _cNumPed,.F.)
				Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == _cNumPed .And. ZZO->(!Eof())
					If Empty(ZZO->ZZO_DOC) // Volume não faturado
						_lTemVl := .T. // Tem Volume ?
						Exit
					EndIf
					ZZO->(DbSkip())
				EndDo
				
				If _lTemOS .Or. _lTemVl // Tem OS ? ou Tem Volume ?
					_lTemErro := !(MsgBox("Atenção: " + Chr(13) + Chr(13) +;
								"Ordem de Separação " + _cOSIt + ;
								If(_lTemOS," 'Em Faturamento'","") + ;
								If(_lTemOS.And._lTemVl, " e ","") + ;
								If(_lTemVl,"'Com Volumes Montados'","") + Chr(13) + Chr(13) + ;
								"Confirma o Cancelamento " + ;
								If(_lTemOS,"da Ordem de Separação","") + ;
								If(_lTemOS.And._lTemVl, " e ",If(!_lTemVl,"?","")) + ;
								If(_lTemVl,"dos Volumes ?",""),"Confirma?","YesNo"))
				EndIf        
				If !_lTemErro
					Processa( {|| u_zLimpaOS(_cNumPed,cStatus)},"Estornando Ordem de Separação...")
				EndIf
			endif
		ElseIf _cWork == "N" // Cria nova OS
			Processa( {|| CriarOS(_cNumPed,cStatus)},"Aglutinando Dados das Liberações...")
			If !_lTemErro
				_C5_X_ULTOS := StrZero(1,Len(SC5->C5_X_ULTOS))
				DbSelectArea("ZZR") // Log das Liberações
				DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI
				DbSeek(xFilial("ZZR")+SC5->C5_NUM+_C5_X_ULTOS,.F.)
				Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == SC5->C5_NUM .And. ZZR->(!Eof())
					If ZZR->ZZR_SEQOS >= _C5_X_ULTOS
						_C5_X_ULTOS := StrZero(Val(ZZR->ZZR_SEQOS)+1,Len(SC5->C5_X_ULTOS))
					EndIf
					ZZR->(DbSkip())
				EndDo
				RecLock("SC5",.F.)
				SC5->C5_X_ULTOS := _C5_X_ULTOS
				MsUnLock()
				Processa( {|| CriarVl(_cNumPed,cStatus,_C5_X_ULTOS)},"Criando Log da Ordem de Separação")
			EndIf
		EndIf
		If !_lTemErro
			RecLock("SC5",.F.)
			SC5->C5_ZSTATUS := If(_cWork=="E","1",'2') // EM FATURAMENTO
			MsUnLock()
		EndIf
	EndIf
Return(_C5_X_ULTOS)

Static Function CriarOS(_cNumPed,cStatus)
	Local _cNumPed, cStatus, cQuery, _aDadDC, _nQtReg, _aDadC9, _nQtDC, _nQtC9
	
	cQuery := "SELECT DC_PEDIDO, DC_ITEM, DC_LOCAL, DC_LOCALIZ, DC_SEQ, DC_QUANT, DC.R_E_C_N_O_ AS NUMREG" // Não trocar a ordem ou excluir campos do select
	cQuery += " FROM "+RetSqlName("SDC") + " DC"
	cQuery += " 	INNER JOIN "+RetSqlName("SC9") + " C9"
	cQuery += " 	ON DC_FILIAL = C9_FILIAL"
	cQuery += " 	AND DC_PEDIDO = C9_PEDIDO"
	cQuery += " 	AND DC_ITEM = C9_ITEM"
	cQuery += " 	AND DC_SEQ = C9_SEQUEN"
	cQuery += " 	AND DC_PRODUTO = C9_PRODUTO"
	cQuery += " 	AND '  ' = C9_BLCRED"
	cQuery += " 	AND '  ' = C9_BLEST"
	cQuery += " 	AND '  ' = C9_SEQOS"
	cQuery += " 	AND DC.D_E_L_E_T_ = C9.D_E_L_E_T_"
	cQuery += " WHERE DC_FILIAL = '"+xFilial("SDC")+"'"
	cQuery += " AND DC_PEDIDO = '"+_cNumPed+"'"
	cQuery += " AND DC_ORIGEM = 'SC6'"
	cQuery += " AND DC.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY DC_PEDIDO, DC_ITEM, DC_LOCAL, DC_LOCALIZ, DC_SEQ"
	
	_aDadDC := u_QryArr(cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	If Len(_aDadDC) == 0
		Return(.F.)
	EndIf
	
	_nQtReg := Len(_aDadDC)
	
	cQuery := "SELECT C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_LOCAL, C9_QTDLIB, C9.R_E_C_N_O_ AS NUMREG" // Não trocar a ordem ou excluir campos do select
	cQuery += " FROM "+RetSqlName("SC9") + " C9"
	cQuery += "   INNER JOIN "+RetSqlName("SB1") + " B1"
	cQuery += " 	ON '  ' = B1_FILIAL"
	cQuery += " 	AND C9_PRODUTO = B1_COD"
	cQuery += " 	AND C9.D_E_L_E_T_ = B1.D_E_L_E_T_"
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery += " AND C9_PEDIDO = '"+_cNumPed+"'"
	cQuery += " AND C9_BLCRED = '  '"
	cQuery += " AND C9_BLEST = '  '"
	cQuery += " AND C9_SEQOS = '  '"
	cQuery += " AND C9.D_E_L_E_T_ = ''"
	cQuery += " AND B1_LOCALIZ = 'S'"
	cQuery += " ORDER BY C9_PEDIDO, C9_ITEM, C9_SEQUEN
	
	_aDadC9 := u_QryArr(cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	If Len(_aDadC9) == 0
		_lTemErro := .T.
		Return(.F.)
	EndIf
	
	// Somar o Array do SDC e comparar com a soma do array do SC9
	// se estiver igual, continua senão sai
	
	// _aDadDC -> {DC_PEDIDO, DC_ITEM, DC_LOCAL, DC_LOCALIZ, DC_SEQ, DC_QUANT, DC.R_E_C_N_O_}
	// _aDadC9 -> {C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_LOCAL, C9_QTDLIB, C9_BLEST, C9.R_E_C_N_O_ AS NUMREG}
	_nQtDC := 0
	For _nArray := 1 to Len(_aDadDC)
		// _aDadDC -> {DC_PEDIDO, DC_ITEM, DC_LOCAL, DC_LOCALIZ, DC_SEQ, DC_QUANT, DC.R_E_C_N_O_}
		_nQtDC += _aDadDC[_nArray,6]
	Next
	
	_nQtC9 := 0
	For _nArray := 1 to Len(_aDadC9)
		// _aDadC9 -> {C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_LOCAL, C9_QTDLIB, C9_BLEST, C9.R_E_C_N_O_ AS NUMREG}
		_nQtC9 += _aDadC9[_nArray,5]
	Next
	
	If _nQtDC # _nQtC9
		Alert("Erro nas quantidades Liberadas")
		_lTemErro := .T.
		Return(.F.)
	EndIf
	
	// Ordena o _aDadDC -> 1-DC_PEDIDO, 2-DC_ITEM, 3-DC_LOCAL, 4-DC_LOCALIZ, 5-DC_SEQ
	aSort(_aDadDC,,,{|x,y| x[01]+x[02]+x[03]+x[04]+x[05]<y[01]+y[02]+y[03]+y[04]+y[05]})
	
	// Ordena 0 _aDadC9 -> 1-C9_PEDIDO, 2-C9_ITEM, 4-C9_LOCAL, 3-C9_SEQUEN
	aSort(_aDadC9,,,{|x,y| x[01]+x[02]+x[04]+x[03]<y[01]+y[02]+y[04]+y[03]})
	
	_cChvDC := "" // 1-DC_PEDIDO + 2-DC_ITEM + 3-DC_LOCAL + 4-DC_LOCALIZ
	_nRegDC := 0
	_nRegC9 := 0
	_nRegBs := 0 // Acho um SC9 base para poder criar outro
	BeginTran()
	For _nArrDC := 1 to Len(_aDadDC)
		// _aDadDC -> {1-DC_PEDIDO, 2-DC_ITEM, 3-DC_LOCAL, 4-DC_LOCALIZ, 5-DC_SEQ, 6-DC_QUANT, 7-DC.R_E_C_N_O_}
	
		If _cChvDC  #  _aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,4]
			_cChvDC := _aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,4]
			_nRegDC := _aDadDC[_nArrDC,7]
			_nRegC9 := 0
			_nRegBs := 0
	
			// Acho o primeiro cara no array do SC9 e alinho o SDC com o SC9
			For _nArrC9 := 1 to Len(_aDadC9)
				// _aDadC9 -> {1-C9_PEDIDO, 2-C9_ITEM, 3-C9_SEQUEN, 4-C9_LOCAL, 5-C9_QTDLIB, 6-C9.R_E_C_N_O_ AS NUMREG}
				// _aDadDC -> {1-DC_PEDIDO, 2-DC_ITEM, 3-DC_LOCAL, 4-DC_LOCALIZ, 5-DC_SEQ, 6-DC_QUANT, 7-DC.R_E_C_N_O_}
				If (_aDadC9[_nArrC9,1]+_aDadC9[_nArrC9,2]+_aDadC9[_nArrC9,4]+_aDadC9[_nArrC9,3]) == ;
				   (_aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,5]) .And. _aDadC9[_nArrC9,5] > 0
				   // Achei um SC9 exatamente igual
					_nRegC9 := _aDadC9[_nArrC9,6]
					_aDadC9[_nArrC9,5] := 0 // Zero a quantidade para não mais usar este registro
					Exit
	
				 // _aDadC9 -> {1-C9_PEDIDO, 2-C9_ITEM, 3-C9_SEQUEN, 4-C9_LOCAL, 5-C9_QTDLIB, 6-C9.R_E_C_N_O_ AS NUMREG}
				 // _aDadDC -> {1-DC_PEDIDO, 2-DC_ITEM, 3-DC_LOCAL, 4-DC_LOCALIZ, 5-DC_SEQ, 6-DC_QUANT, 7-DC.R_E_C_N_O_}
				ElseIf (_aDadC9[_nArrC9,1]+_aDadC9[_nArrC9,2]+_aDadC9[_nArrC9,4]) == ;
					   (_aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3])
					// Acho um SC9 parecido
					_nRegBs := _aDadC9[_nArrC9,6]
				EndIf
			Next
			If _nRegC9 == 0
				// Criar novo SC9
				// Posiciono no SC9 parecido
				DbSelectArea("SC9")
				DbGoTo(_nRegBs)
				// Transfiro dados da base para a memória
				RegToMemory("SC9",.F.)
				M->C9_SEQUEN := "ZZ" // pra ir por último
				M->C9_QTDLIB := _aDadDC[_nArrDC,6]
				
				// Transfiro os dados da memória para o SC9
				_nQtCpo := SC9->(FCount())
				RecLock("SC9",.T.)
				For nCntFor := 1 To _nQtCpo
					FieldPut(nCntFor,M->&(FieldName(nCntFor)))
				Next
				MsUnLock()
				_nRegC9 := SC9->(Recno())
				// Alterar a sequencia do SC9
				DbSelectArea("SC9")
				DbSetOrder(1)
				DbGoTo(_nRegC9)
				DbSkip(-1) // Volto 1 Registro
				_cSequen := "00"
				If SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM == M->C9_FILIAL+M->C9_PEDIDO+M->C9_ITEM
					_cSequen := SC9->C9_SEQUEN
				EndIf       
				_cSequen := Soma1(_cSequen)
				DbGoTo(_nRegC9)
				If SC9->C9_SEQUEN # _cSequen
					RecLock("SC9",.F.)
					SC9->C9_SEQUEN := _cSequen
					MsUnLock()
				EndIf
				
				DbSelectArea("SDC")
				DbGoTo(_nRegDC)
				If SDC->DC_SEQ # _cSequen .Or. SDC->DC_TRT # "01"
					RecLock("SDC",.F.)
					SDC->DC_SEQ := _cSequen
					SDC->DC_TRT := "01"
					MsUnLock()
				EndIf
			Else
				// Posiciono no SC9 e troco a quantidade
				DbSelectArea("SC9")
				DbGoTo(_nRegC9)
				If SC9->C9_QTDLIB # _aDadDC[_nArrDC,6]
					RecLock("SC9",.F.)
					SC9->C9_QTDLIB := _aDadDC[_nArrDC,6]
					MsUnLock()
				EndIf
			EndIf
		Else // If _cChvDC == _aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,4]
			// Achei outro SDC com a mesma chave
			_nDelC9 := 0 // C9 a ser deletado
			For _nArrC9 := 1 to Len(_aDadC9)
				// _aDadC9 -> {1-C9_PEDIDO, 2-C9_ITEM, 3-C9_SEQUEN, 4-C9_LOCAL, 5-C9_QTDLIB, 6-C9.R_E_C_N_O_ AS NUMREG}
				// _aDadDC -> {1-DC_PEDIDO, 2-DC_ITEM, 3-DC_LOCAL, 4-DC_LOCALIZ, 5-DC_SEQ, 6-DC_QUANT, 7-DC.R_E_C_N_O_}
				If (_aDadC9[_nArrC9,1]+_aDadC9[_nArrC9,2]+_aDadC9[_nArrC9,4]+_aDadC9[_nArrC9,3]) == ;
				   (_aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,5]) .And. _aDadC9[_nArrC9,5] > 0
				   // Achei um SC9 exatamente igual
					_nDelC9 := _aDadC9[_nArrC9,6]
					_aDadC9[_nArrC9,5] := 0 // Zero a quantidade para não mais usar este registro
					Exit
				EndIf
			Next
	
			// Localizo o SDC correspondente e deleto
			DbSelectArea("SDC")
			DbGoTo(_aDadDC[_nArrDC,7])
			RecLock("SDC",.F.)
			DbDelete()
			MsUnLock()
	
			// Localizo o SDC vigente e adiciono a quantidade
			DbGoTo(_nRegDC)
			RecLock("SDC",.F.)
			SDC->DC_QUANT   += _aDadDC[_nArrDC,6]
			SDC->DC_QTDORIG += _aDadDC[_nArrDC,6]
			MsUnLock()
	
			If _nDelC9 # 0 // C9 a ser deletado
				// Localizo o SC9 e Deleto
				DbSelectArea("SC9")
				DbGoTo(_nDelC9)
				RecLock("SC9",.F.)
				DbDelete()
				MsUnLock()
				_nDelC9 := 0 // Zero a variável para não ter problemas.
			EndIf
	
			// Localizo o SC9 e adiciono a quantidade
			DbSelectArea("SC9")
			DbGoTo(_nRegC9)
			RecLock("SC9",.F.)
			SC9->C9_QTDLIB += _aDadDC[_nArrDC,6]
			MsUnLock()
		EndIf
	Next
	EndTran()
Return(.T.)


Static Function CriarVl(_cNumPed,cStatus,_C5_X_ULTOS)
	Local _cNumPed, cStatus, cQuery, _aDadC9DC, _nQtReg, _aDadC9, _nQtDC, _nQtC9,_C5_X_ULTOS
	// Tem que partir do SC9 pois pode ter itens que não contolam localização mas controla estoque
	
	cQuery := "SELECT C9_PEDIDO, C9_ITEM, C9_LOCAL, C9_SEQUEN, C9_QTDLIB, C9.R_E_C_N_O_ AS REG_C9,"
	cQuery += "       ISNULL(DC_LOCALIZ,' ') as DC_LOCALIZ, ISNULL(DC_SEQ,' ') as DC_SEQ, ISNULL(DC_QUANT,0) as DC_QUANT, ISNULL(DC.R_E_C_N_O_,0) AS REG_DC,"
	cQuery += "       B1_PESCOB, B1_PESPVC, C9_PRODUTO, B1_DESC, B1_UM, B1_LOCALIZ"  // Não trocar a ordem ou excluir campos do select
	cQuery += " FROM "+RetSqlName("SC9") + " C9"
	cQuery += "    LEFT JOIN "+RetSqlName("SDC") + " DC"
	cQuery += "        ON  C9_FILIAL     = DC_FILIAL"
	cQuery += "        AND C9_PRODUTO    = DC_PRODUTO"
	cQuery += "        AND C9_LOCAL      = DC_LOCAL"
	cQuery += "        AND 'SC6'         = DC_ORIGEM"
	cQuery += "        AND C9_PEDIDO     = DC_PEDIDO"
	cQuery += "        AND C9_ITEM       = DC_ITEM"
	cQuery += "        AND C9_SEQUEN     = DC_SEQ"
	cQuery += "        AND C9.D_E_L_E_T_ = DC.D_E_L_E_T_"
	cQuery += "    INNER JOIN "+RetSqlName("SB1") + " B1"
	cQuery += "        ON  '  '          = B1_FILIAL"
	cQuery += "        AND C9_PRODUTO    = B1_COD"
	cQuery += "        AND C9.D_E_L_E_T_ = B1.D_E_L_E_T_"
	cQuery += "    INNER JOIN "+RetSqlName("SC6") + " C6"
	cQuery += "        ON  C9_FILIAL     = C6_FILIAL"
	cQuery += "        AND C9_PEDIDO     = C6_NUM"
	cQuery += "        AND C9_ITEM       = C6_ITEM"
	cQuery += "        AND C9.D_E_L_E_T_ = C6.D_E_L_E_T_"
	cQuery += "    INNER JOIN "+RetSqlName("SF4") + " F4"
	cQuery += "        ON  '  '          = F4_FILIAL"
	cQuery += "        AND C6_TES        = F4_CODIGO"
	cQuery += "        AND C6.D_E_L_E_T_ = F4.D_E_L_E_T_"
	cQuery += " WHERE C9_FILIAL  = '"+xFilial("SC9")+"'"
	cQuery += "	 AND C9_PEDIDO = '"+_cNumPed+"'"
	cQuery += "	 AND C9_BLCRED = '  '"
	cQuery += "  AND C9_BLEST  = '  '"
	cQuery += "	 AND C9_SEQOS  = '  '"
	cQuery += "	 AND C9.D_E_L_E_T_ = ''"
	cQuery += "	 AND F4.F4_ESTOQUE = 'S'"
	cQuery += " ORDER BY C9_PEDIDO, C9_ITEM, C9_LOCAL, DC_LOCALIZ, DC_SEQ"
	_aDadC9DC := u_QryArr(cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	If Len(_aDadC9DC) == 0
		Return(.F.)
	EndIf
	
	DbSelectArea("ZZR")  // Log das Liberações
	DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
	
	For _nArrC9DC := 1 to Len(_aDadC9DC)
	
		// _aDadC9DC -> {01-C9_PEDIDO              , 02-C9_ITEM,    03-C9_LOCAL,   04-C9_SEQUEN, 05-C9_QTDLIB, 
		//               06-C9.R_E_C_N_O_ AS REG_C9, 07-DC_LOCALIZ, 08-DC_SEQ,     09-DC_QUANT,  10-DC.R_E_C_N_O_ AS REG_DC, 
		//               11-B1_PESCOB,               12-B1_PESPVC,  13-C9_PRODUTO, 14-B1_DESC,   15-B1_UM
		//               16-B1_LOCALIZ
	
		DbSelectArea("SC9")
		DbGoTo(_aDadC9DC[_nArrC9DC,06])
		If SC9->C9_SEQOS # _C5_X_ULTOS
			RecLock("SC9",.F.)
			SC9->C9_SEQOS := _C5_X_ULTOS
			MsUnLock()
		EndIf
		
		If Empty(_aDadC9DC[_nArrC9DC,07])
			// Não está controlando localização
			_cAcond    := " "
			_nTamLance := 1
			_nQtdLance := Int(_aDadC9DC[_nArrC9DC,05] / _nTamLance) // Quantidade do SC9
		Else
			_cAcond    := Left(_aDadC9DC[_nArrC9DC,07],1)           // Acondicionamento RBCMTL
			_nTamLance := Val(Substr(_aDadC9DC[_nArrC9DC,07],2,5))  // Tamanho do lance
			_nQtdLance := Int(_aDadC9DC[_nArrC9DC,09] / _nTamLance) // Quantidade de lances
		EndIf
		_aBobs := {} // {Nro.Bob,PesoLiquido,Tara,PesoBruto}
		If _cAcond == "B"
			// Procurar as bobinas empenhadas para este item
			DbSelectArea("SZE")
			DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
			DbSeek(xFilial("SZE")+_aDadC9DC[_nArrC9DC,01]+_aDadC9DC[_nArrC9DC,02],.F.)
			_nQtdBobs := 0
			Do While SZE->ZE_FILIAL == xFilial("SZE")      .And. SZE->ZE_PEDIDO == _aDadC9DC[_nArrC9DC,01] .And. ;
			         SZE->ZE_ITEM   == _aDadC9DC[_nArrC9DC,02] .And. Len(_aBobs) < _nQtdLance              .And. SZE->(!Eof())
				If SZE->ZE_STATUS == "E" .And. Empty(SZE->ZE_SEQOS) .And. Int(SZE->ZE_QUANT) ==  _nTamLance .And. (_nQtdBobs+SZE->ZE_QUANT) <= _aDadC9DC[_nArrC9DC,09]
					If SZE->ZE_SEQOS # _C5_X_ULTOS
						RecLock("SZE",.F.)
						SZE->ZE_SEQOS := _C5_X_ULTOS
						MsUnLock()
						_nQtdBobs += SZE->ZE_QUANT
					EndIf
					aAdd(_aBobs, {SZE->ZE_NUMBOB,SZE->ZE_PLIQ,SZE->ZE_TARA,SZE->ZE_PESO})
				EndIf
				SZE->(DbSkip())
			EndDo
		EndIf
		//DbSelectArea("ZZO") // Volumes das cargas
		For _nQtdRegs := 1 To If(_cAcond == "B",_nQtdLance,1)
			_ZZR_QTCAIX := 1 // Quantidade de lances por caixa. Se não for caixa gravar 1
			_ZZR_EMBALA := 0 // Peso da embalagem: Caixa, Saco, Cartela, carretel, Ilhos ou peso da bobina
	
			If !_cAcond $ " B" // Calcular somente se não for bobina -> Outros Acondicionamentos -> Calcular
				// _aDadC9DC -> {01-C9_PEDIDO              , 02-C9_ITEM,    03-C9_LOCAL,   04-C9_SEQUEN, 05-C9_QTDLIB, 
				//               06-C9.R_E_C_N_O_ AS REG_C9, 07-DC_LOCALIZ, 08-DC_SEQ,     09-DC_QUANT,  10-DC.R_E_C_N_O_ AS REG_DC, 
				//               11-B1_PESCOB,               12-B1_PESPVC,  13-C9_PRODUTO, 14-B1_DESC,   15-B1_UM
				//               16-B1_LOCALIZ
				_aResult    := CalcEmb(_aDadC9DC[_nArrC9DC,13], _aDadC9DC[_nArrC9DC,07], _aDadC9DC[_nArrC9DC,09]) // (_cProd,_cLocaliz, _nQuant)
				_ZZR_EMBALA := _aResult[1] // Peso da embalagem: Caixa, Saco, Cartela, carretel, Ilhos ou peso da bobina
				_ZZR_QTCAIX := Max(_aResult[2],1) // Quantidade de lances por caixa. Se não for caixa gravar 1
			EndIf
			
			DbSelectArea("ZZR") // Log das O.S.
			RecLock("ZZR",.T.)
			ZZR->ZZR_FILIAL := xFilial("ZZR")
			ZZR->ZZR_PEDIDO := _aDadC9DC[_nArrC9DC,01]
			ZZR->ZZR_ITEMPV := _aDadC9DC[_nArrC9DC,02]
			ZZR->ZZR_SEQUEN := _aDadC9DC[_nArrC9DC,04]
			ZZR->ZZR_SEQOS  := _C5_X_ULTOS
			ZZR->ZZR_PRODUT := _aDadC9DC[_nArrC9DC,13]
			ZZR->ZZR_DESCRI := _aDadC9DC[_nArrC9DC,14]
			ZZR->ZZR_QUAN   := If(_cAcond == "B",_nTamLance,If(_cAcond == " ",_aDadC9DC[_nArrC9DC,05],_aDadC9DC[_nArrC9DC,09]))
							// Se bobina, Tam.Bobina -> Se não tem acondic, Quant.do C9 -> Se tem acondic e não é bobina, quant.do DC
			ZZR->ZZR_DATA   := Date()
			ZZR->ZZR_HORA   := Time()
			ZZR->ZZR_LOCAL  := _aDadC9DC[_nArrC9DC,03]
			ZZR->ZZR_LOCALI := _aDadC9DC[_nArrC9DC,07]
			ZZR->ZZR_NROBOB := If(_cAcond == "B",If(_nQtdRegs<=Len(_aBobs),_aBobs[_nQtdRegs,1],"")," ")
			ZZR->ZZR_LANCES := If(_cAcond == "B",1,_nQtdLance)
			ZZR->ZZR_QTCAIX := Max(_ZZR_QTCAIX,1) // Quantidade de lances por caixa. Se não for caixa, gravar sempre 1
			ZZR->ZZR_EMBALA := If(_cAcond == "B",If(_nQtdRegs<=Len(_aBobs),_aBobs[_nQtdRegs,3],0),_ZZR_EMBALA)
			ZZR->ZZR_PESPRO := If(_cAcond == "B",If(_nQtdRegs<=Len(_aBobs),_aBobs[_nQtdRegs,2],0),ZZR->ZZR_QUAN * (_aDadC9DC[_nArrC9DC,11]+_aDadC9DC[_nArrC9DC,12]))
			ZZR->ZZR_USUARI := cUserName
			ZZR->ZZR_SITUAC := '1' // 1-Em Faturamento - 2-Faturada - 9-Cancelada
			If Empty(ZZR->ZZR_LOCALI) // Não tem acondicionamento -> Busco no SB1
				ZZR->ZZR_BARINT := Posicione("SB1",1,xFilial("SB1")+ZZR->ZZR_PRODUT,"B1_CODBAR")
			ElseIf Left(ZZR->ZZR_LOCALI,1) == "B" // É uma bobina
				ZZR->ZZR_BARINT := "96" + Posicione("SZE",1,xFilial("SZE")+ZZR->ZZR_NROBOB,"ZE_FILORIG") + StrZero(Val(ZZR->ZZR_NROBOB),7)
			Else // Tem acondicinamento e não é bobina
				ZZR->ZZR_BARINT := Posicione("ZAA",1,xFilial("ZAA")+Left(ZZR->ZZR_PRODUT,10)+AllTrim(ZZR->ZZR_LOCALI),"ZAA_BARINT")
			EndIf
			MsUnLock()
		Next
	Next
Return(.T.)


Static Function CalcEmb(_cProd,_cLocaliz, _nQuant)
	// Efetua cálculo de embalagens para blisters, encartelados, carretéis
	Local _cProd,_cLocaliz, _nQuant
	Local _nTotEmb := 0
	Local _nQtCxa  := 0
	Local _cTpBob  := ""
	Local _nRolCx  := 1
	Local _nQtdLc  := _nQuant / Val(Substr(_cLocaliz,2,15))
	local aInfAcond:= {}
	
	If AllTrim(_cLocaliz) == "R00015" // Rolo de 15 metros
		// Se for rolo de 15 Encartelado
		_nRolCx := 0
		If Left(_cProd,3) == "115"  // Cabo Flexicom
			If Substr(_cProd,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 vão 10 rolos por caixa
				_nRolCx := 10
			ElseIf Substr(_cProd,4,2) $ "06/07" //Se for cabo flex 4 ou 6     vão 08 rolos por caixa
				_nRolCx := 8
			ElseIf Substr(_cProd,4,2) == "08" //Se for cabo flex 10         vão 06 rolos por caixa
				_nRolCx := 6
			EndIf
		ElseIf Left(_cProd,3) == "120"  .And. Substr(_cProd,4,2) $ "04/05"// Cordão Paralelo 1,5 ou 2,5
			_nRolCx := 8
		EndIf
		_nQtCxa   := Int(_nQtdLc/_nRolCx)
		_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unitário do conjunto de ilhós em gramas
		_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unitário do saco plastico     em gramas
		_nCart    := (_nQtdLc*8.5232)/1000        // Peso unitário da cartela de papel  em gramas
		_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unitário da caixa de papelão  em kilos
		_nTotEmb  := (_nIlhos+_nSaco+_nCart+_nCaixa)
	elseif Left(_cLocaliz,1) == "L" // Blister de 15 metros
		aInfAcond := u_cbcAcInf(Alltrim(_cProd), AllTrim(_cLocaliz), , _nQtdLc, , .T., .F.,.T.)
		_nRolCx	  := aInfAcond[3,2]
		_nTotEmb  := aInfAcond[2,2]
	ElseIf Left(_cLocaliz,1) == "M" // Carretel
		_nTotEmb := (_nQtdLc*1.45)
	ElseIf Left(_cLocaliz,1) == "C" // Carretel
		_nTotEmb := (_nQtdLc*2.00)
	EndIf
Return({_nTotEmb,_nRolCx})


Static Function ImprZZR()
	// A impressão é feita pelo log das liberações 
	// Carregar o Array _aItens e chamar a função Static Function ImprAItens()
	_aItens := {}	// {1-Produto      ,2-localiz        ,3-quant                  ,4-VALOR TOTAL,
					//  5-peso cobre   ,6-???            ,7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina,
					//  9-Num.Da Bobina,10-Peso do Item  ,11-Quant.Volumes         ,12-Local
									
	DbSelectArea("ZZR")
	DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI
	DbSeek(xFilial("ZZR")+MV_PAR01+MV_PAR10,.F.)
	Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == MV_PAR01 .And. ZZR->ZZR_SEQOS == MV_PAR10 .And. ZZR->(!Eof())
		// Elementos de _aItens
		// {1-Produto,   2-localiz,3-quant,                  4-VALOR TOTAL,
		//  5-peso cobre,6-???,    7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina}
		// Atenção: Para bobinas ainda em mais elementos
		//  9-Num.Da Bobina   10-Peso da Bobina 11-Quant.Caixas  12-Ordem impressao
	
		For _cOrdem := 1 to Len(_aOrdens)
			If AllTrim(ZZR->ZZR_LOCALI) $ _aOrdens[_cOrdem]
				Exit
			ElseIf Left(ZZR->ZZR_LOCALI,1) $ _aOrdens[_cOrdem] .And. _aOrdens[_cOrdem] # "R00100"
				Exit
			EndIf
		Next            
		
		_cOrdem := StrZero(_cOrdem,2)	
		
		If Empty(ZZR->ZZR_LOCALI)
			_cOrdem := "06" // Outros
		ElseIf !Empty(ZZR->ZZR_NROBOB)
			DbSelectArea("SZE")
			DbSetOrder(1)
			DbSeek(xFilial("SZE")+ZZR->ZZR_NROBOB,.F.)
			_cOrdem += SZE->ZE_TPBOB + Right(ZZR->ZZR_NROBOB,1) + ZZR->ZZR_NROBOB // Ordem + Tp.Bobina + Final Nro Bob. + O próprio nro da bobina
		EndIf
	
		Aadd(_aItens,{	ZZR->ZZR_PRODUT,;	//1
						ZZR->ZZR_LOCALI,;	//2
						ZZR->ZZR_QUAN, 	;	//3
						0 ,;				//4
						(ZZR->ZZR_QUAN*Posicione("SB1",1,xFilial("SB1")+ZZR->ZZR_PRODUT,"B1_PESCOB")),;	//5
						0.00,;	//6
						ZZR->ZZR_ITEMPV,;	//7
						If(Empty(ZZR->ZZR_NROBOB)," ",SZE->ZE_TPBOB),;	//8
						ZZR->ZZR_NROBOB,;	//9
						(ZZR->ZZR_EMBALA+ZZR->ZZR_PESPRO),;	//10
						IIf(ZZR->ZZR_QTCAIX > 1,(ZZR->ZZR_LANCES / ZZR->ZZR_QTCAIX),0),;//11
						_cOrdem})			//12

		ZZR->(DbSkip())
	EndDo              
	If Len(_aItens) > 0
		ImprAItens(_aItens)
	EndIf
Return(.T.)
