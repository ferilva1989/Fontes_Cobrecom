#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDFATR05  º Autor ³ Roberto Oliveira   º Data ³  06/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada no recalculo da comissao para gravar      º±±
±±º          ³ o numero do romaneio no SE3                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico ITF.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
***********************
User Function MSE3440()
	***********************
	// Nao precisa do RecLock("SE3",.F.) pois o registro já está travado/
	If SE3->E3_ORIGEM == "F" // Faturamento
		aSavSF2 := SF2->(GetArea())              
		SF2->(DbSetOrder(1))
		If SF2->(DbSeek(xFilial("SF2")+SE3->E3_NUM+SE3->E3_SERIE,.F.))
			If Empty(SE3->E3_ROMAN) .And. !Empty(SF2->F2_CDROMA)
				SE3->E3_ROMAN := SF2->F2_CDROMA
			EndIf
		EndIf
		RestArea(aSavSF2)
	EndIf
Return(.T.)                           

User Function CorrCom()

	DbSelectArea("SF2")
	DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

	DbSelectArea("SD2")
	DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	DbUseArea(.T.,,"\CONDUSUL\COMIS.DTC","TRB",.T.,.F.)
	DbGoTop()
	Do While TRB->(!Eof())
		If TRB->COMIS > 0
			DbSelectArea("SF2")
			DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
			If DbSeek(xFilial("SF2")+TRB->F2_DOC + TRB->F2_SERIE,.F.)
				If SF2->F2_VEND1 # TRB->F2_VEND1
					RecLock("SF2",.F.)
					SF2->F2_VEND1 := TRB->F2_VEND1
					MsUnLock()
				EndIf
			EndIf
			DbSelectArea("SD2")
			DbSeek(xFilial("SD2") + TRB->F2_DOC + TRB->F2_SERIE,.F.)
			Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC+SD2->D2_SERIE == TRB->F2_DOC + TRB->F2_SERIE .And. SD2->(!Eof())
				If SD2->D2_COMIS1 # TRB->COMIS
					RecLock("SD2",.F.)
					SD2->D2_COMIS1 := TRB->COMIS
					MsUnLock()
				EndIf
				SD2->(DbSkip())
			EndDo
			DbSelectArea("TRB")
		EndIf
		TRB->(DbSkip())
	EndDo      
	DbSelectArea("TRB")
	DbCloseArea()           
	Return(.T.)
	*
	************************
User Function CorBase()
	************************
	*   
	DbSelectArea("SF2")
	DbSetOrder(1)// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL                   

	DbSelectArea("SE3")
	DbSetOrder(1)
	DbSeek(xFilial("SE3"),.F.)         
	_cVend := "029   "
	Do While SE3->E3_FILIAL == xFilial("SE3") .And. SE3->(!Eof())    
		If SE3->E3_VEND == _cVend
			If SF2->(DbSeek(xFilial("SF2")+SE3->E3_NUM+SE3->E3_SERIE,.F.))
				If SF2->F2_ICMSRET > 0.00
					RecLock("SE3",.F.)
					SE3->E3_BASE  := SF2->F2_VALMERC// - SF2->F2_ICMSRET
					SE3->E3_COMIS := Round((SE3->E3_BASE * SE3->E3_PORC) / 100,2)   
					SE3->E3_PARCELA := "XXX"
					MsUnLock()
				EndIf
			EndIf
		EndIf
		SE3->(DbSkip())
	EndDo
Return(.T.)