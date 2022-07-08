#include "rwmake.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'
*
************************
User Function MS520VLD()
************************
*
*
Local _nPosic 		:= 0
Local _lRet24h      := .T. // Verifica se tem notas a serem exlcuídas com mais de 24 horas - Não pode porque já foi transferida a quantidade para sucata.
local oCarga		:= nil
Private _aArea		:= GetArea()
Private _aAreF2
Private _lFrete		:= .F. // Erro pelo frete?
Private _aVerNota	:= {}
Public  _lRet		:= .T.
Public _nQtdNF  	// Quantidade de notas a deletar
Public _aNotas  	// {Nro.Romaneio,Quant.de Notas}
Public _aItens  	// {1-Romaneio, 2-Pedido, 3-ItemPV, 4-Produto, 5-Local, 6-Localiz, 7-Quantidade, 8-SEQOS}
Public _cRoman		:= SF2->F2_CDROMA
Public aPediInd		:= {}

_cRoma := Space(Len(SF2->F2_CDROMA))
DbSelectArea("SF2")
_aAreF2   := GetArea()

If Valtype(_nQtdNF) == "U"
	_nQtdNF := 0
EndIf

If MV_PAR04 == 2
	If _nQtdNF == 0
		cMarca := SF2->F2_OK
		SF2->(DbSeek(xFilial("SF2"),.F.))
		Do While SF2->F2_FILIAL ==xFilial("SF2") .And. SF2->(!Eof())
			If cMarca == SF2->F2_OK
				_nQtdNF++
			EndIf
			SF2->(DbSkip())
		EndDo
		RestArea(_aAreF2)
		RestArea(_aArea)
		Alert("Altere a pergunta 'Retornar Pedido de Venda?' para CARTEIRA - Pressione tecla F12")
		Alert("Todas os Cancelamentos serão Rejeitados")
	EndIf
	_nQtdNF--
	Return(.F.)
EndIf

_nQtdNF := 0

If Valtype(_aNotas) == "U"
	_aNotas := {}
EndIf
If Valtype(_aItens) == "U"
	_aItens := {}
EndIf

DbSelectArea("SC9")
_aAreaC9 := GetArea()

DbSelectArea("SDB")
_aAreaDB := GetArea()

DbSelectArea("SD2")
_aAreaD2 := GetArea()
DbSetOrder(3)

