#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN10                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 19/09/2007   //
//                                                                          //
//   Objetivo ...: Consulta a Saldos em Estoque                             //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDGEN10()
	***********************
	*
	Private oFnt1      
	DEFINE FONT oFnt1 NAME "Lucida Console" BOLD

	cCadastro := "Posição de Estoques"
	aCores    := {{"!Left(BF_LOCALIZ,1)$'BT'","ENABLE"    },;
	{"Left(BF_LOCALIZ,1)=='B'" ,"BR_AMARELO"},; 
	{"Left(BF_LOCALIZ,1)=='T'" ,"DISABLE"   }}

	aCampos := {}

	aAdd(aCampos, {"Produto"   ,"BF_PRODUTO"}) 
	aAdd(aCampos, {"Descrição" ,"BF_DESC"   })  
	aAdd(aCampos, {"Almox."    ,"BF_LOCAL"  })
	aAdd(aCampos, {"Acondic."  ,"BF_LOCALIZ"})
	aAdd(aCampos, {"Quantidade","BF_QUANT"  })
	aAdd(aCampos, {"Empenho"   ,"BF_EMPENHO"})

	aRotina := {{ "Pesquisar"   , "AxPesqui"    , 0 , 1},;
	{ "Visualizar"  , "AxVisual"    , 0 , 2},;
	{ "Alternativos", "U_CDGEN10D()", 0 , 3},;
	{ "Legenda"     , "U_CDGEN10L()", 0 , 2}}

	DbSelectArea("SBF")
	DbSetOrder(2)        
	Set Filter to BF_LOCAL $ "00/01" 
	DbSeek(xFilial("SBF"),.F.)
	mBrowse(001,040,200,390,"SBF",aCampos,,,,,aCores)

	DbSelectArea("SBF")
	Set Filter to 
	Return(.T.)
	*
	***********************
User Function CDGEN10L()
	***********************
	*
	BrwLegenda(cCadastro,"Legenda",{{"ENABLE"     ,"Rolo, Carretel ou Carretel de Madeira"},;
	{"BR_AMARELO" ,"Bobina"                               },;
	{"DISABLE"    ,"Retalho"                              }})
	Return(.T.)
	*
	***********************
