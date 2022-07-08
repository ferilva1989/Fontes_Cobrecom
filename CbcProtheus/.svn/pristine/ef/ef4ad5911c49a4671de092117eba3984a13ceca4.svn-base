#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDBAL01                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 04/09/2008   //
//                                                                          //
//   Objetivo ...: Importar dados da Balança e Tratá-los fazendo tb as produ//
//                 coes automaticas.                                        //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////


/*/{Protheus.doc} CDBAL01
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
User Function CDBAL01() // Veja também a u_função CDBL01_a() abaixo.... Juliana
	local i	  := 0
	cCadastro := "Cadastro de Pesagens"

	aCores    := {	{"ZL_STATUS=='A'","ENABLE"  },;   // Verde    - Pesagem a Processar
	{"ZL_STATUS=='P'","BR_AZUL" },;   // Azul     - Pesagem Processada
	{"ZL_STATUS=='E'","BR_LARANJA" },;// Laranja  - Pesagem com erro
	{"ZL_STATUS=='Q'","BR_PRETO" },;  // Preto    - Em Avaliação no CQ
	{"ZL_STATUS=='Z'","BR_AMARELO" },;// Preto    - Em Processamento
	{"ZL_STATUS $'cC'","DISABLE"}}     // Vermelho - Pesagem Cancelada

	PswOrder(2)
	lAchou 		:= PSWSeek(cUserName)
	aUserCB 	:= PswRet(1)
	lOk 		:= .F.
	lAdmin		:= .F.
	lLabor		:= .F.

	If lAchou
		//Percorre todos os grupos do usuario autorizado a cancelar a pesagem
		For i := 1 To Len(aUserCB[1][10])
			If aUserCB[1][10][i] == "000075"
				lOk := .T.
			EndIf
			If aUserCB[1][10][i] == "000000"
				lAdmin := .T.
			EndIf
			If aUserCB[1][10][i] == "000023"
				lLabor := .T.
			EndIf
		Next
	EndIf

	If lAdmin
		aRotina := {{ "Pesquisar"   , "AxPesqui"      ,0,1},;
			{ "Visualizar"  , "AxVisual"      ,0,2},;
			{ "Importar"    , "U_CDBALIM()"   ,0,3},;
			{ "Cancelar"    , "U_CDBALCA(0)"  ,0,4},;  // Pode cancelar tudo
		{ "Libera Blq." , "U_CDBALCA(2)"  ,0,4},;  // Libera os Bloqueados
		{ "Selecionar"  , "U_CDBALCL()"   ,0,4},;
			{ "Processar"   , "U_CDBALPR(.F.)",0,4},;
			{ "Integra WMS" , "StaticCall(CDBAL03, IntegWMS,.T.)"     , 0 , 4  },;
			{ "Legenda"     , "U_CDBALLE"     ,0,2}}
	ElseIf lOk
		// Atenção... a restrição de processamento do Rene foi feito na chamada da função principal para CDBL01_a()
		aRotina := {{ "Pesquisar"   , "AxPesqui"      ,0,1},;
			{ "Visualizar"  , "AxVisual"      ,0,2},;
			{ "Importar"    , "U_CDBALIM()"   ,0,3},;
			{ "Cancelar"    , "U_CDBALCA(0)"  ,0,4},;  // Pode cancelar tudo
		{ "Selecionar"  , "U_CDBALCL()"   ,0,4},;
			{ "Processar"   , "U_CDBALPR(.F.)",0,4},;
			{ "Integra WMS" , "StaticCall(CDBAL03, IntegWMS,.T.)"     , 0 , 4  },;
			{ "Legenda"     , "U_CDBALLE"     ,0,2}}
	ElseIf lLabor
		aRotina := {{ "Pesquisar"   , "AxPesqui"    , 0 , 1	},;
			{ "Visualizar"  , "AxVisual"    , 0 , 2	},;
			{ "Cancelar"    , "U_CDBALCA(0)", 0 , 4	},;  // Pode cancelar somente os bloqueados
		{ "Libera Blq." , "U_CDBALCA(2)", 0 , 4	},;  // Libera os Bloqueados
		{ "Integra WMS" , "StaticCall(CDBAL03, IntegWMS,.T.)"     , 0 , 4  },;
		{ "Legenda"     , "U_CDBALLE"   , 0 , 2 }}
	Else
		aRotina := {{ "Pesquisar"   , "AxPesqui"      ,0,1},;
			{ "Visualizar"  , "AxVisual"      ,0,2},;
			{ "Importar"    , "U_CDBALIM()"   ,0,3},;
			{ "Selecionar"  , "U_CDBALCL()"   ,0,4},;
			{ "Processar"   , "U_CDBALPR(.F.)",0,4},;
			{ "Integra WMS" , "StaticCall(CDBAL03, IntegWMS,.T.)"     , 0 , 3  },;
			{ "Legenda"     , "U_CDBALLE"     ,0,2}}
	EndIf

	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
	DbSeek(xFilial("SZL"),.F.)

	mBrowse(001,040,200,390,"SZL",,,,,,aCores)

Return(.T.)

	*
	************************
User Function CDBL01_a()
	************************
	*
	cCadastro := "Cadastro de Pesagens"

	aCores    := {	{"ZL_STATUS=='A'","ENABLE"  },;   // Verde    - Pesagem a Processar
	{"ZL_STATUS=='P'","BR_AZUL" },;   // Azul     - Pesagem Processada
	{"ZL_STATUS=='E'","BR_LARANJA" },;// Laranja  - Pesagem com erro
	{"ZL_STATUS=='Q'","BR_PRETO" },;  // Preto    - Em Avaliação no CQ
	{"ZL_STATUS=='Z'","BR_AMARELO" },;
		{"ZL_STATUS=='C'","DISABLE"}}     // Vermelho - Pesagem Cancelada

	aRotina := {{ "Pesquisar"   , "AxPesqui"      , 0 , 1 },;
		{ "Visualizar"  , "AxVisual"      , 0 , 2 },;
		{ "Legenda"     , "U_CDBALLE"     , 0 , 2 }}

	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
	DbSeek(xFilial("SZL"),.F.)

	mBrowse(001,040,200,390,"SZL",,,,,,aCores)

Return(.T.)


/*/{Protheus.doc} CDBALLE
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
User Function CDBALLE()
	BrwLegenda(cCadastro,"Legenda",{{"ENABLE"		,"Pesagem a Processar"},;
		{"BR_AZUL"		,"Pesagem Pocessada"},;
		{"BR_LARANJA"	,"Erro no Processamento"},;
		{"BR_PRETO"		,"Em Avaliação no CQ"},;
		{"BR_AMARELO"	,"Em Processamento"},;
		{"DISABLE"		,"Pesagem Cancelada"}})
