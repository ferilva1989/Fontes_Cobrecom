#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include 'protheus.ch'
#include "TOTVS.CH"

/*/{Protheus.doc} CDEST01 
//TODO Rotina liberação de pedidos de venda, com priorização .
@author Edvar Vassaitis
@since 09/11/10
@version 1.0

@type function
/*/
User Function CDEST01()
	local oAcl			:= cbcAcl():newcbcAcl()
	
	if !oAcl:aclValid('LibEmpPedido')
		Alert("Usuário não possui Acesso a Rotina de Liberações/Empenhos de Pedidos!")
		Return(.T.)
	else
		If "RENE" == Upper(AllTrim(cUserName)) .And. xFilial("SDC") == "01"
			Alert("Rene - Atenção a Filial ao Liberar")
			//Return(.T.)
		EndIf	

		Processa({|lEnd| u_DepuSDC()}, 'Analisando Reservas...')
	
		_lMult := .F.
		cCadastro := "Ordem de Separação"
	
		aCores    := {{"Empty(C9_BLCRED) .And. Empty(C9_BLEST)","ENABLE"  },;  // Verde - Liberado
		{"(C9_BLCRED == '01'.OR.!Empty(C9_BLCRED)) .and. C9_BLCRED <> '10'","BR_AZUL" },;  // Azul  - Bloqueado por Crédito
		{"C9_BLCRED == '09'"                     ,"BR_CINZA"},;  // Cinza - Credito rejeitado
		{"C9_BLEST  == '02'"                     ,"BR_PRETO"},;  // Preto - Bloqueado por Estoque
		{"C9_BLEST  == '10'"                     ,"DISABLE"}}    // Vermelho - Faturado
	
		aRotina := DefMenu()
	
		DbSelectArea("SC9")
		DbSetOrder(1)
		DbSeek(xFilial("SC9"))
	
		mBrowse(001,040,200,390,"SC9",,,,,,aCores)
	
		If Select("TRB")>0
			DbSelectArea("TRB")
			DbCloseArea()
		EndIf
		DbSelectArea("SC9")	
	endif
Return(.T.)


/*/{Protheus.doc} CDEST01L
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function CDEST01L()
	local aCanCancel  := {}
	local cExpedindo  := ''
	Local oStatic     := IfcXFun():newIfcXFun()
	Private _cCodDesc := ""  // este
	Private _cCliente := ""
	Private _cQtdEst  := ""
	Private _cQtdRes  := ""
	Private _cQtdLib  := ""
	Private _cQtdDisp := ""
	Private _cRota    := ""
	Private _aMultipl := {} // Variável para controle das Liberações Múltiplas
	Private _aCpaCols := {} // Cópia do aCols
	Private _aCpaHead := {} // Cópia do aHeader
	Private _aCpaN    := 0  // Cópia de N
	Private _lGeral := .F.
	Private cPerg := "CDES01"
	
	//Verifica se a rotina de liberação não está sendo executada.
	//_aAccess := u_CtrlAccess("B","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
	//Bloqueia Rotina em uso
	If !LockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		Return
	EndIf
	
	/*If !_aAccess[1]
		Alert("Processo Interrompido -> Rotina em Uso por " + AllTrim(_aAccess[2]))
		Return(.T.)
	EndIf*/
	if !validAcess(xFilial("SC9"))
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Permissão Negada!")		
		return(nil)
	endif
	ValidPerg()
	Do While .T.
		If !Pergunte(cPerg,.T.)
			// Libera o acesso a rotina
			//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
			Return(.T.)
		ElseIf xFilial("SC6") == "02" .And. MV_PAR13 == 1
			If MsgBox("Confirma a Liberação do Armazém 10 (Industrialização) ?","Confirma?","YesNo")
				Exit
			EndIf
		Else
			Exit
		EndIf
	EndDo

	Private cCbTpLib   := ""
	Private cCbStatus  := ""
	Private _cCondPag  := ""

	Private nOpcE  := 2
	Private nOpcG  := 2
	inclui := .F.
	altera := .T.
	exclui := .F.
	aAltEnchoice :={}

	nUsado:=0
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SZ5")
	aHeader:={}
	Do While !Eof().And.(X3_ARQUIVO=="SZ5")

		If X3USO(X3_USADO) .And. cNivel>=X3_NIVEL .And. !AllTrim(X3_CAMPO)$"Z5_FILIAL,Z5_CLIENTE,Z5_LOJA,Z5_NREDUZ,Z5_DESC"
			nUsado:=nUsado+1
			aAdd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VLDUSER,;
			X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
		EndIf
		DbSkip()
	EndDo

	_cInd := " "
	_cNomArq := CrieTRB(1,_lGeral)

	_lVerVol := .T.
	//If GetMv("MV_ZZUSAC9")
	// Verificar se o pedido já não está em faturamento ou se tem volumes -> Avisar o Usuário que o
	// status do pedido retornará para Normal e os volumes serão cancelados.
	DbSelectArea("TRB")
	DbGoTop()
	_cPedsOk := ""
	_cPedBad := ""
	_cPedVol := ""
	Do While TRB->(!Eof())
		If !TRB->PEDIDO$_cPedsOk
			_cPedsOk := _cPedsOk + "//" + TRB->PEDIDO
			DbSelectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+TRB->PEDIDO,.F.)
			If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) // Em faturamento
				_cPedBad := _cPedBad + TRB->PEDIDO + ", "
			EndIf
			aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(TRB->PEDIDO))
			if !aCanCancel[01]
				cExpedindo += Chr(13) + "Pedido: " + AllTrim(TRB->PEDIDO) + ' - ' + aCanCancel[02]
			endif
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	if !empty(cExpedindo)
		MsgAlert("Atenção: " + Chr(13) +;
					cExpedindo, 'Bloqueado')
	else
		If !Empty(_cPedBad)
			_lVerVol := MsgBox("O(s) pedido(s) " + _cPedBad + "estão EM FATURAMENTO, serão colocados NORMAL e os volumes serão ESTORNADOS","Confirma?","YesNo")
		EndIf
		//EndIf

		aCols := {}
		_i    := 0
		DbSelectArea("SZ5")
		DbSelectArea("TRB")
		DbGoTop()
		Do While TRB->(!Eof()) .And. _lVerVol

			aAdd(aCols,Array(nUsado+1))
			_i++

			GDFieldPut("Z5_PEDIDO" ,TRB->PEDIDO ,_i)
			GDFieldPut("Z5_ITEM"   ,TRB->ITEM   ,_i)
			GDFieldPut("Z5_SEQUEN" ,TRB->SEQUEN ,_i)
			GDFieldPut("Z5_PRODUTO",TRB->PRODUTO,_i)
			GDFieldPut("Z5_ACONDIC",TRB->ACONDIC,_i)
			GDFieldPut("Z5_LANCES" ,TRB->LANCES ,_i)
			GDFieldPut("Z5_METRAGE",TRB->METRAGE,_i)
			GDFieldPut("Z5_ENTREG" ,TRB->ENTREG ,_i)
			GDFieldPut("Z5_QTDVEN" ,TRB->QTDVEN ,_i)
			GDFieldPut("Z5_QTDALIB",TRB->QTDALIB,_i)
			GDFieldPut("Z5_QTDLIB" ,If(TRB->RESERVA	=="S",TRB->QTDALIB,CriaVar(aHeader[GDFieldPos("Z5_QTDLIB"),2])),_i)
		
			If Posicione("SB1",1,xFilial("SB1")+TRB->PRODUTO,"B1_LOCALIZ") == "S"
				GDFieldPut("Z5_LOCALIZ",Left((TRB->ACONDIC + StrZero(TRB->METRAGE,5) + Space(20)),Len(SZ5->Z5_LOCALIZ)),_i)
			Else
				GDFieldPut("Z5_LOCALIZ", Padr(" ",TamSX3("BF_LOCALIZ")[1]),_i)
			EndIf

			GDFieldPut("Z5_LOCAL"  ,TRB->LOCAL,_i)
			GDFieldPut("Z5_RESERVA",TRB->RESERVA,_i)
			aCols[Len(aCols),nUsado+1]:=.F.

			DbSelectArea("TRB")
			DbSkip()

		EndDo

		DbSelectArea("TRB")
		DbCloseArea("TRB")

		Delete File(_cNomArq+".DTC")
		Delete File(_cInd+OrdBagExt())

		_Par01 := MV_PAR01 //Fiz isto pq MV_PAR01 está retornando com tipo diferente......pois no relatório é outra coisa
		_lRet:= .F.
		aButtons := {}
		If Len(aCols)>0
			cTitulo        := "Ordem de Separação"
			cAliasEnchoice := ""
			cAliasGetD     := "SZ5"
			cLinOk         := "u_ValLin(.F.)"
			cTudOk         := "AllwaysTrue()"
			cFieldOk       := "U_Refresh()"
			aCpoEnchoice   := {}
			_lRet:=u_Janela3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
		Else
			Alert("Não existem Pedidos de Vendas a serem Liberados! Verifique a configuração dos parâmetros!")
		Endif
		If _lRet
			If MV_PAR01 == MV_PAR02
				dbSelectArea("SC5")
				dbSetOrder(1)//C5_FILIAL+C5_NUM
				If dbSeek(xFilial("SC5")+MV_PAR01,.F.)
					If SC5->C5_TIPOLIB <> cCbTpLib
						RecLock("SC5",.F.)
						SC5->C5_TIPOLIB := cCbTpLib // Manual / Priorizado / Normal
						MsUnlock()
					EndIf
				EndIf
				
				dbSelectArea("SA1")
				dbSetOrder(1)
				If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
					RecLock("SA1",.F.)
					If FWCodFil() == "01"
						SA1->A1_ROTA := _cRota
					Else
						SA1->A1_ROTA3L := _cRota
					EndIf
					MsUnlock()
				EndIf
				
			EndIf

			Processa({|lEnd| CDEST01G()}, 'Gravando Liberações...')

			If MV_PAR01 == MV_PAR02
				/*
				DbSelectArea("SC5")
				DbSetOrder(1) //C5_FILIAL+C5_NUM
				If dbSeek(xFilial("SC5")+MV_PAR01,.F.) // -OK .And. !GetMv("MV_ZZUSAC9")
					If SC5->C5_ZSTATUS <> Padr(cCbStatus,TamSX3("C5_ZSTATUS")[1])
						If cCbStatus == "2" .And. FWCodFil() == "01"
							// Verificar se pode alterar o Status para Em Faturamento
							If !u_ValQtdFat(SC5->C5_NUM)
								Alert("Status Alterado para 1-Em Separação " + Chr(13) + "Pedido fora da regra para faturamento")
								cCbStatus := "1"
							EndIf
						EndIf
						RecLock("SC5",.F.)
						SC5->C5_ZSTATUS  := cCbStatus // 0=Normal;1=Em Separacäo;2=Em Faturamento
						MsUnlock()
					EndIf
				EndIf
				*/
				u_zLimpaOS(MV_PAR01,cCbStatus)
				If MsgBox("Imprime Ordem de Separação ?","Confirma?","YesNo")
					u_CBCOrSep(MV_PAR01)
				EndIf
			EndIf
		EndIf
	endif
	// Libera o acesso a rotina
	//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
	UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
	
	
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek(xFilial("SC9")+_Par01,.T.)

Return(.T.)


/*/{Protheus.doc} Janela3
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
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
User Function Janela3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
	Local aArea    := GetArea()
	Local aAreaC5
	Local aAreaX3
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
	Local aSize      := {}
	Local aPosObj    := {}
	Local aObjects 	 := {}
	Local aInfo 	 := {}
	Local oCombo     := Nil
	Local aCbTpLib   := {}
	Local aCbStatus  := {}
	Local nPosTpLib  := 0
	Local nPosStatus := 0
	Local cbSX3TpLib := ""
	Local cbSX3Stat  := ""

	dbSelectArea("SC5")
	aAreaC5  := GetArea()
	dbSelectArea("SX3")
	aAreaX3  := GetArea()

	dbSelectArea("SC5")
	dbSetOrder(1)//C5_FILIAL+C5_NUM
	If dbSeek(xFilial("SC5")+MV_PAR01,.F.) // -OK .And. !GetMv("MV_ZZUSAC9")
		cCbTpLib   := SC5->C5_TIPOLIB
		cCbStatus  := SC5->C5_ZSTATUS
	EndIf

	dbSelectArea("SX3")
	dbSetOrder(2)

	If dbSeek("C5_TIPOLIB",.F.)
		cbSX3TpLib := AllTrim(X3Cbox())
	EndIf

	If dbSeek("C5_ZSTATUS",.F.)
		cbSX3Stat := '0=Normal;1=Em Separacao;2=Em Faturamento'
	EndIf
	//Joga conteudo do Campo para um array
	aCbTpLib   := STRTOKARR(cbSX3TpLib,";")
	aCbStatus  := STRTOKARR(cbSX3Stat,";")

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
	Private Altera:=.T.,Inclui:=.F.,lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,99,nLinhas)

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	DbSelectArea("SZ5")

	@ 045,005 Say "Cliente: " Size 50,10 OF oDlg PIXEL
	@ 045,040 Get _cCliente Object _oCliente When .F. Size 175,10

	@ 045,220 Say "Rota: " Size 50,10 OF oDlg PIXEL
	@ 045,245 Get _cRota Object _oRota F3 "SZK" Valid ExistCpo("SZK",_cRota) Size 50,10

	@ 060,005 Say "Produto: " Size 60,10 OF oDlg PIXEL
	@ 060,040 Get _cCodDesc Object _oCodDesc When .F. Size 175,10

	@ 075,005 Say "Estoque: " Size 60,10 OF oDlg PIXEL
	@ 075,040 Get _cQtdEst  Object _oQtdEst  When .F. Size 50,10
	@ 075,105 Say "Reservado: " Size 60,10 OF oDlg PIXEL
	@ 075,140 Get _cQtdRes  Object _oQtdRes  When .F. Size 50,10
	@ 075,220 Say "Liberado: " Size 60,10 OF oDlg PIXEL
	@ 075,245 Get _cQtdLib  Object _oQtdLib  When .F. Size 50,10
	@ 075,305 Say "Disponível: " Size 60,10 OF oDlg PIXEL
	@ 075,355 Get _cQtdDisp Object _oQtdDisp When .F. Size 50,10

	@ 045,305 Say "Tipo Liberação: "  Size 60,10 OF oDlg PIXEL
	@ 045,355 COMBOBOX cCbTpLib ITEMS aCbTpLib SIZE 50,10 OF oDlg PIXEL

	// By Roberto Oliveira 03/08/16 - Inicio
	_cMyStat := "????"
	For _nStat := 1 to Len(aCbStatus)
		If 	left(aCbStatus[_nStat],1) == left(cCbStatus,1)
			_cMyStat := AllTrim(Substring(aCbStatus[_nStat],Len(cCbStatus)+1,30))
			Exit
		EndIf
	Next
	@ 060,305 Say "Status: "  Size 60,10 OF oDlg PIXEL
	@ 060,355 Get _cMyStat When .F. Size 50,10 OF oDlg PIXEL
	@ 045,420 Get _cCondPag  Object _oCondPag  When .F. Size 60,10

	oGetDados := MsGetDados():New(90,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_Refresh()}

	aAdd(aButtons,{"CRITICA"   ,{|| Estoques() }  , "Estoque Detalhado"})
	aAdd(aButtons,{"EDITABLE"  ,{|| LibAll(.T.) } , "Libera Tudo"})
	aAdd(aButtons,{"S4WB005N"  ,{|| LibMult() }   , "Liberação Múltipla"})

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

	lRet:=(nOpca==1)

	RestArea(aAreaX3)
	RestArea(aAreaC5)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} CDEST01G
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function CDEST01G()
	local nQtdLibs	  := 0
	local nX		  := 0
	Private _nQtdLib  := 0
	Private _cLocal   := ""
	Private _cLocaliz := ""
	Private _cPedido  := ""
	Private _cItem    := ""
	Private _cSequen  := ""
	Private _cProduto := ""

	For _i := 1 to Len(_aMultipl)
		If _aMultipl[_i,2] > 0
			_nPosCols := 0
			//Procuro por um no 1ro. acols
			For _x := 1 to Len(aCols)
				If GDFieldGet("Z5_PRODUTO",_x) == _aMultipl[_i,5] .And. GDFieldGet("Z5_LOCAL",_x) == _aMultipl[_i,4] .And. ;
				GDFieldGet("Z5_LOCALIZ",_x) == _aMultipl[_i,3] .And. !GDDeleted(_x)
					_nPosCols := _x
					Exit
				EndIf
			Next
			If _nPosCols == 0
				aAdd(aCols,Array(nUsado+1))
				_nPosCols := Len(aCols)
				For _nCv := 1 to Len(aCols[_nPosCols])-1
					aCols[_nPosCols,_nCv] := CriaVar(aHeader[_nCv,2])
				Next
				aCols[Len(aCols),nUsado+1]:=.F.
				GDFieldPut("Z5_PEDIDO" ,_aMultipl[_i,6],_nPosCols)
				GDFieldPut("Z5_ITEM"   ,_aMultipl[_i,7],_nPosCols)
				GDFieldPut("Z5_SEQUEN" ,_aMultipl[_i,8],_nPosCols)
				GDFieldPut("Z5_PRODUTO",_aMultipl[_i,5],_nPosCols)
				GDFieldPut("Z5_LOCALIZ",Left((_aMultipl[_i,3] + Space(20)),Len(SZ5->Z5_LOCALIZ)),_nPosCols)
				GDFieldPut("Z5_LOCAL"  ,_aMultipl[_i,4],_nPosCols)
			EndIf
			_TotLin := GDFieldGet("Z5_QTDLIB",_nPosCols)+_aMultipl[_i,2]
			GDFieldPut("Z5_QTDLIB" ,_TotLin,_nPosCols)
		EndIf
	Next

	_cPedsOk := ""
	For _i := 1 To Len(aCols)
		// Foi liberado mais alguma coisa
		_cPedido  := GDFieldGet("Z5_PEDIDO",_i)
		DbSeek(xFilial("SC5")+_cPedido,.F.)
		If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) .And. !_cPedido $ _cPedsOk // Em faturamento
			_cPedsOk := _cPedsOk + "//" + _cPedido
			_cC5Seq  := SC5->C5_X_ULTOS
			u_EstZZRZZO(_cPedido,_cC5Seq)
			RecLock("SC5",.F.)
			SC5->C5_ZSTATUS := "1"// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
			MsUnLock()
		EndIf
	Next

	For _i := 1 To Len(aCols)
		_nQtdLib  := GDFieldGet("Z5_QTDLIB",_i)
		_cLocal   := GDFieldGet("Z5_LOCAL",_i)
		_cLocaliz := GDFieldGet("Z5_LOCALIZ",_i)
		_lCtrlLiz := (Posicione("SB1",1,xFilial("SB1")+GDFieldGet("Z5_PRODUTO",_i),"B1_LOCALIZ") == "S")

		If !GDDeleted(_i) .And. _nQtdLib > 0 .And. !Empty(_cLocal) .And. ((!Empty(_cLocaliz) .And. _lCtrlLiz) .Or. (Empty(_cLocaliz) .And. !_lCtrlLiz))

			_cPedido  := GDFieldGet("Z5_PEDIDO",_i)
			_cItem    := GDFieldGet("Z5_ITEM",_i)
			_cSequen  := GDFieldGet("Z5_SEQUEN",_i)
			_cProduto := GDFieldGet("Z5_PRODUTO",_i)
			DbSelectArea("SC5")
			DbSetOrder(1)
			_cStatus := ""
			If DbSeek(xFilial("SC5")+_cPedido,.F.)
				If SC5->C5_ZSTATUS < "1"  //-OK .And. !GetMv("MV_ZZUSAC9") // No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
					RecLock("SC5",.F.)
					SC5->C5_ZSTATUS := "1"// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
					MsUnLock()
				EndIf
			EndIf
			If SC5->C5_ZSTATUS == Padr('1',TamSX3("C5_ZSTATUS")[1]) //- OK .And. !GetMv("MV_ZZUSAC9")// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
				_cStatus := "1"
			EndIf

			/*/
			// Atenção.. Se o armazem da liberação for diferente do armazem do C9, tem que
			// alterar no SB2 o B2_QPEDVEN, tirando do B2/armazem do C9 e somando no B2/armazem da liberação

			SC9->(DbSetOrder(1))  //C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+C9_PRODUTO
			If SC9->(DbSeek(xFilial("SC9")+_cPedido+_cItem+_cSequen+_cProduto,.F.))
			_nQtdTrc := 0
			If SC9->C9_LOCAL # _cLocal
			//EstTRCLc(Armazem De, Armazem Para,Quantidade)
			EstTRCLc(SC9->C9_LOCAL,_cLocal     ,Min(_nQtdLib,SC9->C9_QTDLIB))
			EndIf
			EndIf
			/*/
			// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
			// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
			// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
			if AllTrim(SC5->C5_ZAGLUTI) == 'I'
				if _lCtrlLiz
					nQtdLibs := (_nQtdLib / Val(AllTrim(Substr(_cLocaliz, 2, len(_cLocaliz)))))
				else
					nQtdLibs := _nQtdLib
				endif
				for nX := 1 to nQtdLibs
					U_CDLibEst("L",_cProduto,(_nQtdLib / nQtdLibs),_cLocal,_cLocaliz,_cPedido,_cItem,_cSequen,.F.,_cStatus,"1")
					_cSequen := getC9Seq(_cPedido,_cItem)
				next nX
			else
				U_CDLibEst("L",_cProduto,_nQtdLib,_cLocal,_cLocaliz,_cPedido,_cItem,_cSequen,.F.,_cStatus,"1")
			endif

		EndIf
	Next

Return(.T.)


/*/{Protheus.doc} CDLibEst
//TODO Descrição auto-gerada.
	_cOpcao: L=Liberar ou E=Estornar       lRegis=Usa o mesmo registro do SDC