If (!Empty(SF2->F2_CDROMA)).and.(Alltrim(SF2->F2_CDROMA) <> 'NFIND')
	cMarca := SF2->F2_OK
	_cRoma := SF2->F2_CDROMA
	_cAlert := "Romaneio nro. " + _cRoma + Chr(13) + "Documentos: "
	_cAlert1 :=""
	
	//	SF2->(DbSetOrder(7))
	SF2->(DBOrderNickName("SF2CDROMA"))
	
	SF2->(DbSeek(xFilial("SF2")+_cRoma,.F.))
	Do While SF2->F2_FILIAL ==xFilial("SF2") .And. SF2->F2_CDROMA == _cRoma .And. SF2->(!Eof()) .And._lRet24h .And. _lRet
		_cAlert1 += If(Len(_cAlert1)>0,', ','')+SF2->F2_DOC
		AAdd(_aVerNota,{SF2->F2_DOC,SF2->(RecNo())})
		If SF2->F2_OK # cMarca
			_lRet   := .F.
			Exit
		EndIf
		
		SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
		Do While SD2->D2_FILIAL  == xFilial("SD2") .And. SD2->(!Eof()) .And. ;
			SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
			SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA  .And. _lRet .And._lRet24h
			If SD2->D2_TES # SD2->D2_TESORI .And. !Empty(SD2->D2_TESORI) .And. SD2->D2_SERIE = "U  '
				_lRet24h      := .F.
				Exit
			ElseIf SD2->D2_TES == "809" .And. (SD2->D2_QUANT # 0 .Or. Abs(SD2->D2_QTDEDEV) # Abs(SD2->D2_QTD809))
				_lRet   := .F.
				Exit
			EndIf
			SD2->(DbSkip())
		EndDo
		
		// Neste ponto verificar se tem frete contratado na tabela ZZ4 e se pode excluir
		If SF2->F2_SERIE == "1  "
			ZZ4->(DbSetOrder(1)) // ZZ4_FILIAL+ZZ4_TPMOV+ZZ4_TPDOC+ZZ4_SERIE+ZZ4_DOC+ZZ4_CLIFOR+ZZ4_LOJA
			ZZ4->(DbSeek(xFilial("ZZ4")+"S"+SF2->F2_TIPO+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			
			Do While ZZ4->ZZ4_FILIAL == xFilial("ZZ4") .And. ZZ4->ZZ4_TPMOV  == "S"             .And. ;
				ZZ4->ZZ4_TPDOC  == SF2->F2_TIPO   .And. ZZ4->ZZ4_SERIE  == SF2->F2_SERIE   .And.;
				ZZ4->ZZ4_DOC    == SF2->F2_DOC    .And. ZZ4->ZZ4_CLIFOR == SF2->F2_CLIENTE .And.;
				ZZ4->ZZ4_LOJA   == SF2->F2_LOJA   .And. _lRet .And. _lRet24h .And. ZZ4->(!Eof())
				If !Empty(ZZ4->ZZ4_NROTER)
					_lFrete := .T. // Erro pelo frete?
					Exit
				EndIf
				ZZ4->(DbSkip())
			EndDo
		EndIf
		
		SF2->(DbSkip())
	EndDo
EndIf

If !_lRet24h
	RestArea(_aAreaDB)
	RestArea(_aAreaC9)
	RestArea(_aAreaD2)
	RestArea(_aAreF2)
	RestArea(_aArea)
	Alert(_cAlert+_cAlert1+Chr(13) + Chr(13) + "Documento não Habilitado para Exclusão!")
	Return(_lRet24h)
ElseIf !_lRet
	RestArea(_aAreaDB)
	RestArea(_aAreaC9)
	RestArea(_aAreaD2)
	RestArea(_aAreF2)
	RestArea(_aArea)
	Alert(_cAlert+_cAlert1+Chr(13) + Chr(13) + "Excluir todos os documentos de uma vez!")
	Return(_lRet)
ElseIf _lFrete // Erro pelo frete?
	RestArea(_aAreaDB)
	RestArea(_aAreaC9)
	RestArea(_aAreaD2)
	RestArea(_aAreF2)
	RestArea(_aArea)
	Alert(_cAlert+_cAlert1+Chr(13) + Chr(13) + "Excluir dados do frete!")
	Return(.F.)
EndIf

DbSelectArea("SF2")
/*
For _nCtd := 1 to Len(_aVerNota)
	aRegSD2 := {}
	aRegSE1 := {}
	aRegSE2 := {}
	SF2->(DbGoTo(_aVerNota[_nCtd,2]))
	
	Arru_809(.T.)
	/*_lCerto := MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
	If GetMV("MV_FATDIST") == "S" // Apenas quando utilizado pelo modulo de Distribuicao
		If !(DS520Vld())
			_lCerto := .F.
		EndIf
	EndIf
	Arru_809(.F.)
	
	If !_lCerto
		_lRet   := .F.
		Exit
	EndIf
Next
*/
    
RestArea(_aAreF2)
If !_lRet
	RestArea(_aAreaDB)
	RestArea(_aAreaC9)
	RestArea(_aAreaD2)
	RestArea(_aArea)
	Return(_lRet)
EndIf

// Neste ponto a nota será excluída...
// Verificar se tem frete contratado na tabela ZZ4 e Excluir
DbSelectArea("ZZ4")
DbSetOrder(1) // ZZ4_FILIAL+ZZ4_TPMOV+ZZ4_TPDOC+ZZ4_SERIE+ZZ4_DOC+ZZ4_CLIFOR+ZZ4_LOJA
DbSeek(xFilial("ZZ4")+"S"+SF2->F2_TIPO+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)

Do While ZZ4->ZZ4_FILIAL == xFilial("ZZ4") .And. ZZ4->ZZ4_TPMOV  == "S"             .And. ;
	ZZ4->ZZ4_TPDOC  == SF2->F2_TIPO   .And. ZZ4->ZZ4_SERIE  == SF2->F2_SERIE   .And.;
	ZZ4->ZZ4_DOC    == SF2->F2_DOC    .And. ZZ4->ZZ4_CLIFOR == SF2->F2_CLIENTE .And.;
	ZZ4->ZZ4_LOJA   == SF2->F2_LOJA   .And. ZZ4->(!Eof())
	RecLock("ZZ4",.F.)
	DbDelete()
	MsUnLock()
	ZZ4->(DbSkip())
EndDo

//nPos := aScan(aImp[nY], {|x|x[1]==aTmp[1].And.x[2]==aTmp[2].And.x[5]==aTmp[5].And.x[6]==aTmp[6]})
If aScan(_aNotas, {|x|x[1]==_cRoma}) == 0// {Romaneio,Qtd.de Notas no Romaneio)
	AAdd(_aNotas,{_cRoma,Len(_aVerNota)})
EndIf

DbSelectArea("SC6")
DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

DbSelectArea("SDB")
DbSetOrder(1) // SDB->DB_FILIAL+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ITEM

DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
Do While SD2->D2_FILIAL  == xFilial("SD2") .And. SD2->(!Eof()) .And. ;
	SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
	SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
	If SD2->D2_TES == "809"
		RecLock("SD2",.F.)
		SD2->D2_QUANT   := SD2->D2_QTD809
		SD2->D2_QTDEDEV := 0.00
		SD2->(MsUnLock())
		
		DbSelectArea("SC6")
		DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD,.F.))
			RecLock("SC6",.F.)
			SC6->C6_QTDENT := SC6->C6_QTDENT + SD2->D2_QTD809
			SC6->(MsUnLock())
		EndIf
	Else
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + SD2->D2_COD,.F.)
		DbSelectArea("SDB")
		If SB1->B1_LOCALIZ == "S"
			SDB->(DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.))
			Do While SDB->DB_FILIAL == xFilial("SDB") .And. ;
				SD2->D2_COD    +SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
				SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR +SDB->DB_LOJA .And. !SDB->(Eof())
				
				nPos := aScan(_aItens, {|x|x[1]==_CROMA .And. x[2]==SD2->D2_PEDIDO .And. x[3]==SD2->D2_ITEMPV .And. ;
				                           x[4]==SD2->D2_COD .And. x[5]==SD2->D2_LOCAL .And. x[6]==SDB->DB_LOCALIZ .And. x[8]==SD2->D2_SEQOS}) 
					    // {1-Romaneio, 2-Pedido, 3-ItemPV, 4-Produto, 5-Local, 6-Localiz, 7-Quantidade, 8-SEQOS}
				If nPos == 0
					AAdd(_aItens,{_CROMA  ,SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_LOCAL,SDB->DB_LOCALIZ,0.00,SD2->D2_SEQOS})
					nPos := Len(_aItens)
				EndIf
				_aItens[nPos,7] += SDB->DB_QUANT
				SDB->(DbSkip())
			EndDo
		Else
			nPos := aScan(_aItens, {|x|x[1]==_CROMA .And. x[2]==SD2->D2_PEDIDO .And. x[3]==SD2->D2_ITEMPV .And. ;
			                           x[4]==SD2->D2_COD .And. x[5]==SD2->D2_LOCAL .And. x[6]==Space(Len(SDB->DB_LOCALIZ)) .And. x[8]==SD2->D2_SEQOS}) 
						// {1-Romaneio, 2-Pedido, 3-ItemPV, 4-Produto, 5-Local, 6-Localiz, 7-Quantidade, 8-SEQOS}})
			If nPos == 0
				AAdd(_aItens,{_CROMA  ,SD2->D2_PEDIDO,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_LOCAL,Space(Len(SDB->DB_LOCALIZ)),0.00, SD2->D2_SEQOS})
				nPos := Len(_aItens)
			EndIf
			_aItens[nPos,7] += SD2->D2_QUANT
		EndIf
	EndIf
	
	DbSelectArea("SC6")
	DbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV+SD2->D2_COD,.F.))
		If !Empty(SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ)
			DbSelectArea("SZZ")
			DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
			If DbSeek(xFilial("SZZ") + SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ,.F.)
				RecLock("SZZ",.F.)
				If SC6->C6_QTDENT >= SC6->C6_QTDVEN // Vai zerar a quantidade entregue
					SZZ->ZZ_STATUS := "1"
				Else
					SZZ->ZZ_STATUS := "2"
				EndIf
				MsUnLock()
			EndIf
		EndIf
	EndIf

	oCarga := cbcCtrlCarga():newcbcCtrlCarga(,.F.)	
	DbSelectArea("ZZR")
	DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS+ZZR_LOCALI
	DbSeek(xFilial("ZZR") + SD2->D2_PEDIDO + SD2->D2_ITEMPV,.F.)
	Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == SD2->D2_PEDIDO .And. ZZR->ZZR_ITEMPV  == SD2->D2_ITEMPV .And. ZZR->(!Eof())
		If ZZR->ZZR_DOC  == SD2->D2_DOC .And. ZZR->ZZR_SERIE == SD2->D2_SERIE .And. ZZR->ZZR_ITEM == SD2->D2_ITEM
			RecLock("ZZR",.F.)
			ZZR->ZZR_DOC   := "         "
			ZZR->ZZR_SERIE := "   "
			ZZR->ZZR_ITEM  := "   "
			//ZZR->ZZR_CDROMA    := "      "
			MsUnLock()
			oCarga:byOS(AllTrim(ZZR->ZZR_OS), .T.)
			if oCarga:isOk()
				if oCarga:getStatus(AllTrim(ZZR->ZZR_OS)) == CARGA_FATURADA
					oCarga:update({{'ZZ9_STATUS', CARGA_LIB_FATUR},; 
								{'ZZ9_DOC', Space(TamSX3("D2_DOC")[1])},; 
								{'ZZ9_SERIE', Space(TamSX3("D2_SERIE")[1])}},; 
								AllTrim(ZZR->ZZR_OS))
				endif
			endif
		EndIf
		ZZR->(DbSkip())
	EndDo
	FreeObj(oCarga)

	DbSelectArea("ZZO")
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	DbSeek(xFilial("ZZO") + SD2->D2_PEDIDO ,.F.)
	Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == SD2->D2_PEDIDO .And. ZZO->(!Eof())
		If ZZO->ZZO_DOC  == SD2->D2_DOC .And. ZZO->ZZO_SERIE == SD2->D2_SERIE .And. ZZO->ZZO_ITEM == SD2->D2_ITEM
			RecLock("ZZO",.F.)
			ZZO->ZZO_DOC   := "         "
			ZZO->ZZO_SERIE := "   "
			ZZO->ZZO_ITEM  := "   "
			MsUnLock()
		EndIf
		ZZO->(DbSkip())
	EndDo
	
	DbSelectArea("SZE")
	DbSetOrder(3) // ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
	DbSeek(xFilial("SZE") + "F" + SD2->D2_PEDIDO + SD2->D2_ITEMPV,.F.)
	Do While SZE->(ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM) == ;
		xFilial("SZE") + "F" + SD2->D2_PEDIDO + SD2->D2_ITEMPV .And. SZE->(!Eof())
		
		_nRegZeNow := SZE->(Recno())
		SZE->(DbSkip())
		_nRegZeNex := SZE->(Recno())
		SZE->(DbGoTo(_nRegZeNow))
		
		If SZE->ZE_DOC+SZE->ZE_SERIE+SZE->ZE_NUMSEQ == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_NUMSEQ
			RecLock("SZE",.F.)
			SZE->ZE_STATUS := "E"
			SZE->ZE_DOC	   := Space(Len(SZE->ZE_DOC))
			SZE->ZE_SERIE  := Space(Len(SZE->ZE_SERIE))
			SZE->ZE_NUMSEQ := Space(Len(SZE->ZE_NUMSEQ))
			MsUnLock()
		EndIf
		SZE->(DbGoTo(_nRegZeNex))
	EndDo
	
	DbSelectArea("SD2")
	SD2->(DbSkip())
