#include "rwmake.ch"
#include "protheus.ch"


/*/{Protheus.doc} CDFAT02
//TODO	Liberar o P.V. para alteração/exclusão pelo PCP quando
		este já estiver programado na produçã.
@author zzz
@since 04/07/2006 
@version undefined

@type function
/*/
User Function CDFAT02()
	Private cUserAtu := Alltrim(cUserName)+"|"
	Private cUserLib := GetMv("MV_USERLIB")
	Private cUserAdm := GetMv("MV_USERADM")
	Private aHeader, aCols
	
	_CondPode := ".T."
	If cModulo == "EST"
		cCadastro := "Liberação de Pedidos Para Alterar/Excluir"
		If !Alltrim(cUserName)+"|" $ cUserLib
			_CondPode := "!Empty(SC5->C5_SEMANA)"
		EndIf
		
		aCores    := {	{"!Empty(C5_SEMANA) .And. C5_DTPCP==Date()","ENABLE"  },;  // Verde - Liberado para Alteração
						{"Empty(C5_SEMANA)"                        ,"BR_AZUL" },;  // Não Programado
						{"!Empty(C5_SEMANA)"                       ,"DISABLE"}}    // Vermelho - Bloqueado para Alteração
		
		aRotina := {{ "Pesquisar"   , "AxPesqui"  , 0 , 1	},;
					{ "Visualizar"  , "U_CDFAT02V(.T.)", 0 , 4	},;
					{ "Liberar"     , "U_CDFAT02L", 0 , 4	},;
					{ "Legenda"     , "U_CDFAT02X", 0 , 2 }}
		
	ElseIf cModulo == "FAT" .And. Alltrim(cUserName)+"|" $ cUserLib
		cCadastro := "Renegociação, Liberação, Alterar Regras de Desconto"
		//If Alltrim(Upper(cUserName)) # "DANIELA"
		//	_CondPode := "!Empty(SC5->C5_SEMANA)"
		//EndIf
		
		aCores    := {	{"!Empty(C5_SEMANA) .And. C5_DTPCP==Date()","ENABLE"  },;  // Verde - Liberado para Alteração
						{"Empty(C5_SEMANA)"                        ,"BR_AZUL" },;  // Não Programado
						{"!Empty(C5_SEMANA)"                       ,"DISABLE"}}    // Vermelho - Bloqueado para Alteração
		
		aRotina := {{ "Pesquisar"    , "AxPesqui"       , 0 , 1	},;
					{ "Visualizar"   , "U_CDFAT02V(.T.)", 0 , 4	},;
					{ "Renegociar"   , "U_CDFAT02A"     , 0 , 4	},;
					{ "Liberar PV"   , "U_CDFAT02L"     , 0 , 4	},;
					{ "Liberar Regra", "U_CDFAT02T"     , 0 , 4	},;
					{ "Legenda"      , "U_CDFAT02X"     , 0 , 2 }}
		
	ElseIf cModulo == "FAT" .And. cUserAtu $ cUserLib
		cCadastro := "Liberação de Regras de Desconto"
		_CondPode := "C5_TIPO=='N' .And. !Empty(C5_AUTORIZ)"
		
		aCores    := {	{"Left(SC5->C5_AUTORIZ,7)=='Lib.por'.Or.  Empty(C5_AUTORIZ)"  ,"ENABLE"   },;  // Verde - Liberado
						{"Left(SC5->C5_AUTORIZ,7)<>'Lib.por'.And. !Empty(C5_AUTORIZ)" ,"BR_PRETO" }}   // Preto - Necessario Liberar
		
		aRotina := {{ "Pesquisar"   , "AxPesqui"  , 0 , 1	},;
					{ "Visualizar"  , "U_CDFAT02V(.T.)", 0 , 4	},;
					{ "Liberar"     , "U_CDFAT02T", 0 , 4	},;
					{ "Legenda"     , "U_CDFAT02X", 0 , 2 }}
		_cFiltro := "Left(C5_AUTORIZ,7)<>'Lib.por' .And. !Empty(C5_AUTORIZ)"
		DbSelectArea("SC5")
		DbSetOrder(1)
		Set Filter to &(_cFiltro)
		If !dbSeek(xFilial("SC5"),.F.)
			Alert("Não há P.V a serem liberados")
			Set Filter to
			Return(.T.)
		Endif
	
	ElseIf cModulo == "FAT"
		cCadastro := "Renegociação de Pedidos de Vendas"
		_CondPode := "(Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA)) .Or. (!Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA))"
		
		If SC5->(FieldPos("C5_BLQ")) == 0
			_CondPode := "(Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA)) .Or. (!Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA))"
			aCores := {	{"Empty(C5_LIBEROK).And.Empty(C5_NOTA)",'ENABLE' },;		//Pedido em Aberto
						{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E'",'DISABLE'},;		   	//Pedido Encerrado
						{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA)",'BR_AMARELO'}}	//Pedido Liberado
		Else
			aCores := {	{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
						{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		   	//Pedido Encerrado
						{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;
						{ "C5_BLQ == '1'",'BR_AZUL'},;	//Pedido Bloquedo por regra
						{ "C5_BLQ == '2'",'BR_LARANJA'}}	//Pedido Bloquedo por verba
		Endif
		
		aRotina := {{ "Pesquisar"   , "AxPesqui"  , 0 , 1	},;
					{ "Visualizar"  , "U_CDFAT02V(.T.)", 0 , 4	},;
					{ "Renegociar"  , "U_CDFAT02A", 0 , 4	},;
					{ "Legenda"     , "U_CDFAT02X", 0 , 2 }}
	Else
		Alert("Rotina Não Executada em Outro Módulo")
		Return(.T.)
	EndIf
		
	DbSelectArea("SC5")
	DbSeek(xFilial("SC5"),.F.)
		
	mBrowse(001,040,200,390,"SC5",,,,,,aCores)
	Set Filter to //Sempre desativar filtro após mBrowse
	
Return(.T.)
	

/*/{Protheus.doc} CDFAT02X
//TODO Descrição auto-gerada.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function CDFAT02X()
	Local aLegen := {}
	If cModulo == "FAT"
		If SC5->(FieldPos("C5_BLQ")) == 0
			aLegen := {	{"ENABLE","Pedido em aberto"},;     //
						{"DISABLE","Pedido encerrado"},;   //
						{"BR_AMARELO","Pedido liberado"}}
		ElseIf SC5->(!Empty("C5_AUTORIZ"))//Edvar
			aLegen := {	{"ENABLE"  ,"Pedido Liberado"},;
						{"BR_PRETO","P.V Bloqueado por Tabela"}}
		Else
			aLegen := {	{"ENABLE","Pedido em aberto"},;      //Pedido em aberto
						{"DISABLE","Pedido encerrado"},;    //Pedido encerrado
						{"BR_AMARELO","Pedido liberado"},;
						{"BR_AZUL","Pedido Bloqueado por regra"},;
						{"BR_LARANJA","Pedido Bloqueado por verba"}}
		EndIf
		BrwLegenda(cCadastro,"Legenda",aLegen)
	Else
		BrwLegenda(cCadastro,"Legenda",{{"ENABLE"  ,"Liberado para Alteração"},;
										{"BR_AZUL" ,"Pedido Sem Resumo de Produção"},;
										{"DISABLE" ,"Bloqueado Para Alteração"}})
	EndIf
Return(.T.)


/*/{Protheus.doc} CDFAT02V
//TODO Visualizar.
@author zzz
@since 14/07/2017
@version undefined
@param _lSeePrice, , descricao
@type function
/*/
User Function CDFAT02V(_lSeePrice)
	cOpcao	:=	"VISUALIZAR"	
	U_CDMONTA(_lSeePrice)
Return(.T.)


/*/{Protheus.doc} CDFAT02L
//TODO Liberar.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function CDFAT02L() 
	cOpcao:="LIBERAR"
	U_CDMONTA(.T.)
Return(.T.)


/*/{Protheus.doc} CDFAT02A
//TODO Renegociar.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function CDFAT02A() // 
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
				{ "Visualizar", "AxVisual", 0 , 2	},;
				{ "Incluir"   , "AxInclui", 0 , 3	},;
				{ "Renegociar", "AxAltera", 0 , 4	}}
		
	cOpcao:="RENEGOCIAR"
	
	U_CDMONTA(.T.)
	
	aRotina := {{ "Pesquisar"   , "AxPesqui"  , 0 , 1	},;
				{ "Visualizar"  , "U_CDFAT02V(.T.)", 0 , 4	},;
				{ "Renegociar"  , "U_CDFAT02A", 0 , 3	},;
				{ "Legenda"     , "U_CDFAT02X", 0 , 2 }}
Return(.T.)


/*/{Protheus.doc} CDFAT02T
//TODO Bloqueia Tabela.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function CDFAT02T() // EDVAR
	cOpcao:="BLQTABELA"
	
	U_CDMONTA(.T.)
Return(.T.)


/*/{Protheus.doc} CDFAT02F
//TODO Rotina chamada por CsFatur().
@author zzz
@since 14/07/2017
@version undefined
@param _Quem, , descricao
@type function
/*/
User Function CDFAT02F(_Quem) // 
	local aMyRotina := {}

	if Type("aRotina") <> "U"
		if !empty(aRotina)
			aMyRotina := AClone(aRotina)
		endif
	endif	
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
				{ "Visualizar", "AxVisual", 0 , 2	},;
				{ "Incluir"   , "AxInclui", 0 , 3	},;
				{ "Faturar"   , "AxAltera", 0 , 4	}}
	
	cOpcao:="FATURAR"
	_cQuem := _Quem
	
	U_CDMONTA(.T.)

	if !empty(aMyRotina)
		aRotina := AClone(aMyRotina)
	endif
Return(.T.)


/*/{Protheus.doc} CDMONTA
//TODO FUNCAO QUE MONTA A TELA CONTRATO DE VENDA.
@author zzz
@since 14/07/2017
@version undefined
@param _lSeePrice, , descricao
@type function
/*/
User Function CDMONTA(_lSeePrice) 
	Local aSize			:= {}
	Local aPosObj		:= {}
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local _cItenPV		:= ""
	Private cUserAtu 	:= Alltrim(cUserName)+"|"
	Private cUserLib 	:= GetMv("MV_USERLIB")
	Private cUserAdm 	:= GetMv("MV_USERADM")
	Private n			:= 1
	
	If cOpcao $ "ALTERAR//RENEGOCIAR//LIBERAR//BLQTABELA" .And. !(&_CondPode.)		
		Alert("Pedido não apto para a função")
		Return(.T.)
	EndIf
	if  !Empty(C5_X_IDVEN)  
		 if cOpcao != 'LIBERAR' .And. cOpcao != 'FATURAR' 
		 	Alert("Pedidos MultiFilial apenas disponivel opção Liberar alteração de vendas")
		 	Return(.T.)
		 endif
	endif	
		
	aSize := MsAdvSize()
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 015, .t., .f. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
	nGetLin := aPosObj[3,1]
	
	Do Case
		Case cOpcao $ "VISUALIZAR//LIBERAR"        ; nOpcE:=2 ; nOpcG:=2  //Visualizar
		Case cOpcao $ "ALTERAR//RENEGOCIAR/FATURAR"; nOpcE:=3 ; nOpcG:=3  //Classificar
		Case cOpcao=="EXCLUIR"                     ; nOpcE:=2 ; nOpcG:=2  //Excluir
	EndCase
		
	//³ Cria variaveis M->????? da Enchoice                          ³
	If !_lSeePrice
		M->C5_NUM     := SC5->C5_NUM
		M->C5_TIPO    := SC5->C5_TIPO
		M->C5_CLIENTE := SC5->C5_CLIENTE
		M->C5_LOJACLI	:= SC5->C5_LOJACLI
		//Alterado conforme solicitação da Vania 25/08/2016
		If ! (cOpcao $ "FATURAR")
			//Juliana 18/07/2016
			M->C5_CLIENT	:= SC5->C5_CLIENT
			M->C5_LOJAENT	:= SC5->C5_LOJAENT
			//Fim Juliana
		EndIf
		M->C5_PARCIAL := SC5->C5_PARCIAL
		M->C5_ENTREG  := SC5->C5_ENTREG
		M->C5_TRANSP  := SC5->C5_TRANSP
		M->C5_TIPOCLI := SC5->C5_TIPOCLI
		M->C5_CONDPAG := SC5->C5_CONDPAG
		M->C5_DTFAT   := SC5->C5_DTFAT
		M->C5_PEDCLI  := SC5->C5_PEDCLI
		M->C5_ENDENT1 := SC5->C5_ENDENT1
		M->C5_ENDENT2 := SC5->C5_ENDENT2
		M->C5_OBS     := SC5->C5_OBS
		M->C5_XTELENT := SC5->C5_XTELENT
		M->C5_VEND1   := SC5->C5_VEND1
		M->C5_EMISSAO := SC5->C5_EMISSAO
		M->C5_TPFRETE := SC5->C5_TPFRETE
		M->C5_USERINC := SC5->C5_USERINC
		M->C5_DTINC   := SC5->C5_DTINC
		M->C5_USERALT := SC5->C5_USERALT
		M->C5_DTALT   := SC5->C5_DTALT
		M->C5_SEMANA  := SC5->C5_SEMANA
		M->C5_DTPCP   := SC5->C5_DTPCP
		M->C5_ZSTATUS  := SC5->C5_ZSTATUS
		M->C5_TIPOLIB := SC5->C5_TIPOLIB
	Else
		RegToMemory("SC5",.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SC6")
	aHeader:={}
	
	Do While !Eof().And.(x3_arquivo=="SC6")
		If X3USO(x3_usado) .And. cNivel>=x3_nivel //.And. !AllTrim(x3_campo) $ ""
			nUsado:=nUsado+1
			// O Campo C6_PRCVEN não pode mais ser alterado e o C6_TES só pode ser com o mesmo Financeiro e estoque
			/*/
			If (AllTrim(x3_campo) $ "C6_PRCVEN//C6_TES" .And. cOpcao == "RENEGOCIAR") .Or.;
				(AllTrim(x3_campo) == "C6_TES" .And. cOpcao == "FATURAR")
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,"AllwaysTrue()",;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
				/*/
				//TODO Renegociar Tipo de Operação - Juliana 15/12/2016
			If (AllTrim(x3_campo) == "C6_COMIS1"  .Or. AllTrim(x3_campo) == "C6_PEDCLI"   .Or.;
				AllTrim(x3_campo) == "C6_ITPDCLI" .Or. AllTrim(x3_campo) == "C6_POSHPHU") .And. ;
				cOpcao == "RENEGOCIAR"
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
					
			ElseIf 	(AllTrim(x3_campo) == "C6_TES" .And. cOpcao == "RENEGOCIAR") .Or.;
					(AllTrim(x3_campo) == "C6_TES" .And. cOpcao == "FATURAR")
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,"u_VejaTES()" + If(!Empty(x3_valid), " .and. " + AllTrim(x3_valid),""),;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
					
			ElseIf 	(AllTrim(x3_campo) == "C6_OPER" .And. cOpcao == "RENEGOCIAR") .Or.;
					(AllTrim(x3_campo) == "C6_OPER" .And. cOpcao == "FATURAR")
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
			ElseIf 	(AllTrim(x3_campo) == "C6_DESCONT" .And. cOpcao == "RENEGOCIAR") .Or.;
					(AllTrim(x3_campo) == "C6_DESCONT" .And. cOpcao == "FATURAR")
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )		
			ElseIf 	(AllTrim(x3_campo) == "C6_VALDESC" .And. cOpcao == "RENEGOCIAR") .Or.;
					(AllTrim(x3_campo) == "C6_VALDESC" .And. cOpcao == "FATURAR")
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )		
			Else
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,".F.",;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
			EndIf
		Endif
		DbSkip()
	EndDo
	
	aCols:={}
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!eof())
		_lLista := .F.
		If cOpcao # "FATURAR"
			_lLista := .T.
		ElseIf cOpcao=="FATURAR"
			If SC6->C6_ITEM $ _cQuem
				_lLista := .T.
			EndIf
		EndIf
		If _lLista
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				If ( aHeader[_ni,10] # "V" )
					aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
				Else
					aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
				EndIf
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
		EndIf
		dbSkip()
	EndDo
	
	//TODO Analise do TES
	// Verificar e corrigir o CFOP, se for o caso
	For n := 1 to Len(aCols) // Usar a variável n, mesmo pq a função
		GDFieldPut("C6_CF",u_AvalCFOP(),n)
	Next
	
	n := 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Pedido de Venda - " + cOpcao
	cAliasEnchoice:="SC5"
	cAliasGetD:="SC6"
	cLinOk:="AllwaysTrue()"
	cTudOk:="u_ValCP()" // "AllwaysTrue()"
	cFieldOk:="AllwaysTrue()"
	aCpoEnchoice:={"C5_EMISSAO"}
	lRefresh := .T.
	
	nOpc := If(cOpcao $ "ALTERAR//RENEGOCIAR/FATURAR",4,2)
	nOpcA:= 0
	aAltEnchoice :={}
	
	
	If cOpcao $ "FATURAR/RENEGOCIAR"
		// Alteração Roberto Oliveira 18/08/2016 -> Vânia solicitou para não permitir a alteração quando estiver no faturamento
		If cOpcao $ "/RENEGOCIAR"
			//Alteração Juliana Leme 18/07/2016
			AADD(aAltEnchoice,"C5_CLIENT")
			AADD(aAltEnchoice,"C5_LOJAENT")
			//Fim
		EndIf
		// Fim Alteração Roberto Oliveira 18/08/2016 -> Vânia solicitou para não permitir a alteração quando estiver no faturamento
		AADD(aAltEnchoice,"C5_TIPOCLI")
		AADD(aAltEnchoice,"C5_PARCIAL")
		AADD(aAltEnchoice,"C5_TRANSP")
		AADD(aAltEnchoice,"C5_TPFRETE")
		AADD(aAltEnchoice,"C5_VOLUME1")
		AADD(aAltEnchoice,"C5_VOLUME2")
		AADD(aAltEnchoice,"C5_VOLUME3")
		AADD(aAltEnchoice,"C5_VOLUME4")
		AADD(aAltEnchoice,"C5_ESPECI1")
		AADD(aAltEnchoice,"C5_ESPECI2")
		AADD(aAltEnchoice,"C5_ESPECI3")
		AADD(aAltEnchoice,"C5_ESPECI4")
		AADD(aAltEnchoice,"C5_MENNOTA")
		AADD(aAltEnchoice,"C5_X_MENNF")
		AADD(aAltEnchoice,"C5_MENPAD")
		AADD(aAltEnchoice,"C5_TXDESC")
		AADD(aAltEnchoice,"C5_DCDESC")
		AADD(aAltEnchoice,"C5_PESOBOB")
		AADD(aAltEnchoice,"C5_PEDCLI")
		AADD(aAltEnchoice,"C5_ENDENT1")
		AADD(aAltEnchoice,"C5_ENDENT2")
		AADD(aAltEnchoice,"C5_XTELENT")
		
		If SC5->C5_TXDESC+SC5->C5_DCDESC+SC5->C5_PESOBOB > 0
			RecLock("SC5",.F.)
			SC5->C5_TXDESC  := 0.00
			SC5->C5_DCDESC  := 0.00
			SC5->C5_PESOBOB := 0.00
			MsUnLock()
		EndIf

		// atenÇÃo.. se incluir novos campos aqui... incluir tb linha para gravar no sc5 - (+- linha 322 deste)
	EndIf
	
	If cOpcao == "RENEGOCIAR"
		AADD(aAltEnchoice,"C5_CONDPAG")
		AADD(aAltEnchoice,"C5_OBS")
		AADD(aAltEnchoice,"C5_ENTREG")
		AADD(aAltEnchoice,"C5_DTFAT")
	EndIf
	aTela  :=Array(0,0)
	aGets  :=Array(0)
	
	// Se o SA1 não estiver posicionado não traz o CFOP correto.
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
	
	DbSelectArea("SA4")
	DbSetOrder(1)
	
	DbSelectArea("SC5")
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
	
	EnChoice( "SC5", SC5->(Recno()), nOpc, , , , , aPosObj[1],aAltEnchoice,3,,,"")
	oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,cLinOk,cTudOk,"",.T.,,1,,,,,,)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela), Confirma(), nOpcA := 0)},{|| nOpcA := 0, oDlg:End()})
	
	If nOpcA == 1  // Se confirma
		If cOpcao == "RENEGOCIAR" // Gravar Log do pedido de venda
			_aDadC5 := {M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_ENTREG,M->C5_TIPO}
			AltEnt := .F. // Usar esta rotina somente pelo debug quando houver necessidade.
			If AltEnt
				u_AvalPrz("SC5",,,SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,AltEnt) // Corrige o prazo de entrega
				Return(.T.) // Não faz mais nada
			EndIf
			u_CDGEN21I(15,,,,_aDadC5) // 15-Renegociação Pedidos
		EndIf
		If cOpcao $ "RENEGOCIAR//FATURAR" // Alterar no SC6 e nos SC9 os Preços unitários de venda
			_aDadC5 := {M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_ENTREG,M->C5_TIPO} // Erro Vania pois variavel não existe Juliana
			If cOpcao $ "//FATURAR" // Chamar o evento 16 somente se for faturamento - Variável _nPesos da erro
				u_CDGEN21I(16,,,,_aDadC5) // 16-faturamento - Gravar as alterações que a Vânia fez
			EndIf
			DbSelectArea("SC9")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			If SC5->C5_TIPO $ "N/C/I/P" // Busco o casdastro de Clientes
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
				_cEstCli := SA1->A1_EST
			Else // Cadastro de Fornecedores
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
				_cEstCli := SA2->A2_EST
			EndIf
			
			DbSelectArea("SC6")
			DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				
			//cMV_ESTADO := GetMv("MV_ESTADO")
			
			For ii:=1 to Len(aCols)
				
				_cItenPV := GDFIELDGET("C6_ITEM",ii)
				DbSelectArea("SC6")
				If DbSeek(xFilial("SC6")+SC5->C5_NUM+_cItenPV,.F.)

					RecLock("SC6",.F.)
					SC6->C6_XOPER   := GDFIELDGET("C6_XOPER",ii)
					SC6->C6_TES     := GDFIELDGET("C6_TES",ii)
					SC6->C6_TESORI  := GDFIELDGET("C6_TES",ii)
					SC6->C6_CF      := GDFIELDGET("C6_CF",ii)
					SC6->C6_COMIS1  := GDFIELDGET("C6_COMIS1",ii)
					SC6->C6_CLASFIS := GDFIELDGET("C6_CLASFIS",ii)
					SC6->C6_X_NACIM := GDFIELDGET("C6_X_NACIM",ii)
					SC6->C6_ENTREG  := GDFIELDGET("C6_ENTREG",ii)
					SC6->C6_PEDCLI  := GDFIELDGET("C6_PEDCLI",ii)
					SC6->C6_ITPDCLI := GDFIELDGET("C6_ITPDCLI",ii)
					SC6->C6_POSHPHU := GDFIELDGET("C6_POSHPHU",ii)
					SC6->C6_PRCVEN 	:= GDFIELDGET("C6_PRCVEN",ii)
					SC6->C6_LUCROBR	:= GDFIELDGET("C6_LUCROBR",ii)
					SC6->C6_VALOR	:= GDFIELDGET("C6_VALOR",ii)
					SC6->C6_DESCONT	:= GDFIELDGET("C6_DESCONT",ii)
					SC6->C6_VALDESC	:= GDFIELDGET("C6_VALDESC",ii)

					_cNacImp  := u_CliPed12(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_NUM,SC6->C6_PRODUTO,M->C5_EMISSAO,M->C5_TIPOCLI,SC6->C6_ITEM,SC6->C6_ACONDIC,SC6->C6_METRAGE)
					_cClasFis := Left(_cNacImp,1) + Posicione("SF4",1,xFilial("SF4")+GDFIELDGET("C6_TES",ii),"F4_SITTRIB")
					SC6->C6_CLASFIS := _cClasFis
					SC6->C6_X_NACIM := Right(_cNacImp,1)
					MsUnLock()
					
					// Alterar o TES no SC9
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+SC5->C5_NUM+GDFIELDGET("C6_ITEM",ii),.F.)
					Do While SC9->C9_FILIAL==xFilial("SC9") .And. SC9->C9_PEDIDO==SC5->C5_NUM .And.;
						SC9->C9_ITEM  ==GDFIELDGET("C6_ITEM",ii) .And. SC9->(!Eof())
						If SC9->C9_BLEST # "10"
							RecLock("SC9",.F.)
							SC9->C9_TES    := GDFIELDGET("C6_TES",ii)
							MsUnLock()
						EndIf
						SC9->(DbSkip())
					EndDo
				EndIf
			Next
	
			If cOpcao == "FATURAR"
				_xxx := 1
				/*/
				SC5->C5_MENNOTA := M->C5_MENNOTA
				SC5->C5_X_MENNF := M->C5_X_MENNF
				SC5->C5_PESOL   := M->C5_PESOBOB
				SC5->C5_PBRUTO  := M->C5_PESOBOB
				SC5->C5_PESOBOB := M->C5_PESOBOB
				/*/
			EndIf
			
			RecLock("SC5",.F.)
			SC5->C5_TIPOCLI := M->C5_TIPOCLI
			//Alterado conforme solicitação da Vania  - Juliana Leme 25/08/2016
			If !(cOpcao == "FATURAR")
				//Alteração Juliana 18/07/2016
				SC5->C5_CLIENT	:= M->C5_CLIENT
				SC5->C5_LOJAENT := M->C5_LOJAENT
				//Fim Alteração
			EndIf
			SC5->C5_PARCIAL := M->C5_PARCIAL
			SC5->C5_TRANSP  := M->C5_TRANSP
			SC5->C5_TPFRETE := M->C5_TPFRETE
			SC5->C5_VOLUME1 := M->C5_VOLUME1
			SC5->C5_VOLUME2 := M->C5_VOLUME2
			SC5->C5_VOLUME3 := M->C5_VOLUME3
			SC5->C5_VOLUME4 := M->C5_VOLUME4
			SC5->C5_ESPECI1 := M->C5_ESPECI1
			SC5->C5_ESPECI2 := M->C5_ESPECI2
			SC5->C5_ESPECI3 := M->C5_ESPECI3
			SC5->C5_ESPECI4 := M->C5_ESPECI4
			SC5->C5_MENNOTA := M->C5_MENNOTA
			SC5->C5_X_MENNF := M->C5_X_MENNF
			SC5->C5_MENPAD  := M->C5_MENPAD
			SC5->C5_ENTREG  := M->C5_ENTREG
			SC5->C5_DESCESP := M->C5_DESCESP
			SC5->C5_DESCEQT := M->C5_DESCEQT
			SC5->C5_CONDPAG := M->C5_CONDPAG
			SC5->C5_OBS     := M->C5_OBS
			SC5->C5_XTELENT := M->C5_XTELENT
			SC5->C5_VEND1   := M->C5_VEND1
			SC5->C5_COMIS1  := M->C5_COMIS1
			SC5->C5_VEND2   := M->C5_VEND2
			SC5->C5_COMIS2  := M->C5_COMIS2
			SC5->C5_VEND3   := M->C5_VEND3
			SC5->C5_COMIS3  := M->C5_COMIS3
			SC5->C5_VEND4   := M->C5_VEND4
			SC5->C5_COMIS4  := M->C5_COMIS4
			SC5->C5_VEND5   := M->C5_VEND5
			SC5->C5_COMIS5  := M->C5_COMIS5
			SC5->C5_DCDESC  := M->C5_DCDESC
			SC5->C5_PESOBOB := M->C5_PESOBOB
			SC5->C5_PESOL   := M->C5_PESOL
			SC5->C5_PBRUTO  := M->C5_PESOL+M->C5_PESOBOB
			SC5->C5_TXDESC  := M->C5_TXDESC
			SC5->C5_PEDCLI  := M->C5_PEDCLI
			SC5->C5_ENDENT1 := M->C5_ENDENT1
			SC5->C5_ENDENT2 := M->C5_ENDENT2
			SC5->C5_DTFAT   := M->C5_DTFAT
			MsUnLock()
		ElseIf cOpcao == "LIBERAR" // Gravar C5_DTLBPCP com a data de hoje
			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				If !u_VejaSZ9("V",SC6->C6_NUM, SC6->C6_SEMANA, SC6->C6_ITEM, SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5), SC6->C6_LANCES)
					Exit
				EndIf
				SC6->(DbSkip())
			EndDo
			If SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA))
				Alert("Pedido em Fase de Programação da Produção - Não Pode Ser Alterado!!!")
			ElseIf Alltrim(cUserName)+"|" $ cUserLib
				RecLock("SC5",.F.)
				SC5->C5_DTVEN := Date()
				MsUnLock()
				_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
				u_CDGEN21I(8,,,,_aDadC5) //8-Autoriz.Vendas p/ Alteração
			Else
			RecLock("SC5",.F.)
			SC5->C5_DTPCP := Date()
			MsUnLock()
			_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
			u_CDGEN21I(6,,,,_aDadC5) //6-Autorização PCP p/ Alteração
		EndIf
	ElseIf cOpcao == "BLQTABELA" //Edvar
		If Left(SC5->C5_AUTORIZ,7) <> "Lib.por"
			RecLock("SC5",.F.)
			SC5->C5_AUTORIZ := "Lib.por " + Left(Upper(Alltrim(cUserName)),7)
			MsUnlock()
		Else
			Alert("P.V já liberado")
		EndIf
	EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} Confirma
