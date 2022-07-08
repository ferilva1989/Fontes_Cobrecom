#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} CBCOrSep
//TODO Relatório de Ordens de Separação
     Realizado filtro por grupo de usuarios para ques ejam exibidos valores de venda.
   Ordem do relatório para apresentar conforme: Bobinas, Carretéis, Rolos-
   Retalhos e Blisters, quantidades de lances e pesos por bloco e totais.
@author Juliana.leme  
@since 05/06/2016
@version 1.0
@param _cPedido, , descricao
@type function
/*/
User Function CBCOrSep(_cPedido)  //152903  U_CBCOrSep("203874") 
	Local lAchou			:= .F.
	Local aUserCB			:= {}
	Private lValorFat		:= .F.
	Private nLin 			:= 0
	Private oFont10N	:= TFont():New( "Arial",,10,,.T.,,,,.T.,.F.)
	Private oFont11N	:= TFont():New( "Arial",,11,,.T.,,,,.T.,.F.)
	Private oFont12 		:= TFont():New( "Arial",,12,,.T.,,,,   ,.F.)
	Private oFont12N	:= TFont():New( "Arial",,12,,.T.,,,,.T.,.F.)
	Private oFont14N	:= TFont():New( "Arial",,14,,.T.,,,,.T.,.F.)
	Private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	Private oFont18N	:= TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)
	Private oPrn			
	Private Cabec1      	:= ""
	Private Cabec2     	:= ""
	Private Titulo			:= "Ordem de Separacao - EXP"
	Private cPerg			:= "CDFTR01B"//"CDFTR01B" //CDFATR01
	Private lImpCb		:= .F.
	Private _aItens
	
	PswOrder(2)
	lAchou 		:= PSWSeek(cUserName)
	aUserCB 		:= PswRet(1)
	lValorFat		:= .F.
	
	If lAchou
		//Percorre todos os grupos do usuario autorizado a cancelar a pesagem
		For i := 1 To Len(aUserCB[1][10])
			If aUserCB[1][10][i] == "000103"
				lValorFat := .T.
			Else
				lValorFat := .F.
			EndIf
		Next
	EndIf
	
		
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("ZZO") // Volumes das O.S.
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	
	DbSelectArea("ZZR") // Log das Liberações
	DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
	
	ValidPerg(cPerg)
	
	If Valtype(_cPedido) # "U" 
		Pergunte(cPerg,.F.)
		MV_PAR01 := _cPedido
		Mv_Par02 := _cPedido
		MV_PAR08 := "4"
		Mv_PAR09 := "01"
	
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
	
	if (Pergunte(cPerg,.T.))
		DbSelectArea("SC5")
		DbSetOrder(1)	

		RunReport(Cabec1,Cabec2,Titulo,nLin)
	endif
Return(.T.)


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _cStatus		:= ""
	Local _NewSeq		:= ""
	local cSeqIni		:= ""
	local cSeqFim		:= ""
	Private _lTemErro	:= .F.
	Private _cProduto	:= Space(15)
	Private _nTotMt		:= 0
	Private _nTotPs		:= 0
	Private _nValTot		:= 0
	Private _nValTab		:= 0
	Private _aOrdens		:= {"B","CM","R00100","RT","L"," "} // Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters)
	Private _cOrdem
	Private lRetorna		:= .T.
	Private lFatur			:= IIf(!Empty(Alltrim(MV_PAR05)),.T.,.F.)	

	MV_PAR10 := IIf(!Empty(Alltrim(MV_PAR05)),MV_PAR05,"  ")		// Novo -> Sequência O.S.?
	MV_PAR09 := IIf(Empty(Alltrim(MV_PAR04)),"01",MV_PAR04)	// Qual Armazém    ?
	MV_PAR08 := MV_PAR03	// Alt.Status para ?
	MV_PAR07 := "ZZ"		// Até a Loja      ?
	MV_PAR06 := "ZZZZZZ"	// Até o Cliente   ?
	MV_PAR05 := "  "		// Da Loja         ?
	MV_PAR04 := "      "	// Do Cliente      ?
	MV_PAR03 := MV_PAR02	// Nro.de Vias     ?
	MV_PAR02 := MV_PAR01	// Até o Pedido    ?
	MV_PAR01 := MV_PAR01	// Do Pedido       ?
	MV_PAR03 := Max(MV_PAR03,1)
	
	_cStatus := Str(MV_PAR08-1,1) //mv_par08","Normal","","","Em Separação","","","Em Faturamento","","","Não Altera","","","","",""})
	
	If _cStatus == "2" // Alterar o Status para Em Faturamento
		MV_PAR10 := "  "		// Novo -> Sequência O.S.? // A Seq.tem que estar em branco
	EndIf
	
	_NewSeq := JuntaSDC(MV_PAR01,_cStatus, @cSeqIni, @cSeqFim)
	
	If !_lTemErro
		if !empty(cSeqIni) .and. !empty(cSeqFim)
			_NewSeq := cSeqIni
		else
			cSeqIni := _NewSeq
			cSeqFim := _NewSeq
		endif
		do while(_NewSeq <=  cSeqFim /*.and. !empty(_NewSeq)*/)
			If _cStatus $ "01" // "Normal","","","Em Separação"
				MV_PAR10 := "  " // 
			ElseIf _cStatus $ "23"
				MV_PAR10 := IIf(!Empty(Alltrim(MV_PAR10)),MV_PAR10,_NewSeq)		// Novo -> Sequência O.S.? // A Seq.tem que estar em branco
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
			
			oPrn := FWMsPrinter():New("CBCOrdSep_"+MV_PAR01+"_"+Alltrim(_NewSeq),IMP_PDF,.T.,"\OrdSep\",.T.,,,,.T.)
			oPrn:SetLandscape()	// Formato pagina Paisagem
			oPrn:SetPaperSize(9)	//Papel A4
			oPrn:SetMargin(GPixel(05),GPixel(05),GPixel(05),GPixel(05))
			oPrn:SetViewPDF(.T.)	

			If Empty(MV_PAR10) // Imprime da forma normal considerando SC9, SC6, SDC, SZE, ETC
				U_ImprSC5()
			Else
				ImpZZR()
			EndIf
			oPrn:EndPage()
			oPrn:Preview()
			FreeObj(oPrn)
			_NewSeq := Soma1(_NewSeq)
			if _cStatus == "2"
				MV_PAR10 := "  "
			endIf
		endDo
	EndIf
	
	
Return(.T.)


/*/{Protheus.doc} ImpSC5
//TODO Descrição auto-gerada.
@author juliana.leme
@since 28/06/2018
@version 1.0

@type function
/*/
User Function ImprSC5()
	Local _nTotMt 	:= 0
	Local _nTotPs		:= 0
	Local _nValTot	:= 0
	Local _nValTab	:= 0
	Local _aItens		:= {}
	Local _lTem		:= .F.
	Local _cTES		:= ""
	Local	_nTotVen	:= 0.00
	Local _nTotCus	:= 0.00
	Local _nTotPes	:= 0.00
	local aInfAcondi:={}
	
	_nTotMt	:= 0
	_nTotPs	:= 0
	_nValTot	:= 0
	_nValTab	:= 0
	//SetRegua(RecCount())
	DbSeek(xFilial("SC5")+Mv_Par01,.T.)
	Do While SC5->C5_NUM <= Mv_Par02 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())

		//IncRegua()

		If oPrn:Canceled()
			oPrn:Say(GPixel(5),GPixel(5),"*** CANCELADO PELO OPERADOR ***",oFont16N)
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
				Loop                               
			EndIf
		EndIf

		_aItens := {}	// {1-Produto      ,2-localiz        ,3-quant                  ,4-VALOR TOTAL,
						//  5-peso cobre   ,6-???            ,7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina,
						//  9-Num.Da Bobina,10-Peso do Item  ,11-Quant.Volumes         ,12 - ,13-Local
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

			If Left(SDC->DC_LOCALIZ,1) == "B"
				SC9->(DbSetOrder(1))  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

				_nQtdLc := 0 // Aqui eu Zero pois vou fazer um loop no SDC
				_nUltReg := SDC->(Recno())
				_cChvSDC := SDC->DC_PEDIDO+SDC->DC_ITEM
				_aDadSDC := {} // {Acondic,Quantidade,QtdLance}
				Do While SDC->DC_FILIAL == xFilial("SDC") .And. Left(SDC->DC_LOCALIZ,1) == "B" .And. ;
					SDC->DC_PEDIDO+SDC->DC_ITEM == _cChvSDC .And. SDC->(!Eof())
					_nUltReg := SDC->(Recno())
					If SDC->DC_ORIGEM == "SC6" // Somente os liberados para faturamento
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
						// Elementos de _aItens {1-Produto,2-localiz,3-quant,4-VALOR TOTAL,5-peso cobre,6-???,7-ITEM DO PEDIDO DE VENDA,8-Tipo da Bobina}
						// Atenção: Para bobinas ainda em mais elementos {9-Num.Da Bobina   10-Peso da Bobina 11-Quant.Caixas 12-Ordem Impressao, 13 - Local}

						_nQtItem := (_aDadSDC[_nLoop1,2]/_aDadSDC[_nLoop1,3])
						Aadd(_aItens,{	SDC->DC_PRODUTO,_aDadSDC[_nLoop1,1],_nQtItem,(_nQtItem*_nVlrUnit),;
									   (_nQtItem*Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")),;
									   0.00,SDC->DC_ITEM," ","BOB.NAO LOCALIZ",0,0,_cOrdem,SDC->DC_LOCAL})

						// Atrelar uma bobina ao Item
						// Elementos da _aNumBob {1-Acondic.,2-Num.Bob,3-Peso Bobina,4-Tipo Bobina,5-Flag se já usado}
						For _nLoop3 := 1 To Len(_aNumBob)
							If _aNumBob[_nLoop3,1] == _aItens[Len(_aItens),2] .And. Empty(_aNumBob[_nLoop3,5])
								// Mesmo acondicionamento?
								_aItens[Len(_aItens),08] := _aNumBob[_nLoop3,4] // Tipo da Bobina
								_aItens[Len(_aItens),09] := _aNumBob[_nLoop3,2] // Numero da Bobina
								_aItens[Len(_aItens),10] := _aNumBob[_nLoop3,3] // Peso da bobina
								_aItens[Len(_aItens),12] += _aNumBob[_nLoop3,4]+Right(_aNumBob[_nLoop3,2],1) // Ordem + Tp.Bobina + Final Nro Bob. + O próprio nro da bobina
																																				//Ordem + Tipo da Bobinha + Produto + Tamanho do Lance	
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
					              0.00,SDC->DC_ITEM,"","",0,0,_cOrdem,SDC->DC_LOCAL}) 
					nPos :=  Len(_aItens)
				EndIf
				_aItens[nPos,03] += SDC->DC_QUANT
				_aItens[nPos,04] := _aItens[nPos,03] * _nVlrUnit
				_aItens[nPos,05] := _aItens[nPos,03] * Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESCOB")
				_aItens[nPos,06] += _nTotEmb
				_aItens[nPos,11] += _nQtCxa // Quantidade de caixas
				_aItens[nPos,10] := (_aItens[nPos,03] * Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_PESO")) +_aItens[nPos,06]
				_aItens[nPos,13] := SDC->DC_LOCAL
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
							              0.00,0.00,0.00,SC9->C9_ITEM,"","",0,0,"99",SC9->C9_LOCAL})
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
Return(.T.)


