#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: BuscaPV - CDGEN08                  Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 20/08/2007   //
//                                                                          //
//   Objetivo ...: Cadasro de Saída de Materiais                            //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

*
***********************
User Function BuscaPv()
***********************
*
If Empty(SZF->ZF_CDROMA)
	Return(Space(Len(M->PEDIDOS)))
EndIf

DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SD2")
DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

_cVolta := ""
xPesoCS := 0.00
xPesoCB := 0.00
xPesoPV := 0.00
xValMer := 0.00
DbSelectArea("SF2")
DBOrderNickName("SF2CDROMA")
//DbSetOrder(7) // F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
DbSeek(xFilial("SF2")+SZF->ZF_CDROMA,.F.)
Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == SZF->ZF_CDROMA .And. SF2->(!Eof())
	SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.))
	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC+SD2->D2_SERIE == SF2->F2_DOC+SF2->F2_SERIE .And. SD2->(!Eof())
		SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.))
		If SF4->F4_ESTOQUE == "S"
			xPesoCS += (Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO")   * SD2->D2_QUANT)
			xPesoCB += (Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESCOB") * SD2->D2_QUANT)
			xPesoPV += (Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESPVC") * SD2->D2_QUANT)
		EndIf
		xValMer += SD2->D2_TOTAL
		If !SD2->D2_PEDIDO$_cVolta
			If !Empty(_cVolta)
				_cVolta := _cVolta + "/"
			EndIf
			_cVolta := _cVolta + SD2->D2_PEDIDO
		EndIf
		SD2->(DbSkip())
	EndDo
	SF2->(DbSkip())
EndDo
_cVolta := Left(_cVolta + Space(Len(SZF->ZF_PEDIDOS)),Len(SZF->ZF_PEDIDOS))
Return({_cVolta,xPesoCS,xValMer,xPesoCB,xPesoPV}) // {1-Pedidos da nota, 2-Peso Padrão, 3-Vlr.Mercadoria, 4-Peso Cobre, 5-Peso PVC}