Return(.T.)


/*/{Protheus.doc} CDBALIM
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
User Function CDBALIM()
	If MsgBox("Confirma Importação das Pesagens?","Confirma?","YesNo")
		_TrshBob := ""
		_aNroPes := {}
		Processa({ || ImporCol(.T.)}) // Importa dados do coletor... Bobinas recebidas.
		If Len(_TrshBob) > 0
			_TrshBob := Substr(_TrshBob,3,Len(_TrshBob)-2)
			Alert("Bobinas que foram transferidas mais de uma vez:" + Chr(13)+Chr(13)+_TrshBob)
		EndIf
		Alert("Término do Processamento!")
	EndIf
Return(.T.)


/*/{Protheus.doc} CDBALCA
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined
@param _nOpc, , descricao
@type function
/*/
User Function CDBALCA(_nOpc)
// _nOpc = 0 Cancela Tudo // 1 Cancela Bloq.Labor. // 2 Libera Bloq. Laborat.
	Local _aArea

	_aArea := GetArea()
	If SZL->ZL_STATUS == "C"
		Alert("A Pesagem " + SZL->ZL_NUM + " Já Foi Cancelada!")
	ElseIf SZL->ZL_STATUS == "P"
		Alert("Pesagem Já Processada!")
	ElseIf SZL->ZL_STATUS $ ("A//E") .And. _nOpc == 0 .And. ;
			MsgBox("Confirma o Cancelamento da Pesagem " + SZL->ZL_NUM +"?","Confirma?","YesNo")
		u_CancSZL(.T.) // Cancelar o SZL
		Alert("Cancelamento Efetuado")
	ElseIf SZL->ZL_STATUS == "Q" .And. _nOpc <  2 .And. ;
			MsgBox("Confirma o Cancelamento da Pesagem " + SZL->ZL_NUM +"?","Confirma?","YesNo")
		u_CancSZL(.T.) // Cancelar o SZL
		Alert("Cancelamento Efetuado")
	ElseIf SZL->ZL_STATUS == "Q" .And. _nOpc == 2 .And. ;
			MsgBox("Confirma a Liberação da Pesagem " + SZL->ZL_NUM +"?","Confirma?","YesNo")
		u_CancSZL(.F.) // Liberar o SZL para processamento
		Alert("Liberação Efetuada")
	EndIf
	RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} CDBALPR
//TODO Descrição auto-gerada.
@author juliana.leme
@since 22/12/2016
@version undefined
@param _lMArk, , descricao
@type function
/*/
User Function CDBALPR(_lMArk)
	Private oAppOri := oApp

	DbSelectArea("SZL")
	_aArea := GetArea()

	//_dUltPrc := If Getmv("MV_PROCPES") // 10/10/13 10:45 Processamento de pesagens... permitir somente 1 por vez
	// Criar um arquivo e tratar somente um registro com o nome do usuário
	// e não deixar mais de um processar simultâneo

	If dDataBase <= Getmv("MV_ULMES") .Or. dDataBase <= Getmv("MV_DBLQMOV")
		Alert("Posicione Data Base Posterior a Data do Último Fechamento")
		Return(.T.)
	EndIf
	//_aAccess := u_CtrlAccess("B","CDBALPR",cUserName) // Bloqueia/Libera controle de acesso da rotina
	//Bloqueia Rotina em uso
	If !LockByName("CDBALPR_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		Return
	EndIf

	If MsgBox("Confirma Processamento das Pesagens?","Confirma?","YesNo")
		DbSelectArea("SZL")
		_aAreaPR := GetArea()
		_lSai := .T.
		Do While _lSai
			Processa({ || U_ProcesBal(_lMArk,"Z")})
		EndDo
		RestArea(_aAreaPR)
		Alert("Término do Processamento!")
	EndIf

	oApp := oAppOri

	If _lMArk
		CLOSEBROWSE()
	EndIf

	// Libera o controle de rotinas
	//_aAccess := u_CtrlAccess("L","CDBALPR",cUserName) // Bloqueia/Libera controle de acesso da rotina
	UnLockByName("CDBALPR_"+cFilAnt,.F.,.F.,.T.)

	DbSelectArea("SZL")
	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} ProcesBal
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/12/2016
@version undefined
@param _lMArk, , descricao
@param _cLetra, , descricao
@param _cModo, , descricao
@param cNumPes, characters, descricao
@type function
/*/
User Function ProcesBal(_lMArk,_cLetra,_cModo,cNumPes)//Modo M=Manual//C=Coletor cNumPes fornecido pelo coletor
	Local _cMV_PAR01	:= ""
	Local _cMV_PAR02	:= ""
	Local _cMV_PAR03	:= ""
	Local aColPes 		:= '{"COLETAS": ['
	Local oReq			:= Nil
	Local cUser			:= cFilAnt
	Local _lNumPesg		:= .F.
	Local aPergs   		:= {}
	Local aRet	   		:= {}
	Default _cModo 		:= "M"
	Default cNumPes		:= ""

	If  _cModo == "M"
		If !_lMArk
			cPerg := "CDBAL1"
			ValidPerg()
			If !Pergunte(cPerg,.T.)
				_lSai := .F.
				Return(.T.)
			EndIf
		EndIf
		_cMV_PAR01 := MV_PAR01
		_cMV_PAR02 := MV_PAR02
		_cMV_PAR03 := MV_PAR03
	Else
		_cMV_PAR01 := cNumPes
		_cMV_PAR02 := cNumPes
		_cMV_PAR03 := ""
	EndIf

	DbSelectArea("SZE")
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSelectArea("SZL")
	//SZL->(DbSetOrder(3)) //ZL_FILIAL+ZL_STATUS+ZL_NUMOP
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM

	If _lMArk // Se a rotina foi chamada pelo MarkBrowse, está com filtro e não vai visualisar o Status "Z"
		Set Filter to // Então desfaço o filtro
	EndIf

	If Empty(_cMV_PAR01)
		_lSai := .F.
		Return(.T.)
	EndIf

	_nQtd := 0
	//Posiciona SZL
	DbSeek(xFilial("SZL")+ _cMV_PAR01,.T.)

	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. +;
			SZL->ZL_NUM >= _cMV_PAR01 .And. SZL->ZL_NUM <= _cMV_PAR02 .And. SZL->(!Eof())

		If (SZL->ZL_NUM $ _cMV_PAR03) .Or. ! (SZL->ZL_STATUS $ "AE")
			SZL->(DbSkip())
			Loop
		Else
			_lNumPesg := .T.
			aColPes += '{"COD": "00000' + SZL->ZL_NUM + '","USR": "' + cUser + '"}'
			aColPes += ',' // Continua
		EndIf
		SZL->(DbSkip())
	EndDo
	If _lNumPesg
		//Processa Pesagens pela rotina do coletor no ProcesBalCol
		aColPes := Left(aColPes,Len(aColPes)-1) + ']}'
		If FWJsonDeserialize(aColPes, @oReq)
			If U_PrBalCol(oReq:COLETAS,cUser)
				Alert("Processamento Concluido!")
			Else
				Alert("Procesamento com Erro, Favor verificar!")
			EndIf
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/12/2016
@version undefined

@type function
/*/
Static Function ValidPerg()
	local i	:= 0
	_aArea := GetArea()

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Pesagem Nro.              ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate a Pesagem Nro.           ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Desconsiderar Pesagens?      ?","mv_ch3","C",20,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})

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
		ElseIf i == 3
			RecLock("SX1",.F.)
			SX1->X1_CNT01   := "             "
			MsUnlock()
		Endif
	Next

	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} CrieZe
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined
@param _cStatus, , descricao
@param _cFilOrig, , descricao
@param _cFunc, , descricao
@type function
/*/
Static Function CrieZe(_cStatus,_cFilOrig,_cFunc)

	// Gravar o SZE -> Controle de Bobinas
	_lVolte := .T.
	If _cStatus # "R"
		If SZL->ZL_PEDIDO # "000001" // Este If tem que estar aqui dendro do outro porque só tenho SZL nessa condição.
			If SC6->C6_NUM # SZL->ZL_PEDIDO
				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				DbSeek(xFilial("SC6")+SZL->ZL_PEDIDO,.F.)
			EndIf

			If SA1->A1_COD+SA1->A1_LOJA # SC6->C6_CLI + SC6->C6_LOJA
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				DbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA,.F.)
			EndIf
		EndIf
	EndIf
	DbSelectArea("SZE")
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	If _cStatus == "I" // Bobina Via SZL
		If DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.)
			RecLock("SZE",.F.)
			If SZE->ZE_STATUS == "R"
				If SZE->ZE_PEDIDO == "000001"
					SZE->ZE_STATUS  := "T"
				Else
					SZE->ZE_STATUS  := "P"
				EndIf
			EndIf
		Else
			RecLock("SZE",.T.)
			SZE->ZE_FILIAL  := xFilial("SZE")
			SZE->ZE_NUMBOB  := SZL->ZL_NUMBOB
			SZE->ZE_STATUS  := _cStatus
		EndIf
		SZE->ZE_CLIENTE := SC6->C6_CLI
		SZE->ZE_LOJA    := SC6->C6_LOJA
		SZE->ZE_NOMCLI  := If(SZL->ZL_PEDIDO=="000001","ESTOQUE",SA1->A1_NOME)
		SZE->ZE_PEDIDO  := SZL->ZL_PEDIDO
		SZE->ZE_ITEM    := SZL->ZL_ITEMPV
		SZE->ZE_DESTINO := If(SZL->ZL_PEDIDO=="000001","ESTOQUE",AllTrim(SA1->A1_MUN)+"-"+SA1->A1_EST)
		SZE->ZE_PRODUTO := SZL->ZL_PRODUTO
		SZE->ZE_DESCPRO := SZL->ZL_DESC
		SZE->ZE_QUANT   := SZL->ZL_METROS
		SZE->ZE_LOTE    := SZL->ZL_LOTE
		SZE->ZE_DATA    := SZL->ZL_DATA
		SZE->ZE_TPBOB   := SZL->ZL_TPBOB
		SZE->ZE_TARA    := SZL->ZL_EMB //  A TARA NA BOBINA É O PESO DA EMBALAGEM
		SZE->ZE_PESO    := SZL->ZL_PBRUT-SZL->ZL_TARA
		SZE->ZE_PLIQ    := SZL->ZL_PBRUT-SZL->ZL_TARA-SZL->ZL_EMB
		SZE->ZE_DESVIO  := SZL->ZL_DESVIO
		SZE->ZE_FUNC    := SZL->ZL_OPER
		SZE->ZE_NOME    := SZL->ZL_NOMOPER
		SZE->ZE_OP      := SZL->ZL_NUMOP
		SZE->ZE_DTPES   := Date()
		SZE->ZE_HRPES   := Left(TIME(),Len(SZE->ZE_HRPES))
		MsUnLock()
	ElseIf _cStatus == "R" // Bobina Via Coletor - Recebida
		DbSelectArea("SZE")
		SZE->(DbSetOrder(6)) // ZE_FILORIG+ZE_NUMBOB
		If DbSeek(_cFilOrig+_cnBob,.F.) // Procuro pela filial de origem
			If SZE->ZE_STATUS == "I"
				RecLock("SZE",.F.)
				SZE->ZE_FILIAL := xFilial("SZE")
				SZE->ZE_STATUS  := If(SZE->ZE_PEDIDO=="000001","T","P")
				MsUnLock()

				DbSelectArea("SZL")
				_ZLaArea := GetArea()
				DbSetOrder(4) // ZL_FILIAL+ZL_NUMBOB
				DbSeek(xFilial("SZL")+SZE->ZE_NUMBOB,.F.)
				If SZL->(!Eof()) .And.  SZL->ZL_STATUS == "Q" //
					MsgAlert("A bobina " + _cnBob + " foi recebida mas a pesagem " + SZL->ZL_NUM + " está bloqueada no CQ. Verifique com o CQ","Atenção!")
				EndIf
				RestArea(_ZLaArea)
				DbSelectArea("SZE")

			ElseIf !SZE->ZE_STATUS $ "TP" .Or. SZE->ZE_DTREC < Date() // Faturada ou Cancelada
				_lVolte := .F.
			EndIf
		Else
			RecLock("SZE",.T.)
			SZE->ZE_FILIAL  := _cFilOrig // xFilial("SZE")
			SZE->ZE_NUMBOB  := _cnBob
			SZE->ZE_STATUS  := _cStatus
			SZE->ZE_FILORIG := _cFilOrig // Filial de origem da bobina
			MsUnLock()
		EndIf
		If _lVolte
			RecLock("SZE",.F.)
			SZE->ZE_DTREC   := Date()
			SZE->ZE_HRREC   := Left(TIME(),Len(SZE->ZE_HRREC))
			If Empty(SZE->ZE_FUNCEXP)
				SZE->ZE_FUNCEXP := _cFunc
			EndIf
			MsUnLock()
		EndIf
	Else
		If DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.)
			RecLock("SZE",.F.)
			SZE->ZE_STATUS  := _cStatus
			MsUnLock()
		EndIf
	EndIf
Return(_lVolte)

User Function DistrSZB(_Loclz)
	Local _Loclz
	Default _Loclz := "  "

	// Tem que vir com o SDA posicionado
	If SDA->DA_SALDO = 0 // Não tem nada a distribuir
		Return(.T.)
	EndIf

	DbSelectArea("SDB")
	SDB->(DbSetOrder(1)) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
	DbSeek(xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ,.F.)
	_cItemDb := StrZero(0,Len(SDB->DB_ITEM))
	Do While SDB->DB_FILIAL==xFilial("SDB") .And. SDB->(!Eof()) .And. ;
			SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ == SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ

		If SDB->DB_ITEM > _cItemDb
			_cItemDb := SDB->DB_ITEM
		EndIf
		SDB->(DbSkip())
	EndDo
	_cItemDb := Soma1(_cItemDb)

	If Empty(_Loclz)
		_cLocaliz := SZL->ZL_ACOND+StrZero(SZL->ZL_LANCE,5)
	Else
		_cLocaliz := _Loclz
	EndIf
	_cLocaliz := PadR(_cLocaliz,TamSX3("BE_LOCALIZ")[1])

	If Empty(_Loclz)
		DbSelectArea("SBE")
		SBE->(DbSetOrder(1))
		If !DbSeek(xFilial("SBE") + SDA->DA_LOCAL + _cLocaliz,.F.)
			If SZL->ZL_ACOND == "T"
				_cDesLo :=  "Retalho de "
			ElseIf SZL->ZL_ACOND == "B"
				_cDesLo :=  "Bobina de "
			ElseIf SZL->ZL_ACOND == "M"
				_cDesLo :=  "Carretel de Mad.de "
			ElseIf SZL->ZL_ACOND == "C"
				_cDesLo :=  "Carretel de "
			ElseIf SZL->ZL_ACOND == "R"
				_cDesLo :=  "Rolo de "
			ElseIf SZL->ZL_ACOND == "L"
				_cDesLo :=  "Blister de "
			EndIf

			//_cDesLo +=  Str(SZL->ZL_LANCE,5) + " metros"
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SDA->DA_PRODUTO,.F.))
			_cDesLo +=  Str(SZL->ZL_LANCE,5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")

			RecLock("SBE",.T.)
			SBE->BE_FILIAL   := xFilial("SBE")
			SBE->BE_LOCAL    := SDA->DA_LOCAL
			SBE->BE_LOCALIZ  := _cLocaliz
			SBE->BE_DESCRIC  := _cDesLo
			SBE->BE_PRIOR    := "ZZZ"
			SBE->BE_STATUS   := "1"
			MsUnLock()
		EndIf
	EndIf

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


	aITENS:={{	{"DB_ITEM"    , _cItemDb                   , nil},;
		{"DB_LOCALIZ" , _cLocaliz                  , nil},;
		{"DB_QUANT"   , If(Empty(_Loclz),_QtDistr,SDA->DA_SALDO), nil},;
		{"DB_DATA"    , dDataBase                  , nil},;
		{"DB_ESTORNO" ," "                         , nil} }}

	lMsErroAuto := .F.
	msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)

	If Select("TB_CB") > 0 // Abriu o arquivo
		// O execauto destrava todos os registros de todos os arquivos dá MsUnLockAll
		// e eu preciso desse cara sempre travado
		DbSelectArea("TB_CB")
		RecLock("TB_CB",.F.)
	EndIf

	If lMsErroAuto
		MOSTRAERRO()
		lMsErroAuto := .F.
		RecLock("SZL",.F.)
		SZL->ZL_STATUS := "N"
		MsUnLock()
	ElseIf !("PROD_PCF" $ _Loclz)
		RecLock("SZL",.F.)
		SZL->ZL_QTDISTR := SZL->ZL_QTDISTR + _QtDistr
		If SZL->ZL_QTDISTR == SZL->ZL_METROS
			RecLock("SZL",.F.)
			SZL->ZL_STATUS := "P"
			MsUnLock()
		EndIf
		//Baixa UnMov no PCF
		If ! Empty(SZL->ZL_UNMOV)
			U_PCFBxUnMov(xFilial("SZL"),SZL->ZL_UNMOV,SZL->ZL_NUM)
		EndIf
	Else
		RecLock("SZL",.F.)
		SZL->ZL_STATUS := "A"
		MsUnLock()
	EndIf
Return(.T.)


/*/{Protheus.doc} TemSaldo
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
Static Function TemSaldo()
	_lTemTudo := .T.
	_cLocOrig := Left(GetMv("MV_LOCRET")+"  ",2)
	_cEndOrig := Left(GetMv("MV_ENDRET")+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))
	If !Empty(SZB->ZB_BMMORIG)
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(1)) // ZZE_FILIAL+ZZE_ID
		ZZE->(DbSeek(xFilial("ZZE")+SZB->ZB_BMMORIG,.F.))
		_cEndOrig := Left(ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5)+Space(Len(SZB->ZB_LOCALIZ)),Len(SZB->ZB_LOCALIZ))

		_nSldZZE := (ZZE->ZZE_TOTEN - ZZE->ZZE_QTDPRO)

		_nQtdTira := Min(_nSldZZE,_nQtdTira)
		// Isto ocorre quando a quantidade total devolvida é maior que a quantidade enviada para retrabalho

		RecLock("ZZE",.F.)
		ZZE->ZZE_QTDPRO := ZZE->ZZE_QTDPRO + _nQtdTira
		MsUnLock()

		If _nQtdTira > _nSldZZE
			_nQtdTira := Max(_nSldZZE,0)
		EndIf
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SZB->ZB_PRODUTO,.F.))
	If SB1->B1_LOCALIZ =="S"
		DbSelectArea("SBF")
		SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If DbSeek(xFilial("SBF")+_cLocOrig+_cEndOrig+SZB->ZB_PRODUTO,.F.)
			RecLock("SBF",.F.) // Primeiro dou o RecLock pra ninguem mexer no registro
			//		If SZB->ZB_QUANT  <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0
			If _nQtdTira  <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0
				// Ainda tenho a quantidade disponível
				//			SBF->BF_EMPENHO += SZB->ZB_QUANT
				SBF->BF_EMPENHO += _nQtdTira
				MsUnLock()
			Else  // Se não tenho quantidade disponivel...
				MsUnLock()
				_lTemTudo := .F.
			EndIf
		Else
			_lTemTudo := .F.
		EndIf
	Else
		// Veririfar no SB2
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))//B2_FILIAL+B2_COD+B2_LOCAL
		If DbSeek(xFilial("SB2")+SZB->ZB_PRODUTO+_cLocOrig,.F.)
			RecLock("SB2",.F.)
			If SZB->ZB_QUANT  <= (SB2->B2_QATU - SB2->B2_RESERVA) // Ainda tenho a quantidade disponível
				SB2->B2_RESERVA += SZB->ZB_QUANT
				MsUnLock()
			Else  // Se não tenho quantidade disponivel...
				MsUnLock()
				_lTemTudo := .F.
			EndIf
		Else
			_lTemTudo := .F.
		EndIf
	EndIf