//TODO Confirma.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
Static Function Confirma
	If cOpcao=="FATURAR"
		// Validar os campos especie/volume/pesobruto/peso liq
		If Empty((M->C5_ESPECI1+M->C5_ESPECI2+M->C5_ESPECI3+M->C5_ESPECI4)) .Or.;
			(M->C5_VOLUME1+M->C5_VOLUME2+M->C5_VOLUME3+M->C5_VOLUME4) == 0
			If !MsgBox("Espécies e/ou Volumes não Informados","Confirma?","YesNo")
				Return(.F.)
			EndIf
		EndIf
		
		// Solicitação Jeferson 06/11/2015 - Se for um TES bloqueado ou estiver usando o TES  505
		// alertar o usuário dessa condição.
		_cMsgBox := ""
		_lSo505 := .T.
		_cTESJaVi := ""
		For _nItCols := 1 to Len(aCols)
			If !GDFIELDGET("C6_TES",_nItCols) $ _cTESJaVi
				_cTESJaVi += GDFIELDGET("C6_TES",_nItCols) + "//"
				If GDFIELDGET("C6_TES",_nItCols) == "505"
					_cMsgBox += "Item " + GDFIELDGET("C6_ITEM",_nItCols) + "Usando TES 505 " + Chr(13)
				ElseIf Posicione("SF4",1,xFilial("SF4")+GDFIELDGET("C6_TES",_nItCols),"F4_MSBLQL") == "1" // Bloqueado
					_cMsgBox += "Item " + GDFIELDGET("C6_ITEM",_nItCols) + " -> Usando TES " + GDFIELDGET("C6_TES",_nItCols) + "Bloqueado" + Chr(13)
					_lSo505 := .F.
				Else // Não é 505 e não está bloqueado
					_lSo505 := .F.
				EndIf
			EndIf
		Next
		If !Empty(_cMsgBox)
			Alert("Uso de TES Bloqueado não Permitido " + Chr(13)  + Chr(13) + _cMsgBox)
			Return(.F.)
		EndIf
		if Empty(Alltrim(M->(C5_TRANSP))) .and. GetNewPar('ZZ_VLDTRAN',.T.)
			MsgAlert('Transportadora é obrigatorio!')
			return(.F.)	
		endif
	EndIf
	nOpcA := 1
	oDlg:End()

