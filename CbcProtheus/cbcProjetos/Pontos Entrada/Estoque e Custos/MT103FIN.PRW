#Include 'Protheus.ch'
#Include "Rwmake.ch"

/*
Objetivo: Ponto de Entrada para validar alteração da Condição de Pagamento e Produtos quando já gerou registro para aprovação.
Só pode ter alterações se não gerou registro para aprovação.
Inicialmente, este Ponto de Entrada foi planejado para conferir apenas mudanças nas condições de pagamento, mas como
foi identificada possibilidade de alterações nos produtos (itens da NF), então a validação foi estendida.
Jeferson Gardezani - 04/02/2016

EM QUE PONTO : Este ponto de entrada pode ser utilizado como última validação do folder financeiro na emissão da nota fiscal de entrada. 
*/

User FuncTion MT103FIN()

	Local i, x, y
	Local nX
	Local aItNF    := {}
	Local aColsAUX := {}
	Local nPosIt   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})	//Obtem posição do campo em aCols
	Local nPosPro  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
	Local nPosDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESCRI"})
	Local nPosQtd  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
	Local nPosUnit := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
	Local nPosTot  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
	Local nPosPC   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
	Local nPosItPC := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
	Local lRet     := PARAMIXB[3]		//Parâmetro com valor (.T./.F.) recebido pelo Ponto de Entrada.
	//.T. = Operação Válida
	//.F. = Operação Inválida
	//Salva posição atual dos ponteiros
	Local aArea := GetArea()
	Local aSCR  := SCR->(GetArea())
	Local aSD1  := SD1->(GetArea())

	//Só verifica se alterou a condição de pagamento, se iniciou o Ponto de Entrada com Operação Válida
	If lRet                               
		//Pesquisa se gerou registro para aprovação
		DbSelectarea("SCR")
		SCR->(DbSetOrder(1))	//CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL
		If  SCR->(DbSeek(xFilial("SCR")+"NF"+CNFISCAL+CSERIE+CA100FOR+CLOJA,.F.))		//CNFISCAL, CSERIE, CA100FOR e CLOJA variáveis de memória

			//Verifica se mudou dados da NF após aprovação
			DbSelectarea("SD1")
			SD1->(DbSetOrder(1))	//D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
			DbSeek(xFilial("SD1")+CNFISCAL+CSERIE+CA100FOR+CLOJA,.F.)
			While !Eof() .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SD1")+CNFISCAL+CSERIE+CA100FOR+CLOJA
				Aadd(aItNF,{ SD1->D1_ITEM + SD1->D1_COD + SD1->D1_DESCRI + SD1->D1_PEDIDO + SD1->D1_ITEMPC, SD1->D1_QUANT, SD1->D1_VUNIT, SD1->D1_TOTAL })
				SD1->(DBSkip())
			EndDo

			//Verifica se mudou quantidade de itens
			If Len(aCols) # Len(aItNF)
				MsgBox("Não é permitido alterar a quantidade de itens de um Documento de Entrada em processo de aprovação.","MT103FIN()","ALERT")
				lRet := .F.
			EndIf

			If lRet
				//Percorre todos os itens verificando se mudou dados da NF após aprovação
				For i:=1 To Len(aCols)		//Cria array simplificado para comparação com aItNF
					Aadd(aColsAUX,{ aCols[i][nPosIt] + aCols[i][nPosPro] + aCols[i][nPosDesc] + aCols[i][nPosPC] + aCols[i][nPosItPC], aCols[i][nPosQtd], aCols[i][nPosUnit], aCols[i][nPosTot]})
				Next
				//Ordena arrays para comparação
				Asort(aItNF,,,{|x,y| x[1] < y[1]})
				Asort(aColsAUX,,,{|x,y| x[1] < y[1]})
				//Compara arrays
				For i:=1 To Len(aColsAUX)
					If aColsAUX[i][1]#aItNF[i][1]
						MsgBox("Não é permitido alterar os itens de um Documento de Entrada em processo de aprovação. [1]","MT103FIN()","ALERT")
						lRet := .F.
						Exit
					EndIf
					If aColsAUX[i][2]#aItNF[i][2] .Or. aColsAUX[i][3]#aItNF[i][3] .Or. aColsAUX[i][4]#aItNF[i][4]
						MsgBox("Não é permitido alterar os itens de um Documento de Entrada em processo de aprovação. [2]","MT103FIN()","ALERT")
						lRet := .F.
						Exit
					EndIf
				Next
			EndIf

			If lRet
				//Verifica se trocou condição de pagamento
				If CCONDICAO <> SF1->(F1_COND)
					MsgBox("Não é permitido alterar a Condição de Pagamento de um Documento de Entrada em processo de aprovação.","MT103FIN()","ALERT")
					lRet := .F.
				EndIf
			Endif

		EndIf
	EndIf								

	//Restaura posição dos ponteiros
	RestArea(aSD1)
	RestArea(aSCR)
	RestArea(aArea)

Return lRet