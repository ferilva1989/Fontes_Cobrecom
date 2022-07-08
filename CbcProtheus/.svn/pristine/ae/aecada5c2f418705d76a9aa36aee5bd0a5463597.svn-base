#include "topconn.ch"
#include "rwmake.ch"

/*/{Protheus.doc} CDFAT16
@author legado
@since 21/07/2017
@version 0.0
@type function
@description Similar a rotina de reservas.                               
A rotina padrão não permite realizar reservas mais de uma   
vez para o mesmo produto, pois não consegue controlar o     
SDC com o SC0. Desenvolmenos esta rotina pois a reserva     
tem que acontecer no SBF e não somente no SB2.              
Atenção: A variável _gCodRep tem que estar definida com o código do representante        
/*/
User Function CDFAT16()

	Private aHeader, aCols
	Ft16Depur(.T.)

	aCores    := {{"ZZ_STATUS == '0'","ENABLE"},;    // Aberto 
	{"ZZ_STATUS == '1'","BR_AZUL"},;   // Empenhada
	{"ZZ_STATUS == '2'","BR_AMARELO"},;// Faturado Parcial
	{"ZZ_STATUS == '3'","BR_LARANJA"},;   // Faturado Total
	{"ZZ_STATUS == '9'","DISABLE"}}   // Cancelada

	If "VENDAS" $ Upper(cUserName)
		cCadastro := "Controle de Reservas de Produtos - " + AllTrim(_gCodRep) + " - " + _gNomRep
		aRotina := {{ "Pesquisar"      , "AxPesqui"       , 0 , 1 },;
		{ "Visualizar"     , "U_CDFAT16V()"   , 0 , 2 },;
		{ "Disponibilidade", "U_CDFAT16B()"   , 0 , 3 },;
		{ "Cancelar Item"  , "U_CDFAT16C(.F.)", 0 , 4 },;
		{ "Cancelar Tudo"  , "U_CDFAT16C(.T.)", 0 , 4 },;
		{ "Legenda"        , "U_CDFAT16X()"   , 0 , 6 }}
	Else
		cCadastro := "Controle de Reservas de Produtos"
		aRotina := {{ "Pesquisar"      , "AxPesqui"       , 0 , 1 },;
		{ "Visualizar"     , "U_CDFAT16V()"   , 0 , 2 },;
		{ "Troca Repres."  , "U_CDFAT16T()"   , 0 , 3 },;
		{ "Disponibilidade", "U_CDFAT16B()"   , 0 , 3 },;
		{ "Cancelar Item"  , "U_CDFAT16C(.F.)", 0 , 4 },;
		{ "Cancelar Tudo"  , "U_CDFAT16C(.T.)", 0 , 4 },;
		{ "Legenda"        , "U_CDFAT16X()"   , 0 , 6 }}
	EndIf

	DbSelectArea("ZZ0") // Tabela de Log de acessos
	DbSetOrder(1) // 

	DbSelectArea("SZZ")
	DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
	//Set Filter to ZZ_VEND == _gCodRep

	DbSelectArea("SZZ")
	DbSeek(xFilial("SZZ"),.F.)

	u_GraveLog("Entrou na Rotina",.F.)

	mBrowse(001,040,200,390,"SZZ",,,,,,aCores)
	Set Filter to //Sempre desativar filtro após mBrowse

	u_GraveLog("Saiu da Rotina",.F.)

Return(.T.)

User Function CDFAT16X()
	BrwLegenda(cCadastro,"Legenda",;
	{{"ENABLE"    ,"Reserva Em Aberto"},;
	{"BR_AZUL"   ,"Reserva Empenhada"},;
	{"BR_AMARELO","Faturado Parcial" },;
	{"BR_LARANJA","Faturado Total" },;
	{"DISABLE"   ,"Reserva Cancelada"}})

Return(.T.)

User Function CDFAT16T()
	DefRepr()

	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3") + _gCodRep,.F.)
	_gNomRep := AllTrim(SA3->A3_NOME)
	DbSelectArea("SZZ")
	Set Filter to
	Set Filter to ZZ_VEND == _gCodRep
	DbSeek(xFilial("SZZ"),.F.)
Return(.T.)

User Function CDFAT16V()
	cOpcao:="VISUALIZAR"
	_Reg := SZZ->(Recno())
	u_GraveLog("Entrou Rotina Visualizar",.T.)
	U_MONTARES()
	SZZ->(DbGoTo(_Reg))
	u_GraveLog("Saiu Rotina Visualizar",.T.)
Return(.T.)

User Function CDFAT16C(_lTudo)
	_lAllCanc := .T. // Verifica se a resera já não está cancelada -> Tudos os Itens Estão Cancelados?
	_lTemPV   := .F. // Verifica se a reserva foi atrelada a algum pedido de venda
	_ZZ_NUM   := SZZ->ZZ_NUM
	If _lTudo // 
		DbSelectArea("SZZ")
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.)
		Do While SZZ->ZZ_FILIAL == xFilial("SZZ") .And. SZZ->ZZ_NUM == _ZZ_NUM .And. SZZ->(!Eof())
			If SZZ->ZZ_STATUS # '9'
				_lAllCanc := .F.
			EndIf
			If SZZ->ZZ_QTDPED > 0
				_lTemPV := .T.
			EndIf
			SZZ->(DbSkip())
		EndDo
		If _lAllCanc // Tudo cancelado?
			Alert("Todos os Item da Reserva Já Foram Cancelados")
		ElseIf _lTemPV
			Alert("Existe Itens Empenhados em Pedidos de Vendas")
		EndIf
	Else
		If SZZ->ZZ_STATUS == "9"   // Cancelada
			Alert("Item da Reserva Já Cancelado")
		ElseIf SZZ->ZZ_QTDPED > 0
			Alert("Este Item Está Empenhado em Pedido de Venda")
			_lTemPV := .T.
		Else
			_lAllCanc := .F.
		EndIf               
	EndIf
	If _lAllCanc .Or. _lTemPV // Tudo cancelado?
		Return(.T.)
	EndIf
	// Verificar se existe pedido com essa reserva
	If _lTudo // Todos os Itens  
		SZZ->(DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.))
		cOpcao:="CANCELAR"
		U_MONTARES()
	Else //Somente este item
		nOpca := AxVisual("SZZ",Recno(),2)     
		If nOpca == 1 // Confirmou a Operação
			VolteSZZ("Cancelou a Reserva")
		EndIf
	EndIf
Return(.T.)

