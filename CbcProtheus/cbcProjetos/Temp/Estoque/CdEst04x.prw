#INCLUDE "RWMAKE.CH"

/*
*********************************************************************
ROTINA INUTILIZADA
12/06/2017
*********************************************************************
*/

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: 	cdest04                           Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 27/04/2006   //
//                                                                          //
//   Objetivo ...: Montagem de Browse para digitação dos Boletins de Movi-  //
//                 mentação de Materiais - BMM, pelo qual será realizada a  //
//                 produção no sistema.                                     //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//
User Function CdEst04()

	Private aHeader, aCols
	Private lMsErroAuto := .f.

	cCadastro := "Digitação de Boletins de Movimentação de Materiais (BMM)"

	aCores    := {{"ZB_STATUS == '4'","BR_AMARELO" },; // Amarelo - Sucata
	{"ZB_STATUS == '1'","BR_CINZA" },;   // Cinza  - Envio para Retrabalho
	{"ZB_STATUS == '2'","BR_BRANCO"},;   // Branco - Devolução do Retrabalho
	{"ZB_STATUS == '3'","BR_PINK"},;     // Pink - Transferência
	{"ZB_STATUS == 'S' .And. ZB_QUJP == 0.00","ENABLE"},;   // Verde    - Aberto  - Ainda nÃo dado a produÇÃo
	{"ZB_STATUS == 'C'" ,"BR_PRETO"},;   // Preto - Cancelado
	{"ZB_STATUS == 'N' .Or.  ZB_QUJP #  0.00","DISABLE"},;  // Vermelho - Encerrado - Já efetuado baixa da OP
	{"ZB_STATUS == 'B'","BR_AZUL"},;     // BMM vindo da Pesagem
	{"ZB_STATUS == 'P'","BR_LARANJA"}}   // BMM da Pesagem já processado


	aRotina := {{ "Pesquisa"        ,"AxPesqui" , 0 , 1	},;
	{ "Visual"          ,"U_ACMNUVI", 0 , 2	},;
	{ "Inclui Produção" ,"U_ACMNUIN", 0 , 3	},;
	{ "Altera"          ,"U_ACMNUAL", 0 , 4 },;
	{ "Exclui"          ,"U_ACMNUEX", 0 , 2 },;
	{ "Efetiva BMM"     ,"U_CSEFBTM", 0 , 2 },;
	{ "Excl.BMM Efet."  ,"U_CSESBTM", 0 , 2 },;
	{ "Envio p/ Retrab.","U_ACENVIA", 0 , 3	},;
	{ "Devol.do Retrab.","U_ACVOLTA", 0 , 3	},;
	{ "Transferência"   ,"U_ACTRANS", 0 , 3	},;
	{ "Legenda"         ,"U_CSLEGEN", 0 , 2 }}


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes de acesso para a Modelo 3                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SZB")
	SZB->(DbSetOrder(1))
	DbSeek(xFilial("SZB"),.F.)
	If ! cUsername+"/" $ GetMv("MV_ZZLIBBM")
		Alert("Usuario sem acesso, Favor contatar o Depto de TI")
		Return
	EndIf
	MBrowse(001,040,200,390,"SZB",,,,,,aCores)
	Set Filter To

	Return(.t.)

	***********************
User Function ACENVIA()
	***********************
	*
	_cStatus := "1"
	cOpcao:="ENVIA"

	U_MONTATELA()

	Return(.T.)


	***********************
User Function ACVOLTA()
	***********************
	*
	_cStatus := "2"
	cOpcao:="VOLTA"

	U_MONTATELA()

	Return(.T.)



	***********************
