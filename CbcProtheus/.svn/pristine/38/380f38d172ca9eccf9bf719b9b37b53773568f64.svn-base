#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFCI    º Autor ³ Roberto Oliveira   º Data ³  09/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualização da tabela ZZ6 para apuração do % de Conteúdo   º±±
±±º          ³ de Importação.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
*/
User Function CDFCI()
*
DbSelectArea("ZZ6")
DbSetOrder(1) // ZZ6_FILIAL+ZZ6_PRODUT
If MsgBox("Deseja o Processamento da FCI?","Confirma?","YesNo")
	
	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD
	
	DbSelectArea("SB9")
	DbSetOrder(1) // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
	
	DbSelectArea("SD2")
	DbSetOrder(6) // D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_NUMSEQ
	
//	Processa({|| CDFCISB9()},"Saldos Iniciais")
	Processa({|| CDFCISD2()},"Média de Vendas")
//	Processa({|| CDFCITRB()},"Pedidos de Vendas")
	Processa({|| CDFCISC9()},"Pedidos Liberados")
	Alert("Processamento Concluído")
EndIf
Return(.T.)
*
**************************
Static Function CDFCISB9()
**************************
*
DbSelectArea("SB9")
DbSetOrder(1) // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
Set Filter to DTOS(B9_DATA) == "20121231"

DbSelectArea("SB1")
DbSeek(xFilial("SB1"),.F.)
ProcRegua(RecCount())
Do While SB1->B1_FILIAL == xFilial("SB1") .And. SB1->(!Eof())

    IncProc()
    If SB1->B1_LOCALIZ # "S"
    	SB1->(DbSkip())
    	Loop           
    EndIf
    
	_cProd := SB1->B1_COD
	
	//DbSelectArea("SB9") // 	B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
	SB9->(DbSeek(xFilial("SB9")+_cProd,.F.))
	_nQtdB9 := 0
	Do While SB9->B9_FILIAL == xFilial("SB9") .And. SB9->B9_COD == _cProd .And. SB9->(!Eof())
		_nQtdB9 += Max(SB9->B9_QINI,0)
		SB9->(DbSkip())
	EndDo      
	If _nQtdB9 > 0
		If !ZZ6->(DbSeek(xFilial("ZZ6")+_cProd,.F.))
			RecLock("ZZ6",.T.)
			ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
			ZZ6->ZZ6_PRODUT := _cProd
			ZZ6->ZZ6_DESCR  := SB1->B1_DESC
			ZZ6->ZZ6_DATA   := Ctod("31/12/12")
		Else
			RecLock("ZZ6",.F.)
		EndIf
		ZZ6->ZZ6_QTDSB2 += _nQtdB9
		ZZ6->ZZ6_TOTAL  += _nQtdB9
		ZZ6->ZZ6_PESCOB := SB1->B1_PESCOB
		MsUnLock()
	EndIf
	SB1->(DbSkip())
EndDo
DbSelectArea("SB9")
Set Filter to
Return(.T.)               
*
**************************
Static Function CDFCISD2()
**************************
*      
DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SD2")
DbSetOrder(6) // D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_NUMSEQ
Set Filter to D2_EMISSAO >= Ctod("01/10/12") .And. D2_SERIE == "1  " .And. SD2->D2_TIPO == "N"