User Function MONTARES()

	If cOpcao=="INCLUIR"
		nOpcE:=4 // Apesar de estar 3 no aRotina (senão não entra), tem que ser 4(alterar)para não abrir novamente a primeira tela
		nOpcG:=4 // Apesar de estar 3 no aRotina (senão não entra), tem que ser 4(alterar)para não abrir novamente a primeira tela
		inclui := .T.
		altera := .F.
		exclui := .F.
		//ElseIf cOpcao=="ALTERAR"
		//	nOpcE:=3
		//	nOpcG:=3
		//	inclui := .F.
		//	altera := .T.
		//	exclui := .F.
	ElseIf cOpcao=="VISUALIZAR" .Or. cOpcao == "DISPONI"
		nOpcE:=2
		nOpcG:=2
		inclui := .F.
		altera := .F.
		exclui := .F.
	ElseIf cOpcao=="CANCELAR"
		nOpcE:=5
		nOpcG:=5
		inclui := .F.
		altera := .F.
		exclui := .T.
	EndIf
	aAltEnchoice :={}

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("ZZ_TIPO ",.F.)
	cbSX3TpBx := X3Cbox()
	_aOpcTp := STRTOKARR(cbSX3TpBx,";")

	If cOpcao == "INCLUIR"
		_ZZ_NUM    := CriaVar("ZZ_NUM")// nro da reserva
		_ZZ_TIPO   := " "              // Tipo da Reserva
		_ZZ_VEND   := _gCodRep         // codigo do representante
		_ZZ_EMISSAO:= Date()           // dDataBase        // data da reserva
		_ZZ_DTVALID:= Date()+2         // dDataBase+2      // data de validade da reserva
		_ZZ_CLIENTE:= Space(Len(SZZ->ZZ_CLIENTE))  // codigo do cliente
		_ZZ_LOJA   := Space(Len(SZZ->ZZ_LOJA))     // loja do cliente       
		_ZZ_NOMCLI := Space(Len(SA1->A1_NOME))     // nome do cliente 
	ElseIf cOpcao == "DISPONI"
		// As Variáveis já estão carregadas
		For _nCtd := 1 to Len(_aOpcTp)
			If Left(_aOpcTp[_nCtd],Len(_ZZ_TIPO)) == _ZZ_TIPO
				_ZZ_TIPO := AllTrim(Substr(_aOpcTp[_nCtd],Len(_ZZ_TIPO)+2,100))
				Exit
			EndIf
		Next
	Else
		// nro da reserva
		_ZZ_NUM    := SZZ->ZZ_NUM
		// Tipo da Reserva
		_ZZ_TIPO   := SZZ->ZZ_TIPO
		For _nCtd := 1 to Len(_aOpcTp)
			If Left(_aOpcTp[_nCtd],Len(_ZZ_TIPO)) == _ZZ_TIPO
				_ZZ_TIPO := AllTrim(Substr(_aOpcTp[_nCtd],Len(_ZZ_TIPO)+2,100))
				Exit
			EndIf
		Next
		_ZZ_VEND   := SZZ->ZZ_VEND     // codigo do representante
		_ZZ_EMISSAO:= SZZ->ZZ_EMISSAO  // data da reserva
		_ZZ_DTVALID:= SZZ->ZZ_DTVALID  // data de validade da reserva
		_ZZ_CLIENTE:= SZZ->ZZ_CLIENTE  // codigo do cliente
		_ZZ_LOJA   := SZZ->ZZ_LOJA     // loja do cliente 
		_ZZ_NOMCLI := Posicione("SA1",1,xFilial("SA1")+_ZZ_CLIENTE+_ZZ_LOJA,"A1_NOME") // nome do cliente 
	EndIf
	_ZZ_NOMREP := Posicione("SA3",1,xFilial("SA3")+_ZZ_VEND,"A3_NOME") // nome do representante

	nUsado:=0
	dbSelectArea("SX3")
	DbSetOrder(1)
	dbSeek("SZZ")
	aHeader:={}                                  

	_TamCpo := Len(SX3->X3_CAMPO)
	_cIncCpo:= ""
	_cIncCpo += "ZZ_ITEM"+Space(_TamCpo)    + "//"
	_cIncCpo += "ZZ_PRODUTO"+Space(_TamCpo) + "//"
	_cIncCpo += "ZZ_DESCR"+Space(_TamCpo)   + "//"
	_cIncCpo += "ZZ_LOCAL"+Space(_TamCpo)   + "//"
	_cIncCpo += "ZZ_LOCALIZ"+Space(_TamCpo) + "//"
	_cIncCpo += "ZZ_QUANT"+Space(_TamCpo)   + "//"
	_cIncCpo += "ZZ_OBS"+Space(_TamCpo)     + "//"

	Do While SX3->(!Eof()).And.(SX3->X3_ARQUIVO=="SZZ")
		If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL .And. SX3->X3_CAMPO $ _cIncCpo
			nUsado:=nUsado+1             
			Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
			SX3->X3_TAMANHO, SX3->X3_DECIMAL,If(Empty(SX3->X3_VLDUSER),"AllwaysTrue()",SX3->X3_VLDUSER),;
			SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
		Endif
		SX3->(DbSkip())
	EndDo

	n:=1
	If cOpcao == "INCLUIR"
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		Next
		// Somente Carregar o Acols
	ElseIf cOpcao == "DISPONI"
		SB1->(DbSetOrder(1))
		aCols:={}
		For _nx := 1 to Len(aSelec)
			AADD(aCols,Array(nUsado+1))    
			For _ni:=1 to nUsado
				// Inicializa as variáveis com valores padrão
				aCols[_nx,_ni] := CriaVar(aHeader[_ni,2])
			Next
			aCols[_nx,nUsado+1]:=.F.
			GDFieldPut("ZZ_PRODUTO",aSelec[_nx,1],_nx)
			GDFieldPut("ZZ_LOCALIZ",aSelec[_nx,2],_nx)
			GDFieldPut("ZZ_QUANT"  ,aSelec[_nx,3],_nx)
			GDFieldPut("ZZ_ITEM"   ,aSelec[_nx,4],_nx)
			SB1->(DbSeek(xFilial("SB1") + aSelec[_nx,1],.F.))
			GDFieldPut("ZZ_DESCR"  ,SB1->B1_DESC,_nx)
			GDFieldPut("ZZ_LOCAL"  ,"01",_nx)
		Next
	Else
		aCols:={}
		DbSelectArea("SZZ")
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		DbSeek(xFilial("SZZ")+M->_ZZ_NUM,.F.)
		Do While SZZ->ZZ_FILIAL == xFilial("SZZ") .And. SZZ->ZZ_NUM == M->_ZZ_NUM .And. SZZ->(!eof())
			If cOpcao == "CANCELAR" .And. SZZ->ZZ_STATUS == "9"
				// Não faz Nada
			Else
				AADD(aCols,Array(nUsado+1))
				For _ni:=1 to nUsado
					aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
				Next
				aCols[Len(aCols),nUsado+1]:=.F.
			EndIf
			SZZ->(DbSkip())
		EndDo
	Endif

	_lRet:= .F.
	aButtons := {}
	If Len(aCols)>0
		cTitulo        := "Reserva de Produtos - " + AllTrim(_gCodRep) + " - " + _gNomRep
		cAliasEnchoice := ""
		cAliasGetD     := "SZZ"
		cLinOk         := "AllwaysTrue()"
		cTudOk         := "u_ConfCli(0)"
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice:= {}
		_lRet:=u_JanFt16a(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
	Endif
	If cOpcao == "INCLUIR"
		If _lRet .And. _lGrava
			ConfirmSx8()
		Else
			RollBackSx8()
		EndIf
	EndIf
	If _lRet 
		If cOpcao == "INCLUIR"
			_lFirst := .T.
			_QtdRes := Len(aCols)
			Processa({|lEnd| CDFT16GRV()}, 'Gravando Dados da Reserva....')
			If _lFirst .And. _QtdRes > 0
				MsgAlert("Nenhum Item foi Reservado -> Indisponibilidade","Atenção!")
			Else // Mostrar o Resultado
				If _QtdRes > 0
					MsgAlert("Um ou Mais Itens não Foram Reservados - Verifique!","Atenção!")
				Else
					MsgAlert("Reserva Efetuada com Sucesso - Verifique!","Atenção!")   
				EndIf

				// Abre Novamente a tela para visualizar a reserva
				nOpcE:=2
				nOpcG:=2
				inclui := .F.
				altera := .F.
				exclui := .F.
				u_JanFt16a(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
			EndIf
		ElseIf cOpcao == "CANCELAR"
			CDFT16Dep(.F.,M->_ZZ_NUM)	
		EndIf
	EndIf
Return(_lRet)         

User Function JanFt16a(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,;
	cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)

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

	Private oDlgJ3,oGetDados
	Private lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	nOpcE := If(nOpcE==Nil,2,nOpcE)
	nOpcG := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas:=If(inclui,99,Len(aCols))

	DbSelectArea("SZZ")
	DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM

	DEFINE MSDIALOG oDlgJ3 TITLE cTitulo From 120,0 to 712,980 of oMainWnd PIXEL

	@ 015,005 Say "Nro.Reserva: "                   SIZE 040,10
	@ 015,045 Get _ZZ_NUM Picture "999999" When .F. SIZE 025,10

	@ 015,085 Say "Data da Reserva: "               SIZE 045,10
	@ 015,135 Get _ZZ_EMISSAO              When .F. SIZE 040,10

	@ 015,205 Say "Data de Validade: "             
	@ 015,255 Get _ZZ_DTVALID              When .F. SIZE 040,10

	@ 015,325 Say "Tipo da Reserva: "                              

	If cOpcao == "INCLUIR" 
		@ 015,375 COMBOBOX _ZZ_TIPO ITEMS _aOpcTp SIZE 50,10
	Else
		@ 015,375 Get _ZZ_TIPO WHEN .F. SIZE 50,10
	EndIf

	@ 030,005 Say "Cliente: "                       SIZE 025,10
	@ 030,045 Get _ZZ_CLIENTE F3 "SA1_RV"  When inclui .Or. altera Valid u_ConfCli(1) SIZE 025,10

	@ 030,085 Get _ZZ_LOJA          When inclui .Or. altera Valid u_ConfCli(1)        SIZE 005,10 Object oLoja
	@ 030,115 Get _ZZ_NOMCLI               When .F. SIZE 150,10 Object oNomCli

	oGetDados := MsGetDados():New(080,aPosObj[2,2],290,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk)

	oGetDados:oBrowse:bChange := {|| U_RefoBrow()}

	ACTIVATE MSDIALOG oDlgJ3 ON INIT EnchoiceBar(oDlgJ3,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlgJ3:End()),nOpca := 0)},{||oDlgJ3:End()},,aButtons) CENTERED
	lRet:=(nOpca==1)
Return(lRet)

Static Function CDFT16GRV()
	DbSelectArea("SZZ")
	DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
	For _nx := 1 To Len(aCols)
		If !GDDeleted(_nx)
			// Verificar se tem Saldo no SBF
			SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			SBF->(DbSeek(xFilial("SBF")+"01"+GDFieldGet("ZZ_LOCALIZ",_nx)+GDFieldGet("ZZ_PRODUTO",_nx),.F.))
			If !SBF->(Eof()) .And. (SBF->BF_QUANT - SBF->BF_EMPENHO) >= GDFieldGet("ZZ_QUANT",_nx) .And. SBF->BF_EMPENHO >= 0
				RecLock("SBF",.F.)
				// Vejo de novo se tem saldo
				If (SBF->BF_QUANT - SBF->BF_EMPENHO) >= GDFieldGet("ZZ_QUANT",_nx) .And. SBF->BF_EMPENHO >= 0
					SBF->BF_EMPENHO += GDFieldGet("ZZ_QUANT",_nx)
					MsUnLock()

					// Grava o SB2 - B2_RESERVA
					SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
					If SB2->(DbSeek(xFilial("SB2")+GDFieldGet("ZZ_PRODUTO",_nx)+"01",.F.))
						RecLock("SB2",.F.)
						SB2->B2_RESERVA += GDFieldGet("ZZ_QUANT",_nx)
						MsUnLock()
					EndIf

					// Cria registro no SDC
					RecLock("SDC",.T.)
					SDC->DC_FILIAL  := xFilial("SDC")
					SDC->DC_ORIGEM  := "SZZ"
					SDC->DC_PRODUTO := GDFieldGet("ZZ_PRODUTO",_nx)
					SDC->DC_LOCAL   := "01"
					SDC->DC_LOCALIZ := GDFieldGet("ZZ_LOCALIZ",_nx)
					SDC->DC_QUANT   := GDFieldGet("ZZ_QUANT",_nx)
					SDC->DC_PEDIDO  := If(_lFirst,"  ",_ZZ_NUM)
					SDC->DC_ITEM    := GDFieldGet("ZZ_ITEM",_nx)
					SDC->DC_QTDORIG := GDFieldGet("ZZ_QUANT",_nx)
					SDC->DC_DTLIB   := dDataBase
					SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
					MsUnLock()  
					_nRecSDC := SDC->(Recno())
				Else          
					aCols[_nx,Len(aCols[_nx])]:=.T.
					GDFieldPut("ZZ_QUANT",0.00,_nx)
					MsUnLock()
					Loop
				EndIf
			Else
				aCols[_nx,Len(aCols[_nx])]:=.T.
				GDFieldPut("ZZ_QUANT",0.00,_nx)
				Loop
			EndIf

			If _lFirst
				_lFirst := .F.
				ConfirmSX8()
				Do While SZZ->(DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.))
					_ZZ_NUM := GetSx8Num("SZZ","ZZ_NUM")
					ConfirmSX8()
				EndDo          
				RecLock("SZZ",.T.)
				SZZ->ZZ_FILIAL := xFilial("SZZ")
				SZZ->ZZ_NUM := _ZZ_NUM
				MsUnLock()

				// Sendo o primeiro, ainda não gravei o nro no SDC.
				If SDC->(Recno()) # _nRecSDC
					SDC->(DbGoTo(_nRecSDC))
				EndIf
				RecLock("SDC",.F.)
				SDC->DC_PEDIDO  := _ZZ_NUM
				MsUnLock()

				RecLock("SZZ",.F.)
			Else
				RecLock("SZZ",.T.)
			EndIf
			_QtdRes-- 
			SZZ->ZZ_FILIAL  := xFilial("SZZ")
			SZZ->ZZ_STATUS  := "0" // Em Aberto
			SZZ->ZZ_NUM     := _ZZ_NUM    
			SZZ->ZZ_TIPO    := _ZZ_TIPO
			SZZ->ZZ_EMISSAO := _ZZ_EMISSAO
			SZZ->ZZ_DTVALID := _ZZ_DTVALID
			SZZ->ZZ_VEND    := _ZZ_VEND
			SZZ->ZZ_CLIENTE := _ZZ_CLIENTE
			SZZ->ZZ_LOJA    := _ZZ_LOJA
			SZZ->ZZ_ITEM    := GDFieldGet("ZZ_ITEM",_nx)
			SZZ->ZZ_PRODUTO := GDFieldGet("ZZ_PRODUTO",_nx)
			SZZ->ZZ_DESCR   := GDFieldGet("ZZ_DESCR",_nx)
			SZZ->ZZ_LOCAL   := GDFieldGet("ZZ_LOCAL",_nx)
			SZZ->ZZ_LOCALIZ := GDFieldGet("ZZ_LOCALIZ",_nx)
			SZZ->ZZ_QUANT   := GDFieldGet("ZZ_QUANT",_nx)
			SZZ->ZZ_OBS     := GDFieldGet("ZZ_OBS",_nx)
			MsUnLock()
		Else
			GDFieldPut("ZZ_QUANT",0.00,_nx)
			// Não Considerar os deletados
			_QtdRes--
		EndIf
	Next