@author Roberto
@since 29/08/2017
@version 1.0
@param _cOpcao, , descricao
@param _cProduto, , descricao
@param _nQtdLib, , descricao
@param _cLocal, , descricao
@param _cLocaliz, , descricao
@param _cPedido, , descricao
@param _cItem, , descricao
@param _cSequen, , descricao
@param lRegis, logical, descricao
@param _cStatus, , descricao
@param _cTpLib, , descricao
@param _lFat, , descricao
@type function
/*/
User Function CDLibEst(_cOpcao,_cProduto,_nQtdLib,_cLocal,_cLocaliz,_cPedido,_cItem,_cSequen,lRegis,_cStatus,_cTpLib,_lFat)
	default cNxtSeq := ""
	
	If Valtype(_lFat) == "U" // Esta rotina foi chamada pela de faturamento, CSFATUR ???
		_lFat := .F.
	EndIf

	// Se for uma liberação, verificar se não tem reserva com origem SDC para esse item e estornar.
	If _cOpcao == "L"
		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

		DbSelectArea("SB2")
		DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

		DbSelectArea("SDC")
		DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		Do While SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SDC"+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
			If RecLock("SDC",.F.)
				SBF->(DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))
				RecLock("SBF",.F.) // dou o reclock antes pra garantir BF_QUANT E BF_EMPENHO
				SBF->BF_EMPENHO := SBF->BF_EMPENHO - SDC->DC_QUANT
				SBF->(MsUnLock())

				SB2->(DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.))
				RecLock("SB2",.F.)
				SB2->B2_RESERVA := SB2->B2_RESERVA - SDC->DC_QUANT
				SB2->(MsUnLock())

				SDC->(DbDelete())
				SDC->(MsUnLock())
			EndIf
		EndDo
	EndIf

	_xSeek := If(xFilial("SDC") == "01","ZZ","ZW")

	If Valtype(lRegis) == "U"
		lRegis := .F.
	EndIf
	If Valtype(_cStatus) == "U"
		_cStatus := ""
	EndIf
	If Valtype(_cTpLib) == "U"
		_cTpLib := "X"
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cProduto,.F.)
	_lLocaliz := (SB1->B1_LOCALIZ == "S")

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+C9_PRODUTO
	DbSeek(xFilial("SC9")+_cPedido+_cItem+_cSequen+_cProduto,.F.)

	DbSelectArea("SC6")
	DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO
	If DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
		DbSelectAreA("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
		If SF4->F4_ESTOQUE == "N"
			Return(.F.)    //interrompe a liberação ou estorno
		EndIf
	EndIf


	If !Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ)  .And. !_lFat // o que fazer aqui?????

		/*
		Atenção:

		Este bloco de programação é exclusivamente refetente a
		reserva feita na tabela SZZ através de rotina própria.

		Ela somente muda o "dono" da quantidade reservada para o SZZ ou SC9.

		As quantidades no SB2->B2_RESERVA e SBF->BF_EMPENHO não podem ser alteradas
		pois só se pode liberar essas quantidades se a reserva for cancelada.
		*/

		SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		SZZ->(DbSeek(xFilial("SZZ") + SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ,.F.))

		// Tem Liberar ou estornar todos os SC9 desse item
		// Verifica se as quantidades batem
		_nC9NLibe := 0 // Quantidade não liberada
		_nC9Liber := 0 // Quantidade Liberada
		_nQtdSC9  := 0 // Quanto Registros tem ?
		SC9->(DbSeek(xFilial("SC9")+_cPedido+_cItem,.F.))
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == _cPedido+_cItem .And. SC9->(!Eof())
			If Empty(SC9->C9_BLEST)  // Está Liberado
				_nC9Liber += SC9->C9_QTDLIB
				_nQtdSC9++
			ElseIf SC9->C9_BLEST == "02" // Está bloqueado
				_nC9NLibe += SC9->C9_QTDLIB
				_nQtdSC9++
			EndIf
			SC9->(DbSkip())
		EndDo
		If (_nC9NLibe > 0 .And. _nC9Liber > 0) .Or. (_nC9NLibe+_nC9Liber) # SZZ->ZZ_QUANT
			Return(.F.)    //interrompe a liberação ou estorno
		EndIf

		// Se for pra liberar e não tem nada bloqueado ou
		// Se for pra estornar e não tem nada liberado -> cai fora
		If (_cOpcao == "L" .And. _nC9NLibe == 0.00) .Or. (_cOpcao == "E" .And. _nC9Liber == 0.00)
			Return(.F.)    //interrompe a liberação ou estorno
		EndIf
		If _nQtdSC9 > 1 // Se tiver + de uma Liberação
			_nQtdSC9 := 1
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == _cPedido+_cItem .And. SC9->(!Eof())
				If _cOpcao == "L" .And. SC9->C9_BLEST == "02" // Se estou liberando, então está Bloqueado
					RecLock("SC9",.F.)
					If _nQtdSC9 == 1 // é o primeiro registro
						SC9->C9_QTDLIB := _nC9NLibe
						_nQtdSC9++
					Else
						SC9->(DbDelete())
					EndIf
					MsUnLock()
				ElseIf _cOpcao == "E" .And. Empty(SC9->C9_BLEST) // Se estou estornando, então está liberado
					// Localizo o SDC correspondente
					DbSelectArea("SDC")
					DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
					DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)
					RecLock("SC9",.F.)
					RecLock("SDC",.F.)
					If _nQtdSC9 == 1 // é o primeiro registro
						SC9->C9_QTDLIB  := _nC9NLibe
						SDC->DC_QUANT   := _nC9NLibe
						SDC->DC_QTDORIG := _nC9NLibe
						_nQtdSC9++
					Else
						SC9->(DbDelete())
						SDC->(DbDelete())
					EndIf
					MsUnLockAll()
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf

		RecLock("SZZ",.F.)
		SZZ->ZZ_STATUS := If(_cOpcao == "L","1","0")
		MsUnLock()

		SC9->(DbSeek(xFilial("SC9")+_cPedido+_cItem,.F.))
		If _cOpcao == "L"
			// Procurar um SDC do SZZ -> Deletar
			// Criar    um SDC do SC9 e alterar C9_BLBEST
			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+
			// DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
			If DbSeek(xFilial("SDC") + SZZ->ZZ_PRODUTO + SZZ->ZZ_LOCAL + "SZZ" + SZZ->ZZ_NUM + SZZ->ZZ_ITEM,.F.)
				RecLock("SDC",.F.)
				DbDelete()
				MsUnLock()
			EndIf

			RecLock("SDC",.T.)
			SDC->DC_FILIAL  := xFilial("SDC")
			SDC->DC_ORIGEM  := "SC6"
			SDC->DC_PRODUTO := SC9->C9_PRODUTO
			SDC->DC_LOCAL   := _cLocal
			SDC->DC_LOCALIZ := _cLocaliz
			SDC->DC_QUANT   := SC9->C9_QTDLIB
			SDC->DC_QTDORIG := SC9->C9_QTDLIB
			SDC->DC_TRT     := SC9->C9_SEQUEN
			SDC->DC_PEDIDO  := SC9->C9_PEDIDO
			SDC->DC_ITEM    := SC9->C9_ITEM
			SDC->DC_SEQ     := SC9->C9_SEQUEN
			SDC->DC_DTLIB   := Date()
			SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
			SDC->DC_TPLIB   := _cTpLib
			SDC->DC_STATUS  := If(_cStatus=="1","1"," ")
			MsUnLock()

			RecLock("SC9",.F.)
			SC9->C9_BLEST := "  ";SC9->C9_TPLIB := "R" // É UMA RESERVA
			MsUnLock()
		ElseIf _cOpcao == "E"
			// Procurar o SDC do SC9 -> Deletar e alterar C9_BLBEST
			// Criar    um SDC do SZZ
			RecLock("SC9",.F.)
			SC9->C9_BLEST := "02"
			SC9->C9_TPLIB := " " // É UMA RESERVA
			SC9->C9_STATUS:= "0"
			SC9->C9_SEQOS := "  "
			MsUnLock()
			DbSelectArea("SDC")
			DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
			If DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)

				RecLock("SDC",.F.)
				DbDelete()
				MsUnLock()

				RecLock("SDC",.T.)
				SDC->DC_FILIAL  := xFilial("SDC")
				SDC->DC_ORIGEM  := "SZZ"
				SDC->DC_PRODUTO := SZZ->ZZ_PRODUTO
				SDC->DC_LOCAL   := "01"
				SDC->DC_LOCALIZ := SZZ->ZZ_LOCALIZ
				SDC->DC_QUANT   := SZZ->ZZ_QUANT
				SDC->DC_QTDORIG := SZZ->ZZ_QUANT
				SDC->DC_PEDIDO  := SZZ->ZZ_NUM
				SDC->DC_ITEM    := SZZ->ZZ_ITEM
				SDC->DC_DTLIB   := dDataBase
				SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
				MsUnLock()
			EndIf
		EndIf
		Return(.T.)
	EndIf

	_nQtdExt := 0.00 // Quantidade estornada
	If _lLocaliz // Controla localização?
		If _cOpcao == "L" // .And. !_lFat // (**) // é uma liberação, primeiro reservo no SBF   
			DbSelectArea("SBF")
			DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If DbSeek(xFilial("SBF")+_cLocal+_cLocaliz+_cProduto,.F.)
				RecLock("SBF",.F.) // dou o reclock antes pra garantir BF_QUANT E BF_EMPENHO  // OK - 20/01/16 usar com a variável lFat
				If _nQtdLib  <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0// Ainda tenho a quantidade disponível
					SBF->BF_EMPENHO += _nQtdLib
					MsUnLock()
					DbSelectArea("SB2")
					DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
					DbSeek(xFilial("SB2")+_cProduto+_cLocal,.F.)
					RecLock("SB2",.F.) // OK - 20/01/16 usar com a variável lFat
					SB2->B2_RESERVA := SB2->B2_RESERVA + _nQtdLib
					MsUnLock()
				Else  // Se não tenho quantidade disponivel...
					MsUnLock()
					Return(.F.)    //interrompe a liberação.
				EndIf
			Else
				Return(.F.) // Não achei o SBF então não tenho quantidade para liberar.
			EndIf
		EndIf

		DbSelectArea("SDC")
		DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI

		If _cOpcao == "L"
			If lRegis //Usa o mesmo registro do SDC
				RecLock("SDC",.F.)
				SDC->DC_FILIAL  := xFilial("SDC")
			Else
				RecLock("SDC",.T.)
				SDC->DC_FILIAL  := xFilial("SDC")
				SDC->DC_ORIGEM  := "SC6"
				SDC->DC_PRODUTO := SC9->C9_PRODUTO
				SDC->DC_LOCAL   := _cLocal
				SDC->DC_LOCALIZ := _cLocaliz
				SDC->DC_QUANT   := _nQtdLib
				SDC->DC_QTDORIG := _nQtdLib
				SDC->DC_TRT     := SC9->C9_SEQUEN
				SDC->DC_PEDIDO  := SC9->C9_PEDIDO
				SDC->DC_ITEM    := SC9->C9_ITEM
				SDC->DC_SEQ     := SC9->C9_SEQUEN
			EndIf
			SDC->DC_DTLIB := Date()
			SDC->DC_HRLIB := Left(Time(),Len(SDC->DC_HRLIB))
			SDC->DC_TPLIB := _cTpLib
			SDC->DC_STATUS := If(_cStatus=="1","1"," ")
			MsUnLock()
		Else
			Private _cChave := xFilial("SDC")+_cProduto+_cLocal+"SC6"+_cPedido+_cItem+_cSequen
			Private _aTam   := TamSX3("DC_LOTECTL")
			_cChave += Space(_aTam[1])
			_aTam   := TamSX3("DC_NUMLOTE")
			_cChave += Space(_aTam[1])+_cLocaliz

			DbSelectArea("SDC")
			DbSeek(_cChave,.F.)      // Este loop  para o caso de eu ter mais de um SDC para o mesmo SC9
			Do While SDC->DC_FILIAL+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_ORIGEM+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_LOTECTL+SDC->DC_NUMLOTE+SDC->DC_LOCALIZ ==;
			_cChave .And. SDC->(!Eof())
				_nQtdExt += SDC->DC_QUANT
				RecLock("SDC",.F.)      // OK - 20/01/16 usar com a variável lFat
				SDC->DC_STATUS := " "
				If lRegis //Usa o mesmo registro do SDC
					SDC->DC_FILIAL := _xSeek
					MsUnLock()
					DbSeek(_cChave,.F.)
				Else
					DbDelete()
					MsUnLock()
					DbSkip()
				EndIf
			EndDo
		EndIf
		DbSelectArea("SB2")
		DbSetOrder(1)  //B2_FILIAL+B2_COD+B2_LOCAL
		DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,.F.)//    AQUI.... FAZER O QUE QUEDO TROCA O  LOCAL????
	Else
		DbSelectArea("SB2")
		DbSetOrder(1)  //B2_FILIAL+B2_COD+B2_LOCAL
		DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,.F.)
		If (SB2->B2_QATU - SB2->B2_RESERVA) < _nQtdLib .And. _cOpcao == "L"
			//		Return(.F.) //Verificar o que vai fazer quan do estiver considerando mo estoque
		EndIf
	EndIf

	If Found() // .And. !_lFat // (**) 
		//If Valtype(_cStatus) == "U"
		//	_cStatus := ""
		//EndIf
		//	_nPedVen := CalcPedVen(SC9->C9_PRODUTO,SC9->C9_LOCAL) // ESTOU DESABILITANDO ESTA ROTINA TEMPORARIAMENTE PARA TESTAR PERFORMANCE DO FATURAMENTO
		DbSelectArea("SB2")     // OK - 20/01/16 usar com a variável lFat
		RecLock("SB2",.F.)  // OK - 20/01/16 usar com a variável lFat
		SB2->B2_QPEDVEN := (SB2->B2_QPEDVEN-_nQtdLib) //_nPedVen

		If _cOpcao == "E" .And. _nQtdExt > 0// Gravar o B2_RESERVA só em caso de estorno - Na liberação o B2_RESERVA está sendo atualizado junto com o BF_EMPENHO
			SB2->B2_RESERVA -= _nQtdExt // _nQtdLib
		EndIf

		MsUnLock()
	EndIf

	If _cOpcao == "E" .And. _lLocaliz .And. _nQtdExt > 0 //.And. !_lFat // (**) // Controla localização?
		// No estorno primeiro acerto as outras tabelas e por último o SBF
		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If DbSeek(xFilial("SBF")+_cLocal+_cLocaliz+_cProduto,.F.)  // OK - 20/01/16 usar com a variável lFat
			RecLock("SBF",.F.) // OK - 20/01/16 usar com a variável lFat
			SBF->BF_EMPENHO -= _nQtdExt  // _nQtdLib
			MsUnLock()

			If Left(_cLocaliz,1) == "B" .And. !_lFat
				// Se For bobinas, alterar estatus para a liberar
				DbSelectArea("SZE")
				DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
				_nExtLance := Val(Right(AllTrim(_cLocaliz),5))
				_nQtdMets := _nQtdExt
				DbSeek(xFilial("SZE") + SC9->C9_PEDIDO + SC9->C9_ITEM,.F.)
				Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC9->C9_PEDIDO .And. ;
				SZE->ZE_ITEM == SC9->C9_ITEM .And. SZE->(!Eof()) .And. _nQtdMets > 0
					If SZE->ZE_STATUS == "E" .And. SZE->ZE_QUANT == _nExtLance
						RecLock("SZE",.F.)
						SZE->ZE_STATUS := "P"
						MsUnLock()
						_nQtdMets := _nQtdMets - SZE->ZE_QUANT
					EndIf
					SZE->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	DbSelectArea("SC9")

	_nQtdSC9 :=  SC9->C9_QTDLIB

	RecLock("SC9",.F.)
	If _cOpcao == "L"
		SC9->C9_BLEST  := Space(2)
		SC9->C9_LOCAL  := _cLocal
	Else
		SC9->C9_BLEST  := "02"
		SC9->C9_STATUS := "0"
		SC9->C9_SEQOS  := "  "
		//	SC9->C9_LOCAL := SC6->C6_LOCAL     AQUI....
	EndIf
	MsUnLock()

	If _cOpcao == "E" .And. !_lFat // Estou estornando e não no faturamento
		DbSelectArea("SC9")
		DbSetOrder(1)  //C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+C9_PRODUTO
		_nSomaSC9 := 0
		For _nVoltaC9 := 1 to 2
			DbSeek(xFilial("SC9")+_cPedido+_cItem,.F.)
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cPedido .And. ;
			SC9->C9_ITEM == _cItem .And. SC9->(!Eof())
				If Empty(SC9->C9_BLCRED) .And. SC9->C9_BLEST  == '02' // Somente os que estão com bloqueio de estoque
					If _nVoltaC9 == 1
						_nSomaSC9 += SC9->C9_QTDLIB
					Else
						RecLock("SC9",.F.)
						If _nSomaSC9 >  0
							SC9->C9_QTDLIB := _nSomaSC9
							SC9->C9_STATUS := "0"
							_nSomaSC9 := 0
						Else
							SC9->(DbDelete())
						EndIf
						MsUnLock()
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo
		Next
		// Reposiciona SC9
		DbSeek(xFilial("SC9")+_cPedido+_cItem,.F.)
	EndIf

	If _cOpcao == "L" .And. _nQtdLib # SC9->C9_QTDLIB

		//Se quantidade liberada for menor que a quantidade do SC9, liberar o item com a
		//respectiva quantidade e criar outra sequência com o saldo

		Private _nDif := SC9->C9_QTDLIB - _nQtdLib

		DbSelectArea("SC9")
		Private _aRegSC9 := Array(1,FCount())
		For _j := 1 to FCount()
			_aRegSC9[1][_j] := FieldGet(_j)
		Next

		If _nQtdLib < SC9->C9_QTDLIB

			RecLock("SC9",.F.)
			SC9->C9_QTDLIB  := _nQtdLib
			MsUnLock()

			//Buscar a última sequência do Item do Pedido de Venda
			Private _cSequen := SC9->C9_SEQUEN

			SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			SC9->(DbSeek(xFilial("SC9")+_cPedido+_cItem,.F.))

			Do While SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM == xFilial("SC9")+_cPedido+_cItem .And. SC9->(!Eof())
				_cSequen := If(SC9->C9_SEQUEN > _cSequen,SC9->C9_SEQUEN,_cSequen)
				DbSkip()
			EndDo
			_cSequen := Soma1(_cSequen)

			DbSelectArea("SC9")
			RecLock("SC9",.T.)
			For _j := 1 To FCount()
				FieldPut(_j,_aRegSC9[1,_j])
			Next
			SC9->C9_QTDLIB := _nDif
			SC9->C9_SEQUEN := _cSequen
			SC9->C9_BLEST  := "02"
			SC9->C9_STATUS := "0"
			SC9->C9_SEQOS  := "  "
			SC9->C9_LOCAL  := SC6->C6_LOCAL
			MsUnLock()
		Else

			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
				RecLock("SC6",.F.)
				SC6->C6_QTDEMP := SC6->C6_QTDEMP + _nQtdLib -  SC9->C9_QTDLIB
				MsUnLock()
			EndIf

			RecLock("SC9",.F.)
			SC9->C9_QTDLIB  := _nQtdLib
			MsUnLock()
		EndIf
	EndIf

	Return(.T.)

