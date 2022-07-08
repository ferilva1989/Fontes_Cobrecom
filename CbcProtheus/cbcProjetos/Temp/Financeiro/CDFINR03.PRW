#INCLUDE "rwmake.ch"

//#INCLUDE "FIVEWIN.CH"
/*ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё MATR540  Ё Autor Ё Claudinei M. Benzi       Ё Data Ё 13.04.92 Ё╠╠
╠╠цддддддддддеддддддддддадддддддаддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Relatorio de Comissoes.                                       Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё MATR540(void)                                                 Ё╠╠
╠╠цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                      Ё╠╠
╠╠юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддбддддддбддддддддддбддддддддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠Ё DATA   Ё BOPS ЁProgramad.ЁALTERACAO                                      Ё╠╠
╠╠цддддддддеддддддеддддддддддеддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё05.02.03ЁXXXXXXЁEduardo JuЁInclusao de Queries para filtros em TOPCONNECT.Ё╠╠
╠╠юддддддддаддддддаддддддддддаддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
User Function CDFinR03()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define Variaveis                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local wnrel
	Local titulo    := "Relatorio de Comissoes"
	Local cDesc1    := "Emissao do relatorio de Comissoes."
	Local tamanho   := "P"
	Local limite    := 80
	Local cString   := "SE3"
	Local cAliasAnt := Alias()
	Local cOrdemAnt := IndexOrd()
	Local nRegAnt   := Recno()
	Private aReturn := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nomeprog:= "CDFINR03"
	Private aLinha  := { },nLastKey := 0
	Private cPerg   := "CDFR03"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica as perguntas selecionadas                           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Pergunte("CDFR03",.F.)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para parametros                         Ё
	//Ё mv_par01        	// Pela <E>missao,<B>aixa ou <A>mbos        Ё
	//Ё mv_par02        	// A partir da data                         Ё
	//Ё mv_par03        	// Ate a Data                               Ё
	//Ё mv_par04 	    	// Do Vendedor                              Ё
	//Ё mv_par05	     	// Ao Vendedor                              Ё
	//Ё mv_par06	     	// Quais (a Pagar/Pagas/Ambas)              Ё
	//Ё mv_par07	     	// Incluir Devolucao ?                      Ё
	//Ё mv_par08	     	// Qual moeda                               Ё
	//Ё mv_par09	     	// Comissao Zerada ?                        Ё
	//Ё mv_par10	     	// Abate IR Comiss                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia controle para a funcao SETPRINT                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	wnrel := "CDFINR03"
	wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,"","",.F.,"",.F.,Tamanho)
	_Modelo := 2 // 1 Completo 2 sem nro do romaneio
	//wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

	If nLastKey==27
		Set Filter to
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey ==27
		Set Filter to
		Return
	Endif

	RptStatus({|lEnd| C540Imp(@lEnd,wnRel,cString)},Titulo)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Retorna para area anterior, indice anterior e registro ant.  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea(caliasAnt)
	DbSetOrder(cOrdemAnt)
	DbGoto(nRegAnt)
Return

/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё C540IMP  Ё Autor Ё Rosane Luciane Chene  Ё Data Ё 09.11.95 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chamada do Relatorio                                       Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё MATR540			                                            Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function C540Imp(lEnd,WnRel,cString)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define Variaveis                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Local CbCont,cabec1,cabec2
	Local tamanho  := "P"
	Local limite   := 80
	Local nomeprog := "CDFINR03"
	Local imprime  := .T.
	Local cPict    := ""
	Local cTexto,j :=0,nTipo:=0
	Local cCodAnt,nCol:=0
	Local nAc1:=0,nAc2:=0,nAg1:=0,nAg2:=0,nAc3:=0,nAg3:=0,lFirstV:=.T.
	Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7
	Local lContinua:= .T.
	Local cNFiscal :=""
	Local aCampos  :={}
	Local lImpDev  := .F.
	Local cBase    := ""
	Local cNomArq, cCondicao, cFilialSE1, cFilialSE3, cChave, cFiltroUsu
	Local nDecs    := GetMv("MV_CENT"+(IIF(mv_par08 > 1 , STR(mv_par08,1),"")))
	Local	nBasePrt :=0, nComPrt:=0
	Local aStru    := SE3->(dbStruct()), ni

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para Impressao do Cabecalho e Rodape    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cbtxt    := Space(10)
	cbcont   := 00
	li       := 80
	m_pag    := 01
	imprime  := .T.

	nTipo := IIF(aReturn[4]==1,15,18)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Definicao dos cabecalhos                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If mv_par01 == 1
		titulo := "RELATORIO DE COMISSOES - (PGTO P/EMISSAO)"
	Elseif mv_par01 == 2
		titulo := "RELATORIO DE COMISSOES - (PGTO P/BAIXA)"
	Else
		titulo := "RELATORIO DE COMISSOES"
	Endif

	If MV_PAR13 == 1
		//If _Modelo == 1
		cabec1:="Prf Numero    Data     Cliente                        Vlr.Base    %    Vr.Comis."
	Else                      
		cabec1:="              Data     Cliente                        Vlr.Base    %    Vr.Comis."
	EndIf
	cabec2:=""

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta condicao para filtro do arquivo de trabalho            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	DbSelectArea("SE3")	// Posiciona no arquivo de comissoes
	DbSetOrder(2)			// Por Vendedor
	cFilialSE3 := xFilial("SE3")
	cNomArq :=CriaTrab("",.F.)

	cCondicao := "SE3->E3_FILIAL=='" + cFilialSE3 + "'"
	cCondicao += ".And.SE3->E3_VEND>='" + mv_par04 + "'"
	cCondicao += ".And.SE3->E3_VEND<='" + mv_par05 + "'"
	cCondicao += ".And.DtoS(SE3->E3_EMISSAO)>='" + DtoS(mv_par02) + "'"
	cCondicao += ".And.DtoS(SE3->E3_EMISSAO)<='" + DtoS(mv_par03) + "'"

	If mv_par01 == 1
		cCondicao += ".And.SE3->E3_BAIEMI!='B'"  // Baseado pela emissao da NF
	Elseif mv_par01 == 2
		cCondicao += " .And.SE3->E3_BAIEMI=='B'"  // Baseado pela baixa do titulo
	Endif

	If mv_par06 == 1 		// Comissoes a pagar
		cCondicao += ".And.Dtos(SE3->E3_DATA)=='"+Dtos(Ctod(""))+"'"
	ElseIf mv_par06 == 2 // Comissoes pagas
		cCondicao += ".And.Dtos(SE3->E3_DATA)!='"+Dtos(Ctod(""))+"'"
	Endif

	If mv_par09 == 2 		// Nao Inclui Comissoes Zeradas
		cCondicao += ".And.SE3->E3_COMIS<>0"
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria expressao de filtro do usuario                          Ё
	//юддддддддддддд
	ддддддддддддддддддддддддддддддддддддддддддддддддды
	If ( ! Empty(aReturn[7]) )
		cFiltroUsu := &("{ || " + aReturn[7] +  " }")
	Else
		cFiltroUsu := { || .t. }
	Endif

	nAg1 := nAg2 := 0

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo de trabalho                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//cChave := IndexKey()
	DbSelectArea("SE3")
	nIndex := RetIndex("SE3")
	cChave := "E3_FILIAL+E3_VEND+E3_ROMAN+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ"
	cNomArq :=CriaTrab("",.F.)
	IndRegua("SE3",cNomArq,cChave,,cCondicao, "Selecionando Registros...") //
	#IFNDEF TOP
	DbSetIndex(cNomArq+OrdBagExT())
	#EndIf
	DbSetOrder(nIndex+1)

	SetRegua(RecCount())		// Total de Elementos da regua
	DbGotop()
	Do While !Eof()
		IF lEnd
			@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"  //
			lContinua := .F.
			Exit
		EndIF
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Processa condicao do filtro do usuario                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If ! Eval(cFiltroUsu)
			Dbskip()
			Loop
		Endif

		nAc1   := nAc2 := nAc3 := 0
		lFirstV:= .T.
		cVend  := SE3->E3_VEND

		Do While !Eof() .AND. SE3->E3_VEND == cVend
			If ! Eval(cFiltroUsu)
				IncRegua()
				Dbskip()
				Loop
			Endif
			_Roman := .F.
			_Reg := SE3->(Recno())
			_Loop := SE3->(E3_FILIAL+E3_VEND+E3_ROMAN)
			Do While SE3->(E3_FILIAL+E3_VEND+E3_ROMAN) == _Loop  .And. SE3->(!Eof())
				If ! Eval(cFiltroUsu)
					Dbskip()
					Loop
				Endif
				If !Empty(SE3->E3_ROMAN) .And. !SE3->E3_PREFIXO $ "UNI/1  "
					_Roman := .T.
					Exit
				EndIf
				SE3->(DbSkip())
			EndDo

			SE3->(DbGoTo(_Reg))
			If _Roman
				_cNUMROM   := SE3->E3_ROMAN
				_cVend     := SE3->E3_VEND
				_cCodCli   := SE3->E3_CODCLI
				_cLoja     := SE3->E3_LOJA
				_dEmissao  := SE3->E3_EMISSAO
				dBaixa     := SE3->E3_EMISSAO
				nVlrTitulo := 0.00
				nBasePrt   := 0.00
				nComPrt    := 0.00
				_E3_DATA   := SE3->E3_EMISSAO //DATA
				_E3_PEDIDO := SE3->E3_PEDIDO
				_E3_BAIEMI := SE3->E3_BAIEMI

				Do While SE3->(E3_FILIAL+E3_VEND+E3_ROMAN) == _Loop  .And. SE3->(!Eof())
					IncRegua()
					If ! Eval(cFiltroUsu)
						Dbskip()
						Loop
					Endif

					dbSelectArea("SE1")
					dbSetOrder(1)
					If dbSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO)
						nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
					Else
						dbSelectArea("SF2")
						dbSetorder(1)
						If dbSeek(xFilial()+SE3->E3_NUM+SE3->E3_PREFIXO)
							If ( cPaisLoc=="BRA" )
								nVlrTitulo += Round(xMoeda(F2_VALMERC+F2_VALIPI+F2_FRETE+F2_SEGURO,1,mv_par08,SF2->F2_EMISSAO,nDecs+1),nDecs)
							Else
								nVlrTitulo += Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
							Endif
						Else
							dbSelectArea("SE1")
							dbSetOrder(1)
							cFilialSE1 := xFilial("SE1")
							dbSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM)
							While ( !Eof() .And. SE3->E3_PREFIXO == SE1->E1_PREFIXO .And.;
							SE3->E3_NUM == SE1->E1_NUM .And.;
							SE3->E3_FILIAL == cFilialSE1 )
								If ( SE1->E1_TIPO == SE3->E3_TIPO  .And. ;
								SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
								SE1->E1_LOJA == SE3->E3_LOJA )
									nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
								EndIf
								dbSelectArea("SE1")
								dbSkip()
							EndDo
						EndIf
					EndIf
					nBasePrt +=  SE3->E3_BASE
					nComPrt  +=  SE3->E3_COMIS
					SE3->(DbSkip())
				EndDo


				If li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIF

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Seleciona o Codigo do Vendedor e Imprime o seu Nome          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				IF lFirstV
					dbSelectArea("SA3")
					dbSeek(xFilial("SA3")+_cVend,.F.)
					@li++, 00 PSAY "Vendedor : " + _cVend + " " + SA3->A3_NOME 
					@li  , 18 PSAY "Fone: " + SA3->A3_DDDTEL + "-" + SA3->A3_TEL + "     Fax: " + SA3->A3_DDDTEL +  SA3->A3_FAX//
					li+=2
					dbSelectArea("SE3")
					lFirstV := .F.
				EndIF

				If MV_PAR13 == 1
					//			If _Modelo == 1
					@li, 00 PSAY "ROM"
					@li, 04 PSAY M->_cNUMROM
				EndIf
				@li, 11 PSAY _E3_DATA


				dbSelectArea("SA1")
				dbSeek(xFilial("SA1")+_cCODCLI+_cLOJA,.F.)
				@li, 22 PSAY Substr(SA1->A1_NOME,1,30)

				dbSelectArea("SE3")
				@ li,51 PSAY nBasePrt 			Picture "@E 99999,999.99"
				@ li,64 PSAY (nComPrt / nBasePrt) * 100 Picture "@E 99.99"
				@ li,70 PSAY nComPrt			Picture "@E 999,999.99"

				nAc1 += nBasePrt
				nAc2 += nComPrt
				nAc3 += nVlrTitulo
				li++
			Else
				IncRegua()

				If li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				EndIF

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Seleciona o Codigo do Vendedor e Imprime o seu Nome          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				IF lFirstV
					dbSelectArea("SA3")
					dbSeek(xFilial()+SE3->E3_VEND)
					//				@li, 00 PSAY "Vendedor" + SE3->E3_VEND + " " + A3_NOME //"Vendedor : "
					//		@li, 00 PSAY "Vendedor : " + _cVend + " " + SA3->A3_NOME + " Fone: " + SA3->A3_TEL + "     Fax: " + SA3->A3_FAX//
					@li++, 00 PSAY "Vendedor : " + SE3->E3_VEND + " " + SA3->A3_NOME 
					@li  , 18 PSAY "Fone: " + SA3->A3_DDDTEL + "-" + SA3->A3_TEL + "     Fax: " + SA3->A3_DDDTEL +  SA3->A3_FAX//
					li+=2
					dbSelectArea("SE3")
					lFirstV := .F.
				EndIF

				If MV_PAR13 == 1
					//			If _Modelo == 1
					@li, 00 PSAY SE3->E3_PREFIXO
					@li, 04 PSAY SE3->E3_NUM
				EndIf
				@li, 14 PSAY SE3->E3_EMISSAO

				dbSelectArea("SA1")
				dbSeek(xFilial()+SE3->E3_CODCLI+SE3->E3_LOJA)
				@li, 23 PSAY Substr(A1_NOME,1,29)

				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek(xFilial()+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA+SE3->E3_TIPO)
				nVlrTitulo := Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
				dVencto    := SE1->E1_VENCTO

				/*
				Nas comissoes geradas por baixa pego a data da emissao da comissao que eh igual a data da baixa do titulo.
				Isto somente dara diferenca nas baixas parciais
				*/

				If SE3->E3_BAIEMI == "B"
					dBaixa     := SE3->E3_EMISSAO
				Else
					dBaixa     := SE1->E1_BAIXA
				Endif

				If Eof()
					dbSelectArea("SF2")
					dbSetorder(1)
					dbSeek(xFilial()+SE3->E3_NUM+SE3->E3_PREFIXO)
					If ( cPaisLoc=="BRA" )
						nVlrTitulo := Round(xMoeda(F2_VALMERC+F2_VALIPI+F2_FRETE+F2_SEGURO,1,mv_par08,SF2->F2_EMISSAO,nDecs+1),nDecs)
					Else
						nVlrTitulo := Round(xMoeda(F2_VALFAT,SF2->F2_MOEDA,mv_par08,SF2->F2_EMISSAO,nDecs+1,SF2->F2_TXMOEDA),nDecs)
					Endif

					dVencto    := " "
					dBaixa     := " "

					If Eof()
						nVlrTitulo := 0
						dbSelectArea("SE1")
						dbSetOrder(1)
						cFilialSE1 := xFilial("SE1")
						dbSeek(cFilialSE1+SE3->E3_PREFIXO+SE3->E3_NUM)
						While ( !Eof() .And. SE3->E3_PREFIXO == SE1->E1_PREFIXO .And.;
						SE3->E3_NUM == SE1->E1_NUM .And.;
						SE3->E3_FILIAL == cFilialSE1 )
							If ( SE1->E1_TIPO == SE3->E3_TIPO  .And. ;
							SE1->E1_CLIENTE == SE3->E3_CODCLI .And. ;
							SE1->E1_LOJA == SE3->E3_LOJA )
								nVlrTitulo += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
								dVencto    := " "
								dBaixa     := " "
							EndIf
							dbSelectArea("SE1")
							dbSkip()
						EndDo
					EndIf
				Endif

				//Preciso destes valores para pasar como parametro na funcao TM(), e como
				//usando a xmoeda direto na impressao afetaria a performance (deveria executar
				//duas vezes, uma para imprimir e outra para pasar para a picture), elas devem]
				//ser inicializadas aqui. Bruno.

				nBasePrt	:=	Round(xMoeda(SE3->E3_BASE ,1,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)
				nComPrt	:=	Round(xMoeda(SE3->E3_COMIS,1,MV_PAR08,SE1->E1_EMISSAO,nDecs+1),nDecs)

				dbSelectArea("SE3")
				@ li,51 PSAY nBasePrt 			Picture "@E 99999,999.99"
				@ li,64 PSAY SE3->E3_PORC		Picture "@E 99.99"
				@ li,70 PSAY nComPrt			Picture "@E 999,999.99"

				nAc1 += nBasePrt
				nAc2 += nComPrt
				nAc3 += nVlrTitulo
				li++
				dbSkip()
			EndIf
		EndDo

		If (nAc1+nAc2+nAc3) != 0
			li++

			If li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			EndIF

			@ li, 00  PSAY "TOTAL DO VENDEDOR --> "
			@ li, 51  PSAY nAc1 	PicTure "@E 99999,999.99"

			//		If nAc1 != 0
			//			@ li, 64 PSAY (nAc2/nAc1)*100   PicTure "@E 99.99"
			//		Endif

			@ li, 70  PSAY nAc2 PicTure "@E 999,999.99"
			li++

			@ li++, 00  PSAY __PrtThinLine()
			li := If(MV_PAR11==1,60,li)

		EndIF

		dbSelectArea("SE3")
		nAg1 += nAc1
		nAg2 += nAc2
		nAg3 += nAc3
	EndDo

	IF (nAg1+nAg2+nAg3) != 0
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@li,  00 PSAY "TOTAL  GERAL      --> "
		@li,  51 PSAY nAg1	Picture "@E 99999,999.99"
		//	@li,  64 PSAY (nAg2/nAg1)*100	Picture "@E 99.99"
		@li,  70 PSAY nAg2 Picture "@E 999,999.99"

		roda(cbcont,cbtxt,"G")
	EndIF

	fErase(cNomArq+OrdBagExt())

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Restaura a integridade dos dados                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DbSelectArea("SE3")
	RetIndex("SE3")
	DbSetOrder(2)
	Set Filter To

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se em disco, desvia para Spool                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()
Return()