EndDo

/*
Realiza a exclusão do Pedido de MP para industrialização quando a NF for excluida.
Juliana Leme - 03/09/2015
*/
If Alltrim(SF2->F2_CDROMA) == "NFIND"
	Dbselectarea("SD2")
	DbsetOrder(3) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.F.))
	While (!SD2->(Eof())) .and. (SD2->D2_FILIAL == xFilial("SD2")) .and.(SD2->D2_DOC == SF2->F2_DOC)
		//_nPosic := aScan(aPediInd, {|x|x[1] == SD2->D2_PEDIDO}) By Roberto Oliveira 14/10/16
		_nPosic := aScan(aPediInd,SD2->D2_PEDIDO)
		If _nPosic == 0
			If !Empty(SD2->D2_IDENTB6)// By Roberto Oliveira 14/10/16
			//If Left(Posicione("SB1",1,xFilial("SB1")+Padr(SD2->D2_COD,TamSX3("B1_COD")[1]),"B1_GRUPO"),2) <> "PA" // By Roberto Oliveira 14/10/16
				// aAdd(aPediInd,{SD2->D2_PEDIDO})  // By Roberto Oliveira 14/10/16
				aAdd(aPediInd,SD2->D2_PEDIDO)  // By Roberto Oliveira 14/10/16
			EndIf
		EndIf
		SD2->(dbSkip())
	EndDo