Return(.T.)

User Function RefoBrow()
	oGetDados:Refresh()
Return(.T.)

User Function ValProd()
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+M->ZZ_PRODUTO,.F.))
	If SB1->(Eof()) .Or. SB1->B1_TIPO # "PA" .Or. Empty(SB1->B1_NOME)
		Alert("Produto não Cadastrado")
		Return(.F.)
	EndIf
	// Verificar se tem Saldo no SB2
	SB2->(DbSetOrder(1))
	SB2->(DbSeek(xFilial("SB2")+M->ZZ_PRODUTO+"01",.F.))
	If SB2->(Eof()) .Or. (SB2->B2_QATU-SB2->B2_RESERVA) <= 0
		Alert("Produto Sem Saldo para Reservar")
		Return(.F.)
	EndIf
	//Se trocar o produto, zera a quantidade e limpa o acondicionamento
	If M->ZZ_PRODUTO # GDFieldGet("ZZ_PRODUTO",n)
		GDFieldPut("ZZ_QUANT",0.00,n)
		GDFieldPut("ZZ_LOCALIZ",CriaVar("ZZ_LOCALIZ"),n)
		u_RefoBrow()
	EndIf
Return(.T.)            

User Function ValLclz()                                            
	If Empty(GDFieldGet("ZZ_PRODUTO",n))
		Alert("Informar Primeiro do Código do Produto")
		Return(.F.)
	EndIf
	SBE->(DbSetOrder(1)) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If !SBE->(DbSeek(xFilial("SB1")+"01"+M->ZZ_LOCALIZ,.F.))
		Alert("Acondicionamento não Cadastrado")
		Return(.F.)
	EndIf

	_cChave := M->ZZ_LOCALIZ+GDFieldGet("ZZ_PRODUTO",n)
	For _nn := 1 to Len(aCols)
		If _nn # n
			If GDFieldGet("ZZ_LOCALIZ",_nn)+GDFieldGet("ZZ_PRODUTO",_nn) == _cChave
				Alert("Dados já Informados no item " + AllTrim(Str(_nn)))
				Return(.F.)
			EndIf
		EndIf
	Next		

	If PodeEste(GDFieldGet("ZZ_PRODUTO",n),M->ZZ_LOCALIZ)
		// Verificar se tem Saldo no SBF
		SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		SBF->(DbSeek(xFilial("SBF")+"01"+M->ZZ_LOCALIZ+GDFieldGet("ZZ_PRODUTO",n),.F.))
		If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) <= 0 .Or. SBF->BF_EMPENHO < 0
			Alert("Não há Saldo para esse Produto X Acondic.")
			Return(.F.)
		EndIf
	Else
		Alert("Não há Saldo para esse Produto X Acondic.")
		Return(.F.)
	EndIf

	//Se trocar o ACONDICIONAMENTO, zera a quantidade
	If M->ZZ_LOCALIZ # GDFieldGet("ZZ_LOCALIZ",n)
		GDFieldPut("ZZ_QUANT",0.00,n)
		u_RefoBrow()
	EndIf            
Return(.T.)

User Function ValQuant()     
	If Empty(M->_ZZ_CLIENTE) .Or. Empty(M->_ZZ_LOJA)
		Alert("Obrigatório Definir Cliente")
		Return(.F.)
	EndIf
	If Empty(GDFieldGet("ZZ_PRODUTO",n)) .And. Empty(GDFieldGet("ZZ_LOCALIZ",n))
		Alert("Informar Primeiro do Código do Produto e Acondicionamento")
		Return(.F.)
	ElseIf Empty(GDFieldGet("ZZ_PRODUTO",n))
		Alert("Informar Primeiro do Código do Produto")
		Return(.F.)
	ElseIf Empty(GDFieldGet("ZZ_LOCALIZ",n))
		Alert("Informar Primeiro Acondicionamento")
		Return(.F.)
	ElseIf M->ZZ_QUANT < 0
		Alert("Quantidade Inválida")
		Return(.F.)
	EndIf

	// Verificar se tem Saldo no SBF
	SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	SBF->(DbSeek(xFilial("SBF")+"01"+GDFieldGet("ZZ_LOCALIZ",n)+GDFieldGet("ZZ_PRODUTO",n),.F.))
	If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < M->ZZ_QUANT .Or. SBF->BF_EMPENHO < 0
		Alert("Não há Saldo para esse Produto X Acondic.")
		Return(.F.)
	EndIf                                                      
	_nLance := Val(Substr(GDFieldGet("ZZ_LOCALIZ",n),2,5))  
	_nResto := (M->ZZ_QUANT % _nLance)
	If _nResto > 0
		Alert("Somente é Aceito Múltiplo do Acondicionamento - ( " + Str(_nLance,5) + " metros)")
		Return(.F.)
	EndIf
Return(.T.)

User Function ConfCli(nCham)                                           
	If (Empty(M->_ZZ_CLIENTE) .Or. Empty(M->_ZZ_LOJA)) .And. nCham == 0
		Alert("Informar Cliente")
		Return(.F.)
	EndIf
	If !Empty(M->_ZZ_CLIENTE)
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + M->_ZZ_CLIENTE+AllTrim(M->_ZZ_LOJA),.F.))
		If SA1->(Eof()) .Or. SA1->A1_VEND # _gCodRep
			Alert("Cliente não Cadastrado")
			Return(.F.)
		EndIf
		M->_ZZ_LOJA   := SA1->A1_LOJA
		M->_ZZ_NOMCLI := SA1->A1_NOME

		// Troca o Cliente na tabela SZZ
		DbSelectArea("SZZ")
		SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.)
		Do While SZZ->ZZ_NUM == _ZZ_NUM .And. SZZ->(!Eof())
			If SZZ->ZZ_CLIENTE # _ZZ_CLIENTE .Or. SZZ->ZZ_LOJA # _ZZ_LOJA .Or. SZZ->ZZ_TIPO # _ZZ_TIPO
				RecLock("SZZ",.F.)
				SZZ->ZZ_TIPO    := _ZZ_TIPO
				SZZ->ZZ_CLIENTE := _ZZ_CLIENTE
				SZZ->ZZ_LOJA    := _ZZ_LOJA
				MsUnLock()
			EndIf
			SZZ->(DbSkip())
		EndDo             
		oLoja:Refresh()
		oNomCli:Refresh()    
		oGetDados:Refresh()
		oDlgJ3:Refresh()
	EndIf
Return(.T.)

