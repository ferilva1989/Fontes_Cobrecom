#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATR17                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: ROBERTO OLIVEIRA                   Data ..: 30/01/2012   //
//                                                                          //
//   Objetivo ...: Relatório de Orçamento de Vendas                         //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
************************
User Function CDFATR17()
************************
*
	Local cDesc1        := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2        := "de Orçamento de Vendas de acordo "
	Local cDesc3        := "com os parâmetros informados pelo usuário."
	Local cPict         := ""
	Local titulo        := "Orçamento de Vendas"
	Local nLin          := 80
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "CDFATR17"
	Private nTipo       := 15
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "CDFT17"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CDFATR17"
	Private lImpCb      := .F.
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	Private cString     := "SCJ"

	/* [LEO] 06/03/17 - Relatorio considerando Portal/Orçamento interno */
	if GetNewPar('XX_NEWREP', .T. )
		U_zPrtOrc('orcamento')
	/* [LEO] 06/03/17 - Forma antiga de fazer*/
	else
		DbSelectArea("SCJ")
		DbSetOrder(1)
	
		ValidPerg()
	
		Pergunte(cPerg,.T.)
	
		DbSelectArea("SCJ")
		DbSetOrder(1)
	
		wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
		
		If nLastKey == 27
			Return
		Endif
	
		limite      := 220 
		tamanho     := "G" 
		aReturn[4]  := 2
	
		SetDefault(aReturn,cString)
	
		If nLastKey == 27
			Return
		Endif
	
		nTipo := If(aReturn[4]==1,15,18)
	
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	endif
return( .T. )

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////
	local	nTotPvc		:= 0
	Private _nLi := 80

	Private _cProduto 	:= Space(15)
	Private _nTotMt 	:= 0
	Private _nValTot 	:= 0
	Private _nValTab  	:= 0
	private lQtd		:= (MV_PAR09 == 2) 
	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SCK")
	DbSetOrder(1) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO

	DbSelectArea("SCJ")
	DbSetOrder(1)  //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
	m_pag    := 01
	_nLi     := 80
	_nTotMt  := 0
	_nValTot := 0
	_nValTab := 0
	SetRegua(RecCount())
	DbSeek(xFilial("SCJ")+Mv_Par01,.T.)
	Do While SCJ->CJ_FILIAL == xFilial("SCJ") .And. SCJ->CJ_NUM <= Mv_Par02 .And. SCJ->(!Eof())

		IncRegua()

		If lAbortPrint
			@ _nLi,00 PSay "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If SCJ->CJ_EMISSAO < Mv_Par03 .Or. SCJ->CJ_EMISSAO > Mv_Par04 .Or.;
		SCJ->CJ_CLIENTE < Mv_Par05 .Or. SCJ->CJ_CLIENTE > Mv_Par07 .Or.;
		SCJ->CJ_LOJA    < Mv_Par06 .Or. SCJ->CJ_LOJA    > Mv_Par08
			DbSelectArea("SCJ")
			DbSkip()
			Loop
		EndIf

		_nIndCsMp := 0.00 // Somente custo do Cobre + PVC

		_nTotMet := 0
		_nTotVen := 0.00
		_nTotCus := 0.00
		_nTotPes := 0.00
		_nTotCom := 0.00
		nTotPvc  := 0.00
		_nValTot  := 0
		_nValTab  := 0
		_nPesoTot := 0
		_nVal2_5  := 0
		_nQtd2_5  := 0
		_nTotPV   := 0
		_nComis   := 0

		DbSelectArea("SCK")
		DbSeek(xFilial("SCK")+SCJ->CJ_NUM,.F.)
		Do While SCK->(!Eof()) .And. SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == SCJ->CJ_NUM
			_nTotPV += SCK->CK_VALOR
			SCK->(dbSkip())
		EndDo

		If _nLi > 60
			Titulo := "O R Ç A M E N T O  -  N. " + SCJ->CJ_NUM  + IIf(SCJ->CJ_CONDPAG=="000","  - B N D E S","") 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			_nLi := 7
			ImprCabec()
		Endif

		DbSelectArea("SCK")
		DbSeek(xFilial("SCK")+SCJ->CJ_NUM,.F.)
		Do While SCK->CK_FILIAL+SCK->CK_NUM == xFilial("SCK")+SCJ->CJ_NUM .And. SCK->(!Eof())

			If !Empty(_cProduto) .And. Left(_cProduto,5) # Left(SCK->CK_PRODUTO,5)
				If !lImpCb
					@ _nLi,000 PSay Replicate("-",limite)
					_nLi++
				EndIf
				_cProduto := SCK->CK_PRODUTO
			Else
				_cProduto := SCK->CK_PRODUTO
			EndIf

			If lImpCb
				lImpCb := .F.
			EndIf

			@ _nLi,000 PSay SCK->CK_PRODUTO 		Picture "@R XXX.XX.XX.X.XX"
			@ _nLi,015 PSay Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_DESC")),42)

			_cAcondic := " "

			_cAcondic := Transform(SCK->CK_LANCES,"@E 9,999") + " x " +SCK->CK_ACONDIC+StrZero(SCK->CK_METRAGE,5)

			@ _nLi,058 PSay SCK->CK_QTDVEN  		Picture "@E 9,999,999"
			@ _nLi,068 PSay SCK->CK_PRCVEN  		Picture "@E 9999.9999"

			// Posiciona SB1
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))

			// Recalcula o LB
			If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
				_nCustd   := SB1->B1_CUSTD3L
			Else
				_nCustd   := SB1->B1_CUSTD
			EndIf

			_nPescob  := SB1->B1_PESCOB * SCK->CK_QTDVEN
			nTotPvc	  += SCK->(CK_XFTPVC) * SCK->(CK_QTDVEN)
			//_nFator  := (SCK->CK_QTDVEN * SCK->CK_PRCVEN) / _nPescob //ESTE AQUI
			_nLUCROBR := Round(If(_nCustd==0,0,(((SCK->CK_PRCVEN*100)/_nCustd)-100)),2)
			_nTotVen += SCK->CK_QTDVEN * SCK->CK_PRCVEN
			_nTotCus += SCK->CK_QTDVEN * _nCustd
			_nTotCom += Round(((SCK->CK_QTDVEN * SCK->CK_PRCVEN) * SCK->CK_COMIS1) /100,2)
			_nTotPes += _nPescob
			_nTotMet += SCK->CK_QTDVEN

			_nIndice := SCK->CK_QTDVEN * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item

			// Verifica se o valor do cobre+pcv é maior que 75% do valor do item
			_nVaric  := Round(((_nIndice / 75) * 100),2) //
			If _nVaric > SCK->CK_VALOR
				_nVaric := (_nVaric - SCK->CK_VALOR)
				_nVaric := Round(((_nVaric / SCK->CK_VALOR) * 100),2) // % a acrescentar no valor de venda para poder chegar a 75%
			Else
				_nVaric  := 0.00
			EndIf

			_nIndCsMp += _nIndice // Acumula o valor do Cobre e do PVC
			_nIndice := Round((_nIndice / SCK->CK_VALOR) * 100,2) // Calcula em Percentual

			If SCK->CK_INDICE # _nIndice
				RecLock("SCK",.F.)
				SCK->CK_INDICE := _nIndice
				MsUnLock()
			EndIf

			//@ _nLi,078 PSay _nLUCROBR+GetMv("MV_X_TGT")	Picture "@E 9999.99"
			@ _nLi,078 PSay _nLUCROBR	Picture "@E 9999.99"
			@ _nLi,086 PSay SCK->CK_VALOR  		Picture "@E 99,999,999.99"
			@ _nLi,101 PSay _cAcondic

			_nPesoTot += SCK->CK_QTDVEN * Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_PESO")
			If Left(SCK->CK_PRODUTO,5) $ "10105//11505" // Fio ou Flex 2,5mm
				_nVal2_5  += SCK->CK_VALOR
				_nQtd2_5  += SCK->CK_QTDVEN
			EndIf

			@ _nli,114 PSay SCK->CK_COMIS1 Picture "@E 999.99"
			@ _nLi,122 PSay SCK->CK_TES

			_nPrcUnit  := u_TabBruto(SCJ->CJ_TABELA,_cProduto,SCK->CK_ACONDIC+StrZero(SCK->CK_METRAGE,5))

			/*EDVAR - INCLUIR % DE DESCONTO - SOLICITADO POR FONSECA*/

			If _nPrcUnit == 0
				@ _nLi,128 PSay "??.??"
			Else
				_cDescVis := If(Empty(SCJ->CJ_CONDPAG),"N",Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_AVISTA"))
				_cDescs := u_ClcDesc(SCJ->CJ_TABELA,SCJ->CJ_VEND1,_cProduto,SCK->CK_PRCVEN,_nPrcUnit,_cDescVis)
				_cDescs := _cDescs[1]
				If Len(_cDescs) > 33
					_cDescs := Left(_cDescs,30) + "..."
				EndIf
				@ _nLi,128 PSay _cDescs
			EndIf

			_nPrcUnit := u_TabBruto(SCJ->CJ_TABELA,_cProduto,SCK->CK_ACONDIC+StrZero(SCK->CK_METRAGE,5))

			//@ _nLi,161 PSay _nIndice Picture "@E 9999.99"

			@ _nLi,155 PSay If(SCK->CK_PRCVEN<u_DescCasc(_nPrcUnit,StrTokArr(AllTrim(SCJ->CJ_DESCPAD),"+",.F.),TamSX3("CK_PRCVEN" )[2]),;
			"Desc.Maior","")

			@ _nLi,169 PSay _nVaric  Picture "@E 9999.99"

			_nValTot += SCK->CK_VALOR


			/*/
			DbSelectArea("DA1")
			DbSetOrder(1)
			DbSeek(xFilial("DA1")+SCJ->CJ_TABELA + _cProduto,.F.)
			If SCK->CK_ACONDIC == "R" .And. SCK->CK_METRAGE == 50 .And. DA1->DA1_PRC50M > 0
			_nPrcUnit := DA1->DA1_PRC50M
			ElseIf SCK->CK_ACONDIC == "R" .And. SCK->CK_METRAGE == 15 .And. DA1->DA1_PRC15M > 0
			_nPrcUnit := DA1->DA1_PRC15M
			Else
			_nPrcUnit := DA1->DA1_PRCVEN
			EndIf
			/*/

			If _nPrcUnit == 0
				_nValTab += (SCK->CK_QTDVEN * SCK->CK_PRUNIT)
			Else
				_nValTab += (SCK->CK_QTDVEN * _nPrcUnit)
			EndIf
			_nLi++

			If _nLi > 60
				Titulo := "O R Ç A M E N T O  -  N. "+SCJ->CJ_NUM  + IIf(SCJ->CJ_CONDPAG=="000","  - B N D E S","") 
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				_nLi := 7
				ImprCabec()
			Endif

			DbSelectArea("SCK")
			DbSkip()

		EndDo
		_cProduto := Space(15)

		@ _nLi,000 PSay Replicate("-",limite)
		_nLi++    

		_nIndice := Round(((_nIndCsMp / _nValTot) * 100),2)

		If SCJ->CJ_INDICE # _nIndice
			RecLock("SCJ",.F.)
			SCJ->CJ_INDICE := _nIndice
			MsUnLock()
		EndIf

		_nVaric  := Round(((_nIndCsMp / 75) * 100),2)
		If _nVaric > _nValTot
			_nVaric  := (_nVaric - _nValTot)
			_nVaric  := Round(((_nVaric / _nValTot) * 100),2)
		Else
			_nVaric  := 0.00
		EndIf

		@ _nLi,000 PSay "Fios/Flex 2,5: "
		if lQtd
			@ _nLi,015 PSay Round((_nQtd2_5/_nTotMet) * 100,2) Picture "@E 999.99"
		else
			@ _nLi,015 PSay Round((_nVal2_5/_nValTot) * 100,2) Picture "@E 999.99"
		endif
		@ _nLi,021 PSay "%"
		@ _nLi,026 PSay "Peso Total(PVC+Cob):"
		@ _nLi,047 PSay Transform(Int(_nPesoTot),"@E 999,999") + " kg"
		@ _nLi,072 PSay "Valor Total"	
		@ _nLi,085 PSay _nValTot  		Picture "@E 99,999,999.99"
		@ _nLi,101 PSay "Desc.Medio:"
		@ _nLi,111 PSay Round((((_nValTab - _nValTot) / _nValTab) * 100),2) Picture "@E 999.99"
		// @ _nLi,126 PSay "Indice/Variac.:"
		// @ _nLi,142 PSay _nIndice Picture "@E 9999.99"
		// @ _nLi,150 PSay _nVaric  Picture "@E 9999.99"

		_nLi++
		_nKgKm := Round(((_nTotPes/_nTotMet)*1000),2)

		//_nLUCROBR := Round((((_nTotVen/_nTotCus)*100)-100),2)
		//@ _nLi,000 PSay _nLUCROBR Picture "@E( 9999.99"

		// @ _nLi,026 PSay "Kg Cobre / Km......:"
		// @ _nLi,047 PSay _nKgKm Picture "@E 9999.99"


		_nLi++
		@ _nLi,00 PSay "Cadastro Original: "+SCJ->CJ_USERINC
		@ _nLi,35 PSay "Cadastro Alterado: "+SCJ->CJ_USERALT

		_nLUCROBR := Round((((_nTotVen/_nTotCus)*100)-100),2)
		// @ _nLi,76 PSay "  TGT  "+Transform(_nLUCROBR+GetMv("MV_X_TGT"),"@E 9999.99")
		@ _nLi,76 PSay "  RG:  "+Transform(_nLUCROBR,"@E 9999.99")
		
		/* [LEO]- 01/02/17 - pedido Rafael/Jeferson ( Mudar forma de calculo fator PV ) */
			if empty( SCJ->(CJ_XFTCOBR) )
				_nFator := 0
			else
				_nFator := ((( (_nTotPes * SCJ->(CJ_XFTCOBR) ) + nTotPvc  )/ _nTotVen) * 100) // ESTE AQUI
			endif
		/*[LEO]- FIM*/
		@ _nLi,095 PSay "IMP: " + Transform(_nFator,"@E 999.99") + " Fator: " +;
		 							Transform((_nTotVen/_nTotPes),"@E 999.99")// ESTE AQUI


		//@ _nLi,095 PSay "F =" 
		//@ _nLi,099 PSay _nFator Picture "@E( 999.99"

		_nPerCom := Round((_nTotCom/_nTotVen) * 100,2)
		@ _nLi,141 PSay "%Med.Com: " + Transform(_nPerCom,"@E 999.99") 

		_nLi++

		@ _nLi,00 PSay DToC(SCJ->CJ_DTINC)
		@ _nLi,35 PSay DToC(SCJ->CJ_DTALT)
		_nLi+=2
		@ _nLi,00 PSay "Conferido: __________________________________"
		@ _nLi,50 PSay "Data: ______/______/________"
		_nLi+=60
		DbSelectArea("SCJ")
		DbSkip()
	EndDo

	Set Device To Screen
	If aReturn[5]==1
		DbCommitAll()
		Set Printer To
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)