Return(.T.)


/*/{Protheus.doc} VejaTES
//TODO Descrição auto-gerada.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function VejaTES()
	// Verificar se o TES é de saída
	_cTpTES := Posicione("SF4",1,xFilial("SF4")+M->C6_TES,"F4_TIPO")
	If _cTpTES # "S" // Pedido usa fornecedor e o TES é de Saída -> não pode
		Alert("Use um TES de Saída")
		Return(.F.)
	EndIf
	
	_cBloq := Posicione("SF4",1,xFilial("SF4")+M->C6_TES,"F4_MSBLQL") == "1"
	If _cBloq // TES bloqueado
		Alert("TES Bloqueado para uso.")
		Return(.F.)
	EndIf
	_cDup1 := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",n),"F4_DUPLIC")
	_cEst1 := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",n),"F4_ESTOQUE")
	_cDup2 := Posicione("SF4",1,xFilial("SF4")+M->C6_TES,"F4_DUPLIC")
	_cEst2 := Posicione("SF4",1,xFilial("SF4")+M->C6_TES,"F4_ESTOQUE")
	If _cDup2 # _cDup1
		Alert(	"Use um TES com o mesmo conceito de financeiro -> Gera Duplicata = " + _cDup1 +Chr(13)+Chr(13)+;
				"Para usar esse TES, utilise a rotina de Alteração de Pedido de Venda")
		Return(.F.)
	ElseIf _cEst2 # _cEst1
		Alert(	"Use um TES com o mesmo conceito de estoque -> Atual. Estoque = " + _cEst1 +Chr(13)+Chr(13)+;
				"Para usar esse TES, utilise a rotina de Alteração de Pedido de Venda")
		Return(.F.)
	EndIf
Return(.T.)


/*/{Protheus.doc} ValCP
//TODO Verifica se a condição de pagamento é mais vantajosa que a anterior.
@author zzz
@since 14/07/2017
@version undefined