User Function CDGEN10D()
	***********************
	*
	Private aMyHead1 := {}
	Private aMyCols1 := {}
	Private aMyHead2 := {}
	Private aMyCols2 := {}

	//Solicita Parâmetros
	// Produto
	// Bitola de:
	// Bitola Até
	// Cor De
	// Cor Até
	cPerg := "CDGEN10"
	ValidPerg()
	Do While .T.
		If !Pergunte(cPerg, .T.)
			Return(.T.)
		EndIf
		If !Empty(MV_PAR01) .And. MV_PAR02 <= MV_PAR03 .And. MV_PAR04 <= MV_PAR05

			DbSelectArea("SZ2")
			Set Filter to Z2_XPORTAL == "S"
			DbSeek(xFilial("SZ2")+MV_PAR02,.T.)
			MV_PAR02 := SZ2->Z2_COD

			DbSeek(xFilial("SZ2")+MV_PAR03,.T.)
			If SZ2->Z2_COD # MV_PAR03 .Or. SZ2->(Eof())
				SZ2->(DbSkip(-1))    
				MV_PAR03 := SZ2->Z2_COD
			EndIf
			Set Filter to

			DbSelectArea("SZ3")
			Set Filter to Z3_XPORTAL == "S"
			DbSeek(xFilial("SZ3")+MV_PAR04,.T.)
			MV_PAR04 := SZ3->Z3_COD

			DbSeek(xFilial("SZ3")+MV_PAR05,.T.)
			If SZ3->Z3_COD # MV_PAR05 .Or. SZ3->(Eof())
				SZ3->(DbSkip(-1))    
				MV_PAR05 := SZ3->Z3_COD
			EndIf
			Set Filter to

			Exit
		EndIf
		Alert("Preencha os Parâmetros Corretamente")
	EndDo

	// Cria variáveis para uso na GETDADOS e GETDADOSB

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aMyHead1 da GetDados                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	nUsado:=0
	aMyHead1:={}
	Aadd(aMyHead1,{"Produto"        ,"PRODU"  ,"XXXXXXXXXXXXXXX",TAMSX3("B1_COD")[1],0,".F."            ,"","C","","V"} )
	Aadd(aMyHead1,{"Descrição"      ,"DESCRI" ,"",30,0,".F.","","C","","V"} )
	Aadd(aMyHead1,{"Filial"         ,"FILIAL" ,"XXXXXXXXXXXXXXX",15,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead1,{"Local"          ,"ARMAZ"  ,"XX"             ,02,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead1,{"Acondicion."    ,"LOCALIZ","XXXXXX"         ,06,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead1,{"Qt.Lance"       ,"QTLANCE","@E 999,999"     ,06,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead1,{"Qt.Metros"      ,"QTMTR"  ,"@E 9,999,999"   ,07,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead1,{"Qt.Empenhada./m","EMPEN"  ,"@E 9,999,999"   ,07,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead1,{"Nro.Bobina"     ,"NUMBOB" ,""               ,TamSX3("ZE_NUMBOB")[1],0,".F."            ,"","C","","V"} )
	nUsado:=Len(aMyHead1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aMyHead2 da GetDadosB                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsadoB:=0
	aMyHead2:={}
	Aadd(aMyHead2,{"Produto"        ,"PRODU"  ,"XXXXXXXXXXXXXXX",TAMSX3("B1_COD")[1],0,".F."            ,"","C","","V"} )
	Aadd(aMyHead2,{"Descrição"      ,"DESCRI" ,"",30,0,".F.","","C","","V"} )
	Aadd(aMyHead2,{"Filial"         ,"FILIAL" ,"XXXXXXXXXXXXXXX",15,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead2,{"Local"          ,"ARMAZ"  ,"XX"             ,02,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead2,{"Acondicion."    ,"LOCALIZ","XXXXXX"         ,06,0,".F."            ,"","C","","V"} )
	Aadd(aMyHead2,{"Qt.Lance"       ,"QTLANCE","@E 999,999"     ,06,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead2,{"Qt.Metros"      ,"QTMTR"  ,"@E 9,999,999"   ,07,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead2,{"Qt.Empenhada./m","EMPEN"  ,"@E 9,999,999"   ,07,0,".F."            ,"","N","","V"} )
	Aadd(aMyHead2,{"Nro.Bobina"     ,"NUMBOB" ,""               ,TamSX3("ZE_NUMBOB")[1],0,".F."            ,"","C","","V"} )
	Aadd(aMyHead2,{"Prioridade"     ,"PRIOR"  ,"XXXXXXXXXXXXXXXXXXXX",20,0,".F."            ,"","C","","V"} )
	nUsadoB:=Len(aMyHead2)

	Processa( {|| CDGEN10P() },"Processando Produtos Principais...")
	Processa( {|| CDGEN10a() },"Processando Produtos Alternativos...")

	If Len(aMyCols1) == 0
		AADD(aMyCols1,Array(nUsado+1))
		aMyCols1[01,01] := Space(Len(SBF->BF_PRODUTO))       // Produto
		aMyCols1[01,02] := "Não há Saldo de Alternativos  "    // Descrição
		aMyCols1[01,03] := "            "        // Nome da filial
		aMyCols1[01,04] := "  "                  // Local
		aMyCols1[01,05] := "      "              // Acondicionamento
		aMyCols1[01,06] := 0                     // Tamanho do Lance
		aMyCols1[01,07] := 0                     // Quantidade em metros
		aMyCols1[01,08] := 0                     // Quant. de Lances
		aMyCols1[01,09] := Space(TamSX3("ZE_NUMBOB")[1]) // Nro.Bobina
		aMyCols1[01,10] := .F.
	EndIf
	If Len(aMyCols2) == 0
		AADD(aMyCols2,Array(nUsadoB+1))
		aMyCols2[01,01] := Space(Len(SBF->BF_PRODUTO))       // Produto
		aMyCols2[01,02] := "Não há Saldo de Alternativos  "    // Descrição
		aMyCols2[01,03] := "            "        // Nome da filial
		aMyCols2[01,04] := "  "                  // Local
		aMyCols2[01,05] := "      "              // Acondicionamento
		aMyCols2[01,06] := 0                     // Tamanho do Lance
		aMyCols2[01,07] := 0                     // Quantidade em metros
		aMyCols2[01,08] := 0                     // Quant. de Lances
		aMyCols2[01,09] := Space(TamSX3("ZE_NUMBOB")[1]) // Nro.Bobina
		aMyCols2[01,10] := Space(20)             // Prioridade
		aMyCols2[01,11] := .F.
	EndIf

	MostreDados()

	Return(.T.)
	*               
	*****************************
Static Function MostreDados()
	*****************************
	*
	*
	nOpcE:=3
	nOpcG:=3                         
	inclui := .T.
	altera := .F.
	exclui := .F.

	aAltEnch :={}
	aAltEnchB :={}

	_nRet:= 0
	aButtons := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := "Consulta Estoque de Saldos de Produtos e de Alternativos "
	cAliasEnchoice := ""
	cAliasGetD     := "SBF"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "AllwaysTrue()"
	cLinOkB        := "AllwaysTrue()"
	cTudOkB        := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}
	lRefresh := .T.

	_nRet:=u_JanEst10(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnch,,cLinOkB,cTudOkB,aAltEnchB)
	Return(.T.)
	*
*
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function JanEst10(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnch,nFreeze,cLinOkB,cTudOkB,aAltEnchB)
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	Private _nVarTam:=0

	nGetLin := aPosObj[3,1]

	Private oDlg,oGetDados,oGetDadosB
	Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,999,nLinhas)

	_cDescPrd := Posicione("SZ1",1,xFilial("SZ1")+MV_PAR01,"Z1_DESC")

	_cDescBt1 := Posicione("SZ2",1,xFilial("SZ2")+MV_PAR02,"Z2_DESC")
	_cDescBt2 := Posicione("SZ2",1,xFilial("SZ2")+MV_PAR03,"Z2_DESC")

	_cDescCr1 := Posicione("SZ3",1,xFilial("SZ3")+MV_PAR04,"Z3_DESC")
	_cDescCr2 := Posicione("SZ3",1,xFilial("SZ3")+MV_PAR05,"Z3_DESC")

	Do While .T.	

		DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

		@ 005,040 Say "Produto:"                                   Size  25,06 PIXEL
		@ 005,075 Get MV_PAR01 Picture "XXX" When .F. Size  30,04 PIXEL
		// 005,125 Say "Descrição:"                                 Size  35,06 PIXEL
		@ 005,110 Get _cDescPrd                           When .F. Size  85,04 PIXEL

		@ 018,040 Say "Da Bitola"                                  Size  35,06 PIXEL
		@ 018,075 Get MV_PAR02 Picture "XX"  When .F. Size  30,04 PIXEL
		// 018,125 Say "Descrição:"                                 Size  35,06 PIXEL
		@ 018,110 Get _cDescBt1                           When .F. Size  85,04 PIXEL
		_nPss := 200
		@ 018,_nPss Say "Até a Bitola"                               Size  35,06 PIXEL
		@ 018,_nPss+035 Get MV_PAR03 Picture "XX"  When .F. Size  30,04 PIXEL
		// 018,_nPss+085 Say "Descrição:"                                 Size  35,06 PIXEL
		@ 018,_nPss+70 Get _cDescBt2                           When .F. Size  85,04 PIXEL


		@ 031,040 Say "Da Cor"                               Size  35,06 PIXEL
		@ 031,075 Get MV_PAR04 Picture "XX"  When .F. Size  30,04 PIXEL
		// 031,125 Say "Descrição:"                                 Size  35,06 PIXEL
		@ 031,110 Get _cDescCr1                           When .F. Size  85,04 PIXEL

		@ 031,_nPss Say "Até a Cor"                               Size  35,06 PIXEL
		@ 031,_nPss+035 Get MV_PAR05 Picture "XX"  When .F. Size  30,04 PIXEL
		// 031,_nPss+085 Say "Descrição:"                                 Size  35,06 PIXEL
		@ 031,_nPss+70  Get _cDescCr2                           When .F. Size  85,04 PIXEL

		//
		// Monta duas GetDados na Horizontal 
		// oGetDados em cima
		// oGetDadosB em baixo
		//
		_nVarTam:=0
		If Len(aMyCols1) < 6 .And. Len(aMyCols2) > 11 // Tem poucos no aMyCols1 e mais de 11 no aMyCols2
			_nVarTam:=52
		EndIf

		@ 046,005 Say "Saldos do Produto Principal"                 Size  200,10 PIXEL FONT oFnt1 COLOR CLR_BLACK
		oGetDados  := MsNewGetDados():New(52,aPosObj[2,2],(164-_nVarTam),aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",,nFreeze,Len(aMyCols1),cFieldOk,,,oDlg,aMyHead1,aMyCols1)

		@ (169-_nVarTam),005 Say "Saldos dos Produtos Alternativos" Size  150,10 PIXEL FONT oFnt1 COLOR CLR_BLACK
		oGetDadosB := MsNewGetDados():New((175-_nVarTam),aPosObj[2,2],272,aPosObj[2,4],nOpcG,cLinOkB,cTudOkB,"",,nFreeze,Len(aMyCols2),cFieldOk,,,oDlg,aMyHead2,aMyCols2)

		_nFechou := 0
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons)

		If _nFechou < 3
			Exit
		EndIf
	EndDo
	If _nFechou # 0
		_nRet := _nFechou
	Else
		_nRet := nOpca
	EndIf
	Return(_nRet)                                       
	*
	**************************
Static Function CDGEN10P()
	**************************
	*                       
	_cMyEmp := cNumEmp
	_cMyFil := cFilAnt
	_cEmpTRB := Left(cNumEmp,Len(SM0->M0_CODIGO))
	DbSelectArea("SM0")
	DbSetOrder(1)

	// Verifico quantas filiais tem a empresa
	_nQtFil := 0
	SM0->(DbSeek(_cEmpTRB,.F.))
	Do While SM0->M0_CODIGO == _cEmpTRB .And. SM0->(!Eof())
		_nQtFil++
		SM0->(DbSkip())
	EndDo

	ProcRegua(SB1->(LastRec())*_nQtFil)

	SM0->(DbSeek(_cEmpTRB,.F.))
	Do While SM0->M0_CODIGO == _cEmpTRB .And. SM0->(!Eof())
		cNumEmp := FWCodEmp()+FWCodFil()
		cFilAnt := FWCodEmp()

		DbSelectArea("SBF")
		DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI

		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL+B1_COD

		DbSeek(xFilial("SB1")+MV_PAR01,.T.)
		Do While SB1->B1_FILIAL == xFilial("SB1") .And. Left(SB1->B1_COD,3) == MV_PAR01 .And. SB1->(!Eof())
			IncProc()
			If Substr(SB1->B1_COD,4,2) < MV_PAR02 .Or. Substr(SB1->B1_COD,4,2) > MV_PAR03 .Or.;
			Substr(SB1->B1_COD,6,2) < MV_PAR04 .Or. Substr(SB1->B1_COD,6,2) > MV_PAR05 .Or.;
			Right(AllTrim(SB1->B1_COD),1) == "I" .Or. SB1->B1_LOCALIZ # "S"
				// Não está na abrangência de bitolas ou é código de importado
				SB1->(DbSkip())
				Loop
			EndIf

			DbSelectArea("SBF")
			DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
			DbSeek(xFilial("SBF")+SB1->B1_COD,.F.)
			Do While SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_PRODUTO == SB1->B1_COD .And. SBF->(!Eof())
				If SBF->BF_LOCAL == "01" .And. Left(SBF->BF_LOCALIZ,1) # "B"
					AADD(aMyCols1,Array(nUsado+1))
					_nPsCols := Len(aMyCols1)

					aMyCols1[_nPsCols,01] := SBF->BF_PRODUTO       // Produto
					aMyCols1[_nPsCols,02] := SB1->B1_DESC          // Descrição
					aMyCols1[_nPsCols,03] := SM0->M0_FILIAL        // Nome da filial
					aMyCols1[_nPsCols,04] := SBF->BF_LOCAL         // Local
					aMyCols1[_nPsCols,05] := AllTrim(SBF->BF_LOCALIZ)          // Acondicionamento
					aMyCols1[_nPsCols,06] := Int(SBF->BF_QUANT / Val(Substr(SBF->BF_LOCALIZ,2,5))) // Quant. de Lances
					aMyCols1[_nPsCols,07] := Int(SBF->BF_QUANT)    // Quantidade em metros
					aMyCols1[_nPsCols,08] := Int(SBF->BF_EMPENHO)  // Quantidade empenhada
					aMyCols1[_nPsCols,09] := Space(TamSX3("ZE_NUMBOB")[1]) // Nro.Bobina
					aMyCols1[_nPsCols,10] := .F.
				EndIf
				SBF->(DbSkip())
			EndDo


			DbSelectArea("SZE")
			DbSetOrder(4) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
			DbSeek(xFilial("SZE") + "T" + SB1->B1_COD,.F.)
			Do While SZE->ZE_FILIAL  == xFilial("SZE") .And. SZE->ZE_STATUS == "T" .And.;
			SZE->ZE_PRODUTO == SB1->B1_COD    .And. SZE->(!Eof())

				AADD(aMyCols1,Array(nUsado+1))
				_nPsCols := Len(aMyCols1)

				aMyCols1[_nPsCols,01] := SZE->ZE_PRODUTO       // Produto
				aMyCols1[_nPsCols,02] := SB1->B1_DESC          // Descrição
				aMyCols1[_nPsCols,03] := SM0->M0_FILIAL        // Nome da filial
				aMyCols1[_nPsCols,04] := "01"                  // Local
				aMyCols1[_nPsCols,05] := "B"+StrZero(SZE->ZE_QUANT,5)    // Acondicionamento
				aMyCols1[_nPsCols,06] := 1                     // Quant. de Lances
				aMyCols1[_nPsCols,07] := SZE->ZE_QUANT         // Quantidade em metros
				aMyCols1[_nPsCols,08] := 0                     // Quantidade empenhada
				aMyCols1[_nPsCols,09] := SZE->ZE_NUMBOB        // Nro.Bobina
				aMyCols1[_nPsCols,10] := .F.

				SZE->(DbSkip())
			EndDo

			SB1->(DbSkip())
		EndDo
		DbSelectArea("SM0")
		SM0->(DbSkip())
	EndDo

	// Volta para a filial correta	
	cNumEmp := _cMyEmp
	cFilAnt := _cMyFil

	DbSelectArea("SM0")
	DbSetOrder(1)
	SM0->(DbSeek(cNumEmp,.F.))

	// Ordena o array por produto + acondicionamento + FILIAL
	aSort(aMyCols1,,,{|x,y| x[1]+x[5]+x[3]<y[1]+y[5]+y[3]})
	Return(.T.)		
	*
	**************************
Static Function CDGEN10a()
	**************************
	*        
	_aPrior  := {} 
	AAdd(_aPrior,{MV_PAR01,""})
	DbSelectArea("ZZA")
	DbSetOrder(1) // ZZA_FILIAL+ZZA_PROD+ZZA_PRDALT
	_nPrior := 1
	Do While _nPrior <= Len(_aPrior) // Não usar o for next - ele se perde // For _nPrior := 1 to Len(_aPrior)
		_cAltCh := _aPrior[_nPrior,1]
		_cAlter := Right(_aPrior[_nPrior,1],Len(ZZA->ZZA_PRDALT))
		_cPrior := _aPrior[_nPrior,2]
		DbSeek(xFilial("ZZA")+_cAlter,.F.)
		Do While ZZA->ZZA_FILIAL == xFilial("ZZA") .And. ZZA->ZZA_PROD == _cAlter .And. ZZA->(!Eof())
			_cPriNow := _cPrior + StrZero(ZZA->ZZA_PRIOR,2)
			AAdd(_aPrior,{_cAltCh+ZZA->ZZA_PRDALT,_cPriNow})
			ZZA->(DbSkip())
		EndDo
		_nPrior++
	EndDo //Next

	_aAlter  := {}
	_cAlter  := MV_PAR01 + "//"
	_nTamZZA := Len(ZZA->ZZA_PRDALT)

	Do While Len(_cAlter) > 0
		_cAltNow := Left(_cAlter,_nTamZZA)
		DbSeek(xFilial("ZZA")+_cAltNow,.F.)
		Do While ZZA->ZZA_FILIAL == xFilial("ZZA") .And. ZZA->ZZA_PROD == _cAltNow .And. ZZA->(!Eof())
			If Ascan(_aAlter,ZZA->ZZA_PRDALT) == 0
				AAdd(_aAlter,ZZA->ZZA_PRDALT)
				_cAlter += ZZA->ZZA_PRDALT + "//"
			EndIf
			ZZA->(DbSkip())
		EndDo
		If Len(_cAlter) == (_nTamZZA+2)
			_cAlter := ""
		Else
			_cAlter := Right(_cAlter,Len(_cAlter)-(_nTamZZA+2))
		EndIf
	EndDo

	_cMyEmp := cNumEmp
	_cMyFil := cFilAnt
	_cEmpTRB := Left(cNumEmp,Len(SM0->M0_CODIGO))
	DbSelectArea("SM0")
	DbSetOrder(1)

	// Verifico quantas filiais tem a empresa
	_nQtFil := 0
	SM0->(DbSeek(_cEmpTRB,.F.))
	Do While SM0->M0_CODIGO == _cEmpTRB .And. SM0->(!Eof())
		_nQtFil++
		SM0->(DbSkip())
	EndDo

	ProcRegua(Len(_aAlter)*_nQtFil)

	SM0->(DbSeek(_cEmpTRB,.F.))
	Do While SM0->M0_CODIGO == _cEmpTRB .And. SM0->(!Eof())
		cNumEmp := FWCodEmp()+FWCodFil()
		cFilAnt := FWCodFil()

		DbSelectArea("SBF")
		DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI

		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL+B1_COD

		For _nPosAlt := 1 to Len(_aAlter)
			// Achar a prioridade do produto
			_cPriPrd := Val(Replicate("9",20))
			For _nPrior := 2 to Len(_aPrior) // o primeiro não vale
				If Right(_aPrior[_nPrior,1],_nTamZZA) == _aAlter[_nPosAlt]
					_cPriPrd := Min(_cPriPrd,Val(_aPrior[_nPrior,2]))
				EndIf
			Next
			_cPriPrd := StrZero(_cPriPrd,20)

			DbSelectArea("SBF")
			DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
			DbSeek(xFilial("SBF")+_aAlter[_nPosAlt],.F.)
			Do While SBF->BF_FILIAL == xFilial("SBF") .And. Left(SBF->BF_PRODUTO,_nTamZZA) == _aAlter[_nPosAlt] .And. SBF->(!Eof())
				If SBF->BF_LOCAL == "01" .And. ;
				Substr(SBF->BF_PRODUTO,4,2) >= MV_PAR02 .And. ;
				Substr(SBF->BF_PRODUTO,4,2) <= MV_PAR03 .And. ;
				Substr(SBF->BF_PRODUTO,6,2) >= MV_PAR04 .And. ;
				Substr(SBF->BF_PRODUTO,6,2) <= MV_PAR05 .And. ;
				Left(SBF->BF_LOCALIZ,1) # "B" // Bobinas se´ão vistas pelo SZE

					SB1->(DbSeek(xFilial("SB1")+SBF->BF_PRODUTO,.F.))

					AADD(aMyCols2,Array(nUsadoB+1))
					_nPsCols := Len(aMyCols2)

					aMyCols2[_nPsCols,01] := SBF->BF_PRODUTO       // Produto
					aMyCols2[_nPsCols,02] := SB1->B1_DESC          // Descrição
					aMyCols2[_nPsCols,03] := SM0->M0_FILIAL        // Nome da filial
					aMyCols2[_nPsCols,04] := SBF->BF_LOCAL         // Local
					aMyCols2[_nPsCols,05] := AllTrim(SBF->BF_LOCALIZ)          // Acondicionamento
					aMyCols2[_nPsCols,06] := Int(SBF->BF_QUANT / Val(Substr(SBF->BF_LOCALIZ,2,5))) // Quant. de Lances
					aMyCols2[_nPsCols,07] := Int(SBF->BF_QUANT)    // Quantidade em metros
					aMyCols2[_nPsCols,08] := Int(SBF->BF_EMPENHO)  // Quantidade empenhada
					aMyCols2[_nPsCols,09] := Space(TamSX3("ZE_NUMBOB")[1]) // Nro.Bobina
					aMyCols2[_nPsCols,10] := _cPriPrd              // Prioridade
					aMyCols2[_nPsCols,11] := .F.
				EndIf
				SBF->(DbSkip())
			EndDo

			// Adicionar as bobinas em estoque
			DbSelectArea("SZE")
			DbSetOrder(4) //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
			DbSeek(xFilial("SZE") + "T" + _aAlter[_nPosAlt],.F.)
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_STATUS == "T" .And.;
			Left(SZE->ZE_PRODUTO,_nTamZZA) == _aAlter[_nPosAlt] .And. SZE->(!Eof())

				If Substr(SZE->ZE_PRODUTO,4,2) >= MV_PAR02 .And. ;
				Substr(SZE->ZE_PRODUTO,4,2) <= MV_PAR03 .And. ;
				Substr(SZE->ZE_PRODUTO,6,2) >= MV_PAR04 .And. ;
				Substr(SZE->ZE_PRODUTO,6,2) <= MV_PAR05

					SB1->(DbSeek(xFilial("SB1")+SZE->ZE_PRODUTO,.F.))

					AADD(aMyCols2,Array(nUsadoB+1))
					_nPsCols := Len(aMyCols2)

					aMyCols2[_nPsCols,01] := SZE->ZE_PRODUTO       // Produto
					aMyCols2[_nPsCols,02] := SB1->B1_DESC          // Descrição
					aMyCols2[_nPsCols,03] := SM0->M0_FILIAL        // Nome da filial
					aMyCols2[_nPsCols,04] := "01"                  // Local
					aMyCols2[_nPsCols,05] := "B"+StrZero(SZE->ZE_QUANT,5)    // Acondicionamento
					aMyCols2[_nPsCols,06] := 1                     // Quant. de Lances
					aMyCols2[_nPsCols,07] := SZE->ZE_QUANT         // Quantidade em metros
					aMyCols2[_nPsCols,08] := 0                     // Quantidade empenhada
					aMyCols2[_nPsCols,09] := SZE->ZE_NUMBOB        // Nro.Bobina
					aMyCols2[_nPsCols,10] := _cPriPrd              // Prioridade
					aMyCols2[_nPsCols,11] := .F.
				EndIf
				SZE->(DbSkip())
			EndDo
		Next
		DbSelectArea("SM0")
		SM0->(DbSkip())
	EndDo

	// Volta para a filial correta	
	cNumEmp := _cMyEmp
	cFilAnt := _cMyFil

	DbSelectArea("SM0")
	DbSetOrder(1)
	SM0->(DbSeek(cNumEmp,.F.))

	// Ordena o array por PRIORIDADE + produto + acondicionamento + FILIAL
	aSort(aMyCols2,,,{|x,y| x[10]+x[01]+x[05]+x[03]<y[10]+y[01]+y[05]+y[03]})

	Return(.T.)
	*
	***************************
Static Function ValidPerg()
	***************************
	*
	*
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Produto                   ?","mv_ch1","C",TamSX3("Z1_COD")[1] ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SZ1_PT"})
	aAdd(aRegs,{cPerg,"02","Da Bitola                    ?","mv_ch2","C",TamSX3("Z2_COD")[1] ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SZ2_PT"})
	aAdd(aRegs,{cPerg,"03","Até a Bitola                 ?","mv_ch3","C",TamSX3("Z2_COD")[1] ,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SZ2_PT"})
	aAdd(aRegs,{cPerg,"04","Da Cor                       ?","mv_ch4","C",TamSX3("Z3_COD")[1] ,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SZ3_PT"})
	aAdd(aRegs,{cPerg,"05","Até a Cor                    ?","mv_ch5","C",TamSX3("Z3_COD")[1] ,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SZ3_PT"})

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
	*
	*********************************
Static Function FecheOdlg(nForma)
	*********************************
	*
	_nFechou := nForma
	Close(oDlg)
Return(.T.)