Endif

RestArea(_aAreaDB)
RestArea(_aAreaC9)
RestArea(_aAreaD2)
RestArea(_aAreF2)
RestArea(_aArea)

Return(_lRet)

/*/
Acondicionamento use:
B01-Bob. 65 / 25 - B02-Bob. 65 / 45
B03-Bob. 80 / 45 - B04-Bob.100 / 60
B05-Bob.125 / 70 - B06-Bob.150 / 80
R  -Rolo
CM -Carr.Madeira - CP -Carr.Plástico
/*/
*
************************
User Function M521DNFS()
************************
*
Local aPedido   := {}
Public _aNotas  // {Nro.Romaneio,Quant.de Notas}
Public _aItens  // {1-Romaneio, 2-Pedido, 3-ItemPV, 4-Produto, 5-Local, 6-Localiz, 7-Quantidade, 8-SEQOS}
Public _cRoman  // SF2->F2_CDROMA
Private _aArea    := GetArea()
Private _aAreC6

DbSelectArea("SC6")
_aAreC6   := GetArea()

_nPosi := aScan(_aNotas, {|x|x[1]==_cRoman}) // {Romaneio,Qtd.de Notas no Romaneio)
If _nPosi > 0
	If _aNotas[_nPosi,2] == 1
		// Liberar PV desse romaneio
		For _nCtItens := 1 To Len(_aItens)  // {1-Romaneio, 2-Pedido, 3-ItemPV, 4-Produto, 5-Local, 6-Localiz, 7-Quantidade, 8-SEQOS}
			If _aItens[_nCtItens,1] == _cRoman
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6")+_aItens[_nCtItens,2]+_aItens[_nCtItens,3],.F.))
					_RegC6 := SC6->(RecNo())
					If SC6->C6_LOCALIZ # _aItens[_nCtItens,6]
						RecLock("SC6",.F.)
						SC6->C6_LOCALIZ := _aItens[_nCtItens,6]
						SC6->(MsUnLock())
					EndIf
					                                
					// Verifica se NÃO tenes liberados.... colocar pedido em faturamento
					SC9->(DBOrderNickName("SC9BLQ")) // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM
					_lTemLib := SC9->(DbSeek(xFilial("SC9") + Padr(" ",TamSX3("C9_BLCRED")[1]) + Padr(" ",TamSX3("C9_BLEST")[1])+_aItens[_nCtItens,2],.F.))

					_volta := MaLibDoFat(SC6->(RecNo()),_aItens[_nCtItens,7],.T.     ,.F.     ,.F.    ,.T.   ,.F.    ,.F.,,)
					
					//Function                    MaLibDoFat(nRegSC6       ,nQtdaLib            ,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdalib2)
					//±±³Parametros³ExpN1: Registro do SC6                                      ³±±
					//±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
					//±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
					//±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
					//±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
					//±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
					//±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
					//±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
					//±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
					//±±³          ³       apenas avalia ).                                     ³±±
					//±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
					//±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
					//±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
					//±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
					//±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
					//±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
					
					SC9->C9_TES := SC6->C6_TESORI
					SC9->C9_SEQOS := _aItens[_nCtItens,8]
					If Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCALIZ") # "S" .And. Empty(SC9->C9_BLCRED) .And. SC9->C9_BLEST == "02"
						// Força a liberação do C9
						SC9->C9_BLEST   := Space(2)
					EndIf
					SC9->(MsUnLock())
					If aScan(aPedido,_aItens[_nCtItens,2])==0
						Aadd(aPedido,_aItens[_nCtItens,2])
					EndIf
					If SC6->(RecNo()) # _RegC6
						SC6->(DbGoTo(_RegC6))
					EndIf
					If !Empty(SC6->C6_LOCALIZ)
						RecLock("SC6",.F.)
						SC6->C6_LOCALIZ := Space(Len(SC6->C6_LOCALIZ))
						SC6->(MsUnLock())
					EndIf
					
					// Se não tiver itens liberados. voltar o status do pedido para 2-EM FATURAMENTO
					If !_lTemLib .And. Empty(SC9->C9_BLCRED + SC9->C9_BLEST)
						SC5->(DbSetOrder(1))
						If SC5->(DbSeek(xFilial("SC5")+_aItens[_nCtItens,2],.F.))
							RecLock("SC5",.F.)
							SC5->C5_ZSTATUS := "2"
							MsUnLock()
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	If !Empty(aPedido)
		MaLiberOk(aPedido)
	EndIf
	_aNotas[_nPosi,2] -= 1