Static Function ImprAItens(_aItens, aJoinCab)
	Local _nTotMt  	:= 0
	Local _nTotPs  	:= 0
	Local _nValTot 	:= 0
	Local _nValTab 	:= 0
	Local _nPesoTot := 0
	Local _nTotPes  := 0
	Local _nTotVen  := 0
	Local _aTotRel  := {} // {Qtd.Lances,Peso}
	local oCarga 	:= cbcCtrlCarga():newcbcCtrlCarga(,.F.)
	local oVol   	:= cbcCtrlVolum():newcbcCtrlVolum()
	Local oStatic   := IfcXFun():newIfcXFun()
	local aVol 	 	:= {}
	local oFontVol	:= TFont():New("Arial",,25,,.T.)
	local cOS		:= ''
	Private nFolha 	:= 1
	default aJoinCab:= {}

	if empty(aJoinCab)
		cOS := SC5->C5_NUM + If(Empty(MV_PAR10),"",MV_PAR10)
	else
		cOS := aJoinCab[01]
	endif

	Aadd(_aTotRel,{0,0}) // 1-Bobinas
	Aadd(_aTotRel,{0,0}) // 2-Carretéis
	Aadd(_aTotRel,{0,0}) // 3-Rolos de 100 metros
	Aadd(_aTotRel,{0,0}) // 4-Lances
	Aadd(_aTotRel,{0,0}) // 5-Blisters
	Aadd(_aTotRel,{0,0}) // 6-Outros
	
	// Ordem de apresentação no relatório (01-Bobinas, 02-Carretéis MC, 03-Rolos/Retalhos, 04-Blisters)
	// Ordem de apresentação no relatório (01-Carretéis MC, 02-Rolos/Retalhos, 03-Blisters, 04-Bobinas)
	//aSort(_aItens,,,{|x,y| x[8]+x[2]+x[1]<y[8]+y[2]+y[1]})
	aSort(_aItens,,,{|x,y| x[12]+x[1]+x[2]<y[12]+y[1]+y[2]})
	
	_cUltTot := ""
	if !empty(aJoinCab)
		CBCJoinCabec(aJoinCab)
	else
		U_CBCabec(2,3,2)
	endif
	nFolha := nFolha +1
	
	For _nx := 1 to Len(_aItens)
		If oPrn:Canceled()
			oPrn:Say(GPixel(5),GPixel(5),"*** CANCELADO PELO OPERADOR ***",oFont16N)
			Exit
		Endif
		If nLin > 200
			if !empty(aJoinCab)
				CBCJoinCabec(aJoinCab)
			else
				U_CBCabec(2,3,2)
			endif
			nFolha := nFolha +1
		Endif
	
		If Empty(_cUltTot)
			_cUltTot := Left(_aItens[_nx,12],2)
			_cProduto := _aItens[_nx,1]
		EndIf
		
		If (_cUltTot == "01" .And. _cUltTot # Left(_aItens[_nx,12],2)) .Or. ;
			(_cUltTot #  "01" .And. !Empty(_cProduto) .And. Left(_cProduto,5) # Left(_aItens[_nx,1],5))
			
			If (!lImpCb .And. Left(_aItens[_nx,12],2) # "01") // Não separar bobinas  // Acabei de imprimir o cabeçalho
				nLin++
				oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
				nLin++
			EndIf
			
			_cUltTot := Left(_aItens[_nx,12],2)
			_cProduto := _aItens[_nx,1]
			_nTotPs := 0
			_nTotMt := 0
		EndIf
		
		nLin := nLin +5
		oPrn:Say(GPixel(nLin),GPixel(00),_aItens[_nx,7],oFont14N)
		oPrn:Say(GPixel(nLin),GPixel(05),Transform(_aItens[_nx,1],If(Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_TIPO")=="PA","@R XXX.XX.XX.X.XX","@R XXXXXXXXXXXXXX")),oFont14N) 
		oPrn:Say(GPixel(nLin),GPixel(25),Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_DESC")),42),oFont14N)
		
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
		_nVlTotalIt := _aItens[_nx,3] * _aItens[_nx,4]
		
		oPrn:Say(GPixel(nLin),GPixel(100),_cAcondic			,oFont14N)
		//oPrn:Say(GPixel(nLin),GPixel(120),Transform(_aItens[_nx,3],"@E 9,999,999")	,oFont14N) 
		If Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_LOCALIZ")=="S"		
			oPrn:Say(GPixel(nLin),GPixel(120),Transform(_nQtLance,"@E 999999")	,oFont14N)
			oPrn:Say(GPixel(nLin),GPixel(127),"X"												,oFont14N)		
			oPrn:Say(GPixel(nLin),GPixel(130),Transform(_nMetrage,"@E 99999"),oFont14N)
		Else
			oPrn:Say(GPixel(nLin),GPixel(120),Transform(_aItens[_nx,3],"@E 999999")	,oFont14N)
		EndIf
		
		_nPesoInd := _aItens[_nx,10] 
		
		oPrn:Say(GPixel(nLin),GPixel(150),Transform(_nPesoInd,"@E 9,999,999.99")	,oFont14N)
		
		If _aItens[_nX,11] >= 1 // Quantidade de Caixas
			oPrn:Say(GPixel(nLin),GPixel(185),Transform(_aItens[_nx,11],"@E 999"),oFont14N) 
			oPrn:Say(GPixel(nLin),GPixel(190),"Caixa"+If(_aItens[_nx,11]>1,"s","")	,oFont14N)
		Else
			oPrn:Say(GPixel(nLin),GPixel(170),_aItens[_nx,8]		,oFont14N)
			If Left(_aItens[_nx,2],1)=="B" // Se for Bobina, o peso no array 6 é total
				If Len(AllTrim(_aItens[_nx,9])) > 7
					oPrn:Say(GPixel(nLin),GPixel(185),_aItens[_nx,9]		,oFont14N)
				Else
					oPrn:Say(GPixel(nLin),GPixel(185),_aItens[_nx,9]		,oFont14N)
				EndIf
			EndIf
		EndIf
		
		If lValorFat
			oPrn:Say(GPixel(nLin),GPixel(205),Transform(_nVlTotalIt,"@E 9,999,999.99")	,oFont14N)
		EndIf
		
		_nPesoTot += _nPesoInd
			
		_nTotPes += _nPesoInd
		_nTotVen += _nVlTotalIt
			
		_nTotMt += _aItens[_nx,3]
		_nTotPs += _nPesoInd
			
		If Posicione("SB1",1,xFilial("SB1")+_aItens[_nx,1],"B1_LOCALIZ")=="S"
			_aTotRel[Val(Left(_aItens[_nx,12],2)),1] += If(Left(_aItens[_nx,12],2)=="05",_aItens[_nx,11],_nQtLance)	// Quant.Caixas ou Total de lances
			_aTotRel[Val(Left(_aItens[_nx,12],2)),2] += _nPesoInd 	// Total peso
		EndIf

		If nLin > 200
			if !empty(aJoinCab)
				CBCJoinCabec(aJoinCab)
			else
				U_CBCabec(2,3,2)
			endif
			nFolha := nFolha +1
		Endif
	Next
	
	If _nTotMt > 0 .Or. _nTotPs > 0
		_nTotMt := 0
		_nTotPs := 0
	EndIf
	
	_cProduto := Space(15)
	
	nLin := nLin +2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))

	nLin := nLin +5
	oPrn:Say(GPixel(nLin),GPixel(120),"PESO TOTAL (Kg)"					,oFont16N)
	oPrn:Say(GPixel(nLin),GPixel(150),Transform(_nPesoTot,"@E 999,999.99")	,oFont16N) 
	
	If lValorFat
		oPrn:Say(GPixel(nLin),GPixel(175),"VALOR TOTAL"					,oFont16N)
		oPrn:Say(GPixel(nLin),GPixel(205),Transform(_nTotVen,"@E 9,999,999.99")	,oFont16N) 	
	EndIf
	
	nLin := nLin +5
	oPrn:Say(GPixel(nLin),GPixel(120),"TARA (Kg): "					,oFont16N)
	
	nLin := nLin +10
	
	If nLin+27 > 200
		if !empty(aJoinCab)
			CBCJoinCabec(aJoinCab)
		else
			U_CBCabec(2,3,2)
		endif
		nFolha := nFolha +1
	EndIf
	
	nLin := nLin +5
	
	oBrush1 := TBrush():New( , CLR_HGRAY )
	oPrn:FillRect( {GPixel(nLin), GPixel(60), GPixel(nLin+25), GPixel(200)},oBrush1)
	oBrush1:End()     
	
	nLin := nLin +5
	oPrn:Say(GPixel(nLin),GPixel(65),"Acondic."				,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(85),"Qtd.Lances/Cxs"		,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(110),"Peso Kg."				,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(135),"Acondic."				,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(155),"Qtd.Lances/Cxs"	,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(180),"Peso Kg."				,oFont14N)
	
	nLin := nLin +1
	oPrn:Line(GPixel(nLin), GPixel(60), GPixel(nLin),GPixel(200))
	nLin := nLin +5
	
	oPrn:Say(GPixel(nLin),GPixel(65),"Bobinas" 					,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(85),Transform(_aTotRel[1,1],"@E 9,999,999"),oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(110),Transform(_aTotRel[1,2],"@E 999,999.99"),oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(135),"Carreteis" 					,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(155),Transform(_aTotRel[2,1],"@E 9,999,999"),oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(180),Transform(_aTotRel[2,2],"@E 999,999.99"),oFont14N)
	nLin := nLin +5
	
	oPrn:Say(GPixel(nLin),GPixel(65),"Rolos" 					,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(85),Transform(_aTotRel[3,1]+_aTotRel[4,1],"@E 9,999,999") ,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(110),Transform(_aTotRel[3,2]+_aTotRel[4,2],"@E 999,999.99"),oFont14N)
	nLin := nLin +5
	
	oPrn:Say(GPixel(nLin),GPixel(65),"Blisters" 					,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(85),Transform(_aTotRel[5,1],"@E 9,999,999") ,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(110),Transform(_aTotRel[5,2],"@E 999,999.99"),oFont14N)
	
	If nLin+30 > 200
		if !empty(aJoinCab)
			CBCJoinCabec(aJoinCab)
		else
			U_CBCabec(2,3,2)
		endif
		nFolha := nFolha +1
	EndIf
	
	oCarga:byOS(cOS, .T.)
	if empty(oCarga:getCarga())
		aAdd(aVol, {'', '', '', '','','','','','',''})
	else
		oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aVol, oVol:loadVolumes(oCarga:getCarga(), cOS), .T.)
	endif
	
	nLin := nLin +15
	oPrn:Say(GPixel(nLin),GPixel(00),"VOLUMES : "					,oFont16N)
	nLin := nLin +2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(222))
	nLin := nLin +3
	oPrn:Line(GPixel(nLin-3), GPixel(00), GPixel(nLin+10),GPixel(00))
	oPrn:Say(GPixel(nLin),GPixel(00),"SACOS : "						,oFont14N)
	oPrn:Say(GPixel(nLin + 06),GPixel(03),cValToChar(aVol[01,04])		,oFontVol)
	oPrn:Line(GPixel(nLin-3), GPixel(42), GPixel(nLin+10),GPixel(42))
	oPrn:Say(GPixel(nLin),GPixel(45),"BOBINAS: "						,oFont14N)
	oPrn:Say(GPixel(nLin + 06),GPixel(45 + 03), cValToChar(aVol[01,06]),oFontVol)
	oPrn:Line(GPixel(nLin-3), GPixel(88), GPixel(nLin+10),GPixel(88))
	oPrn:Say(GPixel(nLin),GPixel(90),"CARRETEIS: "				,oFont14N)
	oPrn:Say(GPixel(nLin + 06),GPixel(90 + 03),cValToChar(aVol[01,05]),oFontVol)
	oPrn:Line(GPixel(nLin-3), GPixel(132), GPixel(nLin+10),GPixel(132))
	oPrn:Say(GPixel(nLin),GPixel(135),"CAIXAS: "						,oFont14N)
	oPrn:Say(GPixel(nLin + 06),GPixel(135 + 03),cValToChar(aVol[01,08]),oFontVol)
	oPrn:Line(GPixel(nLin-3), GPixel(178), GPixel(nLin+10),GPixel(178))
	oPrn:Say(GPixel(nLin),GPixel(180),"PALETES: "					,oFont14N)
	oPrn:Say(GPixel(nLin + 06),GPixel(180 + 03),cValToChar(aVol[01,07]),oFontVol)
	oPrn:Line(GPixel(nLin-3), GPixel(222), GPixel(nLin+10),GPixel(222))
	nLin := nLin +10
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(222))

	If nLin+20 > 200
		if !empty(aJoinCab)
			CBCJoinCabec(aJoinCab)
		else
			U_CBCabec(2,3,2)
		endif
		nFolha := nFolha +1
	EndIf
	
	nLin := nLin +3
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
	nLin := nLin +3
	oPrn:Say(GPixel(nLin),GPixel(60),"SEPARADO" ,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(100),"ENSACADO" ,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(140),"CONFERIDO" ,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(180),"MOTORISTA" ,oFont14N)
	nLin := nLin +12
	
	oPrn:Say(GPixel(nLin),GPixel(60),"_____/______/______" 	,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(100),"_____/______/______" 	,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(140),"_____/______/______"	,oFont14N)
	oPrn:Say(GPixel(nLin),GPixel(180),"_____/______/______"	,oFont14N)
	nLin := nLin +2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))	
	
	If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))
		nLin := nLin +10
		U_CBCabec(2,3,2)
		nFolha := nFolha +1
		ChkHwei() // Se tiver laudo para HUAWEI esta função tbm imprime
	ElseIf SC5->C5_LAUDO == "S"
		nLin := nLin +10
		U_CBCabec(2,3,2)
		nFolha := nFolha +1
		ChkLaudo()
	EndIf
	
	_nTotVen := 0
	FreeObj(oCarga)
	FreeObj(oVol)
	FreeObj(oFontVol)
