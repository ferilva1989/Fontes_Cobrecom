/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | FC010CON   | AUTOR | Francisco C Godinho  | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA PARA CONSULTAR PEDIDOS DE VENDAS                       ||
||           | PE CONSULTA ESPECIFICA POSICAO DO CLIENTE                     ||
||---------------------------------------------------------------------------||
|| USO       | FINC010                                                       ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/

#include "Protheus.ch"
#include "dbinfo.ch"

User Function FC010CON()

	PRIVATE aSavSC6
	PRIVATE aSavSX3
	PRIVATE aSavAtu  := GetArea()
	PRIVATE cA1_COD  := SA1->A1_COD
	PRIVATE cA1_LOJA := If(MV_PAR13==1,SA1->A1_LOJA,"") // Considera Loja

	PRIVATE aCpoSC6  := {}
	PRIVATE aTitSC6  := {}
	PRIVATE aSize    := {}
	PRIVATE aRegSC6  := {}
	PRIVATE aButtons := {}
	PRIVATE aTam     := {}
	PRIVATE aListP   := {}
	PRIVATE aListI   := {}
	PRIVATE i := 0

	PRIVATE oDlg
	PRIVATE oLbx
	PRIVATE oVerde    := LoadBitmap(GetResources(),"BR_VERDE")
	PRIVATE oVermelho := LoadBitmap(GetResources(),"BR_VERMELHO")
	PRIVATE oAmarelo  := LoadBitmap(GetResources(),"BR_AMARELO")
	PRIVATE aLeg      := {{"ENABLE","Em aberto"},{"DISABLE","Encerrado"},{"BR_AMARELO","Parcialmente em aberto"}}
	PRIVATE cLine := ""
	PRIVATE bMyLine
	PRIVATE _nVlPedido    := 0
	PRIVATE _nVlFaturado  := 0
	PRIVATE _nVlSaldo     := 0
	Private oFnt1
	Private nOrd := 1
	Private __cCadastro := "Posicao do Faturamento            " + SA1->A1_COD + If(MV_PAR13==1,"-" + SA1->A1_LOJA + " "," ") + SA1->A1_NOME
	Private _cCadastro := "Posicao do Faturamento "
	Private _cMyNmEmp := cNumEmp
	Private _cFilPed := FWCodFil()
	DEFINE FONT oFnt1 NAME "Arial" BOLD

	aAdd(aCpoSC6,"")
	aAdd(aCpoSC6,"C6_NUM")
	aAdd(aCpoSC6,"C6_ITEM")
	aAdd(aCpoSC6,"C6_PRODUTO")
	aAdd(aCpoSC6,"C6_DESCRI")
	aAdd(aCpoSC6,"C6_UM")
	aAdd(aCpoSC6,"C6_QTDVEN")
	aAdd(aCpoSC6,"C6_QTDLIB")
	aAdd(aCpoSC6,"C6_QTDENT")
	aAdd(aCpoSC6,"C6__PENDET")
	aAdd(aCpoSC6,"C6_PRCVEN")
	aAdd(aCpoSC6,"C6_VALOR")
	aAdd(aCpoSC6,"C6_LOCAL")
	aAdd(aCpoSC6,"C6_SEMANA")
	aAdd(aCpoSC6,"C6_DTRESUM")
	aAdd(aCpoSC6,"C6_DTPROGR")
	//aAdd(aCpoSC6,"C6_DTEPA") 
	//aAdd(aCpoSC6,"C6_ENTREG") 
	aAdd(aCpoSC6,"C6_CLI")
	aAdd(aCpoSC6,"C6_LOJA")
	aAdd(aCpoSC6,"C6_NOTA")
	aAdd(aCpoSC6,"C6_SERIE")
	aAdd(aCpoSC6,"C6_DATFAT")

	dbSelectArea("SC6")
	aSavSC6 := GetArea()

	dbSelectArea("SX3")
	aSavSX3 := GetArea()
	dbSetOrder(2)
	For i:=1 To Len(aCpoSC6)
		If i==1
			aAdd(aTitSC6,"")
			aAdd(aTam,GetTextWidth(0,Replicate(";",4)))
		Else
			If dbSeek(aCpoSC6[i])
				aAdd(aTitSC6,RetTitle(aCpoSC6[i]))
				aAdd(aTam,GetTextWidth(0,Replicate(";",IIF(Len(RetTitle(aCpoSC6[i]))<X3_TAMANHO,X3_TAMANHO,Len(RetTitle(aCpoSC6[i]))))))
			Else
				aAdd(aTitSC6,"Qt.Pendente")
				aAdd(aTam,GetTextWidth(0,Replicate(";",12)))
			Endif
		Endif
	Next i


	Processa({||LoadSC5(cA1_COD,cA1_LOJA)},_cCadastro,"Carregando pedidos, aguarde...")


	If Len(aListP)==0
		MsgInfo("Não existe dados a consultar",_cCadastro)
		RestArea(aSavSC6)
		RestArea(aSavSX3)
		RestArea(aSavAtu)
		Return(.T.)
	Endif

	aAdd(aButtons,{"BMPPERG",{|| BrwLegenda(_cCadastro,"Legenda",aLeg)},"Legenda"})
	aAdd(aButtons,{"S4WB011N",{|| C900Pesq(@aListP,@oListP)},"Localizar"})
	//aAdd(aButtons,{"EDIT_OCEAN",{|| C900PedVen(aListP[oListP:nAt,1])},"Pedido"})
	aAdd(aButtons,{"EDIT_OCEAN",{|| C900PedVen(aListP[oListP:nAt,3])},"Pedido"})
	aAdd(aButtons,{"PEDIDO",{|| C900NFS(aRegSC6[oListI:nAt,16],;
		aRegSC6[oListI:nAt,17],;
		aRegSC6[oListI:nAt,2],;
		aRegSC6[oListI:nAt,3])},"Nota"})
	// aAdd(aButtons,{"TK_HISTORY",{|| u_VisuHist(cA1_COD,cA1_LOJA)},"Cons.Histórico"})
	// aAdd(aButtons,{"TK_HISTORY",{|| u_InclHist(.T.,cA1_COD,cA1_LOJA)},"Hist.Inclui"})

	aSize := MsAdvSize()
	DEFINE MSDIALOG oDlg FROM aSize[7],aSize[1] TO aSize[6],aSize[5] TITLE __cCadastro OF oMainWnd PIXEL

	If MV_PAR13 == 1 // Considera Loja
		@  0,0  LISTBOX oListP VAR cVar Fields ;
			HEADER "Filial","Unidade","Pedido","Emissao", "Total","Faturado","Saldo",;
			"Data Entrega","Ocorrência" ;
			FIELDSIZES 10,20,30,40,45,50,55,60,65 ;
			SIZE 80,70 PIXEL  of oDlg
		oListP:SetArray( aListP )
		oListP:bLine := { || { aListP[oListP:nAT,1], aListP[oListP:nAT,2], aListP[oListP:nAT,3], aListP[oListP:nAT,4], aListP[oListP:nAT,5],aListP[oListP:nAT,6],aListP[oListP:nAT,7],aListP[oListP:nAT,8],aListP[oListP:nAT,9] } }
		oListP:bChange := { || displayItem(aListP[oListP:nAt,1]+aListP[oListP:nAt,3],1)}
	Else

		nTm0 := 20
		nTm1 := 50
		nTm2 := 20
		nTm3 := 30
		nTm4 := 40
		nTm5 := 40
		nTm6 := 40
		nTm7 := 40
		nTm8 := 40
		nTm9 := 50
		//  FIELDSIZES 10,20,30,35,40,45,50,55,60,65;

		@  0,0  LISTBOX oListP VAR cVar Fields ;
			HEADER "Filial","Unidade","Loja","Pedido","Emissao",;
			"Total","Faturado","Saldo","Data Entrega","Ocorrência" ;
			FIELDSIZES nTm0,nTm1,nTm2,nTm3,nTm4,nTm5,nTm6,nTm7,nTm8,nTm9 ;
			SIZE 80,70 PIXEL  of oDlg
		oListP:SetArray( aListP )
		oListP:bLine := { || { aListP[oListP:nAT,1], aListP[oListP:nAT,2], aListP[oListP:nAT,3], aListP[oListP:nAT,4], aListP[oListP:nAT,5],aListP[oListP:nAT,6],aListP[oListP:nAT,7],aListP[oListP:nAT,8],aListP[oListP:nAT,9],aListP[oListP:nAT,10] } }
		oListP:bChange := { || displayItem(aListP[oListP:nAt,1]+aListP[oListP:nAt,4],1)}
	EndIf
	oListP:Refresh()
	oListP:Align := CONTROL_ALIGN_TOP

	oListI := TWBrowse():New(0,0,0,0,,aTitSC6,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListI:Align := CONTROL_ALIGN_ALLCLIENT
	oListI:aColSizes := aTam
	oListI:bLDblClick := {|| C900Click(@aRegSC6[oListI:nAt]) }
	oListI:cToolTip := "[Duplo click para visualizar]..."
	oListI:SetArray(aRegSC6)
	cLine := "{IIF(aRegSC6[oListI:nAt,1]==0,oVerde,IIF(aRegSC6[oListI:nAt,1]==1,oAmarelo,oVermelho))"
	aEval( aCpoSC6, {|x,y| cLine += ",aRegSC6[oListI:nAt,"+LTrim(Str(y))+"]" }, 2 )
	cLine += "}"
	bMyLine := &("{|| "+cLine+"}")
	oListI:bLine := bMyLine

	oListI:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelA := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,0,25,.T.,.F.)
	oPanelA:Align := CONTROL_ALIGN_BOTTOM
	oPanelA:NCLRPANE := 14803406

	@ 05,008 SAY "Total do PV "                                            SIZE 90,10   OF oPanelA                    PIXEL  FONT oFnt1 COLOR CLR_BLACK PICTURE "@!"
	@ 05,158 SAY "Faturado "                                               SIZE 90,10   OF oPanelA                    PIXEL  FONT oFnt1 COLOR CLR_BLACK PICTURE "@!"
	@ 05,298 SAY "Saldo "                                                  SIZE 90,10   OF oPanelA                    PIXEL  FONT oFnt1 COLOR CLR_BLACK PICTURE "@!"
	@ 015,008 SAY oTotalP VAR _nVlPedido    PICTURE "@E 99,999,999,999.99"	SIZE 60,06   OF oPanelA PIXEL
	@ 015,150 SAY oTotalF VAR _nVlFaturado  PICTURE "@E 99,999,999,999.99"	SIZE 60,06   OF oPanelA PIXEL
	@ 015,290 SAY oTotalS VAR _nVlSaldo     PICTURE "@E 99,999,999,999.99"	SIZE 60,06   OF oPanelA PIXEL



	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)

	RestArea(aSavSC6)
	RestArea(aSavSX3)
	RestArea(aSavAtu)
Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | LOADSC5    | AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA PARA CARREGAR OS DADOS DO PEDIDO DE VENDAS             ||
||---------------------------------------------------------------------------||
|| USO       | FC010C0N                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function LoadSC5(cA1_COD,cA1_LOJA)

	Local i := 0
	Local nPosCpo := 0
	Local nTamReg := 0
	Local cCond := ""
	Local nRet := 0

	// Apresentar os pedidos das duas filiais
	DbSelectArea("SM0")
	_RegSM0 := Recno()
	DbGoTop()
	_aFiliais := {}
	Do While SM0->(!Eof())
		If SM0->M0_CODIGO == cEmpAnt
			AAdd(_aFiliais,{FWCodFil(),FWCodEmp()})
		EndIf
		SM0->(DbSkip())
	EndDo
	SM0->(DbGoTo(_RegSM0))

	dbSelectArea("SC5") ; dbSetOrder(3)
	dbSeek(xFilial("SC5")+cA1_COD,.T.)
	ProcRegua((RecNo()-LastRec())*2)

	aListP   := {}

	For _nFils := 1 to Len(_aFiliais)
		_cNumero := ""
		//	dbSeek(xFilial("SC5")+cA1_COD,.T.)
		dbSelectArea("SC5") ; dbSetOrder(3)

		dbSeek(_aFiliais[_nFils,1]+cA1_COD,.T.)

		//Do While ! Eof() .And. SC5->(C5_FILIAL+C5_CLIENTE)==xFilial("SC5")+cA1_COD
		Do While ! Eof() .And. SC5->(C5_FILIAL+C5_CLIENTE)==_aFiliais[_nFils,1]+cA1_COD
			If SC5->C5_LOJACLI # cA1_LOJA .And. MV_PAR13==1
				dbSelectArea("SC5")
				dbSkip()
				Loop
			EndIf
			_cNumero := If(Empty(_cNumero),SC5->C5_NUM,"")
			IncProc()
			_nVlFaturado  := 0
			_nVlSaldo     := 0
			_nVlTotal     := 0
			_cOcorrencia  := ""
			_Blq := ""
			_lTemSC9 := .T.
			DbSelectArea("SC9") ; DbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			dbSelectArea("SC6") ; dbSetOrder(1)
			//		dbSeek(xFilial("SC6")+SC5->C5_NUM)
			dbSeek(_aFiliais[_nFils,1]+SC5->C5_NUM)
			ProcRegua(RecNo()-LastRec())
			//		Do While !Eof() .And. SC6->(C6_FILIAL+C6_NUM)==xFilial("SC6")+SC5->C5_NUM
			Do While !Eof() .And. SC6->(C6_FILIAL+C6_NUM)==_aFiliais[_nFils,1]+SC5->C5_NUM
				If _lTemSC9
					_lTemSC9 := SC9->(DbSeek(_aFiliais[_nFils,1]+SC6->C6_NUM+SC6->C6_ITEM,.F.))
				EndIf

				_nVlFaturado  += If(C6_QTDENT>0, C6_QTDENT * C6_PRCVEN,0)
				_nVlTotal     += C6_QTDVEN * C6_PRCVEN
				If SC5->C5_LIBEROK # "E" .And. (C6_QTDVEN-C6_QTDENT) > 0 // aqui verificar o campo C6_QTDVEN
					_nVlSaldo += (C6_QTDVEN-C6_QTDENT) * C6_PRCVEN
				EndIF
				If SC6->C6_BLQ == "R " .And. Empty(_Blq)
					_Blq := SC6->C6_BLQ
				EndIf
				dbSkip()
			EndDo
			//	    If SC5->C5_NOTA == Replicate("X",Len(SC5->C5_NOTA)) //Resíduo Eliminado
			//			_cOcorrencia  := "RESIDUO TOTAL "
			//	    ElseIf SC5->C5_LIBEROK == "E"  //Resíduo Eliminado
			//			_cOcorrencia  := "RESIDUO TOTAL "
			If _Blq == "R "
				_cOcorrencia  := "RESIDUO"
			ElseIf  !_lTemSC9
				_cOcorrencia  := "Bloq. Vendas"
			ElseIf _nVlSaldo > 0
				DbSelectArea("SC9")
				DbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
				_cOcorrencia  := ""
				_nOcReal := 100
				//			If !DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.)
				DbSeek(_aFiliais[_nFils,1]+SC5->C5_NUM,.F.)
				//			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
				Do While SC9->C9_FILIAL == _aFiliais[_nFils,1] .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
					If SC9->C9_BLCRED == "01" .And. _nOcReal > 1
						_nOcReal := 1
						Exit
					ElseIf SC9->C9_BLCRED == "09" .And. _nOcReal > 2
						_nOcReal := 2
					ElseIf SC9->C9_BLEST == "02" .And. _nOcReal > 3
						_nOcReal := 3
					ElseIf Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST) .And. _nOcReal > 4
						_nOcReal := 4
					ElseIf SC9->C9_BLCRED == "10" .And. _nOcReal > 5
						_nOcReal := 5
					EndIf
					DbSkip()
				EndDo
				If _nOcReal == 1
					_cOcorrencia  := "BLQ.CREDITO"
				ElseIf _nOcReal == 2
					_cOcorrencia  := "REJEITADO"
				ElseIf _nOcReal == 3
					_cOcorrencia  := "BLQ.ESTOQUE"
				ElseIf _nOcReal == 4
					_cOcorrencia  := "LIB.P/FATUR"
				ElseIf _nOcReal == 5
					_cOcorrencia  := "FATURADO"
				EndIf
			Else
				_cOcorrencia  := "ENCERRADO"
			EndIF
			//	_dDataEntreg := dDatabase  
			_dDataEntreg := SC5->C5_ENTREG
			//		aadd(aListP,{SC5->C5_NUM,Stod( Dtos(SC5->C5_EMISSAO)),Transform(_nVlTotal,"@E 999,999,999.99"),Transform(_nVlFaturado,"@E 999,999,999.99"),Transform(_nVlSaldo,"@E 999,999,999.99"),Stod( Dtos(_dDataEntreg)),_cOcorrencia })
			If MV_PAR13==1
				aadd(aListP,{_aFiliais[_nFils,1],_aFiliais[_nFils,2],SC5->C5_NUM,Stod( Dtos(SC5->C5_EMISSAO)),Transform(_nVlTotal,"@E 999,999,999.99"),Transform(_nVlFaturado,"@E 999,999,999.99"),Transform(_nVlSaldo,"@E 999,999,999.99"),Stod( Dtos(_dDataEntreg)),_cOcorrencia })
			Else
				aadd(aListP,{_aFiliais[_nFils,1],_aFiliais[_nFils,2],SC5->C5_LOJACLI,SC5->C5_NUM,Stod( Dtos(SC5->C5_EMISSAO)),Transform(_nVlTotal,"@E 999,999,999.99"),Transform(_nVlFaturado,"@E 999,999,999.99"),Transform(_nVlSaldo,"@E 999,999,999.99"),Stod( Dtos(_dDataEntreg)),_cOcorrencia })
			EndIf
			dbSelectArea("SC5")
			dbSkip()
		EndDo
	Next
	//aSort(aListP,,,{|x,y| x[1]>y[1]})
	If MV_PAR13==1
		aSort(aListP,,,{|x,y| x[3]>y[3]})
	Else
		aSort(aListP,,,{|x,y| x[4]>y[4]})
	EndIf
Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | displayItem| AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA PARA CARREGAR OS ITENS DO PEDIDO DE VENDAS             ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function displayItem(_cNum,_nTipo)
	Local i := 0
	Local nPosCpo := 0
	Local nTamReg := 0
	Local cCond := ""
	_cFilPed := Left(_cNum,2) // Filial do C5 atual

	aRegSC6 := {}
	_nVlPedido    := 0
	_nVlFaturado  := 0
	_nVlSaldo     := 0

	cCond := ""


	dbSelectArea("SC6") ; dbSetOrder(1)
	//dbSeek(xFilial("SC6")+_cNum)
	dbSeek(_cNum)
	ProcRegua(RecNo()-LastRec())

	//While !Eof() .And. SC6->(C6_FILIAL+C6_NUM)==xFilial("SC6")+_cNum
	While !Eof() .And. SC6->(C6_FILIAL+C6_NUM)==_cNum
		IncProc()
		If cCond <> ""
			If !&(cCond)
				dbSkip()
				Loop
			Endif
		Endif
		_nQtdLib := 0
		dbSelectArea("SC9") ; dbSetOrder(1)
		//	dbSeek(xFilial("SC9")+_cNum + SC6->C6_ITEM)
		dbSeek(_cNum + SC6->C6_ITEM)
		//	While ! Eof() .And. SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM) == xFilial("SC9")+_cNum + SC6->C6_ITEM
		While ! Eof() .And. SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM) == _cNum + SC6->C6_ITEM
			If EmpTy(C9_NFISCAL) .And. C9_BLEST != "10"
				_nQtdLib += SC9->C9_QTDLIB
			EndIF
			DbSkip()
		EndDo
		dbSelectArea("SC6")
		aAdd(aRegSC6,Array(Len(aCpoSC6)))
		For i:=1 To Len(aCpoSC6)
			nPosCpo := FieldPos(aCpoSC6[i])
			nTamReg := Len(aRegSC6)
			If Empty(aCpoSC6[i])
				aRegSC6[nTamReg,i] := IIF(Empty(C6_BLQ),IIF(C6_QTDENT==0,0,IIF((C6_QTDVEN-C6_QTDENT)>0,1,2)),2)
			Elseif aCpoSC6[i] == "C6__PENDET"
				aRegSC6[nTamReg,i] := Transform(C6_QTDVEN-C6_QTDENT,"@E 999,999,999.99")
			Elseif aCpoSC6[i] == "C6_QTDLIB"
				aRegSC6[nTamReg,i] := Transform(_nQtdLib,"@E 999,999,999.99")
			Else
				If ValType(FieldGet(nPosCpo))=="N"
					aTamVar := TamSX3(aCpoSC6[i])
					aRegSC6[nTamReg,i] := Transform(FieldGet(nPosCpo),PesqPict("SC6",aCpoSC6[i],aTamVar[1]))
				Else
					aRegSC6[nTamReg,i] := FieldGet(nPosCpo)
				Endif
			Endif
		Next i
		_nVlPedido  += C6_QTDVEN * C6_PRCVEN
		_nVlFaturado  += If(C6_QTDENT>0, C6_QTDENT * C6_PRCVEN,0)
		IF C6_QTDVEN-C6_QTDENT > 0
			_nVlSaldo += (C6_QTDVEN-C6_QTDENT) * C6_PRCVEN
		EndIF
		dbSkip()
	End

	aSort(aRegSC6,,,{|x,y| x[2]+x[3]<y[2]+y[3]})
	oListI:SetArray( aRegSC6 )
	cLine := "{IIF(aRegSC6[oListI:nAt,1]==0,oVerde,IIF(aRegSC6[oListI:nAt,1]==1,oAmarelo,oVermelho))"
	aEval( aCpoSC6, {|x,y| cLine += ",aRegSC6[oListI:nAt,"+LTrim(Str(y))+"]" }, 2 )
	cLine += "}"
	bMyLine := &("{|| "+cLine+"}")
	oListI:bLine := bMyLine
	oListI:Refresh()

	If _nTipo = 1
		oTotalP:refresh()
		oTotalF:refresh()
		oTotalS:refresh()
	EndIf

Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | C900PESQ   | AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA DE PESQUISA PEDIDOS                                    ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function C900Pesq(aVetor,oLbx)
	Local oDlg := Nil
	Local oCombo := Nil
	Local cCombo := ""
	Local aCombo := {}
	Local cPesq := Space(6)
	Local nOpc := 0
	Local nCbx := 1
	Local nP := 0

	aAdd(aCombo,"Nr.Pedido + Item")
	//aAdd(aCombo,"Código do Produto + Nr.Pedido")
	//aAdd(aCombo,"Descrição do Produto + Nr.Pedido")

	DEFINE MSDIALOG oDlg TITLE "Localizar" FROM 65,00 TO 135,235 OF oDlg PIXEL STYLE DS_MODALFRAME STATUS
	//   @ 05,05 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 180,50 ON CHANGE (nCbx:=oCombo:nAt) PIXEL OF oDlg
	@ 05,05 SAY "Pedido" SIZE 80,50  PIXEL OF oDlg
	@ 20,05 MSGET cPesq PICTURE "@!" SIZE 40,07 PIXEL OF oDlg
	DEFINE SBUTTON FROM 03,087 TYPE 1 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 18,087 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc<>1
		Return(.T.)
	Endif
	/*
	If nCbx == 1 .And. nOrd <> 1
	nOrd := 1
	aSort(aVetor,,,{|x,y| x[2]+x[3]<y[2]+y[3]})
	Elseif nCbx == 2 .And. nOrd <> 2
	nOrd := 2
	aSort(aVetor,,,{|x,y| x[4]+x[2]<y[4]+y[2]})
	Elseif nCbx == 3 .And. nOrd <> 3
	nOrd := 3
	aSort(aVetor,,,{|x,y| x[5]+x[2]<y[5]+y[2]})
	Endif
	*/
	aSort(aVetor,,,{|x,y| x[1]<y[1]})
	If Empty(cPesq)
		Return(.T.)
	Endif

	cPesq := AllTrim(cPesq)
	//nP := aScan(aVetor,{|x| cPesq==SubStr(x[IIF(nCbx==1,2,Iif(nCbx==2,4,5))],1,Len(cPesq))})
	nP := aScan(aVetor,{|x| cPesq==SubStr(x[1],1,Len(cPesq))})
	If nP == 0
		MsgInfo("Não foi possível encontrar o registro desejado",_cCadastro)
		nP := 1
	Endif

	oListP:nAt := nP
	oListP:Refresh()
	//oListP:bChange := { || displayItem(aListP[oListP:nAt,1],1)}
	displayItem(aListP[oListP:nAt,1]+aListP[oListP:nAt,3],1)

