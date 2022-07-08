#include "protheus.ch"
#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATV02                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: ROBERTO F. OLIVEIRA                Data ..: 15/10/2004   //
//                                                                          //
//   Objetivo ...: Validação de máximo de metragem conforme acondicionamento//
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDFATV02(_nTipo,_cTabela) // Função Revisada

DEFAULT _cTabela := "PV" // Pode ser PV - Pedido de Venda ou OR - Orçamento
_lMostra := .T. // Mostra ou não mensagens de erro
If Len(_cTabela) > 2
	_lMostra := .F.     
	_cTabela := Left(_cTabela,2)
EndIf
If Type("lPvAuto") == "U"
	lPvAuto := .F.
EndIf
      
If lPvAuto
	If nNumAtu # n
		nNumAtu := n
		IncProc()
	EndIf

	Return(.T.)
EndIf

Private _lRet     := .T.
Private _cAcondic
Private _nMetrage
Private _cProduto
Private _cQtdVen //Gustavo Fuentes 10/06/13

If _cTabela == "PV"
	If GDFieldPos("C6_ACONDIC") == 0
		_cTabela := "RS" // Pode ser RS-Resumo, PV-Pedido de Venda ou OR-Orçamento
	EndIf
EndIf

If _cTabela == "RS" // Pode ser RS-Resumo, PV-Pedido de Venda ou OR-Orçamento
	_cAcondic := If(_nTipo==1,M->_C6ACONDIC,GDFieldGet("_C6ACONDIC",n)) // R B C ou T (retalho)
	_nMetrage := If(_nTipo==2,M->_C6METRAGE,GDFieldGet("_C6METRAGE",n))
	_cProduto := GDFieldGet("_C6PRODUTO",n)
	_cQtdVen  := GDFieldGet("_C6QTDVEN",n)
ElseIf _cTabela == "PV" // Pode ser PV - Pedido de Venda ou OR - Orçamento
	_cAcondic := If(_nTipo==1,M->C6_ACONDIC,GDFieldGet("C6_ACONDIC",n)) // R B C ou T (retalho)
	_nMetrage := If(_nTipo==2,M->C6_METRAGE,GDFieldGet("C6_METRAGE",n))
	_cProduto := GDFieldGet("C6_PRODUTO",n)
	_cQtdVen  := GDFieldGet("C6_QTDVEN",n)
Else // OR - orçamento
	_cAcondic := If(_nTipo==1,M->CK_ACONDIC,TMP1->CK_ACONDIC) // R B C ou T (retalho)
	_nMetrage := If(_nTipo==2,M->CK_METRAGE,TMP1->CK_METRAGE)
	_cProduto := TMP1->CK_PRODUTO
	_cQtdVen  := TMP1->CK_QTDVEN  
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

If !Empty(_cAcondic) .And. !Empty(_nMetrage)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))
	_nMax := 0
	If _cAcondic == "R"
		_nMax := SB1->B1_ROLO
	ElseIf _cAcondic == "B"
		_nMax := SB1->B1_BOBINA
	ElseIf _cAcondic == "C"
		_nMax := SB1->B1_CARRETE
	ElseIf _cAcondic == "M"
		_nMax := SB1->B1_CARMAD
	ElseIf _cAcondic == "T" // Retalho
		_nMax := 99
	ElseIf _cAcondic == "L" // BLISTER
		_nMax := u_getMaxMetrage( /*Prod*/, _cAcondic)
	EndIf            
	    
	If _lMostra
		If _nMax <= 0
			u_AutoAlert("Informar a Metragem Máxima para o Acondicionamento!")
		ElseIf (_nMax < _nMetrage)
			u_AutoAlert("Metragem Máxima para Esse Acondicionamento é de " + Transform(_nMax,"@E 99,999") + " Metros.")
		EndIf
	EndIf
	_lRet := (_nMax >= _nMetrage)
	
	If _cAcondic $ "B"
		// Verificar se o peso do material é menor que GetMv("MV_PESMBOB")
		If (_nMetrage * SB1->B1_PESO) < GetMv("MV_PESMBOB")
			If _lMostra
				u_AutoAlert("Materiais em Bobinas somente com peso acima de " + Transform(GetMv("MV_PESMBOB"),"@E 99,999") + " Quilos" + Chr(13) + Chr(13) + "Peso desse material " + Transform((_nMetrage * SB1->B1_PESO),"@E 99,999.99") + " Quilos")
			EndIf
			_lRet := .F.
		EndIf
	ElseIf _cAcondic $ "L"
		_lRet := u_cbcAcInf(Alltrim(_cProduto), (_cAcondic+StrZero(_nMetrage,5)), _nMetrage, , _cQtdVen, .F., _lMostra)[1]
