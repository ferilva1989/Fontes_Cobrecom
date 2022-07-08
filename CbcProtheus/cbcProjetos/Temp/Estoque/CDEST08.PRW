#include "rwmake.ch"

/*/{Protheus.doc} CDEST08
//TODO Receber arquivo dos Fardos do Coletor, fazer a validação com as notas e imprimir etiquetas dos fardos.
@author Roberto Oliveira
@since 15/07/2008
@version 1.0

@type function
/*/
User Function CDEST08()
	cCadastro := "Separação - Fardos"
	aRotina := {{ "Pesquisar"   , "AxPesqui"    , 0 , 1	},;
				{ "Visualizar"  , "U_CDEST08a"  , 0 , 2	},;
				{ "Incluir"     , "U_CDEST08b"  , 0 , 3	},;
				{ "Excluir"     , "U_CDEST08d"  , 0 , 4	},;
				{ "Rel.Fardos"  , "U_CDEST08g"  , 0 , 4	},;
				{ "Exp.Zebra"   , "U_GraveZebra", 0 , 4	}}
	//			{ "Alterar"     , "U_CDEST08c", 0 , 3	},;
	DbSelectArea("SZN")
	DbSeek(xFilial("SZN"))
	
	mBrowse(001,040,200,390,"SZN",,,,,,)
Return(.T.)


/*/{Protheus.doc} CDEST08a
//TODO Chama a função VISUALIZAR FARDOS/SACARIA.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function CDEST08a()
	cOpcao:= "VISUALIZAR"
	u_CDEST08z(cOpcao)
Return(.T.)

/*/{Protheus.doc} CDEST08b
//TODO Chama a função INCLUIR FARDOS/SACARIA.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function CDEST08b()
	cOpcao:= "INCLUIR"
	u_CDEST08z(cOpcao)
Return(.T.)


/*/{Protheus.doc} CDEST08c
//TODO Chama a função ALTERAR FARDOS/SACARIA.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function CDEST08c()
	cOpcao:="ALTERAR"
	u_CDEST08z(cOpcao)
Return(.T.)


/*/{Protheus.doc} CDEST08d
//TODO Chama a função EXCLUIR FARDOS/SACARIA.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function CDEST08d()
	cOpcao:="EXCLUIR"
	u_CDEST08z(cOpcao)
Return(.T.)


