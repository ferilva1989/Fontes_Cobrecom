#include "TOPCONN.ch"
#Include "RWMAKE.Ch"

/*/{Protheus.doc} RFATMAPA6
@author zzz
@since 06/06/2017
@version 1.0
@type function
@description Emitir diariamente o mapa de vendas com quebra de periodos, Este relatorio esta associado com
a tabela SX5 (Z3) onde temos cadastrados os periodos do nosso fechamento. Todo fechamento
devemos criar um registro no SX5 (Z3) contendo a data do proximo fechamento, Para que o relatorio funcione
/*/
User FuncTion RFATMAPA6()
	LOCAL cDesc1   := "Relacao de vendas p/ Vendedores dos 6 meses anteriores a data do parametro.  "
	LOCAL cDesc2   := ""
	LOCAL cDesc3   := ""
	LOCAL cString  := ""
	Local _nPosPer 	:= 0 //Declaração Variavel conforme error.log de 29/06/2015
	Private wnrel    := "RPROSVPER"
	Private cPerg    := "MAPA06"
	Private NomeProg := "RFATMAPA6"
	Private titulo   := "Mapa de Vendas (Vlr.Mercadoria)"
	Private Tamanho  := "G"
	Private nTipo    := 18
	Private aOrd     := {}
	Private m_pag      := 01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis privadas ,padrao de todos os relatorios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aReturn    := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	PRIVATE nLastKey   := 0
	PRIVATE aImpressao := {}
	PRIVATE aCampos := {}
	Private nLin       := 80
	Private nAno := 0
	Private nMes := 0
	Private aPeriodo := {}
	PutSX1(cPerg,"01","Data de referencia ?","Data de referencia ?  ","Data de referencia ? ","mv_ch1","D",08,0,0,"G","",""   ,"","","mv_par01",;
	"","","","","","","","","","","","","","","","",{"Data de referencia de processamento","seis meses anteriores a esta data."},;
	{"Data de referencia de processamento","seis meses anteriores a esta data."},;
	{"Data de referencia de processamento","seis meses anteriores a esta data."})
	PutSx1(cPerg,"02","Vendedor de ? "      ,""                      ,""                     ,"mv_ch2","C",06,0,0,"G","","SA3","","","mv_par02",;
	"","","","","","","","","","","","","","","","",{"Vendedor inicial."},;
	{"Vendedor inicial."},;
	{"Vendedor inicial."})
	PutSx1(cPerg,"03","Vendedor ate ? "     ,""                      ,""                     ,"mv_ch3","C",06,0,0,"G","","SA3","","","mv_par03",;
	"","","","","","","","","","","","","","","","",{"Vendedor final."  },;
	{"Vendedor final."  },;
	{"Vendedor final."  })
	If !Pergunte(cPerg,.T.)
		Return
	EndIF
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint("",wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)
	If nLastKey = 27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey = 27
		Set Filter to
		Return
	Endif
	Private dDataIni  := MV_PAR01
	Private dDataRel  := MV_PAR01
	If EmpTy(dDataIni)
		Alert("Informe a data de referencia...")
		Return
	EndIF
	Li := 80

	/*/
	Representante                                    UF    Inicio         MAR/07         ABR/07         MAI/07         JUN/07         JUL/07         AGO/07      Valor Total  Valor Medio  Rnk.         SET/07  % Vda.  % Acm.
	03/03a31/03    01/04a04/05    05/05a01/06    02/06a30/06    01/07a03/08    04/08a31/08                                        01/09a28/09
	/*/

	Cabec1 :=  	"Representante                                    UF    Inicio"
	Cabec2 :=   ""
	//
	//           0              15     23 25       35                  50              65           80               95
	//                    1         2         3         4         5         6         7         8         9          10       11
	//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789`
	_nTotRel := 0.00
	_PeriCab:={} //{Dt Ini,Dt Fim,Descricao}

	Processa({|| MAPA6PROC() },"Processando...")

	Processa({|| CalcPv() },"Verificando Carteira de Pedidos de Vendas...")

	RptStatus({|lEnd| IMPMAPA6(aOrd,@lEnd,wnRel,cString,tamanho,titulo)},titulo)

Return(NIL)

