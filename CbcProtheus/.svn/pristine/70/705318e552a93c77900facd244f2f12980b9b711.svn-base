#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)

/*
LEONARDO BOLOGNESI
22/04/2015
CRIADO CAMPO ( SE4.E4_ZMEDPAG (C)30 )
1-) ESTE CAMPO DEVE CONTER A MEDIA DAS CONDIÇÃO DE PAGAMENTO


2-) ATUALIZAR TODOS OS REGISTROS EXISTENTES (SE4)
3-) SEMPRE QUE INCLUIR OU ALTERAR UMA FORMA DE PAGAMENTO (CALCULAR/RECALCULAR) MEDIA
*/

****************************************************
User Function MT360GRV() //Executado (Inclusão, Alteração e Exclusão)
	****************************************************
	Local aArea    := Getarea()
	Local aAreaSE4 := SE4->(Getarea())

	U_grvZMEDPAG()

	RestArea(aArea)
	RestArea(aAreaSE4)

	Return Nil

	****************************************************
User Function grvZMEDPAG(cCodCond)   //U_grvZMEDPAG('CV')
	****************************************************
	Default cCodCond := ""

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1)) //E4_FILIAL, E4_DESCRI

	If Empty(cCodCond)
		SE4->(DbGoTop())
		While !SE4->(Eof())
			RecLock("SE4", .F.)
			SE4->E4_ZMEDPAG := CalcMedCond(SE4->(E4_CODIGO) , SE4->(E4_DDD), SE4->(E4_TIPO))
			SE4->(MsUnlock())
			SE4->(DbSkip())
		EndDo
	Else
		Alert( CalcMedCond(cCodCond,'D', '1') )
	EndIf

Return Nil

	****************************************************
Static Function calcMedCond(cCodCond, cDDD, cTipo)
	****************************************************
	Local cMedia 			:= ""
	Local nSoma				:= 0
	Local aCalcCond			:= {}
	Local nI
	Local dDate

	/*
	LEMBRANDO QUE HOJE NÃO UTILIZAMOS O CONCEITO DE FORA PERIODO (TRATAR POR PRECAUÇÃO)
	*/
	dDiaZero := DiaZero(cTipo, cDDD)

	aCalcCond := condicao(1000,cCodCond,,date() )

	//NÃO RETORNOU CONDIÇÃO DE PAGAMENTO
	If Empty(aCalcCond)
		Return '0'
	EndIf

	For nI := 1 to Len(aCalcCond)

		nSoma += (aCalcCond[nI,1] - dDiaZero ) * aCalcCond[nI,2]

	Next

	cMedia := cValToChar(nSoma / 1000 )

	Return cMedia


	****************************************************
Static Function DiaZero(cE4_TIPO, cE4_DDD)
	****************************************************
	/* Devolve o dia zero para condição de pagamento de acordo com o fonte "matxfunb"
	função valcondic, chamada pela função condicao
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para o campo E4_DDD	....E4_TIPO							³
	//³	  D = Data do dia 		(teste ok)....1								³
	//³	  L = Fora o dia		(teste ok)....1								³
	//³	  S = Fora a semana		(teste ok)....1								³
	//³	  Z = Fora a dezena		(teste ok)....1								³
	//³	  Q = Fora a quinzena	(teste ok)....1								³
	//³	  F = Fora o mes		(teste ok)....1								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local dProx
	Local dData0	:= Date()
	Local nDia
	Local nMes
	Local nAno

	If cE4_TIPO <> "9" .And. cE4_TIPO <> "7"

		//D = Data do dia
		If cE4_DDD $ "D "
			dProx 		:= (dData0 - 1)

			//L = Fora o dia
		ElseIf cE4_DDD == "L"
			dProx   	:= dData0

			//S = Fora a semana
		ElseIf cE4_DDD == "S"
			nDias   	:= Dow(dData0)
			If nDias == 7					  // Sabado
				dProx 	:= dData0
			ElseIf nDias == 6 				  // Sexta
				dProx 	:= dData0 + 1
			ElseIf nDias == 5 				  // Quinta
				dProx 	:= dData0 + 2
			ElseIf nDias == 4 				  // Quarta
				dProx 	:= dData0 + 3
			ElseIf nDias == 3 				  // Terca
				dProx 	:= dData0 + 4
			ElseIf nDias == 2 				  // Segunda
				dProx 	:= dData0 + 5
			ElseIf nDias == 1 				  // Domingo
				dProx 	:= dData0 + 6
			EndIf

			//Z = Fora a dezena
		ElseIf cE4_DDD == "Z"
			nDia := day(dData0)
			nMes := month(dData0)
			nAno := year(dData0)
			If nDia >= 01 .And. nDia <= 10
				nDia := 11
			ElseIf nDia >= 11 .And. nDia <= 20
				nDia := 21
			Else
				nDia := 01
				nMes := nMes + 1
			EndIf
			If nMes == 13
				nMes := 01
				nAno := nAno + 1
			EndIf
			nDia	  	:= strzero(nDia,2)
			nMes	  	:= strzero(nMes,2)
			nAno	  	:= substr(lTrim(str(nAno)),3,2)
			dProx   	:= (CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy")) - 1

			//Q = Fora a quinzena
		ElseIf cE4_DDD == "Q"
			nMes := month(dData0)
			nAno := year (dData0)
			If day(dData0) > 15
				nDia := 01
				nMes		:= nMes + 1
			Else
				nDia 	:= 16
			EndIf
			If nMes == 13
				nMes		:= 01
				nAno := nAno + 1
			EndIf
			nDia	  	:= strzero(nDia,2)
			nMes	  	:= strzero(nMes,2)
			nAno	  	:= substr(lTrim(str(nAno)),3,2)
			dProx   	:= ( CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy") ) - 1

			//F = Fora o mes
		ElseIf cE4_DDD == "F"
			nDia := 01
			nMes := month(dData0) + 1
			nAno := year (dData0)
			If nMes == 13
				nMes		:= 01
				nAno := nAno + 1
			EndIf
			nDia	  := strzero(nDia,2)
			nMes	  := strzero(nMes,2)
			nAno	  := substr(lTrim(str(nAno)),3,2)
			dProx   := ( CtoD(nDia+"/"+nMes+"/"+nAno,"ddmmyy") ) -1
		EndIf
	Else
		dProx := (dData0 - 1)
	EndIf

Return dProx