User Function CDFAT16B()                     
	// Apresentar as Disponibilidades conforme indicadas nos parâmetros da tela.
	u_GraveLog("Entrou Rotina p/Reservar",.F.)
	cOpcao:="DISPONI"
	nOpcE:=4 // Apesar de estar 3 no aRotina (senão não entra), tem que ser 4(alterar)para não abrir novamente a primeira tela
	nOpcG:=4 // Apesar de estar 3 no aRotina (senão não entra), tem que ser 4(alterar)para não abrir novamente a primeira tela
	inclui := .T.
	altera := .F.
	exclui := .F.
	aAltEnchoice :={}

	_ZZ_NUM    := CriaVar("ZZ_NUM")// nro da reserva
	_ZZ_TIPO   := " "              // Tipo da Reserva
	_ZZ_VEND   := _gCodRep         // codigo do representante
	_ZZ_NOMREP := Posicione("SA3",1,xFilial("SA3")+_ZZ_VEND,"A3_NOME") // nome do representante
	_ZZ_EMISSAO:= dDataBase        // data da reserva

	// Dois dias úteis para a data de validade
	_ZZ_DTVALID:= DataValida(Date()+1)    // dDataBase+1)      // data de validade da reserva
	_ZZ_DTVALID:= DataValida(_ZZ_DTVALID+1)    // data de validade da reserva

	_ZZ_CLIENTE:= Space(Len(SZZ->ZZ_CLIENTE))  // codigo do cliente
	_ZZ_LOJA   := Space(Len(SZZ->ZZ_LOJA))     // loja do cliente       
	_ZZ_NOMCLI := Space(Len(SA1->A1_NOME))     // nome do cliente 

	_PROD_DE  := Space(Len(SZ1->Z1_COD))
	_DES_PRD1 := Space(50)
	_PROD_AT  := _PROD_DE
	_DES_PRD2 := Space(50)

	_cBitol1  := Space(Len(SZ2->Z2_COD))
	_cDesBt1  := Space(50)
	_cBitol2  := _cBitol1
	_cDesBt2  := Space(50)

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("ZZ_TIPO ",.F.)
	cbSX3TpBx := X3Cbox()
	_aOpcTp := STRTOKARR(cbSX3TpBx,";") //RetSx3Box(Posicione("SX3",2,"ZZ_TIPO","X3_CBOX"),,,14)

	dbSelectArea("SX3")
	DbSetOrder(2) // X3_CAMPO

	// Este aHeader será baseado na tabala SBF - Saldos por Localização
	nUsado:=0
	aHeader:={}           

	// Atenção: Se acrescentar algum campo no aHeader, verificar tb a função  "Static Function LeiaSBF()"
	_nTamX3 := Len(SX3->X3_CAMPO)

	_cCampo := Left("BF_PRODUTO" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_DESC" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Descrição",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_NUMSERI" + Space(100),_nTamX3) // Embalagem
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Embalagem",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_LOTECTL" + Space(100),_nTamX3) // Tam.Lance
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Tam.Lance(m)",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_QUANT" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO)+"(m)",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_EMPENHO" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Qtd.Reserva(m)",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,"u_ValRsrva()",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_LOCAL" + Space(100),_nTamX3) // Vou usar como Observação
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Observação",SX3->X3_CAMPO,"@!",;
	80, 0,"AllwaysTrue()",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_LOCALIZ" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	// Os campos BF_QTSEGUM e BF_PRIOR serão usados para controle da quantidade empenhada..... 
	// pois o empenho nas tabelas SB2, SBF, SDC e SZZ será realizado assim que validar a quantidade 
	// digitada pelo uruário.
	_cCampo := Left("BF_QTSEGUM" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Quant.Emp.",SX3->X3_CAMPO,SX3->X3_PICTURE,;
	SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	_cCampo := Left("BF_PRIOR" + Space(100),_nTamX3)
	DbSeek(_cCampo,.F.)
	nUsado:=nUsado+1             
	Aadd(aHeader,{ 	"Item",SX3->X3_CAMPO,"XX",;
	2,0,".F.",;
	SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )

	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		If !Empty(aCols[1,_ni])
			_cTipo := Type("aCols[1,_ni]")
			If _cTipo == "N"
				aCols[1,_ni] := 0
			ElseIf _cTipo == "C" 
				aCols[1,_ni] := Space(Len(aCols[1,_ni]))
			EndIf
		EndIf
	Next    

	// Enganando o inicializador padrão do campo BF_DESCR
	DbSelectArea("SBF")
	DbGoBottom()
	If !Eof()
		DbSkip()
	EndIf

	_lRet:= .F.
	aButtons := {}

	cTitulo        := "Reserva de Produtos - " + AllTrim(_gCodRep) + " - " + _gNomRep
	cAliasEnchoice := ""
	cAliasGetD     := "SBF"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "u_ValCabec()"
	cFieldOk       := "AllwaysTrue()"
	_lViuSX8       := .F.

	aCpoEnchoice:= {}
	Do While .T.
		_lRet:=u_JanFt16b(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)

		If _lRet // Confirmou a Operação
			Exit
		Else
			// Se tiver algo empenhado, estornar e avisar o Usuário
			_nQtdEmp := 0
			_cItem   := "  "                

			For _nx := 1 to Len(aCols)
				_nQtdEmp += GDFieldGet("BF_EMPENHO",_nx)
				If Empty(_cItem)
					_cItem := GDFieldGet("BF_PRIOR",_nx)
				EndIf
			Next

			If _nQtdEmp > 0 // Empenhou alguma coisa
				_Volta := MsgBox("Você está Cancelando a Operação e Um ou Mais Itens Foram Empenhados";
				,"Escola 'SIM' Para Confirmar o Cancelamento ou 'NÃO' Para Retornar a Digitar","YesNo")
				If _Volta // Confirmou o cancelamento
					// Estornar os Empenhos
					DbSelectArea("SZZ")
					SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
					DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.)
					Do While SZZ->ZZ_NUM == _ZZ_NUM .And. SZZ->(!Eof())
						VolteSZZ("Arrependeu da Reserva")
						RecLock("SZZ",.F.) // Tenho exclusividade no registro?
						DbDelete()
						MsUnLock()
						SZZ->(DbSkip())
					EndDo             
					Exit
				EndIf
			Else
				If Empty(_cItem)
					RollBackSx8() 
				EndIf
				Exit
			EndIf
		EndIf
	EndDo
	If _lRet
		// Leio todos os SZZs para gravar o Cliente, Loja e tipo, pois podem ter sido trocado
		// durante a digitação
		u_GraveLog("Confirmou a Reserva " + _ZZ_NUM,.F.)
		DbSelectArea("SZZ")
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		DbSeek(xFilial("SZZ")+_ZZ_NUM,.F.)
		Do While SZZ->ZZ_NUM == _ZZ_NUM .And. SZZ->(!Eof())
			RecLock("SZZ",.F.)
			SZZ->ZZ_TIPO    := _ZZ_TIPO
			SZZ->ZZ_CLIENTE := _ZZ_CLIENTE
			SZZ->ZZ_LOJA    := _ZZ_LOJA
			MsUnLock()
			SZZ->(DbSkip())
		EndDo

		// Joga os dados para outro array para Excluir o que não foi selecionado
		// Limpa do Acols o que não foi empenhado
		// Jogo os dados para aSelec para deixar o aCols livre ao chamar outra rotina
		aSelec := {} // Neste array só tem Produto, Localiz e quantidade
		For _nx := 1 to Len(aCols)
			If GDFieldGet("BF_EMPENHO",_nx) > 0
				AADD(aSelec,Array(4))
				aSelec[Len(aSelec),1] := GDFieldGet("BF_PRODUTO",_nx)
				aSelec[Len(aSelec),2] := GDFieldGet("BF_LOCALIZ",_nx)
				aSelec[Len(aSelec),3] := GDFieldGet("BF_EMPENHO",_nx)
				aSelec[Len(aSelec),4] := GDFieldGet("BF_PRIOR"  ,_nx)
			EndIf
		Next
		If Len(aSelec) > 0 // Tem algo para confirmar
			aCols := {}
			U_MONTARES() // Para confirmar as reservar - com cOpcao:="DISPONI"
		EndIf
	EndIf
Return(.T.)         

User Function JanFt16b(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,;
	cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)

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

	Private oDlgJ3,oGetDados
	Private lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	nOpcE := If(nOpcE==Nil,2,nOpcE)
	nOpcG := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas:=99

	DbSelectArea("SBF")
	DbSetOrder(1)    
	DEFINE MSDIALOG oDlgJ3 TITLE cTitulo From 120,0 to 712,980 of oMainWnd PIXEL
	@ 015,005 Say "Número:"
	@ 015,035 Get _ZZ_NUM Picture "999999" When .F. SIZE 025,10 Object o_ZZ_NUM
	@ 015,085 Say "Data da Reserva:"
	@ 015,135 Get _ZZ_EMISSAO              When .F. SIZE 040,10
	@ 015,205 Say "Data de Validade:"              
	@ 015,255 Get _ZZ_DTVALID              When .F. SIZE 040,10
	@ 015,325 Say "Tipo da Reserva:"
	@ 015,375 COMBOBOX _ZZ_TIPO ITEMS _aOpcTp SIZE 50,10

	@ 030,005 Say "Cliente:"
	@ 030,035 Get _ZZ_CLIENTE F3 "SA1_RV"  When inclui .Or. altera Valid u_ConfCli(1) SIZE 025,10
	@ 030,070 Get _ZZ_LOJA                 When inclui .Or. altera Valid u_ConfCli(1) SIZE 005,10 Object oLoja
	@ 030,090 Get _ZZ_NOMCLI               When .F. SIZE 220,10 Object oNomCli

	@ 045,005 Say "Do Produto:"
	@ 045,035 Get _PROD_DE      Valid u_ValDads(1)       F3 "SZ1_RV"     SIZE 025,10 oBject oPROD_DE
	@ 045,070 Get _DES_PRD1                When .F. SIZE 100,10 oBject oDES_PRD1

	@ 045,190 Say "Até Produto:"
	@ 045,225 Get _PROD_AT      Valid u_ValDads(2)       F3 "SZ1_RV"     SIZE 025,10
	@ 045,260 Get _DES_PRD2                When .F. SIZE 100,10  oBject oDES_PRD2

	@ 060,005 Say "Da Bitola:"
	@ 060,035 Get _cBitol1     Valid u_ValDads(3)        F3 "SZ2_RV"     SIZE 025,10
	@ 060,070 Get _cDesBt1                When .F. SIZE 100,10 oBject ocDesBt1
	@ 060,190 Say "Até Bitola:"
	@ 060,225 Get _cBitol2     Valid u_ValDads(4)        F3 "SZ2_RV"     SIZE 025,10
	@ 060,260 Get _cDesBt2                When .F. SIZE 100,10 oBject ocDesBt2

	// Posicionar os botoes no cabeçalho
	@ 045,375 BUTTON "Selecionar"    SIZE 045,012 ACTION u_SelSBF()  Object oBtSel
	@ 060,375 BUTTON "Ordem Produto" SIZE 045,012 ACTION u_Ordena(1) Object oBtOrd1
	@ 060,430 BUTTON "Ordem Lance"   SIZE 045,012 ACTION u_Ordena(2) Object oBtOrd2

	oGetDados := MsGetDados():New(080,aPosObj[2,2],290,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_RefoBrow()}

	ACTIVATE MSDIALOG oDlgJ3 ON INIT EnchoiceBar(oDlgJ3,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlgJ3:End()),nOpca := 0)},{||oDlgJ3:End()},,aButtons) CENTERED
	lRet:=(nOpca==1)