/*/{Protheus.doc} CDEST08z
//TODO Prepara Browse conforme opção escolhida.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@param cOpcao, characters, descricao
@type function
/*/
User Function CDEST08z(cOpcao)
	_aAreaAtu := GetArea()
	If cOpcao=="INCLUIR"
		nOpcE:=3
		nOpcG:=3
		inclui := .T.
		altera := .F.
		exclui := .F.
	ElseIf cOpcao=="ALTERAR"
		nOpcE:=3
		nOpcG:=3
		inclui := .F.
		altera := .T.
		exclui := .F.
	ElseIf cOpcao == "VISUALIZAR"
		nOpcE:=2
		nOpcG:=2
		inclui := .F.
		altera := .F.
		exclui := .F.
	ElseIf cOpcao=="EXCLUIR"
		nOpcE:=5
		nOpcG:=5
		inclui := .F.
		altera := .F.
		exclui := .T.
	EndIf
	aAltEnchoice :={}

	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	
	DbSelectArea("SZN")
	DbSetOrder(1)
	
	_nVols := 0
	_nBobs := 0
	_nCarr := 0
	If cOpcao == "INCLUIR"
		//	_cControl := GetSx8Num("SZN","ZN_CTRLE")
		_cControl := Space(Len("ZN_CTRLE"))
		_cPedi := Space((Len(SZN->ZN_PEDIDO)*5)+4)
		_cRoma := Space(Len(SZN->ZN_ROMANEI))
		_cClie := Space(Len(SA1->A1_COD))
		_cLoja := Space(Len(SA1->A1_LOJA))
		_cNome := Space(Len(SA1->A1_NOME))
	Else
		SC5->(DbSeek(xFilial("SC5")+SZN->ZN_PEDIDO,.F.))
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		_cControl := SZN->ZN_CTRLE
		_cPedi := "" // SZN->ZN_PEDIDO
		_cRoma := SZN->ZN_ROMANEI
		_cClie := SC5->C5_CLIENTE
		_cLoja := SC5->C5_LOJACLI
		_cNome := SA1->A1_NOME
	EndIf
	
	dbSelectArea("SX3")
	DbSetOrder(2)
	aHeader:={}
	nUsado:=0
	DbSeek("ZN_PRODUTO",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_DESCRI ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_ACONDIC",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_QUANT  ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	aHeader[Len(aHeader),6] := "u_ValQtd(.F.)"
	nUsado:=nUsado+1
	
	DbSeek("ZN_QTDORI ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	aHeader[Len(aHeader),1] := "Quantidade"
	nUsado:=nUsado+1
	
	DbSeek("ZN_NUMVOL ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	aHeader[Len(aHeader),6] := "u_ValNmVl()"
	nUsado:=nUsado+1
	
	DbSeek("ZN_PEDIDO ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_ITEM   ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_BOBS   ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	DbSeek("ZN_CARR   ",.F.)
	Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
					x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	nUsado:=nUsado+1
	
	If cOpcao=="INCLUIR"
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.
	Else
		aCols:={}
		dbSelectArea("SZN")
		dbSetOrder(1)
	
		_cControl := SZN->ZN_CTRLE
		_cPedi := "" // SZN->ZN_PEDIDO
		_cRoma := SZN->ZN_ROMANEI
	
		dbSeek(xFilial("SZN")+M->_cControl,.F.)
		_nBobs := SZN->ZN_BOBS
		_nCarr := SZN->ZN_CARR
		_nVols := 0
		Do While SZN->ZN_FILIAL == xFilial("SZN") .And. SZN->ZN_CTRLE == _cControl .And. SZN->(!eof())
			If !SZN->ZN_PEDIDO $ _cPedi
				If !Empty(_cPedi)
					_cPedi := _cPedi + ","
				EndIf
				_cPedi := AllTrim(_cPedi) + SZN->ZN_PEDIDO
			EndIf
	
			_nVols := Max(_nVols,SZN->ZN_NUMVOL)
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.T.
			dbSkip()
		EndDo
	Endif
	_lRet:= .F.
	_lGrava := .F.
	aButtons := {}
	If Len(aCols)>0
		cTitulo        := "Montagem de Volumes"
		cAliasEnchoice := ""
		cAliasGetD     := "SZN"
		cLinOk         := "AllwaysTrue()"// "U_ACMD2LINOK()" // "U_ACMD2LINOK()" //"AllwaysTrue()"
		cTudOk         := "u_ConfTd()" // "AllwaysTrue()"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice   := {}
		_lRet:=u_Janela5(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
	Endif
	
	If cOpcao == "INCLUIR"
		If _lRet .And. _lGrava
			ConfirmSx8()
		Else
			RollBackSx8()
		EndIf
	EndIf
	If _lRet .And. cOpcao $ "INCLUIR//ALTERAR"  .And. _lGrava
	
		DbSelectArea("SZN")
		DbSetOrder(1) // ZN_FILIAL+ZN_CTRLE
	
		//	If DbSeek(xFilial("SZN") + _cControl,.F.)
		//		_cRoma := SZN->ZN_ROMANEI
		//	Else
		//		_cRoma := "   "
		//	EndIf
		Do While DbSeek(xFilial("SZN") + _cControl,.F.)
			RecLock("SZN",.F.)
			For _j := 1 To FCount()
				_MyVar := FieldGet(_j)
				If ValType(_MyVar) == "N"
					_MyVar := 0
				ElseIf ValType(_MyVar) == "C"
					_MyVar := " "
				ElseIf ValType(_MyVar) == "L"
					_MyVar := .F.
				ElseIf ValType(_MyVar) == "D"
					_MyVar := Ctod("  /  /  ")
				EndIf
				FieldPut(_j,_MyVar)
			Next
			SZN->ZN_FILIAL := "@@"
			MsUnLock()
		EndDo
	
		For _j := 1 to Len(aCols)
			If SZN->(DbSeek("@@",.F.))
				RecLock("SZN",.F.)
			Else
				RecLock("SZN",.T.)
			EndIf
			For AC:=1 to Len(aHeader)
				FieldPut(FieldPos(ALLTRIM(aHeader[AC,2])),aCols[_j,AC])
			Next
			SZN->ZN_FILIAL  := xFilial("SZN")
			SZN->ZN_CTRLE   := _cControl
			SZN->ZN_ROMANEI := _cRoma
			SZN->ZN_BOBS	:= _nBobs
			SZN->ZN_CARR    := _nCarr
			SZN->ZN_STATUS  := " "
			MsUnLock()
			DbSelectArea("SZN")
		Next
	
		u_GraveZebra()
	
	ElseIf _lRet .And. cOpcao == "EXCLUIR"
		DbSelectArea("SZN")
		DbSetOrder(1) // ZN_FILIAL+ZN_CTRLE
		Do While SZN->(DbSeek(xFilial("SZN") + _cControl,.F.))
			RecLock("SZN",.F.)
			DbDelete()
			MsUnLock()
		EndDo
	EndIf
	RestArea(_aAreaAtu)
Return(_lRet)

/*/{Protheus.doc} Janela5
//TODO Criação do browser.
@author Roberto Oliveira
@since 27/11/2017
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
User Function Janela5(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
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
	nGetLin := aPosObj[3,1]

	Private oDlg,oGetDados
	//Private Altera:=.T.,Inclui:=.F.,lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,999,nLinhas)


	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	@ 035,005 Say "Controle.: " Size 30,10
	@ 035,040 Get _cControl Picture "999999" Object _oCtrl When .F.  Size 40,10

	@ 035,085 Say "Pedido/O.S.: " Size 30,10
	@ 035,120 Get _cPedi When Inclui .And. Empty(_cRoma) Valid If(u_ValCpo(1),u_BuscaPed(1),.F.) Size 30*If(Len(_cPedi)>10,5,1),10 Object _ocPed

	@ 035,370 Say "Nr. Carga...: " Size 30,10
	@ 035,420 Get _cRoma When Inclui .And. Empty(_cPedi)  Valid If(u_ValCpo(2),u_BuscaPed(2),.F.) Picture "999999" Size 40,10

	@ 050,005 Say "Cliente: " Size 30,10
	@ 050,040 Get _cClie Object _oClie When .F. Size 30,10
	@ 050,085 Say "Loja: "    Size 30,10
	@ 050,120 Get _cLoja Object _oLoja When .F. Size 20,10
	@ 050,175 Say "Nome: "    Size 30,10
	@ 050,210 Get _cNome Object _oNome When .F. Size 150,10

	@ 065,005 Say "Qtd.Bobinas: " Size 30,10
	@ 065,040 Get _nBobs Picture "@E 999,999" Object _o_nBobs When .F. Size 30,10
	@ 065,085 Say "Qtd.Carret.: "    Size 30,10
	@ 065,120 Get _nCarr Picture "@E 999,999" Object _o_nCarrLoja When .F. Size 30,10
	@ 065,175 Say "Qtd.Vols: "    Size 30,10
	@ 065,210 Get _nVols Picture "@E 999,999" Object _o_nVols When .F. Size 30,10
	oGetDados := MsGetDados():New(80,aPosObj[2,2],265,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_Refrex()}

	// Roberto 30/06/15 - Esou alterando esta linha pq está dando erro array out of bounds na
	// MSGETDADOS:CHKOBRIGAT(MSGETDAD.PRW). Em debug, verifiquei que as variáveis aGets e aTela estão vazias.
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
	//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),oDlg:End() ,nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

	lRet:=(nOpca==1)

Return(lRet)

/*/{Protheus.doc} BuscaPed
//TODO Busca Pedido conforme opção escolhida.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@param nRotin, numeric, descricao
@type function
/*/
User Function BuscaPed(nRotin)
	_nBobs := 0
	_nCarr := 0
	_nQtdRegs := 0
	aCols := {}
	
	If nRotin == 1 .And. Empty(_cPedi) // Pedidos de Venda.... lê o SDC
		Return(.T.)
	ElseIf nRotin == 2
		If Empty(_cRoma) // Romaneios ... lê o SDB
			Return(.T.)
		Else
			DbSelectArea("SZN")
			DbSetOrder(4) //ZN_FILIAL+ZN_ROMANEI+ZN_PRODUTO+ZN_ACONDIC
			If DbSeek(xFilial("SZN")+_cRoma,.F.)
				Alert("Romaneio Já Incluido")
				Return(.F.)
			EndIf
		EndIf
	EndIf
	
	If nRotin == 1 	// Pedidos de Venda.... lê o SDC
		Processa( {|| LeiaSDC() },"Lendo Tabela de Liberações...")
		// LEO 29/04/19 - Simular a montagem de volume na nova rotina
		if GetNewPar('ZZ_HOMVOLM', .F.)
			if MsgYesNo('Simular na rotina nova?', 'HOM-Volumes')
				u_zVolMnt(.T.,_cPedi)
			endif
		endif
	Else			// Romaneios ... lê o SDB
		Processa( {|| LeiaSDB() },"Lendo Tabela de Movimentos...")
		_lGrava := .T.
	EndIf
	
	_nPosCod := GDFieldPos("ZN_PRODUTO")
	_nPosAco := GDFieldPos("ZN_ACONDIC")
	_nPosNum := GDFieldPos("ZN_NUMVOL")
	//aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]<y[_nPosCod]+y[_nPosAco].And. x[_nPosNum]<y[_nPosNum]})
	aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
	If Len(aCols) == 0
		Alert("Não há Itens a Serem Ensacados")
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.
	EndIf
	
	Processa( {|| AvalQtd() },"Avaliando Quantidades...")
	
	
	If nRotin == 2 .And. Empty(_cControl) // Inclusão  de nova sacaria
		_cControl := GetSx8Num("SZN","ZN_CTRLE")
	EndIf
	
	aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
	SC5->(DbSeek(xFilial("SC5")+Left(_cPedi,Len(SZN->ZN_PEDIDO)),.F.))
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
	_cClie := SC5->C5_CLIENTE
	_cLoja := SC5->C5_LOJACLI
	_cNome := SA1->A1_NOME
	_ocPed:Refresh()
	_oCtrl:Refresh()
	_oClie:Refresh()
	_oLoja:Refresh()
	_oNome:Refresh()
	_o_nBobs:Refresh()
	_o_nCarrLoja:Refresh()
	_o_nVols:Refresh()
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} Refrex
//TODO Atualiza campos Browser.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function Refrex()
	_ocPed:Refresh()
	_oCtrl:Refresh()
	_oClie:Refresh()
	_oLoja:Refresh()
	_oNome:Refresh()
	_o_nBobs:Refresh()
	_o_nCarrLoja:Refresh()
	_o_nVols:Refresh()
	oGetDados:Refresh()
Return(.T.)

/*/{Protheus.doc} ValQtd
//TODO Valida quantidade informada se é valida coforme pedido.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@param _lAuto, , descricao
@type function
/*/
User Function ValQtd(_lAuto)
	If M->ZN_QUANT > GDFieldGet("ZN_QTDORI",n)
		Alert("Quantidade Maior que a Disponivel para Distribuição")
		Return(.F.)
	EndIf
	If (M->ZN_QUANT - Int(M->ZN_QUANT))> 0
		Alert("Informar Somente Inteiros")
		Return(.F.)
	EndIf
	
	If !_lAuto
		_MaxVol := 0 // Quantidade de volumes
		For _ni := 1 To Len(aCols)
			_MaxVol := Max(_MaxVol,GDFieldGet("ZN_NUMVOL",_ni))
		Next
		_MaxVol++
	EndIf
	_nCriar := 0
	If M->ZN_QUANT == GDFieldGet("ZN_QTDORI",n) // Acertar e criar um novo
		GDFieldPut("ZN_QUANT" ,M->ZN_QUANT,n)
		GDFieldPut("ZN_QTDORI",M->ZN_QUANT,n)
		GDFieldPut("ZN_NUMVOL",_MaxVol,n)
		aCols[n,nUsado+1]:=.T.
	ElseIf M->ZN_QUANT < GDFieldGet("ZN_QTDORI",n) // Acertar e criar um novo
		_nCriar := M->ZN_QUANT
		GDFieldPut("ZN_QUANT" ,0.00,n)
		GDFieldPut("ZN_QTDORI",GDFieldGet("ZN_QTDORI",n)-M->ZN_QUANT,n)
	EndIf
	If _nCriar > 0
		AADD(aCols,Array(nUsado+1))
		For _ni2:=1 to nUsado
			aCols[Len(aCols),_ni2] := aCols[n,_ni2]
		Next
		GDFieldPut("ZN_QUANT"  ,_nCriar,Len(aCols))
		GDFieldPut("ZN_QTDORI" ,_nCriar,Len(aCols))
		GDFieldPut("ZN_NUMVOL" ,_MaxVol,Len(aCols))
		aCols[Len(aCols),nUsado+1]:=.T.
	EndIf
	If !_lAuto
		_nPosCod := GDFieldPos("ZN_PRODUTO")
		_nPosAco := GDFieldPos("ZN_ACONDIC")
		_nPosNum := GDFieldPos("ZN_NUMVOL")
		//aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]<y[_nPosCod]+y[_nPosAco] .And. x[_nPosNum]<y[_nPosNum]})
		aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
		M->ZN_QUANT := GDFieldGet("ZN_QUANT",n)
		_nVols := _MaxVol
		_o_nVols:Refresh()
		oGetDados:Refresh()
	EndIf
Return(.T.)


/*/{Protheus.doc} ValNmVl
//TODO Valida numero de Volumes conforme quantidade original pedido.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function ValNmVl()
	If M->ZN_NUMVOL > 0 .And. GDFieldGet("ZN_QUANT",n) == 0
		GDFieldPut("ZN_QUANT",GDFieldGet("ZN_QTDORI",n),n)
	EndIf
	_MaxVol := 0
	For _ni := 1 To Len(aCols)
		_MaxVol := Max(_MaxVol,GDFieldGet("ZN_NUMVOL",_ni))
	Next
	If M->ZN_NUMVOL > _MaxVol
		M->ZN_NUMVOL := _MaxVol+1
	EndIf
	_nPosCod := GDFieldPos("ZN_PRODUTO")
	_nPosAco := GDFieldPos("ZN_ACONDIC")
	_nPosNum := GDFieldPos("ZN_NUMVOL")
	aCols[n,nUsado+1]:=.T.
	aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
	_nVols := _MaxVol
	oGetDados:Refresh()
	_o_nVols:Refresh()
Return(.T.)

/*/{Protheus.doc} ConfTd
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
User Function ConfTd()
	If cOpcao == "EXCLUIR"
		Return(.T.)
	EndIf
	_nPosCod := GDFieldPos("ZN_PRODUTO")
	_nPosAco := GDFieldPos("ZN_ACONDIC")
	_nPosNum := GDFieldPos("ZN_NUMVOL")
	_aNums := {}
	_lTemVaz := .F.
	For _ni := 1 To Len(aCols)
		_NumVol := GDFieldGet("ZN_NUMVOL",_ni)
		If _NumVol == 0
			_lTemVaz := .T.
			Exit
		EndIf
		If Ascan(_aNums, _NumVol) == 0
			Aadd(_aNums, _NumVol)
		EndIf
	Next
	If _lTemVaz .And. cOpcao # "EXCLUIR"
		aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
		oGetDados:Refresh()
		Alert("Existe Produtos sem Nro.de Volume")
		Return(.F.)
	EndIf
	
	aSort(_aNums,,,{|x,y| x<y})
	aSort(aCols,,,{|x,y| x[_nPosNum]<y[_nPosNum]})
	
	For _ni := 1 to Len(aCols)
		_NumVol := GDFieldGet("ZN_NUMVOL",_ni)
		_nNumPos := Ascan(_aNums, _NumVol)
		GDFieldPut("ZN_NUMVOL",_nNumPos,_ni)
	Next
	
	aSort(aCols,,,{|x,y| x[_nPosCod]+x[_nPosAco]+StrZero(x[_nPosNum],6)<y[_nPosCod]+y[_nPosAco] +StrZero(y[_nPosNum],6)})
	_nVols :=  Len(_aNums)
	_o_nVols:Refresh()
	oGetDados:Refresh()
	Alert("Resumo:" + Chr(13) + "Qtd.Bobinas...: " + Transform(_nBobs,"@E 99,999") + Chr(13) + "Qtd.Carreteis.: " + Transform(_nCarr,"@E 99,999") + Chr(13) + "Qtd.Volumes...: " + Transform(_nVols,"@E 99,999"))
Return(.T.)

/*/{Protheus.doc} LeiaSDC
//TODO Carre SDC do pedido para validação das liberações.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
Static Function LeiaSDC()
	DbSelectArea("SDC")
	//DbSetOrder(4) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	SDC->(DBOrderNickName("SDCPED")) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	
	_aPedi := {}
	_cPedi2 := AllTrim(_cPedi)
	_TamCpo := Len(SZN->ZN_PEDIDO)
	_nQtdRegs := 0
	For _Ctd := 0 To Len(_cPedi2)+1 Step _TamCpo+1
		If _Ctd > 1
			If aScan(_aPedi,Substr(_cPedi2,_Ctd-_TamCpo,Len(SZN->ZN_PEDIDO))) == 0
				AAdd(_aPedi,Substr(_cPedi2,_Ctd-_TamCpo,Len(SZN->ZN_PEDIDO)))
			EndIf
		EndIf
	Next
	
	For _ctd := 1 to Len(_aPedi)
		SDC->(DbSeek(xFilial("SDC") + _aPedi[_ctd],.F.))
		_nRegAt := 0
		Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == _aPedi[_ctd] .And. SDC->(!Eof())
			If SDC->DC_ORIGEM == "SC6"
				_nRegAt++
				_nQtdRegs++
			EndIf
			SDC->(DbSkip())
		EndDo
		If _nRegAt == 0
			Alert("Não há Itens Liberados Para o Pedido " + _aPedi[_ctd])
		EndIf
	Next
	
	ProcRegua(_nQtdRegs)
	For _ctd := 1 to Len(_aPedi)
		If !SDC->(DbSeek(xFilial("SDC") + _aPedi[_ctd],.F.))
			Loop
		EndIf
		Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == _aPedi[_ctd] .And. SDC->(!Eof())
			IncProc()
			If SDC->DC_ORIGEM == "SC6" .And. SDC->DC_LOCAL # "10"
				If Left(SDC->DC_LOCALIZ,1) == "B"
					_nBobs += (SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,5)))
				ElseIf Left(SDC->DC_LOCALIZ,1) $ "CM"
					_nCarr += (SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,5)))
				ElseIf Left(SDC->DC_LOCALIZ,1) $ "RTL"
					For _nN := 1 To Len(aCols)
						If GDFieldGet("ZN_ITEM",_nN)+GDFieldGet("ZN_PRODUTO",_nN)+GDFieldGet("ZN_ACONDIC",_nN) ==;
						SDC->DC_ITEM+SDC->DC_PRODUTO+SDC->DC_LOCALIZ
							Exit
						EndIf
					Next
					If _nN > Len(aCols)
						AADD(aCols,Array(nUsado+1))
						_nN := Len(aCols)
						For _ni:=1 to nUsado
							aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
						Next
						GDFieldPut("ZN_PEDIDO",SDC->DC_PEDIDO,_nN)
						GDFieldPut("ZN_ITEM",SDC->DC_ITEM,_nN)
						GDFieldPut("ZN_PRODUTO",SDC->DC_PRODUTO,_nN)
						GDFieldPut("ZN_ACONDIC",SDC->DC_LOCALIZ,_nN)
						GDFieldPut("ZN_DESCRI",Posicione("SB1",1,xFilial("SB1")+SDC->DC_PRODUTO,"B1_DESC"),_nN)
						GDFieldPut("ZN_QUANT",0,_nN)
						GDFieldPut("ZN_QTDORI",0,_nN)
						aCols[Len(aCols),nUsado+1]:=.F.
					EndIf
					GDFieldPut("ZN_QTDORI",GDFieldGet("ZN_QTDORI",_nN)+(SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,5))),_nN)
				EndIf
			EndIf
			SDC->(DbSkip())
		EndDo
	Next
