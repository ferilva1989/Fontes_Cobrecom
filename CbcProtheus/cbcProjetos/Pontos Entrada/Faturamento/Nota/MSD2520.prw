#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
Realiza a exclusão do Pedido de MP para industrialização quando a NF for excluida.
Juliana Leme - 03/09/2015
*/
*
************************
User Function MS520DEL()
************************
*
If Alltrim(SF2->F2_CDROMA) == "NFIND"
	For nNum:= 1 to Len(aPediInd)
		//U_ExPVDados(aPediInd[1][nNum]) 	// By Roberto Oliveira 14/10/16
		U_ExPVDados(aPediInd[nNum]) 	// By Roberto Oliveira 14/10/16
		//MsgInfo("Pedido de MP para Industrialização EXCLUIDO, Numero: "+aPediInd[1][nNum],"Info" ) 	// By Roberto Oliveira 14/10/16
		MsgInfo("Pedido de MP para Industrialização EXCLUIDO, Numero: "+aPediInd[nNum],"Info" ) 	// By Roberto Oliveira 14/10/16
	Next
Endif
Return(.T.)
*
************************
User Function M440SCXI()
************************
*
Local aArea, _C9_NUMSEQ, _C9_SEQOS, _C9_DESCRI, _nRot, _cRotina

/* Testes na exclusão de notas fiscais
A função M440SC9I está dentro da função que cria o SC9 e vou usar somente quando estiver na exclusão de nota
fiscal onde estarei tratando os dados de unitização e controle de sequencia das Ordens de Separação na tabela SC9,
ou seja, dados específicos gravados no SC9 não são restaurados quando a nota fiscal é excluída, veja abaixo:
	1 - Liberação do Pedido -> Cria SC9 conforme SC6 e avalia crédito e estoque. No nosso caso o estoque é liberado em rotinas específicas;
	2 - Análise de Crédito -> Atualiza o C9_BLCRED e outras tabelas;
	3 - Liberação de Estoque -> Rotinas específicas que atualiza C9_BLEST e outras tabelas;
	4 - Ao imprimir Ordem de Separação, de acordo com parâmentro, o campo C9_SEQOS é atualizado;
	5 - Na exclusão da nota, esse campo (C9_SEQOS) deve ser resgatado para o novo C9 criado.
	
/*/
// Verificar se estou na rotina de Exclusão de Notas Fiscais
_nRot := 1
Do While .T.
	_cRotina := ProcName(_nRot++)
	If Empty(_cRotina) .Or. "MATA521" == Left(_cRotina,7) // Acabou ou é a Rotina de Exclusão de Notas Fiscais
		Exit
	EndIf
EndDo
If "MATA521" == Left(_cRotina,7) // É a Rotina de Exclusão de Notas Fiscais
	aArea   := GetArea()

	cQuery :=""
	cQuery +=" SELECT  C9_NUMSEQ, C9_SEQOS , C9_DESCRI"
	cQuery +="  FROM " + RetSqlName("SC9") + " TRC9"
	cQuery +=" WHERE C9_FILIAL = '" + xFilial("SC9") + "'"
	cQuery +=" AND C9_PEDIDO   = '" + SC9->C9_PEDIDO + "'"
	cQuery +=" AND C9_ITEM     = '" + SC9->C9_ITEM   + "'"
	cQuery +=" AND C9_SEQUEN   = '" + SC9->C9_SEQUEN + "'"
	cQuery +=" AND C9_NFISCAL  = '" + SF2->F2_DOC    + "'"
	cQuery +=" AND C9_SERIENF  = '" + SF2->F2_SERIE  + "'"
	cQuery +=" AND TRC9.D_E_L_E_T_ = '*' "
   	// Testar o D_E_L_E_T_, pois o registro que eu quero está deletado.
	cQuery +=" 	ORDER BY C9_NUMSEQ
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGoTop()
	_C9_NUMSEQ := Padr("   ",TamSX3("C9_NUMSEQ")[1])
	_C9_SEQOS  := "  "
	_C9_DESCRI := "  "

	Do While TRB->(!Eof())
		If TRB->C9_NUMSEQ > _C9_NUMSEQ
			_C9_NUMSEQ := TRB->C9_NUMSEQ
			_C9_SEQOS  := TRB->C9_SEQOS
			_C9_DESCRI := TRB->C9_DESCRI
		EndIf
		TRB->(DbSkip())
	EndDo

	DbSelectArea("TRB")
	DbCloseArea("TRB")

	If !Empty(_C9_NUMSEQ)
		//Transfere dados do C9 anterior para o C9 novo
		RecLock("SC9",.F.)
		SC9->C9_SEQOS  := _C9_SEQOS
		SC9->C9_STATUS := "3" // Volta Status a faturar
		SC9->C9_DESCRI := _C9_DESCRI
		SC9->(MsUnLock())
	EndIf

	RestArea(aArea)
EndIf
Return(.T.)