User Function ACTRANS()
	***********************
	*
	_cStatus := "3"
	cOpcao:="TRANS"

	U_MONTATELA()

	Return(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	// FUNCAO MENU INCLUSAO DE CONTRATO DE VENDA                     //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	***********************
User Function ACMNUIN() //OK
	***********************
	*
	_cStatus := "S"
	cOpcao:="INCLUIR"

	U_MONTATELA()

	Return(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	// FUNCAO MENU VISUALIZACAO DO CONTRATO DE VENDA			     //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	***********************
User Function ACMNUVI()//OK
	***********************
	*
	_cStatus := "S"
	cOpcao:="VISUALIZAR"
	_Reg := SZB->(Recno())
	U_MONTATELA()
	SZB->(DbGoTo(_Reg))
	Return(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	// FUNCAO MENU ALTERACAO DO CONTRATO DE VENDA			         //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	***********************
User Function ACMNUAL() //OK
	***********************
	*
	_cStatus := "S"
	cOpcao:="ALTERAR"
	_Reg := SZB->(Recno())
	If PodeAlt()
		SZB->(DbGoTo(_Reg))
		U_MONTATELA()
	EndIf

	Return(.T.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	// FUNCAO MENU EXCLUSÃO DO CONTRATO DE VENDA			         //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	***********************
User Function ACMNUEx() //OK
	***********************
	*
	_cStatus := "S"
	cOpcao:="EXCLUIR"
	_Reg := SZB->(Recno())
	If PodeAlt()
		SZB->(DbGoTo(_Reg))
		U_MONTATELA()
	EndIf
	Return(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	// FUNCAO QUE MONTA A TELA CONTRATO DE VENDA				     //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ//
	*************************
User Function MONTATELA() //ok
	*************************
	*
	Private _nAcContr
	*
	If cOpcao$"INCLUIR//ENVIA//VOLTA/TRANS"
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
	ElseIf cOpcao=="VISUALIZAR"
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

	/*/
	dbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SZB")
	Do While !Eof().And.(x3_arquivo=="SZB")
	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. AllTrim(SX3->X3_CAMPO) $ "ZB_DATA//ZB_NUM"
	AAdd(aAltEnchoice,AllTrim(SX3->X3_CAMPO))
	EndIf
	dbSkip()
	EndDo
	/*/


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOpcao $ "INCLUIR//ENVIA//VOLTA/TRANS"
		_ZB_DATA := MsDate()
		_ZB_NUM  := Space(Len(SZB->ZB_NUM))
		If cOpcao == "TRANS"
			_cLocDes := "  "
		EndIf
	Else
		_ZB_DATA := SZB->ZB_DATA
		_ZB_NUM  := SZB->ZB_NUM
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	dbSelectArea("SX3")
	DbSetOrder(1)
	dbSeek("SZB")
	aHeader:={}
	_TamCpo := Len(SX3->X3_CAMPO)
	_cNotInc := ""
	_cNotInc += Left("ZB_DATA"+Space(_TamCpo),_TamCpo) + "//"
	_cNotInc += Left("ZB_NUM" +Space(_TamCpo),_TamCpo) + "//"
	If cOpcao $ "INCLUIR//VOLTA"
		_cNotInc += Left("ZB_LOCALIZ" +Space(_TamCpo),_TamCpo) + "//"
	EndIf
	If cOpcao # "INCLUIR"
		_cNotInc += Left("ZB_SEMANA" +Space(_TamCpo),_TamCpo) + "//"
		_cNotInc += Left("ZB_ITEM" +Space(_TamCpo),_TamCpo) + "//"
	EndIf



	//		If (cOpcao == "INCLUIR"      .And. !(AllTrim(SX3->X3_CAMPO) $ "ZB_LOCALIZ")) .Or.;
	//		   (cOpcao $  "ENVIA//TRANS" .And.  (AllTrim(SX3->X3_CAMPO) $ "ZB_LOCALIZ")) .Or.;
	//		   (cOpcao $  "ENVIA//VOLTA//TRANS" .And.  (AllTrim(SX3->X3_CAMPO) $ "ZB_PRODUTO,ZB_DESCPRO,ZB_UM,ZB_QUANT,ZB_LOCAL,ZB_STATUS"))


	Do While !Eof().And.(x3_arquivo=="SZB")
		If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. !(SX3->X3_CAMPO $ _cNotInc)
			nUsado:=nUsado+1
			_Tit := TRIM(x3_titulo)
			If AllTrim(SX3->X3_CAMPO) == "ZB_LOCALIZ"
				_Tit := "Localiz. Origem"
			ElseIf AllTrim(SX3->X3_CAMPO) == "ZB_LOCAL"
				If _cStatus $ "S2"
					_Tit := "Armazém Destino"
				Else
					_Tit := "Armazém Origem"
				EndIf
			EndIf
			Aadd(aHeader,{ 	_Tit, x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,"AllwaysTrue()",;
			x3_usado, x3_tipo, x3_arquivo, x3_context } )
			//						x3_tamanho, x3_decimal,If(Empty(X3_VLDUSER),"AllwaysTrue()",X3_VLDUSER),;
			//						x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		DbSkip()
	EndDo

	If cOpcao $ "INCLUIR//ENVIA//VOLTA//TRANS"
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		Next
	Else
		aCols:={}
		dbSelectArea("SZB")
		dbSetOrder(1)
		dbSeek(xFilial("SZB")+M->_ZB_NUM,.F.)
		Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_NUM == M->_ZB_NUM .And. SZB->(!eof())
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		EndDo
	Endif
	For _ni:=1 to nUsado
		_Var := "M->"+AllTrim(aHeader[_ni,2])
		&(_Var) := aCols[1,_ni]
	Next
	_lRet:= .F.
	aButtons := {}
	If Len(aCols)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo        := "Boletim de Transf. de Materiais"
		cAliasEnchoice := ""
		cAliasGetD     := "SZB"
		cLinOk         := "u_CSLinOk()"
		cTudOk         := If(cOpcao$"ENVIA//VOLTA//TRANS","u_CsTudOk()","AllwaysTrue()")
		cFieldOk       := "AllwaysTrue()"
		aCpoEnchoice:= {}
		Do While .T.
			_lRet:=u_Janela4(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
			If _lRet .And. Empty(_ZB_NUM)
				Loop
			EndIf
			Exit
		EndDo
	Endif
	If _lRet .And. cOpcao $ "INCLUIR//ALTERAR"
		Processa({|lEnd| ACGRAVDAD()}, 'Gravando Dados do B.M.M....')
	ElseIf _lRet .And. cOpcao == "EXCLUIR"
		Processa({|lEnd| ACEXCDAD()}, 'Excluindo Dados do B.M.M....')
	ElseIf _lRet .And. cOpcao $ "TRANS"
		Processa({|lEnd| ACTRANSF()}, 'Transferindo Saldos....')
	ElseIf _lRet .And. cOpcao $ "ENVIA//VOLTA"
		//	Processa({|lEnd| ACRetrab(If(cOpcao=="ENVIA","523","100"))}, 'Movimentando Estoque....') // Se for envio faço uma Requisição
		//  Em 21/06/11 Natanael veio na min hamesa pra ver o porque não estava sendo transferido o saldo do almox
		// 01 para o 90... Iamos deixar de controlar os movimento no retrabalho... porém precisamor rever essa posição.
		// estou revertendo até que decidamos o que fazer.
		Processa({|lEnd| ACTRANSF()}, 'Transferindo Saldos....')
	EndIf

	Return(_lRet)

	**************************
Static FuncTion ACEXCDAD()
	**************************
	*
	DbSelectArea("SZB")
	DbSetOrder(1)
	DbSeek(xFilial("SZB")+M->_ZB_NUM,.F.)
	Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_NUM == M->_ZB_NUM .And. SZB->(!Eof())
		If SZB->ZB_STATUS == "S"
			RecLock("SZB",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		DbSkip()
	EndDo
	Return(.T.)
	*
	*
	***************************
Static FuncTion ACTRANSF()
	***************************
	*
	*
	ProcRegua(Len(aCols))
	For ii:=1 to Len(aCols)
		IncProc()
		If !aCols[ii,Len(aCols[ii])]
			If DbSeek("@@",.F.)
				RecLock("SZB",.F.)
			Else
				RecLock("SZB",.T.)
			EndIf
			//GRAVACAO DOS ITENS
			For AC:=1 to Len(aHeader)
				FieldPut(FieldPos(ALLTRIM(aHeader[AC,2])),aCols[ii,AC])
			Next
			SZB->ZB_FILIAL  := xFILIAL("SZB")
			SZB->ZB_NUM     := M->_ZB_NUM
			SZB->ZB_ITBMM    := StrZero(ii,3)
			SZB->ZB_DATA    := M->_ZB_DATA
			MsUnLock()

			cNumSeq := ProxNum()
			// Fazer Movimento no SD3 de Saída RE4
			CrieSD3("RE4") //

			// Fazer Movimento no SD3 de Entrada DE4
			CrieSD3("DE4")
		EndIf
	Next

	Return(.T.)
	*
	*
	***************************
Static FuncTion ACGRAVDAD()
	***************************
	*
	*
	DbSelectArea("SZB")
	DbSetOrder(1)
	Do While DbSeek(xFilial("SZB")+M->_ZB_NUM,.F.)
		RecLock("SZB",.F.)
		SZB->ZB_FILIAL := "@@"
		MsUnLock()
		DbSkip()
	EndDo
	For ii:=1 to Len(aCols)
		If !aCols[ii,Len(aCols[ii])]
			If DbSeek("@@",.F.)
				RecLock("SZB",.F.)
			Else
				RecLock("SZB",.T.)
			EndIf
			//GRAVACAO DOS ITENS
			For AC:=1 to Len(aHeader)
				FieldPut(FieldPos(ALLTRIM(aHeader[AC,2])),aCols[ii,AC])
			Next
			SZB->ZB_FILIAL  := xFILIAL("SZB")
			SZB->ZB_NUM     := M->_ZB_NUM
			SZB->ZB_ITBMM   := StrZero(ii,3)
			SZB->ZB_DATA    := M->_ZB_DATA
			MsUnLock()
		EndIf
	Next

	Return(.T.)
	*
	***********************************************************************************
User Function Janela4(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,;
	cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze) //ok
	***********************************************************************************
	*
	*
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

	Private oDlgJ3,oGetDados
	//Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	Private lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
	bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	nOpcE := If(nOpcE==Nil,2,nOpcE)
	nOpcG := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	//nLinhas:=Iif(nLinhas==Nil,99,nLinhas)
	nLinhas:=99

	DbSelectArea("SZB")
	DbSetOrder(1)
	DEFINE MSDIALOG oDlgJ3 TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	@ 015,005 Say "Nro.BMM: "      //Size 60,10
	@ 015,040 Get _ZB_NUM          When Inclui Valid u_ValNum() //Size 50,10
	@ 015,105 Say "Data Emissão: " //Size 60,10
	@ 015,140 Get _ZB_DATA         Size 50,10 When Inclui Valid u_ConfData()
	If cOpcao == "TRANS"
		@ 015,205 Say "Armazém de Destino: "
		@ 015,260 Get _cLocDes     Valid ConfDes()  //Size 50,10 !Empty(_cLocDes)
	EndIf

	/*/
	Exemplo de get com opcoes
	aRadio := {"Sim","Nao","Talvez","Quem sabe "}
	nRadio := 2
	@ 16,130 TO 67,180 TITLE "Opcao : "
	@ 23,130 RADIO aRadio VAR nRadio
	/*/

	//                                       Janela do get
	//EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,{11,2,100,355},aAltEnchoice,3,,,,,,lVirtual)
	//                            Janela do acols
	//oGetDados := MsGetDados():New(45,aPosObj[2,2],260,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,If(Inclui,nLinhas,Len(aCols)),cFieldOk)
	oGetDados := MsGetDados():New(45,aPosObj[2,2],260,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_AtuVar()}

	//ACTIVATE MSDIALOG oDlgJ3 ON INIT EnchoiceBar(oDlgJ3,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlgJ3:End()),nOpca := 0)},{||oDlgJ3:End()},,aButtons) CENTERED
	ACTIVATE MSDIALOG oDlgJ3 ON INIT EnchoiceBar(oDlgJ3,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlgJ3:End()),nOpca := 0)},{||oDlgJ3:End()}) Centered

	lRet:=(nOpca==1)
	Return(lRet)

	//Legenda
	***********************
User Function CsLEGEN() // OK
	***********************
	*
	*
	BrwLegenda(cCadastro,"Legenda",;
	{{"BR_CINZA"  ,"Envio para Retrabalho"},;
	{"BR_BRANCO" ,"Devolução do Retrabalho"},;
	{"BR_PINK"   ,"Transferência"},;
	{"ENABLE"    ,"BMM não Confirmado"},;
	{"DISABLE"   ,"BMM Confirmado"},;
	{"BR_PRETO"  ,"BMM Cancelado"},;
	{"BR_AZUL"   ,"BMM de Pesagem"},;
	{"BR_LARANJA","BMM de Pesagem Já Processado"},;
	{"BR_AMARELO","Sucata"}})
	Return(.T.)

	***********************
User Function CSLinOk() // OK
	***********************
	*
	If aCols[n,Len(aCols[n])] .And. GdFieldGet("ZB_STATUS",n) $ "NC"
		Alert("Movimento já Confirmado - Dado não pode ser excluído")
		aCols[n,Len(aCols[n])] := .F.
		oGetDados:Refresh()
	ElseIf !aCols[n,Len(aCols[n])]
		If GdFieldGet("ZB_STATUS",n) $ "13"
			_nMult  := Val(Substr(GdFieldGet("ZB_LOCALIZ",n),2))
			_nQuant := GdFieldGet("ZB_QUANT",n)
			_nResto := (_nQuant % _nMult)
			If _nResto # 0
				Alert("Informar somente múltiplos da localização")
				Return(.F.)
			EndIf
		ElseIf GdFieldGet("ZB_ACOND",n) # "R  " .And. GdFieldGet("ZB_QTDBOB",n) == 0
			Alert("Informar obrigatoriamente a quantidade de "+ If(Left(GdFieldGet("ZB_ACOND",n),1)=="B","bobinas","carretéis"))
			Return(.F.)
		ElseIf GdFieldGet("ZB_ACOND",n) == "R  "
			GdFieldPut("ZB_QTDBOB",0,n)
		EndIf
	EndIf
	If GdFieldGet("ZB_STATUS",n) == "2" // Retorno de retrabalho
		If Empty(GdFieldGet("ZB_BMMORIG",n)) .Or. Empty(GdFieldGet("ZB_IBMMORI",n))
			Alert("Preencher os campos BMM Origem e Item do BMM Origem")
			Return(.F.)
		EndIf
	EndIf
	Return(.T.)
	*
	***********************
User Function CsTudOk()
	***********************
	*
	// Verificar se tem saldo na origem para fazer a transferêcia
	// ZB_STATUS == 1 - Envio para retrabalho
	// ZB_STATUS == 2 - Retorno do retrabalho
	// ZB_STATUS == 3 - Transferência (origem)
	_lTemTudo := .T.
	If cOpcao == "TRANS"
		If Empty(_cLocDes)
			Alert("Informar Obrigatoriamente o Armazem de Destino")
			Return(.F.)
		EndIf
	EndIf
	For _n := 1 to Len(aCols)
		If !aCols[_n,Len(aCols[_n])]
			_cLocOrig := Left(If(GdFieldGet("ZB_STATUS",_n) $ "13",GdFieldGet("ZB_LOCAL",_n)  ,GetMv("MV_LOCRET"))+"  ",2)
			_cEndOrig := Left(If(GdFieldGet("ZB_STATUS",_n) $ "13",GdFieldGet("ZB_LOCALIZ",_n),GetMv("MV_ENDRET"))+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+GdFieldGet("ZB_PRODUTO",_n),.F.))
			If SB1->B1_LOCALIZ =="S"
				DbSelectArea("SBF")
				DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				If DbSeek(xFilial("SBF")+_cLocOrig+_cEndOrig+GdFieldGet("ZB_PRODUTO",_n),.F.)
					RecLock("SBF",.F.)
					If GdFieldGet("ZB_QUANT",_n)  <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0 // Ainda tenho a quantidade disponível
						SBF->BF_EMPENHO += GdFieldGet("ZB_QUANT",_n)
						MsUnLock()
					Else  // Se não tenho quantidade disponivel...
						MsUnLock()
						_lTemTudo := .F.
						Exit
					EndIf
				Else
					_lTemTudo := .F.
					Exit
				EndIf
			Else
				// Veririfar no SB2
				DbSelectArea("SB2")
				DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL
				If DbSeek(xFilial("SB2")+GdFieldGet("ZB_PRODUTO",_n)+_cLocOrig,.F.)
					RecLock("SB2",.F.)
					If GdFieldGet("ZB_QUANT",_n)  <= (SB2->B2_QATU - SB2->B2_RESERVA) // Ainda tenho a quantidade disponível
						SB2->B2_RESERVA += GdFieldGet("ZB_QUANT",_n)
						MsUnLock()
					Else  // Se não tenho quantidade disponivel...
						MsUnLock()
						_lTemTudo := .F.
						Exit
					EndIf
				Else
					_lTemTudo := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next
	If !_lTemTudo
		// Reverte os Empenhos
		For _xn := 1 to _n-1
			If !aCols[_xn,Len(aCols[_xn])]
				_cLocOrig := Left(If(GdFieldGet("ZB_STATUS",_xn) $ "13",GdFieldGet("ZB_LOCAL",_xn)  ,GetMv("MV_LOCRET"))+"  ",Len(SZB->ZB_LOCAL))
				_cEndOrig := Left(If(GdFieldGet("ZB_STATUS",_xn) $ "13",GdFieldGet("ZB_LOCALIZ",_xn),GetMv("MV_ENDRET"))+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+GdFieldGet("ZB_PRODUTO",_xn),.F.))
				If SB1->B1_LOCALIZ =="S"
					DbSelectArea("SBF")
					DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If DbSeek(xFilial("SBF")+_cLocOrig+_cEndOrig+GdFieldGet("ZB_PRODUTO",_xn),.F.)
						RecLock("SBF",.F.)
						SBF->BF_EMPENHO -= GdFieldGet("ZB_QUANT",_xn)
						MsUnLock()
					EndIf
				Else
					DbSelectArea("SB2")
					DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL
					If DbSeek(xFilial("SB2")+GdFieldGet("ZB_PRODUTO",_xn)+_cLocOrig,.F.)
						RecLock("SB2",.F.)
						SB2->B2_RESERVA -= GdFieldGet("ZB_QUANT",_xn)
						MsUnLock()
					EndIf
				EndIf
			EndIf
		Next
		Alert("O Item " + StrZero(_xn,3) + " não Possue Saldo Disponível")
	EndIf
	Return(_lTemTudo)

	***********************
User Function  AtuVar()
	***********************
	*
	// Esta função é chamada antes da entrada na linha seguinte
	For _ni:=1 to nUsado
		_Var    := "M->"+AllTrim(aHeader[_ni,2])
		&(_Var) := GDFieldGet(aHeader[_ni,2],n)
	Next
	Return(.t.)

	************************
User Function ValNum()
	************************
	*
	DbSelectArea("SZB")
	dbSetOrder(1)
	_Volta := .T.
	If Empty(M->_ZB_NUM,1)
		Alert("Informar Número do BMM")
		_Volta := .F.
	ElseIf Left(M->_ZB_NUM,1) == "P"
		Alert("BMMs com Inicio 'P' só para Pesagens")
		_Volta := .F.
	ElseIf dbSeek(xFilial("SZB")+M->_ZB_NUM,.F.)
		MsgBox("O BMM Número " +  M->_ZB_NUM + " Já Foi Informado", "", "ERRO")
		_Volta := .F.
	EndIf
	Return(_Volta)

	*********************
User Function CSEFBTM
	*********************
	*
	Processa({|lEnd| EfetBTM("S",0,"Z")}, 'Gravando Dados do BMM...')
	Return(.t.)
	*
	****************************************
User Function ProdPesag(_nQtdZB,_cLetra)
	****************************************
	*
	EfetBTM("B",_nQtdZB,_cLetra)
	Return(.T.)
	*
	************************************************
Static Function EfetBTM(_cStatus,_QtdRg,_cLetra)
	************************************************
	*
	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSelectArea("SZB")
	DbSetOrder(3) // Filial + ZB_STATUS
	If _QtdRg > 0
		ProcRegua(_QtdRg)
	Else
		ProcRegua(LastRec())
	EndIf

	Do While SZB->(DbSeek(xFilial("SZB")+_cStatus,.F.))
		IncProc()
		If !Empty(SZB->ZB_NUMSEQ1)
			// A produção já foi feita pelo PcFactory
			// Tem somente que transferir do LOCAL 20 LOCALIZ PROD_PCF para local 01 localiz do SZL

			//TODO COMEÇO
			For _nMovD3 := 1 To 2 // Para fazer dois movimentos: de saída e de entrada (transferência)
				If _nMovD3 == 1
					// Verificar se tem saldo na localização
					DbSelectArea("SBF")
					DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					_cLocMov := Padr("20",Len(SBF->BF_LOCAL))
					_cLizMov := Padr("PROD_PCF",Len(SBF->BF_LOCALIZ))

					SBF->(DbSeek(xFilial("SBF") + _cLocMov + _cLizMov + SZB->ZB_PRODUTO,.F.))
					If SBF->(Eof()) .Or. (SBF->BF_QUANT-SBF->BF_EMPENHO) < SZB->ZB_QUANT .Or. SBF->BF_EMPENHO < 0
						RecLock("SZB",.F.)
						SZB->ZB_STATUS := "E"
						MsUNLock()
						Exit
					EndIf
					cNumSeq := ProxNum()
				Else
					_cLocMov := Padr("01",Len(SBF->BF_LOCAL))
				EndIf

				DbSelectArea("SB1")
				DbSeek(xFilial("SB1")+SZB->ZB_PRODUTO,.F.)
				DbSelectArea("SB2")
				_cProduto := SZB->ZB_PRODUTO
				If !DbSeek(xFilial("SB2")+_cProduto+_cLocMov,.F.)
					CriaSB2(_cProduto,_cLocMov)
				EndIf

				//U_CBCTraMata(SZB->ZB_PRODUTO,"20","01",SZB->ZB_QUANT,SZB->ZB_NUM, "PROD_PCF", "")

				// Grava a transferência no SD3 com RE4 e DE4
				RecLock("SD3",.T.)
				SD3->D3_FILIAL  := xFilial("SD3")
				SD3->D3_TM      := If(_nMovD3==1,"999","499")
				SD3->D3_COD     := SZB->ZB_PRODUTO
				SD3->D3_UM      := SB1->B1_UM                   '
				SD3->D3_QUANT   := SZB->ZB_QUANT
				SD3->D3_CF      := If(_nMovD3==1,"RE4","DE4")
				SD3->D3_LOCAL   := _cLocMov
				SD3->D3_EMISSAO := SZB->ZB_DATA
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_USUARIO := cUserName
				SD3->D3_CHAVE   := If(_nMovD3==1,"E0","E9")
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_NUMBTM  := SZB->ZB_NUM
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_NUMBTM  := SZB->ZB_NUM
				SD3->D3_ITEBTM  := SZB->ZB_ITEM
				If _nMovD3 == 1 // Estou processando a saída
					SD3->D3_LOCALIZ := _cLizMov
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega os 15 custos medios atuais            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o custo da movimentacao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCusto := GravaCusD3(aCM)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
				SB1->(MsUnLock())
				SB2->(MsUnLock())
				SBF->(MsUnLock())
				SD3->(MsUnLock())
				SDA->(MsUnLock())


				RecLock("SZB",.F.)
				SZB->ZB_NUMSEQ2 := cNumSeq
				SZB->ZB_STATUS  := 'P'
				MsUNLock()
			Next
			//TODO FIM
		EndIf

		/*/
		Else
			_CriouOP := .T.
			_nSdProd := SZB->ZB_QUANT - SZB->ZB_QUJP //quantidade já produzida
			_cItem   := SZB->ZB_ITEM
			_NumOP   := SZB->ZB_SEMANA
			_cProd   := SZB->ZB_PRODUTO
			_cAlmo   := SZB->ZB_LOCAL
			_Obs     := "Cpl.BMM " + SZB->ZB_NUM + " OP " + SZB->ZB_SEMANA+_cItem
			If Empty(_cAlmo)
				_cAlmo := "01"
			EndIf
			_dDtOp   := Max(SZB->ZB_DATA,GetMv("MV_ULMES")+1)
			_dDtOp   := Max(_dDtOp,CtoD("03/06/08"))
			_nTenta := 1
			Do While _nSdProd > 0 .And. _CriouOP
				_cChave := " "
				DbSelectArea("SC2")
				//		If !DbSeek(xFilial("SC2")+SZB->ZB_SEMANA+_cItem+"001",.F.)
				If !DbSeek(xFilial("SC2")+_NumOP+_cItem+"001",.F.)
					_nAProd := 0.00
				ElseIf Empty(SC2->C2_DATRF) .And. (SC2->C2_QUANT-SC2->C2_QUJE) > 0 .And. SC2->C2_QUJE >= 0
					// Se a OP ainda não foi encerrada
					_nAProd := Min(_nSdProd,(SC2->C2_QUANT-SC2->C2_QUJE))
				Else
					_nAProd := 0.00
				EndIf
				If _nAProd > 0.00
					_C2_Local := SC2->C2_LOCAL
					_RegC2 := SC2->(Recno())
					If SC2->C2_LOCAL # _cAlmo
						RecLock("SC2",.F.)
						SC2->C2_LOCAL := _cAlmo
						MsUnLock()
					EndIf
					DbSelectArea("SD3")

					//Realiza o consumo referente ao "PA"
					If Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_TIPO") == "PA" .AND. _nAProd > 0 //VALIDAR JULIANA E ROBERTO
						_cCodComp := Posicione("SG1",1,xFilial("SG1")+_cProd,"G1_COMP")
						_nQtdComp := _nAProd  * Posicione("SG1",1,xFilial("SG1")+_cProd,"G1_QUANT")
						If ! Empty(_cCodComp)
							aItens 	:= {{"D3_TM"		,"504"									 						,NIL},; //TP.MOVIM.
							{"D3_COD" 		,_cCodComp														,NIL},; //D3_COD
							{"D3_DOC"		,Left(_NumOP+Space(Len(SD3->D3_DOC)),Len(SD3->D3_DOC))	,NIL},; //TP.MOVIM.
							{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+_cCodComp,"B1_UM")		,NIL},;
							{"D3_LOCAL" 	,"99"															,NIL},;
							{"D3_QUANT" 	,_nQtdComp														,NIL},;
							{"D3_HIST" 	    ,"CONS REALIZADO CDEST04X"								,NIL},; // Não alterar esta expressão - tem validação em outro lugar
							{"D3_OP" 		,_NumOP+_cItem+"001" 										,NIL},;
							{"D3_EMISSAO" ,_dDtOp												   		,NIL},;
							{"D3_PARCTOT" ,"P"															,NIL}}

							_cLangAtu := __LANGUAGE
							If AllTrim(GetMv("MV_ESTNEG")) == "N"
								__LANGUAGE := "ENGLISH"
							EndIf
							lMsErroAuto 	:= .F.
							MSExecAuto({|x,y| mata240(x,y)},aItens,3)
							If __LANGUAGE # _cLangAtu
								__LANGUAGE := _cLangAtu
							EndIf

							If !lMsErroAuto
								If 	Empty(_cChave)
									_cChave := SD3->D3_NUMSEQ + " - CONS REALIZADO CDEST04X" // Não alterar esta expressão - tem validação em outro lugar
								EndIf
								RecLock("SD3",.F.)
								SD3->D3_HIST := _cChave
								MsUnLock()
							Else
								// MostraErro()
							EndIf

							//Requisitando Bobinas/Carretéis
							_cCodProdut 	:= Alltrim(Posicione("SX5",1,xFilial("SX5") + "ZA" + Alltrim(SZB->ZB_ACOND),"X5_DESCRI"))
							If Alltrim(_cCodProdut) <> ""
								_nQtdProduto	:= SZB->ZB_QTDBOB
								aItens 	:= {{"D3_TM"		,"504"									 				,NIL},; //TP.MOVIM.
								{"D3_COD" 	,_cCodProdut											,NIL},; //D3_COD
								{"D3_DOC"	,Left(_NumOP+Space(Len(SD3->D3_DOC)),Len(SD3->D3_DOC))	,NIL},; //TP.MOVIM.
								{"D3_UM" 	,Posicione("SB1",1,xFilial("SB1")+_cCodComp,"B1_UM")	,NIL},;
								{"D3_LOCAL" ,"01"													,NIL},;
								{"D3_QUANT" ,_nQtdProduto											,NIL},;
								{"D3_HIST" 	,"CONS REALIZADO CDEST04X"								,NIL},; // Não alterar esta expressão - tem validação em outro lugar
								{"D3_OP" 	,_NumOP+_cItem+"001" 									,NIL},;
								{"D3_EMISSAO" ,_dDtOp												,NIL},;
								{"D3_CONTA"	,Posicione("SB1",1,xFilial("SB1")+_cCodProdut,"B1_CONTA"),NIL},;
								{"D3_PARCTOT" ,"P"													,NIL}}

								_cLangAtu := __LANGUAGE
								If AllTrim(GetMv("MV_ESTNEG")) == "N"
									__LANGUAGE := "ENGLISH"
								EndIf
								lMsErroAuto 	:= .F.
								MSExecAuto({|x,y| mata240(x,y)},aItens,3)
								If __LANGUAGE # _cLangAtu
									__LANGUAGE := _cLangAtu
								EndIf

								If !lMsErroAuto
									If 	Empty(_cChave)
										_cChave := SD3->D3_NUMSEQ + " - CONS REALIZADO CDEST04X" // Não alterar esta expressão - tem validação em outro lugar
									EndIf
									RecLock("SD3",.F.)
									SD3->D3_HIST := _cChave
									MsUnLock()
								Else
									// MostraErro()
								EndIf
							EndIf
						EndIf
					EndIf

					_ParcTot := "P"

					_aVetor:={{"D3_TM"      , "006"						,NIL},;
					{"D3_COD"     , _cProd						,NIL},;
					{"D3_UM"      , SZB->ZB_UM				,NIL},;
					{"D3_QUANT"   , _nAProd					,NIL},;
					{"D3_OP"      , _NumOP+_cItem+"001" 		,NIL},;
					{"D3_LOCAL"   , _cAlmo						,NIL},;
					{"D3_DOC"     , Left(_NumOP+Space(Len(SD3->D3_DOC)),Len(SD3->D3_DOC))   ,NIL},;
					{"D3_EMISSAO" , _dDtOp						,NIL},;
					{"D3_PARCTOT" , _ParcTot					,NIL},;
					{"D3_NUMBTM"  , SZB->ZB_NUM				,NIL},;
					{"D3_HIST" 	,_cChave					,NIL},;
					{"D3_ITEBTM"  , "ZZ"						,NIL},;
					{"D3_PERDA"   , 0							,NIL}}
					lMsErroAuto := .F.
					MSExecAuto({|x,y| Mata250(x,y)},_aVetor,3)

					If Select("TB_CB") > 0 // Abriu o arquivo
						// O execauto destrava todos os registros de todos os arquivos dá MsUnLockAll
						// e eu preciso desse cara sempre travado
						DbSelectArea("TB_CB")
						RecLock("TB_CB",.F.)
					EndIf

					If lMsErroAuto
						MOSTRAERRO()
					EndIf

					DbSelectArea("SC2")
					DbGoTo(_RegC2)
					If SC2->C2_LOCAL # _C2_Local
						RecLock("SC2",.F.)
						SC2->C2_LOCAL := _C2_Local
						MsUnLock()
					EndIf
					DbSelectArea("SD3")
					DbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

					//_cOP := Left(SZB->ZB_SEMANA+_cItem+"001"+Space(Len(SD3->D3_OP)),Len(SD3->D3_OP))

					_cOP := Left(_NumOP+_cItem+"001"+Space(Len(SD3->D3_OP)),Len(SD3->D3_OP))
					Dbseek(xFilial("SD3")+_cOP+_cProd+_cAlmo,.F.)
					_lFezMov := .F.
					Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_OP == _cOP .And. SD3->D3_COD == _cProd .And. ;
					SD3->D3_LOCAL == _cAlmo .And. SD3->(!Eof())
						If SD3->D3_EMISSAO == _dDtOp .And. SD3->D3_NUMBTM == SZB->ZB_NUM .And. SD3->D3_ITEBTM == "ZZ"
							RecLock("SD3",.F.)
							SD3->D3_ITEBTM := "  "
							MsUnLock()
							_lFezMov := .T.
							Exit
						EndIf
						SD3->(DbSkip())
					EndDo
					If !_lFezMov
						If _nTenta++ > 5
							RecLock("SZB",.F.)
							SZB->ZB_STATUS := If(_cStatus=="S","E","e")
							MsUnLock()
							Alert("Erro ao Efetivar o BMM " + SZB->ZB_NUM + " Semana " + SZB->ZB_SEMANA + " Item " +  _cItem + Chr(13) + "Exclua e Corrija em outro BMM")
							Exit
						EndIf
					Else
						_nTenta := 1
						_nSdProd -= _nAProd
						DbSelectArea("SZB")
						RecLock("SZB",.F.)
						If Empty(SZB->ZB_NUMSEQ1)
							SZB->ZB_NUMSEQ1 := SD3->D3_NUMSEQ
						Else
							SZB->ZB_NUMSEQ2 := SD3->D3_NUMSEQ
						EndIf
						SZB->ZB_QUJP := SZB->ZB_QUJP + _nAProd
						If SZB->ZB_QUJP >= SZB->ZB_QUANT
							SZB->ZB_STATUS := If(_cStatus=="S","N","P")
						EndIf
						MsUnLock()
					EndIf
				EndIf
				If _nSdProd > 0
					_dDtOp   := Max(_dDtOp,dDatabase)
					SC2->(DbSetOrder(1))
					_lItem := .T.
					Do While SC2->(DbSeek(xFilial("SC2")+_NumOP+_cItem,.F.))
						If _cItem == "ZZ"
							If _lItem
								_lItem := .F.
								_cItem := "00" // Começar de novo pra ver se tem alguma brecha
							Else
								// Cai fora
								Exit
							EndIf
						EndIf
						_cItem := Soma1(_cItem,,.F.)
					EndDo
					If (_cItem == "ZZ" .And. !_lItem) .Or. Len(_cItem) > 2
						// Achar uma OP com número superior a 550000 até 999999
						DbSelectArea("SC2")
						DbSetOrder(1)
						_nNumSeek := 550000
						Do While DbSeek(xFilial("SC2")+StrZero(_nNumSeek,6) + "ZZ",.F.)
							If _nNumSeek == 999999
								Exit
							EndIf
							_nNumSeek++
						EndDo
						If SC2->C2_NUM+SC2->C2_ITEM == "999999ZZ"
							DbSelectArea("SZB")
							RecLock("SZB",.F.)
							SZB->ZB_STATUS := "Z"
							MsUnLock()
							MsgAlert("O BMM " + SZB->ZB_NUM + "Item " + SZB->ZB_ITBMM + " / " + SZB->ZB_SEMANA + " / " + SZB->ZB_ITEM + " não foi processado!!!! Erro na Criação da O.P.","Atencao!")
							Exit
						Else
							_NumOP := StrZero(_nNumSeek,6)
							_cItem := "01"
							Do While SC2->(DbSeek(xFilial("SC2")+_NumOP+_cItem,.F.))
								If _cItem == "ZZ" // Isto nunca deve acontecer
									Exit
								EndIf
								_cItem := Soma1(_cItem,,.F.)
							EndDo
						EndIf
					EndIf
					_Item    := _cItem
					_cSeq    := "001"
					_nQtd    := _nSdProd
					lCriaOPI := .T.
					If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz
						lCriaOPI := .F.
					EndIf
					_CriouOP := u_NovaOP("I",lCriaOPI,dDatabase," ")  // Parâmetros: I=Incluir / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias
					DbSelectArea("SZB")
					RecLock("SZB",.F.)
					If _CriouOP
						SZB->ZB_NROPCPL := _NumOP
						SZB->ZB_ITOPCPL := _Item
						MsUnLock()
					Else
						SZB->ZB_STATUS := "Z"
						MsUnLock()
						MsgAlert("O BMM " + SZB->ZB_NUM + " / " + SZB->ZB_SEMANA + " / " + SZB->ZB_ITEM + " não foi processado!!!! Erro na Criação da O.P.","Atencao!")
						Exit
					EndIf
				EndIf
			EndDo
		EndIf
		/*/
	EndDo
Return(.T.)


/*/{Protheus.doc} M265FIL
//TODO ponto de entrada da MATA265.
@author juliana.leme
@since 12/06/2017
@version undefined

@type function
/*/
User Function M265FIL()
	//Retirado por inutilização // Juliana Leme
Return(.T.)

	*
	**************************
Static Function PodeAlt()
	*************************
	*
	_Volta := .T.
	_cBMM := SZB->ZB_NUM
	SZB->(dbSetOrder(1))
	SZB->(dbSeek(xFilial("SZB")+_cBMM,.F.))
	Do While SZB->ZB_FILIAL == xFilial("SZB") .And. SZB->ZB_NUM == _cBMM .And. SZB->(!eof())
		If SZB->ZB_STATUS # 'S' .Or. SZB->ZB_QUJP # 0.00
			Alert("Este BMM não pode ser "+If(cOpcao=="ALTERAR","Alterado!","Excluído!"))
			_Volta := .F.
			Exit
		EndIf
		SZB->(DbSkip())
	EndDo
	Return(_Volta)

	**********************
User Function CsEsBTM()
	**********************
	*
	If SZB->ZB_STATUS == "C"
		MsgBox("BMM já Cancelado!!!", "Atencao:", "INFO")
		Return(.T.)
	ElseIf SZB->ZB_QUJP == 0
		MsgBox("BMM nao Efetivado - Utilise a Rotina Altera/Exclui", "Atencao:", "INFO")
		Return(.T.)
	ElseIf Empty(SZB->ZB_NUMSEQ1)
		MsgBox("BMM nao Pode ser Excluido", "Atencao:", "INFO")
		Return(.T.)
	EndIf

	_cAlmo   := SZB->ZB_LOCAL
	If Empty(_cAlmo)
		_cAlmo := "01"
	EndIf
	_lPode := .T.

	DbSelectArea("SDA")
	DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
	If DbSeek(xFilial("SDA") + SZB->ZB_PRODUTO + _cAlmo + SZB->ZB_NUMSEQ1,.F.)
		_lPode := (SDA->DA_QTDORI == SDA->DA_SALDO)
	EndIf
	If _lPode .And. !Empty(SZB->ZB_NUMSEQ2)
		If DbSeek(xFilial("SDA") + SZB->ZB_PRODUTO + _cAlmo + SZB->ZB_NUMSEQ2,.F.)
			_lPode := (SDA->DA_QTDORI == SDA->DA_SALDO)
		EndIf
	EndIf
	If !_lPode
		MsgBox("BMM ja Distribuido - Nao Pode ser Excluido - ", "Atencao:", "INFO")
		Return(.T.)
	EndIf
	DbSelectArea("SZB")
	nOpca := AxVisual("SZB",Recno(),2)
	If nOpca == 1 // Confirmou a Operação
		DbSelectArea("SDA")
		DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
		If DbSeek(xFilial("SDA") + SZB->ZB_PRODUTO + _cAlmo + SZB->ZB_NUMSEQ1,.F.)
			_lPode := (SDA->DA_QTDORI == SDA->DA_SALDO)
		EndIf
		If _lPode .And. !Empty(SZB->ZB_NUMSEQ2)
			If DbSeek(xFilial("SDA") + SZB->ZB_PRODUTO + _cAlmo + SZB->ZB_NUMSEQ2,.F.)
				_lPode := (SDA->DA_QTDORI == SDA->DA_SALDO)
			EndIf
		EndIf
		If !_lPode
			MsgBox("BMM ja Distribuido - Nao Pode ser Excluido - ", "Atencao:", "INFO")
			Return(.T.)
		EndIf
		For _nVez := 1 to 2
			If  _nVez == 1
				cZBNUMSEQ := SZB->ZB_NUMSEQ1
			Else
				cZBNUMSEQ := SZB->ZB_NUMSEQ2
			EndIf
			If Empty(cZBNUMSEQ)
				Loop
			EndIf
			DbSelectArea("SD3")
			DbSetOrder(4) // D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
			DbSeek(xFilial("SD3")+ cZBNUMSEQ,.F.)
			Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_NUMSEQ == cZBNUMSEQ .And. SD3->(!Eof())
				If SD3->D3_CF ==  "PR0" .And. Empty(SD3->D3_ESTORNO)
					Exit
				EndIf
				SD3->(DbSkip())
			EndDo
			If SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_NUMSEQ == cZBNUMSEQ .And. ;
			SD3->D3_CF == "PR0" .And. SD3->(!Eof()) .And. Empty(SD3->D3_ESTORNO)
				_cOPNum := SD3->D3_OP

				_aVetor:={{"D3_TM"     , SD3->D3_TM                  ,NIL},;
				{"D3_COD"     , SD3->D3_COD                 ,NIL},;
				{"D3_UM"      , SD3->D3_UM                  ,NIL},;
				{"D3_QUANT"   , SD3->D3_QUANT               ,NIL},;
				{"D3_OP"      , SD3->D3_OP                  ,NIL},;
				{"D3_LOCAL"   , SD3->D3_LOCAL               ,NIL},;
				{"D3_DOC"     , SD3->D3_DOC                 ,NIL},;
				{"D3_EMISSAO" , SD3->D3_EMISSAO             ,NIL},;
				{"D3_PARCTOT" , SD3->D3_PARCTOT             ,NIL},;
				{"D3_NUMBTM"  , SD3->D3_NUMBTM              ,NIL},;
				{"D3_ITEBTM"  , Sd3->D3_ITEBTM              ,NIL},;
				{"D3_PERDA"   , SD3->D3_PERDA               ,NIL}}
				MSExecAuto({|x,y| Mata250(x,y)},_aVetor,5)
				/*
				{ {STR0001,"AxPesqui"  , 0 , 1},;   //"Pesquisar"
				{STR0002,"A250Visual", 0 , 2},;   //"Visualizar"
				{STR0003,"A250Inclui", 0 , 3},;   //"Incluir"
				{STR0004,"A250Estorn", 0 , 5},;   //"Estornar"
				{STR0005,"A250Encer", 0 , 5} }    //"enceRrar"
				BOPS 66326 e BOPS 66317 - incluído tratamento para estorno (nOpc = 5) e
				encerramento (nOpc = 6) por Rotina Automática. - A
				*/
				If !Empty(SZB->ZB_ITOPCPL)
					// Se for uma op complementar, excluir a OP
					If Len(AllTrim(SZB->ZB_ITOPCPL)) == 2 // Gravado somente o Item da OP
						_cOPCpl := Left(SZB->ZB_SEMANA+SZB->ZB_ITOPCPL+"001"+Space(Len(SD3->D3_OP)),Len(SD3->D3_OP))
					Else // Gravado a OP Inteira NUM+ITEM+SEQUEN - 6+2+3
						_cOPCpl := Left(SZB->ZB_ITOPCPL+Space(Len(SD3->D3_OP)),Len(SD3->D3_OP))
					EndIf
					If _cOPCpl == _cOPNum
						DbSelectArea("SC2")
						DbSetOrder(1) // \C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
						If DbSeek(xFilial("SC2")+_cOPNum,.F.)
							u_NovaOP("E",.T.,CtoD("")," ")  // Parâmetros: I=Incluir / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		DbSelectArea("SZB")
		RecLock("SZB",.F.)
		SZB->ZB_STATUS := "C"
		MsUnLock()
	EndIf
	Return(.T.)
	*
	*
	*********************************************
User Function CriaSD3(_cTM,_Numseq,_nQtdTira) // Forma de chamar a CRIESD3() de fora deste PRW
	*********************************************
	*
	*
	If ValType(_nQtdTira) # "N"
		_nQtdTira := 0
	EndIf

	cNumSeq := _Numseq
	CrieSD3(_cTM,_nQtdTira)
	Return(.T.)
	*
	*
	*****************************
Static Function CrieSD3(_cTM,_nQtdTira)
	*****************************
	*
	If ValType(_nQtdTira) # "N"
		_nQtdTira := 0
	EndIf

	//** Atenção... se for saída RE4, a quantidade tem que estar somada em BF_EMPENHO ou B2_RESERVA....

	// SZB->ZB_STATUS == '1' // Envio para Retrabalho
	// SZB->ZB_STATUS == '2' // Devolução do Retrabalho
	// SZB->ZB_STATUS == '3' // Transferência (origem)

	If _cTM == "RE4" // Estou processando a saída
		_cLocOrig := Left(If(SZB->ZB_STATUS $ "13",SZB->ZB_LOCAL   ,GetMv("MV_LOCRET"))+"  ",Len(SZB->ZB_LOCAL))
		_cEndOrig := Left(If(SZB->ZB_STATUS $ "13",SZB->ZB_LOCALIZ ,GetMv("MV_ENDRET"))+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))

		If !Empty(SZB->ZB_BMMORIG) .And. SZB->ZB_STATUS == '2'
			DbSelectArea("ZZE")
			ZZE->(DbSetOrder(1)) // ZZE_FILIAL+ZZE_ID
			ZZE->(DbSeek(xFilial("ZZE")+SZB->ZB_BMMORIG,.F.))
			_cEndOrig := Left(ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5)+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))
		EndIf

		// Estornar o Empenho
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SZB->ZB_PRODUTO,.F.))
		If SB1->B1_LOCALIZ =="S"
			DbSelectArea("SBF")
			DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If DbSeek(xFilial("SBF")+_cLocOrig+_cEndOrig+SZB->ZB_PRODUTO,.F.)
				RecLock("SBF",.F.)
				// SBF->BF_EMPENHO -= SZB->ZB_QUANT
				SBF->BF_EMPENHO -= If(_nQtdTira == 0,SZB->ZB_QUANT,_nQtdTira)
				MsUnLock()
			EndIf
		Else
			DbSelectArea("SB2")
			DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL
			If DbSeek(xFilial("SB2")+SZB->ZB_PRODUTO+_cLocOrig,.F.)
				RecLock("SB2",.F.)
				SB2->B2_RESERVA -= SZB->ZB_QUANT
				MsUnLock()
			EndIf
		EndIf
	Else //If _cTM == "DE4" // Estou processando a entrada
		If SZB->ZB_STATUS == "1"
			_cLocOrig := GetMv("MV_LOCRET")
		ElseIf SZB->ZB_STATUS == "2"
			_cLocOrig := SZB->ZB_LOCAL
		ElseIf SZB->ZB_STATUS == "4" // Se for Sucata
			_cLocOrig := SZB->ZB_LOCAL
		ElseIf SZB->ZB_STATUS == "3"
			_cLocOrig := _cLocDes
		EndIf
		_cLocOrig := Left(_cLocOrig+"  ",Len(SZB->ZB_LOCAL))
		If SZB->ZB_STATUS == "1" //Estou processando uma remessa para retralho
			_cEndOrig := Left(GetMv("MV_ENDRET")+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))
		EndIf
	EndIf

	DbSelectArea("SB1")
	DbSeek(xFilial("SB1")+SZB->ZB_PRODUTO,.F.)

	DbSelectArea("SB2")
	_cProduto := SZB->ZB_PRODUTO
	If !DbSeek(xFilial("SB2")+_cProduto+_cLocOrig,.F.)
		CriaSB2(_cProduto,_cLocOrig)
	EndIf
	RecLock("SB2",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o proximo numero sequencial de movimento      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("SD3",.T.)
	_nRegSD3 := SD3->(Recno())
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_TM      := If(SZB->ZB_STATUS=="4","103",If(_cTM == "RE4","999","499"))
	SD3->D3_COD     := SZB->ZB_PRODUTO
	SD3->D3_UM      := SB1->B1_UM                   '
	SD3->D3_QUANT   := If(_nQtdTira == 0,SZB->ZB_QUANT,_nQtdTira)
	SD3->D3_CF      := If(SZB->ZB_STATUS=="4","DE0",_cTM)
	SD3->D3_LOCAL   := _cLocOrig
	SD3->D3_EMISSAO := SZB->ZB_DATA
	SD3->D3_NUMSEQ  := cNumSeq
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_USUARIO := cUserName
	SD3->D3_CHAVE   := If(SZB->ZB_STATUS=="4","E0",If(_cTM == "RE4","E0","E9"))
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	If !_cTM $ "DE4/RE4"
		SD3->D3_STSERV  := "1"
	EndIf
	SD3->D3_NUMBTM  := SZB->ZB_NUM
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_CONTA   := SB1->B1_CONTA
	SD3->D3_DOC 	:= SZB->ZB_NUM
	SD3->D3_NUMBTM  := SZB->ZB_NUM
	SD3->D3_ITEBTM  := SZB->ZB_ITEM
	If _cTM == "RE4" // Estou processando a saída
		SD3->D3_LOCALIZ := _cEndOrig
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega os 15 custos medios atuais            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o custo da movimentacao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCusto := GravaCusD3(aCM)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
	SB1->(MsUnLock())
	SB2->(MsUnLock())
	SBF->(MsUnLock())
	SD3->(MsUnLock())
	SDA->(MsUnLock())
	If _cTM == "DE4" .And. SZB->ZB_STATUS == "1" // Estou processando a entrada e uma remessa para retralho
		// Efetua a distribuição das quantidades.
		SD3->(DbGoTo(_nRegSD3))

		DbSelectArea("SDA")
		DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
		If DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
			If SDA->DA_SALDO > 0
				_RegSDA := Recno()
				aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
				{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
				{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
				{"DA_DATA"    ,SDA->DA_DATA                , nil},;
				{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
				{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
				{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
				{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
				{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
				{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}

				aITENS:={{	{"DB_ITEM"    , "0001"                     , nil},;
				{"DB_LOCALIZ" , _cEndOrig                  , nil},;
				{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
				{"DB_DATA"    , SDA->DA_DATA               , nil},;
				{"DB_ESTORNO" ," "                         , nil} }}

				msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
			EndIf
		EndIf
	EndIf
	Return(.T.)
	*
	*************************
Static Function ConfDes()
	*************************
	*
	_Volta := .F.
	If Empty(_cLocDes)
		Alert("Informar Obrigatoriamente o Armazém de Destino")
	ElseIf !_cLocDes $ "01/90"
		Alert("Como Armazém de Destino só Pode Ser Escolhido 01 ou 90")
	Else
		_Volta := .T.
	EndIf
	Return(_Volta)
	*
	************************
User Function ValCobre()
	************************
	// Função utilizada X3_VLDUSER dos campos ZB_SEMANA, ZB_ITEM, ZB_PRODUTO, ZB_QUANT e ZB_PESO************************
	*
	If "ZB_PRODUTO" $ ReadVar() // Foi digitado o código do produto
		If !u_VldBMMOr()
			Return(.F.)
		EndIf
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+GdFieldGet("ZB_PRODUTO",n),.F.))
	_nPesoTot := SB1->B1_PESCOB+SB1->B1_PESPVC
	_ZB_PESO  := If("ZB_PESO"  $ ReadVar(),&(ReadVar()),GdFieldGet("ZB_PESO" ,n))
	_ZB_QUANT := If("ZB_QUANT" $ ReadVar(),&(ReadVar()),GdFieldGet("ZB_QUANT",n))
	If _nPesoTot # 0 .And. _ZB_QUANT # 0 .And. _ZB_PESO # 0
		_nPesoLin := (_nPesoTot * _ZB_QUANT)
		//	_nDifPeso := Abs(_nPesoLin - _ZB_PESO)
		_nDifPeso := _nPesoLin - _ZB_PESO
		//	_PercPeso := Abs((_nDifPeso / _ZB_PESO) * 100)
		//	_PercPeso := Abs((_nDifPeso / _nPesoLin) * 100)
		_PercPeso := (_nDifPeso / _nPesoLin) * 100
		_PercPeso  := _PercPeso * -1
		If Abs(_PercPeso) > 5
			Alert("Peso Total Fora do Peso Padrão. " + Transform(_PercPeso,"@E 9999.99") + " %")
		EndIf
	EndIf
Return(.T.)

User Function ConfEst()

	_aCampos := {}
	aAdd(_aCampos, {"PRODUTO" , "C", TamSX3("B1_COD")[1], 0})
	aAdd(_aCampos, {"LOCAL"   , "C", TamSX3("B1_LOCPAD")[1], 0})
	aAdd(_aCampos, {"SALDO_B2", "N", 15, 2})
	aAdd(_aCampos, {"ACLAS_B2", "N", 15, 2})
	aAdd(_aCampos, {"SALDO_BF", "N", 15, 2})
	aAdd(_aCampos, {"ACLAS_DA", "N", 15, 2})
	aAdd(_aCampos, {"ERR_SLD" , "C", 01, 0})
	aAdd(_aCampos, {"ERR_CLS" , "C", 01, 0})

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

	DbSelectArea("SDA")
	DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA

	DbSelectArea("SBF")
	DbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD

	SB1->(DbSeek(xFilial("SB1"),.F.))
	Do While SB1->B1_FILIAL == xFilial("SB1") .And. SB1->(!Eof())
		If SB1->B1_LOCALIZ # "S"
			SB1->(DbSkip())
			Loop
		EndIf
		SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD,.F.))
		Do While SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == SB1->B1_COD .And. SB2->(!Eof())
			_BF_QUANT := 0
			SBF->(DbSeek(xFilial("SBF") + SB1->B1_COD + SB2->B2_LOCAL,.F.))
			Do While SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_PRODUTO == SB1->B1_COD .And.;
			SBF->BF_LOCAL == SB2->B2_LOCAL .And. SBF->(!Eof())
				_BF_QUANT += SBF->BF_QUANT
				SBF->(DbSkip())
			EndDo
			_DA_SALDO := 0
			SDA->(DbSeek(xFilial("SDA") + SB1->B1_COD + SB2->B2_LOCAL,.F.))
			Do While SDA->DA_FILIAL == xFilial("SDA") .And. SDA->DA_PRODUTO == SB1->B1_COD .And.;
			SDA->DA_LOCAL == SB2->B2_LOCAL .And. SDA->(!Eof())
				_DA_SALDO += SDA->DA_SALDO
				SDA->(DbSkip())
			EndDo

			If (SB2->B2_QACLASS # _DA_SALDO) .Or. (SB2->B2_QATU # (_BF_QUANT + _DA_SALDO))
				RecLock("TRB",.T.)
				TRB->PRODUTO	:= SB1->B1_COD
				TRB->LOCAL		:= SB2->B2_LOCAL
				TRB->SALDO_B2	:= SB2->B2_QATU
				TRB->ACLAS_B2	:= SB2->B2_QACLASS
				TRB->SALDO_BF	:= _BF_QUANT
				TRB->ACLAS_DA	:= _DA_SALDO
				If SB2->B2_QATU # (_BF_QUANT + _DA_SALDO)
					TRB->ERR_SLD	:= "X"
				EndIf
				If (SB2->B2_QACLASS # _DA_SALDO)
					RecLock("SB2",.F.)
					SB2->B2_QACLASS := _DA_SALDO
					SB2->(MsUnLock())
					TRB->ERR_CLS	:= "X"
				EndIf
				MsUnLock()
			EndIf
			SB2->(DbSkip())
		EndDo
		SB1->(DbSkip())
	EndDo
Return(.T.)


User Function Re_SDA()

	Processa({|lEnd| Re_SDA1()}, 'Atualizando SDA....')
Return(.T.)

Static Function Re_SDA1()

	DbSelectArea("SD3")
	SD3->(DbSetOrder(6)) //D3_FILIAL+ DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
	Do While .T.
		DbSeek(xFilial("SD3")+DTOS(dDataBase+1),.T.)
		If SD3->D3_EMISSAO > dDataBase .And. !SD3->(Eof())
			_dNeuDt := StrZero(Day(SD3->D3_EMISSAO),2)+"/"+StrZero(Month(SD3->D3_EMISSAO),2)+"/2006"
			RecLock("SD3",.F.)
			SD3->D3_EMISSAO := Ctod(_dNeuDt)
			MsUnLock()
		Else
			Exit
		EndIf
	EndDo

	DbSelectArea("SD3")
	SD3->(DbSetOrder(4)) // D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD

	DbSelectArea("SD1")
	SD1->(DbSetOrder(4)) // D1_FILIAL+D1_NUMSEQ

	DbSelectArea("SDB")
	SDB->(DbSetOrder(1)) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM

	DbSelectArea("SDA")
	SDA->(DbSetOrder(1)) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA

	ProcRegua(LastRec())

	SDA->(DbSeek(xFilial("SDA"),.F.))
	Do While SDA->DA_FILIAL == xFilial("SDA") .And. SDA->(!Eof())
		IncProc()
		If SDA->DA_ORIGEM == "SD3"
			SD3->(DbSeek(xFilial("SD3")+SDA->DA_NUMSEQ,.F.))
			_nRegSD3 := 0
			Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_NUMSEQ == SDA->DA_NUMSEQ .And. SD3->(!Eof())
				If SD3->D3_COD == SDA->DA_PRODUTO .And. SD3->D3_LOCAL == SDA->DA_LOCAL .And. SD3->(!Eof())
					_nRegSD3 := SD3->(Recno())
				EndIf
				RecLock("SD3",.F.)
				SD3->D3_CONTA := "   "
				SD3->(MsUnLock())
				SD3->(DbSkip())
			EndDo
			If 	_nRegSD3 > 0
				SD3->(DbGoTo(_nRegSD3))

				RecLock("SDA",.F.)
				SDA->DA_QTDORI2 := 0
				If SDA->DA_QTDORI # SD3->D3_QUANT
					SDA->DA_QTDORI := SD3->D3_QUANT
				EndIf
				If SDA->DA_DATA # SD3->D3_EMISSAO
					SDA->DA_DATA := SD3->D3_EMISSAO
				EndIf
				SDA->(MsUnLock())
			EndIf
		EndIf

		SDB->(DbSeek(xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ,.F.))
		_nTotDis := 0
		Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->DB_PRODUTO == SDA->DA_PRODUTO .And.;
		SDB->DB_LOCAL == SDA->DA_LOCAL .And. SDB->DB_NUMSEQ == SDA->DA_NUMSEQ .And. SDB->(!Eof())
			If SDB->DB_ESTORNO # "S"
				_nTotDis += SDB->DB_QUANT
			EndIf
			RecLock("SDB",.F.)
			SDB->DB_EMP2 := 0
			If SDB->DB_DATA # SDA->DA_DATA
				SDB->DB_DATA := SDA->DA_DATA
			EndIf
			MsUnLock()
			SDB->(DbSkip())
		EndDo
		If (SDA->DA_QTDORI-_nTotDis) # SDA->DA_SALDO
			RecLock("SDA",.F.)
			SDA->DA_SALDO := (SDA->DA_QTDORI-_nTotDis)
			MsUnLock()
		EndIf
		SDA->(DbSkip())
	EndDo
	Return(.t.)
	*
	************************
User Function ConfData()
	************************
	*
	_Ret := .T.
	If Empty(_ZB_DATA)
		Alert("Informar a Data do B.M.M.")
		_Ret := .F.
	ElseIf _ZB_DATA <= GetMv("MV_ULMES") .Or. _ZB_DATA > dDataBase .Or. _ZB_DATA < (dDataBase-5)
		Alert("Informar Corretamente a Data do B.M.M.")
		_Ret := .F.
	EndIf
	Return(_Ret)
	*
	**********************
User Function D3DESC()
	**********************
	*
	DbUseArea(.T.,,"SDB_INV.DTC","TRB",.T.,.F.)
	DbSelectArea("TRB")
	Do While TRB->(!Eof())
		If Empty(TRB->DB_DESC)
			SB1->(DbSeek(xFilial("SB1")+TRB->DB_PRODUTO,.F.))
			RecLock("TRB",.F.)
			TRB->DB_DESC := u_CortaDesc(SB1->B1_DESC)
			TRB->COBRE   := SB1->B1_PESCOB
			TRB->PVC     := SB1->B1_PESPVC
			MsUnLock()
		EndIf
		TRB->(DbSkip())
	EndDo
	Alert("terminei")
	Return(.T.)
	*
	************************
User Function VldBMMOr()
	************************
	*
	// Função utilizada X3_VLDUSER dos campos ZB_BMMORIG e ZB_IBMMORI e tb é chamada pela u_ValCobre()
	*
	Local _cProd,_cBMM,_cIBMM
	Local _Volta := .T.

	If M->ZB_STATUS == "2"
		_cProd := If("ZB_PRODUTO" $ ReadVar(),M->ZB_PRODUTO,GdFieldGet("ZB_PRODUTO",n))
		_cNBMM := If("ZB_BMMORIG" $ ReadVar(),M->ZB_BMMORIG,GdFieldGet("ZB_BMMORIG",n))
		_cIBMM := If("ZB_IBMMORI" $ ReadVar(),M->ZB_IBMMORI,GdFieldGet("ZB_IBMMORI",n))
		If !Empty(_cProd) .And. !Empty(_cNBMM) .And. !Empty(_cIBMM)
			// Retorno do retrabalho e foi indicado o Cód. Produto, Nro e item do BMM de Envio
			DbSelectArea("SZB")
			SZB->(DbSetOrder(1))
			SZB->(DbSeek(xFilial("SZB") + _cNBMM + _cIBMM,.F.))
			If SZB->(Eof())
				Alert("BMM Origem não Cadastrado")
				_Volta := .F.
			ElseIf SZB->ZB_STATUS # "1"
				Alert("BMM Origem não é de Envio de Retrabalho")
				_Volta := .F.
			ElseIf SZB->ZB_PRODUTO # _cProd
				Alert("Produto não confere com o BMM de Envio para Retrabalho")
				_Volta := .F.
			EndIf
		EndIf
	EndIf
	Return(_Volta)
	*
	******************************
Static Function ACRetrab(_cTM)
	******************************
	*
	// Envio para Retrabalho   -> 523-Requisição do     local 01
	// Devolução do Retrabalho -> 100-Devolução  para o Local 01
	*
	// Ao testar os lançamentos, as quantidades já foram empenhadas no SBF.
	// Assim, ao fazer o movimento no SD3 de Requisição, estornar o empenho.
	ProcRegua(Len(aCols))
	For ii:=1 to Len(aCols)
		IncProc()
		If !aCols[ii,Len(aCols[ii])]
			If SZB->(DbSeek("@@",.F.))
				RecLock("SZB",.F.)
			Else
				RecLock("SZB",.T.)
			EndIf
			//GRAVACAO DOS ITENS
			For AC:=1 to Len(aHeader)
				FieldPut(FieldPos(ALLTRIM(aHeader[AC,2])),aCols[ii,AC])
			Next
			SZB->ZB_FILIAL  := xFILIAL("SZB")
			SZB->ZB_NUM     := M->_ZB_NUM
			SZB->ZB_ITBMM    := StrZero(ii,3)
			SZB->ZB_DATA    := M->_ZB_DATA
			MsUnLock()

			u_GraveD3Rt(_cTM)
		EndIf
	Next
	Return(.T.)
	*
	*****************************
User Function GraveD3Rt(_cTM)
	*****************************
	*

	// Esta função tem que estar o SZB posicionado
	// e o TM só pode ser 100 ou 523
	// Se for Rquisição, o SBF tem que estar "resevado"

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xfilial("SB1")+SZB->ZB_PRODUTO,.F.)

	_aVetor:={{"D3_TM"      , _cTM            ,NIL},;
	{"D3_COD"     , SZB->ZB_PRODUTO ,NIL},;
	{"D3_UM"      , SB1->B1_UM      ,NIL},;
	{"D3_QUANT"   , SZB->ZB_QUANT   ,NIL},;
	{"D3_LOCAL"   , SZB->ZB_LOCAL   ,NIL},;
	{"D3_EMISSAO" , dDataBase       ,NIL},;
	{"D3_LOCALIZ" , SZB->ZB_LOCALIZ ,NIL}}

	If _cTM == "523" // É uma requisição -> Estornar o empenho no SBF e fazer o lançamento no SD3
		DbSelectArea("SBF")
		DbSetOrder(1)
		If DbSeek(xFilial("SBF")+SZB->ZB_LOCAL+SZB->ZB_LOCALIZ+SZB->ZB_PRODUTO,.F.)
			RecLock("SBF",.F.)
			SBF->BF_EMPENHO := SBF->BF_EMPENHO - SZB->ZB_QUANT
			MsUnLock()
		EndIf
	EndIf
	lMsErroAuto := .F.
	_xVolta := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)
	If _cTM == "100" .And. !lMsErroAuto // Se for uma devolução, fazer a distribuição.
		DbSelectArea("SDA")
		DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
		If DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
			_RegSDA := Recno()

			aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
			{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
			{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
			{"DA_DATA"    ,SDA->DA_DATA                , nil},;
			{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
			{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
			{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
			{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
			{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
			{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}

			aITENS:={{{"DB_ITEM"    , "0001"                     , nil},;
			{"DB_LOCALIZ" , SZB->ZB_LOCALIZ            , nil},;
			{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
			{"DB_DATA"    , SDA->DA_DATA               , nil},;
			{"DB_ESTORNO" ," "                         , nil} }}

			msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
		EndIf
	EndIf
	Return(.T.)
	//Gustavo
	*
	***********************
User Function TrfAlmx()
	***********************
	*

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbUseArea(.T.,,"\CONDUSUL\arm05_2.DTC","TRB",.T.,.F.)
	DbSelectArea("TRB")
	_nTtReg := LastRec()
	Private _cInd := CriaTrab(Nil, .F.)
	IndRegua("TRB", _cInd, "CODIGO+ACOND",,, "Selecionando Registros...")

	Processa({|lEnd| TrfAmx()}, 'Gravando Transferências....')
	Return(.T.)

	*
	************************
Static Function TrfAmx()
	************************
	*
	ProcRegua(_nTtReg)
	DbGoTop()

	Do While TRB->(!Eof())
		_cCod   := Left(Alltrim(TRB->CODIGO)+Space(TamSX3("B1_COD")[1]), TamSX3("B1_COD")[1])
		_cAcond := Left(Alltrim(TRB->ACOND)+Space(TamSX3("BF_LOCALIZ")[1]), TamSX3("BF_LOCALIZ")[1])
		_cAcd := TRB->ACOND
		_nQtdTr := 0
		_nQtdDv := 0
		Do While TRB->CODIGO == _cCod .And. TRB->ACOND == _cAcd .And. TRB->(!Eof())
			IncProc()
			_nQtdDv += TRB->TOTAL
			TRB->(DbSkip())
		EndDo

		SB1->(DbSeek(xFilial("SB1")+_cCod,.F.))

		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If DbSeek(xFilial("SBF")+"05"+_cAcond+_cCod,.F.)
			_nQtdTr := Min((SBF->BF_QUANT-SBF->BF_EMPENHO),_nQtdDv)
		EndIf
		_nQtdDv := (_nQtdDv - _nQtdTr)

		For _nVez := 1 to 3
			If _nVez <= 2 .And. _nQtdTr == 0
				Loop
			ElseIf _nVez == 3 .And. _nQtdDv == 0
				Exit
			EndIf

			If !SB2->(DbSeek(xFilial("SB2")+_cCod+If(_nVez==1,"05","01"),.F.))
				CriaSB2(_cCod,If(_nVez==1,"05","01"))
			EndIf
			RecLock("SB2",.F.)

			If _nVez # 2
				cNumSeq := ProxNum()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega o proximo numero sequencial de movimento      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SD3",.T.)
			_nRegSD3 := SD3->(Recno())
			SD3->D3_FILIAL  := xFilial("SD3")
			SD3->D3_TM      := If(_nVez==1,"999",If(_nVez==2,"499","110"))
			SD3->D3_COD     := _cCod
			SD3->D3_UM      := SB1->B1_UM
			SD3->D3_QUANT   := If(_nVez==3,_nQtdDv,_nQtdTr)
			SD3->D3_CF      := If(_nVez==1,"RE4",If(_nVez==2,"DE4","DE0"))
			SD3->D3_LOCAL   := If(_nVez==1,"05","01")
			SD3->D3_EMISSAO := dDataBase
			SD3->D3_NUMSEQ  := cNumSeq
			SD3->D3_TIPO    := SB1->B1_TIPO
			SD3->D3_USUARIO := cUserName
			SD3->D3_CHAVE   := If(_nVez==1,"E0",If(_nVez==1,"E9","E0"))
			SD3->D3_GRUPO   := SB1->B1_GRUPO
			SD3->D3_STSERV  := "1"
			SD3->D3_SEGUM   := SB1->B1_SEGUM
			SD3->D3_CONTA   := SB1->B1_CONTA

			If _nVez==1 // Estou processando a saída
				SD3->D3_LOCALIZ := _cAcond
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega os 15 custos medios atuais            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o custo da movimentacao              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCusto := GravaCusD3(aCM)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
			SB1->(MsUnLock())
			SB2->(MsUnLock())
			SBF->(MsUnLock())
			SD3->(MsUnLock())
			SDA->(MsUnLock())

			If _nVez > 1 // Estou processando a entrada
				// Efetua a distribuição das quantidades.
				SD3->(DbGoTo(_nRegSD3))

				DbSelectArea("SDA")
				DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
				If DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
					If SDA->DA_SALDO > 0
						_RegSDA := Recno()
						aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
						{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
						{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
						{"DA_DATA"    ,SDA->DA_DATA                , nil},;
						{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
						{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
						{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
						{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
						{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
						{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}

						aITENS:={{{"DB_ITEM"    , "0001"           , nil},;
						{"DB_LOCALIZ" , _cAcond                    , nil},;
						{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
						{"DB_DATA"    , SDA->DA_DATA               , nil},;
						{"DB_ESTORNO" ," "                         , nil} }}

						msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
					EndIf
				EndIf
			EndIf
		Next
	EndDo
	Return(.T.)
	*
	// Ponto de entrada da rotina MATA250 para estornar
	// os consumos de materiais das produções efetuadas
	// por esta rotina.
	// Retornar .T. ou .F. se a rotina deve ou não efetuar o estorno.
	************************
User Function MT250EST()
	************************
	*
	Local _lVolta := .T.

	Local _cArea := GetArea()
	Local _cAreaD3

	If !"CONS REALIZADO CDEST04X" $ SD3->D3_HIST // Não alterar esta expressão - tem validação em outro lugar
		Return(.T.)
	EndIf

	// Efetuar estorno dos consumos automáticos
	DbSelectArea("SD3")
	_cAreaD3 := GetArea()
	DbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
	_D3_OP := SD3->D3_OP
	_D3_HIST := SD3->D3_HIST
	DbSeek(xFilial("SD3") + _D3_OP,.F.)
	Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_OP == _D3_OP .And. SD3->(!Eof())
		If SD3->D3_HIST == _D3_HIST .And. Empty(SD3->D3_ESTORNO) .And. SD3->D3_CF == "RE0"
			_nRegAtu := SD3->(Recno())
			SD3->(DbSkip())
			_nRegPrx := SD3->(Recno())
			SD3->(DbGoTo(_nRegAtu))

			cD3Seq	:=	SD3->D3_NUMSEQ
			_aVetor :=  {{"D3_NUMSEQ",cD3Seq,NIL},;
						{"INDEX"  	 ,4		,NIL}}

			_cLangAtu := __LANGUAGE
			If AllTrim(GetMv("MV_ESTNEG")) == "N"
				__LANGUAGE := "ENGLISH"
			EndIf

			lMsErroAuto 	:= .F.
			MSExecAuto({|x,y| mata240(x,y)},_aVetor,5)
			If __LANGUAGE # _cLangAtu
				__LANGUAGE := _cLangAtu
			EndIf
			If lMsErroAuto
				Alert("Erro no estorno do consumo.")
				_lVolta := .F.
				Exit
				//MostraErro()
			Else
				//MsgBox("BMM não excluido, estrutura não encontrada!", "Atencao:", "INFO")
			EndIf

			DbSelectArea("SD3")
			DbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
			SD3->(DbGoTo(_nRegPrx))
		Else
			SD3->(DbSkip())
		EndIf
	EndDo
	RestArea(_cAreaD3)
	RestArea(_cArea)

Return(_lVolta)