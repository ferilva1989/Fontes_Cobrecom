#INCLUDE "rwmake.ch"
#include "TOPCONN.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCDESTR22  บ Autor ณ AP6 IDE            บ Data ณ  14/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CDESTR22()



	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู



	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := ""
	Local cPict        := ""
	Local titulo       := "Transfer๊ncias para EPA - Producoes"
	Local nLin         := 80

	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDESTR22" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR22" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg        := "CDE022"

	Private cString := "SZL"

	dbSelectArea("SZL")
	dbSetOrder(1)

	ValidPerg()
	pergunte(cPerg,.F.)


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a interface padrao com o usuario...                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return(.T.)
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)                                         

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Processa( {|| LeiaSZF() },"Selecionando Registros...")
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return(.T.)            
	*
	*************************
Static Function LeiaSZF()
	*************************
	*
	#IFDEF TOP
	If mv_par10 == 1 // Aglutina por Produto
		cQUERY := " SELECT ZL_PRODUTO,ZL_DESC,ZL_TURNO,SUM(ZL_METROS) AS QUANT,SUM(ZL_PESPADR) AS PESOP,SUM(ZL_PESOEFE) AS PESOE"
		cQUERY += " FROM "+RetSqlName("SZL")+" ZL"
		cQUERY += " WHERE "
	Else // Aglutina por Linha","","","","","","","","","","",""})
		cQUERY := " SELECT B1_LINHA,ZL_PRODUTO,ZL_DESC,ZL_TURNO,SUM(ZL_METROS) AS QUANT,SUM(ZL_PESPADR) AS PESOP,SUM(ZL_PESOEFE) AS PESOE"
		cQUERY += " FROM " + RetSqlName("SZL") + " ZL," + RetSqlName("SB1") + " B1"
		cQUERY += " WHERE "
		cQUERY += " B1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQUERY += " AND B1.D_E_L_E_T_ <> '*'"
		cQUERY += " AND ZL.ZL_PRODUTO = B1.B1_COD"
		cQUERY += " AND "
	EndIf	
	cQUERY += " ZL.ZL_FILIAL = '" + xFilial("SZL") + "'"
	cQUERY += " AND ZL.D_E_L_E_T_ <> '*'"
	//	cQUERY += " AND ZL.ZL_DATA >= '" + DToS(Mv_Par01) + "'"  
	//	cQUERY += " AND ZL.ZL_DATA <= '" + DToS(Mv_Par03) + "'"
	cQUERY += " AND ZL.ZL_DATA+ZL.ZL_HORA BETWEEN '" + DToS(Mv_Par01) + Mv_Par02 + "' AND '" + DToS(Mv_Par03) + Mv_Par04 + "' " 
	//	cQUERY += " AND ZL.ZL_HORA BETWEEN '" + Mv_Par02       + "' AND '" + Mv_Par04       + "' "
	cQUERY += " AND ZL.ZL_PRODUTO >= '" + mv_par05 + "'"
	cQUERY += " AND ZL.ZL_PRODUTO <= '" + mv_par06 + "'"
	cQUERY += " AND ZL.ZL_STATUS <> 'C'"
	cQUERY += " AND ZL.ZL_TIPO IN ('P','U')"
	If mv_par07 == 2 // Nใo inclui retalhos   	
		cQUERY += " AND ZL.ZL_ACOND <> 'T'"
	ElseIf mv_par07 == 3 // Somente retalhos   	
		cQUERY += " AND ZL.ZL_ACOND = 'T'"
	EndIf
	/*	If MV_PAR06 == 2 // Nใo inclui peso acima de 5%
	cQUERY += " AND ABS(ZL.ZL_DESVIO) <= 5"
	*/  
	//	cQUERY += " AND (ZL.ZL_DESVIO <= '" + mv_par08 + "' OR ZL.ZL_DESVIO >= '" + mv_par09 + "') "
	cQUERY += " AND ZL.ZL_DESVIO >= '" + mv_par08 + "' AND ZL.ZL_DESVIO <= '" + mv_par09 + "' "

	If mv_par10 == 1 // Aglutina por Produto
		cQUERY += " GROUP BY ZL.ZL_PRODUTO,ZL.ZL_DESC,ZL_TURNO"
		cQUERY += " ORDER BY ZL.ZL_PRODUTO,ZL.ZL_DESC,ZL_TURNO"
	Else
		cQUERY += " GROUP BY B1_LINHA,ZL.ZL_PRODUTO,ZL.ZL_DESC,ZL_TURNO"
		cQUERY += " ORDER BY B1_LINHA,ZL.ZL_PRODUTO,ZL.ZL_DESC,ZL_TURNO"
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	dbSelectArea("TRB")
	dbGoTop()          
	#ELSE
	aStruTrb := {}
	If mv_par10 == 2 //Por linha
		aTam := TamSX3("B1_LINHA")
		AADD(aStruTrb,{"B1_LINHA","C",aTam[1],aTam[2] } )
	EndIf
	aTam := TamSX3("ZL_PRODUTO")
	AADD(aStruTrb,{"ZL_PRODUTO","C",aTam[1],aTam[2] } )
	aTam := TamSX3("ZL_TURNO")
	AADD(aStruTrb,{"ZL_TURNO","C",aTam[1],aTam[2] } )
	aTam := TamSX3("ZL_DESC")
	AADD(aStruTrb,{"ZL_DESC","C",aTam[1],aTam[2] } )
	AADD(aStruTrb,{"QUANT","N",12,2} )
	AADD(aStruTrb,{"PESOP","N",12,4} )
	AADD(aStruTrb,{"PESOE","N",12,4} )

	cNomTrb := CriaTrab(aStruTrb)
	dbUseArea(.T.,,cNomTrb,"TRB",.F.,.F.) // Abre o arquivo de forma exclusiva
	cNomTrb1 := Subs(cNomTrb,1,7)+"A"
	If mv_par10 == 1 //Por Produto
		IndRegua("TRB",cNomTrb1,"ZL_PRODUTO+ZL_TURNO",,,OemToAnsi("Selecionando Registros..."))
	Else
		IndRegua("TRB",cNomTrb1,"B1_LINHA+ZL_PRODUTO+ZL_TURNO",,,OemToAnsi("Selecionando Registros..."))
	EndIf
	DbSetOrder(1)                

	_cLinha := " "	
	DbSelectArea("SZL")
	ProcRegua(RecCount())
	DbSeek(xFilial("SZL"),.F.)
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->(!Eof())
		IncProc()
		If  ( SZL->ZL_DATA + SZL->ZL_HORA < DToS(Mv_Par01) + Mv_Par02 ) .Or.;
		( SZL->ZL_DATA + SZL->ZL_HORA > DToS(Mv_Par03) + Mv_Par04 ) .Or.;
		SZL->ZL_PRODUTO < mv_par05 .Or. SZL->ZL_PRODUTO > mv_par06 .Or.;
		SZL->ZL_STATUS == "C" .Or. !SZL->ZL_TIPO $ "PU"
			DbSkip()
			Loop
		ElseIf mv_par07 == 2 .And. SZL->ZL_ACOND == "T" // Nใo inclui retalhos   	
			DbSkip()
			Loop
		ElseIf mv_par07 == 3 .And. SZL->ZL_ACOND # "T" // Somente Retalhos
			DbSkip()
			Loop
			//		ElseIf MV_PAR06 == 2 .And. ABS(SZL->ZL_DESVIO) > 5 // Nใo inclui peso acima de 5% 
		ElseIf SZL->ZL_DESVIO < Mv_Par08 .Or. SZL->ZL_DESVIO > Mv_Par09
			DbSkip()
			Loop
		EndIf      
		If mv_par10 == 1 // Aglutina por Produto
			_cLinha := SZL->ZL_PRODUTO+SZL->ZL_TURNO
		Else // Aglutina por Linha","","","","","","","","","","",""})
			_cLinha := Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_LINHA")+SZL->ZL_PRODUTO+SZL->ZL_TURNO
		EndIf
		DbSelectArea("TRB")
		If !DbSeek(_cLinha,.F.)
			RecLock("TRB",.T.)
			If mv_par10 == 2 // Aglutina por Linha
				TRB->B1_LINHA   := _cLinha
			EndIf
			TRB->ZL_PRODUTO := SZL->ZL_PRODUTO
			TRB->ZL_DESC    := SZL->ZL_DESC
			TRB->ZL_TURNO   := SZL->ZL_TURNO
		Else
			RecLock("TRB",.F.)
		EndIf
		TRB->QUANT += SZL->ZL_METROS
		TRB->PESOP += SZL->ZL_PESPADR
		TRB->PESOE += SZL->ZL_PESOEFE
		MsUnLock()
		DbSelectArea("SZL")
		DbSkip()
	EndDo
	#ENDIF
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  15/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	*

	Local titulo       := "Transfer๊ncias para EPA - Producoes (de " + DToc(Mv_Par01) + " as " +Mv_Par02+ " เ " + DToc(Mv_Par03) + " as " +Mv_Par04+ ")"
	_aOpcoes := RetSx3Box(Posicione("SX3",2,"B1_LINHA","X3_CBOX"),,,14)

	DbSelectArea("SB1")
	DbSetOrder(1) 

	DbSelectArea("TRB")
	DbGoTop()

	If mv_par10 == 1 // Aglutina por Produto - Apesar de ter o turno na aglutina็ใo, na imressใo eu nใo considero-o
		_cChave := "TRB->ZL_PRODUTO"              
	Else
		_cChave := "TRB->B1_LINHA+TRB->ZL_PRODUTO"
	EndIf

	SetRegua(RecCount())
	_ngQUANT := 0
	_ngPESOE := 0
	_ngPESOP := 0
	_ngPESOC := 0
	_ngPESO1 := 0
	_ngPESO2 := 0
	_ngPESO3 := 0
	Do While TRB->(!Eof())
		_cProd  := If(mv_par10 == 1,Left(TRB->ZL_PRODUTO,5),TRB->B1_LINHA)
		_nQUANT := 0
		_nPESOE := 0
		_nPESOP := 0
		_nPESOC := 0
		_nPESO1 := 0
		_nPESO2 := 0
		_nPESO3 := 0

		_lNewProd := .T.

		Do While If(mv_par10 == 1,Left(TRB->ZL_PRODUTO,5),TRB->B1_LINHA) == _cProd .And. TRB->(!Eof())
			IncRegua()	
			If lAbortPrint
				@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
				Exit
			EndIf
			If nLin > 63 
				If nLin # 80
					@ nLin,1 PSay "----------------------------------------------------------------------------------------------------------------------------------"
				EndIf
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++                                       
				@ nLin++,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
				@ nLin++,0 PSay "| Produto        | Descricao                                     | Qt.Prod.(m)| Peso (Kg)| Peso Pad. |Kg/100m| %Medio | Peso Cobre|"
				@ nLin++,0 PSay "|----------------|-----------------------------------------------|------------|----------|-----------|-------|--------|-----------|"
				_lNewProd := .F.
			Endif              
			If _lNewProd
				_lNewProd := .f.
				@ nLin++,0 PSay "|----------------|-----------------------------------------------|------------|----------|-----------|-------|--------|-----------|"
			EndIf
			SB1->(DbSeek(xFilial("SB1")+TRB->ZL_PRODUTO,.F.))
			_MyZL_PROD := TRB->ZL_PRODUTO     
			_MyZL_DESC := TRB->ZL_DESC
			_MyQUANT   := 0
			_MyPESOE   := 0
			_MyPESOP := 0

			_cChave2 := &_cChave.
			Do While &_cChave. == _cChave2 .And. !TRB->(Eof())

				_MyQUANT += TRB->QUANT
				_MyPESOE += TRB->PESOE
				_MyPESOP += TRB->PESOP

				_nQUANT += TRB->QUANT
				_nPESOE += TRB->PESOE
				_nPESOP += TRB->PESOP
				_nPESOC += (TRB->QUANT*SB1->B1_PESCOB)

				_nPESO1 += If(TRB->ZL_TURNO=="1",(TRB->QUANT*SB1->B1_PESCOB),0)
				_nPESO2 += If(TRB->ZL_TURNO=="2",(TRB->QUANT*SB1->B1_PESCOB),0)
				_nPESO3 += If(TRB->ZL_TURNO=="3",(TRB->QUANT*SB1->B1_PESCOB),0)

				_ngQUANT += TRB->QUANT
				_ngPESOE += TRB->PESOE
				_ngPESOP += TRB->PESOP
				_ngPESOC += (TRB->QUANT*SB1->B1_PESCOB)

				_ngPESO1 += If(TRB->ZL_TURNO=="1",(TRB->QUANT*SB1->B1_PESCOB),0)
				_ngPESO2 += If(TRB->ZL_TURNO=="2",(TRB->QUANT*SB1->B1_PESCOB),0)
				_ngPESO3 += If(TRB->ZL_TURNO=="3",(TRB->QUANT*SB1->B1_PESCOB),0)

				TRB->(DbSkip())
			EndDo


			_PesoCb := _MyQUANT*SB1->B1_PESCOB
			_Media  := Round(((_MyPESOE-_MyPESOP) / _MyPESOP) * 100,2)

			@ nLin,000 PSay "|"
			@ nLin,002 PSay AllTrim(_MyZL_PROD) Picture "@R 999.99.99.9.99"
			@ nLin,017 PSay "|"
			@ nLin,019 PSay Left(_MyZL_DESC,45)
			@ nLin,065 PSay "|"
			@ nLin,066 PSay _MyQUANT Picture "@E 999,999,999"
			@ nLin,078 PSay "|"
			@ nLin,079 PSay _MyPESOE Picture "@E 99,999,999"
			@ nLin,089 PSay "|"
			@ nLin,090 PSay _MyPESOP Picture "@E 99,999,999"
			@ nLin,101 PSay "|"
			@ nLin,102 PSay Round((_MyPESOE/_MyQUANT)*100,2) Picture "@E 999.99"
			@ nLin,109 PSay "|"
			@ nLin,110 PSay _Media Picture "@E 9999.99
			@ nLin,118 PSay "|"
			@ nLin,119 PSay _PesoCb Picture "@E 99,999,999"
			@ nLin,130 PSay "|"
			nLin := nLin + 1
		EndDo

		For _nN := 1 to 4
			If nLin > 63 
				If nLin # 80
					@ nLin,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
				EndIf
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++                                       
				@ nLin++,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
				@ nLin++,0 PSay "| Produto        | Descricao                                     | Qt.Prod.(m)| Peso (Kg)| Peso Pad. |Kg/100m| %Medio | Peso Cobre|"
			Endif
			If _nN == 1
				_Media  := Round(((_nPESOE-_nPESOP) / _nPESOP) * 100,2)
				@ nLin++,0 PSay "|----------------|-----------------------------------------------|------------|----------|-----------|-------|--------|-----------|"
				@ nLin,000 PSay "|"
				If mv_par10 == 1
					@ nLin,002 PSay _cProd Picture "@R 999.99"
					@ nLin,017 PSay "|  Total Produto   | Peso Medio 100m->"
					@ nLin,056 PSAY (_nPESOE/_nQUANT) * 100 Picture "@E 9999.99"

					@ nLin,065 PSay "|"
				Else
					@ nLin,017 PSay "|  Total da Linha: " 
					For _nxx := 1 to Len(_aOpcoes)
						If AllTrim(_aOpcoes[_nxx,2]) == _cProd
							@ nLin,036 PSay  _aOpcoes[_nxx,1]
							Exit		
						EndIf
					Next
					@ nLin,065 PSay "|"
				EndIf                          
				@ nLin,066 PSay _nQUANT Picture "@E 999,999,999"
				@ nLin,078 PSay "|"
				@ nLin,079 PSay _nPESOE Picture "@E 99,999,999"
				@ nLin,089 PSay "|"
				@ nLin,090 PSay _nPESOP Picture "@E 99,999,999"
				@ nLin,101 PSay "|"
				@ nLin,102 PSay Round((_nPESOE/_nQUANT)*100,2) Picture "@E 999.99"
				@ nLin,109 PSay "|"
				@ nLin,110 PSay _Media Picture "@E 9999.99"
				@ nLin,118 PSay "|"
				@ nLin,119 PSay _nPESOC Picture "@E 99,999,999"
				@ nLin,130 PSay "|"
			Else           
				_nnPeso := "_nPESO"+Str(_nN-1,1)
				_nnPeso := &_nnPeso.
				If _nnPeso <= 0 
					Loop
				EndIf
				@ nLin,000 PSay "|"
				@ nLin,017 PSay "|                  | Total do " + Str(_nN-1,1) + " turno"
				@ nLin,065 PSay "|"
				@ nLin,078 PSay "|"
				@ nLin,089 PSay "|"
				@ nLin,101 PSay "|"
				@ nLin,109 PSay "|"
				@ nLin,118 PSay "|"
				@ nLin,119 PSay _nnPeso Picture "@E 99,999,999"
				@ nLin,130 PSay "|"
			EndIf
			nLin := nLin + 1
		Next

		If TRB->(Eof())

			For _nN := 1 to 4
				If nLin > 63 
					If nLin # 80
						@ nLin,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
					EndIf
					nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin++                                       
					@ nLin++,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
					@ nLin++,0 PSay "| Produto        | Descricao                                     | Qt.Prod.(m)| Peso (Kg)| Peso Pad. |Kg/100m| %Medio | Peso Cobre|"
				Endif
				If _nN == 1
					_Media  := Round(((_ngPESOE-_ngPESOP) / _ngPESOP) * 100,2)
					@ nLin++,0 PSay "|----------------|-----------------------------------------------|------------|----------|-----------|-------|--------|-----------|"
					@ nLin,000 PSay "|"
					@ nLin,017 PSay "|  Total Geral "
					@ nLin,065 PSay "|"
					@ nLin,066 PSay _ngQUANT Picture "@E 999,999,999"
					@ nLin,078 PSay "|"
					@ nLin,079 PSay _ngPESOE Picture "@E 99,999,999"
					@ nLin,089 PSay "|"
					@ nLin,090 PSay _ngPESOP Picture "@E 99,999,999"
					@ nLin,101 PSay "|"
					@ nLin,102 PSay Round((_ngPESOE/_ngQUANT)*100,2) Picture "@E 999.99"
					@ nLin,109 PSay "|"
					@ nLin,110 PSay _Media Picture "@E 9999.99
					@ nLin,118 PSay "|"
					@ nLin,119 PSay _ngPESOC Picture "@E 99,999,999"
					@ nLin,130 PSay "|"
				Else
					_nnPeso := "_ngPESO"+Str(_nN-1,1)
					_nnPeso := &_nnPeso.
					If _nnPeso <= 0 
						Loop
					EndIf
					@ nLin,000 PSay "|"
					@ nLin,017 PSay "|                  | Total do " + Str(_nN-1,1) + " turno"
					@ nLin,065 PSay "|"
					@ nLin,078 PSay "|"
					@ nLin,089 PSay "|"
					@ nLin,101 PSay "|"
					@ nLin,109 PSay "|"
					@ nLin,118 PSay "|"
					@ nLin,119 PSay _nnPeso Picture "@E 99,999,999"
					@ nLin,130 PSay "|"
				EndIf
				nLin := nLin + 1
			Next
			@ nLin,1 PSay "---------------------------------------------------------------------------------------------------------------------------------"
		EndIf
	EndDo
	DbSelectArea("TRB")
	DbCloseArea()

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Data                      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Da Hora                      ?","mv_ch3","C",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","99:99:99"})
	aAdd(aRegs,{cPerg,"03","At้ Data                     ?","mv_ch2","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","At้ Hora                     ?","mv_ch4","C",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","99:99:99"})
	aAdd(aRegs,{cPerg,"05","Do Produto                   ?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SB1",""})
	aAdd(aRegs,{cPerg,"06","At้ o Produto                ?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","SB1",""})
	aAdd(aRegs,{cPerg,"07","Inclui Retalhos              ?","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","Nใo","","","So Retalhos","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Peso De  %                   ?","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Peso Ate %                   ?","mv_ch9","C",04,0,0,"G","","mv_par09","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Aglutina por                 ?","mv_cha","N",01,0,0,"C","","mv_par10","Produto","","","Linha","","","","","","","","","","","",""})

	/*
	aAdd(aRegs,{cPerg,"01","Da Data                      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","At้ Data                     ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Produto                   ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","At้ o Produto                ?","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Inclui Retalhos              ?","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","Nใo","","","So Retalhos","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Inclui Peso Acima 5%         ?","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","Nใo","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Aglutina por                 ?","mv_cha","N",01,0,0,"C","","mv_par10","Produto","","","Linha","","","","","","","","","","",""})
	*/

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			SX1->X1_PICTURE := aRegs[i,27]
			MsUnlock()
			DbCommit()
		Endif
	Next

	RestArea(_aArea)

Return(.T.)

/*/
//	@ _nLi,00 PSay "Produto        Descricao                                         Qtd.(m) Lances/Metragem Acondic.       Peso  Situacao    Quant.Sit."
---------------------------------------------------------------------------------------------------------------------------------	
| Produto       | Descricao                                          | Qt.Prod.(m) | Peso (Kg) | Peso Pad. | % Medio | Peso Cobre |
|---------------|----------------------------------------------------|-------------|-----------|-----------|---------|------------|
| 99.99.99.9.99 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |  99,999,999 | 9,999,999 | 9,999,999 |  999,99 |  9,999,999 |
| 99.99.99.9.99 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |  99,999,999 | 9,999,999 | 9,999,999 |  999,99 |  9,999,999 |
| 99.99.99.9.99 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |  99,999,999 | 9,999,999 | 9,999,999 |  999,99 |  9,999,999 |
| 99.99.99.9.99 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |  99,999,999 | 9,999,999 | 9,999,999 |  999,99 |  9,999,999 |
| 99.99.99.9.99 | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |  99,999,999 | 9,999,999 | 9,999,999 |  999,99 |  9,999,999 |




999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  N/Separ.
999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  Separado
999.99.99.9.99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99,999 999999 X 999999 Carretel 999,999.99  Faturado
/*/