Return(lRet)

User Function SelSBF()
	If Empty(_PROD_AT) .Or. Empty(_cBitol2)
		Alert("Defina Corretamente as Abrangências de Produto e Bitola")
		oPROD_DE:SetFocus()
		Return(.T.)
	EndIf        
	If (_PROD_AT < _PROD_DE  .And. !Empty(_PROD_AT)) .Or.;
	(_cBitol2 < _cBitol1  .And. !Empty(_cBitol2))
		Alert("Informar o Segundo Parâmetro Sempre Maior ou Igual ao Primeiro")
		Return(.F.)
	EndIf

	// Limpa do Acols o que não foi empenhado
	aCls := {}
	For _nx := 1 to Len(aCols)
		If GDFieldGet("BF_EMPENHO",_nx) > 0
			AADD(aCls,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCls[Len(aCls),_ni] := aCols[_nx,_ni]
			Next
			aCls[Len(aCls),nUsado+1]:=.F.
		EndIf
	Next

	aCols := {}
	For _nx := 1 to Len(aCls)
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni] := aCls[_nx,_ni]
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
	Next

	_nPosPrd := GDFieldPos("BF_PRODUTO")
	_nPosLcl := GDFieldPos("BF_LOCALIZ")

	Processa({|lEnd| LeiaSBF()}, 'Selecionando Disponibilidades SBF....')
	Processa({|lEnd| LeiaSZE()}, 'Selecionando Disponibilidades SZE....')

	aSort(aCols,,,{|x,y| x[_nPosPrd]+x[_nPosLcl]<y[_nPosPrd]+y[_nPosLcl]})
	N:=1
	oGetDados:Refresh()
	oDlgJ3:Refresh()
Return(.T.)

User Function ValDads(_nCpo)                          
	If _nCpo == 1 .And. !Empty(_PROD_DE)
		SZ1->(DbSetOrder(1)) // Z1_FILIAL+Z1_COD
		SZ1->(DbSeek(xFilial("SZ1")+_PROD_DE,.F.))
		If SZ1->(Eof()) .Or. _PROD_DE < "101" .Or. _PROD_DE > "148"
			Alert("Código não Cadastrado")
			Return(.F.)
		EndIf
		_DES_PRD1 := Left(SZ1->Z1_DESC+Space(100),Len(_DES_PRD1))
	ElseIf _nCpo == 2 .And. !Empty(_PROD_AT)
		SZ1->(DbSeek(xFilial("SZ1")+_PROD_AT,.F.))
		If SZ1->(Eof()) .Or. _PROD_AT < "101" .Or. _PROD_AT > "148"
			Alert("Código não Cadastrado")
			Return(.F.)
		EndIf
		_DES_PRD2 := Left(SZ1->Z1_DESC+Space(100),Len(_DES_PRD2))
	ElseIf _nCpo == 3 .And. !Empty(_cBitol1)
		SZ2->(DbSetOrder(1)) // Z2_FILIAL+Z2_COD
		SZ2->(DbSeek(xFilial("SZ2") + _cBitol1,.F.))
		If SZ2->(Eof())
			Alert("Código não Cadastrado")
			Return(.F.)
		EndIf
		_cDesBt1 := Left(SZ2->Z2_DESC+Space(100),Len(_cDesBt1))
	ElseIf _nCpo == 4 .And. !Empty(_cBitol2)
		SZ2->(DbSeek(xFilial("SZ2") + _cBitol2,.F.))
		If SZ2->(Eof())
			Alert("Código não Cadastrado")
			Return(.F.)
		EndIf
		_cDesBt2 := Left(SZ2->Z2_DESC + Space(100),Len(_cDesBt2))
	EndIf
	oDES_PRD1:Refresh()
	ocDesBt1:Refresh()
	oGetDados:Refresh()
	oDlgJ3:Refresh()
Return(.T.)