Return(.T.)
*
/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | C900PEDVEN | AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA DE VISUALIZAÇÃO DOS PEDIDOS DE VENDAS                  ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function C900PedVen(cNumPed)//  AQUI AQUI ESTA FOI CHAMADA PELA C900Click(aRegSC6) -> NO DUPLO CLICK NO ITEM DO PEDIDO // E NO BOTÃO PEDIDO
	Local aArea := GetArea()

	cFilAnt := _cFilPed
	cNumEmp := Left(_cMyNmEmp,2) + cFilAnt
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))

	dbSelectArea("SC5")
	dbSetOrder(1)
	If SC5->(dbSeek(xFilial("SC5")+cNumPed))
		A410Visual("SC5",SC5->(RecNo()),2)
	Endif

	cFilAnt := Right(_cMyNmEmp,2)
	cNumEmp := _cMyNmEmp
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))

	RestArea(aArea)
Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | C900CONS   | AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA DE CONSULTA/SELEÇÃO DAS NOTAS FISCAIS                  ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function C900NFS(cC6_NOTA,cC6_SERIE,cC6_NUM,cC6_ITEM)    // AQUI... ESTA FOI CHAMADA PELO BOTAO NOTA
	Local aSavSX3
	Local aSavSD2
	Local aRegSD2 := {}
	Local aCpoSD2 := {}
	Local aTitSD2 := {}
	Local oDlgNF
	Local oLbxNF
	Local oBtn
	Local i := 0
	Local oFnt := TFont():New("Arial",0,-12)
	Local oPanel
	Local cTitulo := "Duplo click para visualizar a nota fiscal ou <ESC> para retronar."
	Local aAreaAtu := GetArea()

	DbSelectArea("SX3")
	aSavSX3 := GetArea()
	DbSelectArea("SD2")
	aSavSD2 := GetArea()

	//If Empty(cC6_NOTA) .And. Empty(cC6_SERIE)
	//   MsgInfo("Não há nota fiscal a visualizar",_cCadastro)
	//   Return
	//Endif                  

	cFilAnt := _cFilPed
	cNumEmp := Left(_cMyNmEmp,2) + cFilAnt
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))

	dbSelectArea("SD2")
	dbSetOrder(8)
	dbSeek(xFilial("SD2")+cC6_NUM+cC6_ITEM)
	While !Eof() .And. SD2->(D2_FILIAL+D2_PEDIDO+D2_ITEMPV)==xFilial("SD2")+cC6_NUM+cC6_ITEM
		//dbSeek(xFilial("SD2")+cC6_NUM)
		//While !Eof() .And. SD2->(D2_FILIAL+D2_PEDIDO)==xFilial("SD2")+cC6_NUM
		DbSelectArea("SF2") ; DbSetOrder(1)
		DbSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE)
		dbSelectArea("SD2")
		If aScan(aRegSD2,{|x| x[1]+x[2]==D2_DOC+D2_SERIE})==0
			//      aAdd(aRegSD2,{D2_DOC,D2_SERIE,D2_TIPO,D2_EMISSAO,SF2->F2_DTENTR,SF2->F2_FRETE,SF2->F2_SEGURO,SF2->F2_DESCONT,SD2->(RecNo())})
			aAdd(aRegSD2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO,SF2->F2_DTENTR,SF2->F2_DTRETCA,Transform(SF2->F2_HRENTR,"@R 99:99"),SF2->F2_MOTOR,SF2->F2_CARREG,SD2->(RecNo())})
		Endif
		dbSkip()
	End

	If Len( aRegSD2) = 0
		MsgInfo("Não há nota fiscal a visualizar",_cCadastro)
		cFilAnt := Right(_cMyNmEmp,2)
		cNumEmp := _cMyNmEmp
		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cNumEmp,.F.))

		RestArea(aSavSD2)
		RestArea(aSavSX3)
		RestArea(aAreaAtu)

		Return(.T.)
	Endif

	RestArea(aSavSD2)

	//If Len(aRegSD2)==0
	//   MsgInfo("Nenhuma nota fiscal encontrada",_cCadastro)
	//   Return
	//Endif

	/*/
	aAdd(aCpoSD2,"D2_DOC")
	aAdd(aCpoSD2,"D2_SERIE")
	aAdd(aCpoSD2,"D2_TIPO")
	aAdd(aCpoSD2,"D2_EMISSAO")
	aAdd(aCpoSD2,"F2_DTENTR")
	aAdd(aCpoSD2,"F2_FRETE")
	aAdd(aCpoSD2,"F2_SEGURO")
	aAdd(aCpoSD2,"F2_DESCONT")
	/*/

	aAdd(aCpoSD2,"F2_DOC")
	aAdd(aCpoSD2,"F2_SERIE")
	aAdd(aCpoSD2,"F2_EMISSAO")
	aAdd(aCpoSD2,"F2_DTENTR")
	aAdd(aCpoSD2,"F2_DTRETCA")
	aAdd(aCpoSD2,"F2_HRENTR")
	aAdd(aCpoSD2,"F2_MOTOR")
	aAdd(aCpoSD2,"F2_CARREG")
	aAdd(aCpoSD2," ")

	dbSelectArea("SX3")
	dbSetOrder(2)
	For i:=1 To Len(aCpoSD2)
		If dbSeek(aCpoSD2[i],.F.)
			aAdd(aTitSD2,RetTitle(aCpoSD2[i]))
		Else
			aAdd(aTitSD2,"RecNo")
		Endif
	Next i
	RestArea(aSavSX3)

	//If Len(aRegSD2)==1
	//   C900NFSaida(aRegSD2[1,Len(aRegSD2[1])])
	//Else
	_cTransp :=""
	DEFINE MSDIALOG oDlgNF TITLE "Relação de notas fiscais" FROM 0,0 TO 300,700 PIXEL
	oLbxNF := TWBrowse():New(0,0,0,0,,aTitSD2,,oDlgNF,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbxNF:Align := CONTROL_ALIGN_ALLCLIENT
	oLbxNF:SetArray(aRegSD2)
	oLbxNF:bLine := {|| aEval(aRegSD2[oLbxNF:nAt],{|z,w| aRegSD2[oLbxNF:nAt,w] } ) }
	oLbxNF:bLDblClick := {|| C900NFSaida(aRegSD2[oLbxNF:nAt,Len(aRegSD2[oLbxNF:nAt])])}
	oLbxNF:bChange := { || displayTransp(aRegSD2[oLbxNF:nAt,1],aRegSD2[oLbxNF:nAt,2])}

	oPanel := TPanel():New(0,0,"",oDlgNF,NIL,.T.,.F.,NIL,NIL,0,26,.T.,.F.)
	oPanel:Align := CONTROL_ALIGN_BOTTOM
	oPanel:NCLRPANE := 14803406

	TSay():New(4,5,{|| cTitulo },oPanel,,oFnt,,,,.T.,CLR_HBLUE,CLR_WHITE)

	@ 015,008 SAY oTransp VAR _cTransp    PICTURE "@!"	SIZE 220,06   OF oPanel PIXEL

	oBtn := TButton():New(0,0,"&Retornar...",oPanel,{|| oDlgNF:End() },42,11,,,.F.,.T.,.F.,,.F.,{||.T.},,.F.)
	oBtn:Align := CONTROL_ALIGN_RIGHT
	ACTIVATE MSDIALOG oDlgNF CENTER
	//Endif


	cFilAnt := Right(_cMyNmEmp,2)
	cNumEmp := _cMyNmEmp
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cNumEmp,.F.))
	RestArea(aSavSD2)
	RestArea(aSavSX3)
	RestArea(aAreaAtu)


Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO   |displayTransp| AUTOR |Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA MOSTRAR A TRANSPORTADORA                               ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function displayTransp(_cDoc,_cSerie)   // AQUI.. ESTA FOI CHAMADA PELA FUNÇÃO CHAMADA PELO BOBTAO NOTA
	_cTransp := ""
	dbSelectArea("SF2") ; dbSetOrder(1)
	If dbSeek(xFilial("SF2") + _cDoc + _cSerie)
		_cTransp := "Transportadora: "+SF2->F2_TRANSP + "-"+POSICIONE("SA4",1,XFILIAL("SA4")+SF2->F2_TRANSP,"A4_NOME")
	EndIF
	oTransp:refresh()
