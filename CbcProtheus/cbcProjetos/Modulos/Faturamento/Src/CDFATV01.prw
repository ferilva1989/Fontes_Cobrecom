#include "rwmake.ch"
#include "protheus.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATV01                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 27/07/2004   //
//                                                                          //
//   Objetivo ...: Validação de Quantidade, Lances e Metragem no PV         //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDFATV01(_nTipo,_cTabela) // Função Revisada

DEFAULT _cTabela := "PV" // Pode ser PV - Pedido de Venda ou OR - Orçamento

_lMostra := .T. // Mostra ou não mensagens de erro
If Len(_cTabela) > 2
	_lMostra := .F.     
	_cTabela := Left(_cTabela,2)
EndIf

If Type("lPvAuto") == "U"
	lPvAuto := .F.
EndIf
Private _lRet     := .T.
Private _nQtdVen
Private _nLances
Private _nMetrage

If _cTabela == "PV"
	If GDFieldPos("C6_ACONDIC") == 0
		_cTabela := "RS" // Pode ser RS-Resumo, PV-Pedido de Venda ou OR-Orçamento
	EndIf
EndIf

If _cTabela == "RS" // Pode ser RS-Resumo, PV-Pedido de Venda ou OR-Orçamento
	_nQtdVen  := If(_nTipo==1,M->_C6QTDVEN ,GDFieldGet("_C6QTDVEN",n))
	_nLances  := If(_nTipo==2,M->_C6LANCES ,GDFieldGet("_C6LANCES",n))
	_nMetrage := If(_nTipo==3,M->_C6METRAGE,GDFieldGet("_C6METRAGE",n))
	_cAcondic := GDFieldGet("_C6ACONDIC",n)
	_cProdu   := GDFieldGet("_C6PRODUTO",n)
ElseIf _cTabela == "PV" // Pode ser PV - Pedido de Venda ou OR - Orçamento
	_nQtdVen  := If(_nTipo==1,M->C6_QTDVEN,GDFieldGet("C6_QTDVEN",n))
	_nLances  := If(_nTipo==2,M->C6_LANCES,GDFieldGet("C6_LANCES",n))
	_nMetrage := If(_nTipo==3,M->C6_METRAGE,GDFieldGet("C6_METRAGE",n))
	_cAcondic := GDFieldGet("C6_ACONDIC",n)
	_cProdu   := GDFieldGet("C6_PRODUTO",n)
Else // OR - orçamento
	_nQtdVen  := If(_nTipo==1,M->CK_QTDVEN,TMP1->CK_QTDVEN)
	_nLances  := If(_nTipo==2,M->CK_LANCES,TMP1->CK_LANCES)
	_nMetrage := If(_nTipo==3,M->CK_METRAGE,TMP1->CK_METRAGE)
	_cAcondic := TMP1->CK_ACONDIC
	_cProdu   := TMP1->CK_PRODUTO
EndIf

If Altera .And. _cTabela == "PV" .And. !Empty(GDFieldGet("C6_SEMANA",n)) // Pode ser PV - Pedido de Venda ou OR - Orçamento
	If !u_VejaSZ9("V",M->C5_NUM, GDFieldGet("C6_SEMANA",n), ;
							 GDFieldGet("C6_ITEM",n), ;
							 _cAcondic+StrZero(_nMetrage,5), ;
							 GDFieldGet("C6_LANCES",n))
		// u_VejaSZ9("V",PEDIDO, ITEM, ACONDIC (R00100), QTD.LANCES)
		Return(.F.)
	EndIf
EndIf

If _nQtdVen # 0 .And. _nLances # 0 .And. _nMetrage # 0 .And. !lPvAuto
	If (_nLances * _nMetrage) # _nQtdVen
		_lRet := .F.
		If _lMostra
			u_AutoAlert("Os campos Quantidade e Metragem devem ser múltiplos!")
		EndIf
	//ElseIf _cAcondic $ "RL" .And. _nMetrage == 15
	// By Roberto Oliveira - 18/11/15
	// Validar somete os blisters
	ElseIf _cAcondic == "L"
		// _cProdu := _cProduto
		If Empty(_cProdu)
			_lRet := .F.
			If _lMostra
				u_AutoAlert("Informe Primeiro o Código do Produto")
			EndIf
		Else
			_lRet := u_cbcAcInf(Alltrim(_cProdu), (_cAcondic + StrZero(_nMetrage,5)), _nMetrage, _nLances, _nQtdVen, .F., .T.)[1]
		EndIf	
	
	EndIf
EndIf
Return(_lRet)