User Function ValRsrva()
	// Verificar se a quantidade empenhada não é maior que a  quantidade disponível
	If M->BF_EMPENHO == GDFieldGet("BF_QTSEGUM",n) // Não alterou a quantidade
		Return(.T.)
	EndIf
	// Verifica se digitou Cliente/Loja
	If Empty(M->_ZZ_CLIENTE) .Or. Empty(M->_ZZ_LOJA)
		Alert("Primeiro Denifir Cliente/Loja")
		Return(.F.)
	EndIf
	// Verificar se é múltiplo do acondicionamento
	_nTLance := Val(Substr(GDFieldGet("BF_LOCALIZ",n),2,5))
	If (M->BF_EMPENHO % _nTLance) > 0
		Alert("Quantidade Só Pode Ser Multiplo do Acondicionamento")
		Return(.F.)
	EndIf

	If "B" $ GDFieldGet("BF_LOCALIZ",n)
		// Se for bobina vou ver se tem bobinas disponíveis
		// 1 Quantas já estão reservadas //// Verificar se tenho 3 bobinas livres no estoque
		_nTmLnce := Val(GDFieldGet("BF_LOTECTL",n)) // Tamanho do Lance
		_nQtdDif := (M->BF_EMPENHO - GDFieldGet("BF_QTSEGUM",n)) // Quantidade a adicionar ou a subtrair
		If _nQtdDif < 0 // Se a quantidade for Negativa -> Tenho que DESEMPENHAR n Bobinas
			_ZE_STATUS := "W" // Tenho que procurar as empenhadas
		Else
			_ZE_STATUS := "T" // Tenho que procurar as em estoque
		EndIf

		DbSelectArea("SZE")
		SZE->(DbSetOrder(4)) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
		Do While _nQtdDif # 0
			DbSeek(xFilial("SZE")+_ZE_STATUS+GDFieldGet("BF_PRODUTO",n),.F.)

			Do While SZE->ZE_FILIAL  == xFilial("SZE") .And. SZE->ZE_STATUS == _ZE_STATUS .And. _nQtdDif # 0 .And. ;
			SZE->ZE_PRODUTO == GDFieldGet("BF_PRODUTO",n) .And. SZE->(!Eof())
				If SZE->ZE_QUANT == _nTmLnce		
					If _nQtdDif < 0 .And. SZE->ZE_RESERVA == _ZZ_NUM
						RecLock("SZE",.F.)
						SZE->ZE_RESERVA := Space(Len(SZE->ZE_RESERVA))
						SZE->ZE_STATUS := "T" // Volta a Bobina para estoque
						MsUnLock()
						_nQtdDif += SZE->ZE_QUANT
						Exit // Cai fora do loop pra forçar o DbSeek acima
					ElseIf _nQtdDif > 0 .And. Empty(SZE->ZE_RESERVA)
						// Verifica se o nro da reserva é esse mesmo
						If !_lViuSX8 // Ainda não foi verificado o nro da reserva
							VejaNum()
							_lViuSX8 := .T.
						EndIf

						RecLock("SZE",.F.)
						SZE->ZE_RESERVA := _ZZ_NUM
						SZE->ZE_STATUS := "W" // Bobina reservada por vendas
						MsUnLock()
						_nQtdDif -= SZE->ZE_QUANT
						Exit // Cai fora do loop pra forçar o DbSeek acima

					EndIf
				EndIf       
				SZE->(DbSkip())
			EndDo
		EndDo
	EndIf	

	SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	SBF->(DbSeek(xFilial("SBF")+"01"+GDFieldGet("BF_LOCALIZ",n)+GDFieldGet("BF_PRODUTO",n),.F.))
	If SBF->(Eof())
		Alert("Quantidade Maior que a Quantidade Disponível")
		Return(.F.)
	EndIf                  

	_nQtdPv := SomePvAb()

	RecLock("SBF",.F.)
	If (SBF->BF_QUANT-SBF->BF_EMPENHO) < (M->BF_EMPENHO-GDFieldGet("BF_QTSEGUM",n)) .And. SBF->BF_EMPENHO >= 0
		MsUnLock()
		Alert("Quantidade Maior que a Quantidade Disponível")
		Return(.F.)
	EndIf
	SBF->BF_EMPENHO := SBF->BF_EMPENHO + (M->BF_EMPENHO-GDFieldGet("BF_QTSEGUM",n))
	MsUnLock()

	_nQtdOld := GDFieldGet("BF_QTSEGUM",n)
	_nQtdNew := M->BF_EMPENHO
	GDFieldPut("BF_QTSEGUM",M->BF_EMPENHO,n)

	// Grava o SB2 - B2_RESERVA
	SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If SB2->(DbSeek(xFilial("SB2")+GDFieldGet("BF_PRODUTO",n)+"01",.F.))
		RecLock("SB2",.F.)
		SB2->B2_RESERVA += (_nQtdNew - _nQtdOld)
		MsUnLock()
	EndIf

	_cItem := GDFieldGet("BF_PRIOR",n)
	If _nQtdNew > 0 // Ver o Proximo Item
		If Empty(GDFieldGet("BF_PRIOR",n))
			_cItem := "00"                
			For _nx := 1 to Len(aCols)
				If GDFieldGet("BF_PRIOR",_nx) > _cItem
					_cItem := GDFieldGet("BF_PRIOR",_nx)
				EndIf
			Next
			_cItem := Soma1(_cItem)
		EndIf
	EndIf
	GDFieldPut("BF_PRIOR",_cItem,n)

	If _nQtdNew >  0 
		If _nQtdOld == 0 // Criar Novos Registros no SDC e SZZ
			// Verifica se o nro da reserva é esse mesmo
			If !_lViuSX8 // Ainda não foi verificado o nro da reserva
				VejaNum()
				_lViuSX8 := .T.
			EndIf

			// Cria registro no SDC
			RecLock("SDC",.T.)
			SDC->DC_FILIAL  := xFilial("SDC")
			SDC->DC_ORIGEM  := "SZZ"
			SDC->DC_PRODUTO := GDFieldGet("BF_PRODUTO",n)
			SDC->DC_LOCAL   := "01"
			SDC->DC_LOCALIZ := GDFieldGet("BF_LOCALIZ",n)
			SDC->DC_QUANT   := _nQtdNew
			SDC->DC_PEDIDO  := _ZZ_NUM
			SDC->DC_ITEM    := _cItem
			SDC->DC_QTDORIG := _nQtdNew
			SDC->DC_DTLIB   := dDataBase
			SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
			MsUnLock()  

			// Cria registro no SZZ
			RecLock("SZZ",.T.)
			SZZ->ZZ_FILIAL  := xFilial("SZZ")
			SZZ->ZZ_STATUS  := "0" // Em Aberto
			SZZ->ZZ_NUM     := _ZZ_NUM    
			SZZ->ZZ_TIPO    := _ZZ_TIPO
			SZZ->ZZ_EMISSAO := _ZZ_EMISSAO
			SZZ->ZZ_DTVALID := _ZZ_DTVALID
			SZZ->ZZ_VEND    := _ZZ_VEND
			SZZ->ZZ_CLIENTE := _ZZ_CLIENTE
			SZZ->ZZ_LOJA    := _ZZ_LOJA
			SZZ->ZZ_ITEM    := _cItem
			SZZ->ZZ_PRODUTO := GDFieldGet("BF_PRODUTO",n)
			SZZ->ZZ_DESCR   := GDFieldGet("BF_DESC",n)
			SZZ->ZZ_LOCAL   := "01"
			SZZ->ZZ_LOCALIZ := GDFieldGet("BF_LOCALIZ",n)
			SZZ->ZZ_OBS     := GDFieldGet("BF_LOCAL",n) // Observação
			SZZ->ZZ_QUANT   := _nQtdNew
			MsUnLock()  
			u_GraveLog("Reservou",.T.)

		ElseIf _nQtdOld >  0 // Alterar as Quantidades nos Registros no SDC e SZZ
			DbSelectArea("SZZ")
			DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
			If DbSeek(xFilial("SZZ")+_ZZ_NUM+_cItem,.F.)
				_nQtdAnt := SZZ->ZZ_QUANT
				RecLock("SZZ",.F.)
				SZZ->ZZ_QUANT := _nQtdNew
				SZZ->ZZ_OBS   := GDFieldGet("BF_LOCAL",n) // Observação
				MsUnLock()
				u_GraveLog("Alterou a quantidade de " + Str(_nQtdAnt,10,2),.T.)
			EndIf
			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+
			// DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI				
			If DbSeek(xFilial("SDC") + SZZ->ZZ_PRODUTO + SZZ->ZZ_LOCAL + "SZZ" + SZZ->ZZ_NUM + SZZ->ZZ_ITEM,.F.)
				RecLock("SDC",.F.)
				SDC->DC_QUANT   := _nQtdNew
				SDC->DC_QTDORIG := _nQtdNew
				SDC->DC_DTLIB   := dDataBase
				SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
				MsUnLock()
			EndIf
		EndIf
	ElseIf _nQtdNew == 0 .And. _nQtdOld >  0 // Exluir os   Registros no SDC e SZZ
		DbSelectArea("SZZ")
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		If DbSeek(xFilial("SZZ")+_ZZ_NUM+_cItem,.F.)
			u_GraveLog("Estornou a reserva",.T.)
			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+
			// DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI				
			If DbSeek(xFilial("SDC") + SZZ->ZZ_PRODUTO + SZZ->ZZ_LOCAL + "SZZ" + SZZ->ZZ_NUM + SZZ->ZZ_ITEM,.F.)
				RecLock("SZZ",.F.)
				DbDelete()
				MsUnLock()

				RecLock("SDC",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	EndIf
Return(.T.)

Static Function LeiaSBF()       
	u_GraveLog("Selecionou Produto  de: " +_DES_PRD1,.F.)
	u_GraveLog("Selecionou Produto Ate: " +_DES_PRD2,.F.)
	u_GraveLog("Selecionou Bitola   de: " +_cDesBt1 ,.F.)
	u_GraveLog("Selecionou Bitola  Ate: " +_cDesBt2 ,.F.)

	// Ver Quantos registros tem no SBF
	cQuery := ""
	cQuery += " SELECT COUNT(*) TOTAL FROM "+RetSqlName("SBF")
	cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"'"
	cQuery += " AND Left(BF_PRODUTO,3) >= '"+_PROD_DE+"' AND Left(BF_PRODUTO,3) <= '"+_PROD_AT+"'""
	cQuery += " AND D_E_L_E_T_ <>'*'"

	cQuery := ChangeQuery(cQuery)     

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()        

	_nQtReg := TRB->TOTAL
	DbCloseArea()

	ProcRegua(_nQtReg)

	DbSelectArea("SB1")
	DbSetOrder(1)

	// O loop abaixo não carrega produtos da curva
	// As bobinas serão carregadas na função LeiaSZE()
	DbSelectArea("SBF")
	DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	DbSeek(xFilial("SBF")+_PROD_DE,.T.)
	Do While SBF->BF_FILIAL == xFilial("SBF") .And. Left(SBF->BF_PRODUTO,3) <= _PROD_AT .And. SBF->(!Eof())

		IncProc()

		If Substr(SBF->BF_PRODUTO,4,2) < _cBitol1 .Or. Substr(SBF->BF_PRODUTO,4,2) > _cBitol2 .Or. ;
		SBF->BF_QUANT <= SBF->BF_EMPENHO .Or. SBF->BF_EMPENHO < 0 .Or. SBF->BF_LOCAL # "01" .Or.;
		!PodeEste(SBF->BF_PRODUTO,SBF->BF_LOCALIZ)
			SBF->(DbSkip())
			Loop
		EndIf

		SB1->(DbSeek(xFilial("SB1")+SBF->BF_PRODUTO,.F.))
		If SB1->(Eof()) .Or. SB1->B1_TIPO # "PA" .Or. Empty(SB1->B1_NOME) // .Or. SB1->B1_ESPECIA # "01"
			SBF->(DbSkip())
			Loop
		EndIf

		// Verifica se já não está no acols -> do jeito portuga... mas sei que funciona
		// pode ser que tenha sobrado algum elemento do processamento anterior
		_lTem := .F.
		For _nNx := 1 to Len(aCols)
			If GDFieldGet("BF_PRODUTO",_nNx) == SBF->BF_PRODUTO .And.;
			GDFieldGet("BF_LOCALIZ",_nNx) == SBF->BF_LOCALIZ
				_lTem := .T.
				Exit
			EndIf
		Next

		If !_lTem
			// Verificar quanto tem de pedidos em aberto para esse produto/localização
			_nQtdPv := SomePvAb()
			If (SBF->BF_QUANT-SBF->BF_EMPENHO-_nQtdPv) >= 0 .And. SBF->BF_EMPENHO >= 0 
				AADD(aCols,Array(nUsado+1))
				_nCols := Len(aCols)     '
				aCols[_nCols,nUsado+1]:=.F.

				GDFieldPut("BF_PRODUTO",SBF->BF_PRODUTO,_nCols)
				GDFieldPut("BF_DESC"   ,SB1->B1_DESC,_nCols)
				GDFieldPut("BF_LOCALIZ",SBF->BF_LOCALIZ,_nCols)
				GDFieldPut("BF_QUANT"  ,SBF->BF_QUANT-SBF->BF_EMPENHO-_nQtdPv,_nCols)
				GDFieldPut("BF_EMPENHO",0.00,_nCols)   
				GDFieldPut("BF_LOCAL"  ,Space(Len(SZZ->ZZ_OBS)),_nCols) // Observação
				GDFieldPut("BF_QTSEGUM",0.00,_nCols)   
				GDFieldPut("BF_PRIOR"  ,"  ",_nCols)   
				_cLocaliz := Left(SBF->BF_LOCALIZ,1)
				If _cLocaliz == "T"   
					GDFieldPut("BF_NUMSERI","Lance Irregular ",_nCols)   
				ElseIf _cLocaliz == "R"
					GDFieldPut("BF_NUMSERI","Rolo            ",_nCols)   
				ElseIf _cLocaliz == "C"
					GDFieldPut("BF_NUMSERI","Carretel N8     ",_nCols)   
				ElseIf _cLocaliz == "M"
					GDFieldPut("BF_NUMSERI","Carretel Madeira",_nCols)   
				ElseIf _cLocaliz == "B"
					GDFieldPut("BF_NUMSERI","Bobina          ",_nCols)   
				Else
					GDFieldPut("BF_NUMSERI","????            ",_nCols)   
				EndIf
				GDFieldPut("BF_LOTECTL",Str(Val(Substr(SBF->BF_LOCALIZ,2,5)),Len(SBF->BF_LOTECTL)),_nCols)   
			EndIf
		EndIf
		SBF->(DbSkip())
	EndDo
Return(.T.)

Static Function LeiaSZE()
	// Ver Quantos registros tem no SBF
	cQuery := ""
	cQuery += " SELECT COUNT(*) TOTAL FROM "+RetSqlName("SZE")
	cQuery += " WHERE ZE_FILIAL = '"+xFilial("SZE")+"'"
	cQuery += " AND Left(ZE_PRODUTO,5) >= '"+_PROD_DE+_cBitol1+"' AND Left(ZE_PRODUTO,5) <= '"+_PROD_AT+_cBitol2+"'""
	cQuery += " AND D_E_L_E_T_ <>'*' AND ZE_STATUS = 'T'"
	cQuery := ChangeQuery(cQuery)     
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()        

	_nQtReg := TRB->TOTAL
	DbCloseArea()

	ProcRegua(_nQtReg)
	DbSelectArea("SZE")
	DbSetOrder(4) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
	DbSeek(xFilial("SZE")+"T"+_PROD_DE+_cBitol1,.T.)
	Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_STATUS == "T" .And.;
	Left(SZE->ZE_PRODUTO,5) <= _PROD_AT+_cBitol2 .And. SZE->(!Eof())

		IncProc()
		If Substr(SZE->ZE_PRODUTO,4,2) < _cBitol1 .Or. Substr(SZE->ZE_PRODUTO,4,2) > _cBitol2
			SZE->(DbSkip())
			Loop
		EndIf

		SB1->(DbSeek(xFilial("SB1")+SZE->ZE_PRODUTO,.F.))
		If SB1->(Eof()) .Or. SB1->B1_TIPO # "PA" .Or. Empty(SB1->B1_NOME) // .Or. SB1->B1_ESPECIA # "01"
			SZE->(DbSkip())
			Loop
		EndIf

		// Verifica se já não está no acols -> do jeito portuga... mas sei que funciona
		_nArray := 0
		_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(30),Len(SBF->BF_LOCALIZ))
		For _nNx := 1 to Len(aCols)
			If GDFieldGet("BF_PRODUTO",_nNx) == SZE->ZE_PRODUTO .And.;
			GDFieldGet("BF_LOCALIZ",_nNx) == _cLocaliz
				_nArray := _nNx
				Exit
			EndIf
		Next

		If 	_nArray == 0
			AADD(aCols,Array(nUsado+1))
			_nCols := Len(aCols)     '
			aCols[_nCols,nUsado+1]:=.F.
			GDFieldPut("BF_PRODUTO",SZE->ZE_PRODUTO,_nCols)
			GDFieldPut("BF_DESC"   ,SB1->B1_DESC,_nCols)
			GDFieldPut("BF_LOCALIZ",_cLocaliz,_nCols)
			GDFieldPut("BF_QUANT"  ,SZE->ZE_QUANT,_nCols)
			GDFieldPut("BF_EMPENHO",0.00,_nCols)   
			GDFieldPut("BF_LOCAL"  ,Space(Len(SZZ->ZZ_OBS)),_nCols) // Observação
			GDFieldPut("BF_QTSEGUM",0.00,_nCols)   
			GDFieldPut("BF_PRIOR"  ,"  ",_nCols)   
			GDFieldPut("BF_NUMSERI","Bobina          ",_nCols)   
			GDFieldPut("BF_LOTECTL",Str(SZE->ZE_QUANT,Len(SBF->BF_LOTECTL)),_nCols)   
		Else
			GDFieldPut("BF_QUANT",GDFieldGet("BF_QUANT",_nArray)+SZE->ZE_QUANT,_nArray)
		EndIf
		SZE->(DbSkip())
	EndDo
