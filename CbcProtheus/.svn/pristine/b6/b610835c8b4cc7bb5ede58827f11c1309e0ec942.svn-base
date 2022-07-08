#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

// Função chamada por gatilho
// mata103 e mata140
*
**************************
User Function fAcertaNCM()
	**************************
	*
	Local aArea := SB1->(GetArea())
	Local cCod  := GDFieldGet("D1_COD")
	Local cNcm  := GDFieldGet("D1_POSIPI")

	If SB1->(dbSeek(xFilial("SB1")+cCod,.F.))
		If SB1->B1_POSIPI <> cNcm .And. !Empty(cNcm)
			RecLock("SB1",.F.)
			SB1->B1_POSIPI := cNcm
			MsUnlock()
		EndIf
	EndIf

Return(cNcm)