EndIf

_lTemNta := .F.
For _nCtNt := 1 to Len(_aNotas)
	If _aNotas[_nCtNt,2] # 0
		_lTemNta := .T.
		Exit
	EndIf
Next
If !_lTemNta
	_aNotas := {}
	_aItens := {}
EndIf

RestArea(_aAreC6)
RestArea(_aArea)
Return(.T.)
*
*******************************
Static Function Arru_809(_lVer)
*******************************
*
DbSelectArea("SD2")
DbSetOrder(3)
DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
Do While SD2->D2_FILIAL  == xFilial("SD2") .And. SD2->(!Eof()) .And. ;
	SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
	SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
	If SD2->D2_TES == "809"
		RecLock("SD2",.F.)
		SD2->D2_QUANT   := If(_lVer,SD2->D2_QTD809,0.00)
		If  _lVer
			SD2->D2_QTDEDEV := SD2->D2_QTDEDEV + SD2->D2_QTD809
		Else
			SD2->D2_QTDEDEV := SD2->D2_QTDEDEV - SD2->D2_QTD809
		EndIf
		SD2->(MsUnLock())
	EndIf
	
	DbSelectArea("SD2")
	SD2->(DbSkip())
EndDo
Return(.T.)


/*/
SELECT DISTINCT  D2_PEDIDO, D2_TES
FROM SD2010 WHERE D2_DOC = '000134602'

SELECT  F2_CDROMA,* FROM SF2010  WHERE F2_CDROMA = '285109' F2_DOC = '000134602'AND D_E_L_E_T_ = ''

SELECT * FROM SC5010 WHERE C5_NUM IN ('160238','160695','160902','161223','161286','161749','161910')AND D_E_L_E_T_ = ''

SELECT * FROM SC9010 WHERE C9_PEDIDO IN ('160238','160695','160902','161223','161286','161749','161910')AND D_E_L_E_T_ = '' AND C9_NFISCAL = '000134602'

SELECT * FROM SDC010 WHERE DC_PEDIDO IN ('160238','160695','160902','161223','161286','161749','161910') AND D_E_L_E_T_ = ''
/*/