Return(.T.)

User Function Ordena(_nComo)                          
	_nPosPrd := GDFieldPos("BF_PRODUTO")
	_nPosLcl := GDFieldPos("BF_LOCALIZ")
	_nPosLnc := GDFieldPos("BF_LOTECTL")
	If _nComo == 1 // Por Produto
		aSort(aCols,,,{|x,y| x[_nPosPrd]+x[_nPosLcl]<y[_nPosPrd]+y[_nPosLcl]})
	Else // Por Acond
		aSort(aCols,,,{|x,y| x[_nPosLnc]+x[_nPosPrd]<y[_nPosLnc]+y[_nPosPrd]})
	EndIf
	n:=1
	oGetDados:Refresh()
	oDlgJ3:Refresh()
Return(.T.)

User Function PrepRepr()       
	Local aParamBox := {}
	Private aRet    := {}
	Public _gCodRep := "      "

	_lVolta := 0
	If "VENDAS" $ Upper(cUserName)
		DbSelectArea("SA3")
		DbSetOrder(3) // A3_FILIAL + A3_CGC
		_nVez := 1
		Do While _nVez < 4
			aParamBox := {}
			aAdd(aParamBox,{1,"C.N.P.J.",Space(14),"@R 99.999.999/9999-99","","","",055,.T.})
			aAdd(aParamBox,{8,"Senha   ",Space(06),"","","","",030,.T.})
			If !ParamBox(aParamBox, "Parametros", @aRet)
				_lVolta := 2
				Exit
			Else                
				_lVolta := 1
				If !SA3->(DbSeek(xFilial("SA3")+aRet[1],.F.))
					Alert("CNPJ Inválido!")
				ElseIf SA3->A3_SENHA # aRet[2]
					Alert("Senha Inválida")
				Else           
					_gCodRep := SA3->A3_COD
					_lVolta  := VejaExcl()
					Exit
				EndIf
			EndIf
			_nVez++
		EndDo                  
	EndIf
	If _lVolta > 0
		If _lVolta == 2 // no 1 já deu a mensg acima
			Alert("Abortado pelo Usuário")
		ElseIf _lVolta == 3
			Alert("É Permitido Somente UM Acesso por Representante")
		ElseIf _lVolta == 4
			Alert("ERRO ao Abrir Arquivo de Configuração - Contate Administrador")
		EndIf
		DbCloseAll()
		__Quit()
	EndIf
	Ft16Depur(.T.)
Return(.T.)

Static Function Ft16Depur(_lTodos)

	Processa({|lEnd| CDFT16Dep(_lTodos)}, If(_lTodos,'Depurando Reservas....',"Cancelando Reserva..."))
Return(.T.)

Static Function CDFT16Dep(_lTodos,_ZZ_NUM)

	DbSelectArea("SDC")
	DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI				

	DbSelectArea("SBF")
	DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	// ZZ_TIPO   -> "0" A Confirmar ou  "1" Confirmada
	// ZZ_STATUS -> 0=Em Aberto;1=Empenhada;9=Cancelada
	DbSelectArea("SZZ")              
	If _lTodos
		DbSetOrder(3) // ZZ_FILIAL+ZZ_TIPO
		Set Filter to ZZ_STATUS == "0"

		SZZ->(DbSeek(xFilial("SZZ")+"0",.F.))
		Do While SZZ->ZZ_FILIAL == xFilial("SZZ") .And. SZZ->ZZ_TIPO == "0" .And. SZZ->(!Eof())
			IncProc()
			//		If SZZ->ZZ_STATUS == "0" .And. SZZ->ZZ_TIPO == "0" .And. SZZ->ZZ_DTVALID < Date() // dDataBase
			If SZZ->ZZ_STATUS == "0" .And. SZZ->ZZ_TIPO == "0" .And. SZZ->ZZ_DTVALID <= dDataBase
				VolteSZZ("Canc.por Prazo (todos)")
			EndIf
			SZZ->(DbSkip())
		EndDo
		Set Filter to
	Else
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		ProcRegua(Len(aCols))
		SZZ->(DbSeek(xFilial("SZZ")+M->_ZZ_NUM,.F.))
		Do While SZZ->ZZ_FILIAL == xFilial("SZZ") .And. SZZ->ZZ_NUM == M->_ZZ_NUM .And. SZZ->(!Eof())
			IncProc()
			If SZZ->ZZ_STATUS # "9"
				VolteSZZ("Canc.por Prazo (só um)")
			EndIf
			SZZ->(DbSkip())
		EndDo

	EndIf
Return(.T.)                  

User Function RsvIncre()
	If Type("aCols") == "A"
		_nUltIt := Len(aCols)
		If _nUltIt == 1 // é a primeira linha
			_ZZ_ITEM := StrZero(1,Len(SZZ->ZZ_ITEM))
		Else
			_ZZ_ITEM := Soma1(GDFieldGet("ZZ_ITEM",_nUltIt-1))
		EndIf
	Else
		_ZZ_ITEM := StrZero(1,Len(SZZ->ZZ_ITEM))
	EndIf
Return(_ZZ_ITEM)

Static Function PodeEste(_cPdProd,_cPdLoclz)          
	// Aqui se for curva -> não pode
	_lVolta := !u_fCurvaA(_cPdProd,_cPdLoclz,.T.)
	If Left(_cPdLoclz,1) == "B" .Or. Left(_cPdLoclz,1) == "T" //.Or. "R00100" $ _cPdLoclz
		// Não apresentar retalhos -> Solicitação do Ivo e autorizado a mim por 
		// Rafael + Denise em 03/10/12 às 14:30h na sala do Rafael quando discutiamos sobre o inventário
		_lVolta := .F.
	EndIf
Return(_lVolta)