/*/{Protheus.doc} CDEST01E
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _lTudo, , descricao
@param _lReserv, , descricao
@type function
/*/
User Function CDEST01E(_lTudo,_lReserv)
	Local _aArea := GetArea(), _aAreaC9
	Local _lResZP4 := .F.
	Local _lTemRm, _cPedZZR := "      "
	Local _lConfi := .T.
	Local oStatic    := IfcXFun():newIfcXFun()
	local aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(SC9->C9_PEDIDO))
	
	if !validAcess(xFilial("SC9"))
		MsgAlert("Permissão Negada!")
		return(.T.)
	endif

	if !aCanCancel[01]
		MsgAlert("Atenção: " + Chr(13) + Chr(13) +;
			aCanCancel[02],'Bloqueado')
	else
		//LEO 19/07/16-PORTAL
		If !_lReserv
			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC9->C9_PEDIDO .And. SC6->(!Eof())
				If Left(SC6->C6_SEMANA,3) == "ZP4" .Or. !Empty(SC6->C6_ZZNRRES)// Reserva do Portal Roberto/Leo 21/03/2016
					_lReserv := .T.
					Exit
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf

		_lTemRm := .F.
		_cPedZZR := "      "
		If _lTudo // Estornar tudo????
			If MsgBox("Tem certeza que deseja estornar todas as liberações de estoque do Pedido de Venda: "+SC9->C9_PEDIDO+"?",;
			"Confirma","YesNo")
				_cPedido := SC9->C9_PEDIDO
				_cPedZZR := SC9->C9_PEDIDO

				DbSelectAreA("SF4")
				DbSetOrder(1)

				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.) //.And. !GetMv("MV_ZZUSAC9")
					If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1])
						_lConfi := MsgBox("O Pedido de Venda: "+SC9->C9_PEDIDO+" está em FATURAMENTO, tem certeza que deseja estornar todas as liberações?",;
						"Confirma","YesNo")//Pedidos em FATURAMENTO alertar novamente e pedir confirmação
						If _lConfi
							RecLock("SC5",.F.)
							SC5->C5_ZSTATUS := "0" // Volta o pedido com Status Normal
							MsUnLock()
						EndIf
					EndIf
				EndIf
				If _lConfi
					DbSelectArea("SC6")
					DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		
					DbSelectArea("SC9")
					DbSetOrder(1)  //C9_FILIAL+SC9->C9_PEDIDO+sc9->C9_ITEM+sc9->C9_SEQUEN+C9_PRODUTO
		
					DbSeek(xFilial("SC9") + _cPedido,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cPedido .And. SC9->(!Eof())
						If Empty(SC9->C9_BLEST) //  Tratar somente os registros liberados
							DbSelectArea("SC6")
							DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
							If DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
		
								DbSelectAreA("SF4")
								DbSetOrder(1)
								DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
								If SF4->F4_ESTOQUE == "S"
									SB1->(DbSetOrder(1))
									SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
									_lLocaliz := (SB1->B1_LOCALIZ == "S")
		
									DbSelectArea("SDC")
									DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
									DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)
									If _lReserv .And. _lLocaliz .And. Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ)
										// Mantém o item reservado ?
										// O produto controla localização?
										// Ele não foi reservado no SZZ?
		
										// SC9 - Bloquear estoque
										// SBF - Não Altera (mantém o empenho)
										// SDC - Alterar a Origem
										RecLock("SDC",.F.)
										SDC->DC_ORIGEM := "SDC" // Estorno com reserva
										SDC->DC_DTLIB  := DataValida(dDataBase+1)
										MsUnLock()
		
										RecLock("SC9",.F.)
										SC9->C9_BLEST  := "02"
										SC9->C9_STATUS := "0"
										SC9->C9_SEQOS  := "  "
										MsUnLock()
									Else
										U_CDLibEst("E",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,SDC->DC_LOCALIZ,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN)
									EndIf
								EndIf
							EndIf
							DbSelectArea("SC9")
						EndIf
						DbSkip()
					EndDo
				EndIf
			EndIf
		Else
			_lTemRm := .T.  // Presumo que não posso estornar
			If !Empty(SC9->C9_NFISCAL)
				Alert("Não é possível estornar a liberação de estoque de um Item de Pedido de Venda já faturado!")
			ElseIf 	SC9->C9_BLEST == "02"
				Alert("Não é possível estornar a liberação de estoque de um Item de Pedido de Venda não Liberado!")
			ElseIf 	!Empty(SC9->C9_BLEST)
				Alert("Não é possível estornar a liberação deste Item do Pedido de Venda!")
			Else
				_lTemRm := .F. // Eu posso estornar
			EndIf


			If !_lTemRm .And. !Empty(SC9->C9_SEQOS) // Usa controle pelo SC9 e tem romaneio confirmado
				_lTemRm := .T. // Como tem romaneio confirmado, pergunto se posso estornar
				If MsgBox("O Pedido/Item "+SC9->C9_PEDIDO+"/"+SC9->C9_ITEM+" tem Romaneio/Volumes em Aberto. " + Chr(13) +;
				"Este Estorno Excluirá o Romaneios e os Volumes Criados, Confirma?",;
				"Confirma","YesNo")
					_lTemRm := .F.
				EndIf
			EndIf

			If !_lTemRm
				DbSelectArea("SC6")
				DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
					DbSelectAreA("SF4")
					DbSetOrder(1)
					DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
					If SF4->F4_ESTOQUE == "N"
						Alert("Item sem Movimentação de Estoque - Estorno não Realizado")
					ElseIf MsgBox("Tem certeza que deseja estornar a liberação de estoque do Item "+;
					SC9->C9_ITEM+" Pedido de Venda: "+SC9->C9_PEDIDO+"?",;
					"Confirma","YesNo")

						_cPedZZR := SC9->C9_PEDIDO

						DbSelectArea("SDC")
						DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
						DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)

						U_CDLibEst("E",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,SDC->DC_LOCALIZ,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN)
					EndIf
				EndIf
			EndIf
		EndIf

		If !Empty(_cPedZZR)
			u_EstZZRZZO(_cPedZZR," ")
		EndIf
	endif
	RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} CDEST01X
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function CDEST01X()
	BrwLegenda(cCadastro,"Legenda",{{"ENABLE"  ,"Liberado para Faturar"},;
	{"BR_AZUL" ,"Bloqueado por Crédito"},;
	{"BR_CINZA","Pedido Rejeitado"},;
	{"BR_PRETO","Bloqueado por Estoque"},;
	{"DISABLE" ,"Já Faturado"}})
Return(.t.)

/*/{Protheus.doc} ValidPerg
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function ValidPerg
	Local _aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//   Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Pedido                    ?","mv_ch1","C",060,0,"G","u_Passa('1')","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Pedido                 ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Entrega           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Entrega        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Produto                   ?","mv_ch5","C",TAMSX3("B1_COD")[1],0,0,"G","","mv_par05","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Até o Produto                ?","mv_ch6","C",TAMSX3("B1_COD")[1],0,0,"G","","mv_par06","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"07","Do Cliente                   ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Da Loja                      ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Até o Cliente                ?","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"10","Até a Loja                   ?","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Do Representante             ?","mv_chb","C",06,0,0,"G","","mv_par11","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"12","Até o Representante          ?","mv_chc","C",06,0,0,"G","","mv_par12","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"13","Local 10 (Só p/3 Lagoas)     ?","mv_chd","N",01,0,0,"C","","mv_par13","Sim","","","","","Não","","","","","","","","",""})
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


/*/{Protheus.doc} Estoques
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function Estoques()
	_cProduto := GDFieldGet("Z5_PRODUTO",n)

	_aCamposSBF := {}
	_aCamposSBF :=   {{"LOCAL"  , "C", 02, 0},;
	{"LOCALIZ", "C", 15, 0},;
	{"QUANT"  , "N", 12, 2},;
	{"EMPENHO", "N", 12, 2},;
	{"LIBERAD", "N", 12, 2},;
	{"DISPONI", "N", 12, 2}}

	_cNomArq := CriaTrab(_aCamposSBF, .T.)

	If Select("TRB") > 0
		DbSelectArea("TRB")
		Zap
	Else
		DbUseArea(.T.,,_cNomArq,"TRB",.T.,.F.)
		DbSelectArea("TRB")
	EndIf

	_cInd := CriaTrab(NIL,.f.)
	IndRegua("TRB",_cInd,"LOCAL+LOCALIZ",,,"Selecionando Registros...")
	DbSetIndex(_cInd+OrdBagExt())

	_aCamSBF := {}
	aAdd(_aCamSBF,{"LOCAL"  ,"Armazém"})
	aAdd(_aCamSBF,{"LOCALIZ","Endereço"})
	aAdd(_aCamSBF,{"QUANT"  ,"Quantidade","@E 9,999,999.99"})
	aAdd(_aCamSBF,{"EMPENHO","Empenho","@E 9,999,999.99"})
	aAdd(_aCamSBF,{"LIBERAD","Liberado","@E 9,999,999.99"})
	aAdd(_aCamSBF,{"DISPONI","Disponível","@E 9,999,999.99"})

	Private _nTotQtde := 0
	Private _nTotEmp  := 0
	Private _nTotLib  := 0
	Private _nTotDisp := 0

	DbSelectArea("SBF")
	DbSetOrder(2)  //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	DbSeek(xFilial("SBF")+_cProduto,.F.)
	Do While SBF->BF_FILIAL+SBF->BF_PRODUTO == xFilial("SBF")+_cProduto .And. SBF->(!Eof())

		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->LOCAL   := SBF->BF_LOCAL
		TRB->LOCALIZ := SBF->BF_LOCALIZ
		TRB->QUANT   := SBF->BF_QUANT
		TRB->EMPENHO := SBF->BF_EMPENHO
		TRB->LIBERAD := U_QtdLib(.F.,SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOCALIZ,.T.,.F.)
		TRB->DISPONI := TRB->QUANT - (TRB->EMPENHO + TRB->LIBERAD)
		MsUnLock()

		_nTotQtde += TRB->QUANT
		_nTotEmp  += TRB->EMPENHO
		_nTotLib  += TRB->LIBERAD
		_nTotDisp += TRB->DISPONI

		DbSelectArea("SBF")
		DbSkip()

	EndDo

	DbSelectArea("TRB")
	DbGoTop()

	@ 000,000 TO 325,700 DIALOG _dSaldos TITLE "Consulta do Estoque por Endereço"

	@ 005,005 Say "Produto:  "+Transform(_cProduto,"@R XXX.XX.XX.X.XX")+" - "+Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC")  Size 250,015
	@ 020,005 TO 140,345 BROWSE "TRB" FIELDS _aCamSBF

	@ 145,005 Say "Totais:"
	@ 155,005 Say "Quantidade: " + Transform(_nTotQtde,"@E 9,999,999.99")  Size 100,010
	@ 155,075 Say "Empenho: "    + Transform(_nTotEmp ,"@E 9,999,999.99")  Size 100,010
	@ 155,145 Say "Liberado: "   + Transform(_nTotLib ,"@E 9,999,999.99")  Size 100,010
	@ 155,215 Say "Disponível: " + Transform(_nTotDisp,"@E 9,999,999.99")  Size 100,010
	@ 150,300 BMPBUTTON TYPE 1 ACTION Close(_dSaldos)

	Activate Dialog _dSaldos Centered

	DbSelectArea("TRB")
	DbCloseArea("TRB")
	If File(_cNomArq+'.DTC')
		FErase(_cNomArq+'.DTC')
	EndIf
	If File(_cNomArq+'.idx')
		FErase(_cNomArq+'.idx')
	EndIf

Return


/*/{Protheus.doc} QtdLib
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _lLocal, , descricao
@param _cProd, , descricao
@param _cLocal, , descricao
@param _cLocaliz, , descricao
@param _lAdLin, , descricao
@param _lRefre, , descricao
@type function
/*/
User Function QtdLib(_lLocal,_cProd,_cLocal,_cLocaliz,_lAdLin,_lRefre)
	Private _nRet := 0
	If _lMult // Somar o 1ro acols
		_nPos1 := _nPos2 := _nPos3 := _nPos4 := 0
		For _nx := 1 to Len(_aCpaHead)
			If AllTrim(_aCpaHead[_nx,2]) == "Z5_PRODUTO"
				_nPos1 := _nx
			ElseIf AllTrim(_aCpaHead[_nx,2]) == "Z5_LOCAL"
				_nPos2 := _nx
			ElseIf AllTrim(_aCpaHead[_nx,2]) == "Z5_LOCALIZ"
				_nPos3 := _nx
			ElseIf AllTrim(_aCpaHead[_nx,2]) == "Z5_QTDLIB"
				_nPos4 := _nx
			EndIf
		Next
		For _i := 1 To Len(_aCpaCols)
			If _aCpaCols[_i,_nPos1] == _cProd .And. _aCpaCols[_i,_nPos2] == _cLocal .And.(_aCpaCols[_i,_nPos3] == _cLocaliz .Or. _lLocal)
				_nRet += _aCpaCols[_i,_nPos4]
			EndIf
		Next
	Else
		For _i := 1 To Len(aCols)
			If GDFieldGet("Z5_PRODUTO",_i) == _cProd    .And. !GDDeleted(_i) .And. ;
			GDFieldGet("Z5_LOCAL",_i)   == _cLocal   .And. GDFieldGet("Z5_RESERVA",_i) == "N" .And.;
			(GDFieldGet("Z5_LOCALIZ",_i) == _cLocaliz .Or. _lLocal)

				If _lRefre
					If AllTrim(ReadVar()) == "M->Z5_QTDLIB" .And. _i == n //Digitado QtdLib e estou na mesma linha
						_nRet += M->Z5_QTDLIB
					Else
						_nRet += GDFieldGet("Z5_QTDLIB",_i)
					EndIf
				Else
					_nRet += If(_i==n.And.!_lAdLin,0,GDFieldGet("Z5_QTDLIB",_i))
				EndIf
			EndIf
		Next
		If _lAdLin // Soma-se Tudo
			For _x := 1 to Len(_aMultipl)
				If _aMultipl[_x,5] == GDFieldGet("Z5_PRODUTO",n) .And. _aMultipl[_x,4] == GDFieldGet("Z5_LOCAL",n) .And. ;
				_aMultipl[_x,3] == GDFieldGet("Z5_LOCALIZ",n)

					_nRet += _aMultipl[_x,2]
				EndIf
			Next
		EndIf
	EndIf

Return(_nRet)


/*/{Protheus.doc} Refresh
//TODO Descrição auto-gerada.
@author Roberto
@since 07/10/2016
@version undefined

@type function
/*/
User Function Refresh()

	DbSelectArea("SB1")
	DbSetOrder(1)  //B1_FILIAL+B1_COD
	DbSeek(xFilial("SB1")+GDFieldGet("Z5_PRODUTO",n),.F.)

	_cCodDesc := AllTrim(SB1->B1_COD)+" - "+AllTrim(SB1->B1_DESC)
	_oCodDesc:Refresh()


	If SB1->B1_LOCALIZ == "S"
		// Inicio SBF
		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

		_VarDig := AllTrim(ReadVar())
		_Z5_LOCAL := If(_VarDig=="M->Z5_LOCAL",M->Z5_LOCAL,GDFieldGet("Z5_LOCAL",n))
		_Z5_LOCALIZ := If(_VarDig=="M->Z5_LOCALIZ",M->Z5_LOCALIZ,GDFieldGet("Z5_LOCALIZ",n))

		DbSeek(xFilial("SBF")+_Z5_LOCAL+_Z5_LOCALIZ+GDFieldGet("Z5_PRODUTO",n),.F.)
		_cQtdEst := Transform(SBF->BF_QUANT,"@E 999,999,999.99")
		_oQtdEst :Refresh()

		_cQtdRes := Transform(SBF->BF_EMPENHO,"@E 999,999,999.99")
		_oQtdRes :Refresh()

		Private _nQtLib := U_QtdLib(.F.,SBF->BF_PRODUTO,SBF->BF_LOCAL,SBF->BF_LOCALIZ,.T.,.T.)
		_cQtdLib := Transform(_nQtLib,"@E 999,999,999.99")
		_oQtdLib :Refresh()

		_cQtdDisp := Transform(SBF->BF_QUANT-SBF->BF_EMPENHO-_nQtLib,"@E 999,999,999.99")
		_oQtdDisp:Refresh()
		// Fim SBF
	Else
		// Inicio SB2
		DbSelectArea("SB2")
		DbSetOrder(1)  //B2_FILIAL+B2_COD+B2_LOCAL
		DbSeek(xFilial("SB2")+GDFieldGet("Z5_PRODUTO",n)+GDFieldGet("Z5_LOCAL",n),.F.)

		_cQtdEst := Transform(SB2->B2_QATU,"@E 999,999,999.99")
		_oQtdEst :Refresh()

		_cQtdRes := Transform(SB2->B2_RESERVA,"@E 999,999,999.99")
		_oQtdRes :Refresh()

		Private _nQtLib := U_QtdLib(.T.,SB2->B2_COD,SB2->B2_LOCAL,"",,.T.)
		_cQtdLib := Transform(_nQtLib,"@E 999,999,999.99")
		_oQtdLib :Refresh()

		_cQtdDisp := Transform(SB2->B2_QATU-(SB2->B2_RESERVA+_nQtLib),"@E 999,999,999.99")
		_oQtdDisp:Refresh()
		// Fim SB2
	EndIf

	Private _cCodCli  := Posicione("SC5",1,xFilial("SC5")+GDFieldGet("Z5_PEDIDO",n),"C5_CLIENTE")+Posicione("SC5",1,xFilial("SC5")+GDFieldGet("Z5_PEDIDO",n),"C5_LOJACLI")

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA
	DbSeek(xFilial("SA1")+_cCodCli,.F.)

	_cCliente := SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME
	_oCliente:Refresh()

	//If FWCodFil() == "01" /// Só a Matriz trabalha com rotas *Gustavo Zacarias, retirado 24/09/13.
	_cRota := If(FWCodFil() == "01",SA1->A1_ROTA,SA1->A1_ROTA3L)
	_oRota:Refresh()
	//EndIf

	_cCondPag := Posicione("SC5",1,xFilial("SC5")+GDFieldGet("Z5_PEDIDO",n),"C5_CONDPAG")
	IF _cCondPag == "000"
		_cCondPag := "BNDES"
	Else
		_cCondPag := Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_DESCRI")
	EndIf
	_oCondPag:Refresh()

Return(.T.)

/*/{Protheus.doc} CDEST24A
//TODO Descrição auto-gerada.
	If !MsgBox("Atenção:"+Chr(13)+Chr(13)+;
	"Esta rotina efetuará a liberação de TODOS os pedidos em carteira,"+Chr(13)+;
	"exceto os pedidos com status 'EM FATURAMENTO' ou que o tipo de liberação"+Chr(13)+;
	"seja MANUAL ou que a DATA INICIO FATURAMENTO ainda não tenha ocorrido"+Chr(13)+;
	"ou que não seja pedido com reserva originado no Portal."+Chr(13)+Chr(13)+;
	"Compreende em :"+Chr(13)+;
	"     1-Estorno das liberações dos produtos curva 'A' e dos produtos;"+Chr(13)+;
	"       ainda não programados no PCP;" +Chr(13)+;
	"     2-Liberação por ordem de data de entrega para:"+Chr(13)+;
	"          a-Pedidos atrasados;"+Chr(13)+;
	"          b-Pedidos PRIORIZADOS;"+Chr(13)+;
	"          c-Pedidos com produtos NÃO curva 'A' já programados pelo PCP;"+Chr(13)+;
	"          d-Pedidos somente quando atingem 100% do pedido;"+Chr(13)+;
	"          e-Pedidos que somem R$ 4.000,00 e restem outros R$ 4.000,00 de saldo;"+Chr(13)+Chr(13)+;
	"     3-Liberação Geral."+Chr(13)+Chr(13)+;
	"Atenção: Não serão efetuadas librerações de pedidos com cadastro do "+Chr(13)+;
	"cliente bloqueado."+Chr(13)+Chr(13)+;
	"Tem certeza que deseja processar a liberação automática de estoque?","Atenção","YesNo")
	
	By Roberto Oliveira 18/10/16
	Ontem o Felipe (exp.) esteve solicitando a alteração das regras de liberação dos estoques.
	Primeiro são realizados os estornos com exceção de:
	- Pedidos atrasados
	- Bobinas
	Nas liberações serão consideradas somente duas regras:
	- Data de entrega do pedido;
	- Pedidos priorizados.
	Assim sendo a rotina efetuará:
	- Estorno das liberações de pedidos não atrasados e não sejam bobinas
	- Liberação dos pedidos atrasados
	- Liberação dos pedidos priorizados
	- Liberação dos demais pedidos por ordem de data de entrega.
	Alterado em 09/04/2015 ->  "          e-Pedidos que somem R$ 4.000,00 e restem outros R$ 4.000,00 de saldo;"+Chr(13)+Chr(13)+;
	16/04/2015-Rafael p/Jeferson ->voltou o que era
	 "          e-Pedidos que somem R$ 3.000,00 e restem outros R$ 10.000,00 de saldo;"+Chr(13)+Chr(13)+;
@author Roberto
@since 29/08/2017
@version 1.0
@param _lGeral, , descricao
@type function
/*/
User Function CDEST24A(_lGeral)
	Local aParamBox 	:= {}
	Local aRet 			:= ""

	//_aAccess := u_CtrlAccess("B","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
	//Bloqueia Rotina em uso
	If !LockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		Return
	EndIf
	
	/*
	If !_aAccess[1]
		Alert("Processo Interrompido -> Rotina em Uso por " + AllTrim(_aAccess[2]))
		Return(.T.)
	EndIf
	*/
	if !validAcess(xFilial("SC9"))
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Permissão Negada!")
		return(nil)
	endif

	If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
		If !MsgBox("Atenção:"+Chr(13)+Chr(13)+;
		"Esta rotina efetuará a liberação de TODOS os pedidos em carteira, exceto:"+Chr(13)+;
		"     1-Pedidos com status 'EM FATURAMENTO';"+Chr(13)+;
		"     2-Tipo de liberação seja MANUAL;"+Chr(13)+;
		"     3-A DATA INICIO FATURAMENTO ainda não tenha ocorrido;"+Chr(13)+;
		"     4-Não seja pedido com reserva originado no Portal;"+Chr(13)+;
		"     5-Pedidos com cadastro do cliente BLOQUEADO."+Chr(13)+Chr(13)+;
		"Compreende em :"+Chr(13)+;
		"     1-Estorno das liberações dos produtos curva 'A' e dos produtos;"+Chr(13)+;
		"       ainda não programados no PCP;" +Chr(13)+;
		"     2-Liberação por ordem de data de entrega para:"+Chr(13)+;
		"          a-Pedidos atrasados;"+Chr(13)+;
		"          b-Pedidos PRIORIZADOS;"+Chr(13)+;
		"          c-Pedidos com produtos NÃO curva 'A' já programados pelo PCP;"+Chr(13)+;
		"          d-Pedidos somente quando atingem 100% do pedido;"+Chr(13)+;
		"          e-Pedidos que somem R$ 4.000,00 e restem outros R$ 4.000,00 de saldo;"+Chr(13)+;
		"     3-Liberação Geral."+Chr(13)+Chr(13)+;
		"Tem certeza que deseja processar a liberação automática de estoque?","Atenção","YesNo")

			//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
			
			Return(.T.)
		EndIf
	Else // Após dia 17/10/16 // Date() < Ctod("18/10/2016")
		If !MsgBox("Atenção:"+Chr(13)+Chr(13)+;
		"Esta rotina efetuará a liberação de TODOS os pedidos em carteira, exceto:"+Chr(13)+;
		"     1-Pedidos com status 'EM FATURAMENTO';"+Chr(13)+;
		"     2-Tipo de liberação seja MANUAL"+Chr(13)+;
		"Compreende em :"+Chr(13)+;
		"     1-Estorno das liberações de pedidos que:"+Chr(13)+;
		"          a-Pedidos NÃO atrasados;"+Chr(13)+;
		"          b-Pedidos NÃO reservados;"+Chr(13)+;
		"          c-Pedidos com acondicionamento diferente de bobina." +Chr(13)+;
		"     2-Liberação por ordem de data de entrega para:"+Chr(13)+;
		"          a-Pedidos atrasados;"+Chr(13)+;
		"          b-Pedidos PRIORIZADOS;"+Chr(13)+;
		"          c-Demais pedidos " +Chr(13)+Chr(13)+;
		"Tem certeza que deseja processar a liberação automática de estoque?","Atenção","YesNo")

			//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
			
			Return(.T.)
		EndIf
	EndIf

	Private cPerg := "CDES01"
	ValidPerg()
	Pergunte(cPerg,.F.)
	MV_PAR01 := Replicate(" ",Len(MV_PAR01)) // 01-Do Pedido                    ?"
	MV_PAR02 := Replicate("Z",Len(MV_PAR02)) // 02-Até o Pedido                 ?"
	MV_PAR03 := Ctod("  /  /  ")             // 03-Da Data de Entrega           ?"
	MV_PAR04 := dDataBase+60                 // 04-Até a Data de Entrega        ?"
	MV_PAR05 := Replicate(" ",Len(MV_PAR05)) // 05-Do Produto                   ?"
	MV_PAR06 := Replicate("Z",Len(MV_PAR06)) // 06-Até o Produto                ?"
	MV_PAR07 := Replicate(" ",Len(MV_PAR07)) // 07-Do Cliente                   ?"
	MV_PAR08 := Replicate(" ",Len(MV_PAR08)) // 08-Da Loja                      ?"
	MV_PAR09 := Replicate("Z",Len(MV_PAR09)) // 09-Até o Cliente                ?"
	MV_PAR10 := Replicate("Z",Len(MV_PAR10)) // 10-Até a Loja                   ?"
	MV_PAR11 := Replicate(" ",Len(MV_PAR11)) // 11-Do Representante             ?"
	MV_PAR12 := Replicate("Z",Len(MV_PAR12)) // 12-Até o Representante          ?"

	Processa({|lEnd| fEstorno()}, "Estornando Liberações")
	Processa({|lEnd| fLibera()} , "Efetuando Liberações")

	//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
	UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
	
	If MsgBox("Deseja enviar Email de Notificação?","Atenção","YesNo")

		aAdd(aParamBox,{1,"Emails p/ Envio(;)",PadR(GetMV("MV_ZZEXEMA"),250),"","","","",100,.F.})

		If !ParamBox(aParamBox, "Parametros", @aRet)
			Return(.F.)
		EndIf

		_cPara := Alltrim(aRet[1])
		//Grava emails
		PutMV("MV_ZZEXEMA",_cPara)

		//Teste
		If Empty(_cPara)
			_cPara := Alltrim("felipe@cobrecom.com.br;Roberto@cobrecom.com.br")
		EndIf
		U_SendMail(_cPara,"Expedição - Sistema Liberado em "+ Substr(DtoS(dDataBase),7,2)+"/" + Substr(DtoS(dDataBase),5,2)+ "/" + ;
		Substr(DtoS(dDataBase),1,4),"Expedição - Sistema Liberado")
	EndIf

	Alert("Termino do Processamento")