Return(.T.)

/*/{Protheus.doc} LeiaSDB
//TODO Varre SDB conforme pedido para validação das liberações.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
Static Function LeiaSDB()
	DbSelectArea("SD2")
	DbSetOrder(4) // D2_FILIAL+D2_NUMSEQ
	
	DbSelectArea("SDB")
	DbSetOrder(6) // DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA
	ProcRegua(LastRec())
	
	DbSelectArea("SF2")
	//DBOrderNickName("SF2CDROMA") //F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
	DBOrderNickName("SF2CDCARGA") //F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
	DbSeek(xFilial("SF2")+_cRoma,.F.)
	//Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _cRoma .And. SF2->(!Eof())
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDCARGA == _cRoma .And. SF2->(!Eof())
		DbSelectArea("SDB")
		DbSeek(xFilial("SDB")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
		Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->(!Eof()) .And. ;
		SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
	
			IncProc()
			If SDB->DB_ORIGEM == "SC6" .And. Empty(SDB->DB_ESTORNO)
				If Left(SDB->DB_LOCALIZ,1) == "B"
					_nBobs += (SDB->DB_QUANT / Val(Substr(SDB->DB_LOCALIZ,2,5)))
				ElseIf Left(SDB->DB_LOCALIZ,1) $ "CM"
					_nCarr += (SDB->DB_QUANT / Val(Substr(SDB->DB_LOCALIZ,2,5)))
				ElseIf Left(SDB->DB_LOCALIZ,1) $ "RTL"
	
					SD2->(DbSeek(xFilial("SD2")+SDB->DB_NUMSEQ,.F.))
	
					For _nN := 1 To Len(aCols)
						If GDFieldGet("ZN_PRODUTO",_nN)+GDFieldGet("ZN_ACONDIC",_nN) == SDB->DB_PRODUTO+SDB->DB_LOCALIZ
							Exit
						EndIf
					Next
					If _nN > Len(aCols)
						AADD(aCols,Array(nUsado+1))
						_nN := Len(aCols)
						For _ni:=1 to nUsado
							aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
						Next
						If !SD2->D2_PEDIDO $ _cPedi
							If Len(AllTrim(_cPedi)) > 0
								_cPedi += ","
							EndIf
							_cPedi := AllTrim(_cPedi) + SD2->D2_PEDIDO
						EndIf
						GDFieldPut("ZN_PEDIDO",SD2->D2_PEDIDO,_nN)
						GDFieldPut("ZN_ITEM",SD2->D2_ITEMPV,_nN)
						GDFieldPut("ZN_PRODUTO",SDB->DB_PRODUTO,_nN)
						GDFieldPut("ZN_ACONDIC",SDB->DB_LOCALIZ,_nN)
						GDFieldPut("ZN_DESCRI",Posicione("SB1",1,xFilial("SB1")+SDB->DB_PRODUTO,"B1_DESC"),_nN)
						GDFieldPut("ZN_QUANT",0,_nN)
						GDFieldPut("ZN_QTDORI",0,_nN)
						aCols[Len(aCols),nUsado+1]:=.F.
					EndIf
					GDFieldPut("ZN_QTDORI",GDFieldGet("ZN_QTDORI",_nN)+(SDB->DB_QUANT / Val(Substr(SDB->DB_LOCALIZ,2,5))),_nN)
				EndIf
			EndIf
			SDB->(DbSkip())
		EndDo
		DbSelectArea("SF2")
		DbSkip()
	EndDo
Return(.T.)

/*/{Protheus.doc} AvalQtd
//TODO Avalia quantidade dos volumes conforme pedido e liberações.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0
@type function
/*/
Static Function AvalQtd()
	SB1->(DbSetOrder(1))
	ProcRegua(Len(aCols))
	//_aProds := {Produto,qtd/Saco/Qtd Total)}
	_aProds := {}
	_nTamCls := Len(aCols) // Tenho que pegar a qtd antes de criar novos
	For _QtdLin := 1 To _nTamCls
		IncProc()
		If Left(GDFieldGet("ZN_ACONDIC",_QtdLin),6) == "R00100" // Somente Rolos de 100 metros são distribuidos.. os demais será feito pelo usuario
			_cProd := Left(GDFieldGet("ZN_PRODUTO",_QtdLin),5)
			_nPosPd := aScan(_aProds, {|x|x[1]==_cProd})
			If _nPosPd  == 0
				SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
				_nQtdScs := 0
				Do While SB1->B1_FILIAL == xFilial("SB1") .And. Left(SB1->B1_COD,5) == _cProd .And. SB1->(!Eof())
					If SB1->B1_QTSCS > 0
						_nQtdScs := SB1->B1_QTSCS
						Exit
					EndIf
					SB1->(DbSkip())
				EndDo
				Aadd(_aProds,{_cProd,_nQtdScs,GDFieldGet("ZN_QTDORI",_QtdLin)})
			Else
				_aProds[_nPosPd,3] += GDFieldGet("ZN_QTDORI",_QtdLin)
			EndIf
		EndIf
	Next
	
	_MaxVol := 0
	For _QtdLin := 1 To Len(_aProds)
		//_aProds := {Produto,qtd/Saco/Qtd Total)}
		_nQtdScs := Int(_aProds[_QtdLin,3] / _aProds[_QtdLin,2]) // Quant. de volumes
		If _nQtdScs <= 0
			Loop
		EndIf
		_nQtdSld := _nQtdScs * _aProds[_QtdLin,2] // Quant. total nos volume
		_nQtdVol := 0 // Quant. no volume atual
		For _nCtAcls := 1 To _nTamCls
			If Left(GDFieldGet("ZN_ACONDIC",_nCtAcls),6) == "R00100" // Somente Rolos de 100 metros são distribuidos.. os demais será feito pelo usuario
				If Left(GDFieldGet("ZN_PRODUTO",_nCtAcls),5) == _aProds[_QtdLin,1]
					If _nQtdVol == 0 // Quant. no volume atual
						_nQtdVol := _aProds[_QtdLin,2]// Quant. no volume atual
						_MaxVol++
					EndIf
					_QtdNow := Min(_nQtdVol,GDFieldGet("ZN_QTDORI",_nCtAcls))  // Quantidade Agora
					_QtdNow := Min(_QtdNow,_nQtdSld)
					_nQtdSld -= _QtdNow
					_nQtdVol -= _QtdNow
	
					M->ZN_QUANT := _QtdNow
					n := _nCtAcls
					u_ValQtd(.T.)
					If _nQtdSld == 0
						Exit
					EndIf
					If (GDFieldGet("ZN_QTDORI",_nCtAcls) - GDFieldGet("ZN_QUANT",_nCtAcls)) > 0
						_nCtAcls--
					EndIf
				EndIf
			EndIf
		Next
	Next
	_nVols := _MaxVol
Return(.T.)

/*/{Protheus.doc} ValCpo
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0
@param nRotin, numeric, descricao
@type function
/*/
User Function ValCpo(nRotin)
	_lVolta := .T.
	If nRotin == 1 // Pedidos de Venda
		SC5->(DbSetOrder(1))
		_cCliLoj := " "
		_cPedi2 := AllTrim(_cPedi)
		_TamCpo := Len(SZN->ZN_PEDIDO)
		For _Ctd := 0 To Len(_cPedi2)+1 Step _TamCpo+1
			If _Ctd > 1
				If Substr(_cPedi2,_Ctd,1) # "," .And. (_Ctd # Len(_cPedi2)+1)
					Alert("Usar a Vírgula ',' como separador a cada " + StrZero(_TamCpo,2) + " Dígitos")
					_lVolta := .F.
					Exit
				EndIf
				SC5->(DbSeek(xFilial("SC5")+Substr(_cPedi2,_Ctd-_TamCpo,Len(SZN->ZN_PEDIDO)),.F.))
				If Empty(_cCliLoj)
					_cCliLoj := SC5->C5_CLIENTE+SC5->C5_LOJACLI
				ElseIf _cCliLoj # SC5->C5_CLIENTE+SC5->C5_LOJACLI
					Alert("Pedido " + Substr(_cPedi2,_Ctd+1,Len(SZN->ZN_PEDIDO)) + " Não Pertence ao Mesmo Cliente")
					_lVolta := .F.
					Exit
				EndIf
			EndIf
		Next
	Else // Romaneio
		DbSelectArea("SF2")
		//	DBOrderNickName("SF2CDROMA") //F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
		DBOrderNickName("SF2CDCARGA")
	
		If !DbSeek(xFilial("SF2")+_cRoma,.F.)
			Alert("Nro. Carga Inválido")
			_lVolta := .F.
		EndIf
	EndIf
Return(_lVolta)


User Function CDEST08g()
	Local cDesc1         := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2         := "de acordo com os parâmetros informados pelo usuário."
	Local cDesc3         := ""
	Local cPict          := ""
	
	Private Titulo       := "Relatório p/ Ensaque"
	Private Cabec1       := ""
	Private Cabec2       := ""
	Private imprime      := .T.
	Private aOrd         := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "P"
	Private nomeprog     := "CDEST08g"
	Private nTipo        := 18
	Private nEstru       := 0
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDE08g"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDEST08g"
	Private cString      := "SZN"
	nLin         := 80
	
	ValidPerg()
	pergunte(cPerg,.F.)
	
	DbSelectArea("SZN")
	DbSetOrder(1)
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	Titulo := "Relatorio p/Ensaque "
	nTipo := 18 //If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(.T.)

/*/{Protheus.doc} ValidPerg
//TODO Grupo de Perguntas.
@author juliana.leme
@since 27/11/2017
@version 1.0

