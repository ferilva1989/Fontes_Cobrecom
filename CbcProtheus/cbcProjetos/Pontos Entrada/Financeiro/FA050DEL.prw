#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050DEL  ºAutor  ³EDVAR W. VASSAITIS  º Data ³  20/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ O ponto de entrada FA050DEL sera executado logo apos 	  º±±
±±º          ³ a confirmacao da exclusao do titulo.    					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COBRECOM - FINANCEIRO                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA050DEL

	Local _aArea   := GetArea()
	Local _aAreaE2 := SE2->(GetArea())

	SZT->(DbSetOrder(2)) //ZT_FILIAL+ZT_PREFIXO+ZT_NUMSE2+ZT_PARCELA+ZT_TIPO
	If SZT->(DbSeek(xFilial("SE2")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) , .F.))
		If !MsgBox("Deseja excluir registros da folha de pagamento referente a este titulo?","Confirma?","YesNo")
			Return(.F.)
		Else
			Do While SZT->(!Eof()) .And.;
			SZT->ZT_FILIAL  == xFilial("SZT")  .And.;
			SZT->ZT_PREFIXO == SE2->E2_PREFIXO .And.;
			SZT->ZT_NUMSE2  == SE2->E2_NUM     .And.;
			SZT->ZT_PARCELA == SE2->E2_PARCELA .And.;
			SZT->ZT_TIPO    == SE2->E2_TIPO

				RecLock("SZT",.F.)
				SZT->(DbDelete())
				MsUnLock()
				SZT->(DbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(_aAreaE2)
	RestArea(_aArea)

Return(.T.)