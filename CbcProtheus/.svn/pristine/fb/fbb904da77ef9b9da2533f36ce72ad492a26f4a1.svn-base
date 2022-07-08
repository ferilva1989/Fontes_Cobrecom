#include "TOPCONN.ch"
#INCLUDE "rwmake.ch"
static cDrive := if(U_zIs12(),'CTREECDX','')

/*/{Protheus.doc} CdEstR09
//TODO Relatório de Entregas/Faltas.
@author Roberto
@since 21/07/2017
@version 1.0

@type function
/*/
User Function CdEstR09()
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatorio de Entregas/Faltas"
	Local imprime      := .T.
	Local aOrd := {}
	
	Private titulo       := "Relatório de Entregas/Faltas"
	Private Cabec1       := ""//"Codigo          Descricao                      Quant.     Quant.     Saldo       Quant.      Quant.      Acond/  Semana   Saldo a"
	Private Cabec2       := ""//"Produto                                        Ped.Venda  Entregue   A Entregar  Separada    Faltante    Lance   Produc.  Produzir"
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDESTR09"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDES09"
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR09"
	
	Private cString := "SC6"
	
	dbSelectArea("SC6")
	dbSetOrder(3)
	
	u_VldR09() // é Uma ValidPerg para os fontes CDESTR09 e CDESTR09A
	pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := Iif(aReturn[4]==1,15,18)

	titulo := "Relat.de Entr./Faltas de " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
	If MV_PAR13 == 1
		titulo := titulo + " - (Somente Faltas)"
	EndIf
	
	_cCentury := Upper(Set(_SET_DATEFORMAT))
	Set Century off
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	If "YYYY" $ _cCentury
		Set Century on
	EndIf
Return(.T.)