Return(.T.)



/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    |C900NFSaida| AUTOR | Francisco C Godinho   | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA DE CONSULTA NOTAS FISCAIS                              ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function C900NFSaida(nRecNo)
	Local aSavAtu := GetArea()
	Local aSavSD2
	dbSelectArea("SD2")
	aSavSD2 := GetArea()
	dbSetOrder(3)
	dbGoTo(nRecNo)
	A920NFSAI("SD2",nRecNo,0)
	RestArea(aSavSD2)
	RestArea(aSavAtu)
Return(.T.)

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | C900Click | AUTOR |Francisco C Godinho    | DATA | 01/01/1901 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | DECISÃO DO CLICK NA TELA DE PEDIDOS DE VENDAS                 ||
||---------------------------------------------------------------------------||
|| USO       | FC010CON                                                      ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
Static Function C900Click(aRegSC6) //  AQUI AQUI ESTA NO DUPLO CLICK NO ITEM DO PEDIDO
	Local nOpc := 0
	If !Empty(aRegSC6[16])
		nOpc := Aviso(_cCadastro,"O quê quer consultar?",{" PEDIDO "," NOTA "},1,"Selecione")
		If nOpc == 1
			C900PedVen(aRegSC6[2])
		Elseif nOpc == 2
			C900NFS(aRegSC6[16],aRegSC6[17],aRegSC6[2],aRegSC6[3])
		Endif
	Else
		C900PedVen(aRegSC6[2])
	Endif