Return(_lTemTudo)


/*/{Protheus.doc} ImporCol
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined
@param lForma, logical, descricao
@type function
/*/
Static Function ImporCol(lForma)
	local _nArqs	:= 0
	local _nVez		:= 0
	Local lForma // .T. pela rotina de importação de bobinas, então a variável 	_aNroPes := {} existe

	If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Itu
		_cPasta := "\COLETORES\"
	ElseIf FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas

		// Copiar do Drive D: para o servidor na pasta \COLET3L

		aFilesMs := Array(ADIR("D:\COLETORES\INVENT*.T?T"))
		ADIR("D:\COLETORES\INVENT*.T?T",aFilesMs)
		For _nArqs := 1 to Len(aFilesMS)
			IncProc()
			_cArqOrig := "D:\COLETORES\" + AllTrim(aFilesMS[_nArqs])
			CPYT2S(_cArqOrig,"\COLET3L\",.F.)
			DELETE FILE &_cArqOrig.
		Next

		aFilesMs := Array(ADIR("D:\COLETORES\BOBINAS*.TXT"))
		ADIR("D:\COLETORES\BOBINAS*.TXT",aFilesMs)
		For _nArqs := 1 to Len(aFilesMS)
			IncProc()
			_cArqOrig := "D:\COLETORES\" + AllTrim(aFilesMS[_nArqs])
			CPYT2S(_cArqOrig,"\COLET3L\",.F.)
			DELETE FILE &_cArqOrig.
		Next
		_cPasta := "\COLET3L\"
	EndIf

	aStruTrb := {}
	AADD(aStruTrb,{"CAMPO","C",40,0} ) // Tipo do registro

	cNomTrb0 := CriaTrab(aStruTrb)
	dbUseArea(.T.,,cNomTrb0,"TRBBAL01",.F.,.F.) // Abre o arquivo de forma exclusiva

	For _nVez := 1 to 2
		DbSelectArea("TRBBAL01")
		Zap //

		If _nVez == 1 // Forma Antiga
			aFiles := ARRAY(ADIR(_cPasta + "INVENT*.TX?"))
			ADIR(_cPasta + "INVENT*.TX?",aFiles)
			If Len(aFiles) <= 0
				Loop
			EndIf
			DbSelectArea("TRBBAL01")
			ProcRegua(Len(aFiles))
			For _nArqs := 1 to Len(aFiles)
				IncProc()
				_cArqT := _cPasta + aFiles[_nArqs]
				Append from &_cArqT. SDF
				DbGoBottom()
				_cContag := Substr(TRBBAL01->CAMPO,01,01)
				If !(Substr(TRBBAL01->CAMPO,09,04) $ "8000/9601/9602" .And. _cContag == "9") // Não é transferência de Bobinas - não interessa aqui
					_cArqR := Left(_cArqT,Len(_cArqT)-3)+"TIT" //
				Else
					_cArqR := Left(_cArqT,Len(_cArqT)-3)+"OLB"
				EndIf
				Rename &(_cArqT) to &(_cArqR)
			Next
			_cMens := "Processando Dados dos Coletores"
			DbSelectArea("SB1")
			SB1->(DbSetOrder(5)) //B1_FILIAL+B1_CODBAR

			DbSelectArea("TRBBAL01")
			ProcRegua(LastRec())
			DbGoTop()
			Do While TRBBAL01->(!Eof())
				IncProc()
				_cContag := Substr(TRBBAL01->CAMPO,01,01)
				If !(Substr(TRBBAL01->CAMPO,09,04) $ "8000/9601/9602" .And. _cContag == "9") // Não é transferência de Bobinas - não interessa aqui
					TRBBAL01->(DbSkip())
					Loop
				EndIf
				_cnBob := Substr(TRBBAL01->CAMPO,13,07)
				If Substr(TRBBAL01->CAMPO,09,04) $ "/9601/9602"
					_cFilOrig := Substr(TRBBAL01->CAMPO,11,02)
				Else
					_cFilOrig := xFilial("SZE")
				EndIf
				If !CrieZe("R",_cFilOrig," ") // ok
					_TrshBob := _TrshBob + ", " + _cnBob
				EndIf
				DbSelectArea("TRBBAL01")
				TRBBAL01->(DbSkip())
			EndDo
		Else // Forma Nova
			aFiles := ARRAY(ADIR(_cPasta + "BOBINAS*.TXT"))
			ADIR(_cPasta + "BOBINAS*.TXT",aFiles)
			If Len(aFiles) <= 0
				Loop
			EndIf
			DbSelectArea("TRBBAL01")

			ProcRegua(Len(aFiles))
			For _nArqs := 1 to Len(aFiles)
				IncProc()
				_cArqT := _cPasta + aFiles[_nArqs]
				Append from &_cArqT. SDF
				_cArqR := Left(_cArqT,Len(_cArqT)-3)+"OLB"
				Rename &(_cArqT) to &(_cArqR)
			Next
			_cMens := "Processando Dados dos Coletores"
			DbSelectArea("SB1")
			SB1->(DbSetOrder(5)) //B1_FILIAL+B1_CODBAR

			/*/
			Agora a estrutura é:

			UUU 96 FF BBBBBBBD QQQ     onde:

			UUU     - Cód. Usuário 			96      - Fixo 96
			FF      - Filial de Origem			BBBBBBB - Nro da Bobina
			D       - DAC do cód de barras		QQQ     - Quantidade (neste arquivo será desprezado)

			OU

			UUU 8000 BBBBBBBD QQQ		onde:

			UUU - Cód. Usuário					8000 - Fixo 8000
			BBBBBBB - Nro da Bobina			D - DAC do cód de barras
			QQQ - Quantidade (neste arquivo
			será desprezado)

			/*/
			DbSelectArea("TRBBAL01")
			ProcRegua(LastRec())
			DbGoTop()
			Do While TRBBAL01->(!Eof())
				IncProc()
				// É bobina ?
				If Substr(TRBBAL01->CAMPO,04,04) $ "8000/9600/9601/9602"
					_cFunc := Left(TRBBAL01->CAMPO,3)
					_cnBob := Substr(TRBBAL01->CAMPO,08,07)
					If Substr(TRBBAL01->CAMPO,04,04) $ "/9601/9602"
						_cFilOrig := Substr(TRBBAL01->CAMPO,06,02)
					Else
						_cFilOrig := xFilial("SZE")
					EndIf
					If !CrieZe("R",_cFilOrig," ") // ok
						_TrshBob := _TrshBob + ", " + _cnBob
					EndIf
				EndIf
				DbSelectArea("TRBBAL01")
				TRBBAL01->(DbSkip())
			EndDo
		EndIf
	Next
	DbSelectArea("TRBBAL01")
	DbCloseArea("TRBBAL01")
	cNomTrb0 := cNomTrb0 + ".*"
	Delete File &cNomTrb0.
Return(.T.)


/*/{Protheus.doc} ProcSZE
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ProcSZE()
	local _nxPosic	:= 0
	local _nGrava	:= 0
	local _nBobs	:= 0
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))  //C5_FILIAL+C5_NUM

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SC9")
	DBOrderNickName("SC9BLQ") // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM

	DbSelectArea("SBF")
	SBF->(DbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SZE")
	SZE->(DbSetOrder(3)) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
	ProcRegua(LastRec())
	DbSeek(xFilial("SZE")+"P",.F.)
	Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS == "P" .And. SZE->(!Eof())
		SC5->(DbSeek(xFilial("SC5")+SZE->ZE_PEDIDO,.F.))
		aBobs := {} // 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
		_cChave := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM
		Do While SZE->ZE_FILIAL = xFilial("SZE") .And. SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM == _cChave .And. SZE->(!Eof())
			IncProc()
			If SC5->C5_ZSTATUS $ "29" //OK-  .And. !GetMv("MV_ZZUSAC9")	// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento; 9-Faturando
				SZE->(DbSkip())
				Loop
			EndIf
			_nPosic := 0
			For _nxPosic := 1 to Len(aBobs) // 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
				If aBobs[_nxPosic,1] == SZE->ZE_PRODUTO .And. aBobs[_nxPosic,2] == SZE->ZE_PEDIDO .And.;
						aBobs[_nxPosic,3] == SZE->ZE_ITEM    .And. aBobs[_nxPosic,4] == StrZero(SZE->ZE_QUANT,5)
					_nPosic := _nxPosic
					Exit
				EndIf
			Next
			If _nPosic == 0
				AADD(aBobs,{SZE->ZE_PRODUTO,SZE->ZE_PEDIDO,SZE->ZE_ITEM,StrZero(SZE->ZE_QUANT,5),0,""})
				_nPosic := Len(aBobs)
			EndIf
			aBobs[_nPosic,5] += SZE->ZE_QUANT
			aBobs[_nPosic,6] := aBobs[_nPosic,6] + SZE->ZE_NUMBOB
			SZE->(DbSkip())
		EndDo
		_cChave := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM // Quardo a chave do registro atual
		For _nBobs := 1 to Len(aBobs) // Se tenho o que Ver

			//Monta a variável da localização
			_cLocaliz := Left(("B" + aBobs[_nBobs,4] + Space(300)),Len(SBF->BF_LOCALIZ))

			DbSelectArea("SBF")
			SBF->(DbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If SBF->(DbSeek(xFilial("SBF")+"01"+_cLocaliz+aBobs[_nBobs,1],.F.)) //BF_FILIAL+SBF->(BF_LOCAL+BF_LOCALIZ+BF_PRODUTO)+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				If (SBF->BF_QUANT-SBF->BF_EMPENHO) > 0 .And. SBF->BF_EMPENHO >= 0 // Dá pra fazer alguma liberação?
					Reclock("SBF",.F.)
					_nQtdRes := (SBF->BF_QUANT-SBF->BF_EMPENHO)
					SBF->BF_EMPENHO := SBF->BF_QUANT
					MsUnLock()

					// 	Aglutinar SC9
					SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					SC9->(DbSeek(xFilial("SC9")+aBobs[_nBobs,2]+aBobs[_nBobs,3],.F.))
					_nQtdSC9 := 0
					_cSeq := ""
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == aBobs[_nBobs,2]+aBobs[_nBobs,3] .And. SC9->(!Eof())
						If (SC9->C9_BLCRED + SC9->C9_BLEST) == "  02"
							_nQtdSC9 += SC9->C9_QTDLIB
							If Empty(_cSeq)
								_cSeq := SC9->C9_SEQUEN
							Else
								RecLock("SC9",.F.)
								SC9->(DbDelete())
								MsUnLock()
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo

					// Grava a quantidade total em um único SC9
					SC9->(DbSeek(xFilial("SC9")+aBobs[_nBobs,2]+aBobs[_nBobs,3],.F.))
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == aBobs[_nBobs,2]+aBobs[_nBobs,3] .And. SC9->(!Eof())
						If (SC9->C9_BLCRED + SC9->C9_BLEST) == "  02" .And. SC9->C9_SEQUEN == _cSeq
							If SC9->C9_QTDLIB # _nQtdSC9
								RecLock("SC9",.F.)
								SC9->C9_QTDLIB := _nQtdSC9
								MsUnLock()
							EndIf
						EndIf
						SC9->(DbSkip())
					EndDo

					DbSelectArea("SC9")
					DBOrderNickName("SC9BLQ") // C9_FILIAL + C9_BLCRED + C9_BLEST+C9_PEDIDO+C9_ITEM

					// aBobs = 1-PRODUTO 2-PEDIDO 3-ITEM 4-METRAGEM 5-QUANTIDADE 6-NRO DAS BOBINAS - Esta variárel representa o que TENHO a liberar
					_nLib := Min(aBobs[_nBobs,5],(_nQtdRes)) // Pelo saldo, quanto dá pra liberar?

					If SC9->(DbSeek(xFilial("SC9") + "  02" + aBobs[_nBobs,2] + aBobs[_nBobs,3],.F.))
						_nALib := Min(_nLib,SC9->C9_QTDLIB) // Esta Linha estava marcada com "//"
						//		        	_nALib := _nLib
						_nDaPra := Int(_nALib / aBobs[_nBobs,5])
						_nALib := _nDaPra*aBobs[_nBobs,5]
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
							U_CDLibEst("L",SC9->C9_PRODUTO,_nALib,SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"A")

							//Gravar os Registros do SZE como liberados
							_BobsGrv := AllTrim(aBobs[_nBobs,6])
							DbSelectArea("SZE")
							SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
							For _nGrava := 1 to _nDaPra
								_nNumBob := Left(_BobsGrv,7)
								If Len(_BobsGrv) == 7
									_BobsGrv := ""
								Else
									_BobsGrv := Substr(_BobsGrv,8,Len(_BobsGrv)-7)
								EndIf
								If SZE->(DbSeek(xFilial("SZE")+_nNumBob,.F.))
									RecLock("SZE",.F.)
									SZE->ZE_DTLIB := Date()
									SZE->ZE_HRLIB := Left(Time(),Len(SZE->ZE_HRLIB))
									SZE->ZE_STATUS := "E" //Empenhado
									MsUnLock()
								EndIf
								If Empty(_BobsGrv)
									Exit
								EndIf
							Next

						EndIf
					EndIf
					If _nQtdRes > 0.00
						Reclock("SBF",.F.)
						SBF->BF_EMPENHO -= _nQtdRes
						MsUnLock()
					EndIf
				EndIf
			EndIf
		Next
		DbSelectArea("SZE")
		SZE->(DbSetOrder(3)) //ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
		DbSeek(xFilial("SZE") + _cChave,.F.) //  := SZE->ZE_STATUS+SZE->ZE_PEDIDO+SZE->ZE_ITEM // Quardo a chave do registro atual
	EndDo
Return(.T.)


/*/{Protheus.doc} CDBALCL
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
User Function CDBALCL()
	cPerg := "CDBAL1"
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return(.T.)
	EndIf

	Private cCadastro
	Private aRotina
	_My_MVPAR01 := MV_PAR01
	lInverte:=.F.
	cMarca := GetMark()
	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
	Set Filter to ZL_STATUS == "A" .And. ZL_NUM >= MV_PAR01 .And. ZL_NUM <= MV_PAR02
	DbSeek(xFilial("SZL")+MV_PAR01,.F.)
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM <= MV_PAR02 .And. SZL->(!Eof())
		RecLock("SZL",.F.)
		SZL->ZL_OK := cMarca
		DbSkip()
	EndDo

	cCadastro:="Seleção e Processamento de Pesagens"
	aRotina := {{ "Pesquisar" ,"AxPesqui" , 0 , 1},;
		{ "Visualizar","u_VisuSZL", 0 , 2},;
		{ "Processar" ,"u_CDBALPR(.T.)", 0 , 2}}

	DbSelectArea("SZL")
	MarkBrow("SZL","ZL_OK","ZL_NUMBMM",,@lInverte,@cMarca,,,,,) // ZL_NUMBMM só para poder marcar o item... nada a ver
	DbSelectArea("SZL")
	Set Filter to
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
	DbSeek(xFilial("SZL")+_My_MVPAR01,.T.)
Return(.T.)


/*/{Protheus.doc} VisuSZL
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined

@type function
/*/
User Function VisuSZL()
	AxVisual("SZL",Recno(),2)
Return(.T.)


/*/{Protheus.doc} ProcBal03
//TODO Descrição auto-gerada.
@author juliana.leme
@since 10/01/2017
@version undefined
@param MV_PAR01, , descricao
@param MV_PAR02, , descricao
@param _cLetra, , descricao
@param MV_PAR03, , descricao
@type function
/*/
User Function ProcBal03(MV_PAR01,MV_PAR02,_cLetra,MV_PAR03)
	// Esta Rotina é usada como "ponte" da rotina CDBAL03() para que todos os
	// processamentos sejam realizados por somente uma Função, a ProcesaBal()
	Processa({ || U_ProcesBal(.F.,"","C",MV_PAR01)})
Return(.T.)


User Function CancSZL(_lCancel)
	// _lCancel - .T.=Cancela ou .F.=Libera para Processamento
	Local oStatic    := IfcXFun():newIfcXFun()

	_NumPes := SZL->ZL_NUM
	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) // ZL_FILIAL+ZL_NUM+SZL->ZL_ITEM
	DbSeek(xFilial("SZL")+_NumPes,.F.)
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _NumPes .And. SZL->(!Eof())
		RecLock("SZL",.F.)
		If _lCancel // A pesagem está sendo cancelada
			_lCq := (SZL->ZL_STATUS == "Q")
			SZL->ZL_STATUS := "C"
			//		SZL->ZL_COMENTS := "CANCELADA POR:"+cUserName
			MsUnLock()
			If SZL->ZL_TIPO == "R"
				BxRet(.F.,_lCq) // caso tenha retrabalho oficial PCP deve estornar ZZE __ROBERT__
			EndIf
			If !Empty(SZL->ZL_NUMBOB)
				SZE->(DbSetOrder(1))
				SZE->(DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.))
				If !SZE->(Eof())
					RecLock("SZE",.F.)
					SZE->ZE_STATUS := "C"
					MsUnLock()
					// Procuro a tabela SZ9-Complemento da OP para atualizar a quantidade de bobinas e metragem já PRODUZIDAS
					DbSelectArea("SZ9")
					SZ9->(DbSetOrder(7)) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
					If DbSeek(xFilial("SZ9")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,.F.)
						RecLock("SZ9",.F.)
						SZ9->Z9_QTDETQ := SZ9->Z9_QTDETQ - 1
						SZ9->Z9_QTDMTS := Max((SZ9->Z9_QTDMTS - SZE->ZE_QUANT),0)
						MsUnLock()
					EndIf
				EndIf
			EndIf
		Else // Liberação da pesagem do CQ para processamento
			SZL->ZL_STATUS := "A"
			SZL->ZL_USLIBCQ := cUserName
			SZL->ZL_DTLIBCQ := dDataBase
			MsUnLock()
			If SZL->ZL_TIPO == "R"
				BxRet(.T.,.T.) // caso tenha retrabalho oficial PCP deve estornar ZZE __ROBERT__
			EndIf
			oStatic:sP(1):callStatic('CDBAL03', 'IntegWMS')
		EndIf
		SZL->(DbSkip())
	EndDo
	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) // ZL_FILIAL+ZL_NUM+SZL->ZL_ITEM
	DbSeek(xFilial("SZL")+_NumPes,.F.)