@type function
/*/
User Function ValCP()
	If M->C5_CONDPAG # SC5->C5_CONDPAG
		_cVis1 := Upper(Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_AVISTA"))
		_cVis2 := Upper(Posicione("SE4",1,xFilial("SE4")+  M->C5_CONDPAG,"E4_AVISTA"))
		
		_cVis1 := If(Empty(_cVis1),"N",_cVis1)
		_cVis2 := If(Empty(_cVis2),"N",_cVis2)
		
		If _cVis1 # _cVis2
			Alert("Condição de Pagamento Inválida!"+CHR(13)+CHR(13)+"Somente usar cond.pagto. que gerem comissão iguais")
			M->C5_CONDPAG := SC5->C5_CONDPAG
			Return(.F.)
		EndIf
		
		aCond   := Condicao(1000,SC5->C5_CONDPAG,,dDataBase)
		nSomat  := 0
		For nI := 1 to Len(aCond)
			nSomat += (aCond[nI,1] - dDataBase) * aCond[nI,2]
		Next
		nPrazo1 := Int(nSomat / _nTotPV)
		
		aCond   := Condicao(1000,M->C5_CONDPAG,,dDataBase)
		nSomat  := 0
		For nI := 1 to Len(aCond)
			nSomat += (aCond[nI,1] - dDataBase) * aCond[nI,2]
		Next
		nPrazo2 := Int(nSomat / _nTotPV)
		
		If nPrazo2 > nPrazo1
			Alert("Condição de Pagamento Inválida!"+CHR(13)+CHR(13)+"Para usar essa condição, use a rotina de Alt.de Pedidos")
			M->C5_CONDPAG := SC5->C5_CONDPAG
			Return(.F.)
		EndIf
	EndIf
Return(.T.)

//O campo "Fat.a Partir" indica a partir de qual data esse pedido pode ser faturado, mesmo antes da data de entrega.
//Fizemos alteração na rotina de Renegociação, onde é possível alterar essa data, desde que seja menor que a data de entrega.

//Estarei também alterando a rotina de renegociação para permitir alterar a data de entrega desde que a nova data seja maior que a data já cadastrada no pedido.