///////////////////////////
Static FuncTion MAPA6PROC()
Local _nPosPer := 0
	///////////////////////////
	//
	// Carrega a tabela Z3 (SX5)
	DbSelectArea("SX5")
	DbSeek(xFilial("SX5")+"Z3",.F.)
	aPeriodo := {} // {Data Fim,Data INI,Descr}
	Do While SX5->X5_FILIAL == xFilial("SX5") .And.SX5->X5_TABELA == "Z3".And.SX5->(!Eof())
		aadd(aPeriodo,{Ctod(AllTrim(SX5->X5_DESCRI)),Ctod("  /  /  "),SX5->X5_CHAVE})
		SX5->(DbSkip())
	EndDo

	aSort(aPeriodo,,,{|x,y| x[1]<y[1]})
	_UltDated := Ctod("")
	For _n1 := 1 to Len(aPeriodo)
		aPeriodo[_n1,2] := _UltDated
		_UltDated := aPeriodo[_n1,1] + 1
		If dDataIni >= aPeriodo[_n1,2] .And. dDataIni <= aPeriodo[_n1,1]
			_nPosPer := _n1
		EndIf
	Next
	
	_PeriCab:={} //{Dt Ini,Dt Fim,Descricao}
	dDataIni := dDatabase
	dDataFim := Ctod("")
	For _n1 := _nPosPer-6 to _nPosPer
		If _n1 < 1
			Loop
		EndIf
		Aadd(_PeriCab,{aPeriodo[_n1,2],Min(dDataRel,aPeriodo[_n1,1]),aPeriodo[_n1,3]}) //{Dt Ini,Dt Fim,Descricao}
		dDataIni := Min(dDataIni,_PeriCab[Len(_PeriCab),1])
		dDataFim := Max(dDataFim,_PeriCab[Len(_PeriCab),2])
	Next
	/*/
	epresentante                                    UF    Inicio        MAR/07        ABR/07        MAI/07        JUN/07        JUL/07        AGO/07   Valor Total  Vlr Medio  Rnk.        SET/07  PV Carteira  %Vda.   %Acm.
	03/03a31/03   01/04a04/05   05/05a01/06   02/06a30/06   01/07a03/08   04/08a31/08                                  01/09a28/09
	99999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  XX  01/01/01  99999,999.99  99999,999.99  99999,999.99  99999,999.99  99999,999.99  99999,999.99   999,999,999 99,999,999  9999  99999,999.99  999,999,999  999.9   999.9
	7                                         49  53        63            77            91            105           119           133            148         160         172   178           192          205     213

	/*/
	cabec2 := "                                                             "
	For nP := 1 To Len(_PeriCab)-1  //{Dt Ini,Dt Fim,Descricao}
		cabec1 +=  "        "+_PeriCab[nP,3]
		cabec2 +=  "   "+Left(Dtoc(_PeriCab[nP,1]),5)+"a"+Left(Dtoc(_PeriCab[nP,2]),5)
	Next
	cabec1 := Left(cabec1 + Space(148),148) + "Valor Total  Vlr Medio  Rnk.        " + _PeriCab[Len(_PeriCab),3] + "  PV Carteira  %Vda.   %Acm."
	cabec2 +=  "                                  " + Left(Dtoc(_PeriCab[Len(_PeriCab),1]),5)+"a"+Left(Dtoc(_PeriCab[Len(_PeriCab),2]),5)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montando Array aCampos com a estrutura do DBF         		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aTam := TamSX3("A3_COD")
	AAdd( aCampos, {"VEND","C",aTam[1],aTam[2]} )

	//aTam := TamSX3("A1_COD")
	//AAdd( aCampos, {"CLIENTE","C",aTam[1],aTam[2]} )

	//aTam := TamSX3("A1_LOJA")
	//AAdd( aCampos, {"LOJA","C",aTam[1],aTam[2]} )

	//aTam := TamSX3("D2_TOTAL")
	AAdd( aCampos, {"MES1","N",11,2} )
	AAdd( aCampos, {"MES2","N",11,2} )
	AAdd( aCampos, {"MES3","N",11,2} )
	AAdd( aCampos, {"MES4","N",11,2} )
	AAdd( aCampos, {"MES5","N",11,2} )
	AAdd( aCampos, {"MES6","N",11,2} )
	AAdd( aCampos, {"MES7","N",11,2} )
	AAdd( aCampos, {"TOTREL","N",12,2} )
	AAdd( aCampos, {"MESES","N",2,0} )
	AAdd( aCampos, {"CART","N",11,2} )


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando estrutura Temporaria                          		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cArqTmp := CriaTrab( aCampos, .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definindo um Alias para a estrutura                   		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea(.T.,,cArqTmp,"TRB", .T., .F.)

	cIndTrb := CriaTrab('', .F.)

	cIndTr1 := 	Left(cIndTrb,7)+ "A"
	IndRegua('TRB',cIndTr1,"VEND",,,'Selecionando Registros...')

	cIndTr2 := 	Left(cIndTrb,7)+ "B"
	IndRegua('TRB',cIndTr2,"StrZero(TOTREL,12,2)",,,'Selecionando Registros...')

	DbClearIndex() // Fecha todos s arquivos de indices
	DbSetIndex(cIndTr1 + OrdBagExt())
	DbSetIndex(cIndTr2 + OrdBagExt())
	DbSetOrder(1)

	#IFDEF TOP
	For _nNx := 1 to 7

		_cQuery := "SELECT F2_VEND1, ROUND(SUM(D2_TOTAL),2) D2_TOTAL "
		_cQuery += "FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SF4")+" SF4 "
		_cQuery += "WHERE D2_FILIAL  = '"+xFilial("SD2")+"'AND F4_FILIAL = '"+xFilial("SF4")+"' AND F2_FILIAL = '"+xFilial("SF2")+"' AND A3_FILIAL = '"+xFilial("SA3")+"' "
		_cQuery += "AND D2_DOC     = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D2_TES = F4_CODIGO "
		_cQuery += "AND F4_DUPLIC  = 'S' AND F2_VEND1   = A3_COD AND D2_EMISSAO BETWEEN '" + Dtos(_PeriCab[_nNx,1]) +"' AND '" + Dtos(_PeriCab[_nNx,2]) +"' "
		_cQuery += "AND F2_VEND1 >= '" + MV_PAR02 + "'AND F2_VEND1 <= '" + MV_PAR03 + "' "
		_cQuery += "AND SD2.D_E_L_E_T_<>'*' AND SF2.D_E_L_E_T_<>'*' AND SA3.D_E_L_E_T_<>'*' AND SF4.D_E_L_E_T_<>'*'"
		_cQuery += "GROUP BY F2_VEND1 ORDER BY F2_VEND1"
		_cQuery := ChangeQuery(_cQuery)

		If Select("TRBQry") > 0
			DbSelectArea("TRBQry")
			DbCloseArea("TRBQry")
		EndIf

		TCQUERY _cQuery NEW ALIAS "TRBQry"

		DbSelectArea("TRBQry")
		TRBQry->(DbGoTop())
		ProcRegua(TRBQry->(RecCount()))

		cCampo := "TRB->MES"+StrZero(_nNx,1)
		DbSelectArea("TRB")

		Do While TRBQry->(!Eof())
			IncProc()
			If TRB->(DbSeek(TRBQry->F2_VEND1,.F.))
				TRB->(Reclock("TRB",.F.))
			Else
				TRB->(Reclock("TRB",.T.))
				TRB->VEND   := TRBQry->F2_VEND1
			EndIF

			&cCampo     += TRBQry->D2_TOTAL
			If _nNx # Len(_PeriCab)
				TRB->TOTREL += TRBQry->D2_TOTAL
				_nTotRel    += TRBQry->D2_TOTAL
			EndIf
			TRB->(MSUNLOCK())
			TRBQry->(DbSkip())
		EndDo
		If Select("TRBQry") > 0
			DbSelectArea("TRBQry")
			DbCloseArea("TRBQry")
		EndIf
	Next
	#ELSE
	DbSelectArea("SD2")
	DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	DbSelectArea("SF4")
	DbSetOrder(1) // F4_FILIAL+F4_CODIGO

	DbSelectArea("SF2")
	cNomArq := CriaTrab('', .F.)
	cKey    := "F2_FILIAL + DTOS(F2_EMISORI)"
	IndRegua('SF2',cNomArq,cKey,,,'Selecionando Registros...')
	nInd := RetIndex("SF2")
	#IFNDEF TOP
	DbSetIndex(cNomArq+OrdBagExt())
	#ENDIF
	DbSetOrder(nInd+1)
	ProcRegua( Reccount() )
	_dIniSiga := Ctod("05/03/07") // Data de inicio do faturamento no Microsiga
	DbSeek(xFilial("SF2")+DtoS(Max(dDataIni,_dIniSiga)),.T.)
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_EMISORI <= dDataFim .And. SF2->(!Eof())
		IncProc()
		If SF2->F2_VALFAT > 0.00 .And. SF2->F2_VEND1 >= MV_PAR02 .And. SF2->F2_VEND1 <= MV_PAR03 .And. SF2->F2_TIPO == "N"
			nPos := 0
			For _nx  := 1 To Len(_PeriCab)
				If SF2->F2_EMISORI <= _PeriCab[_nx,2]
					nPos := _nx
					Exit
				EndIf
			Next

			If nPos > 0
				DbSelectArea("SD2")
				DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
				_nSomaItem := 0.00
				Do While SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
				xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA .And. SD2->(!Eof())

					SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.))
					If SF4->F4_DUPLIC == "S"
						_nSomaItem += SD2->D2_TOTAL
					EndIf
					SD2->(DbSkip())
				EndDo

				cCampo := "TRB->MES"+StrZero(nPos,1)
				DbSelectArea("TRB")
				If DbSeek(SF2->F2_VEND1,.F.)
					TRB->(Reclock("TRB",.F.))
				Else
					TRB->(Reclock("TRB",.T.))
					TRB->VEND   := SF2->F2_VEND1
				EndIF

				&cCampo     += _nSomaItem
				If nPos # Len(_PeriCab)
					TRB->TOTREL += _nSomaItem
					_nTotRel    += _nSomaItem
				EndIf
				TRB->(MSUNLOCK())
			EndIF
		EndIF
		DbSelectArea("SF2")
		DbSkip()
	EndDo
	RetIndex("SF2")
	Ferase(cNomArq)
	#ENDIF