Return(.T.)

/*/{Protheus.doc} BxRet
//TODO Descrição auto-gerada.
@author juliana.leme
@since 25/07/2016
@version undefined
@param lAprovado, logical, descricao
@param lCq, logical, descricao
@type function
/*/
Static Function BxRet(lAprovado,lCq) // caso tenha retrabalho oficial PCP deve estornar ZZE
	Local lOk
	Default lCq := .F.

	If !Empty(SZL->ZL_ZZEID)
		ZZE->(dbsetorder(2)) // FILIAL + ID + PEDIDO + ITEM PV
		If lAprovado
			lOk := U_BAL03ZZE({SZL->ZL_ZZEID,SZL->ZL_QTLANCE,SZL->ZL_METROS,SZL->ZL_ACOND,SZL->ZL_PEDIDO,SZL->ZL_ITEMPV,;
				SZL->ZL_PRODUTO},.T.,.T.,.F.) // BAIXAR RETRABALHO PROATIVA
		Else
			lOk := U_BAL03ZZE({SZL->ZL_ZZEID,SZL->ZL_QTLANCE,SZL->ZL_METROS,SZL->ZL_ACOND,SZL->ZL_PEDIDO,SZL->ZL_ITEMPV,;
				SZL->ZL_PRODUTO},.F.,lCq,.F.) // BAIXAR RETRABALHO PROATIVA
		EndIf
	EndIf