/////////////////////////
Static Function ImprCabec() //revisar para orçamento
	/////////////////////////

	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,.F.)

	@ _nLi,00 PSay "DATA DO ORÇAMENTO: "+DToC(SCJ->CJ_EMISSAO)
	@ _nLi,70 PSay "CIDADE: "+Left(SA1->A1_MUN,25)
	@ _nLi,105 PSay "UF: "+SA1->A1_EST
	@ _nLi,150 PSay "***********************   A T E N Ç Ã O   ************************"

	_nLi++
	@ _nLi,00 PSay "CLIENTE: "+SCJ->CJ_CLIENTE+"/"+SCJ->CJ_LOJA+" - " + SA1->A1_NOME
	_cMyTpCli := "?????"


	/*/
	If SCJ->CJ_TIPOCLI == "S"
	_cMyTpCli := "Solidario"
	ElseIf SCJ->CJ_TIPOCLI == "F"
	_cMyTpCli := "Cons.Final"
	ElseIf SCJ->CJ_TIPOCLI == "R"
	_cMyTpCli := "Revend."
	EndIf
	/*/
	If SA1->A1_TIPO == "S"
		_cMyTpCli := "Solidario"
	ElseIf SA1->A1_TIPO == "F"
		_cMyTpCli := "Cons.Final"
	ElseIf SA1->A1_TIPO == "R"
		_cMyTpCli := "Revend."
	EndIf

	@ _nLi,105 PSay "TP.CLI.: "+_cMyTpCli
	@ _nLi,150 PSay "*   1) DESCONTO PADRÃO = " + SCJ->CJ_DESCPAD
	@ _nLi,215 PSay "*"

	_nLi++

	@ _nLi,00 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA1->A1_CGC))==11,;
	Transform(SA1->A1_CGC,"@R 999.999.999-99"),;
	Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))
	@ _nLi,70 PSay "FONE: "+SA1->A1_TEL	
	@ _nLi,105 PSay "Tabela : "+SCJ->CJ_TABELA

	@ _nLi,150 PSay "*   2) MEDIA MINIMA TARGET = 40"
	@ _nLi,215 PSay "*"

	_nLi++                    

	@ _nLi,00 PSay "VENDEDOR: "+SCJ->CJ_VEND1+" - "+Posicione("SA3",1,xFilial("SA3")+SCJ->CJ_VEND1,"A3_NOME")
	//@ _nLi,105 PSay "Regra  : "+SCJ->CJ_DESCPAD
	@ _nLi,150 PSay "*   3) FIOS/FLEX 2,5 NÃO PODE PASSAR DE 30% DO PEDIDO            *"

	_nLi++

	@ _nLi,00 PSay "DATA DE ENTREGA: "+DToC(SCJ->CJ_ENTREG)
	@ _nLi,70 PSay "Ordem Compra:"
	@ _nLi,84 PSay SCJ->CJ_PEDCLI
	_LocEnt := AllTrim(AllTrim(SCJ->CJ_ENDENT1) + " " + AllTrim(SCJ->CJ_ENDENT2))
	@ _nLi,105 PSay "Loc.Entrega: " + _LocEnt
	@ _nLi,150 PSay "******************************************************************"
	_nLi++

	@ _nLi,00 PSay "COND. DE PGTO.: "+ AllTrim(SCJ->CJ_CONDPAG) + "  -  " + Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_DESCRI")
	@ _nLi,70 PSay "PRZ. MEDIO:"
	@ _nLi,83 PSay Int(Val(Posicione("SE4",1,xFilial("SE4")+SCJ->CJ_CONDPAG,"E4_ZMEDPAG"))) Picture "@E 999"
	_nLi++

	@ _nLi,00 PSay "OBSERVACOES: "+SCJ->CJ_OBS
	_nLi++

	@ _nLi,00 PSay "TRANSP.: " + SCJ->CJ_TRANSP + " " + If(!Empty(SCJ->CJ_TRANSP),Posicione("SA4",1,xFilial("SA4")+SCJ->CJ_TRANSP,"A4_NOME"),"")
	_cMyTpFrete := "????"
	If SCJ->CJ_TPFRETE == "C"
		_cMyTpFrete := "CIF"
	ElseIf SCJ->CJ_TPFRETE == "F"
		_cMyTpFrete := "FOB"
	EndIf
	@ _nLi,70 PSay "TIPO FRETE : " + _cMyTpFrete
	_nLi++

	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++

	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit.     RG       Total        Lances       %Com. TES   Desc.Aplicado                      Indice  Variac."    
	//@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit.     TGT      Total       Lances      %Com. TES   Desc.Aplicado                              Variac."    
	_nLi++

	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++
	lImpCb := .T.