Return(.T.)
	
User Function FC010BRW()
	aAdd(aRotina,{ "Hist.Cliente"      , "u_VisuHist(SA1->A1_COD,SA1->A1_LOJA)"    , 0 , 2} )
	//aAdd(aRotina,{ "Hist.Inclui"      , "u_InclHist(.T.,SA1->A1_COD,SA1->A1_LOJA)", 0 , 3} ) //, 0, .F.})
	aAdd(aRotina,{ "Anot.Incluir"  , 'CRMA090(3,"SA1")'  , 0 , 2})  //, 0, .F.})
	aAdd(aRotina,{ "Anot.Visualiza"  , 'CRMA090(,"SA1")'  , 0 , 2})  //, 0, .F.})
Return(.T.)
	
User Function FC010BOL()
	Local oAcl	:= cbcAcl():newcbcAcl()
	PRIVATE aSavaAtu  := GetArea()

	if !oAcl:aclValid('posCliente')
		MsgInf(oAcl:getAlert(), 'Validação de Acesso')
		Return(.F.)
	endif
	
	aAlias := ParamIXB[2]
	aParam := ParamIXB[3]
	aGet   := ParamIXB[5]

	Fc010Brow(ParamIXB[1],@aAlias,aParam,ParamIXB[4],aGet)

	// A função Fc010Brow cria um arquivo de trabalho e não deleta... na próxima chamada ele não 
	// refaz esse arquivo, por isso tem que fechar e deletar o TRB.
	
	If ParamIXB[1] == 1
		cAlias    := "FC010QRY01"
	ElseIf ParamIXB[1] == 2
		cAlias    := "FC010QRY02"
	EndIf
	If Select(cAlias) # 0
		DbSelectArea(cAlias)
		cArquivo := DBINFO(DBI_FULLPATH)
		(cAlias)->(dbCloseArea())
		If Len(cArquivo) > 0
			_cArqNow :=""
			For _nPosi := Len(cArquivo) To 0 Step -1
				If Substr(cArquivo,_nPosi,1) == "\"
					Exit
				EndIf
				_cArqNow := Substr(cArquivo,_nPosi,1) + _cArqNow
			Next
			_cArqNow := Left(_cArqNow,Len(_cArqNow)-4)
			Ferase(_cArqNow+GetDBExtension())
			Ferase(_cArqNow+OrdBagExt())
		EndIf
	EndIf
	
	RestArea(aSavaAtu)
Return(.T.)