DbSelectArea("SB1")
DbSeek(xFilial("SB1"),.F.)
ProcRegua(RecCount())
Do While SB1->B1_FILIAL == xFilial("SB1") .And. SB1->(!Eof())

    IncProc()
    If SB1->B1_LOCALIZ # "S"
    	SB1->(DbSkip())
    	Loop           
    EndIf
    
	_cProd := SB1->B1_COD
	
	SD2->(DbSeek(xFilial("SD2")+_cProd,.F.))
	_nQtdD2 := 0
	_nVlrD2 := 0
	_nMaiorVr := 0
	_nQtFat1 := 0
	_nVrFat1 := 0
	_nICFat1 := 0
	_nQtFat2 := 0
	_nVrFat2 := 0
	_nICFat2 := 0
	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_COD == _cProd .And. SD2->(!Eof())
		SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.))
		If SF4->F4_ESTOQUE == "S" .And. SF4->F4_DUPLIC == "S"
			If SD2->D2_EMISSAO <= Ctod("31/12/12") 
				_nQtdD2 += SD2->D2_QUANT
				_nVlrD2 += SD2->D2_TOTAL
				_nMaiorVr := Max(_nMaiorVr,SD2->D2_PRCVEN)
			ElseIf Left(SD2->D2_CF,1) =="5" // Dentro do Estado
				_nQtFat1 += SD2->D2_QUANT
				_nVrFat1 += SD2->D2_TOTAL
				_nICFat1 += SD2->D2_VALICM
			Else
				_nQtFat2 += SD2->D2_QUANT
				_nVrFat2 += SD2->D2_TOTAL
				_nICFat2 += SD2->D2_VALICM
			EndIf
		EndIf
		SD2->(DbSkip())
	EndDo

	If _nQtdD2+_nVlrD2+_nMaiorVr+_nQtFat1+_nVrFat1+_nICFat1+_nQtFat2+_nVrFat2+_nICFat2 > 0
		If !ZZ6->(DbSeek(xFilial("ZZ6")+_cProd,.F.))
			RecLock("ZZ6",.T.)
			ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
			ZZ6->ZZ6_PRODUT := _cProd
			ZZ6->ZZ6_DESCR  := SB1->B1_DESC
			ZZ6->ZZ6_DATA   := Ctod("31/12/12")
		Else
			RecLock("ZZ6",.F.)
		EndIf
		ZZ6->ZZ6_QTDVEN := _nQtdD2
		ZZ6->ZZ6_VLRVEN := _nVlrD2
		ZZ6->ZZ6_PESCOB := SB1->B1_PESCOB
		ZZ6->ZZ6_QTFAT1 := _nQtFat1
		ZZ6->ZZ6_VRFAT1 := _nVrFat1
		ZZ6->ZZ6_ICMS1  := _nICFat1
		ZZ6->ZZ6_QTFAT2 := _nQtFat2
		ZZ6->ZZ6_VRFAT2 := _nVrFat2
		ZZ6->ZZ6_ICMS2  := _nICFat2
		If _nMaiorVr > ZZ6->ZZ6_MAIORV
			ZZ6->ZZ6_MAIORV := _nMaiorVr
		EndIf
		MsUnLock()
	EndIf
	SB1->(DbSkip())
EndDo
DbSelectArea("SD2")
Set Filter to
Return(.T.)               
*
**************************
Static Function CDFCITRB()
**************************
*          
DbUseArea(.T.,,"\ESTOQUE\SC9_3112.DTC","TRB",.T.,.F.)
IndRegua("TRB","\ESTOQUE\SC9_3112.IDX","C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO";
         ,,,OemToAnsi("Selecionando Registros..."))

DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM

DbSelectArea("SC6")
DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO --- Tab Z TES=505

DbSelectArea("SF2")
DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("TRB")
DbSeek(xFilial("SC9"),.F.)

_cC9Chv  := TRB->C9_PEDIDO+TRB->C9_ITEM
_cPrdZZ6 := TRB->C9_PRODUTO

_nC9Qtd := 0
ProcRegua(RecCount())
Do While TRB->C9_FILIAL == xFilial("SC9") .And. TRB->(!Eof())
    IncProc()
    _lDel := .F.
    If !TRB->C9_BLCRED $ "  //01//10" .Or. TRB->C9_SERIENF == "UNI"
	    _lDel := .T.
    Else
	    SC5->(DbSeek(xFilial("SC5")+TRB->C9_PEDIDO,.F.))
    	If SC5->C5_EMISSAO >= Ctod("01/01/13") .Or. SC5->C5_TIPO # "N" .Or. SC5->(Eof())
			_lDel := .T.
		Else
		    SC6->(DbSeek(xFilial("SC6")+TRB->C9_PEDIDO+TRB->C9_ITEM,.F.))
		    If SC6->C6_TES == "505" .Or. SC6->(Eof()) // Tab Z
				_lDel := .T.
			Else
				SB1->(DbSeek(xFilial("SB1")+TRB->C9_PRODUTO,.F.))
			    If SB1->B1_LOCALIZ # "S" .Or. SB1->(Eof())
		    	    _lDel := .T.
				Else    
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
					If SF4->F4_ESTOQUE # "S" .Or. SF4->F4_DUPLIC # "S" .Or. SF4->(Eof())
					    _lDel := .T.
					Else
						If TRB->C9_BLCRED == "10"  
							SF2->(DbSeek(xFilial("SF2")+TRB->C9_NFISCAL+TRB->C9_SERIENF,.F.))
							If SF2->(Eof()) .Or. SF2->F2_EMISSAO < Ctod("01/01/13")
							    _lDel := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf       
	If _lDel
    	RecLock("TRB",.F.)
    	DbDelete()
    	MsUnLock()
 	ElseIf TRB->C9_FILIAL == xFilial("SC9") .And. TRB->C9_PEDIDO+TRB->C9_ITEM == _cC9Chv
		_nC9Qtd += TRB->C9_QTDLIB
    EndIf
   	TRB->(DbSkip())
 	If TRB->C9_FILIAL # xFilial("SC9") .Or. TRB->C9_PEDIDO+TRB->C9_ITEM # _cC9Chv .Or. TRB->(Eof())
 		If _nC9Qtd > 0
			If !ZZ6->(DbSeek(xFilial("ZZ6")+TRB->C9_PRODUTO,.F.))
				RecLock("ZZ6",.T.)
				ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
				ZZ6->ZZ6_PRODUT := TRB->C9_PRODUTO
				ZZ6->ZZ6_DESCR  := SB1->B1_DESC
				ZZ6->ZZ6_DATA   := Ctod("31/12/12")
			Else
				RecLock("ZZ6",.F.)
			EndIf
			If SC5->C5_DESCEQT > 0
				_nC9Qtd := Int(((_nC9Qtd * SC5->C5_DESCEQT) / 100))
			EndIf
			ZZ6->ZZ6_QTDSC9 += _nC9Qtd
			ZZ6->ZZ6_PESCOB := SB1->B1_PESCOB
			MsUnLock()
		EndIf
	 	_cC9Chv := TRB->C9_PEDIDO+TRB->C9_ITEM
		_nC9Qtd := 0
	EndIf