Return nil


/*/{Protheus.doc} CBCDevSuc
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/12/2016
@version undefined
@param cTM, characters, descricao
@param cProduto, characters, descricao
@param nQtde, numeric, descricao
@param cDoc, characters, descricao
@param cLocal, characters, descricao
@type function
/*/
User Function CBCDevSuc(cTM,cProduto,nQtde,cDoc,cLocal)
	aItens 	:= {{"D3_TM"		,Padr(cTM,TamSX3("D3_TM")[1])	 							,NIL},; //TP.MOVIM.
	{"D3_COD" 		,Padr(Alltrim(cProduto),TamSX3("D3_COD")[1])				,NIL},; //D3_COD
	{"D3_DOC"		,Padr(Alltrim(cDoc),TamSX3("D3_DOC")[1])					,NIL},;
		{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+Alltrim(cProduto),"B1_UM"),NIL},;
		{"D3_LOCAL" 	,Padr(cLocal,TamSX3("D3_LOCAL")[1])							,NIL},;
		{"D3_LOCALIZ" 	,""															,NIL},;
		{"D3_QUANT" 	,Round(ABS(nQtde),4)										,NIL},;
		{"D3_HIST" 		,"DEV. PESAGEM SUCATA CDBAL03"							  	,NIL},;
		{"D3_OP" 		,""															,NIL},;
		{"D3_EMISSAO" 	,dDataBase											  	   	,NIL},;
		{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])						   	,NIL},;
		{"D3_ZZLOTE" 	,""			   												,NIL},;
		{"D3_ZZUNMOV" 	,0															,NIL}}

	lMsErroAuto 	:= .F.
	MSExecAuto({|x,y| mata240(x,y)},aItens,3)

	If lMsErroAuto
		//Ver o que fazer
	EndIf