Return(.T.)

///////////////////////////
Static FuncTion IMPMAPA6()
	///////////////////////////

	DbSelectArea("SA1")
	DbSetOrder(1)

	DbSelectArea("TRB")
	DbSetOrder(2) // Ranking
	DbGoBottom()
	nTMes1 := 0
	nTMes2 := 0
	nTMes3 := 0
	nTMes4 := 0
	nTMes5 := 0
	nTMes6 := 0
	nTMes7 := 0
	nTCart := 0
	_nRank := 0
	_nTotAcm := 0.00
	_dIniSiga := Ctod("05/03/07") // Data de inicio do faturamento no Microsiga
	_dDtIni := Max(dDataIni,_dIniSiga)

	Do While TRB->(!EoF()) .And. TRB->(!BoF())
		If nLin > 60
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin ++
		Endif
		_nMeses := 6
		If Empty(TRB->VEND)
			@nLin,007 PSAY "SEM DEFINICAO DE VENDEDOR"
		Else
			SA3->(DbSeek(xFilial("SA3")+TRB->VEND,.F.))
			_dDtBase := Max(_dDtIni,SA3->A3_ADMISS)
			_nMeses := 6
			For _nx  := 1 To Len(_PeriCab) //{Dt Ini,Dt Fim,Descricao}
				If _dDtBase <= _PeriCab[_nx,2]
					Exit
				EndIf
			Next
			_nMeses := 6 - _nx + 1
			IF Empty(SA3->A3_DEMISS) .Or. (SA3->A3_DEMISS >= _Pericab[1,1] .And. SA3->A3_DEMISS <= _Pericab[Len(_Pericab),2])
				@nLin,000 PSAY TRB->VEND + " " + Left(SA3->A3_NOME,40)
				@nLin,049 PSAY SA3->A3_EST
				@nLin,053 PSAY SA3->A3_ADMISS
			EndIf
		EndIf
		_cVend := TRB->VEND

		/*/
		nMes1 := 0
		nMes2 := 0
		nMes3 := 0
		nMes4 := 0
		nMes5 := 0
		nMes6 := 0
		nMes7 := 0
		/*/
		nTMes1 += TRB->MES1
		nTMes2 += TRB->MES2
		nTMes3 += TRB->MES3
		nTMes4 += TRB->MES4
		nTMes5 += TRB->MES5
		nTMes6 += TRB->MES6
		nTMes7 += TRB->MES7
		nTCart += TRB->CART

		_nTotAcm += TRB->TOTREL

		/*/
		epresentante                                    UF    Inicio        MAR/07        ABR/07        MAI/07        JUN/07        JUL/07
		99999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  XX  01/01/01  99999,999.99  99999,999.99  99999,999.99  99999,999.99  99999,999.99
		7                                         49  53        63            77            91            105           119
		AGO/07   Valor Total  Vlr Medio  Rnk.        SET/07  PV Carteira  %Vda.   %Acm.
		99999,999.99   999,999,999 99,999,999  9999  99999,999.99  999,999,999  999.9   999.9
		133            148         160         172   178           192          205     213
		/*/
		//    IF Empty(SA3->A3_DEMISS)
		IF Empty(SA3->A3_DEMISS) .Or. (SA3->A3_DEMISS >= _Pericab[1,1] .And. SA3->A3_DEMISS <= _Pericab[Len(_Pericab),2])

			@nLin,063 PSAY TRB->MES1     Picture  "@E 99999,999.99"
			@nLin,077 PSAY TRB->MES2     Picture  "@E 99999,999.99"
			@nLin,091 PSAY TRB->MES3     Picture  "@E 99999,999.99"
			@nLin,105 PSAY TRB->MES4     Picture  "@E 99999,999.99"
			@nLin,119 PSAY TRB->MES5     Picture  "@E 99999,999.99"
			@nLin,133 PSAY TRB->MES6     Picture  "@E 99999,999.99"
			@nLin,148 PSAY TRB->TOTREL   Picture  "@E 999,999,999"
			@nLin,160 PSAY TRB->TOTREL/_nMeses Picture  "@E 99,999,999"
			@nLin,172 PSAY ++_nRank      Picture  "9999"
			@nLin,178 PSAY TRB->MES7     Picture  "@E 99999,999.99"
			@nLin,192 PSAY TRB->CART     Picture  "@E 999,999,999"
			@nLin,205 PSAY (TRB->TOTREL /_nTotRel) * 100 Picture  "@E 999.9"
			@nLin,213 PSAY (_nTotAcm    /_nTotRel) * 100 Picture  "@E 999.9"
			nLin ++
		EndIf
		TRB->(DbSkip(-1))
	EndDo
	@ nLin,000 PSay __PrtThinLine()
	nLin ++
	nTotal := nTMes1 + nTMes2 + nTMes3 + nTMes4 + nTMes5 + nTMes6
	@nLin,007 PSAY "Totais:"
	@nLin,063 PSAY nTMes1    Picture  "@E 99999,999.99"
	@nLin,077 PSAY nTMes2    Picture  "@E 99999,999.99"
	@nLin,091 PSAY nTMes3    Picture  "@E 99999,999.99"
	@nLin,105 PSAY nTMes4    Picture  "@E 99999,999.99"
	@nLin,119 PSAY nTMes5    Picture  "@E 99999,999.99"
	@nLin,133 PSAY nTMes6    Picture  "@E 99999,999.99"
	@nLin,148 PSAY nTotal    Picture  "@E 999,999,999"
	@nLin,160 PSAY nTotal/6  Picture  "@E 99,999,999"
	@nLin,178 PSAY nTMes7    Picture  "@E 99999,999.99"
	@nLin,192 PSAY nTCart    Picture  "@E 999,999,999"
	nLin ++
	//nTCart
	@ nLin,000 PSay __PrtThinLine()

	DbSelectArea("TRB")
	DbCloseArea()
	//Ferase(cArqTmp)

	If aReturn[5] == 1
		Set Printer TO
		dbCommitAll()
		Ourspool(wnrel)
	EndIf

	Ms_Flush()

	Return(.T.)
	*
	************************