EndDo
DbSelectArea("TRB")
DbCloseArea()
Return(.T.)
*
**************************
Static Function CDFCISC9()
**************************
*          
DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM

DbSelectArea("SC6")
DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO --- Tab Z TES=505

DbSelectArea("SF2")
DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SC9")
DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

DbSeek(xFilial("SC9"),.F.)

cQuery := "SELECT * FROM " + RetSqlName("SC9") + " WHERE C9_FILIAL = '" +;
          xFilial("SC9") + "' AND D_E_L_E_T_ <> '*' AND (C9_BLCRED = ' ' OR C9_BLCRED = '01') ORDER BY C9_PEDIDO,C9_ITEM"

If Select("TRA") > 0
	TRA->(DbCloseArea())
EndIf

TcQuery cQuery NEW ALIAS "TRA"

DbSelectArea("TRA")
Dbgotop()
_CNumPed := "  "
ProcRegua(RecCount())

While !TRA->(Eof())
//Do While TRA->C9_FILIAL == xFilial("SC9") .And. TRA->(!Eof())
    IncProc()
    _lSkip := .F.
    If !TRA->C9_BLCRED $ "  //01"
	    _lSkip := .T.
    Else
	    SC5->(DbSeek(xFilial("SC5")+TRA->C9_PEDIDO,.F.))
    	If SC5->C5_EMISSAO >= Ctod("01/01/13") .Or. SC5->C5_TIPO # "N" .Or. SC5->(Eof())
			_lSkip := .T.
		Else
		    SC6->(DbSeek(xFilial("SC6")+TRA->C9_PEDIDO+TRA->C9_ITEM,.F.))
		    If SC6->C6_TES == "505" .Or. SC6->(Eof()) // Tab Z
				_lSkip := .T.
			Else
				SB1->(DbSeek(xFilial("SB1")+TRA->C9_PRODUTO,.F.))
			    If SB1->B1_LOCALIZ # "S" .Or. SB1->(Eof())
		    	    _lSkip := .T.
				Else    
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
					If SF4->F4_ESTOQUE # "S" .Or. SF4->F4_DUPLIC # "S" .Or. SF4->(Eof())
					    _lSkip := .T.
					Else
						If TRA->C9_BLCRED == "10"  
							SF2->(DbSeek(xFilial("SF2")+TRA->C9_NFISCAL+TRA->C9_SERIENF,.F.))
							If SF2->(Eof()) .Or. SF2->F2_EMISSAO < Ctod("01/01/13")
							    _lSkip := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf       
	If !_lSkip
		If TRA->C9_PEDIDO # _cNumPed
			_cNumPed := TRA->C9_PEDIDO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa a funcao fiscal                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisSave()
			MaFisEnd()
			
			_nPosFisRet := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Alimenta as variáveis de cabeçalho para utilizar no calculo dos impostos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisIni(SC5->C5_CLIENTE,;				// 1-Codigo Cliente/Fornecedor
			SC5->C5_LOJACLI,;			    		// 2-Loja do Cliente/Fornecedor
			IIf(SC5->C5_TIPO $ "DB","F","C"),;		// 3-C:Cliente , F:Fornecedor
			SC5->C5_TIPO,;							// 4-Tipo da NF
			SC5->C5_TIPOCLI,;						// 5-Tipo do Cliente/Fornecedor
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461")
		EndIf
		
		_nC9Qtd := TRA->C9_QTDLIB
		If SC5->C5_DESCEQT > 0
			_nC9Qtd := Int(((_nC9Qtd * SC5->C5_DESCEQT) / 100))
		EndIf

		
		SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Agrega os itens para a funcao fiscal         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAdd(SC6->C6_PRODUTO,;	// 1-Codigo do Produto ( Obrigatorio )
		SC6->C6_TES,;	   			// 2-Codigo do TES ( Opcional )
		_nC9Qtd,;       		    // 3-Quantidade ( Obrigatorio )
		SC6->C6_PRCVEN,;   			// 4-Preco Unitario ( Obrigatorio )
		0,;                         // 5-Valor do Desconto ( Opcional )
		"",;	   				    // 6-Numero da NF Original ( Devolucao/Benef )
		"",;					    // 7-Serie da NF Original ( Devolucao/Benef )
		0,;     				    // 8-RecNo da NF Original no arq SD1/SD2
		0,;					 		// 9-Valor do Frete do Item ( Opcional )
		0,;					   		// 10-Valor da Despesa do item ( Opcional )
		0,;					 	    // 11-Valor do Seguro do item ( Opcional )
		0,;					    	// 12-Valor do Frete Autonomo ( Opcional )	
		_nC9Qtd*SC6->C6_PRCVEN,; // 13-Valor da Mercadoria ( Obrigatorio )
		0)						    // 14-Valor da Embalagem ( Opiconal )
		
		_nPosFisRet ++  //Obrigatorio, pois deve se manter a estrutura do array no mafisadd
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna Imposto conforme segundo parametro   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_BaseIcm := MaFisRet(_nPosFisRet, "IT_BASEICM")
		_ValIcm  := MaFisRet(_nPosFisRet, "IT_VALICM")
		
		If !ZZ6->(DbSeek(xFilial("ZZ6")+TRA->C9_PRODUTO,.F.))
			RecLock("ZZ6",.T.)
			ZZ6->ZZ6_FILIAL := xFilial("ZZ6")
			ZZ6->ZZ6_PRODUT := TRA->C9_PRODUTO
			ZZ6->ZZ6_DESCR  := SB1->B1_DESC
			ZZ6->ZZ6_DATA   := Ctod("31/12/12")
		Else
			RecLock("ZZ6",.F.)
		EndIf
        If Left(SC6->C6_CF,1) == "5"
			ZZ6->ZZ6_QTPED1 += _nC9Qtd
			ZZ6->ZZ6_VRPED1 += _nC9Qtd*SC6->C6_PRCVEN
			ZZ6->ZZ6_ICMSP1 += _ValIcm
		Else
			ZZ6->ZZ6_QTPED2 += _nC9Qtd
			ZZ6->ZZ6_VRPED2 += _nC9Qtd*SC6->C6_PRCVEN
			ZZ6->ZZ6_ICMSP2 += _ValIcm
		EndIf
		MsUnLock()
	EndIf
	TRA->(DbSkip())
EndDo
If !Empty(_cNumPed)
	MaFisEnd()
	MaFisRestore()
EndIf
Return(.T.)

**********************
User Function CARLAO()
**********************
*
// Se esta função ainda estiver no projeto e não souber pra que serve, EXCLUA
DbUseArea(.T.,,"\ESTOQUE\CARLOS.DTC","TRB",.T.,.F.)
dbGoTop()
Do While TRB->(!Eof())
	_myCod := Left(AllTrim(TRB->COD ) + Space(100),Len(SB1->B1_COD ))
	_myDes := Left(AllTrim(TRB->DESC) + Space(100),Len(SB1->B1_DESC))
	
	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD
	DbSeek(xFilial("SB1")+_myCod,.F.)
	If AllTrim(_myCod) # AllTrim(SB1->B1_COD) .Or. AllTrim(_myDes) # AllTrim(SB1->B1_DESC)
		DbSelectArea("SB1")
		DbSetOrder(3) // B1_FILIAL+B1_DESC+B1_COD
		DbSeek(xFilial("SB1")+_myDes,.F.)
		If AllTrim(_myCod) # AllTrim(SB1->B1_COD) .Or. AllTrim(_myDes) # AllTrim(SB1->B1_DESC)
			If !(_myDes == SB1->B1_DESC .And. Val(_myCod) == Val(SB1->B1_COD))
				DbSelectArea("TRB")
				RecLock("TRB",.F.)
				TRB->ACHEI := "Nao"
				MsUnLock()
				DbSkip()
				Loop
			EndIf
		EndIf
	EndIf
	
	RecLock("SB1",.F.)
	SB1->B1_EMIN := TRB->PPED
	MsUnLock()

	DbSelectArea("TRB")
	RecLock("TRB",.F.)
	TRB->ACHEI := "Sim"
	MsUnLock()
	DbSkip()          
EndDo
Return(.T.)
