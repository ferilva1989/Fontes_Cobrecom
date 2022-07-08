#Include 'Protheus.ch'
#Include "Rwmake.ch"

*
****************************************
User Function MT097SCR()
	****************************************
	*
	Local aArea		:= GetArea()
	Local aSE4    	:= SE4->(GetArea())
	Local aSC7    	:= SC7->(GetArea())
	Local aSF1    	:= SF1->(GetArea())
	Local aSD1    	:= SD1->(GetArea())
	Local a
	Local nX
	Local nY
	Local aOcor	:= {}

	If SCR->(CR_TIPO) $ 'NF'

		//Preparar Header e Linha
		AAdd( PARAMIXB[1]:ACONTROLS[16]:AHEADERS,"Complemento Divergência" )
		For nY := 1 To Len(PARAMIXB[1]:ACONTROLS[16]:AARRAY)

			AAdd( PARAMIXB[1]:ACONTROLS[16]:AARRAY[nY], "" )

		Next

		//Retorno: {(T/F, ItemNFE, PC, Item PC, Mensagem}
		aOcor := U_DivergNFE( {},{},"",SF1->(F1_DOC),SF1->(F1_SERIE),SF1->(F1_FORNECE),SF1->(F1_LOJA) )

		For nX := 1 To Len(aOcor)
			If aOcor[nX][1]
				//Procura a ocorrencia nas linhas da Tela
				nPos := aScan(PARAMIXB[1]:ACONTROLS[16]:AARRAY,{|x|x[1] == aOcor[nX,2] .AND. x[5] == aOcor[nX,3] .AND. x[6] == aOcor[nX,4]} )

				If nPos > 0

					/*
					//Adiciona o complemento de ocorrencia
					If Alltrim(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10]) 	$ "OK"
					PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10] 			:= "Ver Complemento"
					EndIf

					If Alltrim(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10]) $ "Sem Pedido"

					If Empty(Alltrim(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11]))
					PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10] := "OK"

					Else
					PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11] += ""
					EndIf

					Else
					PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11] += Alltrim(aOcor[nX][5])
					EndIf
					*/

					//Preenche mensagem PERSONALIZADA
					PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11] := Alltrim(aOcor[nX][5])

					//Se "OK" (não tem divergência SISTEMA) e tem divergência PERSONALIZADA, altera mensagem SISTEMA
					If Alltrim(Upper(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10])) == "OK" .And. PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11] <> ""
						PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10] := ""
					EndIf

					//Se mensagem SISTEMA e PERSONALIZADA iguais, limpa mensagem PERSONALIZADA (Ex."Sem Pedido")
					If Alltrim(Upper(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][10])) == Alltrim(Upper(PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11]))
						PARAMIXB[1]:ACONTROLS[16]:AARRAY[nPos][11] := ""
					EndIf

					//Função encontrou divergencia mas na tela de aprovação não esta mostrando o item
				Else
					/*
					[1]Item NF			[6]Item Pedido		[11]Compl. Divergencia
					[2]Produto			[7]Quantidade
					[3]Quantidade		[8]Prc Unitario
					[4]Vlr. Unitario	[9]Qtd. Entregue
					[5]Nro Pedido		[10]Divergênvia
					PARAMIXB[1]:ACONTROLS[16]:AARRAY
					*/
					Aadd(PARAMIXB[1]:ACONTROLS[16]:AARRAY,{aOcor[nX,2], " ", " ", " ", aOcor[nX,3], aOcor[nX,4], " ", " ", " ", " ",aOcor[nX,5] } )
				EndIF
			EndIf
		Next
	EndIf

	RestArea(aSD1)
	RestArea(aSF1)
	RestArea(aSC7)
	RestArea(aSE4)
	RestArea(aArea)

Return(nil)