Return(.T.)


Static Function ValidPerg(cPerg)
	Private cPerg
	
	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	
	aAdd(aRegs,{cPerg,"01","Nro. Pedido      ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Nro.de Vias      ?","mv_ch2","N",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Alt.Status para ?","mv_ch3","N",01,0,0,"C","","mv_par03","Normal","","","Em Separação","","","Em Faturamento","","","Não Altera","","","","",""})
	aAdd(aRegs,{cPerg,"04","Qual Armazém   ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Sequencia OS (Apenas faturados) ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	
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


/*/{Protheus.doc} JuntaSDC
//TODO Esta rotina só deve ser acionada quando for alterar o Status do pedido DE/PARA Em Faturamento.
@author juliana.leme
@since 26/06/2018
@version 1.0
@param _cNumPed, , descricao
@param cStatus, characters, descricao
@type function
/*/
Static Function JuntaSDC(_cNumPed,cStatus, cSeqIni, cSeqFim)
	local aCanCancel := {}
	Local oStatic    := IfcXFun():newIfcXFun()
	default cSeqIni	 := ""
	default cSeqFim	 := ""

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
			If (ZZR->ZZR_SITUAC == "1" .or. ZZR->ZZR_SITUAC == "2") .And. ZZR->(!Eof()) // Em Faturamento
				_C5_X_ULTOS := SC5->C5_X_ULTOS // Imprime o último desde que não esteja cancelado
				cSeqIni := _C5_X_ULTOS
				cSeqFim := _C5_X_ULTOS
			EndIf
		EndIf
	Else
		If _cWork == "E" // Estorna a O.S.
			aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(_cNumPed))
			if !aCanCancel[01]
				_lTemErro := .T.
				MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
					aCanCancel[02],'Bloqueado')
			else
				// Verificar se tem OS em faturamento e avisar usuário que vai cancelar a OS e os volumes                                                              
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
					Processa( {|| _lTemErro := !(u_zLimpaOS(_cNumPed,cStatus))},"Estornando Ordem de Separação...")
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
						// _C5_X_ULTOS := StrZero(Val(ZZR->ZZR_SEQOS)+1,Len(SC5->C5_X_ULTOS))
						_C5_X_ULTOS := PadR(SOMA1(ZZR->ZZR_SEQOS),Len(SC5->C5_X_ULTOS), '0')
					EndIf
					ZZR->(DbSkip())
				EndDo
				RecLock("SC5",.F.)
				SC5->C5_X_ULTOS := _C5_X_ULTOS
				cSeqIni := _C5_X_ULTOS
				MsUnLock()
				Processa( {|| CriarVl(_cNumPed,cStatus, @_C5_X_ULTOS)},"Criando Log da Ordem de Separação")
				cSeqFim := _C5_X_ULTOS
			EndIf
		EndIf
		If !_lTemErro
			RecLock("SC5",.F.)
			SC5->C5_ZSTATUS := If(_cWork=="E","1",'2') // EM FATURAMENTO
			MsUnLock()
		EndIf
	EndIf
Return(_C5_X_ULTOS)


user Function zLimpaOS(_cNumPed,cStatus)
	Local oStatic    := IfcXFun():newIfcXFun()
	local aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(_cNumPed))
	local lRet := .T.
	if !aCanCancel[01]
		lRet := .F.
		MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
			aCanCancel[02],'Bloqueado')
	else
		DbSelectArea("SC9")
		DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		DbSeek(xFilial("SC9") + _cNumPed,.F.)
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cNumPed .And. SC9->(!Eof())
			If Empty(SC9->C9_BLEST) .And. !Empty(SC9->C9_SEQOS)
				// Estou Estornando , estoque está liberado e foi criada uma sequencia da Ordem de Separação
				DbSelectArea("ZZO")
				DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
				DbSeek(xFilial("ZZO") + SC9->C9_PEDIDO + SC9->C9_SEQOS + SC9->C9_ITEM,.F.)
				Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == SC9->C9_PEDIDO .And. ;
						ZZO->ZZO_SEQOS == SC9->C9_SEQOS   .And. ZZO->ZZO_ITEMPV == SC9->C9_ITEM   .And. ZZO->(!Eof())
					RecLock("ZZO",.F.)
					DbDelete()
					MsUnLock()
					ZZO->(DbSkip())
				EndDo
				DbSelectArea("ZZR") // Log das Liberações
				DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
				DbSeek(xFilial("ZZR") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_SEQUEN + SC9->C9_SEQOS,.F.)
				Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == SC9->C9_PEDIDO .And. ZZR->ZZR_ITEMPV == SC9->C9_ITEM  .And. ;
						ZZR->ZZR_SEQUEN == SC9->C9_SEQUEN .And. ZZR->ZZR_SEQOS  == SC9->C9_SEQOS  .And. ZZR->(!Eof())
					RecLock("ZZR",.F.)
					ZZR->ZZR_SITUAC := "9" // Cancelado
					MsUnLock()
					ZZR->(DbSkip())
				EndDo
				
				DbSelectArea("SZE")
				DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
				DbSeek(xFilial("SZE") + SC9->C9_PEDIDO + SC9->C9_ITEM,.F.)
				Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC9->C9_PEDIDO .And. SZE->ZE_ITEM == SC9->C9_ITEM .And. SZE->(!Eof())
					If SZE->ZE_SEQOS == SC9->C9_SEQOS
						RecLock("SZE",.F.)
						SZE->ZE_SEQOS := "  "
						MsUnLock()
					EndIf
					SZE->(DbSkip())
				EndDo
				If !Empty(SC9->C9_SEQOS)
					RecLock("SC9",.F.)
					SC9->C9_SEQOS := "  "
					MsUnLock()
				EndIf
			EndIf
			SC9->(DbSkip())
		EndDo
	endif