Return(.T.)

/////////////////////////
Static Function ValidPerg 
	/////////////////////////

	Private cPerg       := "CDFT17"

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Orçamento                 ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Orçamento              ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Emissão           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Emissão        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","% Felx 2.5             		 ?","mv_ch9","N",01,0,0,"C","","mv_par09","Valor","","","Quantidade","","","","","","","","","","",""})
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
			MsUnlock()
			DbCommit()
		Endif
	Next

	RestArea(_aArea)

Return(.T.)
/*/
@ _nLi,150 PSay "***************************************************************"
@ _nLi,150 PSay "* OBSERVACAO                                                  *"
@ _nLi,150 PSay "*                                                             *"
@ _nLi,150 PSay "* 	DESCONTO = 50+25+18                                        *"
@ _nLi,150 PSay "* 	MEDIA TGT MINIMA = 40                                      *"
@ _nLi,150 PSay "* 	FLEXIVEL 2,5 NAO PODE PASSAS DE 30% DO ORCAMENTO/PEDIDO    *"
@ _nLi,150 PSay "***************************************************************"


***********************   A T E N Ç Ã O   ************************"
*   1) DESCONTO PADRÃO = 50+20+06                                *"
*   2) MEDIA MINIMA TARGET = 40                                  *"
*   3) FIOS/FLEX 2,5 NÃO PODE PASSAR DE 30% DO PEDIDO            *"
******************************************************************"

/*/