Return(.T.)

/*/{Protheus.doc} ProcTrb
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _lGeral, , descricao
@type function
/*/
Static Function ProcTrb(_lGeral)
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("TRB")
	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB->(!Eof())
		IncProc()

		If _lGeral // Liberar somente o que não é curva
			// Curva A compreende:
			// Fio  do 1,5 ao 10    		10104 a0 10108
			// Flex do 0,50 ao 35			11501 ao 11511
			// Plasticom do 6 ao 35			11007 ao 11011
			// Paralelo do 2x0,50 ao 2x4	12001 ao 12006
			// Torcido do 2x1 ao 2x4        12201 ao 12206
			If (_cCodPrd >= "10104" .And. _cCodPrd <= "10108") .Or. (_cCodPrd >= "11501" .And. _cCodPrd <= "11511") .Or.;
			(_cCodPrd >= "11007" .And. _cCodPrd <= "11011") .Or. (_cCodPrd >= "12001" .And. _cCodPrd <= "12006") .Or.;
			(_cCodPrd >= "12201" .And. _cCodPrd <= "12206") // O produto está dentro da curva

				// Verificar se o acondicionamento corresponde a curva -> Rolos de 100 mts ou carretéis
				If (TRB->ACONDIC == "R" .And. TRB->METRAGE == 100) .Or. TRB->ACONDIC $ "CM"

					// Não Fazer a liberação agora
					DbSelectArea("TRB")
					DbSkip()
					Loop
				EndIf
			EndIf
		EndIf

		SC9->(DbGoTo(TRB->REGC9))
		If SC9->(!Deleted()) .And. (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02" .And. !TRB->ACONDIC $ "TB" // Bobinas e retalhos são obrigatoriamente liberados manualmente
			For _nxxy := 1 to 2
				If _nxxy == 1
					_cLocaliz := Left(TRB->ACONDIC+StrZero(TRB->METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
				Else
					SC9->(DbGoTo(TRB->REGC9))
					If SC9->(!Deleted()) .And. (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02" .And. TRB->ACONDIC == "R" .And. TRB->METRAGE < 100
						// Verificar se tem retalhos
						_cLocaliz := Left("T"+StrZero(TRB->METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
					Else
						Exit
					EndIf
				EndIf
				DbSelectArea("SBF")
				If	DbSeek(xFilial("SBF")+TRB->LOCAL+_cLocaliz+TRB->PRODUTO,.F.)
					_nLib:= Min(TRB->QTDALIB,If(SBF->BF_EMPENHO>=0,(SBF->BF_QUANT - SBF->BF_EMPENHO),0))
					_nLocaliz := Val(Right(_cLocaliz,Len(_cLocaliz)-1))
					_nLib:= Int(_nLib / _nLocaliz) * _nLocaliz
					If _nLib > 0.00
						_nALib := Int(_nLib / TRB->METRAGE) * TRB->METRAGE
						If _nALib > 0.00
							If (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02"

								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
								U_CDLibEst("L",TRB->PRODUTO,_nLib,TRB->LOCAL,_cLocaliz,SC9->C9_PEDIDO,TRB->ITEM,TRB->SEQUEN,,,"2")
							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	DbSelectArea("TRB")
Return(.T.)


/*/{Protheus.doc} CrieTRB
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param nQuando, numeric, descricao
@param _lGeral, , descricao
@type function
/*/
Static Function CrieTRB(nQuando,_lGeral)
	_aCampos := {{"PEDIDO" , "C", TamSX3("C9_PEDIDO")[1], 0},;
	{"ITEM"   , "C", TamSX3("C9_ITEM")[1], 0},;
	{"SEQUEN" , "C", TamSX3("C9_SEQUEN")[1], 0},;
	{"CLIENTE", "C", TamSX3("C9_CLIENTE")[1], 0},;
	{"LOJA"   , "C", TamSX3("C9_LOJA")[1], 0},;
	{"PRODUTO", "C", TamSX3("C9_PRODUTO")[1], 0},;
	{"ACONDIC", "C", TamSX3("C6_ACONDIC")[1], 0},;
	{"LANCES" , "N", TamSX3("C6_LANCES")[1], 0},;
	{"METRAGE", "N", 06, 0},;
	{"ENTREG" , "D", 08, 0},;
	{"QTDVEN" , "N", 12, 2},;
	{"QTDALIB", "N", 12, 2},;
	{"LOCAL"  , "C", TamSX3("C9_LOCAL")[1], 0},;
	{"RESERVA", "C", 01, 0},;
	{"REGC9"  , "N", 15, 0}}

	_cNomArq := CriaTrab(_aCampos, .T.)

	If Select("TRB") > 0
		DbselectArea("TRB")
		DbCloseArea("TRB")
	EndIf

	DbUseArea(.T.,,_cNomArq,"TRB",.T.,.F.)
	DbSelectArea("TRB")

	_cInd := CriaTrab(NIL,.F.)
	If nQuando == 1
		IndRegua("TRB",_cInd,"PRODUTO+DtoS(ENTREG)",,,"Selecionando Registros...")
	Else
		IndRegua("TRB",_cInd,"DtoS(ENTREG)+PRODUTO",,,"Selecionando Registros...")
	EndIf
	If _lGeral // Criar ordem 2 para tratar as liberaçoes das curvas
		_cInd2 := CriaTrab(NIL,.F.)
		IndRegua("TRB",_cInd,"Dtos(ENTREG)+PEDIDO+PRODUTO",,,"Selecionando Registros...")
		DbClearIndex() // Fecha todos s arquivos de indices
		DbSetIndex(_cInd+OrdBagExt())
		DbSetIndex(_cInd2+OrdBagExt())
	Else
		DbSetIndex(_cInd+OrdBagExt())
	EndIf

	DbSetOrder(1)

	Processa({|lEnd| MontaTRB(nQuando)}, 'Montando Arquivo de Trabalho...')
Return(_cNomArq)

/*/{Protheus.doc} MontaTRB
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param nQuando, numeric, descricao
@type function
/*/
Static Function MontaTRB(nQuando)
	_cCliBlq := ""
	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SC9")
	DBOrderNickName("SC9BLQ") // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM

	ProcRegua(LastRec())
	DbSeek(xFilial("SC9") + "  02"+Mv_Par01,.T.)

	Do While SC9->C9_FILIAL == xFilial("SC9") .And. (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02" .And. SC9->(!Eof())
		If Empty(SC9->C9_DESCRI)
			SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
			RecLock("SC9",.F.)
			SC9->C9_DESCRI := SB1->B1_DESC
			MsUnLock()
		EndIf
		IncProc()

		If SC9->C9_PEDIDO  < Mv_Par01 .Or. SC9->C9_PEDIDO  > Mv_Par02 .Or.;
		SC9->C9_CLIENTE < Mv_Par07 .Or. SC9->C9_CLIENTE > Mv_Par09 .Or.;
		SC9->C9_LOJA    < Mv_Par08 .Or. SC9->C9_LOJA    > Mv_Par10 .Or.;
		SC9->C9_PRODUTO < Mv_Par05 .Or. SC9->C9_PRODUTO > Mv_Par06

			DbSelectArea("SC9")
			DbSkip()
			Loop

		EndIf

		If SC9->C9_FILIAL == "02"
			If (MV_PAR13 == 1 .And. SC9->C9_LOCAL <> "10") .Or.;
			(MV_PAR13 <> 1 .And. SC9->C9_LOCAL == "10")
				DbSelectArea("SC9")
				DbSkip()
				Loop
			EndIf
		EndIf

		If !Empty(SC9->C9_BLCRED) .Or. Empty(SC9->C9_BLEST) .Or. !Empty(SC9->C9_NFISCAL)
			DbSelectArea("SC9")
			DbSkip()
			Loop
		EndIf

		DbSelectArea("SC5")
		DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.)

		If SC5->C5_VEND1 < MV_PAR11 .OR. SC5->C5_VEND1 > MV_PAR12 .Or. ;
		(SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) .And. nQuando == 2) // Pedido em faturamento... não fazer nada// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
			DbSelectArea("SC9")
			DbSkip()
			Loop
		EndIf

		If !(SC5->C5_TIPO $ "DB") .And. Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1' // Sim
			If !(SC5->C5_CLIENTE+SC5->C5_LOJACLI $ _cCliBlq)
				Alert("Liberação não permitida para o cliente " + SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+ ", Bloqueado!")
				_cCliBlq := _cCliBlq + SC5->C5_CLIENTE+SC5->C5_LOJACLI + "//"
			EndIf
			DbSelectArea("SC9")
			DbSkip()
			Loop
		EndIf

		DbSelectArea("SC6")
		DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO,.F.)

		DbSelectAreA("SF4")
		DbSetOrder(1)
		DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)

		If SC6->C6_ENTREG  < Mv_Par03 .Or. SC6->C6_ENTREG  > Mv_Par04 .Or. SF4->F4_ESTOQUE # "S"
			DbSelectArea("SC9")
			DbSkip()
			Loop
		EndIf

		// Mata caso haja reserva no SDC com origem SDC
		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

		DbSelectArea("SB2")
		DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

		// Estorna o SDC se foi uma reserva de "estorno com reserva"
		DbSelectArea("SDC")
		DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		Do While SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SDC"+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
			SBF->(DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))
			SB2->(DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.))
			If RecLock("SDC",.F.)
				_nValEst := SDC->DC_QUANT
				SDC->(DbDelete())
				SDC->(MsUnLock())

				RecLock("SBF",.F.) // dou po reclock antes pra garantir BF_QUANT E BF_EMPENHO
				SBF->BF_EMPENHO := SBF->BF_EMPENHO - _nValEst
				SBF->(MsUnLock())

				RecLock("SB2",.F.)
				SB2->B2_RESERVA := SB2->B2_RESERVA - _nValEst
				SB2->(MsUnLock())
			EndIf
		EndDo

		DbSelectArea("TRB")
		RecLock("TRB",.T.)
		TRB->PEDIDO  := SC9->C9_PEDIDO
		TRB->ITEM    := SC9->C9_ITEM
		TRB->SEQUEN  := SC9->C9_SEQUEN
		TRB->CLIENTE := SC9->C9_CLIENTE
		TRB->LOJA    := SC9->C9_LOJA
		TRB->PRODUTO := SC9->C9_PRODUTO
		TRB->ACONDIC := SC6->C6_ACONDIC
		TRB->LANCES  := SC6->C6_LANCES
		TRB->METRAGE := SC6->C6_METRAGE
		TRB->ENTREG  := SC6->C6_ENTREG
		TRB->QTDVEN  := SC6->C6_QTDVEN
		TRB->QTDALIB := SC9->C9_QTDLIB
		TRB->LOCAL   := SC9->C9_LOCAL
		TRB->RESERVA := If(Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ),"N","S")
		TRB->REGC9   := SC9->(Recno())
		MsUnLock()

		DbSelectArea("SC9")
		DbSkip()

	EndDo
	DbSelectArea("SC9")

Return(.T.)

/*/{Protheus.doc} LibAll
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param lLibTudo, logical, descricao
@type function
/*/
Static Function LibAll(lLibTudo)
	_LinAtu := n
	Processa({|lEnd| u_LibxTdo()}, 'Analisando Dados...')
	n := _LinAtu
Return(.T.)

/*/{Protheus.doc} LibxTdo
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function LibxTdo()
	ProcRegua(Len(aCols))
	For n := 1 To Len(aCols)
		IncProc()
		_cProduto := GDFieldGet("Z5_PRODUTO",n)
		_cLocaliz := GDFieldGet("Z5_LOCALIZ",n)
		_cLocal   := GDFieldGet("Z5_LOCAL",n)
		_nQtdLib   := GDFieldGet("Z5_QTDLIB",n)
		_nQtdaLib  := GDFieldGet("Z5_QTDALIB",n)
		_nQtLoc    := Val(Substr(_cLocaliz,2,10))
		If (_nQtdaLib%_nQtLoc) == 0 // Qtd a liberar é multiplo do acondicionamento
			If !GDDeleted(n) .And. _nQtdLib == 0 .And. Left(_cLocaliz,1) # "B"


				// Novo modelo de liberação "tudo"

				// Somar o Array pra ver se já não tem quantidades liberadas em outras linhas
				_nJaLib := 0
				For _i := 1 To Len(aCols)
					If GDFieldGet("Z5_PRODUTO",_i) == _cProduto .And. GDFieldGet("Z5_LOCALIZ",_i) == _cLocaliz .And.;
					GDFieldGet("Z5_LOCAL",_i) == _cLocal .And. !GDDeleted(_i) .And. _i # n // Não é a mesma linha
						_nJaLib += GDFieldGet("Z5_QTDLIB",_i)
					EndIf
				Next

				// Posiciona cadastro do Produto
				DbSelectArea("SB1")
				DbSeek(xFilial("SB1")+_cProduto,.F.)
				_lLocaliz := (SB1->B1_LOCALIZ == "S")

				If _lLocaliz // Controla Localização?
					// Posiciona e verifica se tem quantidade a liberar no SBF
					DbSelectArea("SBF")
					DbSetOrder(1)  //BF_FILIAL+sbf->(BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If DbSeek(xFilial("SBF")+_cLocal+_cLocaliz+_cProduto,.F.)
						If (_nQtdaLib+_nJaLib) <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0
							GDFieldPut("Z5_QTDLIB" ,GDFieldGet("Z5_QTDALIB",n),n)
						EndIf
					EndIf
				Else
					// Posiciona e verifica se tem quantidade a liberar no SB2
					DbSelectArea("SB2")
					DbSetOrder(1)  //B2_FILIAL+B2_COD+B2_LOCAL
					If DbSeek(xFilial("SB2")+_cProduto+_cLocal,.F.)
						If (_nQtdaLib+_nJaLib) <= (SB2->B2_QATU - SB2->B2_RESERVA)
							GDFieldPut("Z5_QTDLIB" ,GDFieldGet("Z5_QTDALIB",n),n)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next
Return(.T.)

	/*
	Na liberação do PV tem que obedecer o múltiplo?

	Liberei credito de 10  do produto 1010602101
	soma no B2_RESERVA
	tira do B2_QPEDVEN
	soma no BF_EMPENHO
	criou registro de empenho no SDC (empenho por endereço)

	Liberei maiS 20 do produto 1010602101
	soma no B2_RESERVA
	tira do B2_QPEDVEN
	soma no BF_EMPENHO
	criou registro de empenho no SDC (empenho por endereço) Atenção para os campos
	DC_SEQ := DC_TRT := C9_SEQUEN e DC_ITEM := C9_ITEM

	Verificar A1_SALPED
	A1_SALPEDL

	Ponto de entrada na liberacao -
	MTA440L (RETORNAR O SALDO DISPONIVEL, QUE ELE TIRA E DA ZERO)
	se o produto tiver controle de localização
	*/

/*/{Protheus.doc} CalcPedVen
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _Prod, , descricao
@param _Almox, , descricao
@type function
/*/
Static Function CalcPedVen(_Prod,_Almox)
	Local _aAreaC6

	#IFDEF TOP
	_nTamBlq := Space(Len(SC6->C6_BLQ))
	cQUERY := "SELECT SUM(C6_QTDVEN - C6_QTDEMP - C6_QTDENT) AS SALDO "
	cQUERY += " FROM "+RetSqlName("SC6")
	cQUERY += " WHERE C6_FILIAL = '"+ xFILIAL("SC6")+ "'"
	cQUERY += " AND C6_PRODUTO = '" + _Prod + "'"
	cQUERY += " And C6_LOCAL = '"+_Almox+"' And C6_BLQ = '"+_nTamBlq+"' And C6_QTDEMP >= 0 AND C6_QTDENT >= 0
	cQUERY += " AND D_E_L_E_T_ <> '*'"

	TCQUERY cQuery NEW ALIAS "RSC6"

	dbSelectArea("RSC6")
	dbGoTop()
	_nVolta := RSC6->SALDO
	DbCloseArea("RSC6")
	#ELSE
	DbSelectArea("SC6")
	_aAreaC6 := GetArea()
	DbSetOrder(2) // C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
	DbSeek(xFilial("SC6")+_Prod,.F.)
	_nVolta := 0.00
	Do While SC6->C6_FILIAL == xFilial("SC6") .And.SC6->C6_PRODUTO == _Prod  .And. SC6->(!Eof())
		If SC6->C6_LOCAL == _Almox .And. Empty(SC6->C6_BLQ) .And. SC6->C6_QTDEMP >= 0 .AND. SC6->C6_QTDENT >= 0
			_nSdo := SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT
			If _nSdo > 0
				_nVolta += (SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT)
			EndIf
		EndIf
		SC6->(DbSkip())
	Enddo
	RestArea(_aAreaC6)
	#ENDIF
	DbSelectArea("SC6")

Return(_nVolta)

/*/{Protheus.doc} ValLin
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param lTemPrd, logical, descricao
@type function
/*/
User Function ValLin(lTemPrd)
	Private _cProduto := If(lTemPrd,_cProduto,GDFieldGet("Z5_PRODUTO",n))
	Private _cLocaliz := GDFieldGet("Z5_LOCALIZ",n)
	Private _nQtdLib  := GDFieldGet("Z5_QTDLIB",n)
	_Volta := .T.
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cProduto,.F.)
	If SB1->B1_LOCALIZ == "S"
		_nQtLoc := Val(Substr(_cLocaliz,2,10))
		If (_nQtdLib%_nQtLoc) # 0 .And. (!"ADMINISTRADOR" $ Upper(cUserName).and. ;
		!"Roberto" $ Upper(cUserName)) .and. SB1->B1_UM # 'KG'  // Administrador pode!!
			_Volta := .F.
			Alert("Acondicionamento não confere com a Quantidade Liberada")
		EndIf
	EndIf
Return(_Volta)

/*/{Protheus.doc} Passa
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param cVAr, characters, descricao
@type function
/*/
User Function Passa(cVAr)
	If cVar == "1"
		MV_PAR02 := MV_PAR01
	ElseIf cVar == "2"
		MV_PAR03 := MV_PAR02
	EndIf
Return(.T.)