Return(lRet)


Static Function CriarOS(_cNumPed,cStatus)
	Local cQuery, _aDadDC, _nQtReg, _aDadC9, _nQtDC, _nQtC9
	local cAglutina := getPedAglutina(_cNumPed)

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
	
	/* 
	Somar o Array do SDC e comparar com a soma do array do SC9
	 se estiver igual, continua senão sai
	 _aDadDC -> {DC_PEDIDO, DC_ITEM, DC_LOCAL, DC_LOCALIZ, DC_SEQ, DC_QUANT, DC.R_E_C_N_O_}
	 _aDadC9 -> {C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_LOCAL, C9_QTDLIB, C9_BLEST, C9.R_E_C_N_O_ AS NUMREG}
	 */
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
	
		If (_cChvDC  #  _aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,4]) .or. (_cChvDC  ==  _aDadDC[_nArrDC,1]+_aDadDC[_nArrDC,2]+_aDadDC[_nArrDC,3]+_aDadDC[_nArrDC,4] .and. (cAglutina == 'I' .or. cAglutina == 'P'))
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
	Local cQuery, _aDadC9DC, _nQtReg, _aDadC9, _nQtDC, _nQtC9
	local cAglutina := AllTrim(SC5->C5_ZAGLUTI)
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
		if (cAglutina == 'I' .or. cAglutina == 'P') .and. _nArrC9DC > 1
			_C5_X_ULTOS := Soma1(_C5_X_ULTOS)
		endif
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
			ZZR->ZZR_OS := AllTrim(_aDadC9DC[_nArrC9DC,01]) + AllTrim(_C5_X_ULTOS)
			MsUnLock()
		Next
	Next
Return(.T.)


Static Function CalcEmb(_cProd,_cLocaliz, _nQuant)
	// Efetua cálculo de embalagens para blisters, encartelados, carretéis
	Local _nTotEmb  := 0
	Local _nQtCxa   := 0
	Local _cTpBob   := ""
	Local _nRolCx   := 1
	Local _nQtdLc   := _nQuant / Val(Substr(_cLocaliz,2,15))
	local aInfAcond := {}
	
	if Left(_cLocaliz,1) == "L" // Blister de 15 metros
		aInfAcond := u_cbcAcInf(Alltrim(_cProd), AllTrim(_cLocaliz), , _nQtdLc, , .T., .F.,.T.)
		_nRolCx	  := aInfAcond[3,2]
		_nTotEmb  := aInfAcond[2,2]
	ElseIf Left(_cLocaliz,1) == "M" // Carretel
		_nTotEmb := (_nQtdLc*1.45)
	ElseIf Left(_cLocaliz,1) == "C" // Carretel
		_nTotEmb := (_nQtdLc*2.00)
	EndIf
Return({_nTotEmb,_nRolCx})


Static Function ImpZZR()
	Local _nVlrUnit := 0
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
		
		If Alltrim(ZZR->ZZR_LOCAL) <> Alltrim(MV_PAR09)
			ZZR->(DbSkip())
			Loop
		EndIf
		
		_nVlrUnit := Posicione("SC6",1,xFilial("SC6")+ZZR->(ZZR_PEDIDO+ZZR_ITEMPV),"C6_PRCVEN")
	
		Aadd(_aItens,{	ZZR->ZZR_PRODUT,;	//1
						ZZR->ZZR_LOCALI,;	//2
						ZZR->ZZR_QUAN, 	;	//3
						_nVlrUnit ,;				//4
						(ZZR->ZZR_QUAN*Posicione("SB1",1,xFilial("SB1")+ZZR->ZZR_PRODUT,"B1_PESCOB")),;	//5
						0.00,;	//6
						ZZR->ZZR_ITEMPV,;	//7
						If(Empty(ZZR->ZZR_NROBOB)," ",SZE->ZE_TPBOB),;	//8
						ZZR->ZZR_NROBOB,;	//9
						(ZZR->ZZR_EMBALA+ZZR->ZZR_PESPRO),;	//10
						IIf(ZZR->ZZR_QTCAIX > 1,(ZZR->ZZR_LANCES / ZZR->ZZR_QTCAIX),0),;//11
						_cOrdem,;//12
						ZZR->ZZR_LOCAL})			//13

		ZZR->(DbSkip())
	EndDo              
	If Len(_aItens) > 0
		ImprAItens(_aItens)
	EndIf
Return(.T.)

/*/{Protheus.doc} GPixel
//TODO Converte Pixel em Milimetros.
@author juliana.leme
@since 03/09/2016
@version undefined
@param _nMm, numerico, converte milimetros em pixels
@type function
/*/
Static Function GPixel(_nMm)
	_nRet:=(_nMm/25.4)*300
Return(_nRet)


/*/{Protheus.doc} CBCabec
//TODO Descrição auto-gerada.
@author juliana.leme
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param Mv_Par01, , descricao
@param MV_PAR04, , descricao
@param Mv_Par12, , descricao
@type function
/*/
User Function CBCabec(Mv_Par01,MV_PAR04,Mv_Par12)
	Local cNomeCli, cPVCli
	Local aDadInd := {}
	Local aDtasFx := {} // Datas fixas no SC5
	Local cPedNumSeq := ""
	Private _lGpo		:= (Ascan(USRRETGRP(),"000002") > 0)
	
	oPrn:StartPage(,"OrdSep_"+SC5->C5_NUM + If(Empty(MV_PAR10),"","_"+MV_PAR10))
	
	nLin := 15
	oPrn:Say(GPixel(nLin),GPixel(200),"Folha : " + Str(nFolha),oFont10N)
	oPrn:Say(GPixel(nLin),GPixel(00),"Cobrecom - Filial :" + FwFilial() +  " - " + FWFilialName(FwFilial()) ,oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(200),"Data/Hora Imp :" + DTOC(DATE()) + " - " + TIME(),oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(200),"Usuario Imp :" + RetCodUsr() + " - "+ UsrRetName(RetCodUsr()),oFont10N)
		
	nLin := 20
	
	cPedNumSeq:= SC5->C5_NUM + If(Empty(MV_PAR10),"",MV_PAR10)
	nWidth	 	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
	nHeigth   	:= 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3

	oPrn:FWMSBAR("CODE128" , 4, 0, Alltrim(cPedNumSeq), oPrn,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth,nHeigth,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
	//oPrn:QRCode(0,4, Alltrim(cPedNumSeq),100)
	
	cTitulo := "O R D E M   D E   S E P A R A C A O  -  N. " + SC5->C5_NUM + If(Empty(MV_PAR10),""," - "+MV_PAR10) + If(SC5->C5_CONDPAG=="000","  - B N D E S","")
	oPrn:Say(GPixel(nLin),GPixel(40),cTitulo,oFont18N)	
	
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
	
	//Inicializa o Array com 30 posições
	aDadInd := Array(1,30)
	aDadInd := u_InfTrian(xFilial("SC5"),SC5->C5_NUM,"CDFATR01")
	
	If Len(aDadInd) = 0
		aDadInd := Array(1,30)
	EndIf
	
	If SC5->C5_TIPO $ "DB" // Devolução de compras ou Envio para beneficiamento
		DbSelectArea("SA2")
		DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
	Else
		DbSelectArea("SA1")
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
	EndIf
	
	If MV_PAR04 == 1     // Saldo do Pedido
		oPrn:Say(GPixel(nLin),GPixel(150),"SITUAÇÃO: SALDO PV"					,oFont14N)	
	ElseIf MV_PAR04 == 2     // Não Separados
		oPrn:Say(GPixel(nLin),GPixel(150),"SITUAÇÃO: N/SEPAR."					,oFont14N)
	ElseIf MV_PAR04 == 3 // Separados
		oPrn:Say(GPixel(nLin),GPixel(150),"SITUAÇÃO: SEPARADO"					,oFont14N)
	ElseIf MV_PAR04 == 4  // Faturados
		oPrn:Say(GPixel(nLin),GPixel(150),"SITUAÇÃO: FATURADO"					,oFont14N)
	EndIf
	
	nLin := nLin +5
		
	If nFolha == 1		
	
		oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
		nLin := nLin +5
		
		If SC5->C5_TIPO $ "DB" // Devolução de compras ou Envio para beneficiamento
			oPrn:Say(GPixel(nLin),GPixel(00),"FORNECEDOR: "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+SA2->A2_NOME,oFont14N)
		Else
			If ! Empty(Alltrim(aDadInd[1,2]))
				oPrn:Say(GPixel(nLin),GPixel(00),"CLIENTE : "+Alltrim(aDadInd[1,2])+" (Ped.:"+aDadInd[1,1]+")",oFont14N)
			Else
				 oPrn:Say(GPixel(nLin),GPixel(00),"CLIENTE : "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+Alltrim(SA1->A1_NOME) + " " +;
				 						U_RetPedOri551(xFilial("SC5"),SC5->C5_NUM),oFont14N)
			EndIf
		EndIf
	
		If SC5->C5_TIPO $ "DB" // Devolução de compras ou Envio para beneficiamento
			oPrn:Say(GPixel(nLin),GPixel(150),"CNPJ/CPF: "+If(Len(AllTrim(SA2->A2_CGC))==11,;
									Transform(SA2->A2_CGC,"@R 999.999.999-99"),;
									Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")),oFont14N)
		Else
			If !Empty(aDadInd[1,6])
				oPrn:Say(GPixel(nLin),GPixel(150),"CNPJ/CPF: "+If(Len(AllTrim(aDadInd[1,6]))==11,;
									Transform(aDadInd[1,6],"@R 999.999.999-99"),;
									Transform(aDadInd[1,6],"@R 99.999.999/9999-99")),oFont14N)
			Else
				oPrn:Say(GPixel(nLin),GPixel(150),"CNPJ/CPF: "+If(Len(AllTrim(SA1->A1_CGC))==11,;
									Transform(SA1->A1_CGC,"@R 999.999.999-99"),;
									Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")),oFont14N)
									
			EndIf
		EndIf
		
		oPrn:Say(GPixel(nLin),GPixel(215),"LOCAL FAT: "+MV_PAR09 	,oFont14N)
		
		nLin := nLin +5
	
		If !SC5->C5_TIPO $ "DB" // Devolução de compras ou Envio para beneficiamento
			_cGerSup := Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_SUPER")
			If Empty(_cGerSup)
				_cGerSup := Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_GEREN")
			EndIf
			oPrn:Say(GPixel(nLin),GPixel(00),"VENDEDOR: "+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22])+" - "+Posicione("SA3",1,xFilial("SA3")+IIf(Empty(aDadInd[1,22]),SC5->C5_VEND1,aDadInd[1,22]),"A3_NOME"),oFont14N)
			oPrn:Say(GPixel(nLin),GPixel(150),"STATUS: " + If(SC5->C5_ZSTATUS < "1","Normal",If(SC5->C5_ZSTATUS==Padr('1',TamSX3("C5_ZSTATUS")[1]),"Em Separacäo","Em Faturamento")),oFont14N)
			nLin := nLin +5
			oPrn:Say(GPixel(nLin),GPixel(00),"GER./SUP: "+_cGerSup+" - "+Posicione("SA3",1,xFilial("SA3")+_cGerSup,"A3_NOME"),oFont14N)
		EndIf
		
		nLin := nLin +5
		oPrn:Say(GPixel(nLin),GPixel(00),"DATA ENTR.: "+ IIf(Empty(aDadInd[1,12]),DToC(SC5->C5_ENTREG),DtoC(StoD(aDadInd[1,12]))),oFont14N)
	
		If !Empty(SC5->C5_DTENTR)
			oPrn:Say(GPixel(nLin),GPixel(40),"NEG.",oFont14N)
		EndIf
		If SC5->C5_DIASNEG > 0
			oPrn:Say(GPixel(nLin),GPixel(50),"PRZ: ",oFont14N) 
			oPrn:Say(GPixel(nLin),GPixel(60),Transform(SC5->C5_DIASNEG,"999") ,oFont14N) 
		EndIf
	
		oPrn:Say(GPixel(nLin),GPixel(70),"CIDADE: " + IIf(!Empty(aDadInd[1,4]),Alltrim(aDadInd[1,4]),Left(If(SC5->C5_TIPO $ "DB",SA2->A2_MUN,SA1->A1_MUN),25)),oFont14N)
		oPrn:Say(GPixel(nLin),GPixel(150),"UF: " + IIf(!Empty(aDadInd[1,5]),Alltrim(aDadInd[1,5]),If(SC5->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST)),oFont14N)
		cUfCli := IIf(!Empty(aDadInd[1,5]),Alltrim(aDadInd[1,5]),If(SC5->C5_TIPO $ "DB",SA2->A2_EST,SA1->A1_EST))
		
		If Alltrim(cUfCli) == "EX"
			oPrn:Say(GPixel(nLin),GPixel(165)," -  EXPORTAÇÃO " ,oFont14N)
		EndIf
		
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
               
		If !Empty(_LocEnt)   
			nLin := nLin +5
			oPrn:Say(GPixel(nLin),GPixel(00),"LOC.ENTREGA: " + _LocEnt,oFont14N)
		EndIf
		
		nLin := nLin +5
		oPrn:Say(GPixel(nLin),GPixel(00),"COND.PAGTO.: "+ IIF(Empty(aDadInd[1,9]),AllTrim(SC5->C5_CONDPAG),Alltrim(aDadInd[1,9]));
		+ "  -  " + Posicione("SE4",1,xFilial("SE4")+IIF(Empty(aDadInd[1,9]),AllTrim(SC5->C5_CONDPAG),Alltrim(aDadInd[1,9])),"E4_DESCRI"),oFont14N)
	
		oPrn:Say(GPixel(nLin),GPixel(150),"Nº DRC: " + If(SC5->C5_DRC==0," ",AllTrim(Str(SC5->C5_DRC))),oFont14N)
	
		_cTransp := Iif(Empty(Alltrim(aDadInd[1,19])),SC5->C5_TRANSP,Alltrim(aDadInd[1,19]))
		nLin := nLin +5
		oPrn:Say(GPixel(nLin),GPixel(00),"TRANSP.: " + _cTransp + " " + If(! Empty(_cTransp),Posicione("SA4",1,xFilial("SA4")+_cTransp,"A4_NOME"),""),oFont14N)
	
		_cMyTpFrete := "????"
		If SC5->C5_TPFRETE == "C"
			_cMyTpFrete := "CIF"
		ElseIf SC5->C5_TPFRETE == "F"
			_cMyTpFrete := "FOB"
		EndIf																				
		
		oPrn:Say(GPixel(nLin),GPixel(90),"TIPO FRETE : " + _cMyTpFrete,oFont14N)
	
		If Empty(Alltrim(aDadInd[1,24]))
			oPrn:Say(GPixel(nLin),GPixel(150),"PALETIZAR ? " + IIf (SC5->C5_PALLET =="S"," SIM "," NÃO "),oFont14N)
		Else
			oPrn:Say(GPixel(nLin),GPixel(150),"PALETIZAR ? " + IIf (Alltrim(aDadInd[1,24])=="S"," SIM "," NÃO "),oFont14N)
		EndIf
	
		//Mensagem para NF
		nLin := nLin +5
		oPrn:Say(GPixel(nLin),GPixel(00),"INF.TRANSP: " + Iif(Empty(Alltrim(aDadInd[1,25])),AllTrim(SC5->C5_XTELENT),Alltrim(aDadInd[1,25])),oFont14N)
	
		//Envio de Laudo
		If Empty(Alltrim(aDadInd[1,26]))
			oPrn:Say(GPixel(nLin),GPixel(150) ,"ENVIA LAUDO ?" + IIf(SC5->C5_LAUDO == "S", " SIM ", " NAO "),oFont14N)
		Else
			oPrn:Say(GPixel(nLin),GPixel(150),"ENVIA LAUDO ?" + IIf(Alltrim(aDadInd[1,26]) == "S", " SIM ", " NAO "),oFont14N)
		EndIf
	
		oPrn:Say(GPixel(nLin),GPixel(180),"PARCIAL ?" + if( SC5->(C5_PARCIAL) == "S", " SIM", " NAO"),oFont14N)																															
		
		//Mensagem para Nota
		nLin := nLin +5
		_cMsgNota := Iif(Empty(Alltrim(aDadInd[1,27])),AllTrim(SC5->C5_MENNOTA),Alltrim(aDadInd[1,27]))
		If Len(_cMsgNota) <= 85
			oPrn:Say(GPixel(nLin),GPixel(00),"MSG NOTA: " + _cMsgNota,oFont14N)		
			//Agendar Entrega
			If Empty(Alltrim(aDadInd[1,26]))
				oPrn:Say(GPixel(nLin),GPixel(150),"AGENDAR ENTREGA? "+ IIF(SA1->A1_XAGENTR == "S"," SIM ", " NAO "),oFont14N)		
			Else
				oPrn:Say(GPixel(nLin),GPixel(150),"AGENDAR ENTREGA? "+ IIF(Alltrim(aDadInd[1,28]) == "S"," SIM ", " NAO "),oFont14N)		
			EndIf
		Else
			oPrn:Say(GPixel(nLin),GPixel(00),"MSG NOTA: " + SubStr(AllTrim(_cMsgNota),1,85),oFont14N)		
			//Agendar Entrega
			oPrn:Say(GPixel(nLin),GPixel(150),"AGENDAR ENTREGA? "+ IIF(SA1->A1_XAGENTR == "S"," SIM ", " NAO "),oFont14N)
			nLin := nLin + 5		
			If Len(_cMsgNota)-86 <= 85
				oPrn:Say(GPixel(nLin),GPixel(00),"MSG NOTA(Cont): " + SubStr(AllTrim(_cMsgNota),86,Len(_cMsgNota)),oFont14N)		
			Else
				oPrn:Say(GPixel(nLin),GPixel(00),"MSG NOTA(Cont): " + SubStr(AllTrim(_cMsgNota),86,110),oFont14N)		
				nLin := nLin + 5
				oPrn:Say(GPixel(nLin),GPixel(00),"MSG NOTA(Cont2): " + SubStr(AllTrim(_cMsgNota),196,Len(_cMsgNota)),oFont14N)		
			EndIf
		EndIf
		nLin := nLin + 5
		oPrn:Say(GPixel(nLin),GPixel(00),"OBSERVACOES: "+ IIF(Empty(Alltrim(aDadInd[1,10])),SC5->C5_OBS,Alltrim(aDadInd[1,10])),oFont14N)
		oPrn:Say(GPixel(nLin),GPixel(200),"NOTA FISCAL: ",oFont14N)
		
		nLin := nLin + 4
		oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
		nLin := nLin + 5
	EndIf
	
	If nFolha > 1
		nLin := nLin + 2
		oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
		nLin := nLin + 5
	EndIf
	
	oPrn:Say(GPixel(nLin), GPixel(00),"It." ,oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(05),"Produto" ,oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(25),"Descricao",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(100),"Acondic.",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"Lances / Metrag",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(150),"Peso",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(170),"Tp.Bob.",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(185),"Nro.Bobina",oFont14N)
	If lValorFat
		oPrn:Say(GPixel(nLin), GPixel(205),"Val.Venda",oFont14N)
	Endif

	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
	lImpCb := .T.
Return(.T.)


/*/{Protheus.doc} ChkHwei
//TODO Descrição auto-gerada.
@author juliana.leme
@since 11/07/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ChkHwei()
	nLin := nLin + 10
	oPrn:Say(GPixel(nLin),GPixel(00),"Chek-Lisk de Carregamento e Liberação dos Materiais."	,oFont16N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(00),"Nro.Bobina",oFont16N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Sr. Conferente, ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Os itens abaixo deverão obrigatoriamente ser vistoriados e atendidos.",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"1 - Acondicionamento: ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Tem bobina maior que 100/60 ?",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Reprovado'  (    ) NAO - 'Aprovado' ",oFont14N)
	nLin := nLin + 5	
	oPrn:Say(GPixel(nLin), GPixel(20),"Tem material em rolos ? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Reprovado'  (    ) NAO - 'Aprovado' ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"2 - Visual: ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Cada bobina contém 3 etiquetas Huawei ? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Aprovado'  (    ) NAO - 'Reprovado' ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Código de barras das etiquetas Huawei estão legiveis ? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Aprovado'  (    ) NAO - 'Reprovado' ",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"3 - Transporte:",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"As bobinas estão dispostas 'em pé' no caminhão ?",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Aprovado'  (    ) NAO - 'Reprovado' ",oFont14N)
	nLin := nLin + 5

	If SC5->C5_LAUDO == "S"
		oPrn:Say(GPixel(nLin), GPixel(15),"4 - Documentação: ",oFont14N)
		nLin := nLin + 5
		oPrn:Say(GPixel(nLin), GPixel(20),"Os laudos de todos os produtos foram solicitados para o C.Q.?",oFont14N)
		oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Aprovado'  (    ) NAO - 'Reprovado' ",oFont14N)
		nLin := nLin + 5
		oPrn:Say(GPixel(nLin), GPixel(20),"  ",oFont14N)
		nLin := nLin + 5
		oPrn:Say(GPixel(nLin), GPixel(20),"Resp. pela solicitação: _____________________________     Data: ____/____/____",oFont14N)
		nLin := nLin + 5
		oPrn:Say(GPixel(nLin), GPixel(15),"5 - Conclusão:",oFont14N)
	Else
		oPrn:Say(GPixel(nLin), GPixel(15),"4 - Conclusão:",oFont14N)
	EndIf
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Todos os itens acima estão 'Aprovados' ? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Liberado para entrega'         (    ) NAO - ''Chamar o supervisor' ",oFont14N)
	nLin := nLin + 5
	
Return(.T.)

/*/{Protheus.doc} ChkLaudo
//TODO Esta função tem a finalidade de após a impressão de cada ordem de separação
			imprimir um Chek-Lisk no carregamento dos materiais.
@author juliana.leme
@since 11/07/2018
@version 1.0

@type function
/*/
Static Function ChkLaudo()
	nLin := nLin + 10
	oPrn:Say(GPixel(nLin),GPixel(00),"Chek-Lisk de Carregamento e Liberação dos Materiais."	,oFont16N)
	nLin := nLin + 5
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Sr. Conferente, ",oFont14N)
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Os itens abaixo deverão obrigatoriamente ser vistoriados e atendidos.",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"1 - Documentação:",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Os laudos de todos os produtos foram solicitados para o C.Q.? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Aprovado'   (    ) NAO - 'Reprovado'",oFont14N)

	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Resp. pela solicitação: _____________________________     Data: ____/____/____",oFont14N)

	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"2 - Conclusão:",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Todos os itens acima estão 'Aprovados' ? ",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"(    ) SIM - 'Liberado para entrega'         (    ) NAO - ''Chamar o supervisor' ",oFont14N)
	nLin := nLin + 5
Return(.T.)

static function CBCJoinCabec(aJoinCab)
    local cOS	 := aJoinCab[1]
	local aDados := aJoinCab[2]

	oPrn:StartPage()
	nLin := 15
	oPrn:Say(GPixel(nLin),GPixel(200),"Folha : " + Str(nFolha),oFont10N)
	oPrn:Say(GPixel(nLin),GPixel(00),"Cobrecom - Filial :" + FwFilial() +  " - " + FWFilialName(FwFilial()) ,oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(200),"Data/Hora Imp :" + DTOC(DATE()) + " - " + TIME(),oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(200),"Usuario Imp :" + RetCodUsr() + " - "+ UsrRetName(RetCodUsr()),oFont10N)
		
	nLin        := 20
	nWidth	 	:= 0.0164
	nHeigth   	:= 0.6

	oPrn:FWMSBAR("CODE128" , 4, 0, Alltrim(cOS), oPrn,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth,nHeigth,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
		
	cTitulo := "O R D E M   D E   S E P A R A C A O  -  N. " + cOS +  " - AGLUTINADA"
	oPrn:Say(GPixel(nLin),GPixel(40),cTitulo,oFont18N)
	nLin := nLin +5
		
	If nFolha == 1
		oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
		nLin := nLin +5		
		oPrn:Say(GPixel(nLin),GPixel(00),aDados[1],oFont14N)			
		oPrn:Say(GPixel(nLin),GPixel(150), aDados[2],oFont14N)		
		oPrn:Say(GPixel(nLin),GPixel(215), aDados[3],oFont14N)
		nLin := nLin +5		
		oPrn:Say(GPixel(nLin),GPixel(70), aDados[4],oFont14N)
		oPrn:Say(GPixel(nLin),GPixel(150),aDados[5],oFont14N)
        nLin := nLin + 5
		oPrn:Say(GPixel(nLin),GPixel(00),aDados[6],oFont14N)
		nLin := nLin + 5
    else
		nLin := nLin + 2
		oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
		nLin := nLin + 5
	EndIf
	
	oPrn:Say(GPixel(nLin), GPixel(00),"It." ,oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(05),"Produto" ,oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(25),"Descricao",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(100),"Acondic.",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(120),"Lances / Metrag",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(150),"Peso",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(170),"Tp.Bob.",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(185),"Nro.Bobina",oFont14N)
	If lValorFat
		oPrn:Say(GPixel(nLin), GPixel(205),"Val.Venda",oFont14N)
	Endif

	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(260))
	lImpCb := .T.
return(nil)

static function getPedAglutina(cPedido)
	local aArea    	:= GetArea()
    local aAreaSC5	:= SC5->(getArea())
	local cAglutina := ""
	local oSql      := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryC5Aglutina(cPedido))
    if oSql:hasRecords()
        oSql:goTop()		
        cAglutina := AllTrim(oSql:getValue("AGLUT"))
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSC5)
    RestArea(aArea)
return(cAglutina)

static function qryC5Aglutina(cPedido)
	local cQry := ""
	cQry += " SELECT SC5.C5_ZAGLUTI AS [AGLUT] "
	cQry += " FROM SC5010 SC5 "
	cQry += " WHERE SC5.C5_FILIAL = '" + xFilial('SC5') + "' "
	cQry += " AND SC5.C5_NUM = '" + AllTrim(cPedido) + "' "
	cQry += " AND SC5.D_E_L_E_T_ = '' "
return(cQry)

