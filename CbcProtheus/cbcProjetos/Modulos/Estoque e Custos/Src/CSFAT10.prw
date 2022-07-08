#include "protheus.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CSFAT10
//TODO Solicitação de transferência de materiais a outra uni-   
		dade da empresa - cria o pedido. .
@author Roberto Oliveira 
@since 28/04/2010
@version 1.0

@type function
/*/
User Function CSFAT10()
	Private _nOrdCols := 1
	cCadastro := "Solicitação de Transferência de Materiais"
	aRotina := {{ "Pesquisar"   , "AxPesqui"    , 0 , 1	},;
				{ "Visualizar"  , "AxVisual"    , 0 , 2	},;
				{ "Incluir"     , "U_CSFAT10a"  , 0 , 3	}} //,;
	DbSelectArea("SC9")
	SC9->(DbSeek(xFilial("SC9")))
	
	mBrowse(001,040,200,390,"SC9",,,,,,)
Return(.T.)


/*/{Protheus.doc} CSFAT10a
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function CSFAT10a()
	Local nOpcE		:= 3
	Local nOpcG		:= 3
	Local inclui	:= .T.
	Local altera 	:= .F.
	Local exclui 	:= .F.
	
	Private aAltEnchoice :={}
	Private _cBNDES	:= "N"
	Private _nVolta	:= 1
	Private nUsado	:= 0
	Private _cPedi1	:= ""
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SBF")
	DbSetOrder(1)  // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	_cPedi1 := Space((Len(SC5->C5_NUM)*20)+18)
	
	Do While _nVolta < 3
	
		If _nVolta == 2 // Criar cópia do acols
			_MyAcols := {}
			For _nxx := 1 to Len(aCols)
				AADD(_MyAcols,Array(Len(aHeader)+1))
				For _nxx1 := 1 to Len(aCols[_nxx])
					_MyAcols[_nxx,_nxx1] := aCols[_nxx,_nxx1]
				Next
			Next
		EndIf
	
		dbSelectArea("SX3")
		DbSetOrder(2)
		aHeader := {}
		For _nx := 1 to If(_nVolta==2,9,8) //hear
			nUsado := nUsado+1
			Aadd(aHeader,{" "," "," ",0,0," "," "," "," "," "} )
	
			If _nVolta == 1
				If _nx == 1
					aHeader[_nx,1] := "Pedido"
					aHeader[_nx,2] := "C9_PEDIDO"
				ElseIf _nx == 2
					aHeader[_nx,1] := "Item"
					aHeader[_nx,2] := "C9_ITEM"
				ElseIf _nx == 3
					aHeader[_nx,1] := "Produto"
					aHeader[_nx,2] := "C9_PRODUTO"
				ElseIf _nx == 4
					aHeader[_nx,1] := "Descricao"
					aHeader[_nx,2] := "C9_DESCRI"
				ElseIf _nx == 5
					aHeader[_nx,1] := "Quantidade"
					aHeader[_nx,2] := "C9_QTDLIB"
				ElseIf _nx == 6
					aHeader[_nx,1] := "Acondicionamento"
					aHeader[_nx,2] := "C9_NUMSERI" // Só estou emprestando a variável
				ElseIf _nx == 7
					aHeader[_nx,1] := "Tam. do Lance"
					aHeader[_nx,2] := "C9_QTDORI"// Só estou emprestando a variável
				ElseIf _nx == 8
					aHeader[_nx,1] := "Separar Item?"
					aHeader[_nx,2] := "C9_DAV"// Só estou emprestando a variável
				EndIf
			Else
				If _nx == 1
					aHeader[_nx,1] := "Produto"
					aHeader[_nx,2] := "C9_PRODUTO"
				ElseIf _nx == 2
					aHeader[_nx,1] := "Descricao"
					aHeader[_nx,2] := "C9_DESCRI"
				ElseIf _nx == 3
					aHeader[_nx,1] := "Acondicionamento"
					aHeader[_nx,2] := "C9_NUMSERI" // Só estou emprestando a variável
				ElseIf _nx == 4
					aHeader[_nx,1] := "Tam. do Lance"
					aHeader[_nx,2] := "C9_QTDORI"// Só estou emprestando a variável
				ElseIf _nx == 5
					aHeader[_nx,1] := "Quantidade"
					aHeader[_nx,2] := "C9_QTDLIB"
				ElseIf _nx == 6
					aHeader[_nx,1] := "Quant.Transf."
					aHeader[_nx,2] := "C9_QTDLIB2"
				ElseIf _nx == 7
					aHeader[_nx,1] := "Sld.Estoque"
					aHeader[_nx,2] := "C9_QTDRESE"
				ElseIf _nx == 8
					aHeader[_nx,1] := "Nro.Bob.Reserv."
					aHeader[_nx,2] := "ZE_NUMBOB"
				ElseIf _nx == 9
					aHeader[_nx,1] := "Separar Item?"
					aHeader[_nx,2] := "C9_DAV"// Só estou emprestando a variável
				EndIf
			EndIf
			DbSeek(aHeader[_nx,2],.F.)
			aHeader[_nx,03] := SX3->X3_PICTURE
			aHeader[_nx,04] := SX3->X3_TAMANHO
			aHeader[_nx,05] := SX3->X3_DECIMAL
			If _nVolta == 1 .And. _nx == 8
				aHeader[_nx,06] := "Pertence('SN')" //SX3->X3_VLDUSER // "AllwaysTrue()"
			ElseIf _nVolta == 2 .And. _nx == 6
				aHeader[_nx,06] := "u_VldQtd()" //SX3->X3_VLDUSER // "AllwaysTrue()"
			ElseIf _nVolta == 2 .And. _nx == 8
				aHeader[_nx,06] := "u_VldRes()" //SX3->X3_VLDUSER // "AllwaysTrue()"
			Else
				aHeader[_nx,06] := ".F." //SX3->X3_VLDUSER // "AllwaysTrue()"
			EndIf
			aHeader[_nx,07] := SX3->X3_USADO
			aHeader[_nx,08] := SX3->X3_TIPO
			aHeader[_nx,09] := SX3->X3_ARQUIVO
			aHeader[_nx,10] := SX3->X3_CONTEXT
		Next
	
		If _nVolta == 1
			aCols:={Array(nUsado+1)}
			For _ni:=1 to nUsado
				aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
			Next
			aCols[1,8]:="N" //Item não separado
			aCols[1,nUsado+1]:=.F.
		Else // _nVolta == 2 -> Aglutinar as Quantidades em MyAcols no novo acols
			Acols := {}
			For _nxx := 1 to Len(_MyAcols)
				If !_MyAcols[_nxx,Len(_MyAcols[_nxx])] // Se não estiver deletado
					// Procurar o produto e o Acondicionamento no aCols
					_npos := 0
					If _MyAcols[_nxx,8] == "N" //Item não separado
						For _nposSrh := 1 to Len(aCols)
							If aCols[_nposSrh,1] == _MyAcols[_nxx,3] .And. ;
								aCols[_nposSrh,3] == _MyAcols[_nxx,6] .And. ;
								aCols[_nposSrh,4] == _MyAcols[_nxx,7] .And. ;
								aCols[_nposSrh,9] == "N'
								// Mesmo produto e mesmo acondicionamento e mesmo tamanho do lance
								_npos := _nposSrh
								Exit
							EndIf
						Next
					EndIf
					If _npos == 0
						AADD(Acols,Array(Len(aHeader)+1))
						_npos := Len(Acols)
						Acols[_npos,1] := _MyAcols[_nxx,3]
						Acols[_npos,2] := _MyAcols[_nxx,4]
						Acols[_npos,3] := _MyAcols[_nxx,6]
						Acols[_npos,4] := _MyAcols[_nxx,7]
						Acols[_npos,5] := 0
						Acols[_npos,6] := 0
						Acols[_npos,7] := 0
						If _nVolta == 2
							Acols[_npos,8] := "       "
						EndIf
						Acols[_npos,Len(Acols[_npos])] := .F.
	
						_cLocaliz := "?"
						If AllTrim(Upper(Acols[_npos,3])) == "ROLO"
							_cLocaliz := "R"
						ElseIf AllTrim(Upper(Acols[_npos,3])) == "BOBINA"
							_cLocaliz := "B"
						ElseIf AllTrim(Upper(Acols[_npos,3])) == "CARRETEL N8"
							_cLocaliz := "C"
						ElseIf AllTrim(Upper(Acols[_npos,3])) == "CARRETEL MAD."
							_cLocaliz := "M"
						ElseIf AllTrim(Upper(Acols[_npos,3])) == "BLISTER"
							_cLocaliz := "L"
						ElseIf AllTrim(Upper(Acols[_npos,3])) == "RETALHO"
							_cLocaliz := "T"
						EndIf
	
						_cLocaliz := _cLocaliz + StrZero(Acols[_npos,4],5)
						_cLocaliz := Left(_cLocaliz+Space(40),Len(SBE->BE_LOCALIZ))
	
						SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
						SBF->(DbSeek(xFilial("SBF")+"01"+_cLocaliz+Acols[_npos,1],.F.))
						Acols[_npos,7] := (SBF->BF_QUANT-SBF->BF_EMPENHO)
						Acols[_npos,9] := _MyAcols[_nxx,8]
					EndIf
					Acols[_npos,5] += _MyAcols[_nxx,5]
					Acols[_npos,6] += _MyAcols[_nxx,5]
	
					// Gravo no último elemento de MyAcols o nro do elemento de acols... para depois eu saber quais itens fe pedidos a serem gravados no SC6
				EndIf
			Next
			aSort(aCols,,,{|x,y| x[1]<y[1]})
		EndIf
	
		_lRet:= .F.
		aButtons := {}
		aAdd( aButtons, { "PREV"  , { || u_InvDel()  }, "Inv.Deleção"} )
		aAdd( aButtons, { "PREV"  , { || u_TrcOrdem()}, "Inv.Ordem"} )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo        := "Solicitação de Transferência de Materiais"
		cAliasEnchoice := ""
		cAliasGetD     := "SC9"
		cLinOk         := "AllwaysTrue()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice   := {}
	
		_lRet:=u_JanFat10(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
		If _lRet
			If _nVolta == 1
				_nVolta := 2
			Else
				_cMensFT10 := "Processando Pedido de Venda..."
				Processa( {|| CSCriaPV() },_cMensFT10)
				_nVolta := 10 // Pra cair fora do Loop
			EndIf
		Else
			_nVolta := 10 // Pra cair fora do Loop
		EndIf
	EndDo
Return(.T.)


/*/{Protheus.doc} JanFat10
//TODO Janela Browser da função principal.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0
@param cTitulo, characters, descricao
@param cAlias1, characters, descricao
@param cAlias2, characters, descricao
@param aMyEncho, array, descricao
@param cLinOk, characters, descricao
@param cTudoOk, characters, descricao
@param nOpcE, numeric, descricao
@param nOpcG, numeric, descricao
@param cFieldOk, characters, descricao
@param lVirtual, logical, descricao
@param nLinhas, numeric, descricao
@param aAltEnchoice, array, descricao
@param nFreeze, numeric, descricao
@type function
/*/
User Function JanFat10(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
	Local aSize := {}
	Local aPosObj := {}
	Local aObjects := {}
	Local aInfo := {}
	
	aSize := MsAdvSize()
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 015, .t., .f. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
	//                                            {15,2,40,355}  45,2,190,355
	nGetLin := aPosObj[3,1]
	
	Private oDlg,oGetDados
	Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	
	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,999,nLinhas)
	
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	@ 015,015 Say "Nros.PV's: "                                   Size 45,10
	@ 015,065 Get _cPedi1                       Valid ConfPds()  When _nVolta == 1      Size 290,10 //Object _ocPed
	
	@ 035,015 Say "Pedidos BNDES ? : "                                                  Size 45,10
	@ 035,065 Get _cBNDES  Picture "@!"         Valid _cBNDES $ " NS" When _nVolta == 1 Size 12,10 //Object _ocPed
	
	oGetDados := MsGetDados():New(50,aPosObj[2,2],265,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	//oGetDados := MsGetDados():New(50,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_RefFat10()}
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
	
	lRet:=(nOpca==1)
Return(lRet)

/*/{Protheus.doc} RefFat10
//TODO Refresh.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function RefFat10()
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} ConfPds
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
Static Function ConfPds()
	aCols:={}
	_lRetFun := .T.
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	_cVarTRB := AllTrim(_cPedi1)
	_cPedVisto := ""
	Do While Len(_cVarTRB) > 0
		_cTRBNum := Left(_cVarTRB,6)
		If Len(_cVarTRB) > 6
			_cTRBVir := Substr(_cVarTRB,7,1)
		Else
			_cTRBVir := ","
		EndIf
		_cVarTRB := AllTrim(Substr(_cVarTRB,8))
		If _cTRBVir # ","
			Alert("Informar os Números Corretos dos Pedidos Separados por Vírgulas ','")
			_lRetFun := .F.
			Exit
		EndIf
		If _cTRBNum $ _cPedVisto // Se já fiz o pedido... pra não fazermais de uma vez
			Loop
		EndIf
		_cPedVisto := _cPedVisto + "/" + _cTRBNum
	
		DbSelectArea("SC9")
		_lTem := .F.
		SC9->(DbSeek(xFilial("SC9")+_cTRBNum,.F.))
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cTRBNum .And. SC9->(!Eof())
	
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM,.F.))
	
			If (Empty(SC9->C9_BLCRED)  .And. SC9->C9_BLEST == "02" .And. ;
				Empty(SC6->C6_SEMANA)  .And. SC6->C6_ACONDIC # "T") .Or. ;
				(Empty(SC9->C9_BLCRED)  .And. SC9->C9_BLEST == "02" .And. ;
				SC6->C6_ACONDIC == "T" .And. ("ADMINISTRADOR" $ Upper(cUserName) .Or. "ROBERTO" $ Upper(cUserName)))
				// Crédito liberado e não Separados e não incluidos em resumo
	
				If !_lTem
					_lTem := .T.
				EndIf
	
				_nCol := 0
				For _nxx := 1 to Len(aCols)
					If SC9->C9_PEDIDO == GDFieldGet("C9_PEDIDO",_nxx)  .And. SC9->C9_ITEM == GDFieldGet("C9_ITEM",_nxx)
						_nCol := _nxx
					EndIf
				Next
				If _nCol == 0
					AADD(aCols,Array(Len(aHeader)+1))
					_nCol := Len(aCols)
	
					aCols[Len(aCols),Len(aHeader)+1]:=.F.
	
					GDFieldPut("C9_PEDIDO",SC9->C9_PEDIDO,_nCol)
					GDFieldPut("C9_ITEM",SC9->C9_ITEM,_nCol)
					GDFieldPut("C9_PRODUTO",SC9->C9_PRODUTO,_nCol)
					GDFieldPut("C9_DESCRI",Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_DESC"),_nCol)
					GDFieldPut("C9_QTDLIB",0,_nCol)
					If SC6->C6_ACONDIC == "R"
						_cAcon := "Rolo"
					ElseIf SC6->C6_ACONDIC == "B"
						_cAcon := "Bobina"
					ElseIf SC6->C6_ACONDIC == "C"
						_cAcon := "Carretel N8"
					ElseIf SC6->C6_ACONDIC == "M"
						_cAcon := "Carretel Mad."
					ElseIf SC6->C6_ACONDIC == "T"
						_cAcon := "Retalho"
					ElseIf SC6->C6_ACONDIC == "L"
						_cAcon := "Blister"
					Else
						_cAcon := "????????"
					EndIf
					GDFieldPut("C9_DAV","N",_nCol)
					GDFieldPut("C9_NUMSERI",_cAcon,_nCol) // Só estou emprestando a variável -> Acondicionamento
					GDFieldPut("C9_QTDORI",SC6->C6_METRAGE,_nCol) // Só estou emprestando a variável -> Tam.do Lance
				EndIf
	
				GDFieldPut("C9_QTDLIB",GDFieldGet("C9_QTDLIB",_nCol)+SC9->C9_QTDLIB,_nCol)
			EndIf
			SC9->(DbSkip())
		EndDo
		If !_lTem
			Alert("O Pedido " + _cTRBNum + " Não Possui Itens Liberados para Transferência")
		EndIf
	EndDo
	If Len(aCols) == 0
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.
	EndIf
	u_RefFat10()
Return(_lRetFun)


/*/{Protheus.doc} CSCriaPV
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
Static Function CSCriaPV()
	Local _cTes		:= "551"
	Local _cTpOper	:= "11"
	Local _cTpProd	:= ""
	Private lPvAuto := .T.
	Private nNumAtu := 0
	
	If !MsgBox("Deseja Efetivar a Solicitação dos Materiais?","Confirma?","YesNo")
		Return(.T.)
	EndIf
	
	// Guardar dados da empresa atual
	_cFt10NEmp := cNumEmp
	If xFilial("SC6") == "01" // cNumEmp == "0101"   // estou na matriz // By Roberto Oliveira 23/03/17 - Usar xFilial("SC6") - Se o Usuário tiver acesso a todas as filiais, vem errado
		_cCli := "002560"  // seleciono o cliente matriz
		_cLoj := "01"
		cNumEmp := "0102"  // crio o pedido na filial
		cFilAnt := "02"
	Else                   // estou na filial
		_cCli := "008918"  // seleciono o cliente filial
		_cLoj := "01"
		cNumEmp := "0101"  // crio o pedido na matriz
		cFilAnt := "01"
	EndIf
	
	_cTabPrc :=	Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_TABELA")
	
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))
	
	ProcRegua(Len(aCols))
	
	// ATENÇÃO....
	//Guardar o acols atual porque a rotina automática vai usar esse nome de variável
	//na criação do novo pedido de venda.....
	///
	// Primeiro vou carregar o C6 e saber se tem o que fazer
	aBobsRes := {} // {Nro.Bobina,Item do Pedido}
	aItens:={}
	_cItem := StrZero(0,Len(SC6->C6_ITEM))
	For  _nMyxx := 1 To Len(aCols)
		IncProc()
		If !GDDeleted(_nMyxx)
			_cItem := Soma1(_cItem)
			_nCusto := Posicione("SB1",1,xFilial("SB1")+GDFieldGet("C9_PRODUTO",_nMyxx),"B1_CUSTD")
			_nCusto := Max(0.01,_nCusto)
	
			If !Empty(_cTabPrc)
				DbSelectArea("DA1")
				DbSetOrder(1)  //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
				DbSeek(xFilial("DA1")+_cTabPrc+GDFieldGet("C9_PRODUTO",_nMyxx),.F.)
				If !Eof() .And. DA1->DA1_PRCVEN > 0
					_nCusto := DA1->DA1_PRCVEN
				EndIf
			EndIf
	
			If !Empty(GDFieldGet("ZE_NUMBOB",_nMyxx))
				_cAcon := "B"
				_nMetr := GDFieldGet("C9_QTDLIB2",_nMyxx)
				_nLanc := 1
				Aadd(aBobsRes,{GDFieldGet("ZE_NUMBOB",_nMyxx),_cItem}) // {Nro.Bobina,Item do Pedido}
			Else
				_cAcon := Upper(GDFieldGet("C9_NUMSERI",_nMyxx))
				If "CARRETEL MAD." $ Upper(_cAcon)
					_cAcon := "M"
				ElseIf "RETALHO" $ Upper(_cAcon)
					_cAcon := "T"
				ElseIf "BLISTER" $ Upper(_cAcon)
					_cAcon := "L"
				Else
					_cAcon := Left(_cAcon,1)
				EndIf
				_nMetr := GDFieldGet("C9_QTDORI",_nMyxx)
				_nLanc := Int(GDFieldGet("C9_QTDLIB2",_nMyxx) / GDFieldGet("C9_QTDORI",_nMyxx))
			EndIf
			
			_cTpProd := Posicione("SB1",1,xFilial("SB1")+GDFieldGet("C9_PRODUTO",_nMyxx),"B1_TIPO")
			If _cTpProd == "PA"
				_cTpOper 	:= "09"
				_cTes 		:= "849"
			Else
				_cTpOper 	:= "11"
				_cTes 		:= "551"
			EndIf
	
			aAdd(aItens,{	{"C6_NUM"     ,"      "                        ,Nil},;
							{"C6_ITEM"    ,_cItem                          ,Nil},;
							{"C6_PRODUTO" ,GDFieldGet("C9_PRODUTO",_nMyxx) ,Nil},;
							{"C6_QTDVEN"  ,GDFieldGet("C9_QTDLIB2",_nMyxx) ,Nil},;
							{"C6_PRCVEN"  ,_nCusto                         ,Nil},;
							{"C6_ACONDIC" ,_cAcon                          ,Nil},;
							{"C6_METRAGE" ,_nMetr                          ,Nil},;
							{"C6_QTDLIB"  ,GDFieldGet("C9_QTDLIB2",_nMyxx) ,Nil},;
							{"C6_ENTREG"  ,dDataBase + 10                  ,Nil},;
							{"C6_TES"     ,_cTes						   ,Nil},; 
							{"C6_XOPER"   ,_cTpOper    					   ,Nil},; 
							{"C6_LANCES"  ,_nLanc                          ,Nil}})

		EndIf
	Next
	If Len(aItens) == 0
		cNumEmp := _cFt10NEmp
		cFilAnt := Right(cNumEmp,2)
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cNumEmp,.F.))
		Alert("Transferência não Realizada!!! Nenhum Item Selecionado!!!")
		Return(.T.)
	EndIf
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	Do While .T.
		cNumPed := GetSx8Num("SC5","C5_NUM")
		If !(DbSeek(xFilial("SC5")+cNumPed,.F.))
			Exit
		EndIf
		ConfirmSX8()
	EndDo

	aCabPV:={	{"C5_NUM"     ,cNumPed,nil},;
				{"C5_TIPO"    ,"N",nil},;
				{"C5_CLIENTE" ,_cCli,nil},;
				{"C5_LOJACLI" ,_cLoj,nil},;
				{"C5_CLIENT"  ,_cCli,nil},;
				{"C5_LOJAENT" ,_cLoj,nil},;
				{"C5_ENTREG"  ,dDataBase+10,nil},;
				{"C5_TRANSP"  ,"",nil},;
				{"C5_TABELA"  ,_cTabPrc,nil},;
				{"C5_TIPOCLI" ,"R",nil},;
				{"C5_CONDPAG" ,If(_cBNDES=="S","000","263"),nil},;
				{"C5_PEDCLI"  ,"",nil},;
				{"C5_OBS"     ,"TRANSFERENCIA DE MATERIAIS NAO COBRAR"+If(_cBNDES=="S","//BNDES",""),nil},;
				{"C5_DESCESP" ,0,nil},;
				{"C5_DESCEQT" ,0,nil},;
				{"C5_VEND1"   ,"010",nil},;
				{"C5_EMISSAO" ,dDatabase,nil},;
				{"C5_COTACAO" ,"",nil},;
				{"C5_PARC1"   ,0,nil},;
				{"C5_MOEDA"   ,1,nil},;
				{"C5_TPFRETE" ,"C",nil},;
				{"C5_LIBEROK" ,"S",nil},;
				{"C5_TXMOEDA" ,1,nil},;
				{"C5_TIPLIB"  ,"2",nil},;
				{"C5_TPCARGA" ,"2",nil},;
				{"C5_USERINC" ,Left(cUserName,Len(SC5->C5_USERINC)),nil},;
				{"C5_DTINC"   ,dDatabase,nil},;
				{"C5_CLIOK"   ,"S",nil},;
				{"C5_XOPER"   ,_cTpOper,nil},;
				{"C5_GERAWMS" ,"1",nil}}
				// Atenção... Não confundir:
				// C5_TIPLIB  -> campo do sistema - 1=Libera por Item;2=Libera por Pedido
				// C5_TIPOLIB -> Campo do usuário - Tipo Liberacao do Estoque
	
	For  _nMyxx := 1 To Len(aItens)
		_NN := 1
		If aItens[_nMyxx,1,1] == "C6_NUM"
			aItens[_nMyxx,1,2] := cNumPed
		EndIf
	Next
	
	_cMensFT10 := "Alterando Condições do Pedido de Venda..."
	ProcRegua(Len(aCols)) // O Incproc esta dentro da função CDFATV02
	
	lMsErroAuto:=.f.
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItens,3)
	_cNewPed := SC5->C5_NUM
	
	If ! lMsErroAuto
		ConfirmSX8()
	Else
		RollBackSx8()
	EndIf
	
	If lMsErroAuto
		Alert("Erro na Inclusão do Pedido de Transferência")
		MOSTRAERRO()
		Alert("Os Pedidos Estão em Suas Condições Originais")
	ElseIf Len(aBobsRes) > 0 // Tem bobina reservada?
		For _nBobs := 1 to Len(aBobsRes) // {Nro.Bobina,Item do Pedido}
			u_GraveSZR(aBobsRes[_nBobs,1],_cNewPed,aBobsRes[_nBobs,2],.F.)
		Next
	EndIf
	
	// Voltar para a filial original
	// esta retornando com nil
	cNumEmp := _cFt10NEmp
	SM0->(dbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))
	cFilAnt := Right(cNumEmp,2)
	If lMsErroAuto
		Return(.T.)
	EndIf
	
	_cMensFT10 := "Alterando Condições do Pedido de Venda..."
	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	ProcRegua(Len(aCols))
	For _nMyCt1 := 1 to Len(aCols)
		IncProc()
		If !Acols[_nMyCt1,Len(Acols[_nMyCt1])] // Se não estiver deletado
			For _nMyCt2 := 1 to Len(_MyaCols)
				If !_MyAcols[_nMyCt2,Len(_MyAcols[_nMyCt2])] // Se não estiver deletado
	
					If Acols[_nMyCt1,1] == _MyAcols[_nMyCt2,3] .And. Acols[_nMyCt1,3] == _MyAcols[_nMyCt2,6] .And. Acols[_nMyCt1,4] == _MyAcols[_nMyCt2,7]
						// Mesmo Produto, Acondicionamento e Tamanho do lance
	
						// Localiza o SC6
						// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
						If DbSeek(xFilial("SC6")+_MyAcols[_nMyCt2,1]+_MyAcols[_nMyCt2,2],.F.)
							RecLock("SC6",.F.)
							SC6->C6_SEMANA := "T"+_cNewPed
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	Next
	Alert("Processo Concluído -> Pedido Nro. " + _cNewPed)