/*/{Protheus.doc} LibMult
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function LibMult()
	If !"ADMINISTRADOR" $ Upper(cUserName) .And. !"ROBERTO" $ Upper(cUserName)
		Alert("Rotina em Desenvolvimento")
		Return(.T.)
	EndIf
	Private _cProduto := GDFieldGet("Z5_PRODUTO",n)
	Private _nQtdALib := GDFieldGet("Z5_QTDALIB",n)
	Private _cLocal   := GDFieldGet("Z5_LOCAL",n)
	Private _nQtdLib  := GDFieldGet("Z5_QTDLIB",n)
	Private _cLocaliz := GDFieldGet("Z5_LOCALIZ",n)
	Private _cPedido  := GDFieldGet("Z5_PEDIDO",n)
	Private _cItem    := GDFieldGet("Z5_ITEM",n)
	Private _cSequ    := GDFieldGet("Z5_SEQUEN",n)

	_lMult := .T.
	_aCpaHead := aClone(aHeader)
	_aCpaCols := aClone(ACols)
	_aCpaN    := N
	_nUsado   := nUsado

	nUsado:=0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SZ5")
	aHeader:={}
	While !Eof().And.(X3_ARQUIVO=="SZ5")

		If X3USO(X3_USADO) .And. cNivel>=X3_NIVEL .And. AllTrim(X3_CAMPO)$"Z5_QTDLIB//Z5_LOCALIZ//Z5_LOCAL"
			nUsado:=nUsado+1
			aAdd(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VLDUSER,;
			X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT } )
		EndIf
		DbSkip()
	EndDo

	aCols := {}
	For _x := 1 to Len(_aMultipl)
		If _aMultipl[_x,1] == _aCpaN .And. _aMultipl[_x,2] # 0.00
			AAdd(aCols,Array(4))
			GDFieldPut("Z5_QTDLIB"  ,_aMultipl[_x,2],Len(aCols))
			GDFieldPut("Z5_LOCALIZ" ,_aMultipl[_x,3],Len(aCols))
			GDFieldPut("Z5_LOCAL"   ,"01"           ,Len(aCols))
			Acols[Len(aCols),4] := .F.
		EndIf
	Next
	If Len(aCols) == 0
		AAdd(aCols,Array(4))
		GDFieldPut("Z5_QTDLIB" ,CriaVar(aHeader[GDFieldPos("Z5_QTDLIB") ,2]),1)
		GDFieldPut("Z5_LOCALIZ",CriaVar(aHeader[GDFieldPos("Z5_LOCALIZ"),2]),1)
		GDFieldPut("Z5_LOCAL"  ,CriaVar(aHeader[GDFieldPos("Z5_LOCAL")  ,2]),1)
		aCols[1,4] := .F.
	EndIf

	l_Confirma := .F.
	@ 000,000 TO 325,700 DIALOG _oLibMul TITLE "Liberação Múltipla"
	@ 005,005 Say "Produto:  "+Transform(_cProduto,"@R XXX.XX.XX.X.XX")+" - "+Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC")  Size 250,015
	@ 020,005 TO 140,345 MULTILINE MODIFY DELETE OBJECT oMultiline VALID u_ValLin(.T.)

	@ 150,258 BMPBUTTON TYPE 01 ACTION u_ButConf() // Ok
	@ 150,300 BMPBUTTON TYPE 02 ACTION Close(_oLibMul) // Cancela
	omultiline:nmax:=999
	ACTIVATE DIALOG _oLibMul CENTERED

	If l_Confirma
		// Primeiro zerar todos os dados da linha
		// Não pode zerar o _aMultipl[_x,2] antes porque o usuário pode clicar em cancelar com liberações feitas anteriormente
		For _x := 1 to Len(_aMultipl)
			If _aMultipl[_x,1] == _aCpaN
				_aMultipl[_x,2] := 0.00
			EndIf
		Next

		// Depois trato o aCols
		For _nx := 1 to Len(aCols)
			If !GDDeleted(_nx) .And. GDFieldGet("Z5_QTDLIB",_nx) > 0
				_PosMult := 0
				// Procuto por um exatamente igual não importando se está zerado
				For _x := 1 to Len(_aMultipl)
					If _aMultipl[_x,1] == _aCpaN                     .And. _aMultipl[_x,3] == GDFieldGet("Z5_LOCALIZ",_nx) .And. ;
					_aMultipl[_x,4] == GDFieldGet("Z5_LOCAL",_nx) .And. _aMultipl[_x,5] == _cProduto .And. ;
					_aMultipl[_x,6] == _cPedido                   .And. _aMultipl[_x,7] == _cItem    .And. _aMultipl[_x,8] == _cSequ

						_PosMult := _x
						Exit
					EndIf
				Next
				If _PosMult == 0
					AAdd(_aMultipl,Array(8))
					_PosMult := Len(_aMultipl)

					_aMultipl[_PosMult,1] := _aCpaN
					_aMultipl[_PosMult,2] := 0.00
					_aMultipl[_PosMult,3] := GDFieldGet("Z5_LOCALIZ",_nx)
					_aMultipl[_PosMult,4] := GDFieldGet("Z5_LOCAL",_nx)
					_aMultipl[_PosMult,5] := _cProduto
					_aMultipl[_PosMult,6] := _cPedido
					_aMultipl[_PosMult,7] := _cItem
					_aMultipl[_PosMult,8] := _cSequ
				EndIf
				_aMultipl[_PosMult,2] += GDFieldGet("Z5_QTDLIB",_nx)
			EndIf
		Next
	EndIf
	_lMult  := .F.
	aHeader := aClone(_aCpaHead)
	ACols   := aClone(_aCpaCols)
	N       := _aCpaN
	nUsado  := _nUsado
Return(.T.)


/*/{Protheus.doc} ButConf
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function ButConf()
	l_Confirma := .T.
	Close(_oLibMul)
Return(.T.)

/*/{Protheus.doc} QtdLib2
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function QtdLib2()
	Private _nRet := 0
	If _lMult // Somar o 1ro acols + 2 acols excluindo aprópria linha
		_nPos1 := _nPos2 := _nPos3 := _nPos4 := 0
		For _nx := 1 to Len(_aCpaHead)
			If AllTrim(_aCpaHead[_nx,2]) == "Z5_QTDLIB"
				_nPos4 := _nx
				Exit
			EndIf
		Next
		_nRet += _aCpaCols[_aCpaN,_nPos4]

		For _i := 1 To Len(aCols)
			If !GDDeleted(_i)
				_nRet += If(_i==n,0,GDFieldGet("Z5_QTDLIB",_i))
			EndIf
		Next
	Else // Não soma o primeiro acols.... somente o segundo pelo array _aMultiPl
		For _x := 1 to Len(_aMultipl)
			If _aMultipl[_x,1] == _aCpaN
				_nRet += _aMultipl[_x,2]
			EndIf
		Next
	EndIf

Return(_nRet)

/*/{Protheus.doc} CompE1
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function CompE1()
	DbUseArea(.T.,,"\COBRANCA\SE1.DTC"   ,"TRB1",.T.,.F.)
	IndRegua("TRB1","SE1","E1_NUM+E1_PARCELA+E1_TIPO",,, "Selecionando Registros...") //

	DbUseArea(.T.,,"\COBRANCA\SE1_SP.DTC","TRB2",.T.,.F.)
	DbGoTop()
	Do While TRB2->(!Eof())
		_cNum := AllTrim(TRB2->NUM)
		If Right(_cNum,1) $ "0123456789"
			_cParc := Space(Len(SE1->E1_PARCELA))
		Else
			_cParc := Left(Right(_cNum,1)+Space(Len(SE1->E1_PARCELA)),Len(SE1->E1_PARCELA))
			_cNum  := Left(_cNum,Len(_cNum)-1)
		EndIf
		_cNum := StrZero(Val(_cNum),6)

		If !TRB1->(DbSeek(_cNum+_cParc+"NF ",.F.))
			RecLock("TRB2",.F.)
			TRB2->SE1 := "0"
			MsUnLock()
		Else
			RecLock("TRB1",.F.)
			TRB1->E1_VALLIQ :=  TRB1->E1_VALLIQ+TRB2->VALOR
			MsUnLock()
			RecLock("TRB2",.F.)
			TRB2->SE1 := Str(Val(TRB2->SE1)+1,1)
			MsUnLock()
		EndIf
		TRB2->(DbSkip())
	EndDo
Return(.T.)

/*/{Protheus.doc} VerPedVen
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function VerPedVen() // Função ponte pra chamar a C900PedVen()
	Local aArea := GetArea()
	dbSelectArea("SC5")
	dbSetOrder(1)
	If SC5->(dbSeek(xFilial("SC5")+GDFieldGet("Z5_PEDIDO",n)))
		// Salvar a Situação do acols  e aHeader
		_aVerHead  := aClone(aHeader)
		_aVerCols  := aClone(ACols)
		_aVerN     := N
		_nVerUsado := nUsado

		u_CDFAT02V(.F.)

		//   Restaurar a situação de aCols e aHeader
		aHeader := aClone(_aVerHead)
		ACols   := aClone(_aVerCols)
		n       := _aVerN
		nUsado  := _nVerUsado
	Endif
	RestArea(aArea)
Return(.T.)

/*/{Protheus.doc} BlqEst
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function BlqEst()
	SB1->(DbSetOrder(1))

	DbSelectAreA("SF4")
	DbSetOrder(1)

	Dbselectarea("SC6")
	DbsetOrder(1)

	DbSelectArea("SDC")
	DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI

	DbSelectArea("SC9")
	DbSetOrder(1)

	DbSeek(xFilial("SC9"),.F.)

	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->(!Eof())
		If Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
			SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
			SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
			If SB1->B1_LOCALIZ == "S" .And. SF4->F4_ESTOQUE == "S"
				If !SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
					RecLock("SC9",.F.)
					SC9->C9_BLEST := "02"
					SC9->C9_STATUS:= "0"
					SC9->C9_SEQOS := "  "
					MsUnLock()
				EndIf
			EndIf
		EndIf
		SC9->(DbSkip())
	EndDo
Return(.T.)

/*/{Protheus.doc} CDEST01B
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function CDEST01B()
	if !validAcess()
		MsgAlert("Permissão Negada!")
		return(.T.)
	endif
	
	lInverte:=.F.
	cMarca := GetMark()
	DbSelectArea("SZE")
	DbSetOrder(1)
	Set Filter to ZE_STATUS $ "AP"  // Adiantadas ou a Empenhar
	DbSeek(xFilial("SZE"),.F.)
	Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->(!Eof())
		RecLock("SZE",.F.)
		SZE->ZE_OK := cMarca
		DbSkip()
	EndDo

	cCadastro:="Liberação de Bobinas"
	aRotina := {{ "Pesquisar" ,"AxPesqui" , 0 , 1},;
	{ "Visualizar","u_VisuSZE", 0 , 2},;
	{ "Adiantada?","u_AdiBob" , 0 , 2},;
	{ "Liberar"   ,"u_LibBob" , 0 , 2}}
	MarkBrow("SZE","ZE_OK","ZE_CONDIC",,@lInverte,@cMarca,,,,,)
	DbSelectArea("SZE")
	Set Filter to
	dbSetOrder(1)
	DbSelectArea("SC9")
	DbSetOrder(1)


	// Voltar o conteudo original do primeiro browse
	cCadastro := "Ordem de Separação"
	aRotina := DefMenu()

Return(.t.)

/*/{Protheus.doc} VisuSZE
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function VisuSZE()
	AxVisual("SZE",Recno(),2)
Return(.T.)

/*/{Protheus.doc} AdiBob
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function AdiBob()
	RecLock("SZE",.F.)
	SZE->ZE_CONDIC := If(SZE->ZE_CONDIC=="A"," ","A") // Adiantada ou nao
	SZE->ZE_OK := "  "
	MsUnLock()
Return(.T.)

/*/{Protheus.doc} LibBob
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function LibBob()
	If MsgYesNo("Confirma Processamento da(s) Liberação(ções)?")
		Processa({ || ProcSZEp()},"Efetuando Liberações de Pedidos de Vendas")
		Processa({ || ProcSZEa()},"Efetuando Estornos de Adiantamentos")
		
		//_aAccess := //u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		Alert("Processo Concluido")
	EndIf
Return(.T.)

/*/{Protheus.doc} ProcSZEp
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function ProcSZEp()
	local lTemPes 	:= .T.
	local lPesProc 	:= .T.
	local cAglutina := ""
	
	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM

	DbSelectArea("SC6")
	DbSetOrder(1)  //C6_FILIAL+SC6->C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SC9")
	DBOrderNickName("SC9BLQ") // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM

	DbSelectArea("SBF")
	DbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SZL")
	DbSetOrder(4) //ZL_FILIAL+ZL_NUMBOB

	DbSelectArea("SZE")
	DbSetOrder(3) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB

	_nQtdReg := 0
	DbSeek(xFilial("SZE")+"P",.F.)
	Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS == "P" .And. SZE->(!Eof())
		If Marked("ZE_OK")
			_nQtdReg++
		EndIf
		DbSkip()
	EndDo
	ProcRegua(_nQtdReg)
	DbSeek(xFilial("SZE")+"P",.F.)
	Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS == "P" .And. SZE->(!Eof())
		SC5->(DbSeek(xFilial("SC5")+SZE->ZE_PEDIDO,.F.))
		cAglutina := AllTrim(SC5->C5_ZAGLUTI)
		aBobs := {} // 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
		_cChave := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM
		Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM == _cChave .And. SZE->(!Eof())				
			if empty(SZE->ZE_SEQORIG)
				if (lTemPes := SZL->(DbSeek(xFilial("SZL")+SZE->ZE_NUMBOB,.F.)))
					lPesProc := SZL->ZL_STATUS == "P"
				endif
			endif
			If !Marked("ZE_OK")
				SZE->(DbSkip())
				Loop
			ElseIf SC5->C5_ZSTATUS $ "29" //-OK .And. !GetMv("MV_ZZUSAC9")// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento;9-Faturando
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Pedido em Faturamento"
				SZE->ZE_OK := "  "
				MsUnLock()
				SZE->(DbSkip())
				Loop
			ElseIf !(SC5->C5_TIPO $ "DB") .And. ;
			Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1' // Sim
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Cliente Bloqueado"
				SZE->ZE_OK := "  "
				MsUnLock()
				SZE->(DbSkip())
				Loop
			ElseIf SC5->C5_DTPCP == Date() .Or. SC5->C5_DTVEN == Date()
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Pedido em Alteração"
				SZE->ZE_OK := "  "
				MsUnLock()
				SZE->(DbSkip())
				Loop
			ElseIf SZE->ZE_CONDIC == "A"
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Bobina Adiantada"
				MsUnLock()
				// Não fazer nada.....
				// A proxima rotina vai dar baixa no adiantamento
				SZE->(DbSkip())
				Loop
			ElseIf !lTemPes
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Pesagem nao Localizada"
				SZE->ZE_OK := "  "
				MsUnLock()
				SZE->(DbSkip())
				Loop
			ElseIf !lPesProc // Pesagem não processada
				RecLock("SZE",.F.)
				SZE->ZE_MOTIVO := "Pesagem nao Processada"
				SZE->ZE_OK := "  "
				MsUnLock()
				SZE->(DbSkip())
				Loop
			Else // Verificar se a bobina tem a mesma metragem solicitada no pedido de venda
				If !SC6->(DbSeek(xFilial("SC6")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,.F.))
					RecLock("SZE",.F.)
					SZE->ZE_MOTIVO := "Pedido não Localizado"
					MsUnLock()
					SZE->(DbSkip())
					Loop
				ElseIf SZE->ZE_QUANT # SC6->C6_METRAGE .And. SC6->C6_UM  # "KG" //To Elektro
					RecLock("SZE",.F.)
					SZE->ZE_MOTIVO := "Metragem Diferente"
					MsUnLock()
					SZE->(DbSkip())
					Loop
				EndIf
			EndIf
			IncProc()
			// Localiza se tem outro array com as mesmas caracteristicas- ASCAN de português
			_nPosic := 0
			For _nxPosic := 1 to Len(aBobs) // 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
				If aBobs[_nxPosic,1] == SZE->ZE_PRODUTO .And. aBobs[_nxPosic,2] == SZE->ZE_PEDIDO .And.;
				aBobs[_nxPosic,3] == SZE->ZE_ITEM    .And. aBobs[_nxPosic,4] == StrZero(SZE->ZE_QUANT,5)
					_nPosic := _nxPosic
					Exit
				EndIf
			Next

			// Se nao achou outro array adiciona um elemento no array
			If _nPosic == 0
				AADD(aBobs,{SZE->ZE_PRODUTO,SZE->ZE_PEDIDO,SZE->ZE_ITEM,StrZero(SZE->ZE_QUANT,5),0,""})
				_nPosic := Len(aBobs)
			EndIf

			// Grava quantidade e nro da bobina
			aBobs[_nPosic,5] += SZE->ZE_QUANT
			aBobs[_nPosic,6] := aBobs[_nPosic,6] + SZE->ZE_NUMBOB
			SZE->(DbSkip())
			//Individual gera uma liberação por Bobina
			if cAglutina == 'I'
				EXIT
			endif
		EndDo

		// Guarda a chave do proximo registro
		_cChave := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM+SZE->ZE_NUMBOB // Quardo a chave do registro atual

		// Trata o array criado
		For _nBobs := 1 to Len(aBobs) // Se tenho o que Ver

			//Monta a variável da localização
			_cLocaliz := Left(("B" + aBobs[_nBobs,4] + Space(300)),Len(SBF->BF_LOCALIZ))

			If SBF->(DbSeek(xFilial("SBF")+"01"+_cLocaliz+aBobs[_nBobs,1],.F.))
				//BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

				If (SBF->BF_QUANT-SBF->BF_EMPENHO) > 0 .And. SBF->BF_EMPENHO >=0
					// Dá pra fazer alguma liberação?
					Reclock("SBF",.F.)
					_nQtdRes := (SBF->BF_QUANT-SBF->BF_EMPENHO)
					SBF->BF_EMPENHO := SBF->BF_QUANT
					MsUnLock()

					// 	Aglutinar SC9
					SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					SC9->(DbSeek(xFilial("SC9")+aBobs[_nBobs,2]+aBobs[_nBobs,3],.F.))
					_nQtdSC9 := 0
					_nRegsC9 := 0
					_cSeq := Replicate("Z",Len(SC9->C9_SEQUEN))
					_lErroC9 := .F.
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == aBobs[_nBobs,2]+aBobs[_nBobs,3] .And. SC9->(!Eof())
						If (SC9->C9_BLCRED + SC9->C9_BLEST) == "  02"
							_nQtdSC9 += SC9->C9_QTDLIB
							_nRegsC9++
							If _cSeq > SC9->C9_SEQUEN
								_cSeq := SC9->C9_SEQUEN
							EndIf
							If aBobs[_nBobs,1] # SC9->C9_PRODUTO
								_lErroC9 := .T.
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo

					If _nRegsC9 > 1 .And. !_lErroC9 // Se vi mais de 1 registro no SC9
						// Grava a quantidade total em um único SC9
						SC9->(DbSeek(xFilial("SC9")+aBobs[_nBobs,2]+aBobs[_nBobs,3],.F.))
						Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == aBobs[_nBobs,2]+aBobs[_nBobs,3] .And. SC9->(!Eof())
							If (SC9->C9_BLCRED + SC9->C9_BLEST) == "  02"
								RecLock("SC9",.F.)
								If SC9->C9_SEQUEN == _cSeq
									SC9->C9_QTDLIB := _nQtdSC9
								Else
									SC9->(DbDelete())
								EndIf
								MsUnLock()
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf

					DbSelectArea("SC9")
					DBOrderNickName("SC9BLQ") // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM

					// aBobs = 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
					_nLib := Min(aBobs[_nBobs,5],(_nQtdRes)) // Pelo saldo, quanto dá pra liberar?

					If SC9->(DbSeek(xFilial("SC9") + "  02" + aBobs[_nBobs,2] + aBobs[_nBobs,3],.F.)) .And. !_lErroC9

						_nALib := Min(_nLib,SC9->C9_QTDLIB)
						// Não sei porque havia inibido esta linha onde compara se a quantidade é maior
						// que a quantidade liberada.... e deixei a linha abaixo.....
						// hoje estou revertendo na situação em que foi produzida duas bobinas para o mesmo pedido/item
						// o sistema tem que liberar somente uma.
						// _nALib := _nLib

						_nDaPra := Int(_nALib / Val(aBobs[_nBobs,4]))
						_nALib := _nDaPra*Val(aBobs[_nBobs,4])
						If _nALib > 0
							_cSeq := SC9->C9_SEQUEN
							// Volto a quantidade para poder liberar
							Reclock("SBF",.F.)
							SBF->BF_EMPENHO -= _nQtdRes
							MsUnLock()
							_nQtdRes := 0.00

							// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
							// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
							// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
							U_CDLibEst("L",SC9->C9_PRODUTO,_nALib,SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"3")


							//Gravar os Registros do SZE como liberados
							_nQtdSC9 := 0.00

							_BobsGrv := AllTrim(aBobs[_nBobs,6])
							_nQtdBos := Len(_BobsGrv) / 7

							DbSelectArea("SZE")
							DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
							For _nGrava := 1 to _nQtdBos
								_nNumBob := Left(_BobsGrv,7)
								If Len(_BobsGrv) == 7
									_BobsGrv := ""
								Else
									_BobsGrv := Substr(_BobsGrv,8,Len(_BobsGrv)-7)
								EndIf

								If SZE->(DbSeek(xFilial("SZE")+_nNumBob,.F.))
									RecLock("SZE",.F.)
									If _nGrava <= _nDaPra
										SZE->ZE_STATUS := "E" //Empenhada
										SZE->ZE_MOTIVO := " "
										SZE->ZE_DTLIB  := Date()
										SZE->ZE_HRLIB  := Left(Time(),Len(SZE->ZE_HRLIB))
									Else
										SZE->ZE_MOTIVO := "Sem Saldo em Estoque" //lIBERADO
									EndIf
									SZE->ZE_OK := "  "
									MsUnLock()
								EndIf
							Next
						EndIf
					Else // Nao achei SC9 para liberar....
						If _lErroC9
							GraveSZE("Pedido/Item Errado")
						Else
							GraveSZE("Nao Liberado no SC9")
						EndIf
					EndIf
					If _nQtdRes > 0.00
						Reclock("SBF",.F.)
						SBF->BF_EMPENHO -= _nQtdRes
						MsUnLock()
					EndIf
				EndIf
			Else // Se nao achou nada no SBF- Saldo

				//Gravar os Registros do SZE como sem saldo para liberar
				GraveSZE("Sem Saldo em Estoque")
			EndIf
		Next
		DbSelectArea("SZE")
		dbSetOrder(3)
		DbSeek(xFilial("SZE") + _cChave,.F.) //  := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM // Quardo a chave do registro atual
	EndDo
Return(.T.)

/*/{Protheus.doc} ProcSZEa
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function ProcSZEa()
	DbSelectArea("SZH")  // Controle de Adiantamentos
	DbSetOrder(2) // ZH_FILIAL+ZH_STATUS+ZH_PRODUTO+ZH_LOCAL+ZH_LOCALIZ

	DbSelectArea("SZE")
	DbSetOrder(3) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
	_nQtdReg := 0
	DbSeek(xFilial("SZE")+"P",.F.)
	Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS == "P" .And. SZE->(!Eof())
		_nQtdReg++
		DbSkip()
	EndDo
	_nProxZE := 0
	ProcRegua(_nQtdReg)
	DbSeek(xFilial("SZE")+"P",.F.)
	Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS == "P" .And. SZE->(!Eof())
		IncProc()
		If SZE->ZE_CONDIC # "A" // Não é bobina adiantada
			MsUnLock()
			SZE->(DbSkip())
			Loop
		EndIf

		// Verifico se tem adiantamento em aberto para esse produto/acondicionamnto
		_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(10),Len(SBF->BF_LOCALIZ))

		DbSelectArea("SZH") // Ordem: ZH_FILIAL+ZH_STATUS+ZH_PRODUTO+ZH_LOCAL+ZH_LOCALIZ
		DbSeek(xFilial("SZH")+"A"+SZE->ZE_PRODUTO+"01"+_cLocaliz,.F.)
		Do While SZH->ZH_FILIAL == xFilial("SZH") .And. SZH->ZH_STATUS == "A" .And. SZH->ZH_PRODUTO == SZE->ZE_PRODUTO .And. ;
		SZH->ZH_LOCAL == "01" .And. SZH->ZH_LOCALIZ ==_cLocaliz .And. SZH->(!Eof())

			If SZH->ZH_SALDO >= SZE->ZE_QUANT .And. SZH->ZH_PEDIDO == SZE->ZE_PEDIDO //.AND. SZH->ZH_ITEMPV == SZE->ZE_ITEM
				// Verificar se tem saldo em estoque para fazer o movimento
				DbSelectArea("SBF")
				DbSetOrder(1)
				DbSeek(xFilial("SBF")+"01"+_cLocaliz+SZE->ZE_PRODUTO,.F.)
				If SBF->(!Eof()) .And. (SBF->BF_QUANT-SBF->BF_EMPENHO) >= SZE->ZE_QUANT .And. SBF->BF_EMPENHO >= 0

					// Fazer o movimento 508
					SB1->(DbSeek(xFilial("SB1")+SZH->ZH_PRODUTO,.F.))
					_aVetor:={{"D3_TM"      , "508"           ,NIL},;
					{"D3_COD"     , SZH->ZH_PRODUTO ,NIL},;
					{"D3_UM"      , SB1->B1_UM      ,NIL},;
					{"D3_QUANT"   , SZE->ZE_QUANT   ,NIL},;
					{"D3_LOCAL"   , "01"            ,NIL},;
					{"D3_EMISSAO" , dDataBase       ,NIL},;
					{"D3_LOCALIZ" , _cLocaliz       ,NIL}}

					lMsErroAuto := .F.
					_xVolta := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)

					If _xVolta
						_xVolta := .F.

						// Guardar o próximo registro porque vou mudar o status e a ordem é por essa chave
						DbSelectArea("SZE")
						SZE->(DbSkip())
						_nProxZE := SZE->(Recno())
						SZE->(DbSkip(-1))

						// Alterar SZE
						RecLock("SZE",.F.)
						SZE->ZE_MOTIVO := "Bobina Adiantada"
						SZE->ZE_OK := "  "
						SZE->ZE_STATUS := "F" // Adiantada
						MsUnLock()

						RecLock("SZH",.F.)
						SZH->ZH_SALDO := SZH->ZH_SALDO - SZE->ZE_QUANT
						If SZH->ZH_SALDO == 0.00
							SZH->ZH_STATUS := "B'
						EndIf
						MsUnLock()
					EndIf

					// Sair do Loop
					Exit // Não pode dar DbSkip no SZH senão baixa outro adiantamento com a mesma bobina
				EndIf
			EndIf
			SZH->(DbSkip())
		EndDo
		DbSelectArea("SZE")
		If _nProxZE == 0
			DbSkip()
		Else
			DbGoTo(_nProxZE)
			_nProxZE := 0
		EndIf
	EndDo
