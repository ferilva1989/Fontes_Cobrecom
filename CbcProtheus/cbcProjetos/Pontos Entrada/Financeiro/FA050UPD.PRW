#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA050UPD  ºAutor  ³EDVAR W. VASSAITIS  º Data ³  20/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ O ponto de entrada FA050UPD sera executado antes da entradaº±±
±±º          ³ nas rotinas de Inclusão/ Alteracao/ Exclusao. Utilizado    º±±
±±º          ³ como pre-validacao da inclusao / alteracao / exclusao.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COBRECOM - FINANCEIRO                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA050UPD

	Local _aArea   := GetArea()
	Local _aAreaE2 := SE2->(GetArea())

	If !(INCLUI) .And. !(ALTERA)
		If !Empty(SE2->E2_NUMCX)
			Alert("(Ponto de Entrada FA050UPD)"+Chr(13)+Chr(10)+;
			"Não é permitido excluir este titulo."+Chr(13)+Chr(10)+;
			"Motivo: Necessario excluir registros do caixa " + SE2->E2_NUMCX )
			Return(.F.)
		EndIf
	ElseIf  ALTERA .And. !Empty(SE2->E2_NUMCX)
		Alert("(Ponto de Entrada FA050UPD)"+Chr(13)+Chr(10)+;
		"Não é permitido alterar este titulo."+Chr(13)+Chr(10)+;
		"Motivo: Necessario excluir registros do caixa " + SE2->E2_NUMCX )
		Return(.F.)
	Endif

	RestArea(_aAreaE2)
	RestArea(_aArea)

Return(.T.)                           