Return(.T.)


/*/{Protheus.doc} VldQtd
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function VldQtd()
	// Não permitir alterar a quantidade se estiver preenchida o número da bobina
	If !Empty(GDFieldGet("ZE_NUMBOB",n))
		Alert("Alteração da Quantidade não Permitida -> Transf. Bobina")
		Return(.F.)
	ElseIf M->C9_QTDLIB2 <= 0
		Alert("Quantidade 0 não permitida! Para não Transferir, Delete a Linha")
		Return(.F.)
	ElseIf (M->C9_QTDLIB2 % GDFieldGet("C9_QTDORI",n)) > 0
		Alert("Informar quantidade maior que 0 e Múltiplo do Lance.")
		Return(.F.)
	EndIf
Return(.T.)


/*/{Protheus.doc} VldRes
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function VldRes()
	Local _cCli
	Local _cLoj
	Local _cNumEmp
	Local _cFilAnt
	Local _lVolta := .T.
	
	// Varrer o acols e verificar se essa bobina já não foi informada em outra linha
	If GDFieldGet("ZE_NUMBOB",n) == M->ZE_NUMBOB // Nro. de Bobinas iguais, mesmo que vazio
		Return(.T.)
	ElseIf !Empty(GDFieldGet("ZE_NUMBOB",n)) .And. !Empty(M->ZE_NUMBOB) .And. ;// Foi informada uma bobina anteriormente e agora quer tirar
		GDFieldGet("ZE_NUMBOB",n) # M->ZE_NUMBOB // Nro. de Bobinas são diferentes
		Alert("Uma vez informada, não excluir a bobina.")
		Alert("Para trocar, reinicie a operação.")
		Return(.F.)
	ElseIf !Empty(GDFieldGet("ZE_NUMBOB",n)) .And. Empty(M->ZE_NUMBOB) // Foi informada uma bobina anteriormente e agora quer tirar
		Alert("Uma vez informada, não excluir a bobina.")
		Alert("Para desconsiderar, reinicie a operação.")
		Return(.F.)
	EndIf
	For _nCls := 1 to Len(aCols)
		//If !GDDeleted(_nCls) .And. _nCls # n .And. GDFieldGet("ZE_NUMBOB",_nCls) == _BobAtu
		If _nCls # n .And. GDFieldGet("ZE_NUMBOB",_nCls) == M->ZE_NUMBOB
			// Não importa se está deletado... forçar o usuário a trocar se não for usar nessa linha.
			Alert("Bobina já Informada nesta Solicitação de Transferência")
			_lVolta := .F.
			Exit
		EndIf
	Next
	If _lVolta
		If cNumEmp == "0101"   // estou na matriz
			_cCli := "002560"  // seleciono o cliente matriz
			_cLoj := "01"
			_cNumEmp := "0102"  // crio o pedido na filial
			_cFilAnt := "02"
		Else                   // estou na filial
			_cCli := "008918"  // seleciono o cliente filial
			_cLoj := "01"
			_cNumEmp := "0101"  // crio o pedido na matriz
			_cFilAnt := "01"
		EndIf
		_aArea := GetArea()
	
		DbSelectArea("SZE")
		DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
		If !(DbSeek(_cFilAnt+M->ZE_NUMBOB,.F.))
			Alert("Bobina não Existe")
			_lVolta := .F.
		ElseIf SZE->ZE_STATUS # "V"
			Alert("Bobina não Reservada")
			_lVolta := .F.
		ElseIf SZE->ZE_CLIRES+SZE->ZE_LJRES # _cCli+_cLoj
			Alert("Bobina Reservada a Outro Cliente")
			_lVolta := .F.
		ElseIf SZE->ZE_PRODUTO # GDFieldGet("C9_PRODUTO",n)
			Alert("Produtos Diferentes")
			_lVolta := .F.
		EndIf
	EndIf
	If _lVolta
		//Verificar as quantidades e os acondicionamentos
		// Se a quantidade da Bobina for menor que e quantidade total -> Criar nova linha com a diferência,
		// respeitando o tamanho do lance.
		If SZE->ZE_QUANT < GDFieldGet("C9_QTDLIB",n) // Vejo pela quantidade  e não pela quantidade a transferir
			_nTotLnc := Int(GDFieldGet("C9_QTDLIB",n) / GDFieldGet("C9_QTDORI",n))
			_nQtdLnc := Max(Int(SZE->ZE_QUANT / GDFieldGet("C9_QTDORI",n)),1) // Tem que ser pelo menos 1 lance
	
			If _nTotLnc <= _nQtdLnc
				GDFieldPut("C9_QTDLIB" ,SZE->ZE_QUANT,n)
				GDFieldPut("C9_QTDLIB2",SZE->ZE_QUANT,n)
				GDFieldPut("C9_QTDRESE",0.00,n)
				// Dou um refresh
				oDlg:Refresh()
			ElseIf _nTotLnc > _nQtdLnc
				// Criar nova linha do mesmo produto para a quantidade
				AADD(Acols,Array(Len(aHeader)+1))
				_npos := Len(Acols)
				aCols[_npos,Len(aHeader)+1]:=.F.
				For _nPsAtu := 1 to Len(aHeader)
					aCols[_npos,_nPsAtu] := aCols[n,_nPsAtu]
				Next
	
				// Altero o novo aCols pela quantidade restante
				GDFieldPut("C9_QTDLIB" ,(_nTotLnc-_nQtdLnc),_npos)
				GDFieldPut("C9_QTDLIB2",(GDFieldGet("C9_QTDORI",_npos)*GDFieldGet("C9_QTDLIB",_npos)),_npos)
	
				// Altero o aCols atual pela quantidade da Bobina
				// Ops... não posso altertar pq depois não acha o pedido original para marcar o campo C6_SEMANA
				//GDFieldPut("C9_NUMSERI","Bobina"     ,n)
				//GDFieldPut("C9_QTDORI" ,SZE->ZE_QUANT,n)
				GDFieldPut("C9_QTDLIB" ,SZE->ZE_QUANT,n)
				GDFieldPut("C9_QTDLIB2",SZE->ZE_QUANT,n)
				GDFieldPut("C9_QTDRESE",0.00,n)
	
				// Dou um refresh
				oDlg:Refresh()
			EndIf
		ElseIf SZE->ZE_QUANT > GDFieldGet("C9_QTDLIB",n)
			GDFieldPut("C9_QTDLIB" ,SZE->ZE_QUANT,n)
			GDFieldPut("C9_QTDLIB2",SZE->ZE_QUANT,n)
			GDFieldPut("C9_QTDRESE",0.00,n)
			// Dou um refresh
			oDlg:Refresh()
		EndIf
	EndIf