Return(.T.)

/*/{Protheus.doc} GraveSZE
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _cMotivo, , descricao
@type function
/*/
Static Function GraveSZE(_cMotivo)
	_BobsGrv := AllTrim(aBobs[_nBobs,6])
	DbSelectArea("SZE")
	DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
	Do While Len(_BobsGrv) > 0
		_nNumBob := Left(_BobsGrv,7)
		If Len(_BobsGrv) == 7
			_BobsGrv := ""
		Else
			_BobsGrv := Substr(_BobsGrv,8,Len(_BobsGrv)-7)
		EndIf
		If SZE->(DbSeek(xFilial("SZE")+_nNumBob,.F.))
			RecLock("SZE",.F.)
			SZE->ZE_MOTIVO := _cMotivo
			SZE->ZE_OK := "  "
			MsUnLock()
		EndIf
	EndDo
Return(.T.)

/*/{Protheus.doc} ProcGer
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function ProcGer()
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("TRB")
	DbSetOrder(2) // Dtos(ENTREG)+PEDIDO+ITEM+SEQUEN

	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB->(!Eof())
		IncProc()

		// Agora vamos liberar somente o que é curva
		// Porém somenmte o que dá 100 do pedido

		// Curva A compreende:
		// Fio  do 1,5 ao 10    		10104 a0 10108
		// Flex do 0,50 ao 35			11501 ao 11511
		// Plasticom do 6 ao 35			11007 ao 11011
		// Paralelo do 2x0,50 ao 2x4	12001 ao 12006
		// Torcido do 2x1 ao 2x4        12201 ao 12206
		If (_cCodPrd >= "10104" .And. _cCodPrd <= "10108") .Or. (_cCodPrd >= "11501" .And. _cCodPrd <= "11511") .Or.;
		(_cCodPrd >= "11007" .And. _cCodPrd <= "11011") .Or. (_cCodPrd >= "12001" .And. _cCodPrd <= "12006") .Or.;
		(_cCodPrd >= "12201" .And. _cCodPrd <= "12206") // O produto está dentro da curva

			// Verificar se o acondicionamento corresponde a cusrva -> Rolos de 100 mts ou carretéis
			If (TRB->ACONDIC == "R" .And. TRB->METRAGE == 100) .Or. TRB->ACONDIC $ "CM"

				// Não Fazer a liberação agora
				DbSelectArea("TRB")
				DbSkip()
				Loop
			EndIf
		EndIf

		SC9->(DbGoTo(TRB->REGC9))
		If SC9->(!Deleted()) .And. (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02" .And. !TRB->ACONDIC $ "TB" // Bobinas e retalhos são obrigatoriamente liberados manualmente
			For _nxxy := 1 to 2
				If _nxxy == 1
					_cLocaliz := Left(TRB->ACONDIC+StrZero(TRB->METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
				Else
					SC9->(DbGoTo(TRB->REGC9))
					If SC9->(!Deleted()) .And. (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02" .And. TRB->ACONDIC == "R" .And. TRB->METRAGE < 100
						// Verificar se tem retalhos
						_cLocaliz := Left("T"+StrZero(TRB->METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
					Else
						Exit
					EndIf
				EndIf
				DbSelectArea("SBF")
				If	DbSeek(xFilial("SBF")+TRB->LOCAL+_cLocaliz+TRB->PRODUTO,.F.)
					_nLib:= Min(TRB->QTDALIB,If(SBF->BF_EMPENHO>=0,(SBF->BF_QUANT - SBF->BF_EMPENHO),0))
					_nLocaliz := Val(Right(_cLocaliz,Len(_cLocaliz)-1))
					_nLib:= Int(_nLib / _nLocaliz) * _nLocaliz
					If _nLib > 0.00
						_nALib := Int(_nLib / TRB->METRAGE) * TRB->METRAGE
						If _nALib > 0.00
							If (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02"

								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
								U_CDLibEst("L",TRB->PRODUTO,_nLib,TRB->LOCAL,_cLocaliz,SC9->C9_PEDIDO,TRB->ITEM,TRB->SEQUEN,,,"4")

							EndIf
						EndIf
					EndIf
				EndIf
			Next
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	DbSelectArea("TRB")
Return(.T.)

/*/{Protheus.doc} fEstorno
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function fEstorno()
	local aCanCancel := {}
	local cActPed	 := ''
	Local oStatic    := IfcXFun():newIfcXFun()
	
	//fPack("SDC")//Tenta fazer um pack na tabela

	DbSelectArea("SB1")
	DbSetOrder(1)  //B1_FILIAL+B1_COD

	DbSelectArea("SC6")
	DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO

	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SBF")
	DbSetOrder(1)

	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SDC")
	DbSetOrder(1)

	ProcRegua(LastRec())
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		IncProc()
		if AllTrim(cActPed) <> AllTrim(SDC->DC_PEDIDO)
			cActPed := AllTrim(SDC->DC_PEDIDO)
			aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(SDC->DC_PEDIDO))
		endif		
		if !aCanCancel[01]
			SDC->(DbSkip())
			Loop
		endif
		If 	SDC->DC_ORIGEM # "SC6" .Or. (SDC->DC_FILIAL == "02" .And. SDC->DC_LOCAL == "10")
			SDC->(DbSkip())
			Loop
		EndIf

		DbSelectArea("SC6")
		DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO
		If !(DbSeek(xFilial("SC6")+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.))
			SDC->(DbSkip())
			Loop
		EndIf

		If !(Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ)) // Não estorna o que estiver reservado
			SDC->(DbSkip())
			Loop
		EndIf

		//Não estornar quando material é retorno de industrialização.
		//Juliana - 01/08/2016
		If SC6->C6_FILIAL == '02' .And. !Empty(SC6->C6_ZZPVORI)
			SDC->(DbSkip())
			Loop
		EndIf

		//LEO 19/07/16 - PORTAL
		If Left(SC6->C6_SEMANA,3) == "ZP4" .Or. !Empty(SC6->C6_ZZNRRES)
			// Pedidos com origem no Portal - Leonardo/Roberto 21/03/2016
			SDC->(DbSkip())
			Loop
		EndIf

		DbSelectArea("SC5")
		DbSetOrder(1)
		If !(DbSeek(xFilial("SC5")+SDC->DC_PEDIDO,.F.))
			SDC->(DbSkip())
			Loop
		EndIf

		If SC5->C5_ZSTATUS > Padr("0", TamSx3('C5_ZSTATUS')[1])//-OK .And. !GetMv("MV_ZZUSAC9") // No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
			SDC->(DbSkip())
			Loop
		EndIf

		If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
			// By Roberto Oliveira 
			// Antes não estornava os pedidos priorizados
			If SC5->C5_TIPOLIB $ "PM" // Não estorna pedidos com lib. Prioritária ou Manual
				SDC->(DbSkip())
				Loop
			EndIf
		Else
			If SC5->C5_TIPOLIB == "M" // Não estorna pedidos com lib. Manual
				SDC->(DbSkip())
				Loop
			EndIf
		EndIf

		If SC5->C5_ENTREG < date() // Não estorna pedidos que estejam com entrega atrasada
			SDC->(DbSkip())
			Loop
		EndIf

		If Left(SDC->DC_LOCALIZ,1) $ "BT" // Bobinas e Retalhos não são estornados
			SDC->(DbSkip())
			Loop
		EndIf

		If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
			// By Roberto Oliveira
			// Condição desconsiderada a partir desta data 
			If !Empty(SC5->C5_SEMANA) // Se foi incluido em um resumo -> estorna só o que é curva.
				// Se não está em resumo estorna tudo.
				_cCodPrd :=	Left(SDC->DC_PRODUTO,5)
				// Estorno das liberações de Curva A
				If !u_fCurvaA(_cCodPrd, SDC->DC_LOCALIZ,.F.)
					// Somente estorna produtos que sejam CURVA "A" mesmo que estejam em um resumo
					SDC->(DbSetOrder(1))
					SDC->(DbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		_RegAtu := SDC->(Recno())

		SDC->(DbSkip())
		_PrxReg := SDC->(Recno())

		SDC->(DbGoTo(_RegAtu))
		SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.))
		// Não estorna se a liberação for por reserva

		If SC9->C9_TPLIB == "R"
			SDC->(DbSkip())
			Loop
		EndIf

		U_CDLibEst("E",SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ,.F.)

		DbSelectArea("SDC")
		DbSetOrder(1)
		SDC->(DbGoTo(_PrxReg))
	EndDo
	//fPack("SDC")//Tenta fazer um pack na tabela
Return(.T.)