Static Function CalcPv()
	************************
	*
	DbSelectArea("TRB")
	DbSetOrder(1)  //VEND

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	#IFDEF TOP
	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM

	_cQuery := " SELECT C5_NUM,C5_VEND1,C5_DATALIB"
	_cQuery += " FROM " +RetSqlName("SC5")+ " SC5"
	_cQuery += " WHERE "
	_cQuery += " C5_FILIAL      = '"+xFilial("SC5")+"' "
	_cQuery += " AND C5_VEND1 BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
	_cQuery += " AND C5_NOTA = ''"
	_cQuery += " AND C5_LIBEROK <> 'E'"
	_cQuery += " AND SC5.D_E_L_E_T_<>'*'"
	_cQuery := ChangeQuery(_cQuery)

	If Select("TRBQry") > 0
		DbSelectArea("TRBQry")
		DbCloseArea("TRBQry")
	EndIf

	TCQUERY _cQuery NEW ALIAS "TRBQry"

	DbSelectArea("TRBQry")
	TRBQry->(DbGoTop())
	ProcRegua(TRBQry->(RecCount()))

	Do While TRBQry->(!Eof())
		IncProc()

		SC9->(DbSeek(xFilial("SC9")+TRBQry->C5_NUM,.F.))
		If Empty(TRBQry->C5_DATALIB)
			If SC5->(DbSeek(xFilial("SC5")+TRBQry->C5_NUM,.F.))
				If Empty(SC5->C5_DATALIB)
					RecLock("SC5",.F.)
					SC5->C5_DATALIB := SC9->C9_DATALIB
					MsUnLock()
				EndIf
			EndIf
		EndIf

		_nValTot := u_SomaPed(TRBQry->C5_NUM,.F.," ","S",1) //(Nro.PV,Tudo ou só saldo,TES Estoque, TES Financeiro)
		// SomaPed retorna o Valor de Venda e o Valor de Custo
		If _nValTot[1] > 0.00
			DbSelectArea("TRB")
			If !DbSeek(TRBQry->C5_VEND1,.F.)
				RecLock("TRB",.T.)
				TRB->VEND := TRBQry->C5_VEND1
			Else
				RecLock("TRB",.F.)
			EndIf
			TRB->CART := TRB->CART + _nValTot[1]
			MsUnLock()
		EndIf
		DbSelectArea("TRBQry")
		TRBQry->(DbSkip())
	EndDo

	If Select("TRBQry") > 0
		DbSelectArea("TRBQry")
		DbCloseArea("TRBQry")
	EndIf

	#ELSE

	DbSelectArea("SC5")
	DbSetOrder(2)  //C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM
	ProcRegua(RecCount())
	DbSeek(xFilial("SC5"),.T.)
	Do While SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())

		IncProc()

		// se tiver eliminado residuo??
		If SC5->C5_LIBEROK == "E"
			DbSelectArea("SC5")
			DbSkip()
			Loop
		EndIf

		//	If SC5->C5_NUM $ "005066/005328/005334/005207/005189"
		//	  ddd := 1
		//	EndIf

		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
		_lTemFat := .F.
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
			If SC9->C9_BLEST == "10" .Or. SC9->C9_BLCRED == "10"
				_lTemFat := .T.
				Exit
			EndIf
			SC9->(DbSkip())
		EndDo
		SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
		If Empty(SC5->C5_DATALIB)
			RecLock("SC5",.F.)
			SC5->C5_DATALIB := SC9->C9_DATALIB
			MsUnLock()
		EndIf

		_nValTot := u_SomaPed(SC5->C5_NUM,.F.," ","S",1) //(Nro.PV,Tudo ou só saldo,TES Estoque, TES Financeiro)
		// SomaPed retorna o Valor de Venda e o Valor de Custo
		If _nValTot[1] > 0.00
			DbSelectArea("TRB")
			If !DbSeek(SC5->C5_VEND1,.F.)
				RecLock("TRB",.T.)
				TRB->VEND := SC5->C5_VEND1
			Else
				RecLock("TRB",.F.)
			EndIf
			TRB->CART := TRB->CART + _nValTot[1]
			MsUnLock()
		EndIf
		DbSelectArea("SC5")
		DbSkip()
	EndDo
	#ENDIF

Return(.T.)