Static Function VolteSZZ(_cTxt)
	Begin Sequence
		If RecLock("SZZ",.F.) // Tenho exclusividade no registro?
			//Se For Bobina, Liberar o SZE
			u_GraveLog(_cTxt,.T.)
			If Left(SZZ->ZZ_LOCALIZ,1) == "B"
				DbSelectArea("SZE")
				DbSetOrder(4) // ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
				DbSeek(xFilial("SZE")+"W"+SZZ->ZZ_PRODUTO,.F.)
				Do While xFilial("SZE") == xFilial("SZE") .And. SZE->ZE_STATUS == "W" .And. ;
				SZE->ZE_PRODUTO == SZZ->ZZ_PRODUTO .And. SZE->(!Eof())
					If SZE->ZE_QUANT == Val(Substr(SZZ->ZZ_LOCALIZ,2,5)) .And. SZE->ZE_RESERVA == SZZ->ZZ_NUM
						RecLock("SZE",.F.)
						SZE->ZE_STATUS  := "T" // Volta para estoque                           
						SZE->ZE_RESERVA := "      "
						SZE->(MsUnLock())
						// Reposiciona o SZE pois mudou a chave principal
						DbSeek(xFilial("SZE")+"W"+SZZ->ZZ_PRODUTO,.F.)
					Else
						DbSkip()
					EndIf       
				EndDo
			EndIf
			// Localizar SDC
			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+
			// DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI				
			If DbSeek(xFilial("SDC") + SZZ->ZZ_PRODUTO + SZZ->ZZ_LOCAL + "SZZ" + SZZ->ZZ_NUM + SZZ->ZZ_ITEM,.F.)
				If RecLock("SDC",.F.)
					DbSelectArea("SBF")
					DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If DbSeek(xFilial("SBF") + "01" + SZZ->ZZ_LOCALIZ + SZZ->ZZ_PRODUTO,.F.)
						If RecLock("SBF",.F.)
							DbSelectArea("SB2")
							DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
							If DbSeek(xFilial("SB2")+SZZ->ZZ_PRODUTO+"01",.F.)
								If RecLock("SB2",.F.)
									SB2->B2_RESERVA -= SZZ->ZZ_QUANT
									SBF->BF_EMPENHO -= SZZ->ZZ_QUANT
									SDC->(DbDelete())
									SZZ->ZZ_STATUS := "9" // Cancelado
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			SZZ->ZZ_STATUS := "9" // Cancelado
		EndIf
		DbUnLockAll()
	End Sequence
Return(.T.)

User Function ValCabec()

	If Empty(M->_ZZ_CLIENTE) .Or. Empty(M->_ZZ_LOJA)
		Alert("Obrigatório Definir Cliente")
		Return(.F.)
	EndIf

	_nQtdEmp := 0
	For _nx := 1 to Len(aCols)
		_nQtdEmp += GDFieldGet("BF_EMPENHO",_nx)
	Next
	If _nQtdEmp == 0
		Alert("Nenhuma Reserva Foi Definida")
		Return(.F.)
	EndIf

Return(.T.)

User Function GrvObs()
	If !Empty(GDFieldGet("BF_PRIOR",n)) .And. GDFieldGet("BF_EMPENHO",n) > 0
		DbSelectArea("SZZ")
		DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		If DbSeek(xFilial("SZZ")+_ZZ_NUM+GDFieldGet("BF_PRIOR",n),.F.)
			RecLock("SZZ",.F.)
			SZZ->ZZ_OBS   := M->BF_LOCAL
			MsUnLock()
		EndIf
	EndIf
Return(.T.)

Static Function VejaNum()
	_OldNum := M->_ZZ_NUM
	ConfirmSx8()
	DbSelectArea("SZZ")
	DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
	Do While DbSeek(xFilial("SZZ")+M->_ZZ_NUM,.F.)
		M->_ZZ_NUM := CriaVar("ZZ_NUM")// nro da reserva
		ConfirmSx8()
	EndDo
	If M->_ZZ_NUM # _OldNum
		o_ZZ_NUM:Refresh()
		Alert("Atenção: Nro, da Reserva Alterado Para " + M->_ZZ_NUM)
	EndIf
Return(.T.)

Static Function DefRepr()
	Local aParamBox := {}
	Private aRet    := {}
	Public _gCodRep := "      "

	DbSelectArea("SA3")
	DbSetOrder(1) // A3_FILIAL + A3_CODIGO
	Do While .T.
		aParamBox := {}
		aAdd(aParamBox,{1,"Cód.Repres.","      ","","","SA3","",TamSx3("A3_COD")[1],.F.})
		If !ParamBox(aParamBox, "Parametros", @aRet)
			Exit
		EndIf
		If !SA3->(DbSeek(xFilial("SA3")+aRet[1],.F.))
			Alert("Representante não Cadastrado")
		Else
			_gCodRep := SA3->A3_COD
			Exit
		EndIf
	EndDo
Return(!Empty(_gCodRep))

Static Function VejaExcl()       
	_Volta := 0
	_cNomArq := "\REPRES\"+AllTrim(_gCodRep) + ".DTC"
	If !File(_cNomArq)
		If !File("\REPRES\REPRES.DTC")
			_Volta := 4
		Else
			DbUseArea(.T.,"DBFCDXADS","\REPRES\REPRES.DTC","MODELO",.F.,.F.)
			DbSelectArea('MODELO')
			Copy  To &_cNomArq VIA "DBFCDXADS"
		EndIf
	EndIf
	If _Volta == 0
		// Tenta Abrir o arquivo exclusivo
		DbUseArea(.T.,"DBFCDXADS",_cNomArq,"VENDAS",.F.,.F.) // Abre o arquivo de forma exclusiva
		If NetErr() // Deu erro na abertura
			_Volta := 3
		EndIf
	EndIf
Return(_Volta)

User Function GraveLog(_cOcorr,lSZZ) 
	/*
	Rotina desativada - 22/03/2016 - Juliana e Roberto
	Utilizada para geração de log dos acessos dos representantes nesta rotina
	Solicitada por Rafael em mil oitocentos e bolinha
	*/
	/*
	RecLock("ZZ0",.T.)
	ZZ0->ZZ0_FILIAL := xFilial("ZZ0")
	ZZ0->ZZ0_VEND   := _gCodRep
	ZZ0->ZZ0_NOMEVE := Posicione("SA3",1,xFilial("SA3")+_gCodRep,"A3_NOME") // nome do representante
	ZZ0->ZZ0_DATA   := dDataBase
	ZZ0->ZZ0_HORA   := Left(Time(),Len(ZZ0->ZZ0_HORA))
	ZZ0->ZZ0_OCORR  := _cOcorr
	If lSZZ
	ZZ0->ZZ0_NUM    := SZZ->ZZ_NUM
	ZZ0->ZZ0_ITEM   := SZZ->ZZ_ITEM
	ZZ0->ZZ0_CLIENT := SZZ->ZZ_CLIENTE
	ZZ0->ZZ0_LOJA   := SZZ->ZZ_LOJA
	ZZ0->ZZ0_PRODUT := SZZ->ZZ_PRODUTO
	ZZ0->ZZ0_DESCR  := SZZ->ZZ_DESCR
	ZZ0->ZZ0_LOCALI := SZZ->ZZ_LOCALIZ
	ZZ0->ZZ0_QUANT  := SZZ->ZZ_QUANT
	ZZ0->ZZ0_DTVALI := SZZ->ZZ_DTVALID
	ZZ0->ZZ0_EMISSA := SZZ->ZZ_EMISSAO
	ZZ0->ZZ0_TIPO   := SZZ->ZZ_TIPO
	ZZ0->ZZ0_STATUS := SZZ->ZZ_STATUS
	EndIf
	MsUnLock()*/
Return(.T.)        

Static Function SomePvAb()
	_nQtdPv := 0.00
	DbSelectArea("SC6")
	DbSetOrder(1)  //SC6->C6_FILIAL+sc6->C6_NUM+sc6->C6_ITEM+C6_PRODUTO

	_aVistos := {}
	DbSelectArea("SC9")
	DbSetOrder(7) // C9_FILIAL+C9_PRODUTO+C9_LOCAL+C9_NUMSEQ
	Set Filter to C9_BLCRED == "  " .And. C9_BLEST == "02"
	DbSeek(xFilial("SC9")+SBF->BF_PRODUTO+SBF->BF_LOCAL,.F.)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. ;
	SC9->C9_PRODUTO+SC9->C9_LOCAL == SBF->BF_PRODUTO+SBF->BF_LOCAL .And. SC9->(!Eof())

		SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
		_cAconSC6 := Left(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5) + Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
		If _cAconSC6 == SBF->BF_LOCALIZ .And. Empty(SC6->C6_RES_SZZ)
			// Mesmo estando com SC6->C6_RES_SZZ vazio, pode haver uma
			// reserva para esse item com SDC->DC_ORIGEM == "SDC".
			//
			_nSoma := 0
			If Ascan(_aVistos, SC9->C9_PEDIDO+SC9->C9_ITEM) == 0
				AADD(_aVistos, SC9->C9_PEDIDO+SC9->C9_ITEM)
				DbSelectArea("SDC")
				DbSetOrder(4) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
				DbSeek(xFilial("SDC")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
				Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof()) .And. ;
				SDC->DC_PEDIDO+SDC->DC_ITEM == SC9->C9_PEDIDO+SC9->C9_ITEM
					If SDC->DC_ORIGEM == "SDC" .And. _cAconSC6 == SDC->DC_LOCALIZ
						_nSoma += SDC->DC_QUANT
					EndIf
					SDC->(DbSkip())
				EndDo
			EndIf
			If SC9->C9_QTDLIB > _nSoma
				_nQtdPv += (SC9->C9_QTDLIB - _nSoma)
			EndIf
		EndIf
		SC9->(DbSkip())
	EndDo
	DbSelectArea("SC9")
	Set Filter to  
Return(_nQtdPv)

User Function VolteSZz()
	DbSelectArea("SBF")
	DbSelectArea("SB2")
	DbSelectArea("SDC")
	DbSetOrder(1) 
	Do While DbSeek("ZZ",.F.)
		// Verificar se tem Saldo no SBF
		SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		SBF->(DbSeek(xFilial("SBF")+"01"+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.))
		If !SBF->(Eof()) .And. (SBF->BF_QUANT - SBF->BF_EMPENHO) >= SDC->DC_QUANT .And. SBF->BF_EMPENHO >= 0
			RecLock("SBF",.F.)
			SBF->BF_EMPENHO += SDC->DC_QUANT
			MsUnLock()

			// Grava o SB2 - B2_RESERVA
			SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
			If SB2->(DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+"01",.F.))
				RecLock("SB2",.F.)
				SB2->B2_RESERVA += SDC->DC_QUANT
				MsUnLock()
			EndIf
			RecLock("SDC",.F.)
			SDC->DC_FILIAL  := xFilial("SDC")
			MsUnLock()
		Else
			RecLock("SDC",.F.)
			SDC->DC_FILIAL  := "ZA"
			MsUnLock()
		EndIf
		DbSelectArea("SDC")
	EndDo
Return(.T.)