Static Function fLibera()
	Local nTam        := TamSX3("BF_LOCALIZ")[1]
	local cAglutina	  := ""
	local cSequenc 	  := ""
	local nQtdLibs 	  := 0
	local nX		  := 0
	Private _cCodPrd  := ""
	Private _cLocaliz := ""
	Private nSaldo    := 0
	Private aPedidos  := {}

	Dbselectarea("SF4")
	DbsetOrder(1)

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	For nI := 0 to 5

		/*/
		0-Pedidos atrasados / Reservados Vendas
		1-Pedidos PRIORIZADOS
		2-Pedidos com produtos NÃO curva 'A' já programados pelo PCP
		3-Pedidos somente quando atingem 100% do pedido
		4-Pedidos que somem R$ 3.000,00 e restem outros R$ 3.000,00 de saldo // até 15/06/11

		4-Pedidos que somem R$ 4.000,00 e restem outros R$ 4.000,00 de saldo
		// em 15/06/11 Welington e Claudecir pediram para alterar para R$ 4.000,00

		5-Liberação Geral.
		/*/

		If Date() >= Ctod("18/10/2016") .And. (FWCodEmp()+FWCodFil() == "0101") /// Cobrecom Itu
			// By Roberto Oliveira 
			// Com a nova sistemática de liberação, as fazes 2, 3 e 4 não são realizadas.
			// Da fase 1 já pula para a fase 5
			If nI == 2
				nI := 5
			EndIf
		EndIf

		if nI := 5
			if GetNewPar('ZZ_LNEWLIB',.T.)
				if MsgNoYes("Deseja executar a <b>simulação</b> de liberação na nova rotina?","Homologação")
					u_zBeginLib()
				endif
			endif
		endif

		_nQtdRegs := fQuery(nI)

		ProcRegua(_nQtdRegs)
		TRB->(DbGoTop())
		Do While !TRB->(Eof())  // .And. .f.

			// Mesmo se passou pedidos com C5_ZSTATUS # "0"
			// Não considerar
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5") + TRB->PEDIDO,.F.))
			If SC5->C5_DTPCP == Date() .Or. SC5->C5_DTVEN == Date() .Or. SC5->C5_ZSTATUS > "0" // -OK .Or. (SC5->C5_ZSTATUS # "0" .And. !GetMv("MV_ZZUSAC9"))
				// SC5->C5_DTPCP -> Pedido está liberado para alteração
				// SC5->C5_DTVEN -> Dt.Lib.Venda -> LIBERADO HOJE?
				// SC5->C5_ZSTATUS ->  "0"=NORMAL
				IncProc()
				TRB->(DbSkip())
				Loop
			EndIf

			cAglutina := AllTrim(SC5->C5_ZAGLUTI)

			If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
				// By Roberto Oliveira
				// Com a nova sistemática, não importa se o cliente está com bliqueio

				// Verifica se o cliente está com o carastro bloqueado
				If !(SC5->C5_TIPO $ "DB") .And. Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1' // Sim
					IncProc()
					TRB->(DbSkip())
					Loop
				EndIf
			EndIf

			// Verifica se tem reserva para esse pedido de venda com DC_ORIGEM == "SDC"
			SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

			SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL

			SDC->(DbSetOrder(5))  //DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
			SDC->(DbSeek(xFilial("SDC")+TRB->PEDIDO,.F.))
			_lEstor := .T.
			Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == TRB->PEDIDO .And. SDC->(!Eof())
				If SDC->DC_ORIGEM == "SDC"
					If dDataBase > SDC->DC_DTLIB
						SBF->(DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))
						SB2->(DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.))

						If RecLock("SDC",.F.)
							_nQtdEst := SDC->DC_QUANT
							SDC->(DbDelete())
							SDC->(MsUnLock())

							RecLock("SBF",.F.)
							SBF->BF_EMPENHO := SBF->BF_EMPENHO - _nQtdEst
							SBF->(MsUnLock())

							RecLock("SB2",.F.)
							SB2->B2_RESERVA := SB2->B2_RESERVA - _nQtdEst
							SB2->(MsUnLock())
						Else
							_lEstor := .F.
							Exit
						EndIf
					Else
						_lEstor := .F.
						Exit
					EndIf
				EndIf
				SDC->(DbSkip())
			EndDo
			If !_lEstor
				IncProc()
				TRB->(DbSkip())
				Loop
			EndIf

			If nI == 3 .Or. nI == 4
				// nOpcao == 3  // 3- TODOS OS PRODUTOS DESDE QUE ATINJAM 100% DO PEDIDO
				// nOpcao == 4  // 4- TODOS OS PRODUTOS DESDE QUE ATINJAM R$ 4.000,00 e sobrem outros R$ 4.000,00 de saldo

				_nTotPv := 0.00
				_nTotLb := 0.00

				If nI == 4 //4- TODOS OS PRODUTOS DESDE QUE ATINJAM R$ 4.000,00 e sobrem outros R$ 4.000,00 de saldo

					// Primeiro somar o total desse pedido e quanto dele está liberado

					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9") + TRB->PEDIDO,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == TRB->PEDIDO .And. SC9->(!Eof())

						Dbselectarea("SC6")
						DbsetOrder(1)
						DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)

						If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TESORI,"F4_ESTOQUE") == "S"
							If SC9->C9_BLEST # "10" // Não Faturado
								_nTotPv += (SC9->C9_QTDLIB * SC6->C6_PRCVEN) // Soma no total do pedido
								If Empty(SC9->C9_BLEST)
									_nTotLb += (SC9->C9_QTDLIB * SC6->C6_PRCVEN) // Soma no total liberado
								EndIf
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo
				EndIf

				_cPedido := TRB->PEDIDO
				aPedidos := {}
				lLibera := .T.

				Do While TRB->PEDIDO == _cPedido .And. TRB->(!Eof())
					_cProd  := TRB->PRODUTO
					_cLocal := TRB->ALMOX
					_cAcond := TRB->ACONDIC
					_cMetra := TRB->METRAGE
					_cLocaliz := Left(Alltrim(TRB->ACONDIC)+StrZero(TRB->METRAGE,5)+Space(nTam),nTam)
					_nQuantC9 := 0

					Do While TRB->PEDIDO  ==  _cPedido .And. TRB->PRODUTO == _cProd .And. TRB->ALMOX == _cLocal .And. ;
					TRB->ACONDIC == _cAcond   .And. TRB->METRAGE == _cMetra .And. TRB->(!Eof())
						IncProc()
						// Verifica se o C9 ainda está nas mesmas condições de quando foi "SELETADO"
						DbSelectArea("SC9")
						DbSetOrder(1) // C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO
						If DbSeek(xFilial("SC9")+TRB->PEDIDO+TRB->ITEM+TRB->SEQUEN+TRB->PRODUTO,.F.)
							If Empty(SC9->C9_BLCRED) .And. SC9->C9_BLEST == '02'
								_nQuantC9 += TRB->QTDALIB
								aAdd(aPedidos, {TRB->PEDIDO,TRB->ITEM,TRB->SEQUEN,TRB->PRODUTO,_cLocaliz,_cLocal})
							EndIf
						EndIf
						TRB->(DbSkip())
					EndDo

					// Verifica se tem saldo para liberação

					nSaldo := 0
					nSdRet := 0
					DbSelectArea("SBF")
					DbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If DbSeek(xFilial("SBF")+_cLocal+_cLocaliz+_cProd,.F.)
						nSaldo := If(SBF->BF_EMPENHO>=0,(SBF->BF_QUANT - SBF->BF_EMPENHO),0)
					EndIf
					If Left(_cLocaliz,1) $ "TR" .And. Val(Right(_cLocaliz,Len(_cLocaliz)-1)) < 100
						// Se for rolo, procurar retalho ou inverso
						_cLocz2 := If(Left(_cLocaliz,1) == "T","R","T") + Right(_cLocaliz,Len(_cLocaliz)-1)
						If DbSeek(xFilial("SBF")+_cLocal+_cLocz2+_cProd,.F.)
							nSdRet := If(SBF->BF_EMPENHO>=0,(SBF->BF_QUANT - SBF->BF_EMPENHO),0)
						EndIf
					EndIf

					If nI == 3
						//VERIFICAR SE 100% DO PV TEM EM ESTOQUE
						If lLibera .And. nSaldo < _nQuantC9 .And. nSdRet < _nQuantC9
							// Não tem em um nem em outro
							lLibera := .F.
							// Exit - Não pode dar Exit -> tem que ir até o fim desse pedido no TRB
							// Corre o Resto do TRB do mesmo pedido
							Do While TRB->PEDIDO == _cPedido .And. TRB->(!Eof())
								TRB->(DbSkip())
							EndDo
						EndIf
					Else // Só pode ser nI == 4
						If nSaldo >= _nQuantC9 .Or. nSdRet >= _nQuantC9
							// Tem em um dos dois
							_nTotLb += _nQuantC9
						EndIf
					EndIf
				EndDo

				If nI == 4
					lLibera := (_nTotLb >= 4000 .And. (_nTotPv-_nTotLb) >= 4000)
					// lLibera := (_nTotLb >= 3000 .And. (_nTotPv-_nTotLb) >= 10000)
				EndIf
				If lLibera
					For _nPsArray := 1 To Len(aPedidos)
						DbSelectArea("SC9")
						DbSetOrder(1) // C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO
						If DbSeek(xFilial("SC9") + aPedidos[_nPsArray,1] + aPedidos[_nPsArray,2] + aPedidos[_nPsArray,3] + aPedidos[_nPsArray,4],.F.)
							DbSelectArea("SBF")
							DbSetOrder(1) //BF_FILIAL+SBF->BF_LOCAL+SBF->BF_LOCALIZ+SBF->BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
							SBF->(DbSeek(xFilial("SBF")+aPedidos[_nPsArray,6]+aPedidos[_nPsArray,5]+aPedidos[_nPsArray,4],.F.))
							If !Empty(TRB->NRORES+TRB->ITERES) // Já tem reserva do material por vendas
								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
								if cAglutina == 'I'
									cSequenc := SC9->C9_SEQUEN
									nQtdLibs := (SC9->C9_QTDLIB / Val(AllTrim(Substr(AllTrim(aPedidos[_nPsArray,5]), 2, len(AllTrim(aPedidos[_nPsArray,5]))))))
									for nX := 1 to nQtdLibs
										U_CDLibEst("L",SC9->C9_PRODUTO,(SC9->C9_QTDLIB / nQtdLibs),SC9->C9_LOCAL,aPedidos[_nPsArray,5],SC9->C9_PEDIDO,SC9->C9_ITEM,cSequenc,,,"D")
										cSequenc := getC9Seq(SC9->C9_PEDIDO, SC9->C9_ITEM)
									next nX
								else
									U_CDLibEst("L",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,aPedidos[_nPsArray,5],SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"D")
								endif

							ElseIf (SBF->BF_QUANT - SBF->BF_EMPENHO) >= SC9->C9_QTDLIB .And. SBF->(!Eof()) .And. SBF->BF_EMPENHO >=0
								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.

								// Libertar somente o múltiplo do acondicionamento
								_nTmLce := Val(Substr(aPedidos[_nPsArray,5],2,5))
								_nQtdALib := Int((SC9->C9_QTDLIB / _nTmLce))
								_nQtdALib := (_nQtdALib * _nTmLce)
								If _nQtdALib > 0
									if cAglutina == 'I'
										cSequenc := SC9->C9_SEQUEN
										nQtdLibs := Int((_nQtdALib / _nTmLce))
										for nX := 1 to nQtdLibs
											U_CDLibEst("L",SC9->C9_PRODUTO,(_nQtdALib / nQtdLibs),SC9->C9_LOCAL,aPedidos[_nPsArray,5],SC9->C9_PEDIDO,SC9->C9_ITEM,cSequenc,,,"5")
											cSequenc := getC9Seq(SC9->C9_PEDIDO, SC9->C9_ITEM)
										next nX
									else
										U_CDLibEst("L",SC9->C9_PRODUTO,_nQtdALib,SC9->C9_LOCAL,aPedidos[_nPsArray,5],SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"5")
									endif									
								EndIf
								//U_CDLibEst("L",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,aPedidos[_nPsArray,5],SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"5")

							ElseIf Left(aPedidos[_nPsArray,5],1) $ "TR" .And. Val(Right(aPedidos[_nPsArray,5],Len(aPedidos[_nPsArray,5])-1)) < 100
								// Se for rolo ou retalho menor que 100 metros
								// Não efetuou a liberação no If anterior, verificar se tem como Rolo/reTalho
								_cLocz2 := If(Left(aPedidos[_nPsArray,5],1) == "T","R","T") + Right(aPedidos[_nPsArray,5],Len(aPedidos[_nPsArray,5])-1)

								// Libertar somente o múltiplo do acondicionamento
								_nTmLce := Val(Substr(_cLocz2,2,5))
								_nQtdALib := Int((SC9->C9_QTDLIB / _nTmLce))
								_nQtdALib := (_nQtdALib * _nTmLce)

								SBF->(DbSeek(xFilial("SBF")+aPedidos[_nPsArray,6]+_cLocz2+aPedidos[_nPsArray,4],.F.))
								If (SBF->BF_QUANT - SBF->BF_EMPENHO) >= _nQtdALib .And. SBF->(!Eof()) .And. ;
								SBF->BF_EMPENHO >=0 .And. _nQtdALib > 0

									// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
									// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
									// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
									if cAglutina == 'I'
										cSequenc := SC9->C9_SEQUEN
										nQtdLibs := Int((_nQtdALib / _nTmLce))
										for nX := 1 to nQtdLibs
											U_CDLibEst("L",SC9->C9_PRODUTO,(_nQtdALib / nQtdLibs),SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,cSequenc,,,"C")
											cSequenc := getC9Seq(SC9->C9_PEDIDO, SC9->C9_ITEM)
										next nX
									else
										U_CDLibEst("L",SC9->C9_PRODUTO,_nQtdALib,SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"C")
									endif	
									// U_CDLibEst("L",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"C")
								EndIf
							EndIf
						EndIf
					Next
				EndIf
			Else
				// nOpcao == 0  // 0- Atrasados
				// nOpcao == 1  // 1- PRIORITARIO
				// nOpcao == 2  // 2- NÃO É CURVA "A" E JÁ INCLUIDOS EM RESUMO DE PRODUÇÃO
				// nOpcao == 5  // 5- TODO RESTO

				IncProc()
				_cCodPrd  := Left(TRB->PRODUTO,5)
				_cLocaliz := Left(Alltrim(TRB->ACONDIC)+StrZero(TRB->METRAGE,5)+Space(nTam),nTam)
				_cLocal   := TRB->ALMOX
				lLibera   := .T.

				If nI == 2 //Liberar somente produtos que não pertençam a CURVA "A"
					lLibera := (!u_fCurvaA(_cCodPrd, _cLocaliz,.F.))
				EndIf

				If lLibera
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO
					If DbSeek(xFilial("SC9")+TRB->PEDIDO+TRB->ITEM+TRB->SEQUEN+TRB->PRODUTO,.F.)
						DbSelectArea("SBF")   // AQUI1 PERGUNTAR SE AINDA ESTA BLOQUEADO PELO ESTOQUE
						DbSetOrder(1) //BF_FILIAL+SBF->BF_LOCAL+SBF->BF_LOCALIZ+SBF->BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
						SBF->(DbSeek(xFilial("SBF")+_cLocal+_cLocaliz+TRB->PRODUTO,.F.))
						//					If (SBF->BF_QUANT - SBF->BF_EMPENHO) >= SC9->C9_QTDLIB .And. SBF->(!Eof())
						If (SBF->BF_QUANT - SBF->BF_EMPENHO) > 0 .And. SBF->(!Eof()) .And. SBF->BF_EMPENHO >=0

							_nTmLce := Val(Substr(_cLocaliz,2,5))
							// Pega o menor dos dois
							_nQtdALib := Min(SC9->C9_QTDLIB,(SBF->BF_QUANT - SBF->BF_EMPENHO))
							// Libertar somente o múltiplo do acondicionamento
							_nQtdALib := Int((_nQtdALib / _nTmLce))
							_nQtdALib := (_nQtdALib * _nTmLce)
							If _nQtdALib > 0
								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
								if cAglutina == 'I'
									cSequenc := SC9->C9_SEQUEN
									nQtdLibs := Int((_nQtdALib / _nTmLce))
									for nX := 1 to nQtdLibs
										U_CDLibEst("L",SC9->C9_PRODUTO,(_nQtdALib / nQtdLibs),;
												SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,cSequenc,,,"6")
										cSequenc := getC9Seq(SC9->C9_PEDIDO, SC9->C9_ITEM)
									next nX
								else
									U_CDLibEst("L",SC9->C9_PRODUTO,_nQtdALib,;
												SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"6")
								endif
								//U_CDLibEst("L",SC9->C9_PRODUTO,Min(SC9->C9_QTDLIB,(SBF->BF_QUANT - SBF->BF_EMPENHO)),;
								//	       SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"6")
							EndIf
						ElseIf Left(_cLocaliz,1) $ "TR" .And. Val(Right(_cLocaliz,Len(_cLocaliz)-1)) < 100
							// Se for rolo ou retalho menor que 100 metros
							_cLocz2 := If(Left(_cLocaliz,1) == "T","R","T") + Right(_cLocaliz,Len(_cLocaliz)-1)
							SBF->(DbSeek(xFilial("SBF")+_cLocal+_cLocz2+TRB->PRODUTO,.F.))
							If (SBF->BF_QUANT - SBF->BF_EMPENHO) > 0 .And. SBF->(!Eof()) .And. SBF->BF_EMPENHO >=0

								_nTmLce := Val(Substr(_cLocz2,2,5))
								// Pega o menor dos dois
								_nQtdALib := Min(SC9->C9_QTDLIB,(SBF->BF_QUANT - SBF->BF_EMPENHO))
								// Libertar somente o múltiplo do acondicionamento
								_nQtdALib := Int((_nQtdALib / _nTmLce))
								_nQtdALib := (_nQtdALib * _nTmLce)
								If _nQtdALib > 0
									// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
									// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
									// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
									if cAglutina == 'I'
										cSequenc := SC9->C9_SEQUEN
										nQtdLibs := Int((_nQtdALib / _nTmLce))
										for nX := 1 to nQtdLibs
											U_CDLibEst("L",SC9->C9_PRODUTO,(_nQtdALib / nQtdLibs),;
														SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,cSequenc,,,"C")
											cSequenc := getC9Seq(SC9->C9_PEDIDO, SC9->C9_ITEM)
										next nX
									else
										U_CDLibEst("L",SC9->C9_PRODUTO,_nQtdALib,;
													SC9->C9_LOCAL,_cLocz2,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"C")
									endif
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				TRB->(dbSkip()) // Este comando tem que ser dentro deste IF
			EndIf
		EndDo
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	Next
Return(.T.)