@type function
/*/
Static Function ValidPerg()
	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Nro.Ordem de Carga  ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	// Não pode ter De - Até.... somente 1
	
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

/*/{Protheus.doc} RunReport
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	_lImpTrc := .F.
	DbSelectArea("SZN")
	DbSetOrder(3) //ZN_FILIAL+ZN_ROMANEI+STRZERO(ZN_NUMVOL,6)+ZN_PRODUTO+ZN_ACONDIC
	_nTTPeso := 0.00
	
	DbSeek(xFilial("SZN") + MV_PAR01,.T.)
	Do While SZN->ZN_FILIAL == xFilial("SZN") .And. SZN->ZN_ROMANEI == MV_PAR01 .And. SZN->(!Eof())
		nLin := 80
		_cRoma := SZN->ZN_ROMANEI
		_NumVol := SZN->ZN_NUMVOL
		_nTPeso := 0.00
		_nPeso  := 0
		Titulo := "Relat.P/Ensaque-O.Carga : " + SZN->ZN_ROMANEI
		Do While SZN->ZN_FILIAL == xFilial("SZN") .And. SZN->ZN_ROMANEI == _cRoma .And. SZN->(!Eof())
			If nLin > 60 .Or. (nLin == 60 .And. SZN->ZN_NUMVOL # _NumVol)
				If SZN->ZN_NUMVOL # _NumVol .And. _nTPeso # _nPeso
					@ nLin,00 PSAY "|   |                          Peso Total Vol. " + Str(_NumVol,3) + "->                  |"
					@ nLin,71 PSAY _nTPeso Picture "@E 99999.99"
					@ nLin++,79 PSAY "|"
					_nTPeso := 0.00
				EndIf
				If (nLin == 60 .And. SZN->ZN_NUMVOL # _NumVol)
					_NumVol := SZN->ZN_NUMVOL
				EndIf
				If nLin # 80
					@ nLin,001 PSay Replicate("-",78)
				EndIf
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++
				//	@ nLin++,00 PSay "|Volume|Produto    Descricao                               | Acond.|Qtd |Pedido|"
				@ nLin++,00 PSay "|Vol|Produto    Descricao                            |Acond.|Qt|Pedido| Peso Kg|"
				_lImpTrc := .T.
			EndIf
			If SZN->ZN_NUMVOL # _NumVol .Or. _lImpTrc
				If !_lImpTrc
					If _nTPeso # _nPeso
						@ nLin,00 PSAY "|   |                          Peso Total Vol. " + Str(_NumVol,3) + "->                  |"
						@ nLin,71 PSAY _nTPeso Picture "@E 99999.99"
						@ nLin++,79 PSAY "|"
					EndIf
					_nTPeso := 0.00
				EndIf
				_lImpTrc := .F.
				@ nLin++,00 PSay "|---|------------------------------------------------|------|--|------|--------|"
				_NumVol := SZN->ZN_NUMVOL
			EndIf
			
			_nPeso := (SZN->ZN_QUANT * Val(Substr(SZN->ZN_ACONDIC,2,5))) * Posicione("SB1",1,xFilial("SB1")+SZN->ZN_PRODUTO,"B1_PESBRU")
	
			@ nLin,00 PSAY "|"
			@ nLin,01 PSAY SZN->ZN_NUMVOL Picture "999"
			@ nLin,04 PSAY "|" + Left(SZN->ZN_PRODUTO,10) + "-" + Left(u_CortaDesc(SZN->ZN_DESCRI),37)
			@ nLin,53 PSAY "|"
			@ nLin,54 PSAY Left(SZN->ZN_ACONDIC,6)
			@ nLin,60 PSAY "|"
			@ nLin,61 PSAY Int(SZN->ZN_QUANT) Picture "99"
			@ nLin,63 PSAY "|"
			@ nLin,64 PSAY SZN->ZN_PEDIDO
			@ nLin,70 PSAY "|"
			@ nLin,71 PSAY _nPeso Picture "@E 99999.99"
			@ nLin++,79 PSAY "|"
			_nTPeso  += _nPeso
			_nTTPeso += _nPeso
			SZN->(DbSkip())
		EndDo
		If _nTPeso > 0
			@ nLin,00 PSAY "|   |                          Peso Total Vol. " + Str(_NumVol,3) + "->                  |"
			@ nLin,71 PSAY _nTPeso Picture "@E 99999.99"
			@ nLin++,79 PSAY "|"
		EndIf
		@ nLin++,001 PSay Replicate("-",78)
		If _nTTPeso > 0
			@ nLin,53 PSAY "Total Relat. Kg."
			@ nLin,71 PSAY _nTTPeso Picture "@E 99999.99"
		EndIf
	EndDo

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
Return(.T.)

User Function GraveZebra()
	Processa( {|| GraveZba() },"Transferindo Dados para a Impressora Zebra")
Return(.T.)

/*/{Protheus.doc} GraveZba
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0

@type function
/*/
Static Function GraveZba()
	_cNomArq  := ""
	_cNF      := ""
	_cRoman   := SZN->ZN_ROMANEI
	_cControl := SZN->ZN_CTRLE
	CrieTRB()
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	
	DbSelectArea("SDB")
	DbSetOrder(6) // DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA
	
	DbSelectArea("SF2")
	//DBOrderNickName("SF2CDROMA") //F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
	DBOrderNickName("SF2CDCARGA") //F2_FILIAL+F2_CDCARGA+F2_SERIE+F2_DOC
	
	SF2->(DbSeek(xFilial("SF2")+SZN->ZN_ROMANEI,.F.))
	SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
	//Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == SZN->ZN_ROMANEI .And. SF2->(!Eof())
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDCARGA == SZN->ZN_ROMANEI .And. SF2->(!Eof())
		If SDB->(DbSeek(xFilial("SDB")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			If !SF2->F2_DOC $ _cNF .And. SF2->F2_SERIE $ "UNI//1  "
				_cNF := _cNF + AllTrim(SF2->F2_DOC) + ", "
			EndIf
		EndIf
		SF2->(DbSkip())
	EndDo
	
	DbSelectArea("SZN")
	DbSetOrder(1) // ZN_FILIAL+ZN_CTRLE
	_nVolTot := 0
	DbSeek(xFilial("SZN")+_cControl,.F.)
	Do While SZN->ZN_FILIAL == xFilial("SZN") .And. SZN->ZN_CTRLE == _cControl .And. SZN->(!eof())
		_nVolTot := Max(_nVolTot,SZN->ZN_NUMVOL)
	
		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->CONTROL := SZN->ZN_CTRLE
		TRB->NF      := Left(_cNF,Len(_cNF)-2)
		TRB->VOLUME  := StrZero(SZN->ZN_NUMVOL,3)
		TRB->CLIENTE := SA1->A1_NOME
		TRB->CIDADE  := SA1->A1_MUN
		TRB->UF      := SA1->A1_EST
		TRB->DATADIA := dDataBase
		TRB->BOBINA  := SZN->ZN_BOBS
		TRB->CARRET  := SZN->ZN_CARR
		MsUnLock()
		SZN->(DbSkip())
	EndDo
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		RecLock("TRB",.F.)
		TRB->VOLTOT  := StrZero(_nVolTot,3)
		MsUnLock()
		TRB->(DbSkip())
	EndDo
	
	_ArqSai := AllTrim(_cRoman)+".DTC"
	
	//	Rename &(_cNomArq) to &(_ARQsAI)
	//	__CopyFile(_ArqSai,)
	If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom Tres Lagoas
		// Está ocorrendo troca de máquinas da impressora zebra e não estão fazendo o
		// compartilhamento da para o Protheus poder transferir os aquivos para a impressão das etiquetas
		// na ZEBRA.
		// Procedimentos:
		// 	- Em uma máquina da rede, compartilhar uma pasta;
		//  - Nas máquinas que usarão esta rotina para criação de volumes, mapear a pasta acima como
		//    drive "X:";
		//  - Na máquina que efetuará a impressão das etiquetas mapear a mesma pasta como
		//    drive "U:".
		// Na pasta compartilhada, deverá conter pelo menos um arquivo, com qualquer extensão para
		// o sistema poder reconhecer a sua existência.
	
		_lGrava	:= .T.
		Do While .T.
			_lGrava := Array(ADIR("X:\*.*"))
			//ADIR("X:\*.*",_lGrava)
			_lGrava := (Len(_lGrava) > 0)
			If _lGrava  // A pasta existe
				Exit
			EndIf
			If !MsgBox(	"Atenção:" + Chr(13)+;
			"Mapear a pasta como drive X:\ para gravação" + Chr(13)+;
			"do arquivo para a impressão das etiquetas." + Chr(13)+;
			"Confirma -> Pesquisa pasta novamente"  + Chr(13)+;
			"Cancela -> Sai sem efetuar a gravação","Confirma?","YesNo")
				Exit
			EndIf
		EndDo
		If _lGrava
			Copy To "\SYSTEM\FARDMS\"+_ARQsAI
			CPYS2T("\SYSTEM\FARDMS\"+_ARQsAI,"X:\",.F.)      // verificar o que fazer
		EndIf
	Else
		Copy To "\SYSTEM\FARDOS\"+_ARQsAI
	EndIf
	DbSelectArea("TRB")
	DbCloseArea("TRB")
	DbSelectArea("SZN")
Return(.T.)

/*/{Protheus.doc} CrieTRB
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 27/11/2017
@version 1.0
@type function
/*/
Static Function CrieTRB()
	_aCampos := {}
	aAdd(_aCampos, {"CONTROL", "C", 06, 0})
	aAdd(_aCampos, {"NF"     , "C", 30, 0})
	aAdd(_aCampos, {"VOLUME" , "C", 03, 0})
	aAdd(_aCampos, {"VOLTOT" , "C", 03, 0})
	aAdd(_aCampos, {"CLIENTE", "C", 40, 0})
	aAdd(_aCampos, {"CIDADE" , "C", 30, 0})
	aAdd(_aCampos, {"UF"     , "C", 02, 0})
	aAdd(_aCampos, {"DATADIA", "D", 02, 0})
	aAdd(_aCampos, {"BOBINA" , "N", 04, 0})
	aAdd(_aCampos, {"CARRET" , "N", 04, 0})
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIf
	
	_cNomArq := AllTrim(CriaTrab(_aCampos, .T.))
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)
Return(.T.)