/*/{Protheus.doc} RunReport
//TODO Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS 
		monta a janela com a regua de processamento.
@author Roberto
@since 21/07/2017
@version 1.0
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	local aWSheet := {}, aTable := {}
	
	// Se for imprimir por rota, criar arquivo temporario
	If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
		_cNomArq := ""                               // Arquivo Temporario
		_aCampos := {}
		
		aAdd(_aCampos, {"C6_NUM"    , "C", TamSX3("C6_NUM")[1], 0})
		aAdd(_aCampos, {"C6_ITEM"   , "C", TamSX3("C6_ITEM")[1], 0})
		aAdd(_aCampos, {"C6_PRODUTO", "C", TamSX3("C6_PRODUTO")[1], 0})
		aAdd(_aCampos, {"C6_DESCRI" , "C", 32, 0})
		aAdd(_aCampos, {"C6_QTDVEN" , "N", 09, 0})
		aAdd(_aCampos, {"C6_QTDENT" , "N", 09, 0})
		aAdd(_aCampos, {"C6_VLRTOT" , "N", 09, 0})
		aAdd(_aCampos, {"QTDSC9"    , "N", 09, 0})
		aAdd(_aCampos, {"C6_ACOND"  , "C", 06, 0})
		aAdd(_aCampos, {"NPESO"     , "N", 07, 0})
		aAdd(_aCampos, {"NSLDEST"   , "N", 09, 0})
		aAdd(_aCampos, {"NQTDSC2"   , "N", 09, 0})
		aAdd(_aCampos, {"C6_DTEPA2" , "C", 08, 0})
		aAdd(_aCampos, {"ROTA"      , "C", 03, 0})
		aAdd(_aCampos, {"NOME"      , "C", 30, 0})
		aAdd(_aCampos, {"NEGOC"     , "C", 10, 0})
		aAdd(_aCampos, {"ENTREG"    , "D", 08, 0})
		If Select("TRB") > 0
			DbSelectArea("TRB")
			DbCloseArea()
		EndIf
		
		if U_zIs12()
			_cNomArq := AllTrim(CriaTrab(,.F.))
			FWDBCreate( _cNomArq , _aCampos , "CTREECDX")
		else
			_cNomArq := CriaTrab(_aCampos, .T.)
		endif
		DbUseArea(.T.,cDrive, _cNomArq, "TRB", .T., .F.)
		
		Private _cInd := CriaTrab(Nil, .F.)
		IndRegua("TRB", _cInd, "ROTA+NOME+C6_NUM+C6_ITEM",,, "Selecionando Registros...")
		DbSetIndex(_cInd + OrdBagExt())
		EndIf
		
		DbSelectArea("SC2")
		DBOrderNickName("SC2SEMANA")
		//DbSetOrder(9) // C2_FILIAL+C2_SEMANA+C2_PRODUTO
		
		dbSelectArea("SC5")
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		
		dbSelectArea("SA1")
		dbSetOrder(1) //A1_FILIAL+A1_COD
		
		dbSelectArea("SA3")
		dbSetOrder(1) //A3_FILIAL+A3_COD
		
		dbSelectArea("SF4")
		dbSetOrder(1) //F4_FILIAL+F4_CODIGO
		
		dbSelectArea("SB1")
		dbSetOrder(1) //B1_FILIAL+B1_COD
		
		dbSelectArea("SB2")
		dbSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL
		
		dbSelectArea("SBF")
		dbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		
		dbSelectArea("SDC")
		DBOrderNickName("SDCPED") // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
		// dbSetOrder(4) //DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
		
		dbSelectArea("SC9")
		dbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		
		#IFDEF TOP
			cQUER := " FROM "+RetSqlName("SC6")+" C6,"+RetSqlName("SC5")+" C5, "+RetSqlName("SF4")+" F4,"+RetSqlName("SA1")+" A1"
			
			cQUER += " WHERE C6.C6_NUM  	 		>= '" + MV_PAR01 + "'"
			cQUER += " AND C6.C6_NUM     			<= '" + MV_PAR02 + "'"
			cQUER += " AND C6.C6_ENTREG  			>= '" + DToS(MV_PAR03) + "'"
			cQUER += " AND C6.C6_ENTREG  			<= '" + DToS(MV_PAR04) + "'"
			cQUER += " AND C6.C6_CLI+C6.C6_LOJA 	>= '" + MV_PAR05 + MV_PAR06 + "'"
			cQUER += " AND C6.C6_CLI+C6.C6_LOJA 	<= '" + MV_PAR07 + MV_PAR08 + "'"
			cQUER += " AND C6.C6_QTDVEN 			> C6.C6_QTDENT"
			cQUER += " AND C6.C6_BLQ					<> 'R '"
			If MV_PAR18 == 2
				cQUER += " AND C6.C6_LOCAL				= '01'"
			EndIf
			cQUER += " AND C6.C6_FILIAL				= '" + xFilial("SC6") + "'"
			cQUER += " AND C5.C5_FILIAL+C5.C5_NUM	= C6.C6_FILIAL+C6.C6_NUM"
			cQUER += " AND C5.C5_EMISSAO 			>= '" + DToS(MV_PAR14) + "'"
			cQUER += " AND C5.C5_EMISSAO 			<= '" + DToS(MV_PAR15) + "'"
			cQUER += " AND C5.C5_VEND1 				>='" + MV_PAR09 + "'"
			cQUER += " AND C5.C5_VEND1 				<='" + MV_PAR10 + "'"
			cQUER += " AND F4.F4_CODIGO 			= C6.C6_TES"
			cQUER += " AND F4.F4_FILIAL 			= '" + xFilial("SF4") + "'"
			cQUER += " AND F4.F4_ESTOQUE 			= 'S'"
			cQUER += " AND A1.A1_COD+A1.A1_LOJA 	= C6.C6_CLI+C6.C6_LOJA"
			cQUER += " AND A1.A1_FILIAL 			= '" + xFilial("SA1") + "'"
			
			If MV_PAR11==1
				cQUER += " AND A1.A1_EST = 'SP'"
			ElseIf MV_PAR11==2
				cQUER += " AND A1.A1_EST <> 'SP'"
			EndIf
			cQUER += " AND C5.D_E_L_E_T_ <> '*'"
			cQUER += " AND C6.D_E_L_E_T_ <> '*'"
			cQUER += " AND F4.D_E_L_E_T_ <> '*'"
			cQUER += " AND A1.D_E_L_E_T_ <> '*'"
			
			cQUERY := "SELECT Count(C6.C6_NUM) as QtdReg " + cQUER
			TCQUERY cQuery NEW ALIAS "RSC6"
			dbSelectArea("RSC6")
			dbGoTop()
			_Total := RSC6->QtdReg
			DbCloseArea("RSC6")
			
			cQUERY := "SELECT C6.*" + cQUER + " ORDER BY C6.C6_ENTREG,C6.C6_NUM,C6.C6_ITEM"
			TCQUERY cQuery NEW ALIAS "RSC6"
			          
			If MV_PAR19 > 0
				_cPeds := ""
				cQUERY := "SELECT C6_FILIAL, C6_NUM, SUM(((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN)) TOTAL" + cQUER + " GROUP BY C6_FILIAL, C6_NUM ORDER BY C6_FILIAL, C6_NUM"
				_aDadRel:= u_QryArr(cQUERY) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
				For _nPds := 1 To Len(_aDadRel)
					If _aDadRel[_nPds,3] >= MV_PAR19
						_cPeds += _aDadRel[_nPds,1] + _aDadRel[_nPds,2] + "//"
					EndIf
				Next
			EndIf
			SetRegua(_Total)
			_cAliasC6 := "RSC6"
			dbSelectArea("RSC6")
			dbGoTop()
			Do While RSC6->(!Eof())
			
				If MV_PAR19 > 0
					If !(RSC6->C6_FILIAL + RSC6->C6_NUM) $ _cPeds
						RSC6->(DbSkip())
						Loop
					EndIf
				EndIf
		#ELSE
			_cAliasC6 := "SC6"
			dbSelectArea("SC6")
			dbSetOrder(3)  // C6_FILIAL+ DTOS(C6_ENTREG)+C6_NUM+C6_ITEM
			SetRegua(RecCount())
			DbSeek(xFilial("SC6")+Dtos(MV_PAR03),.T.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_ENTREG <= MV_PAR04 .And. SC6->(!Eof())
		#ENDIF
		If (_cAliasC6)->C6_NUM == "010593"
			nddd:=1
		EndIf
		
		If lAbortPrint
			Exit
		Endif
		_lTem := .F.
		If (_cAliasC6)->C6_NUM >= MV_PAR01 .And. (_cAliasC6)->C6_NUM <= MV_PAR02 .And. ;
			(_cAliasC6)->C6_CLI+(_cAliasC6)->C6_LOJA >= MV_PAR05+MV_PAR06 .And. ;
			(_cAliasC6)->C6_CLI+(_cAliasC6)->C6_LOJA <= MV_PAR07+MV_PAR08 .And. ;
			(_cAliasC6)->C6_QTDENT < (_cAliasC6)->C6_QTDVEN .And. (_cAliasC6)->C6_BLQ # "R " .And.;
			Iif(MV_PAR18 == 2,(_cAliasC6)->C6_LOCAL == '01',(_cAliasC6)->C6_LOCAL <= '99')
			
			SC5->(DbSeek(xFilial("SC5")+(_cAliasC6)->C6_NUM,.F.))
			SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		
			SDC->(DbSeek(xFilial("SDC")+(_cAliasC6)->C6_NUM,.F.))
			Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == (_cAliasC6)->C6_NUM .And.;
				SDC->DC_ORIGEM # "SC6" .And. SDC->(!Eof())
				SDC->(DbSkip())
			EndDo
		
			_lTemSDC := (SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == (_cAliasC6)->C6_NUM .And.;
			SDC->DC_ORIGEM == "SC6" .And. SDC->(!Eof()))
		
			If SC5->C5_EMISSAO >= MV_PAR14 .And. SC5->C5_EMISSAO <= MV_PAR15 .And. (dDataBase-SC5->C5_EMISSAO) >= MV_PAR17 .And.;
				SC5->C5_VEND1 >=  MV_PAR09 .And. SC5->C5_VEND1 <= MV_PAR10 .And. ;
				((MV_PAR11==1 .And. SA1->A1_EST == "SP") .Or. (MV_PAR11==2 .And. SA1->A1_EST # "SP") .Or. (MV_PAR11==3)) .And. ;
				((MV_PAR12==1 .And. _lTemSDC) .Or. (MV_PAR12==2))
		
				_lTem := .T.
			EndIf
		
			SC9->(DbSeek(xFilial("SC9")+(_cAliasC6)->C6_NUM+(_cAliasC6)->C6_ITEM,.F.))
			Do While SC9->C9_FILIAL ==xFilial("SC9") .And. SC9->C9_PEDIDO == (_cAliasC6)->C6_NUM .And. SC9->(!Eof()) .And. _lTem
				//			If SC9->C9_BLCRED == "09" // Rejeitado
				If SC9->C9_BLCRED $ "09/01" // Rejeitado ou bloqueado por credito -> Solicitado Denise 26/05/11
					_lTem := .F.
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf
			
		If _lTem
			SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
			SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
			
			_lFirst := .T.
			_cNumPed:= (_cAliasC6)->C6_NUM
			_nTotPeso := 0.00
			_nTotVlr1 := 0.00
			_nTotVlr2 := 0.00
			_lBlqCre  := .F.
			#IFDEF TOP
			Do While (_cAliasC6)->C6_NUM == _cNumPed .And. (_cAliasC6)->(!Eof())
			#ELSE
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _cNumPed .And. SC6->(!Eof())
			#ENDIF
				If lAbortPrint
					@	nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
					Exit
				Endif
				IncRegua()
		
				SF4->(DbSeek(xFilial("SF4")+(_cAliasC6)->C6_TES,.F.))
		
				If (_cAliasC6)->C6_QTDENT < (_cAliasC6)->C6_QTDVEN .And. (_cAliasC6)->C6_BLQ # "R " .And. SF4->F4_ESTOQUE == "S"
		
					dbSelectArea("SC9")
					dbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					
					SC9->(DbSeek(xFilial("SC9")+(_cAliasC6)->C6_NUM+(_cAliasC6)->C6_ITEM,.F.))
					_nQtdSC9 := 0.00 // Quantidade Liberada no estoque
					Do While SC9->C9_FILIAL ==xFilial("SC9") .And. SC9->C9_PEDIDO == (_cAliasC6)->C6_NUM .And. SC9->C9_ITEM == (_cAliasC6)->C6_ITEM .And. SC9->(!Eof())
					
						If Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
							_nQtdSC9 += SC9->C9_QTDLIB
						EndIf
					
						If !_lBlqCre .And. SC9->C9_BLCRED == "01" // Pedido Bloqueado no Crédito
							_lBlqCre := .T.
						EndIf
						SC9->(DbSkip())
					EndDo
					
					If MV_PAR13 == 2 .Or. (MV_PAR13 == 1 .And. ((_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT-_nQtdSC9 > 0))
					
						If MV_PAR16 # 2 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
							If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 6
								nLin := MyCab(nLin,_lFirst)
								_lFirst := .F.
							Endif
							If _lFirst
								@ nLin,000 PSAY Replicate("-",limite)
								nLin++
								nLin := MyCab(nLin,_lFirst)
								_lFirst := .F.
							EndIf
				 		EndIf
		
						_nQtdSC2 := 0.00
						
						//MADEIRA 25/10/2017 - ( Obter Saldo do Produto Semiacabado no 99 )						
						_nQtdSC2 := U_cbrSaldoProcSB2((_cAliasC6)->C6_PRODUTO)
						
						//DESATIVADO 25/10/2017 - Solicitado Natanael - ( Obtinha Saldo da OP )
						//If SC2->(DbSeek(xFilial("SC2")+(_cAliasC6)->C6_SEMANA+(_cAliasC6)->C6_PRODUTO,.F.))
							//_nQtdSC2 += Iif(Empty(SC2->C2_DATRF).And.(SC2->C2_QUJE<SC2->C2_QUANT).And.SC2->C2_QUJE >= 0,(SC2->C2_QUANT-SC2->C2_QUJE),0)
						//EndIf
						//Fim MADEIRA
						
						SB1->(DbSeek(xFilial("SB1")+(_cAliasC6)->C6_PRODUTO,.F.))
						_nPeso := Int(((_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT)* SB1->B1_PESO)
						_nTotPeso += _nPeso
						_nTotVlr1 += ((_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT) * (_cAliasC6)->C6_PRCVEN
						_nTotVlr2 += _nQtdSC9 * (_cAliasC6)->C6_PRCVEN
						
						If SB1->B1_LOCALIZ == "S"
							_cLocaliz := Left((_cAliasC6)->C6_ACONDIC+StrZero((_cAliasC6)->C6_METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
							_nSldEst := Posicione("SBF",1,xFilial("SBF")+(_cAliasC6)->C6_LOCAL+_cLocaliz+(_cAliasC6)->C6_PRODUTO,"BF_QUANT-BF_EMPENHO")
							// 1-BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
						Else
							_nSldEst := Posicione("SB2",1,xFilial("SB2")+(_cAliasC6)->C6_PRODUTO+(_cAliasC6)->C6_LOCAL,"B2_QATU-B2_QEMP")
							// 1-B2_FILIAL+B2_COD+B2_LOCAL
						EndIf
			
						// By Roberto 09/01/15
						// Até que entre no ar o PreActor, será impresso o C5_DTEPA2
						// No SC5 e SC¨existem os campos C?_DTEPA E C?_DTEPA2. Esses campos recebem a data prevista
						// para entrega do material no EPA e o C?_DTEPA somente será atualizado se estiver vazio e
						// o C?_DTEPA2 será atualizado sempre.
						// No início, para não confundir, será impresso C5_DTEPA2 e depois que tivermos a informação
						// correta por item o C6_DTEPA2.
						//
						// Alterar também CDESTR14 e CDESTR20
						
						_cDtEPA := DtoC(SC5->C5_DTEPA2)
						If Len(_cDtEPA)>8
							_cDtEPA := Left(_cDtEPA,6) + Right(_cDtEPA,2)
						EndIf
						
						_cDescri := Left(u_CortaDesc((_cAliasC6)->C6_DESCRI),32)
						
						If MV_PAR16 # 2 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
							@ nLin,000 PSAY Left((_cAliasC6)->C6_ITEM,2)
							@ nLin,003 PSAY (_cAliasC6)->C6_PRODUTO Picture "@R 999.99.99.9.99"
							@ nLin,018 PSAY _cDescri
							@ nLin,051 PSAY (_cAliasC6)->C6_QTDVEN                         PICTURE "@E 999,999"
							@ nLin,060 PSAY (_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT          PICTURE "@E 999,999"
							@ nLin,069 PSAY _nQtdSC9                               PICTURE "@E 999,999"
							@ nLin,078 PSAY (_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT-_nQtdSC9 PICTURE "@E 999,999"
							@ nLin,087 PSAY (_cAliasC6)->C6_ACONDIC+StrZero((_cAliasC6)->C6_METRAGE,5)
							@ nLin,094 PSAY _nPeso                                 PICTURE "@EZ 9,999,999"
							@ nLin,104 PSAY _nSldEst                               PICTURE Iif(_nSldEst>9999999,"@EZ 99999,999","@EZ 9,999,999")
							@ nLin,114 PSAY _nQtdSC2                               PICTURE Iif(_nQtdSC2>9999999,"@EZ 99999,999","@EZ 9,999,999")
							// By Roberto Oliveira 18/05/17 - Natanael solicitou imprimir C6_SEMANA 
							//If AllTrim((_cAliasC6)->C6_SEMANA) $ "RESERVA/MATRIZ" .Or. Left((_cAliasC6)->C6_SEMANA,3) == "DRC"
								@ nLin,124 PSAY AllTrim((_cAliasC6)->C6_SEMANA)
							//Else
							//	@ nLin,124 PSAY _cDtEPA
							//EndIf
							// Fim By Roberto Oliveira 18/05/17 - Natanael solicitou imprimir C6_SEMANA 
							nLin := nLin + 1 // Avanca a linha de impressao
						EndIf
						
						If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
							RecLock("TRB",.T.)
							TRB->C6_NUM		:= (_cAliasC6)->C6_NUM
							TRB->C6_ITEM	:= (_cAliasC6)->C6_ITEM
							TRB->C6_PRODUTO := (_cAliasC6)->C6_PRODUTO
							TRB->C6_DESCRI  := _cDescri
							TRB->C6_QTDVEN  := (_cAliasC6)->C6_QTDVEN
							TRB->C6_QTDENT  := (_cAliasC6)->C6_QTDENT
							TRB->QTDSC9     := _nQtdSC9
							TRB->C6_ACOND   := (_cAliasC6)->C6_ACONDIC+StrZero((_cAliasC6)->C6_METRAGE,5)
							TRB->NPESO      := _nPeso
							TRB->NSLDEST    := Int(_nSldEst)
							TRB->NQTDSC2    := _nQtdSC2
							TRB->C6_DTEPA2  := _cDtEPA
							TRB->C6_VLRTOT	:= (TRB->C6_QTDVEN-TRB->C6_QTDENT)*RSC6->C6_PRCVEN
							TRB->ROTA       := Iif(Empty(Iif(FWCodFil() == "01",SA1->A1_ROTA,SA1->A1_ROTA3L)),"999",Iif(FWCodFil() == "01",SA1->A1_ROTA,SA1->A1_ROTA3L))
							TRB->NOME       := SA1->A1_NOME
							//TRB->NEGOC      := Iif(SC5->C5_DIASNEG>0.And.!Empty(SC5->C5_DTENTR),"Negoc."," ")
							TRB->NEGOC      := Iif(!Empty(SC5->C5_DTENTR),"Negoc."," ")
							TRB->ENTREG     := SC5->C5_ENTREG
							MsUnLock()
						EndIf
					EndIf
				EndIf
				DbSelectArea(_cAliasC6)
				(_cAliasC6)->(DbSkip())
			EndDo
			If MV_PAR16 == 1 .Or. MV_PAR16 == 3 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
				If _nTotPeso > 0 .Or. _nTotVlr1 > 0 .Or. _nTotVlr2 > 0
					@ nLin,025 PSAY "Saldo P.V. R$"
					@ nLin,039 PSAY _nTotVlr1 Picture "@E 9,999,999.99"
					@ nLin,052 PSAY "Total Emp.R$"
					@ nLin,065 PSAY _nTotVlr2 Picture "@E 9,999,999.99"
					@ nLin,078 PSAY "Peso Total ->"
					@ nLin,094 PSAY _nTotPeso                                 PICTURE "@EZ 9,999,999"
					nLin := nLin + 1 // Avanca a linha de impressao
					nLin := PrintLog(_cNumPed,nLin)
					DbSelectArea(_cAliasC6)
				EndIf
			EndIf
		Else
			IncRegua()
			DbSelectArea(_cAliasC6)
			(_cAliasC6)->(DbSkip())
		EndIf
	EndDo
	
	#IFDEF TOP
		dbSelectArea("RSC6")
		DbCloseArea("RSC6")
	#ENDIF
	
	If MV_PAR16 > 1
		_cAliasC6 := "SC6"
		u_ImpRota()
	EndIf
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	
	If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
		If MsgBox("Abre Arquivo no Excel?","Abrir ?","YesNo")
			If !ApOleClient("MsExcel")
				MsgBox("Microsoft Excel Não Instalado nesta Máquina !!!", "Atenção !!!", "INFO")
			Else
				DbSelectArea("TRB")
				TRB->(DbGoTop())
				aTrbArea := TRB->(GetArea())
				aColuna := u_RetTRBCol(aTrbArea)
				aDados 	:= u_RetTRBReg(aTrbArea)
				u_cntPedNF(@aColuna, @aDados, .T.)
				aadd(aWSheet,{"Rel.EntrFaltas"})
				aadd(aTable,{"Rel.EntrFaltas"})
				u_TExcArr(aDados,aColuna,aWSheet,aTable)
			EndIf
		EndIf
	EndIf
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
Return(.T.)


/*/{Protheus.doc} MyCab
//TODO Descrição auto-gerada.
@author Roberto
@since 21/07/2017
@version 1.0
@param nLin, numeric, descricao
@param _lFirst, , descricao
@type function
/*/
Static Function MyCab(nLin,_lFirst)
	local lEmpFatPar := .F.
	Local cIdTrans	:= ''
	local oMultFil	:= ctrlMultiPedidos():newctrlMultiPedidos()
	
	/*Processo de Industrialização
	Juliana Leme - 16/09/2015
	*/
	aDados		:= {{"","","","","","","","","","","","","","","","","","","",""}}
	//1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20
	aDados		:= u_InfTrian(xFilial("SC5"),(_cAliasC6)->C6_NUM,"CDESTR09")
	If Len(aDados) = 0
		aDados		:= {{"","","","","","","","","","","","","","","","","","","",""}}
		// 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20
	EndIf

	cIdTrans := (_cAliasC6)->C6_ZZPVORI
	If oMultFil:setPedido(SC5->(RECNO())):isOk()
		cIdTrans := oMultFil:getIdVen()
	EndIf
	
	@ nLin,000 PSAY "Pedido: " + (_cAliasC6)->C6_NUM;
				   + " Semana.: " + Transform(SC5->C5_SEMANA,"@R XXXXXX-X") + "   Dt.Ent.: "
	@ nLin,044 PSAY Iif(Empty(aDados[1,12]),SC5->C5_ENTREG,Dtoc(Stod(aDados[1,12])))
	If !Empty(SC5->C5_DTENTR)
		@ nLin,052 PSAY "**"
	EndIf
	@ nLin,054 PSAY "Cliente: " + Iif(Empty(aDados[1,2]),SC5->C5_CLIENTE + "-" + SC5->C5_LOJACLI + " " + Left(SA1->A1_NOME,45),;
	aDados[1,17]  + "-" + aDados[1,18] + " " + Left(aDados[1,2],45)) + "(Ped."+ cIdTrans + ")"
	
	nLin  += 1
	_cRepres := AllTrim(SC5->C5_VEND1) + "-" + Substr(AllTrim(SA3->A3_NOME),1,25)
	_cObs := ""
	If _lBlqCre
		_cObs := "Bl.Cred"
	EndIf
	If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) 
		_cObs := _cObs + "Em Fat"
	EndIf
	@ nLin,000 PSAY _cObs
	@ nLin,015 PSAY "Repres.: " + Left(_cRepres,25) // Nao cabe mais que 32
	@ nLin,054 PSAY "Cidade : " + Iif(Empty(aDados[1,4]),AllTrim(Left(SA1->A1_MUN,30))+ " " +SA1->A1_EST,;
		Alltrim(Left(aDados[1,4],30))+ " " + aDados[1,5])
	@ nLin,100 PSAY "D.Fab.:"
	@ nLin,108 PSAY Date()-SC5->C5_EMISSAO Picture "999"
	@ nLin,113 PSAY "D.Crt.:"
	If Empty(SC5->C5_DTLICRE)
		@ nLin,121 PSAY 0 Picture "999"
	Else
		@ nLin,121 PSAY Date()-SC5->C5_DTLICRE Picture "999"
	EndIf
	
	nLin +=  1
	@ nLin,015 PSAY "Sit.Vendas.: " + If(SC5->C5_ZZBLVEN=="S","BLOQUEADO","NAO BLOQUEADO")
	
	If Len(aDados[1]) >= 30
		If !Empty(aDados[1,30])
			If aDados[1,30] < aDados[1,12] .And. Stod(aDados[1,30]) > Date()// Fat. a Partir de < Dt. Entrega
				@ nLin,080 PSAY "Pode Faturar a Partir de: " + Dtoc(Stod(aDados[1,30]))
			EndIf
		Else
			//If SC5->C5_DTFAT < SC5->C5_EMISSAO .And. SC5->C5_DTFAT < Date()
				@ nLin,080 PSAY "Pode Faturar a Partir de: " + Dtoc(SC5->C5_DTFAT)
			//EndIf
		EndIf
	Else
		//If SC5->C5_DTFAT < SC5->C5_EMISSAO  .And. SC5->C5_DTFAT < Date()
			@ nLin,080 PSAY "Pode Faturar a Partir de: " + Dtoc(SC5->C5_DTFAT)
		//EndIf
	EndIf
	
	lEmpFatPar := Alltrim(SC5->(C5_PARCIAL)) =='N' 
	if lEmpFatPar
		//nLin +=  1
		@ nLin,047 PSAY '[ACEITA FAT. PARCIAL?] ' + if(SC5->(C5_PARCIAL) == 'S','Sim','Não')
	endif
	
	If SC5->C5_CONDPAG =="000"
		nLin +=  1
		@ nLin,000 PSAY "Obs.: P.V.  BNDES"
	Else
		_xDscE4 := Upper(Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI"))
		If "VISTA" $ _xDscE4
			nLin +=  1
			@ nLin,000 PSAY "Obs.: " + _xDscE4
		EndIf
	Endif
	nLin += 2
	@ nLin,000 PSAY "It Codigo         Descricao                        Qtd.PV.  Sld.P.V  Qt.Sep.  Falta    Acond.      Peso Sld.Estq.  Sld.ESA . Semana  "
	nLin +=  1
Return(nLin)


/*/{Protheus.doc} ImpRota
//TODO Descrição auto-gerada.
@author Roberto
@since 21/07/2017
@version 1.0

@type function
/*/
User Function ImpRota()
	DbSelectArea("SZK")
	DbSetOrder(1)
	
	dbSelectArea("SC6")
	SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	DbSelectArea("TRB")
	DbGoTop() //ROTA+NOME+C6_NUM+C6_ITEM
	
	SetRegua(RecCount())
	Do While TRB->(!Eof())
		If lAbortPrint
			Exit
		Endif
		DbSelectArea("SC6")
		DbSeek(xFilial("SC6")+TRB->C6_NUM,.F.)
		
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
		
		_lFirst := .T.
		_cNumPed:= TRB->C6_NUM
		_nTotPeso := 0.00
		_nTotVlr1 := 0.00
		_nTotVlr2 := 0.00
		_lBlqCre  := .F.
		Do While TRB->C6_NUM == _cNumPed .And. TRB->(!Eof())
			If lAbortPrint
				@	nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			IncRegua()
			
			DbSelectArea("SC6")
			DbSeek(xFilial("SC6")+TRB->C6_NUM+TRB->C6_ITEM,.F.)
			
			If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 6
				SZK->(DbSeek(xFilial("SZK") + TRB->ROTA,.F.))
				@ nLin,000 PSAY TRB->ROTA + " - " + SZK->ZK_DESCR
				nLin := 7
				nLin := MyCab(nLin,_lFirst)
				_lFirst := .F.
			Endif
			If _lFirst
				@ nLin,000 PSAY Replicate("-",limite)
				nLin++
				SZK->(DbSeek(xFilial("SZK") + TRB->ROTA,.F.))
				@ nLin,000 PSAY TRB->ROTA + " - " + SZK->ZK_DESCR
				nLin++
				nLin := MyCab(nLin,_lFirst)
				_lFirst := .F.
			EndIf
			_nTotPeso += TRB->NPESO
			_nTotVlr1 += ((_cAliasC6)->C6_QTDVEN-(_cAliasC6)->C6_QTDENT) * (_cAliasC6)->C6_PRCVEN
			_nTotVlr2 += TRB->QTDSC9 * (_cAliasC6)->C6_PRCVEN
			
			@ nLin,000 PSAY Left(TRB->C6_ITEM,2)
			@ nLin,003 PSAY TRB->C6_PRODUTO Picture "@R 999.99.99.9.99"
			@ nLin,018 PSAY TRB->C6_DESCRI
			@ nLin,051 PSAY TRB->C6_QTDVEN                         PICTURE "@E 999,999"
			@ nLin,060 PSAY TRB->C6_QTDVEN-TRB->C6_QTDENT          PICTURE "@E 999,999"
			@ nLin,069 PSAY TRB->QTDSC9                               PICTURE "@E 999,999"
			@ nLin,078 PSAY TRB->C6_QTDVEN-TRB->C6_QTDENT-TRB->QTDSC9 PICTURE "@E 999,999"
			@ nLin,087 PSAY TRB->C6_ACOND
			@ nLin,094 PSAY TRB->NPESO                             PICTURE "@EZ 9,999,999"
			@ nLin,104 PSAY TRB->NSLDEST                           PICTURE Iif(TRB->NSLDEST>9999999,"@EZ 99999,999","@EZ 9,999,999")
			@ nLin,114 PSAY TRB->NQTDSC2                           PICTURE Iif(TRB->NQTDSC2>9999999,"@EZ 99999,999","@EZ 9,999,999")
			@ nLin,124 PSAY TRB->C6_DTEPA2
			nLin := nLin + 1 // Avanca a linha de impressao
			DbSelectArea("TRB")
			TRB->(DbSkip())
		EndDo
		If _nTotPeso > 0 .Or. _nTotVlr1 > 0 .Or. _nTotVlr2 > 0
			@ nLin,025 PSAY "Saldo P.V. R$"
			@ nLin,039 PSAY _nTotVlr1 Picture "@E 9,999,999.99"
			@ nLin,052 PSAY "Total Emp.R$"
			@ nLin,065 PSAY _nTotVlr2 Picture "@E 9,999,999.99"
			@ nLin,078 PSAY "Peso Total ->"
			@ nLin,094 PSAY _nTotPeso PICTURE "@EZ 9,999,999"
			nLin := nLin + 1 // Avanca a linha de impressao
			nLin := PrintLog(_cNumPed,nLin)
			DbSelectArea("TRB")
		EndIf
	EndDo
Return(.T.)


/*/{Protheus.doc} PrintLog
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/07/2017
@version 1.0
@param _cNumPed, , descricao
@param _nLin, , descricao
@type function
/*/
Static Function PrintLog(_cNumPed,_nLin)
	DbSelectArea("ZZI")
	DbSetOrder(2) // ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
	// Procura o último evento código 90 para esse pedido
	_cDtHr := ""
	_cZZIMsg := " "
	DbSeek(xFilial("ZZI")+"90"+_cNumPed,.F.)
	Do While ZZI->ZZI_FILIAL == xFilial("ZZI") .And. ZZI->ZZI_CODEVE == "90" .And. ;
		ZZI->ZZI_PEDIDO == _cNumPed .And. ZZI->(!Eof())
		If	Dtos(ZZI->ZZI_DATA)+ZZI->ZZI_HORA > _cDtHr .And. ZZI->ZZI_CODEVE == "90"
			_cZZIMsg := AllTrim(ZZI->ZZI_USER) + " " + Dtoc(ZZI->ZZI_DATA) + " " + ZZI->ZZI_HORA + " - " + AllTrim(ZZI->ZZI_OBS)
			_cDtHr := Dtos(ZZI->ZZI_DATA)+ZZI->ZZI_HORA
		EndIf
		ZZI->(DbSkip())
	EndDo
	If !Empty(SC5->C5_DTEPA2)
		If !Empty(_cZZIMsg)
			_cZZIMsg := AllTrim(_cZZIMsg) + " - Data PCP.: " + Dtoc(SC5->C5_DTEPA2)
		Else
			_cZZIMsg := "Data PCP.: " + Dtoc(SC5->C5_DTEPA2)
		EndIf
	EndIf
	
	If !Empty(_cZZIMsg)
		_cZZIMsg := "Obs.: " + _cZZIMsg
		@ _nLin,000 PSAY Left(_cZZIMsg,limite)
		_nLin := _nLin + 1 // Avanca a linha de impressao
		If Len(_cZZIMsg) > limite
			@ _nLin,000 PSAY Substr(_cZZIMsg,limite+1,limite)
			_nLin := _nLin + 1 // Avanca a linha de impressao
		EndIf
	EndIf
Return(_nLin)



/*/{Protheus.doc} cbcSaldoProcSB2
//TODO .
@author MADEIRA
@since 25/10/2017
@version undefined
@param cCod, characters, o codigo do produto
@type function
/*/
USER FUNCTION cbrSaldoProcSB2(cCod)
      Local aArea := GetArea()
      //Local cCod := "1599001100"
      Local nSaldoSb2 := ""
      
      DbSelectArea("SB2")
      SB2->(DbSetOrder(2))
      
      SB2->(DbSeek(xFilial("SB2")+'99'+'Q'+cCod))
      
      nSaldoSb2 := SB2->B2_QATU
      
            
      RestArea(aArea)

Return(nSaldoSb2)