/*/{Protheus.doc} fCurvaA
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _cCodPrd, , descricao
@param _Acondic, , descricao
@param _lIncCar, , descricao
@type function
/*/
User Function fCurvaA(_cCodPrd,_Acondic,_lIncCar)// Critica se produto pertence a Curva A ( .T. = CURVA A )
	Local   lRetorno := .F.
	//Default _lIncCar := .F.  // Inclui Carretéis como sendo Curva?

	_cCodPrd := Left(_cCodPrd,5)   // Produto
	_Acondic := AllTrim(_Acondic)  // Acondicionamento


	// Curva A compreende:
	// Fio  do 1,5 ao 10    		10104 a0 10108
	// Flex do 0,50 ao 35			11501 ao 11511
	// Plasticom do 6 ao 35			11007 ao 11011
	// Paralelo do 2x0,50 ao 2x4	12001 ao 12006
	// Torcido do 2x1 ao 2x4        12201 ao 12206
	If ((_cCodPrd >= "10104" .And. _cCodPrd <= "10108") .Or.;
	(_cCodPrd >= "11501" .And. _cCodPrd <= "11511") .Or.;
	(_cCodPrd >= "11007" .And. _cCodPrd <= "11011") .Or.;
	(_cCodPrd >= "12001" .And. _cCodPrd <= "12006") .Or.;
	(_cCodPrd >= "12201" .And. _cCodPrd <= "12206"))    ;
	.And.;
	(Alltrim(_Acondic) == "R00100" .Or.;
	(_lIncCar .And. Left(_Acondic,1) $ "CM"))
		lRetorno := .T.
	ElseIf Alltrim(_Acondic) == "R00050" .Or. Alltrim(_Acondic) $ "R00015//L00015"
		lRetorno := .T.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} fPack
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param cAlias, characters, descricao
@type function
/*/
Static Function fPack(cAlias)// Realizar um pack na tabela
	dbSelectArea(cAlias)
	dbCloseArea()

	IF ChkFile(cAlias,.T.)//Abrir Tabela em Modo Exclusivo
		Pack
	Endif

	// Finaliza
	If Select(cAlias) > 0
		dbCloseArea()
	Endif
	ChkFile(cAlias,.F.)//Abrir Tabela em Modo Compartilhado

Return(.T.)

/*/{Protheus.doc} fQuery
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param nOpcao, numeric, descricao
@type function
/*/
Static Function fQuery(nOpcao)
	*
	/*/
	0 - Pedidos atrasados
	1-Pedidos PRIORIZADOS
	2-Pedidos com produtos NÃO curva 'A' já programados pelo PCP
	3-Pedidos somente quando atingem 100% do pedido
	4-Pedidos que somem R$ 4.000,00 e restem outros R$ 4.000,00 de saldo
	5-Liberação Geral.
	/*/

	Local cQuery    := ""
	Local cQueryCb1 := ""
	Local cVarCond  := ""
	Local cVarOrde  := ""

	// C5.C5_TIPOLIB -> 'M'anual / 'P'riorizado / 'N'ormal

	If nOpcao == 0  //0- Atrasados / Reservados Vendas
		If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
			// By Roberto Oliveira
			// Conforme conversa com o Felipe e a data de entrega é hoje não é considerado atrasado
			cVarCond += " AND (C6.C6_ENTREG <= '"+DtoS(Date())+"' OR C6.C6_RES_SZZ <> '      ') AND C5.C5_TIPOLIB <> 'M'"
		Else
			cVarCond += " AND (C6.C6_ENTREG < '"+DtoS(Date())+"' OR C6.C6_RES_SZZ <> '      ') AND C5.C5_TIPOLIB <> 'M'"
		EndIf
		cVarOrde += " ORDER BY ENTREG,PEDIDO,PRODUTO,ALMOX,ACONDIC,METRAGE"
	ElseIf nOpcao == 1  //1- PRIORITARIO
		cVarCond += " AND C5.C5_TIPOLIB = 'P'" // 
		cVarOrde += " ORDER BY ENTREG,PEDIDO,PRODUTO,ALMOX,ACONDIC,METRAGE"
	ElseIf nOpcao == 2 // 2- NÃO É CURVA "A" E JÁ INCLUIDOS EM RESUMO DE PRODUÇÃO
		cVarCond += " AND (C5.C5_TIPOLIB = ' ' OR C5.C5_TIPOLIB = 'N') AND C5_SEMANA <> '       '"
		cVarOrde += " ORDER BY ENTREG,PEDIDO,PRODUTO,ALMOX,ACONDIC,METRAGE"
	ElseIf nOpcao == 3 .Or. nOpcao == 4
		// 3- TODOS OS PRODUTOS DESDE QUE ATINJAM 100% DO PEDIDO
		// 4- TODOS OS PRODUTOS DESDE QUE ATINJAM R$ 4.000,00 e sobre outros R$ 4.000,00 de saldo
		cVarCond += " AND (C5.C5_TIPOLIB = ' ' OR C5.C5_TIPOLIB = 'N')"
		cVarOrde += " ORDER BY ENTREG,PEDIDO,PRODUTO,ALMOX,ACONDIC,METRAGE"
	ElseIf nOpcao == 5  //4- TODO RESTO
		cVarCond += " AND C5.C5_TIPOLIB <> 'M'" // Não libera os de tipo MANUAL
		cVarOrde += " ORDER BY ENTREG,C5.C5_TIPOLIB,PEDIDO,PRODUTO,ALMOX,ACONDIC,METRAGE"
	EndIf

	cQueryCb1 += " SELECT C9.C9_PEDIDO AS PEDIDO, C9.C9_ITEM AS ITEM, C9.C9_SEQUEN AS SEQUEN,"
	cQueryCb1 += " C9.C9_CLIENTE AS CLIENTE, C9.C9_LOJA AS LOJA, C9.C9_PRODUTO AS PRODUTO, "
	cQueryCb1 += " C9.C9_QTDLIB AS QTDALIB, C9.C9_LOCAL AS ALMOX, C9.R_E_C_N_O_ AS REGC9,"
	cQueryCb1 += " C6.C6_ACONDIC AS ACONDIC, C6.C6_LANCES AS LANCES, C6.C6_METRAGE AS METRAGE,C6.C6_RES_SZZ AS NRORES, C6.C6_ITE_SZZ AS ITERES,"
	cQueryCb1 += " C6.C6_ENTREG AS ENTREG, C6.C6_QTDVEN AS QTDVEN, C5.C5_TIPOLIB AS TIPOLIB"

	cQuery += " FROM "+RetSqlName("SC9")+ " C9"
	cQuery += " INNER JOIN "+RetSqlName("SC6")+ " AS C6 ON C9.C9_FILIAL = C6.C6_FILIAL AND C9.C9_PEDIDO = C6.C6_NUM AND C9.C9_ITEM = C6.C6_ITEM AND C9.D_E_L_E_T_ = C6.D_E_L_E_T_"
	cQuery += " INNER JOIN "+RetSqlName("SC5")+ " AS C5 ON C6.C6_FILIAL = C5.C5_FILIAL AND C6.C6_NUM = C5.C5_NUM AND "
	cQuery += " C5.C5_ZSTATUS NOT IN ('1', '2') AND C6.D_E_L_E_T_ = C5.D_E_L_E_T_"
	cQuery += " INNER JOIN "+RetSqlName("SF4")+ " AS F4 ON '  ' = F4_FILIAL AND C6.C6_TES = F4.F4_CODIGO AND 'S' = F4.F4_ESTOQUE AND C6.D_E_L_E_T_ = F4.D_E_L_E_T_"
	cQuery += " WHERE C9.C9_FILIAL = '"+xFilial("SC9")+"'"
	//cQuery += " AND C5.C5_FILIAL = '"+xFilial("SC5")+"'"
	//cQuery += " AND C6.C6_FILIAL = '"+xFilial("SC6")+"'"
	//cQuery += " AND F4.F4_FILIAL = '"+xFilial("SF4")+"'"
	//cQuery += " AND F4.F4_ESTOQUE = 'S'"
	cQuery += " AND C9.C9_BLCRED = '  '"
	cQuery += " AND C9.C9_BLEST = '02'"
	If SC9->C9_FILIAL == "02"
		cQuery += " AND C9.C9_LOCAL <> '10'"
	EndIf

	If Date() < Ctod("18/10/2016") .Or. (FWCodEmp()+FWCodFil() == "0102") /// Cobrecom 3 Lagoas
		// By Roberto Oliveira
		// Com a nova sistemática, não importa a data de inicio de faturamento
		// C5_DTFAT = Faturar a Partir de:     
		cQuery += " AND C5.C5_DTFAT <= '"+DtoS(Date())+"'" // Somente serão liberados pedidos que
		// Dt.Inicio de Faturamento <= Hoje
	EndIf



	cQuery += " AND C9.D_E_L_E_T_ <> '*'"
	cQuery += " AND C6.C6_ACONDIC <> 'T' AND  C6.C6_ACONDIC <> 'B'"
	// Retalhos somete libera manualmente e bobinas tem rotina própria
	cQuery := cQuery + cVarCond

	// Primeiro Vejo quantos registros tem
	cMyQuery := " SELECT Count(C9.C9_PEDIDO) AS PEDIDO"  + cQuery
	cMyQuery := ChangeQuery(cMyQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cMyQuery NEW ALIAS "TRB"
	DbSelectArea("TRB")
	DbGoTop()
	_nQtd := TRB->PEDIDO
	DbCloseArea()

	cQuery := cQueryCb1 + cQuery + cVarOrde
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()

Return(_nQtd)

/*/{Protheus.doc} DepuSDC
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
User Function DepuSDC()
	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SDC")
	DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	Set Filter to DC_ORIGEM == "SDC"
	ProcRegua(LastRec())
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		IncProc()
		If dDataBase > SDC->DC_DTLIB .And. SDC->DC_ORIGEM == "SDC" // só para garantir
			_lEstor := .T.
			SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.))
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. ;
			SC9->C9_PEDIDO == SDC->DC_PEDIDO .And. ;
			SC9->C9_ITEM   == SDC->DC_ITEM   .And. SC9->(!Eof())
				If SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "02"
					_lEstor := .F.
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
			If _lEstor

				SBF->(DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))
				SB2->(DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.))

				If RecLock("SDC",.F.)
					_nQtdEst := SDC->DC_QUANT
					SDC->(DbDelete())
					SDC->(MsUnLock())

					RecLock("SBF",.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO - _nQtdEst
					SBF->(MsUnLock())

					RecLock("SB2",.F.)
					SB2->B2_RESERVA := SB2->B2_RESERVA - _nQtdEst
					SB2->(MsUnLock())
				EndIf
			EndIf
		EndIf
		SDC->(DbSkip())
	EndDo
	DbSelectArea("SDC")
	DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	Set Filter to
	DbSeek(xFilial("SDC"),.F.)
Return(.T.)


/*/{Protheus.doc} DefMenu
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0

@type function
/*/
Static Function DefMenu()	
	Return({{ "Pesquisar"    , "AxPesqui"       ,0,1},;
	{ "Lib.Manual"   , "U_CDEST01L"     ,0,4},;
	{ "Lib.Automat"  , "U_CDEST24A(.F.)",0,4},;
	{ "Lib.Bobinas"  , "U_CDEST01B"     ,0,4},;
	{ "Estor. Item"  , "U_CDEST01E(.F.,.F.)",0,4},;
	{ "Estor. Tudo"  , "U_CDEST01E(.T.,.F.)",0,4},;
	{ "Legenda"      , "U_CDEST01X"     ,0,2},;
	{ "Est.Libera"   , "U_CBCLibA",0,4}})
return(nil)
/*/{Protheus.doc} ValQtdFat
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _MyC5_NUM, , descricao
@type function
/*/
User Function ValQtdFat(_MyC5_NUM)
	// O SC5 já deve estar posicionado
	Local aArea    := GetArea()
	Local aAreaC9
	Local aAreaD2
	Local aAreaC6

	If SC5->C5_NUM # _MyC5_NUM
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+_MyC5_NUM,.F.))
	eNDiF
	//If Date() < Ctod("01/01/2012") .Or. FWCodEmp()+FWCodFil() # "0101" // Somente a partir de 01/01/2012 e em Itu
	//If Date() < Ctod("09/01/2012") .Or. FWCodEmp()+FWCodFil() # "0101" // Somente a partir de 01/01/2012 e em Itu
	// Rafael liberou o dia 02/02/12 para faturar sem regras

	If SC5->C5_TIPO # "N" 					// Outros tipos de pedidos não se aplicam as regras
		Return(.T.)
	ElseIf Left(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_CGC"),8) == "02544042" // Para a própria Cobrecom
		Return(.T.)
	ElseIf Date() >= Ctod("12/04/2015")	.And. GetMv("MV_X_MINFT")  > 0 .And. GetMv("MV_X_SLDPD") > 0 .And.;
	"S/" $ GetMv("MV_X_CONSM") .And. !(_MyC5_NUM $ GetMv("MV_X_CONSM"))
		// Tenho valores minimos e saldo de pedidos
		// É para considetar
		// o pedido atual não está listado como excessão

		// email da Denise para Jeferson que determina que:
		//  Fatura tudo ou
		// 	Fatura o minimo de 3 mil e com saldo a faturar de 10 mil
		// Obs.: Para qe esta função não seja executada, basta zerar os parâmetros MV_X_MINFT e MV_X_SLDPD
		Return(u_lFatura(_MyC5_NUM))
	ElseIf FWCodEmp()+FWCodFil() # "0101"	// Somente em Itu
		Return(.T.)
	ElseIf Date() < Ctod("03/02/2012")			// Somente a partir de 01/01/2012
		Return(.T.)
	ElseIf Date() == Ctod("16/02/2012")			// Rafael liberou o dia 16 de fevereiro para faturar parciais
		Return(.T.)
	ElseIf Date() == Ctod("29/02/2012")			// Rafael/Denise liberou o dia 29 de fevereiro para faturar parciais
		Return(.T.)
	ElseIf Date() == Ctod("01/03/2012")			// Rafael/Denise liberou o dia 01 de março para faturar parciais
		Return(.T.)
	ElseIf Date() == Ctod("02/03/2012")			// Rafael/Denise liberou o dia 02 de março para faturar parciais
		Return(.T.)
	ElseIf Date() >= Ctod("08/03/2012")	.And. Date() <= Ctod("31/03/2012")
		// 07/03/12 - Rafael/Denise liberou do dia 08 a 31 de março para faturar parciais
		Return(.T.)
	ElseIf Date() == Ctod("05/04/2012")			// 11:17h Denise liberou o dia de hoje para faturar parciais
		Return(.T.)
	ElseIf Date() >= Ctod("09/04/2012")		// 09:30h Denise informa que Rafael liberou em definitivo
		Return(.T.)
	ElseIf SC5->C5_TRANSP $ "000123//000271//"
		// 02/12 - Rafael liberou quando RETIRA for a "transportadora" 000123 - RETIRA
		// 15/02/12 Rafael autorizou o que for do Martinez liberar. Em contato com Denise
		// ela determinou liberar quando a transportadora for 000271-TRANSMARTINEZ
		Return(.T.)
	EndIf

	DbSelectArea("SC9")
	aAreaC9  := GetArea()
	DbSelectArea("SD2")
	aAreaD2  := GetArea()
	DbSelectArea("SC6")
	aAreaC6  := GetArea()

	_lDpl_e_Est := .F. // Presumo que não movimente estoque E não tenha duplicatas
	_Volta := .T. // presumo que está tudo OK
	_nValAFat := 0
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	// Verificar se esta liberação "mata' o pedido
	DbSeek(xFilial("SC9") + _MyC5_NUM,.F.)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _MyC5_NUM .And. SC9->(!Eof())

		// 05/01/11 - BY Roberto -> Seria correto ver pelo SC9, uma vez que pode ter coisas não liberdaos ?

		If Empty(SC9->C9_BLEST) // Liberado para faturamento
			// Somar o valor a ser faturado
			Dbselectarea("SC6")
			DbsetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
			_nValAFat += (SC9->C9_QTDLIB * SC6->C6_PRCVEN)
		ElseIf SC9->C9_BLEST == "02" .And. _Volta // Vai ficar algo para faturar depois
			_Volta := .F.
		EndIf
		If !_lDpl_e_Est // Presumo que não movimente estoque E não tenha duplicatas
			Dbselectarea("SC6")
			DbsetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
			_cMyTES := If(Empty(SC6->C6_TESORI),SC6->C6_TES,SC6->C6_TESORI)
			_lDpl_e_Est := (Upper(Posicione("SF4",1,xFilial("SF4")+_cMyTES,"F4_ESTOQUE+F4_DUPLIC")) == "SS")
		EndIf
		SC9->(DbSkip())
	EndDo
	// Se não movimenta estoque OU não movimenta financeiro
	If !_lDpl_e_Est
		RestArea(aAreaD2)
		RestArea(aAreaC6)
		RestArea(aAreaC9)
		RestArea(aArea)
		Return(.T.)
	EndIf
	If !_Volta // Não vou faturar tudo agora
		aRomans := {}
		// Verificar quantos faturamentos já ocorreram para este pedido e quantos são permitidos

		DbSelectArea("SF2")
		DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

		DbSelectArea("SD2")
		DbSetOrder(8) // D2_FILIAL+D2_PEDIDO+D2_ITEMPV
		DbSeek(xFilial("SD2")+_MyC5_NUM,.F.)

		Do While SD2->D2_FILIAL  == xFilial("SD2") .And. SD2->D2_PEDIDO == _MyC5_NUM .And. SD2->(!Eof())
			SF2->(DbSeek(xFilial("SF2")+SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.))
			If Ascan(aRomans,SF2->F2_CDROMA) == 0
				Aadd(aRomans,SF2->F2_CDROMA)
			EndIf
			SD2->(DbSkip())
		EndDo

		// Regra estipulada pelo Rafael referente a quantidade de faturamentos
		// conforme o valor do pedido
		// até      R$  50.000,00 em somete 1 faturamento
		// até      R$ 100.000,00 em até    2 faturamentos
		// até      R$ 200.000,00 em até    3 faturamentos
		// acima de R$ 200.000,00 em até    4 faturamentos

		// Solicitado em 05/01/12 pelo Crispilho para vigorar a partir de 09/01/12Até R$ 20.000 - 1 vez
		//    Até 20.000       - em uma verz
		//    De 20.000,01 a 50.000 - Até 2 vezes
		//    De 50.000,01 a 100.000 - Até 3 vezes
		//    Acima de 100.000 - Até 4 vezes

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
		If SA1->A1_EST == "SP"
			// Se for para São Paulo
			If     SC5->C5_TOTAL > 100000.00 // 200000.00
				_nPodeFat := 4
			ElseIf SC5->C5_TOTAL > 50000.00  // 100000.00
				_nPodeFat := 3
			ElseIf SC5->C5_TOTAL > 20000.00  // 50000.00
				_nPodeFat := 2
			Else
				_nPodeFat := 1
			EndIf
			// Em 20/01/12 a Denise falou com o Rafael e foi reavaliado o valor minimo para faturamento
			// de R$ 20.000,00 para R$ 10.000,00 até 31/05/12.
			If date() < Ctod("01/06/12")
				_nMinFat := 10000.00
			Else
				_nMinFat := 20000.00
			EndIf
		Else
			// Se for fora de São Paulo
			If     SC5->C5_TOTAL > 200000.00
				_nPodeFat := 4
			ElseIf SC5->C5_TOTAL > 100000.00
				_nPodeFat := 3
			ElseIf SC5->C5_TOTAL > 50000.00
				_nPodeFat := 2
			Else
				_nPodeFat := 1
			EndIf
			// Em 20/01/12 a Denise falou com o Rafael e foi reavaliado o valor minimo para faturamento
			// de R$ 50.000,00 para R$ 20.000,00 até 31/05/12.
			If date() < Ctod("01/06/12")
				_nMinFat := 20000.00
			Else
				_nMinFat := 50000.00
			EndIf
		EndIf

		_Volta := .T. // Retorno a variável para nova análise
		_nQtdFat := Len(aRomans)
		If (_nQtdFat+2 > _nPodeFat) .Or. _nValAFat < _nMinFat
			// + 2 porque nesta rotina não estou faturando tudo, ou seja,
			// uma parte agora e consequentemente terei outra parte em outro faturamento
			_Volta := .F.
		EndIf
	EndIf
	RestArea(aAreaD2)
	RestArea(aAreaC6)
	RestArea(aAreaC9)
	RestArea(aArea)
Return(_Volta)

/*/{Protheus.doc} lFatura
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _MyC5_NUM, , descricao
@type function
/*/
User Function lFatura(_MyC5_NUM)
	Local aArea  := GetArea()
	Local aAreaC9
	Local aAreaC6
	Local _lVolta := .T.

	DbSelectArea("SC9")
	aAreaC9  := GetArea()

	DbSelectArea("SC6")
	aAreaC6  := GetArea()
	DbsetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	_nTotLib := 0
	_nTotBlq := 0

	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	DbSeek(xFilial("SC9") + _MyC5_NUM,.F.)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _MyC5_NUM .And. SC9->(!Eof())
		SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
		If Empty(SC9->C9_BLEST) // Liberado para faturamento
			_nTotLib += (SC9->C9_QTDLIB * SC6->C6_PRCVEN)
		ElseIf SC9->C9_BLEST == "02"  // Estoque Bloqueado
			_nTotBlq += (SC9->C9_QTDLIB * SC6->C6_PRCVEN)
		EndIf
		SC9->(DbSkip())
	EndDo
	RestArea(aAreaC6)
	RestArea(aAreaC9)
	RestArea(aArea)

	If _nTotBlq <= 0 // Vou faturar tudo, então pode
		_lVolta := .T.
	ElseIf Date() >= Ctod("12/04/2015")	.And.;
	(GetMv("MV_X_MINFT")  > 0  .And. GetMv("MV_X_SLDPD") > 0) .And.;
	("S" $ GetMv("MV_X_CONSM") .And. !(_MyC5_NUM $ GetMv("MV_X_CONSM"))) .And.;
	(_nTotLib<GetMv("MV_X_MINFT") .Or. _nTotBlq < GetMv("MV_X_SLDPD"))
		_lVolta := .F.
		// Tenho valores minimos e saldo de pedidos
		// É para considetar
		// o pedido atual não está listado como excessão
		// Faturando tudo ou 3.000 e sobra 10.000
	EndIf
Return(_lVolta)

/*/{Protheus.doc} EstZZRZZO
//TODO Descrição auto-gerada.
@author Roberto
@since 29/08/2017
@version 1.0
@param _cPedido, , descricao
@param _cC5Seq, , descricao
@type function
/*/
User Function EstZZRZZO(_cPedido,_cC5Seq)
	// Log das O.S.
	_cSeqExc := "" // Quais sequencias eu realmente estornei

	DbSelectArea("SZE")
	DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB

	DbSelectArea("ZZR")
	DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS

	DbSeek(xFilial("ZZR")+_cPedido,.F.)
	Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == _cPedido .And. ZZR->(!Eof())
		If (Empty(_cC5Seq) .Or. ZZR->ZZR_SEQOS == _cC5Seq) .And.;
		Empty(ZZR->ZZR_DOC) .And. !(ZZR->ZZR_SITUAC $ "3/4/9") // 3-Carregado, 4-Expedido, 9-Cancelado
			If !ZZR->ZZR_SEQOS $ _cSeqExc // Quais sequencias eu realmente estornei
				_cSeqExc := _cSeqExc + "/" + ZZR->ZZR_SEQOS // Quais sequencias eu realmente estornei
			EndIf
			RecLock("ZZR",.F.)
			ZZR->ZZR_SITUAC := "9" // Cancelado
			MsUnLock()

			If !Empty(ZZR->ZZR_NROBOB)
				If SZE->(DbSeek(xFilial("SZE")+ZZR->ZZR_PEDIDO+ZZR->ZZR_ITEMPV+ZZR->ZZR_NROBOB,.F.))
					RecLock("SZE",.F.)
					SZE->ZE_SEQOS := "  "
					MsUnLock()
				EndIf
			EndIf
		EndIf
		ZZR->(DbSkip())
	EndDo

	// Verificar se tem volumes montados
	DbSelectArea("ZZO")
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	DbSeek(xFilial("ZZO")+_cPedido,.F.)
	
	Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == _cPedido .And. ZZO->(!Eof())
		If Empty(ZZO->ZZO_DOC) .And. ZZO->ZZO_SEQOS $ _cSeqExc // Quais sequencias eu realmente estornei
			RecLock("ZZO",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		ZZO->(DbSkip())
	EndDo
	
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+_cPedido,.F.))
	RecLock("SC5",.F.)
	SC5->C5_ZSTATUS := "0"
	MsUnLock()
Return(.T.)




/*/{Protheus.doc} CBCLibA
//TODO Descrição auto-gerada.
@author Adaptação do Legado
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@param _lGeral, , descricao
@type function
Chamada da função de liberação automática de rolos e carretéis que não estão em Faturamento
/*/
User Function CBCLibA()
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	
	If !LockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		Return
	EndIf
	
	// Lock do Semáforo	Cobrecom	
	if !u_prxCanOp('EMP', 'FAT')
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Faturamento em execução! Aguarde!")
		Return(nil)
	endif

	if !validAcess(xFilial("SC9"))
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Permissão Negada!")
		return(nil)
	endif

	If !MsgBox("Atenção:"+Chr(13)+Chr(13)+;
		"Esta rotina Compreende em :"+Chr(13)+;
		"     Estorno das liberações dos produtos nos acondicionamentos ROLO e CARRETEL"+Chr(13)+;
		"     que ainda não estão em STATUS de FATURAMENTO;" +Chr(13)+;
		"Tem certeza que deseja processar o estorno dessas liberações de estoque?","Atenção","YesNo")

			//_aAccess := u_CtrlAccess("L","CDEST01",cUserName) // Bloqueia/Libera controle de acesso da rotina
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
			
		Return(.T.)
	EndIf

	Processa({|lEnd| u_fEsLibA()}, "Estornando Liberações")
	
	UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
	
	// Unlock do Semáforo Cobrecom
	u_prxCanCl('EMP')
	
	If MsgBox("Deseja enviar Email de Notificação?","Atenção","YesNo")

		aAdd(aParamBox,{1,"Emails p/ Envio(;)",PadR(GetMV("MV_ZZEXEMA"),250),"","","","",100,.F.})

		If !ParamBox(aParamBox, "Parametros", @aRet)
			Return(.F.)
		EndIf

		_cPara := Alltrim(aRet[1])
		//Grava emails
		PutMV("MV_ZZEXEMA",_cPara)

		//Teste
		If Empty(_cPara)
			_cPara := Alltrim("wfti@cobrecom.com.br")
		EndIf
		U_SendMail(_cPara,"Expedição - Sistema Liberado em "+ Substr(DtoS(dDataBase),7,2)+"/" + Substr(DtoS(dDataBase),5,2)+ "/" + ;
		Substr(DtoS(dDataBase),1,4),"Expedição - Sistema Liberado")
	EndIf

	Alert("Termino do Processamento")

Return(.T.)





/*/{Protheus.doc} fEsLibA()
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@type function
Estorna as Liberações que não estejam nas seguintes situações:
1-Posicionado em TL e Armazém 10
2-Reservado
3-Retorno de Industrialização
4-Reserva do Portal
5-Status em Faturamento (C5_ZSTATUS)
6-Liberação Manual ou Priorizada
7-Não esteja nos acondicionamentos ROLO e CARRETEL
8-Não for liberação por reserva
/*/
User Function fEsLibA()
	local aCanCancel := {}
	local cActPed	 := ''
	Local oStatic    := IfcXFun():newIfcXFun()
	
	DbSelectArea("SB1")
	DbSetOrder(1)  //B1_FILIAL+B1_COD

	DbSelectArea("SC6")
	DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO

	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SBF")
	DbSetOrder(1)

	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SDC")
	DbSetOrder(1)

	ProcRegua(LastRec())
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		if AllTrim(cActPed) <> AllTrim(SDC->DC_PEDIDO)
			cActPed := AllTrim(SDC->DC_PEDIDO)
			aCanCancel := oStatic:sP(1):callStatic('cbcCtrlOS', 'canCancelbyPed', AllTrim(SDC->DC_PEDIDO))
		endif		
		IncProc()
		if !aCanCancel[01]
			SDC->(DbSkip())
			Loop
		endif
		//Não Estorna Armazém 10 se estiver posicionado na Filial
		If 	SDC->DC_ORIGEM # "SC6" .Or. (SDC->DC_FILIAL == "02" .And. SDC->DC_LOCAL == "10")
			SDC->(DbSkip())
			Loop
		EndIf

		DbSelectArea("SC6")
		DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO
		If !(DbSeek(xFilial("SC6")+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.))
			SDC->(DbSkip())
			Loop
		EndIf
		
		// Não estorna o que estiver reservado
		If !(Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ)) 
			SDC->(DbSkip())
			Loop
		EndIf

		//Não estornar quando material é retorno de industrialização.
		If SC6->C6_FILIAL == '02' .And. !Empty(SC6->C6_ZZPVORI)
			SDC->(DbSkip())
			Loop
		EndIf
		
		//LEO 19/07/16 - PORTAL
		If Left(SC6->C6_SEMANA,3) == "ZP4" .Or. !Empty(SC6->C6_ZZNRRES)
			// Pedidos com origem no Portal - Leonardo/Roberto 21/03/2016
			SDC->(DbSkip())
			Loop
		EndIf

		DbSelectArea("SC5")
		DbSetOrder(1)
		If !(DbSeek(xFilial("SC5")+SDC->DC_PEDIDO,.F.))
			SDC->(DbSkip())
			Loop
		EndIf
		
		//No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
		If SC5->C5_ZSTATUS > Padr("1", TamSx3('C5_ZSTATUS')[1])
			SDC->(DbSkip())
			Loop
		EndIf

		//Não estorna pedidos com lib. Manual e priorizada
		If SC5->C5_TIPOLIB $ "PM"
				SDC->(DbSkip())
				Loop			
		EndIf

		//Não seja Rolo ou Carretel
		If Left(SDC->DC_LOCALIZ,1) # "R" .And. Left(SDC->DC_LOCALIZ,1) # "M"
			SDC->(DbSkip())
			Loop
		EndIf

		_RegAtu := SDC->(Recno())

		SDC->(DbSkip())
		_PrxReg := SDC->(Recno())

		SDC->(DbGoTo(_RegAtu))
		SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.))
		
		// Não estorna se a liberação for por reserva
		If SC9->C9_TPLIB == "R"
			SDC->(DbSkip())
			Loop
		EndIf

		U_CDLibEst("E",SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ,.F.)

		DbSelectArea("SDC")
		DbSetOrder(1)
		SDC->(DbGoTo(_PrxReg))
	EndDo
Return(.T.)

static function validAcess(cFili)
	local oAcl 		:= cbcAcl():newcbcAcl()
	local lVld		:= .F.
	local cGrp		:= 'EmpenhaFil'
	default cFili 	:= FwFilial()

	cGrp += AllTrim(cFili)
	lVld := oAcl:aclValid(cGrp)
	
	FreeObj(oAcl)
return(lVld)

static function getC9Seq(cPedido, cItem)
	local aArea    	:= GetArea()
    local aAreaSC9	:= SC9->(getArea())
	local cSequen 	:= ""
	local oSql      := LibSqlObj():newLibSqlObj()

    oSql:newAlias(qryC9Seq(cPedido, cItem))
    if oSql:hasRecords()
        oSql:goTop()		
        cSequen := oSql:getValue("SEQ")
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSC9)
    RestArea(aArea)
return(cSequen)

static function qryC9Seq(cPedido, cItem)
	local cQry := ""
	cQry += " SELECT MAX(SC9.C9_SEQUEN) AS [SEQ] "
	cQry += " FROM SC9010 SC9 "
	cQry += " WHERE SC9.C9_FILIAL = '" + xFilial('SC9') + "' "
	cQry += " AND SC9.C9_PEDIDO = '" + AllTrim(cPedido) + "' "
	cQry += " AND SC9.C9_ITEM = '" + AllTrim(cItem) + "' "
	cQry += " AND SC9.D_E_L_E_T_ = '' "
return(cQry)