Return


/*/{Protheus.doc} CtrlAccess
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/05/2017
@version undefined
@param cModo, characters, descricao
@param cRotina, characters, descricao
@param cUserNm, characters, descricao
@type function
/*/
User Function CtrlAccess(cModo,cRotina,cUserNm)
	Local cModo     // B-loqueia / L-ibera / C-onsulta
	Local cRotina := Left((AllTrim(cRotina)+Space(15)),15)  // Rotina/Função a ser tratada
	Local cUserNm := Left((AllTrim(cUserNm)+Space(20)),20)// Usuário
	Local _cNomeArq, _cNomArq, _lTemFil
	Local _aArea := GetArea()

	If Select("TB_CB") == 0 // Tabela não está aberta
		_cNomeArq := "CDBAL"+SM0->M0_CODIGO+".DTC"
		If !File(_cNomeArq)
			aStruTrb := {}
			AADD(aStruTrb,{"FILIAL" ,"C",02,0} )
			AADD(aStruTrb,{"ROTINA" ,"C",15,0} )
			AADD(aStruTrb,{"USUARIO","C",20,0} )
			AADD(aStruTrb,{"EM_USO" ,"L",01,0} )
			_cNomArq := AllTrim(CriaTrab(aStruTrb, .T.)) + ".DTC"
			Rename &(_cNomArq) to &(_cNomeArq)
		EndIf

		DbUseArea(.T.,,_cNomeArq, "TB_CB",.T.,.F.) // Abre o arquivo de forma compartilhada
	EndIf
	_aVolta := {} // ok-?, Usuário
	_lTemFil := .F.
	DbSelectArea("TB_CB")
	DbGoTop()
	Do While TB_CB->(!Eof())
		If TB_CB->FILIAL == FWCodFil() .And. TB_CB->ROTINA == cRotina
			_lTemFil := .T.
			If cModo == "B" // Bloqueio
				If TB_CB->EM_USO
					_aVolta := {.F.,TB_CB->USUARIO} // ok-?, Usuário
					Exit
				ElseIf RecLock("TB_CB",.F.)
					TB_CB->EM_USO := .T.
					TB_CB->USUARIO := cUserNm
					MsUnLock()
					_aVolta := {.T.,TB_CB->USUARIO} // ok-?, Usuário
					Exit
				Else
					_aVolta := {.F.,TB_CB->USUARIO} // ok-?, Usuário
					Exit
				EndIf
			ElseIf cModo == "L" .And. (TB_CB->USUARIO == cUserNm .Or. !TB_CB->EM_USO)// Solicitado desbloqueio -> Mesmo usuário?
				If RecLock("TB_CB",.F.)
					TB_CB->EM_USO := .F.
					TB_CB->USUARIO := "  "
					MsUnLock()
					_aVolta := {.T.,TB_CB->USUARIO} // ok-?, Usuário
					Exit
				Else
					_aVolta := {.F.,TB_CB->USUARIO} // ok-?, Usuário
					Exit
				EndIf
			ElseIf cModo == "C" .And. !TB_CB->EM_USO
				_aVolta := {.T.,TB_CB->USUARIO} // Retorna como se estivesse bloqueando
			Else
				_aVolta := {.F.,TB_CB->USUARIO} // ok-?, Usuário
				Exit
			EndIf
		EndIf
		TB_CB->(DbSkip())
	EndDo

	If !_lTemFil
		If cModo $ "LC" // Liberação
			_aVolta := {.T.,TB_CB->USUARIO} // ok-?, Usuário
		ElseIf	RecLock("TB_CB",.T.)
			TB_CB->FILIAL := FWCodFil()
			TB_CB->ROTINA := cRotina
			TB_CB->EM_USO := .T.
			TB_CB->USUARIO := cUserNm
			MsUnLock()
			_aVolta := {.T.,TB_CB->USUARIO} // ok-?, Usuário
		Else
			_aVolta := {.F.,"  "} // ok-?, Usuário
		EndIf
	EndIf

	If cModo == "L" // Liberação
		// Só fecho a tabela se for uma liberação
		// Senão mantenho aberta para que não seja deletada
		If Select("TB_CB") > 0 // Abriu o arquivo
			DbSelectArea("TB_CB")
			DbCloseArea()
		EndIf
	EndIf
	RestArea(_aArea)
Return(_aVolta)