//	ElseIf _cAcondic $ "M" .And. SB1->B1_QTDCAR > 0 .And. _nMetrage # SB1->B1_QTDCAR
//		If _lMostra
//			u_AutoAlert("Esse Produto em Carretel é Obrigatório Metragem Exata em " + Transform(SB1->B1_QTDCAR,"@E 99,999") + " metros")
//		EndIf
//		_lRet := .F.
//	ElseIf _cAcondic $ "C" .And. SB1->B1_CARRETE > 0 .And. _nMetrage # SB1->B1_CARRETE
//		If _lMostra
//			u_AutoAlert("Esse Produto em Carretel é Obrigatório Metragem Exata em " + Transform(SB1->B1_CARRETE,"@E 99,999") + " metros")
//		EndIf
//		_lRet := .F.	
	EndIf
	
	// Atenção:
	// Alterações efetuadas em 11/11/13 onde as quantidades nos campos SB1->B1_CARMAD e 
	// SB1->B1_CARRETE não mais se refere a quantidade máxima por acondiciomaneto e sim a quantidade
	// exata por acondicionamento.
	// Assim sendo, o campo SB1->B1_QTDCAR deixa de ter funcionalidade e poderá ser excluído da base de dados.
	
 	If _cAcondic $ "M" .And. _nMetrage # SB1->B1_CARMAD .And. !u_isInd()
		If _lMostra
			u_AutoAlert("Esse Produto em Carretel de Madeira tem Metragem Máxima em " + Transform(SB1->B1_CARMAD,"@E 99,999") + " metros")
		EndIf
		_lRet := .F.
	ElseIf _cAcondic $ "C" .And. _nMetrage # SB1->B1_CARRETE
		If _lMostra
			u_AutoAlert("Esse Produto em Carretel é Obrigatório Metragem Exata em " + Transform(SB1->B1_CARRETE,"@E 99,999") + " metros")
		EndIf
		_lRet := .F.	
	EndIf
EndIf
Return(_lRet)
*
*********************
User Function Troca()
*********************
*
If MsgBox("Confirma processamento dos Limites de Metragem?","Confirma?","YesNo")
	Processa({ || Atualiza()})
	u_AutoAlert("Término do Processamento!")
EndIf
Return(.T.)
*
**************************
Static Function Atualiza()
**************************
*
*
DbUseArea(.T.,,"\CONDUSUL\TAB_ACON.DTC","TRB",.T.,.F.)
DbSelectArea("TRB")
Index on CODPROD TO TRB
DbGoTop()
Do While Empty(TRB->CODPROD)
	RecLock("TRB",.F.)
	DbDelete()
	DbSkip()
EndDo

DbSelectArea("SB1")
ProcRegua(RecCount())
DbGoTop()
Do While !Eof()
	IncProc()
	DbSelectArea("TRB")
	_lTem := DbSeek(Left(SB1->B1_COD,5),.F.)

	If _lTem .And. !Empty(SB1->B1_NOME) .And. !Empty(SB1->B1_BITOLA)
 		DbSelectArea("SB1")
		RecLock("SB1",.F.)
		SB1->B1_ROLO    := TRB->ROLO
		SB1->B1_BOBINA  := TRB->BOBINA
		SB1->B1_CARRETE := TRB->CARRETE
		SB1->B1_CARMAD  := TRB->CARMAD
		SB1->B1_RAIO    := TRB->R_CURVA
		SB1->B1_PE      := TRB->T_PROD
		SB1->B1_TIPE    := "D"
		SB1->B1_XPORTAL := "S"
		
		If TRB->DIAMETRO > 0
			SB1->B1_DIAMETR := TRB->DIAMETRO
			SB1->B1_EIXOMA  := 0
			SB1->B1_EIXOME  := 0
		Else
			SB1->B1_DIAMETR := 0
			SB1->B1_EIXOMA  := TRB->D_MAIOR
			SB1->B1_EIXOME  := TRB->D_MENOR
		EndIf
		
	Else
		DbSelectArea("SB1")
		RecLock("SB1",.F.)
		SB1->B1_ROLO    := 0
		SB1->B1_BOBINA  := 0
		SB1->B1_CARRETE := 0
		SB1->B1_CARMAD  := 0
		SB1->B1_EIXOMA  := 0
		SB1->B1_EIXOME  := 0
		SB1->B1_DIAMETR := 0
		SB1->B1_RAIO    := 0
		SB1->B1_XPORTAL := "N"
	EndIf
	MsUnLock()
	DbSkip()
EndDo
DbSelectArea("TRB")
DbCloseArea()
Return(.t.)