Return(_lVolta)


/*/{Protheus.doc} InvDel
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function InvDel()
	For _nInv := 1 to Len(aCols)
		Acols[_nInv,Len(Acols[_nInv])] := !(Acols[_nInv,Len(Acols[_nInv])])
	Next
	oDlg:Refresh()
Return(.T.)


/*/{Protheus.doc} TrcOrdem
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0

@type function
/*/
User Function TrcOrdem()
	If _nVolta == 1
		If _nOrdCols == 1
			aSort(aCols,,,{|x,y| x[1]+x[2]<y[1]+y[2]}) // pedido +  item
			_nOrdCols := 2
		Else
			aSort(aCols,,,{|x,y| x[3]+x[6]<y[3]+y[6]}) // produto + acondicionamento
			_nOrdCols := 1
		EndIf
	Else
		aSort(aCols,,,{|x,y| x[1]+x[3]<y[1]+y[3]}) // produto + acondicionamento
	EndIf
	oDlg:Refresh()
Return(.T.)


/*/{Protheus.doc} GraveSZR
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 28/04/2010
@version 1.0
@param _cNumBob, , descricao
@param _cNumPed, , descricao
@param _cItPed, , descricao
@param _lBegin, , descricao
@type function
/*/
User Function GraveSZR(_cNumBob,_cNumPed,_cItPed,_lBegin)
	Local _cNumBob,_cNumPed,_cItPed,_lBegin
	Local _lVolta := .F.
	
	Default _lBegin := .F.
	
	If !_lBegin //TODO UNDERLINE
		BeginTran()
	EndIf
	
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	_lVolta := SZE->(DbSeek(xFilial("SZE")+_cNumBob,.F.))
	
	SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If SC6->(DbSeek(xFilial("SC6") + _cNumPed + _cItPed,.F.)) .And. _lVolta
		If RecLock("SC6",.F.)
			SC6->C6_SEMANA := If(Empty(SC6->C6_ZZNRRES),"RESERVA","ZP4")
			SC6->C6_QTDRES := SC6->C6_QTDVEN
			MsUnLock()
			DbSelectArea("SZR")
			RecLock("SZR",.T.)
			SZR->ZR_FILIAL  := xFilial("SZR")
			SZR->ZR_NUMBOB  := _cNumBob
			SZR->ZR_TAMBOB  := SZE->ZE_QUANT
			SZR->ZR_DATA    := dDataBase
			SZR->ZR_PRODUTO := SC6->C6_PRODUTO
			SZR->ZR_DESCR   := SC6->C6_DESCRI
			SZR->ZR_PEDIDO  := SC6->C6_NUM
			SZR->ZR_ITEMPV  := SC6->C6_ITEM
			SZR->ZR_CODCLI  := SC6->C6_CLI
			SZR->ZR_LOJA    := SC6->C6_LOJA
			SZR->ZR_NOMCLI  := Posicione("SA1",1,xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,"A1_NOME")
			SZR->ZR_QTDPV   := SC6->C6_QTDVEN
			SZR->ZR_ACONDIC := "B"
			SZR->ZR_LANCES  := 1
			SZR->ZR_METRAGE := SZE->ZE_QUANT
			SZR->ZR_RESP    := cUserName
			SZR->ZR_OBS     := If(Empty(SC6->C6_ZZNRRES),"Solicitada transferencia","Reserva do portal")
			MsUnLock()
	
			If !RecLock("SZE",.F.)
				_lVolta := .F.
			Else
				SZE->ZE_STATUS := "N" // Reserva confirmada
				SZE->ZE_CLIRES := SC6->C6_CLI
				SZE->ZE_LJRES  := SC6->C6_LOJA
				//I=Import..;C=Canc.;R=Recebida;P=A Liberar;E=Empenh.;F=Faturada;T=Estoque;
				//A=Adiantada;X=Expedida;D=Devolv.;V=Reserv.;N=Res.Conf.
				MsUnLock()
			EndIf
		Else
			_lVolta := .F.
		EndIf
	EndIf
	If !_lBegin //TODO UNDERLINE
		If !_lVolta
			DisarmTransaction()
		EndIf
		EndTran()
	EndIf
Return(_lVolta)