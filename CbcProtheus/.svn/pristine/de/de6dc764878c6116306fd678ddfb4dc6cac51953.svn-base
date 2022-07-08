#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

/*/{Protheus.doc} CDBAL03R
//TODO Chamada da Pesagem de ROLOS/CARRETEIS/BLISTER
Alteração em 11/04/11 - A pesagem será imediatamente confirmada no esto//
que quando finalizada. Somete ficará para posterior confirmação quando //
esta estiver fora dos  parâmetros do CQ. Cada um pode confirmar a sua pesagem.

@author Roberto Oliveira 
@since 26/09/2010
@version undefined

@type function
/*/
User Function CDBAL03R()
	Private _cTiAcd	:= "R"
	Private ZL_TIPO	:= ""

	u_CDBAL03("R") // Pesagem de Rolos
Return(.T.)


/*/{Protheus.doc} CDBAL03B
//TODO Chamada da Pesagem de BOBINA.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function CDBAL03B()
	Private _cTiAcd := "B"

	u_CDBAL03("B") // Pesagem de Bobinas
Return(.T.)

/*/{Protheus.doc} CDBAL03S
//TODO Chamada da Pesagem de SUCATA.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function CDBAL03S()
	Private _cTiAcd := "S"

	u_CDBAL03("S") // Pesagem de Sucatas de Cobre

Return(.T.)

/*/{Protheus.doc} CDBAL03
//TODO Inclusão das Pesagens de Bobinas/Rolos/Carretéis.
@author Roberto Oliveira
@since 30/08/2016
@version undefined
@param _cTiAcd, Caracter , Tipo de Pesagens (R=Rolos,B=Bobinas,S=Sucatas)
@type function
/*/
User Function CDBAL03(_cTiAcd)
	Private _nDesMin 		:= -2
	Private _nDesMax 		:= 2
	Public _lTipoPes		:= _cTiAcd

	//Bloqueado para inventario
	If GetMV("MV_BLQINVE")
		Return(.F.)
	EndIf

	aCores    := {	{"ZL_STATUS=='A'","ENABLE"  },;  // Verde    - Pesagem a Processar
	{"ZL_STATUS=='P'","BR_AZUL" },;  // Azul     - Pesagem Processada
	{"ZL_STATUS=='Q'","BR_LARANJA" },;  // LARANJA	   - Pesagem CQ
	{"ZL_STATUS=='C'","DISABLE"}}    // Vermelho - Pesagem Cancelada

	If _cTiAcd == "R" // Rolos e Itu
		cCadastro := "Pesagem de Rolos"
		aRotina := {{ "Pesquisar"        , "AxPesqui"      , 0 , 1	},;
			{ "Visualizar"       , "AxVisual"      , 0 , 2	},;
			{ "Pesar Rolos"      , "U_IncRolo"     , 0 , 3	},;
			{ "Imprimir Boletim" , "U_ImprBol1(1)" , 0 , 3	},;  //U_ImprBol1(1) Grafico //U_IMPRBOLET(1) Matricial
		{ "Legenda"          , "U_CDBAL03LG"   , 0 , 2  },;
			{ "LogoTipo"         , "U_LoadGRF()"   , 0 , 3  },;
			{ "Integra WMS"      , "StaticCall(CDBAL03, IntegWMS,.T.)"   , 0 , 3  }}

		If FWCodEmp()+FWCodFil() == "0101"
			_nDesMin := -3 // Por email de 04/01/13, Wellington solicitou +2 -3
			_nDesMax := 2  // somente para itu
		EndIf
	ElseIf _cTiAcd == "B" // Bobinas

		Private wnrel   := "ETIQUETA"
		Private cString := "ETIQUETA"
		Private aReturn := {"Zebrado",1,"Administracao",1,3,"COM2","",1}
		Private cPorta  := "COM2:9600,E,8,1,P"

		_lResp := .F.

		Do While .T.
			aRet :={}
			aParamBox := {}
			aAdd(aParamBox,{3,"Porta de Impressão..:",2,{"COM1","COM2","LPT1","LPT2","LPT3"},50,"",.F.})
			_lResp := ParamBox(aParamBox, "Informe Porta para Impressão", @aRet)
			If _lResp //.And. aRet[1] $ "COM1/COM2/LPT1/LPT2/LPT3"
				Exit
			EndIf
			Alert("Informe corretamente a porta de impressão " + Chr(13) +;
				"COM1, COM2, LPT1, LPT2 ou LPT3 e" + Chr(13) +;
				"confirme a operação")
		EndDo
		cPorta  := Substr("COM1/COM2/LPT1/LPT2/LPT3/",((aRet[1]-1)*5)+1,4)
		If "COM" $ cPorta
			cPorta  := cPorta + ":9600,E,8,1,P"
		EndIf
		aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}

		cCadastro := "Pesagem de Bobinas"

		If "ADMINISTRADOR" $ Upper(cUserName)
			aRotina := {{ "Pesquisar"        , "AxPesqui"      , 0 , 1	},;
				{ "Visualizar"       , "AxVisual"      , 0 , 2	},;
				{ "Pesar Bobinas"    , "U_IncBobs"     , 0 , 3	},;
				{ "Imprimir Boletim" , "U_IMPRBOLET(1)", 0 , 3	},;
				{ "Imprimir Etiqueta", "U_INewEtBob(1)", 0 , 3	},;
				{ "Etiq.Elektro"     , "U_DigElktro()" , 0 , 3	},;
				{ "Legenda"          , "U_CDBAL03LG"   , 0 , 2  },;
				{ "LogoTipo"         , "U_LoadGRF()"   , 0 , 3  },;
				{ "Integra WMS"      , "StaticCall(CDBAL03, IntegWMS,.T.)" , 0 , 3  }}
		Else
			aRotina := {{ "Pesquisar"        , "AxPesqui"          , 0 , 1	},;
				{ "Visualizar"       , "AxVisual"          , 0 , 2	},;
				{ "Pesar Bobinas"    , "U_IncBobs"         , 0 , 3	},;
				{ "Imprimir Boletim" , "U_IMPRBOLET(1)"    , 0 , 3	},;
				{ "Imprimir Etiqueta", "U_ImprEtBob(1,.F.)", 0 , 3	},;
				{ "Etiq.Av.Huawei"   , "U_EtiqAvul(1)" 		, 0 , 3	},;
				{ "Etiq.Av.Elektro"  , "U_EtiqAvul(2)" 		, 0 , 3	},;
				{ "Legenda"          , "U_CDBAL03LG"       , 0 , 2  },;
				{ "LogoTipo"         , "U_LoadGRF()"       , 0 , 3  },;
				{ "Integra WMS"      , "StaticCall(CDBAL03, IntegWMS,.T.)"     , 0 , 3  }}
		EndIf
	ElseIf _cTiAcd == "S" // Sucatas de Cobre

		cCadastro := "Pesagem de Sucatas de Cobre"

		aRotina := {{ "Pesquisar"        , "AxPesqui"      , 0 , 1	},;
			{ "Visualizar"       , "AxVisual"      , 0 , 2	},;
			{ "Pesar Sucata"     , "U_IncSuca"     , 0 , 3	},;
			{ "Imprimir Boletim" , "U_IMPRBOLET(1)", 0 , 3	},;
			{ "Legenda"          , "U_CDBAL03LG"   , 0 , 2  }}
	EndIf


	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
	DbSeek(xFilial("SZL"),.F.)

	mBrowse(001,040,200,390,"SZL",,,,,,aCores)
Return(.T.)


/*/{Protheus.doc} IncBobs
//TODO Inclui Bobinas no ZE.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function IncBobs()
	local lImprEtq		:= .T.
	local lNewNum		:= .T.
	local lOpcTEtq 		:= GetNewPar('ZZ_OPCTETQ', .F.)
	local lTemBobOri 	:= .F.

	Private _cBobAnt  := "  " // Filial + Nro Bobina
	aButtons := {}
	AAdd(aButtons, { "BALANCA" ,{|| u_CalcPeso()}, "Captura Peso"} )
	If !Empty(SZL->ZL_NUMBOB)
		_cBobAnt := SZL->ZL_FILIAL+SZL->ZL_NUMBOB
		DbSelectArea("SZE")
		DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
		Do While DbSeek(_cBobAnt,.F.)
			If !Empty(SZE->ZE_BOBORIG)
				_cBobAnt := SZE->ZE_BOBORIG
				lTemBobOri := .T.
			Else
				Exit
			EndIf
		EndDo
	EndIf
	_nRegSZE := 0 // Esta variável será alimentada pela função TrocaEtq()
	_nRegSZL := 0 // Esta variável será alimentada pela função TrocaEtq()
	// Alterar a variavel dDatabase porque está passando da meia noite e não estão saindo so sistema para atualizar
	dDataBase := Date()
	nOpca := AxInclui("SZL",0,3,,,,"u_ValDad()")
	If nOpca == 1
		dDataBase := Date()
		if lOpcTEtq
			if (SZL->ZL_TIPO == "T") .or. (SZL->ZL_TIPO == "F")
				if !MsgYesNo('Deseja Trocar o Num.Bobina?','Trocar Num.Bobina')
					//lImprEtq	:= .F.
					lNewNum		:= .F.
					if !lTemBobOri
						_cBobAnt  	:= Space(TamSX3("ZE_BOBORIG")[1])
					endif
				endif
			endif
		endif
		U_GrvDadSZL(lImprEtq,lNewNum,xFilial("SZE")) // Imprime etiqueta?, Dá novo número?, Filial de origem da bobina
	EndIf
	DbSelectArea("SZL")
Return(.T.)


/*/{Protheus.doc} CDBAL03LG
//TODO Menu do CDBAL03LG.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function CDBAL03LG()
	BrwLegenda(cCadastro,"Legenda",{{"ENABLE"		,"Pesagem a Processar"},;
		{"BR_AZUL"		,"Pesagem Pocessada"},;
		{"BR_LARANJA"	,"Pesagem No C.Q."},;
		{"DISABLE"		,"Pesagem Cancelada"}})
Return(.T.)


/*/{Protheus.doc} ValDad
//TODO Valida Dados de Pesagem.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function ValDad()
	_lVolta := .T.
	// Verificar se o Tipo da Bobina foi digitado
	If _cTiAcd =="B" .And. Empty(M->ZL_TPBOB )
		Alert("Informar obrigatoriamente o Tipo da Bobina")
		Return(.F.)
	EndIf

	// aqui entra a planilha do Rosevaldo
	SC6->(DbSetOrder(1))
	If M->ZL_PEDIDO == "000001" .Or. (M->ZL_TIPO == "R" .And. SC6->(!DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)))
		If Substr(M->ZL_PRODUTO,4,2) <= "08" .And. M->ZL_METROS < 20 // Bitola até 10mm2 e abaixo de 20 metros
			_lVolta := .F.
			Alert("Material até 10mm2 com menos de 20 metros - Sucatear")
		ElseIf Substr(M->ZL_PRODUTO,4,2) > "08" .And. M->ZL_METROS < 10 // Bitola acima de 10mm2 e abaixo de 10 metros
			_lVolta := .F.
			Alert("Material acima de 10mm2 com menos de 10 metros - Sucatear")
		ElseIf M->ZL_PESOEFE < GetNewPar('ZZ_PBOBEST', 50) .And. FWCodEmp()+FWCodFil() == "0101" .and. M->ZL_TIPO <> "F"
			_lVolta := .F.
			Alert("Material com menos de 50 Quilos, Fazer rolo")
		ElseIf M->ZL_PESOEFE < GetNewPar('ZZ_PBOBCLI', 30)
			// 31/01/11 - Rosevaldo pediu para não liberar bobinas < que 30 quilos
			_lVolta := .F.
			Alert("Material com menos de 30 Quilos, Fazer rolo")
		EndIf
	ElseIf M->ZL_PESOEFE < GetMv("MV_PESMBOB") //18
		If M->ZL_PEDIDO+M->ZL_ITEMPV $ GetMv("MV_PESLBOB") .Or. ;
				(M->ZL_PEDIDO == "136741" .And. M->ZL_ITEMPV $ "01//05") .Or. ;
				(M->ZL_PEDIDO == "136827" .And. M->ZL_ITEMPV == "12") //.Or. ;
				// (M->ZL_PEDIDO == "166267" .And. M->ZL_ITEMPV == "01")   // Aguardando autorização.
			// Crispilho autorizou a enviar essas bobinas com peso menor que 18 quilos
			// By   Roberto Oliveira 25/09/15. Solicitado por Lucas
			_lVolta := .T.
		Else
			_lVolta := .F.
			Alert("Peso mínimo para bobinas é de 18 Quilos")
		EndIf
	EndIf

	If M->ZL_TIPO =="R" .And. (Empty(M->ZL_ZZEID) .Or. Empty(M->ZL_PEDIDO) .Or. Empty(M->ZL_ITEMPV))
		Alert("Para retorno de retrabalho obrigatório informar:" + chr(13)   + chr(13) + ;
			"ID do Retrabalho" + chr(13) + ;
			"Número do Pedido de Venda" + chr(13) + ;
			"Item do Pedido de Vanda")
		_Volta := .F.
	EndIf

	If (M->ZL_DESVIO < _nDesMin .Or. M->ZL_DESVIO > _nDesMax) .And. _lVolta
		_lVolta := MsgBox("Desvio de " + AllTrim(Str(M->ZL_DESVIO,7,2)) + "%,  fora do permitido - Entre " + Transform(_nDesMin,"@E 999") + " a " + Transform(_nDesMax,"@E 999") +"%","Confirma?","YesNo")
	EndIf

	If M->ZL_TIPO =="R" .And. _lVolta
		DbSelectArea("ZZE")
		DbSetOrder(2) // ZZE_FILIAL+ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV

		If M->ZL_PEDIDO == "000001" // Para estoque
			// Procurar registro com ZZE->ZZE_SITUAC # "1"
			DbSeek(xFilial("ZZE")+M->ZL_ZZEID,.F.)
			Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ;
					ZZE->ZZE_ID == M->ZL_ZZEID    .And. ZZE->ZZE_SITUAC == "1" .And. ZZE->(!Eof())
				ZZE->(DbSkip())
			EndDo
			If ZZE->ZZE_ID # M->ZL_ZZEID .Or. ZZE->(Eof())
				DbSeek(xFilial("ZZE")+M->ZL_ZZEID,.F.)
			EndIf
		Else
			// Procuro exatamente o registro
			If !(DbSeek(xFilial("ZZE") + M->ZL_ZZEID + M->ZL_PEDIDO + M->ZL_ITEMPV,.F.))
				Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
					"Comunique o PCP")
				_lVolta := .F.
			EndIf
		EndIf

		//If _nQtMetros > ZZE->ZZE_SALDO
		If ZZE->ZZE_SITUAC == "1" .And. ZZE->ZZE_ID == M->ZL_ZZEID .And. ZZE->(!Eof())
			Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
				"Pesagem já Encerrada." + chr(13) + chr(13) + ;
				"Comunique o PCP")
			_lVolta := .F.
		ElseIf M->ZL_METROS > ZZE->ZZE_SALDO .And. _lVolta
			Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
				"Metragem Maior que o Saldo do Retrabalho." + chr(13) + chr(13) + ;
				"Comunique o PCP")
			_lVolta := .F.
		EndIf
		If !Empty(ZZE->ZZE_NUMBOB)
			_cBobAnt := ZZE->ZZE_FILIAL+ZZE->ZZE_NUMBOB			
			DbSelectArea("SZE")
			DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
			Do While DbSeek(_cBobAnt,.F.)
				If !Empty(SZE->ZE_BOBORIG)
					_cBobAnt := SZE->ZE_BOBORIG
				Else
					Exit
				EndIf
			EndDo
		Else
			_cBobAnt := "  "
		EndIf
	EndIf

	If _lVolta .And. M->ZL_TIPO == "R" .And. M->ZL_PEDIDO # "000001"
		SC6->(DbSetOrder(1))
		If SC6->(!DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)) // Pedido cancelado -> enviar para estoque
			M->ZL_PEDIDO := "000001"
			M->ZL_ITEMPV := "99"
		EndIf
	EndIf

	//Garantindo que o Lance é quantidade informada na pesagem - Juliana - 10/02/2017
	If _cTiAcd =="B" .And. _lVolta
		M->ZL_LANCE := M->ZL_METROS
	EndIf

	//TODO ELETROREDE - Juliana Leme
	//Conforme solicitação Felipe - 29/08/2016
	//Se Troca de Etiqueta para EletroRede Bloqueia - Solicitação de envio para Retrabalho
	_cCliLj := Posicione("SC5",1,xFilial("SC5")+M->ZL_PEDIDO,"C5_CLIENTE+C5_LOJACLI")
	If u_xIsInspe(Alltrim(M->ZL_PEDIDO))[1]
		If M->ZL_TIPO =="T" .And. _lVolta
			Alert("Não pode ser realizada a TROCA DE ETIQUETA." + chr(13) + chr(13) + ;
				"Material necessita de Inspeção do CQ." + chr(13) + chr(13) + ;
				"Favor utilizar a rotina de RETRABALHO!")
			_cCliLj := ""
			_lVolta := .F.
		EndIf
	EndIf
Return(_lVolta)


/*/{Protheus.doc} VerBMMOri
//TODO Verificar BMM Original.
@author Roberto Oliveira
@since 30/08/2016
@version undefined

@type function
/*/
User Function VerBMMOri()

	If Empty(M->ZL_BMMORI) .Or. Empty(M->ZL_IBMMORI)
		Return(.T.)
	EndIf
	DbSelectArea("SZB")
	SZB->(DbSetOrder(1))
	If !DbSeek(xFilial("SZB")+M->ZL_BMMORI+M->ZL_IBMMORI,.F.)
		Alert("BMM de Origem não Cadastrado")
		Return(.F.)
	ElseIf SZB->ZB_STATUS # "1"
		Alert("Este BMM não é de Envio para Retrabalho")
		Return(.F.)
	EndIf
	If !Empty(M->ZL_PRODUTO)
		If SZB->ZB_PRODUTO # M->ZL_PRODUTO
			Alert("Produtos do BMM Original e Digitado não Conferem")
			Return(.F.)
		EndIf
	EndIf
	SZB->(DbSetOrder(1))
Return(.T.)

/*/{Protheus.doc} VejaPeso
//TODO Analisa Peso informado na Balança.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function VejaPeso()
	// LEONARDO
	If !GetMv("MV_LERCOM") //(.F.=LER PESO DOS ARQUIVOS TXT, .T.=LER PESOS DAS PORTAS COM(1/2) )
		//LER ARQUIVO TEXTO
		Do While .T.
			_cArqTXT  := "C:\BALANCA\PESO.TXT"
			_cLidos := ""
			_nPesBal1 := 0
			// Tenta abrir o arquivo para ler o seu conteúdo

			If File(_cArqTXT)
				For _nVez := 1 To 10 // Tenta 10 Vezes
					nHdl := fOpen(_cArqTXT)
					If nHdl > 0 // Abriu
						nBytes := fRead(nHdl,@_cLidos,80)
						fClose(nHdl)
						_cLidos := AllTrim(_cLidos)
						_nPesBal1 := Val(StrTran(_cLidos,",","."))
						Exit
					EndIf
				Next
			EndIf

			_cArqTXT := "C:\BALANCA\PESO2.TXT"
			_cLidos := ""
			_nPesBal2 := 0
			// Tenta abrir o arquivo para ler o seu conteúdo

			If File(_cArqTXT)
				For _nVez := 1 To 10 // Tenta 10 Vezes
					nHdl := fOpen(_cArqTXT)
					If nHdl > 0 // Abriu
						nBytes := fRead(nHdl,@_cLidos,80)
						fClose(nHdl)
						_cLidos := AllTrim(_cLidos)
						_nPesBal2 := Val(StrTran(_cLidos,",","."))
						Exit
					EndIf
				Next
			EndIf
			Exit
		EndDo

		//OBTEM PESO LENDO DIRETO NAS PORTAS
	Else
		_nPesBal1 := U_liderPrt("1")
		_nPesBal2 := U_liderPrt("2")
	EndIf

	If _nPesBal1 == 0 .Or. _nPesBal2 == 0
		_nPesBal := _nPesBal1+_nPesBal2
	Else

		// Pedir para o usuário escolher
		cTitulo:="Escolha do Peso"
		cMensagem:="As Duas Balanças Tem Pesos! -> Escolha a Correta!"
		aOpcoes := {"1 " + AllTrim(Str(_nPesBal1,8,2)) + "Kg","2 " + AllTrim(Str(_nPesBal2,8,2)) + "Kg"}
		_cVolta := Aviso(cTitulo,cMensagem,aOpcoes)

		If _cVolta == 1
			_nPesBal := _nPesBal1
		Else
			_nPesBal := _nPesBal2
		EndIf
	EndIf
Return(_nPesBal)


/*/{Protheus.doc} CalcPeso
//TODO Calcula Peso.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param lMsgClc, logical, descricao
@type function
/*/
User Function CalcPeso(lMsgClc)
	Default lMsgClc  := .T.
	_lVolta := .T.
	If M->ZL_TIPO == "S" // Pesagem de Sucata
		M->ZL_PBRUT := VejaPeso()
		M->ZL_PESOEFE := M->ZL_PBRUT - M->ZL_TARA
	Else
		If M->ZL_TIPO == "R" .And. M->ZL_PEDIDO # "000001" .And. !Empty(M->ZL_ZZEID)
			// Se for retrabalho para pedido, tem que pesar exatamente a quantidade indicada no retrabalho
			DbSelectArea("ZZE")
			DbSetOrder(2)
			If M->ZL_PEDIDO # "000001" // Não é para cliente
				If !DbSeek(xFilial("ZZE")+M->ZL_ZZEID+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)
					_lVolta := .F.
					Alert("Pesagem de Retrabalho Inválida - Não Localizada")
				ElseIf ZZE->ZZE_SITUAC == "1"
					_lVolta := .F.
					Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
						"Pesagem já Encerrada." + chr(13) + chr(13) + ;
						"Comunique o PCP")
				ElseIf M->ZL_METROS # ZZE->ZZE_METRAS .And. M->ZL_METROS # 0
					_lVolta := .F.
					Alert("Pesagem de Retrabalho Inválida - Metragem Errada")
				EndIf
			EndIf
		EndIf
		If _lVolta
			If !M->ZL_TIPO $ "TDF" // Troca de Etiq. ou Prod.acima de 1500Kg não pode pegar o peso da balanca ou Troca de Filial
				M->ZL_PBRUT := VejaPeso()
			ElseIf M->ZL_TIPO # "D" // Prod.acima de 1500Kg não pode pegar o peso da balanca
				M->ZL_LOTE    := SZL->ZL_LOTE
				M->ZL_TPBOB   := SZL->ZL_TPBOB
				M->ZL_PRODUTO := SZL->ZL_PRODUTO
				M->ZL_DESC    := Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_DESC")
				M->ZL_METROS  := SZL->ZL_METROS
				M->ZL_TARA    := SZL->ZL_EMB
				M->ZL_PBRUT   := SZL->ZL_PBRUT
			EndIf
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			DbSeek(xFilial("SB1")+M->ZL_PRODUTO,.F.)
			M->ZL_LANCE   := M->ZL_METROS // no caso de bobinas é igual
			//M->ZL_PESPADR := (M->ZL_METROS * (SB1->B1_PESCOB+SB1->B1_PESPVC))
			M->ZL_PESPADR := (M->ZL_METROS * SB1->B1_PESBRU)
			M->ZL_PESOEFE := (M->ZL_PBRUT - M->ZL_TARA - M->ZL_EMB)
			M->ZL_DESVIO  :=  Round(((M->ZL_PESOEFE - M->ZL_PESPADR) / M->ZL_PESPADR) * 100,2)

			_xcCli := ""
			_xcLoj := ""
			// Verificar se a metragem da Bobina corresponde ao pedido de venda
			If !Empty(M->ZL_PEDIDO) .And. !Empty(M->ZL_ITEMPV) .And. M->(ZL_METROS) > 0 .And. M->ZL_PEDIDO # "000001"
				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+M->ZL_PEDIDO,.F.))
				_xcCli := SC5->C5_CLIENTE
				_xcLoj := SC5->C5_LOJACLI

				DbSelectArea("SC6")
				SC6->(DbSetOrder(1))
				If DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)
					// Pode ser que não exista pq a pesagem é Ret.Retrabalho, que será considerado para estoque.
					If M->ZL_METROS > 0 .And. M->ZL_METROS # SC6->C6_METRAGE .And. lMsgClc
						Alert("O tamanho do Lance no Pedido é de " + AllTrim(Str(SC6->C6_METRAGE,5)) + " Metros")
					EndIf
				EndIf
			EndIf
			// Verificar se o tipo da bobina é o ideal
			If !Empty(M->ZL_TPBOB) .And. !Empty(M->ZL_PRODUTO) .And. M->ZL_METROS > 0
				If !Empty(M->ZL_PEDIDO) .And. SC5->C5_EMISSAO <= Ctod("06/05/2017") // Pedidos incluidos até dia 6 tem que calcular da forma antiga
					_cTipoBob := u_CalcBob(M->ZL_PRODUTO,M->ZL_METROS)  //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				Else
					_cTipoBob := u_CalcBob(M->ZL_PRODUTO,M->ZL_METROS,,_xcCli,_xcLoj)  //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				EndIf
				_cTp := ""
				For nXx := 1 to Len(_cTipoBob[1])
					If Substr(_cTipoBob[1],nXx,1) $ "1234567890"
						_cTp := _cTp + Substr(_cTipoBob[1],nXx,1)
					EndIf
				Next

				_lVolta := .T.
				// O Cliente tem restrição de tambanho de bobinas?
				If !Empty(M->ZL_PEDIDO) .And. M->ZL_PEDIDO # "000001"
					SC5->(DbSetOrder(1))
					SC5->(DbSeek(xFilial("SC5")+M->ZL_PEDIDO,.F.))

					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
					If SA1->A1_MENORBB+SA1->A1_MAIORBB # "00" // Tem Bobina específica
						If AllTrim(M->ZL_TPBOB) < SA1->A1_MENORBB .Or. AllTrim(M->ZL_TPBOB) > SA1->A1_MAIORBB
							_lVolta := .F.
							_cMenor := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/170x80/",(((Val(AllTrim(SA1->A1_MENORBB))-1) * 7) + 1),6))
							_cMaior := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/170x80/",(((Val(AllTrim(SA1->A1_MAIORBB))-1) * 7) + 1),6))
							If SA1->A1_MENORBB == SA1->A1_MAIORBB
								Alert("O Cliente só aceita bobinas do tamanho " + _cMenor)
							Else
								Alert("O Cliente só aceita bobinas do tamanho " + _cMenor + " até " + _cMaior)
							EndIf
						EndIf
					EndIf
				EndIf

				If _lVolta
					If 	(_cTp == "6525"  .And. AllTrim(M->ZL_TPBOB) # "1") .Or.;
							(_cTp == "6545"  .And. AllTrim(M->ZL_TPBOB) # "2") .Or.;
							(_cTp == "8045"  .And. AllTrim(M->ZL_TPBOB) # "3") .Or.;
							(_cTp == "10060" .And. AllTrim(M->ZL_TPBOB) # "4") .Or.;
							(_cTp == "12570" .And. AllTrim(M->ZL_TPBOB) # "5") .Or.;
							(_cTp == "15080" .And. AllTrim(M->ZL_TPBOB) # "6") .Or.;
							(_cTp == "17080" .And. AllTrim(M->ZL_TPBOB) # "7")

						_cTpAtu := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/170x80/",(((Val(AllTrim(M->ZL_TPBOB))-1) * 7) + 1),6))
						_lVolta := If(lMsgClc,MsgBox("Para esse Produto/Metragem Usar Bobina " + _cTipoBob[1] + "." + Chr(13) + "Confirma o Uso da Bobina Tipo " + _cTpAtu + "?","Confirma?","YesNo"),.T.)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	//Valida qtde da UnMov
	//Alterado para que a qtde reportada seja exatamente a mesma pesada - Juliana Leme 02/09/2016
	If M->ZL_TIPO == "U" .and. ! GetMV("MV_LBPEBAL") .and. !Empty(M->ZL_UNMOV) .And. _lVolta //Parametro que libera pesagem a maior .F. = Bloqueado e .T. = Liberado
		M->ZL_METROS := (_nQtdPPI - _nQtUnmov)
		If M->ZL_METROS <> (_nQtdPPI - _nQtUnmov) //nQtUnMov Soma ZLMEtros e nQtdPPi Unmov PCF
			_lVolta := .F.
			Alert("Quantidade diferente da UNMOV " + AllTrim(Str((_nQtdPPI - _nQtUnmov))) + " Metros. Pesagem não liberada!")
		EndIf
	EndIf
Return(_lVolta)

/*/{Protheus.doc} VerPed
//TODO Analisa o pedido se o mesmo atende a pesagem a ser realizada.
@author oo
@since 20/05/2016
@version 1.0
@type function
@see CDBAL03
@obs 20/05/2016 - Juliana Leme - Realizada a alteração para bloqueio de pesagens para pedidos quando
o numero de bobinas for superior ao pedido colocado.
/*/
User Function VerPed()

	Local _lVolta 	:= .T.

	If M->ZL_PEDIDO == "000001" .And. M->ZL_TIPO # "R" // Enviando para estoque e NÃO é Retorno de retrabalho
		Return(.T.)
	EndIf

	If M->ZL_TIPO == "R" // Retorno de retrabalho
		// Primeiro verificar se for Retrabalho achar o item no ZZE
		DbSelectArea("ZZE")
		DbSetOrder(2) // ZZE_FILIAL+ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV
		_cChvZZE := ""
		If !Empty(M->ZL_ZZEID)
			_cChvZZE := M->ZL_ZZEID
			If !Empty(M->ZL_PEDIDO)
				_cChvZZE += M->ZL_PEDIDO
				If !Empty(M->ZL_ITEMPV)
					_cChvZZE += M->ZL_ITEMPV
				EndIf
			EndIf
		EndIf

		If !DbSeek(xFilial("ZZE")+_cChvZZE,.F.) .And. M->ZL_PEDIDO == "000001"
			If !MsgBox("Não há previsão de retorno desse lance para estoque." + Chr(13) + Chr(13) +;
					"Confirma a operação?","Confirma?","YesNo")
				Return(.F.)
			EndIf
			_cChvZZE := M->ZL_ZZEID
		EndIf

		If !DbSeek(xFilial("ZZE")+_cChvZZE,.F.)
			Alert("Pedido/Item não Pertence ao ID Informado")
			_lVolta := .F.
		ElseIf ZZE->ZZE_PRODUT # M->ZL_PRODUTO .And. !Empty(M->ZL_PRODUTO) //
			Alert("Produtos do ID do Retrab. e Digitado não Conferem")
			_lVolta := .F.
		ElseIf ZZE->ZZE_SITUAC == "1" .And. M->ZL_PEDIDO # "000001"
			_lVolta := .F.
			Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
				"Pesagem já Encerrada." + chr(13) + chr(13) + ;
				"Comunique o PCP")
		Else
			_lTemZZE := .F. // Tem registro no ZZE para retrabalho ?
			_lTemSai := .F. // Tem saldo de retrabalho para bobina ?
			Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->(!Eof())
				If Left(ZZE->ZZE_ID+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,Len(_cChvZZE)) == _cChvZZE .And. ZZE->ZZE_ACONDS =="B"
					_lTemZZE := .T. // Tem registro no ZZE para retrabalho !
					If ZZE->ZZE_DEVTOT < ZZE->ZZE_TOTSA
						_lTemSai := .T. // Tem saldo de retrabalho para bobina !
						Exit
					EndIf
				EndIf
				ZZE->(DbSkip())
			EndDo
			If !_lTemZZE // Não tem registro no ZZE para retrabalho!
				Alert("Pedido/Item não Pertence ao ID Informado")
				_lVolta := .F.
			ElseIf !_lTemSai // Não tem saldo de retrabalho para bobina!
				Alert("ID Retrabalho já Finalizado")
				_lVolta := .F.
			EndIf
		EndIf
	ElseIf M->ZL_TIPO == "T" .And. SZE->ZE_STATUS == "N" .And. !Empty(M->ZL_PEDIDO) .And. !Empty(M->ZL_ITEMPV)
		// Troca de etiqueta, verificar  se a bobina original estiver com reserva se o pedido
		// e item são para quem foi reservada.
		_lVolta := .F.
		SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB
		SZR->(DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.))
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
			If M->ZL_PEDIDO == SZR->ZR_PEDIDO .And. M->ZL_ITEMPV == M->ZL_ITEMPV
				_lVolta := .T.
				Exit
			EndIf
			SZR->(DbSkip())
		EndDo
		If !_lVolta
			Alert("Bobina reservada para outro Pedido/Item")
		Else
			DbSelectArea("SC9")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			DbSeek(xFilial("SC9")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)
			_lVolta := .F.
			Do While (SC9->C9_FILIAL == xFilial("SC9")) .And. SC9->(C9_PEDIDO+C9_ITEM) == M->ZL_PEDIDO+M->ZL_ITEMPV .And. SC9->(!Eof())
				If Empty(SC9->C9_BLCRED)
					_lVolta := .T.
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
			If !_lVolta
				Alert("Bobina reservada Pedido/Item não Liberado")
			EndIf
		EndIf
	EndIf

	If _lVolta
		If M->ZL_TIPO == "R" .And. M->ZL_PEDIDO # "000001"  // Retorno de Retrabalho
			SC6->(DbSetOrder(1))
			If SC6->(!DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.))
				// Retrabalho com pedido cancelado
				M->ZL_MOTIVO  := "08" //PEDIDO CANCELADO
				M->ZL_NOMECLI := Padr("Estoque",TamSX3("ZL_NOMECLI")[1])
				Alert("Pedido/Item " + M->ZL_PEDIDO + "-" + M->ZL_ITEMPV + " foi cancelado! " + Chr(13) + Chr(13) + "Essa pesagem será para estoque")
				Return(_lVolta)
			EndIf
		EndIf
	EndIf

	If M->ZL_PEDIDO == "000001" .And. M->ZL_TIPO == "R" // Retorno de retrabalho 617
		Return(_lVolta)
	EndIf

	If _lVolta
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		If !SC6->(DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.))
			Alert("Pedido/Item não Localizado")
			_lVolta := .F.
		ElseIf SC6->C6_BLQ == "R "
			Alert("Pedido/Item não Localizado - (Resíduo)")
			_lVolta := .F.
		ElseIf !Empty(M->ZL_PRODUTO)
			_cPrdI := Left(AllTrim(M->ZL_PRODUTO)+"I" +Space(50),Len(SC6->C6_PRODUTO))
			If M->ZL_PRODUTO # SC6->C6_PRODUTO .And. _cPrdI # SC6->C6_PRODUTO
				Alert("Produto Diferente do Pedido de Venda " + M->ZL_PEDIDO + " Item " + M->ZL_ITEMPV)
				_lVolta := .F.
			ElseIf SC6->C6_ACONDIC # "B"
				If M->ZL_TIPO $ "TF" // Troca de Etiq.// Troca de filial
					_lVolta := MsgBox("Acondicionamento no Pedido não é em Bobina","Confirma?","YesNo")
				Else
					Alert("Acondicionamento no Pedido não é em Bobina")
					_lVolta := .F.
				EndIf
			EndIf
			If _lVolta .And. !(M->ZL_TIPO $ "T/R") .And. "DRC" $ SC6->C6_SEMANA
				If Upper(Posicione("SC5",1,xFilial("SC5")+SC6->C6_NUM,"C5_DRCPROD")) == "N"
					// Não é para produzir
					Alert("Pedido com DRC e Não Produzir")
					_lVolta := .F.
				EndIf
			EndIf
			If _lVolta
				// Verificar se esse pedido está liberado no SC9
				DbSelectArea("SC9")
				DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
				DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.)
				_lVolta := .F.
				Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC6->C6_NUM .And.;
						SC9->C9_ITEM == SC6->C6_ITEM .And. SC9->(!Eof()) .And. !_lVolta
					_lVolta := (SC9->C9_BLCRED $ "  /10") // Liberado ou faturado
					DbSkip()
				EndDo
				If !_lVolta
					Alert("Pedido Ainda não Liberado")
				EndIf
			EndIf
		EndIf
	EndIf
	If !Empty(M->ZL_PRODUTO)
		If _lVolta .And. Empty(Posicione("SB1",1,xFilial("SB1")+M->ZL_PRODUTO,"B1_CODBAR"))
			Alert("Solicitar Cadastro do Cód. de Barras")
			_lVolta := .F.
		EndIf
	EndIf
	If _lVolta
		// Verificar quantas bobinas foram solicitadas pelo cliente
		// Verificar a quantidade de bobinas já produzidas
		_nQtdBob := 0
		DbSelectArea("SZE") // Cadastro de bobinas
		SZE->(DbSetOrder(2)) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
		DbSeek(xFilial("SZE")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.)
		Do While SZE->ZE_FILIAL ==xFilial("SZE") .And. SZE->ZE_PEDIDO+SZE->ZE_ITEM == M->ZL_PEDIDO+M->ZL_ITEMPV .And. SZE->(!Eof())
			If SZE->ZE_STATUS # "C" // Não é cancelada
				_nQtdBob++
			EndIf
			SZE->(DbSkip())
		EndDo
		If _nQtdBob >= SC6->C6_LANCES
			Alert("Já foram produzidas " + AllTrim(Str(_nQtdBob,5)) + " Bobinas para esse Pedido/Item, esta pesagem não podera ser realizada!")
			_lVolta := .F.
			//TODO Verificar aqui
		ElseIf M->ZL_TIPO == "T" .And. !Empty(M->ZL_PEDIDO) .And. !Empty(M->ZL_ITEMPV) .and. _lTipoPes = "B"
			// Primeiro verificar se for Retrabalho achar o item no ZZE
			_nQtdRet := 0
			DbSelectArea("ZZE")
			DbSetOrder(4) // ZZE_FILIAL+ZZE_PEDIDO+ZZE_ITEMPV+ZZE_PRODUT
			If DbSeek(xFilial("ZZE") + M->ZL_PEDIDO + M->ZL_ITEMPV,.F.)
				If (ZZE->ZZE_STATUS # '9') .AND. (ZZE->ZZE_STATUS # '4')
					_nQtdRet := ZZE->ZZE_LANCES
				EndIf
				If (_nQtdBob + _nQtdRet) >= SC6->C6_LANCES
					Alert("Existe solicitação de retrabalho para este pedido. Total de lances superior ao pedido, esta pesagem não podera ser realizada!")
					_lVolta := .F.
				EndIf
			ElseIf !Empty(SC6->C6_SEMANA)
				dbSelectArea("SZ9")
				dbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO
				_LocPed := SC6->C6_ACONDIC + StrZero(SC6->C6_METRAGE,5)
				_LocPed := Padr(_LocPed,TamSX3("BE_LOCALIZ")[1])
				If DbSeek(xFilial("SZ9")+SC6->C6_SEMANA+M->ZL_PRODUTO+SC6->C6_LOCAL+_LocPed+SC6->C6_NUM+SC6->C6_ITEM,.T.)
					If (SZ9->Z9_QTDETQ >= SC6->C6_LANCES) .and. (SZ9->Z9_IMPETIQ == "S") //Alteração Juliana 11/05/2017
						Alert("Não existe Saldo para liberação da troca de etiquetas.")
						_lVolta := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		SC6->(DbSeek(xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,.F.))
		If SC6->(Eof()) .Or. SC6->C6_BLQ == "R "
			_lVolta := MsgBox(" Retorna Retrabalho para ESTOQUE ?","Confirma?","YesNo")
			M->ZL_PEDIDO := "000001"
			M->ZL_ITEMPV := "99"
			M->ZL_MOTIVO := "08"
		EndIf
	EndIf
Return(_lVolta)


/*/{Protheus.doc} ImprEtBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVias, , descricao
@param _lNova, , descricao
@type function
/*/
User Function ImprEtBob(_nVias,_lNova)
	Local cSeloVIt, cSeloVTL, cPVCli, cNomeCli
	Local _lUsaAcond
	Local cAltLay 		:= ""
	Local lInvert 		:= .F.
	local lPrtExtEtq 	:= GetNewPar('ZZ_PRTEETQ', .T.)

	If Empty(SZL->ZL_NUMBOB)
		Alert("Posicione em um Registro de Bobina")
		Return(.T.)
	EndIf

	// Posiciona Tabelas
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	SZE->(DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.))

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+SZL->ZL_PEDIDO,.F.))

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	DbSeek(xFilial("SC6")+SZL->ZL_PEDIDO+SZL->ZL_ITEMPV,.F.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	DbSeek(xFilial("SA1")+SZE->ZE_CLIENTE+SZE->ZE_LOJA,.F.)

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	DbSeek(xFilial("SB1")+SZL->ZL_PRODUTO,.F.)

	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(1))
	SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))

	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))

	DbSelectArea("SZ3")
	SZ3->(DbSetOrder(1))
	SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))

	SetDefault(aReturn,cString)

	cAltLay := AllTrim(SZ1->(Z1_LAYOUT))

	If cAltLay == "CHL"
		u_CbcEtChl(_nVias,_lNova)
	Else
		@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
		@ 0,0 PSAY "^FX ======================================================== ^FS"
		@ 0,0 PSAY "^FX =               *** ETIQUETA P/ BOBINAS ***            = ^FS"
		@ 0,0 PSAY "^FX =                                                      = ^FS"
		@ 0,0 PSAY "^FX =      Etiqueta desenvolvida por Valter Sanavio e      = ^FS"
		@ 0,0 PSAY "^FX =            Roberto Oliveira em 29/10/2008            = ^FS"
		@ 0,0 PSAY "^FX ======================================================== ^FS"
		@ 0,0 PSAY "^FX ==== BORDAS EXTERNAS =================================== ^FS"
		@ 0,0 PSAY "^FO008,012^GB800,590,6^FS"
		@ 0,0 PSAY "^FX ==== LINHAS HORIZONTAIS ================================ ^FS"
		@ 0,0 PSAY "^FO008,100^GB800,001,4^FS"	//EM CIMA  DO COMPRIMENRO
		@ 0,0 PSAY "^FO008,212^GB800,001,4^FS"	//EM BAIXO DO COMPRIMENRO
		@ 0,0 PSAY "^FO008,274^GB800,001,4^FS"	//EM CIMA  DE PEDIDO E CLIENTE
		@ 0,0 PSAY "^FO008,336^GB800,001,4^FS"  //EM BAIXO DE PEDIDO E CLIENTE
		@ 0,0 PSAY "^FO008,398^GB664,001,4^FS"	//EM CIMA  DE LOTE/DATA, TARA, MASSA BRUTO ETC
		@ 0,0 PSAY "^FO008,460^GB664,001,4^FS"	//EM CIMA  DO COD.EAN E SELO INMETRO
		@ 0,0 PSAY "^FX ==== LINHAS VERTICAIS ================================== ^FS"
		@ 0,0 PSAY "^FO170,212^GB001,062,4^FS"	//Apos TENSAO ISOLAMENTO
		@ 0,0 PSAY "^FO370,212^GB001,062,4^FS"	//Apos COMPOSICAO PRODUTO
		@ 0,0 PSAY "^FO570,212^GB001,062,4^FS"	//Apos NORMA TECNICA
		@ 0,0 PSAY "^FO184,274^GB001,186,4^FS"	//Apos N.PEDIDO e desce ate LOTE / DATA
		@ 0,0 PSAY "^FO368,398^GB001,199,4^FS"	//Apos MASSA BRUTA e desce ate a borda inferior
		@ 0,0 PSAY "^FO672,336^GB001,263,4^FS"	//Apos DESTINO e desce ate a borda inferior
		@ 0,0 PSAY "^FX ===== LOGO COBRECOM ==================================== ^FS"
		@ 0,0 PSAY "^FO024,014^XGLOGO30A.GRF^FS"
		@ 0,0 PSAY "^FO344,024^A0N,15,22^FDI.F.C. IND. COM. CONDUTORES ELETRICOS LTDA^FS"
		@ 0,0 PSAY "^FO344,040^A0N,15,22^FDITU/SP-Av. Primo Schincariol, 670-Jd. Oliveira^FS"
		@ 0,0 PSAY "^FO344,056^A0N,15,22^FDCNPJ 02.544.042/0001-19   I.E.387.086.243.118^FS"
		@ 0,0 PSAY "^FO344,072^A0N,15,22^FDTres Lagoas/MS Av.2,sn-Esq.Av.5-Distr.Indl.^FS"
		@ 0,0 PSAY "^FO344,088^A0N,15,22^FDCNPJ 02.544.042/0002-08   I.E.283.453.354^FS"
		@ 0,0 PSAY "^FO096,086^A0N,15,22^FDIndustria Brasileira^FS"
		@ 0,0 PSAY "^FX ===== 1a. LINHA DESCRICAO PRODUTO ====================== ^FS"
		@ 0,0 PSAY "^FO008,100^GB600,115,115^FS"
		@ 0,0 PSAY "^FO016,108^A0N,15,17^FR^FDPRODUTO^FS"

		If Val(Left(SB1->B1_COD,1)) == 0
			// Alteração feita para o Vitor em 21/05/14 para imprimir etiquetas dos cabos
			// de alumínio. Apesar de serem PIs, alteramos o SB1 para PA.
			// As pesagens geradas devem ser excluídas e não processadas.
			@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + Left(SB1->B1_DESC,30) + "^FS"
			@ 0,0 PSAY "^FO024,176^A0N,40,35^FR^FD" + AllTrim(Substr(SB1->B1_DESC,31,50)) + "^FS"
		Else
			If Left(SB1->B1_COD,3) == "164" // Cabos multiplexados não tem cor
				@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
			Else
				@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
			EndIf
			@ 0,0 PSAY "^FO024,184^A0N,20,20^FR^FDSECAO:^FS"
			@ 0,0 PSAY "^FO104,170^A0N,47,50^FR^FD" + Str(SZ1->Z1_VIAS,2) + "x" + AllTrim(SZ2->Z2_BITOLA) + "^FS"
			If Left(SB1->B1_COD,3) $ "162/163/164" // Cabos multiplexados não tem cor
				@ 0,0 PSAY "^FO472,184^A0N,25,25^FR^FDmm^FS"
				@ 0,0 PSAY "^FO514,176^A0N,20,20^FR^FD2^FS"
			Else
				@ 0,0 PSAY "^FO312,184^A0N,25,25^FR^FDmm^FS"
				@ 0,0 PSAY "^FO354,176^A0N,20,20^FR^FD2^FS"
				@ 0,0 PSAY "^FO378,176^A0N,35,35^FR^FD" + AllTrim(SZ3->Z3_DESC) + "^FS"
			EndIf
		EndIf

		@ 0,0 PSAY "^FX ===== DEMAIS CAMPOS DA ETIQUETA ========================= ^FS"

		If (SZE->ZE_QUANT - Int(SZE->ZE_QUANT)) > 0
			_ZEQTD := AllTrim(Str(SZE->ZE_QUANT,10,2))
		Else
			_ZEQTD := AllTrim(Str(SZE->ZE_QUANT,10))
		EndIf

		If Upper(AllTrim(SB1->B1_UM)) == "KG"
			@ 0,0 PSAY "^FO616,108^A0N,15,17^FDQUANTIDADE (kg)^FS"
		ElseIf Upper(AllTrim(SB1->B1_UM)) == "MT"
			@ 0,0 PSAY "^FO616,108^A0N,15,17^FDCOMPRIMENTO (m)^FS"
		Else
			@ 0,0 PSAY "^FO616,108^A0N,15,17^FDQUANTIDADE ("+AllTrim(SB1->B1_UM)+")^FS"
		EndIf
		@ 0,0 PSAY "^FO624,132^A0N,75,65^FD" + _ZEQTD +"^FS"
		@ 0,0 PSAY "^FO016,220^A0N,15,17^FDTENSAO ISOLAMENTO^FS"
		_cTensao := SZ1->Z1_DESC3
		If SZ2->Z2_COD <= "03" .And. !Empty(SZ1->Z1_DESC3A)
			_cTensao := SZ1->Z1_DESC3A
		EndIf

		@ 0,0 PSAY "^FO016,244^A0N,35,15^FD" + AllTrim(_cTensao) + "^FS"
		@ 0,0 PSAY "^FO178,220^A0N,15,17^FDCOMPOSICAO PRODUTO^FS"
		@ 0,0 PSAY "^FO178,244^A0N,35,15^FD " + AllTrim(SZ1->Z1_COMPOS) + " ^FS"
		@ 0,0 PSAY "^FO380,220^A0N,15,17^FDNORMA TECNICA^FS"
		@ 0,0 PSAY "^FO380,244^A0N,35,15^FD" + AllTrim(SB1->B1_NORMA) + "^FS"
		@ 0,0 PSAY "^FO578,220^A0N,15,17^FDDESIGNACAO^FS"
		@ 0,0 PSAY "^FO578,244^A0N,35,15^FD" + AllTrim(SB1->B1_XDESIG) + "^FS"
		@ 0,0 PSAY "^FO016,282^A0N,15,17^FDN. PEDIDO^FS"

		_lUsaAcond := .F.
		aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
		If SZE->ZE_PEDIDO # "000001" // Pesagens que vão para o estoque... não existe o pedido 000001
			_lUsaAcond := Left(SA1->A1_CGC,8) $ GetMv("MV_XTRCCOD")
			aDadInd    := u_InfTrian(xFilial("SZE"),SZE->ZE_PEDIDO,"CDBAL03")
			/*/
			Retorno da InfTrian
			[1]PEDIDO
			[2]A1_NOME
			[3]A1_NREDUZ
			[4]A1_MUN
			[5]A1_EST
			[6]A1_CGC
			[7]A1_TEL
			/*/
			If Len(aDadInd) = 0
				aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
			Else
				_lUsaAcond := Left(aDadInd[1,6],8) $ GetMv("MV_XTRCCOD")
			EndIf
		EndIf

		If !Empty(aDadInd[1,1])
			@ 0,0 PSAY "^FO036,306^A0N,35,30^FD" + aDadInd[1,1] + "^FS"
		Else
			@ 0,0 PSAY "^FO036,306^A0N,35,30^FD" + AllTrim(SZE->ZE_PEDIDO) + "^FS"
		EndIf
		// Fim Código Novo

		@ 0,0 PSAY "^FO192,282^A0N,15,17^FDCLIENTE^FS"

		If !Empty(aDadInd[1,2])
			@ 0,0 PSAY "^FO192,306^A0N,35,30^FD" + Substr(AllTrim(aDadInd[1,2]),6,60) + "^FS"
		Else
			@ 0,0 PSAY "^FO192,306^A0N,35,30^FD" + AllTrim(SZE->ZE_NOMCLI) + "^FS"
		EndIf
		// Fim Código Novo

		@ 0,0 PSAY "^FO016,347^A0N,15,17^FDN. BOBINA^FS"
		@ 0,0 PSAY "^FO036,368^A0N,35,30^FD" + AllTrim(SZE->ZE_NUMBOB) + "^FS"
		@ 0,0 PSAY "^FO192,347^A0N,15,17^FDDESTINO^FS"
		@ 0,0 PSAY "^FO192,368^A0N,35,30^FD" + IIF(Empty(aDadInd[1,4]),AllTrim(SZE->ZE_DESTINO),Alltrim(aDadInd[1,4])+"-"+aDadInd[1,5]) + "^FS"
		@ 0,0 PSAY "^FO016,406^A0N,15,17^FDLOTE / DATA^FS"

		// Forçar a data com o século
		_cDataB := DtoS(SZE->ZE_DATA)
		_cDataB := Right(_cDataB,2) + "/" + Substr(_cDataB,5,2) + "/" + Left(_cDataB,4)

		_xCodBars := SB1->B1_CODBAR
		DbSelectArea("SZJ")
		DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ

		// Se _lUsaAcond e for bobina, localizar sempre um codbar genérico
		/*/
		Retorno da InfTrian no array aDadInd
		[1]PEDIDO
		[2]A1_NOME
		[3]A1_NREDUZ
		[4]A1_MUN
		[5]A1_EST
		[6]A1_CGC
		[7]A1_TEL
		/*/
		If _lUsaAcond
			// Procurar sempre um codbar de uma bobina genérica
			_cLczNow := Padr("B",TamSX3("ZJ_LOCALIZ")[1])
			DbSelectArea("SZJ")
			DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
			If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
				_xCodBars := SZJ->ZJ_CODBAR
			Else
				_xCodBars := u_NewSzj(SB1->B1_COD,_cLczNow)
			EndIf
		Else
			//Procuro primeiro um codbar específico e depois um genérico
			_cLczNow := Padr(("B" + StrZero(SZE->ZE_QUANT,5)),TamSX3("ZJ_LOCALIZ")[1])
			If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
				// Procuto primeiro um GTIN para a bobina exata.
				_xCodBars := SZJ->ZJ_CODBAR
			Else
				_cLczNow := Padr("B",TamSX3("ZJ_LOCALIZ")[1])
				DbSelectArea("SZJ")
				DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
				If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
					_xCodBars := SZJ->ZJ_CODBAR
				Else
					_xCodBars := u_NewSzj(SB1->B1_COD,_cLczNow)
				EndIf
			EndIf
		EndIf

		@ 0,0 PSAY "^FO016,430^A0N,30,15^FD" + AllTrim(SZE->ZE_LOTE) + " / " +  _cDataB + "^FS"
		@ 0,0 PSAY "^FO192,406^A0N,15,17^FDTARA^FS"
		@ 0,0 PSAY "^FO192,430^A0N,30,15^FD" + Transform(SZE->ZE_TARA,"@E 999.99") + " kg^FS"
		@ 0,0 PSAY "^FO256,406^A0N,15,17^FDMASSA BRUTA^FS"
		@ 0,0 PSAY "^FO288,430^A0N,30,15^FD" + Transform(SZE->ZE_PESO,"@E 9999.99") + "kg^FS"
		@ 0,0 PSAY "^FO376,406^A0N,15,17^FDSITUACAO DE INSPECAO^FS"
		@ 0,0 PSAY "^FX ====== QUADRADO APROVADO =============================== ^FS"
		@ 0,0 PSAY "^FO400,422^GB32,32,4^FS"
		@ 0,0 PSAY "^FO408,425^A0N,30,30^FDx^FS"
		@ 0,0 PSAY "^FO464,422^A0N,44,40^FDAPROVADO^FS"
		@ 0,0 PSAY "^FX ====== CODIGO DE BARRAS ================================ ^FS"
		@ 0,0 PSAY "^FO048,484^BY3,,60^BEN,70,Y,N^FD" + Left(AllTrim(_xCodBars),12) + "^FS"
		@ 0,0 PSAY "^FO702,376^BY2,,60^BUB,80,Y,N,N^FD" + "96" + SZE->ZE_FILORIG + StrZero(Val(SZE->ZE_NUMBOB),7) + "^FS"
		@ 0,0 PSAY "^FO680,400^A0B,20,25^FD" + AllTrim(SB1->B1_COD) + "^FS"
		//Verifica se possui Registro para impressão do Selo da TUV/INMETRO
		@ 0,0 PSAY "^FX ====== SELO TUV/INMETRO ================================ ^FS"

		If !Empty(SZE->ZE_BOBORIG)
			_cFilOri := Left(SZE->ZE_BOBORIG,2)
		Else
			_cFilOri := FWCodFil()
		EndIf

		If _cFilOri == "01" // Itu / Matriz
			If !Empty(SB1->B1_XREGINM)
				@ 0,0 PSAY "^FO370,464^XGREG^FS"
				@ 0,0 PSAY "^FO480,525^A0N,15,17^FDRegistro^FS"
				@ 0,0 PSAY "^FO470,540^A0N,12,15^FD" + AllTrim(SB1->B1_XREGINM) + "^FS"
			Else
				//Se não existir Selo com Registro TUV/INMETRO, verifica se existe selo TUV-Voluntário
				cSeloVIt := GetMv("MV_XSELOIT")
				If Substr(SB1->B1_COD,1,3) $ cSeloVIt
					//@ 0,0 PSAY "^FO370,464^XGCR1^FS"
					@ 0,0 PSAY "^FO445,464^XGCR1^FS"
				EndIf
			EndIf
		ElseIf _cFilOri == "02" // Filial / 3 Lagoas
			If !Empty(SB1->B1_XREGIN3)
				@ 0,0 PSAY "^FO370,464^XGREG^FS"
				@ 0,0 PSAY "^FO480,525^A0N,15,17^FDRegistro^FS"
				@ 0,0 PSAY "^FO470,540^A0N,15,17^FD" + AllTrim(SB1->B1_XREGIN3) + "^FS"
			Else
				//Se não existir Selo com Registro TUV/INMETRO, verifica se existe selo TUV-Voluntário
				cSeloVTL := GetMv("MV_XSELOIT")
				If Substr(SB1->B1_COD,1,3) $ cSeloVTL
					@ 0,0 PSAY "^FO445,464^XGCR1^FS"
				EndIf
			EndIf
		EndIf
		@ 0,0 PSAY "^FX ======================================================== ^FS"
		@ 0,0 PSAY "^FX =                   Fim da Etiqueta                    = ^FS"
		@ 0,0 PSAY "^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS"
		@ 0,0 PSAY "^FX ======================================================== ^FS"
		@ 0,0 PSAY "^PQ"+AllTrim(Str(_nVias))+"^FS"
		@ 0,0 PSAY "^MTT^FS"
		@ 0,0 PSAY "^MPE^FS"
		@ 0,0 PSAY "^JUS^FS"
		@ 0,0 PSAY "^XZ"
		SET DEVICE TO SCREEN
		If aReturn[5]==1
			DbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		EndIf
		MS_FLUSH()

		//Chama função onde analisa se existe etiqueta personalizada para impressão
		U_fEtiqCBC(SC5->(Recno()),SZL->ZL_ITEMPV,SA1->(A1_COD+A1_LOJA),cPorta,_nVias)

		If !Empty(SA1->(A1_FILTRF))
			lInvert := .T.
		EndIf
		//Imprime etiqueta com numero da bobina e pedido
		//Array // aString 	:= {{"Numero do Pedido","35,40",10},{"255000","65,70",18},{"Numero da Bobina","35,40"},{"999999","65,70"}}
		aString 	:= {{"Numero do Pedido","75,80",12,lInvert},;
			{iif(!empty(aDadInd[1,1]),aDadInd[1,1],AllTrim(SZE->ZE_PEDIDO)),"205,210",30,.F.},;
			{"Numero da Bobina","75,80",12,lInvert},;
			{SZE->ZE_NUMBOB,"205,210",0,.F.}}
		if lPrtExtEtq
			u_cbcPrintEti(aString,cPorta,_nVias)
		endif

		// Verificar se precisa imprimir etiqueta de identificação do cliente final em um processo de atendimento multi-filial.
		if !empty(SC5->(C5_X_IDVEN))
			u_cbcXIdEtq(SC5->(Recno()), SZE->(Recno()),cPorta)
		endif

		if !empty(SC6->(C6_ZZPVORI))
			u_cbcEtqPVDiv(SC6->(Recno()), SZE->(Recno()),cPorta)
		endif

		// Se o cliente for a HUAWEI, imprimir tambem as etiquetas específicas a eles
		//If "HUAWEI" $ Upper(SA1->A1_NOME)
		If "HUAWEI" $ Upper(SZE->ZE_NOMCLI)
			If _lNova
				DbSelectArea("SA7")
				DbSetOrder(1) //A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
				// Procurar no SA7 sempre os produtos cadastrados para o cliente 014642-04"
				_cPrdHwy := Left(Left(SZL->ZL_PRODUTO,10) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
				If DbSeek(xFilial("SA7")+SZE->ZE_CLIENTE+SZE->ZE_LOJA+_cPrdHwy,.F.)
					// Ir para a rotina de impressão
					EtiHuawei(_nVias,SZE->ZE_QUANT,_cPrdHwy,1,"B",SZE->ZE_NUMBOB)
				EndIf
			Else
				Alert('Etiquetas Huawey devem ser emitidas pela opção "Etiq.Avulsas Huawei".')
			EndIf
			// Andra Mat.Elétricos Ltda e FECVA
		ElseIf (Left(SA1->A1_CGC,8) == "47674429") .or.;
				(Left(SA1->A1_CGC,8) == "57369027")
			EtiAndra(_nVias)
			// Emitir também duas etiquetas só com o nro das bobinas BEM GRANDE.
			EtiNumBob(SZE->ZE_NUMBOB)
		ElseIf Left(SA1->A1_CGC,8) == "02328280" // ELEKTRO ELETRICIDADE E SERVIÇOS S.A.
			//CNPJ/MF 02.328.280/0001-97 NIRE 35.300.153.570
			DbSelectArea("SA7")
			DbSetOrder(1) //A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
			// Procurar no SA7 sempre os produtos cadastrados para o cliente 014642-04"
			_cPrdElek := Left(Left(SZL->ZL_PRODUTO,10) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
			If DbSeek(xFilial("SA7")+"01988351"+_cPrdElek,.F.)
				EtiElektro(_nVias)
			EndIf
		EndIf

	EndIf
Return(.T.)


/*/{Protheus.doc} CbcEtChl
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 26/07/2018
@version 1.0
@param _nVias, , descricao
@param _lNova, , descricao
@type function
Etiqueta de Bobinas para o Layout do Chile.
Selo SEC deve usar o padrão SZ1_COD+SEC.GRF
/*/
User Function CbcEtChl(_nVias,_lNova)
	Local cSeloVIt, cSeloVTL, cPVCli, cNomeCli
	Local _lUsaAcond
	Local cSeloSec := AllTrim(SZ1->Z1_COD)+"SEC"


	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =               *** ETIQUETA P/ BOBINAS ***            = ^FS"
	@ 0,0 PSAY "^FX =                                                      = ^FS"
	@ 0,0 PSAY "^FX =       Manutenção do legado por Alexandre Madeira     = ^FS"
	@ 0,0 PSAY "^FX =                             em 13/07/2018            = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX ==== BORDAS EXTERNAS =================================== ^FS"
	@ 0,0 PSAY "^FO008,012^GB800,590,6^FS"
	@ 0,0 PSAY "^FX ==== LINHAS HORIZONTAIS ================================ ^FS"
	@ 0,0 PSAY "^FO008,100^GB800,001,4^FS"	//EM CIMA  DO COMPRIMENRO
	@ 0,0 PSAY "^FO008,212^GB800,001,4^FS"	//EM BAIXO DO COMPRIMENRO
	@ 0,0 PSAY "^FO008,274^GB800,001,4^FS"	//EM CIMA  DE PEDIDO E CLIENTE
	@ 0,0 PSAY "^FO008,336^GB800,001,4^FS"  //EM BAIXO DE PEDIDO E CLIENTE
	@ 0,0 PSAY "^FO008,398^GB435,001,4^FS"	//EM CIMA  DE LOTE/DATA, TARA, MASSA BRUTO ETC
	@ 0,0 PSAY "^FO008,460^GB360,001,4^FS"	//EM CIMA  DO COD.EAN
	@ 0,0 PSAY "^FX ==== LINHAS VERTICAIS ================================== ^FS"
	@ 0,0 PSAY "^FO170,212^GB001,062,4^FS"	//Apos TENSAO ISOLAMENTO
	@ 0,0 PSAY "^FO370,212^GB001,062,4^FS"	//Apos COMPOSICAO PRODUTO
	@ 0,0 PSAY "^FO570,212^GB001,062,4^FS"	//Apos NORMA TECNICA
	@ 0,0 PSAY "^FO184,274^GB001,186,4^FS"	//Apos N.PEDIDO e desce ate LOTE / DATA
	@ 0,0 PSAY "^FO368,398^GB001,199,4^FS"	//Apos MASSA BRUTA e desce ate a borda inferior
	@ 0,0 PSAY "^FO440,336^GB001,263,4^FS"	//Apos DESTINO e desce ate a borda inferior
	@ 0,0 PSAY "^FO672,336^GB001,263,4^FS"	//Apos Selo SEC e desce ate a borda inferior
	@ 0,0 PSAY "^FX ===== LOGO COBRECOM ==================================== ^FS"
	@ 0,0 PSAY "^FO024,014^XGLOGOESP1^FS"
	@ 0,0 PSAY "^FO344,024^A0N,15,22^FDI.F.C. IND. COM. CONDUTORES ELETRICOS LTDA^FS"
	@ 0,0 PSAY "^FO344,040^A0N,15,22^FDITU/SP-Av. Primo Schincariol, 670-Jd. Oliveira^FS"
	@ 0,0 PSAY "^FO344,056^A0N,15,22^FDCNPJ 02.544.042/0001-19   I.E.387.086.243.118^FS"
	@ 0,0 PSAY "^FO344,072^A0N,15,22^FDTres Lagoas/MS Av.2,sn-Esq.Av.5-Distr.Indl.^FS"
	@ 0,0 PSAY "^FO344,088^A0N,15,22^FDCNPJ 02.544.042/0002-08   I.E.283.453.354^FS"
	//@ 0,0 PSAY "^FO096,086^A0N,15,22^FDIndustria Brasileira^FS"
	@ 0,0 PSAY "^FX ===== 1a. LINHA DESCRICAO PRODUTO ====================== ^FS"
	@ 0,0 PSAY "^FO008,100^GB600,115,115^FS"
	@ 0,0 PSAY "^FO016,108^A0N,15,17^FR^FDPRODUTO^FS"

	If Val(Left(SB1->B1_COD,1)) == 0
		// Alteração feita para o Vitor em 21/05/14 para imprimir etiquetas dos cabos
		// de alumínio. Apesar de serem PIs, alteramos o SB1 para PA.
		// As pesagens geradas devem ser excluídas e não processadas.
		@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + Left(SB1->B1_DESC,30) + "^FS"
		@ 0,0 PSAY "^FO024,176^A0N,40,35^FR^FD" + AllTrim(Substr(SB1->B1_DESC,31,50)) + "^FS"
	Else
		If Left(SB1->B1_COD,3) == "164" // Cabos multiplexados não tem cor
			@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
		Else
			@ 0,0 PSAY "^FO024,128^A0N,45,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
		EndIf
		@ 0,0 PSAY "^FO024,184^A0N,20,20^FR^FDSECAO:^FS"
		@ 0,0 PSAY "^FO104,170^A0N,47,50^FR^FD" + Str(SZ1->Z1_VIAS,2) + "x" + AllTrim(SZ2->Z2_BITOLA) + "^FS"
		If Left(SB1->B1_COD,3) $ "162/163/164" // Cabos multiplexados não tem cor
			@ 0,0 PSAY "^FO472,184^A0N,25,25^FR^FDmm^FS"
			@ 0,0 PSAY "^FO514,176^A0N,20,20^FR^FD2^FS"
		Else
			@ 0,0 PSAY "^FO312,184^A0N,25,25^FR^FDmm^FS"
			@ 0,0 PSAY "^FO354,176^A0N,20,20^FR^FD2^FS"
			@ 0,0 PSAY "^FO378,176^A0N,35,35^FR^FD" + AllTrim(SZ3->Z3_DESC) + "^FS"
		EndIf
	EndIf

	@ 0,0 PSAY "^FX ===== DEMAIS CAMPOS DA ETIQUETA ========================= ^FS"

	If (SZE->ZE_QUANT - Int(SZE->ZE_QUANT)) > 0
		_ZEQTD := AllTrim(Str(SZE->ZE_QUANT,10,2))
	Else
		_ZEQTD := AllTrim(Str(SZE->ZE_QUANT,10))
	EndIf

	If Upper(AllTrim(SB1->B1_UM)) == "KG"
		@ 0,0 PSAY "^FO616,108^A0N,15,17^FDQUANTIDADE (kg)^FS"
	ElseIf Upper(AllTrim(SB1->B1_UM)) == "MT"
		@ 0,0 PSAY "^FO616,108^A0N,15,17^FDCOMPRIMENTO (m)^FS"
	Else
		@ 0,0 PSAY "^FO616,108^A0N,15,17^FDQUANTIDADE ("+AllTrim(SB1->B1_UM)+")^FS"
	EndIf
	@ 0,0 PSAY "^FO624,132^A0N,75,65^FD" + _ZEQTD +"^FS"
	@ 0,0 PSAY "^FO016,220^A0N,15,17^FDTENSAO ISOLAMENTO^FS"
	_cTensao := SZ1->Z1_DESC3
	If SZ2->Z2_COD <= "03" .And. !Empty(SZ1->Z1_DESC3A)
		_cTensao := SZ1->Z1_DESC3A
	EndIf

	@ 0,0 PSAY "^FO016,244^A0N,35,15^FD" + AllTrim(_cTensao) + "^FS"
	@ 0,0 PSAY "^FO178,220^A0N,15,17^FDCOMPOSICAO PRODUTO^FS"
	@ 0,0 PSAY "^FO178,244^A0N,35,15^FD " + AllTrim(SZ1->Z1_COMPOS) + " ^FS"
	@ 0,0 PSAY "^FO380,220^A0N,15,17^FDNORMA TECNICA^FS"
	@ 0,0 PSAY "^FO380,244^A0N,35,15^FD" + AllTrim(SB1->B1_NORMA) + "^FS"
	@ 0,0 PSAY "^FO578,220^A0N,15,17^FDDESIGNACAO^FS"
	@ 0,0 PSAY "^FO578,244^A0N,35,15^FD" + AllTrim(SB1->B1_XDESIG) + "^FS"
	@ 0,0 PSAY "^FO016,282^A0N,15,17^FDN. PEDIDO^FS"

	_lUsaAcond := .F.
	aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
	If SZE->ZE_PEDIDO # "000001" // Pesagens que vão para o estoque... não existe o pedido 000001
		_lUsaAcond := Left(SA1->A1_CGC,8) $ GetMv("MV_XTRCCOD")
		aDadInd    := u_InfTrian(xFilial("SZE"),SZE->ZE_PEDIDO,"CDBAL03")
		/*/
		Retorno da InfTrian
		[1]PEDIDO
		[2]A1_NOME
		[3]A1_NREDUZ
		[4]A1_MUN
		[5]A1_EST
		[6]A1_CGC
		[7]A1_TEL
		/*/
		If Len(aDadInd) = 0
			aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
		Else
			_lUsaAcond := Left(aDadInd[1,6],8) $ GetMv("MV_XTRCCOD")
		EndIf
	EndIf

	If !Empty(aDadInd[1,1])
		@ 0,0 PSAY "^FO036,306^A0N,35,30^FD" + aDadInd[1,1] + "^FS"
	Else
		@ 0,0 PSAY "^FO036,306^A0N,35,30^FD" + AllTrim(SZE->ZE_PEDIDO) + "^FS"
	EndIf
	// Fim Código Novo

	@ 0,0 PSAY "^FO192,282^A0N,15,17^FDCLIENTE^FS"

	If !Empty(aDadInd[1,2])
		@ 0,0 PSAY "^FO192,306^A0N,35,30^FD" + Substr(AllTrim(aDadInd[1,2]),6,60) + "^FS"
	Else
		@ 0,0 PSAY "^FO192,306^A0N,35,30^FD" + AllTrim(SZE->ZE_NOMCLI) + "^FS"
	EndIf
	// Fim Código Novo

	@ 0,0 PSAY "^FO016,347^A0N,15,17^FDN. BOBINA^FS"
	@ 0,0 PSAY "^FO036,368^A0N,35,30^FD" + AllTrim(SZE->ZE_NUMBOB) + "^FS"
	@ 0,0 PSAY "^FO192,347^A0N,15,17^FDDESTINO^FS"
	@ 0,0 PSAY "^FO192,368^A0N,30,25^FD" + IIF(Empty(aDadInd[1,4]),AllTrim(SZE->ZE_DESTINO),Alltrim(aDadInd[1,4])+"-"+aDadInd[1,5]) + "^FS"
	@ 0,0 PSAY "^FO016,406^A0N,15,17^FDLOTE / DATA^FS"

	// Forçar a data com o século
	_cDataB := DtoS(SZE->ZE_DATA)
	_cDataB := Right(_cDataB,2) + "/" + Substr(_cDataB,5,2) + "/" + Left(_cDataB,4)

	_xCodBars := SB1->B1_CODBAR
	DbSelectArea("SZJ")
	DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ

	// Se _lUsaAcond e for bobina, localizar sempre um codbar genérico
	/*/
	Retorno da InfTrian no array aDadInd
	[1]PEDIDO
	[2]A1_NOME
	[3]A1_NREDUZ
	[4]A1_MUN
	[5]A1_EST
	[6]A1_CGC
	[7]A1_TEL
	/*/
	If _lUsaAcond
		// Procurar sempre um codbar de uma bobina genérica
		_cLczNow := Padr("B",TamSX3("ZJ_LOCALIZ")[1])
		DbSelectArea("SZJ")
		DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
		If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
			_xCodBars := SZJ->ZJ_CODBAR
		Else
			_xCodBars := u_NewSzj(SB1->B1_COD,_cLczNow)
		EndIf
	Else
		//Procuro primeiro um codbar específico e depois um genérico
		_cLczNow := Padr(("B" + StrZero(SZE->ZE_QUANT,5)),TamSX3("ZJ_LOCALIZ")[1])
		If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
			// Procuto primeiro um GTIN para a bobina exata.
			_xCodBars := SZJ->ZJ_CODBAR
		Else
			_cLczNow := Padr("B",TamSX3("ZJ_LOCALIZ")[1])
			DbSelectArea("SZJ")
			DbSetOrder(1) //ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
			If DbSeek(xFilial("SZJ") + SB1->B1_COD + _cLczNow,.F.)
				_xCodBars := SZJ->ZJ_CODBAR
			Else
				_xCodBars := u_NewSzj(SB1->B1_COD,_cLczNow)
			EndIf
		EndIf
	EndIf

	@ 0,0 PSAY "^FO016,430^A0N,30,15^FD" + AllTrim(SZE->ZE_LOTE) + " / " +  _cDataB + "^FS"
	@ 0,0 PSAY "^FO192,406^A0N,15,17^FDTARA^FS"
	@ 0,0 PSAY "^FO192,430^A0N,30,15^FD" + Transform(SZE->ZE_TARA,"@E 999.99") + " kg^FS"
	@ 0,0 PSAY "^FO256,406^A0N,15,17^FDMASSA BRUTA^FS"
	@ 0,0 PSAY "^FO288,430^A0N,30,15^FD" + Transform(SZE->ZE_PESO,"@E 9999.99") + "kg^FS"
	@ 0,0 PSAY "^FO376,406^A0B,15,17^FDSITUACAO DE INSPECAO^FS"
	@ 0,0 PSAY "^FX ====== QUADRADO APROVADO =============================== ^FS"
	@ 0,0 PSAY "^FO400,555^GB32,32,4^FS"
	@ 0,0 PSAY "^FO405,565^A0B,30,30^FDx^FS"
	@ 0,0 PSAY "^FO405,410^A0B,34,30^FDAPROVADO^FS"
	@ 0,0 PSAY "^FX ====== CODIGO DE BARRAS ================================ ^FS"
	@ 0,0 PSAY "^FO048,484^BY3,,60^BEN,70,Y,N^FD" + Left(AllTrim(_xCodBars),12) + "^FS"
	@ 0,0 PSAY "^FO702,376^BY2,,60^BUB,80,Y,N,N^FD" + "96" + SZE->ZE_FILORIG + StrZero(Val(SZE->ZE_NUMBOB),7) + "^FS"
	@ 0,0 PSAY "^FO680,400^A0B,20,25^FD" + AllTrim(SB1->B1_COD) + "^FS"
	@ 0,0 PSAY "^FX ====== SELO SEC ================================ ^FS"
	@ 0,0 PSAY "^FO440,340^XG"+ cSeloSec +"^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =                   Fim da Etiqueta                    = ^FS"
	@ 0,0 PSAY "^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^PQ"+AllTrim(Str(_nVias))+"^FS"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)



/*/{Protheus.doc} ImprBolet
//TODO Imprime Boletim.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param nVias, numeric, descricao
@param _lInsp, , descricao
@type function
/*/
User Function ImprBolet(nVias,_lInsp)
	Default _lInsp  := .F.
	Private wnrel   := "BOLETIM"
	Private cString := "BOLETIM"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,"LPT1","",1}

	SetDefault(aReturn,cString)
	_nLin := 80
	_cOper := SZL->ZL_OPER
	_cNOpe := SZL->ZL_NOMOPER
	@ 0,0 PSay Chr(27) + "@"
	@ 0,0 PSay Chr(27)+'C'+CHR(33)

	DbSelectArea("SZL")

	_aAreaSZL := SZL->(GetArea())
	_cNumPes := SZL->ZL_NUM
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM

	SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.)) // Dou um DbSeek pois pode haver mais de um registro com o mesmo nro.da pesagem
	_nPesEmb := 0.00
	_nQtLnc  := 0
	_nMetros := 0
	_nPspdr  := 0
	_nTtEmb  := 0
	//DbSeek(xFilial("SZL")+_cNumPes,.F.)
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _cNumPes .And. SZL->(!Eof())
		_nPesEmb += SZL->ZL_EMB
		_nQtLnc  += SZL->ZL_QTLANCE
		_nMetros += SZL->ZL_METROS
		_nPspdr  += SZL->ZL_PESPADR
		_nTtEmb  += SZL->ZL_EMB
		SZL->(DbSkip())
	EndDo

	SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.))
	_nPesLiq := (SZL->ZL_PBRUT - SZL->ZL_TARA - _nPesEmb)
	_nDesvio := ((_nPesLiq - _nPspdr) / _nPspdr) * 100
	If (_nDesvio < _nDesMin .Or. _nDesvio > _nDesMax) .And. nVias == 2
		_nVias := 2
	Else
		_nVias := 1
	EndIf

	For _nViasImp := 1 To _nVias
		_ImpCab := .T.
		SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.))
		_nPesLiq := (SZL->ZL_PBRUT - SZL->ZL_TARA - _nPesEmb)
		_lEspc := (Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_ESPECIA") # "01")
		Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _cNumPes .And. SZL->(!Eof())
			If _ImpCab
				_ImpCab := .F.

				@ 01,00 Psay "Numero:"
				@ 01,08 Psay SZL->ZL_NUM
				If SZL->ZL_TIPO $ "PD"
					@ 01,15 Psay "- Producao"
				ElseIf SZL->ZL_TIPO=="R"
					@ 01,15 Psay "- Ret.Retrab."
				ElseIf SZL->ZL_TIPO=="T"
					@ 01,15 Psay "- Troca Etiq."
				ElseIf SZL->ZL_TIPO=="F"
					@ 01,15 Psay "- Troca Filial"
				ElseIf SZL->ZL_TIPO=="S"
					@ 01,15 Psay "- Sucata"
				ElseIf SZL->ZL_TIPO=="U"
					@ 01,15 Psay "- Prod. UnMov"
				EndIf
				@ 01,31 Psay "Lote:"
				@ 01,37 Psay SZL->ZL_LOTE
				@ 01,54 Psay "Data:"
				@ 01,60 Psay SZL->ZL_DATA
				@ 01,71 Psay Left(SZL->ZL_HORA,5)+"h"

				@ 03,00 Psay "Peso Bruto:"
				@ 03,12 Psay SZL->ZL_PBRUT Picture "@E 9,999.99"
				@ 03,22 Psay "Tara:"
				@ 03,28 Psay SZL->ZL_TARA Picture "@E 9,999.99"
				@ 03,38 Psay "Peso Liq.:"
				@ 03,49 Psay _nPesLiq Picture "@E 9,999.999"
				@ 03,60 Psay "% Desvio.:"

				If SZL->ZL_TIPO=="S"
					@ 03,71 Psay 0.00 Picture "@E 999.999"
				Else
					@ 03,71 Psay ((_nPesLiq - _nPspdr) / _nPspdr) * 100  Picture "@E 999.999"
				EndIf

				@ 05,00 Psay "Nro. OP.:"
				@ 05,10 Psay SZL->ZL_NUMOP Picture "@R XXXXXX-XX"

				_cDesPrd := Alltrim(SZL->ZL_DESC)
				If Right(_cDesPrd,3) == "(E)"
					_cDesPrd := AllTrim(Left(_cDesPrd,Len(_cDesPrd)-3))
				EndIf
				_cDesPr2 := ""
				If Len(_cDesPrd) > 34 // Não cabe tudo na mesma linha
					_nUltPs := 34
					For _nPs := 1 to 34 // Quantidade qua cabNe na linha
						If Substr(_cDesPrd,_nPs,1) == " " .And. _nPs <= 35
							_nUltPs := _nPs
						EndIf
					Next
					_cDesPr2 := AllTrim(AllTrim(Substr(_cDesPrd,_nUltPs+1,100)) + " " + _cDesPr2)
					_cDesPrd := AllTrim(Left(_cDesPrd,_nUltPs))

					If Len(_cDesPr2) > 34 .Or. Len(_cDesPrd) > 34
						_cDesPrd := _cDesPrd+" "+_cDesPr2
						_cDesPr2 := AllTrim(Substr(_cDesPrd,35,100))
						_cDesPrd := Left(_cDesPrd,34)
					EndIf
				EndIf

				//@ 05,22 Psay "Produto: " + AllTrim(SZL->ZL_PRODUTO) + " - " + Left(SZL->ZL_DESC,38)
				@ 05,22 Psay "Produto: " + AllTrim(SZL->ZL_PRODUTO) + " - " + _cDesPrd
				@ 06,44 Psay _cDesPr2

				If SZL->ZL_TIPO == "R" // Retorno de retrabalho
					@ 07,01 Psay "Acond.   ID.Retr. Tam.Lance  Qtd.Lances  Total     UM Peso Padrao  Ps.Embal."
				Else
					@ 07,01 Psay "Acond.   UnMov    Tam.Lance  Qtd.Lances  Total     UM Peso Padrao  Ps.Embal."
				EndIf
				@ 08,01 Psay "-----------------------------------------------------------------------------"
				_nLin := 09
			EndIf

			If SZL->ZL_TIPO # "S" // Sucata não imprime detalhes
				If SZL->ZL_ACOND == "R"
					_cAcond := "Rolo"
				ElseIf SZL->ZL_ACOND == "B"
					_cAcond := SZL->ZL_NUMBOB ///"Bobina"
				ElseIf SZL->ZL_ACOND == "M"
					_cAcond := "Car.Madeira"
				ElseIf SZL->ZL_ACOND == "C"
					_cAcond := "Carretel N8"
				ElseIf SZL->ZL_ACOND == "T"
					_cAcond := "Retalho"
				ElseIf SZL->ZL_ACOND == "L" //Gustavo Fuentes 12/06/2013
					_cAcond := "Blister"
				EndIf

				DbSelectArea("SB1")
				DBSetOrder(1)
				DbSeek(xFilial("SB1")+AllTrim(SZL->ZL_PRODUTO),.F.)

				@ _nLin,01 Psay _cAcond
				If SZL->ZL_TIPO == "R"
					@ _nLin,10 Psay SZL->ZL_ZZEID
				Else
					@ _nLin,10 Psay SZL->ZL_UNMOV   Picture "@E 9999999999"
				EndIf
				@ _nLin,22 Psay SZL->ZL_LANCE   Picture "@E 99,999"
				@ _nLin,34 Psay SZL->ZL_QTLANCE Picture "@E 99,999"
				@ _nLin,42 Psay SZL->ZL_METROS  Picture "@E 999999.99"
				@ _nLin,52 Psay SB1->B1_UM		Picture "@!"
				@ _nLin,56 Psay SZL->ZL_PESPADR Picture "@E 99,999.999"
				@ _nLin,68 Psay SZL->ZL_EMB     Picture "@E 99,999.99"
			EndIf

			SZL->(DbSkip())
			If ++_nLin > 23
				_ImpCab := .T.
			EndIf
		EndDo
		@ _nLin++,01 Psay "-----------------------------------------------------------------------------"
		@ _nLin,01 Psay "Totais"
		@ _nLin,34 Psay _nQtLnc  Picture "@E 99,999"
		@ _nLin,42 Psay _nMetros Picture "@E 999999.99"
		@ _nLin,56 Psay _nPspdr  Picture "@E 99,999.999"
		@ _nLin,68 Psay _nTtEmb  Picture "@E 99,999.99"

		If _lEspc // Produto especial
			_nLin += 2
			@ _nLin,00 Psay "** ESPECIAL **"
		EndIf

		If _lInsp	// Dar mensagem que o material tem que ser enviado para CQ
			_nLin += 3
			@ _nLin,00 Psay "ENVIAR MATERIAL PARA INSPECAO NO C.Q."
		EndIf
		@ 27,00 Psay "-----------------------------------          -----------------------------------"
		@ 28,00 Psay AllTrim(_cOper) + "-" + AllTrim(_cNOpe)
		@ 28,45 Psay "C. Q."
	Next
	@ 0,0 PSay Chr(27) + "@"
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	SET DEVICE TO SCREEN
	MS_FLUSH()
	RestArea(_aAreaSZL)
Return(.T.)

/*/{Protheus.doc} ImprBol1
//TODO Impressão do BMM em modelo Grafico com Codigo de barras.
@author juliana.leme
@since 24/08/2016
@version 1.0
@param nVias, numeric, Numero de vias para impressão
@param _lInsp, lógical, BMM requer inspeção do CQ
@type function
/*/
User Function ImprBol1(nVias,_lInsp)
	local lCbcWms   	:= GetNewPar('ZZ_ICBCWMS', .F.)
	local nLin 			:= 0
	local nLin2 		:= 0
	local lIsCq			:= 0
	local nLimit		:= 145
	private oFont10 	:= TFont():New( "Arial",,10,,.T.,,,,   ,.F.)
	private oFont12 	:= TFont():New( "Arial",,12,,.T.,,,,   ,.F.)
	private oFont12N	:= TFont():New( "Arial",,12,,.T.,,,,.T.,.F.)
	private oFont14N	:= TFont():New( "Arial",,14,,.T.,,,,.T.,.F.)
	private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	private oFont18N	:= TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)
	private oFont20N	:= TFont():New( "Arial",,20,,.T.,,,,.T.,.F.)
	private oFont24N	:= TFont():New( "Arial",,24,,.T.,,,,.T.,.F.)
	private oFont28N	:= TFont():New( "Arial",,28,,.T.,,,,.T.,.F.)
	private oFont30N	:= TFont():New( "Arial",,30,,.T.,,,,.T.,.F.)
	private oFont32N	:= TFont():New( "Arial",,32,,.T.,,,,.T.,.F.)
	private oFont40N	:= TFont():New( "Arial",,40,,.T.,,,,.T.,.F.)
	private oFont42N	:= TFont():New( "Arial",,42,,.T.,,,,.T.,.F.)
	private oFont46N	:= TFont():New( "Arial",,46,,.T.,,,,.T.,.F.)
	private oFont62N	:= TFont():New( "Arial",,62,,.T.,,,,.T.,.F.)
	private cTipoPes	:= ""
	Default _lInsp		:= .F.

	Private oPrn	:= TMSPrinter():New("Boletim BMM")
	Private oPrn2	:= TMSPrinter():New("Identif.BMM2")

	/*
	cImpr	:= "MKT - PB"
	cPorta	:= "USB"
	PreparePrint(.T.,cImpr, .F.,cPorta)
	InitPrint(1,"Boletim BMM","080",,"Boletim")
	*/

	_cOper	:= SZL->ZL_OPER
	_cNOpe	:= SZL->ZL_NOMOPER

	DbSelectArea("SZL")

	_aAreaSZL := SZL->(GetArea())
	_cNumPes := SZL->ZL_NUM
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM

	SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.)) // Dou um DbSeek pois pode haver mais de um registro com o mesmo nro.da pesagem
	_nPesEmb := 0.00
	_nQtLnc  := 0
	_nMetros := 0
	_nPspdr  := 0
	_nTtEmb  := 0
	//DbSeek(xFilial("SZL")+_cNumPes,.F.)
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _cNumPes .And. SZL->(!Eof())
		_nPesEmb += SZL->ZL_EMB
		_nQtLnc  += SZL->ZL_QTLANCE
		_nMetros += SZL->ZL_METROS
		_nPspdr  += SZL->ZL_PESPADR
		_nTtEmb  += SZL->ZL_EMB
		SZL->(DbSkip())
	EndDo

	SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.))
	_nPesLiq := (SZL->ZL_PBRUT - SZL->ZL_TARA - _nPesEmb)
	_nDesvio := ((_nPesLiq - _nPspdr) / _nPspdr) * 100
	If (_nDesvio < _nDesMin .Or. _nDesvio > _nDesMax) .And. nVias == 2
		_nVias := 2
	Else
		_nVias := 1
	EndIf

	oPrn:Setup()
	oPrn:SetPortrait()		// Formato pagina Retrato
	oPrn:SetPaperSize(9)	//Papel A4

	For _nViasImp := 1 To _nVias
		_ImpCab := .T.
		oPrn:StartPage() 		//inicializa pagina por problemas duplicação registro - Renato/Michel

		SZL->(DbSeek(xFilial("SZL")+_cNumPes,.F.))
		_nPesLiq := (SZL->ZL_PBRUT - SZL->ZL_TARA - _nPesEmb)
		_lEspc := (Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_ESPECIA") # "01")
		Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _cNumPes .And. SZL->(!Eof())
			lIsCq := (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax)
			nLanc	:= SZL->ZL_LANCE
			dDataZL	:= SZL->ZL_DATA
			_cDesPrd := Alltrim(SZL->ZL_DESC)
			If Right(_cDesPrd,3) == "(E)"
				_cDesPrd := AllTrim(Left(_cDesPrd,Len(_cDesPrd)-3))
			EndIf
			_cDesPr2 := ""
			If Len(_cDesPrd) > 40 // Não cabe tudo na mesma linha
				_nUltPs := 40
				For _nPs := 1 to 34 // Quantidade qua cabNe na linha
					If Substr(_cDesPrd,_nPs,1) == " " .And. _nPs <= 35
						_nUltPs := _nPs
					EndIf
				Next
				_cDesPr2 := AllTrim(AllTrim(Substr(_cDesPrd,_nUltPs+1,100)) + " " + _cDesPr2)
				_cDesPrd := AllTrim(Left(_cDesPrd,_nUltPs))

				If Len(_cDesPr2) > 34 .Or. Len(_cDesPrd) > 34
					_cDesPrd := _cDesPrd+" "+_cDesPr2
					_cDesPr2 := AllTrim(Substr(_cDesPrd,35,100))
					_cDesPrd := Left(_cDesPrd,34)
				EndIf
			EndIf
			If SZL->ZL_ACOND == "R"
				_cAcond := "ROLO"
			ElseIf SZL->ZL_ACOND == "B"
				_cAcond := SZL->ZL_NUMBOB ///"Bobina"
			ElseIf SZL->ZL_ACOND == "M"
				_cAcond := "CAR.MAD."
			ElseIf SZL->ZL_ACOND == "C"
				_cAcond := "CARR.N8"
			ElseIf SZL->ZL_ACOND == "T"
				_cAcond := "RETALHO"
			ElseIf SZL->ZL_ACOND == "L"
				_cAcond := "BLISTER"
			EndIf
			If _ImpCab
				_ImpCab := .F.
				mntHeader(0, @nLin)
				if lIsCq
					mntHeader(nLimit, @nLin2)
				endif
			endif
			mntBody(0, @nLin, lCbcWms)
			if lIsCq
				mntBody(nLimit, @nLin2, .F.)
			endif
			SZL->(DbSkip())
			If nLin > nLimit
				_ImpCab := .T.
			EndIf
		EndDo

		mntTail(@nLin, lCbcWms, _lInsp)
		if lIsCq
			mntTail(@nLin2, .F., _lInsp)
		endif
		//Codigo de Barras
		nCo 	:= 16.6
		nLi 	:= 0.5
		_cCdBar	:= "9"+StrZero(Val(_cNumPes),10) // Tem que ter 11 dígitos para imprimir o tipo UPCA
		MSBAR3("UPCA",nLi,nCo,_cCdBar,oPrn,.F.,Nil,Nil,0.030 ,1.5,.F.,NIL,NIL)//Codigo Correto
		oPrn:EndPage() // Encerra a página atual
	Next
	RestArea(_aAreaSZL)
Return(.T.)

static function mntHeader(nLinIni, nLin)
	default nLinIni := 0
	oPrn:Say(GPixel(nLinIni + 5),GPixel(5),"COBRECOM",oFont16N)
	oPrn:Say(GPixel(nLinIni + 5),GPixel(55),"  BMM - NUMERO: " + _cNumPes ,oFont16N)

	//oPrn:Say(GPixel(15),GPixel(5),"Num: " + ,oFont18)
	oPrn:Say(GPixel(nLinIni + 15),GPixel(5),"NRO.OP: " + SZL->ZL_NUMOP,oFont12N)//Picture "@R XXXXXX-XX"
	If SZL->ZL_TIPO $ "PD"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (PRODUCAO)",oFont12N)
	ElseIf SZL->ZL_TIPO=="R"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (RET.RETRAB.)",oFont12N)
	ElseIf SZL->ZL_TIPO=="T"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (TR.ETIQ.)",oFont12N)
	ElseIf SZL->ZL_TIPO=="F"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (TR.FILIAL)",oFont12N)
	ElseIf SZL->ZL_TIPO=="S"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (SUCATA)",oFont12N)
		cTipoPes := "S"
	ElseIf SZL->ZL_TIPO=="U"
		oPrn:Say(GPixel(nLinIni + 15),GPixel(41)," (PROD.UNMOV)",oFont12N)
	EndIf

	oPrn:Say(GPixel(nLinIni + 15),GPixel(75)	,"LOTE: " + SZL->ZL_LOTE,oFont12N)
	oPrn:Say(GPixel(nLinIni + 15),GPixel(115)	,"DATA: " + DtoC(SZL->ZL_DATA) +"  " + Left(SZL->ZL_HORA,5) + "h",oFont12N)

	oPrn:Say(GPixel(nLinIni + 22),GPixel(5)	,"PES.BRUT: "+ Transform(SZL->ZL_PBRUT,"@E 9,999.99") ,oFont12N)
	oPrn:Say(GPixel(nLinIni + 22),GPixel(47)	,"TARA: "+ Transform(SZL->ZL_TARA,"@E 9,999.99") ,oFont12N)
	oPrn:Say(GPixel(nLinIni + 22),GPixel(82)	,"PES.LIQ: "+ Transform(_nPesLiq,"@E 9,999.999") ,oFont12N)
	oPrn:Say(GPixel(nLinIni + 22),GPixel(124)	,"%DESVIO: " ,oFont12N)

	If SZL->ZL_TIPO=="S"
		oPrn:Say(GPixel(nLinIni + 22),GPixel(145)," 0.00" ,oFont12N)//Picture "@E 999.999"
	Else
		oPrn:Say(GPixel(nLinIni + 22),GPixel(145),Transform((((_nPesLiq - _nPspdr) / _nPspdr) * 100),"@E 999.999") ,oFont12N)
	EndIf

	oPrn:Say(GPixel(nLinIni + 29),GPixel(5),"PRODUTO: " + AllTrim(SZL->ZL_PRODUTO) + " - " + _cDesPrd,oFont14N)
	oPrn:Say(GPixel(nLinIni + 36),GPixel(5),"         " + _cDesPr2,oFont14N)//Picture "@R XXXXXX-XX"

	oPrn:Line(GPixel(nLinIni + 40),GPixel(4),GPixel(nLinIni + 40),GPixel(203))
	If SZL->ZL_TIPO == "R" // Retorno de retrabalho
		oPrn:Line(GPixel(nLinIni + 40),GPixel(4),GPixel(nLinIni + 50),GPixel(4))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(5)	,"ACOND."	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(27),GPixel(nLinIni + 50),GPixel(27))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(28)	,"ID.RETR."	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(54),GPixel(nLinIni + 50),GPixel(54))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(55)	,"TAM.LNC",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(77),GPixel(nLinIni + 50),GPixel(77))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(78)	,"QTD.LNC"	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(97),GPixel(nLinIni + 50),GPixel(97))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(98)	,"   TOTAL"	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(122),GPixel(nLinIni + 50),GPixel(122))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(123)	,"UM"		,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(134),GPixel(nLinIni + 50),GPixel(134))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(135)	,"PS.PADRAO",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(170),GPixel(nLinIni + 50),GPixel(170))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(171)	,"PS.EMBAL.",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(205),GPixel(nLinIni + 50),GPixel(205))
	Else
		oPrn:Line(GPixel(nLinIni + 40),GPixel(4),GPixel(nLinIni + 50),GPixel(4))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(5)	,"ACOND."	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(27),GPixel(nLinIni + 50),GPixel(27))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(28)	,"UNMOV"	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(54),GPixel(nLinIni + 50),GPixel(54))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(55)	,"TAM.LNC",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(77),GPixel(nLinIni + 50),GPixel(77))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(78)	,"QTD.LNC"	,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(97),GPixel(nLinIni + 50),GPixel(97))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(98)	,"     TOTAL",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(122),GPixel(nLinIni + 50),GPixel(122))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(123)	,"UM."		,oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(134),GPixel(nLinIni + 50),GPixel(134))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(135)	,"PS.PADRAO",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(170),GPixel(nLinIni + 50),GPixel(170))
		oPrn:Say(GPixel(nLinIni + 43),GPixel(171)	,"PS.EMBAL.",oFont12N)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(203),GPixel(nLinIni + 50),GPixel(203))
	EndIf
	//oPrn:Line(GPixel(50),GPixel(4),GPixel(50),GPixel(203))
	nLin := nLinIni + 51
return(nil)

static function mntBody(nLinIni, nLin, lCbcWms)
	default nLinIni := 0

	If SZL->ZL_TIPO # "S" // Sucata não imprime detalhes
		DbSelectArea("SB1")
		DBSetOrder(1)
		DbSeek(xFilial("SB1")+AllTrim(SZL->ZL_PRODUTO),.F.)

		oPrn:Line(GPixel(nLinIni + 40),GPixel(4),GPixel(nLin + 7),GPixel(4))
		oPrn:Say(GPixel(nLin),GPixel(5)	,_cAcond,oFont12)

		oPrn:Line(GPixel(nLinIni + 40),GPixel(27),GPixel(nLin+7),GPixel(27))
		If SZL->ZL_TIPO == "R"
			oPrn:Say(GPixel(nLin),GPixel(28)	,SZL->ZL_ZZEID		,oFont12)
		Else
			oPrn:Say(GPixel(nLin),GPixel(28),Transform(SZL->ZL_UNMOV,"@E 999999999"),oFont12)
		EndIf

		oPrn:Line(GPixel(nLinIni + 40),GPixel(54),GPixel(nLin+7),GPixel(54))
		oPrn:Say(GPixel(nLin),GPixel(55)	,Transform(SZL->ZL_LANCE,"@E 99,999")		,oFont12)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(77),GPixel(nLin+7),GPixel(77))
		oPrn:Line(GPixel(nLinIni + 40),GPixel(97),GPixel(nLin+7),GPixel(97))
		if !lCbcWms				
			oPrn:Say(GPixel(nLin),GPixel(78)	,Transform(SZL->ZL_QTLANCE,"@E 99,999")		,oFont12)
			oPrn:Say(GPixel(nLin),GPixel(98)	,Transform(SZL->ZL_METROS,"@E 999999.99")	,oFont12)
		endif			
		oPrn:Line(GPixel(nLinIni + 40),GPixel(122),GPixel(nLin+7),GPixel(122))
		oPrn:Say(GPixel(nLin),GPixel(123)	," " + SB1->B1_UM							,oFont12)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(134),GPixel(nLin+7),GPixel(134))
		oPrn:Say(GPixel(nLin),GPixel(145)	,Transform(SZL->ZL_PESPADR,"@E 99,999.999")	,oFont12)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(170),GPixel(nLin+7),GPixel(170))
		oPrn:Say(GPixel(nLin),GPixel(176)	,Transform(SZL->ZL_EMB,"@E 99,999.99")		,oFont12)
		oPrn:Line(GPixel(nLinIni + 40),GPixel(203),GPixel(nLin+7),GPixel(203))

		

		oPrn:Line(GPixel(nLin),GPixel(4),GPixel(nLin),GPixel(203))
		nLin := nLin +7
	EndIf
return(nil)

static function mntTail(nLin, lCbcWms, _lInsp)
	oPrn:Line(GPixel(nLin),GPixel(4),GPixel(nLin),GPixel(203))
	nLin := nLin + 7
	oPrn:Say(GPixel(nLin),GPixel(51)	," TOTAIS :",oFont12)
	if !lCbcWms	
		oPrn:Say(GPixel(nLin),GPixel(78)	,Transform(_nQtLnc,"@E 99,999"),oFont12)
		oPrn:Say(GPixel(nLin),GPixel(98)	,Transform(_nMetros,"@E 999999.99"),oFont12)
	endif
	oPrn:Say(GPixel(nLin),GPixel(145)	,Transform(_nPspdr, "@E 99,999.999"),oFont12)
	oPrn:Say(GPixel(nLin),GPixel(176)	,Transform(_nTtEmb, "@E 99,999.99"),oFont12)

	If _lEspc // Produto especial
		nLin := nLin + 7
		oPrn:Say(GPixel(nLin),GPixel(5)	,"** ESPECIAL **",oFont12N)
	EndIf

	If _lInsp	// Dar mensagem que o material tem que ser enviado para CQ
		nLin := nLin + 7
		oPrn:Say(GPixel(nLin),GPixel(5)	,"ENVIAR MATERIAL PARA INSPECAO NO C.Q.",oFont12N)
	EndIf
	nLin += 30
	oPrn:Say(GPixel(nLin),GPixel(5)	,"_________________________________",oFont12N)
	oPrn:Say(GPixel(nLin),GPixel(110),"_________________________________",oFont12N)
	oPrn:Say(GPixel(nLin + 07),GPixel(5),AllTrim(_cOper) + "-" + AllTrim(_cNOpe),oFont12N)
	oPrn:Say(GPixel(nLin + 07),GPixel(115),"C. Q.",oFont12N)
	oPrn:Line(GPixel(nLin +15),GPixel(4),GPixel(nLin +15),GPixel(203))
return(nil)


/*/{Protheus.doc} ConfFun
//TODO Esta função além de identificar o usuário verificará a integridade dos dados,
		pois não pode haver dois códigos iguais como ativo..
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfFun()
	_nQtd := 0
	_nRegSZS := 0
	DbSelectArea("SZS")
	SZS->(DbSetOrder(1)) // ZS_FILIAL+ZS_CODIGO
	DbSeek(xFilial("SZS")+M->_ZL_OPER,.F.)
	Do While SZS->ZS_FILIAL == xFilial("SZS") .And. SZS->ZS_CODIGO == M->_ZL_OPER .And. SZS->(!Eof())
		If SZS->ZS_ATIVO == "S"
			_nQtd++
			_nRegSZS := Recno()
		EndIf
		SZS->(DbSkip())
	EndDo
	If _nQtd == 0
		Alert("Operador não Cadastrado")
		Return(.F.)
	ElseIf _nQtd > 1
		Alert("Operador Inválido! Cadastrado em Duplicidade")
		Return(.F.)
	EndIf
	SZS->(DbGoTo(_nRegSZS))
	M->_ZL_NOMOPER := SZS->ZS_NOME
Return(.T.)

/*/{Protheus.doc} ConfOP
//TODO Confere OP.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfOP()
	DbSelectArea("SC2")
	SC2->(DbSetOrder(1))
	If !DbSeek(xFilial("SC2")+M->_ZL_NUMOP+"001",.F.)
		Alert("O.P. não Cadastrada")
		Return(.F.)
	EndIf
	If Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_TIPO") # "PA"
		Alert("O.P. Inválida")
		Return(.F.)
	ElseIf Empty(Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_CODBAR"))
		Alert("Solicitar Cadastro do Cód. de Barras")
		Return(.F.)
	EndIf
	M->_ZL_PROD := Left(SC2->C2_PRODUTO,10)
	M->_ZL_DESC    := Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC")

	// Matar qualquer acols que exista
	aCols:={Array(nUsado+1)}
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	aCols[1,nUsado+1]:=.F.

	u_SomeAcols()

	u_Refbal03()

Return(.T.)


/*/{Protheus.doc} ConfPro
//TODO Descrição auto-gerada.
@author juliana.leme
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfPro()
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !DbSeek(xFilial("SB1")+M->_ZL_PROD,.F.)
		Alert("Produto Não Cadastrado")
		Return(.F.)
	ElseIf SB1->B1_TIPO # "PA"
		Alert("Somente Produtos Acabados Podem ser Movimentados")
		Return(.F.)
	ElseIf Empty(SB1->B1_CODBAR)
		Alert("Solicitar Cadastro do Cód. de Barras")
		Return(.F.)
		//ElseIf M->_ZL_TIPO == "R" .And. !Empty(M->_ZL_BMMORI) .And. !Empty(M->_ZL_IBMMORI)
		//	DbSelectArea("SZB")
		//	SZB->(DbSetOrder(1))
		//	DbSeek(xFilial("SZB")+M->_ZL_BMMORI+M->_ZL_IBMMORI,.F.)
		//	If SZB->ZB_PRODUTO # M->_ZL_PROD
		//		Alert("Produtos do BMM Origem e Digitado não Conferem")
		//		Return(.F.)
		//	EndIf
	ElseIf M->_ZL_TIPO == "R" .And. !Empty(M->_ZL_ZZEID)
		DbSelectArea("ZZE")
		ZZE->(DbSetOrder(1)) // ZZE_FILIAL+ZZE_ID
		ZZE->(DbSeek(xFilial("ZZE")+M->_ZL_ZZEID,.F.))
		If ZZE->ZZE-PROTUT # M->_ZL_PROD
			Alert("Produtos do ID Retrab. e Digitado não Conferem")
			Return(.F.)
		EndIf
	EndIf
	M->_ZL_DESC    := SB1->B1_DESC

	// Matar qualquer acols que exista
	aCols:={Array(nUsado+1)}
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	aCols[1,nUsado+1]:=.F.

	u_SomeAcols()

	u_Refbal03()

Return(.T.)


/*/{Protheus.doc} ConfZZE
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _ZL_ZZEID, , descricao
@param _ZL_PROD, , descricao
@type function
/*/
User Function ConfZZE(_ZL_ZZEID,_ZL_PROD)
	If Empty(M->_ZL_ZZEID)
		Alert("Para Retorno de Retrabalho Obrigatório o ID")
		Return(.F.)
	EndIF

	// Verifica se todos os os itens desse ID estão encerrados
	DbSelectArea("ZZE")
	ZZE->(DbSetOrder(1)) // ZZE_FILIAL+ZZE_ID
	If !ZZE->(DbSeek(xFilial("ZZE")+M->_ZL_ZZEID,.F.))
		Alert("ID Retrabalho não Cadastrado")
		Return(.F.)
	ElseIf ZZE->ZZE_SITUAC == "1"
		Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
			"Pesagem já Encerrada." + chr(13) + chr(13) + ;
			"Comunique o PCP")
		Return(.F.)
	ElseIf !Empty(M->_ZL_PROD)// .And. _lRolo
		If ZZE->ZZE_PRODUT # M->_ZL_PROD
			Alert("Produtos do ID do Retrab. e Digitado não Conferem")
			Return(.F.)
		EndIf
	EndIf
	_lVolta := .F. // Assumo tudo encerrado
	_lRetOS := .T. //
	Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == M->_ZL_ZZEID .And. ZZE->(!Eof())
		If ZZE->ZZE_STATUS == '3' // EM RETRABALHO ..
			_lVolta := .T. // Achei um cara ainda não encerrado
			Exit
		ElseIf ZZE->ZZE_STATUS == '2' // OS ainda não Emitida
			_lRetOS := .F.
		EndIf
		ZZE->(DbSkip())
	EndDo
	If !_lVolta // Não achei nenhum em aberto
		If !_lRetOS
			Alert("O.S. Ainda não Emitida para Esse Retrabalho. Contate PCP")
		Else
			Alert("ID Retrabalho já Finalizado")
		EndIf
	ElseIf _cTiAcd == "R"
		ZZE->(DbSeek(xFilial("ZZE")+M->_ZL_ZZEID,.F.))
		M->_ZL_PROD := PadR(Left(ZZE->ZZE_PRODUT,10),TamSX3("B1_COD")[1])
		M->_ZL_DESC := Posicione("SB1",1,xFilial("SB1")+M->_ZL_PROD,"B1_DESC")

		// Matar qualquer acols que exista
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.

		u_SomeAcols()

		u_Refbal03()
	EndIf

Return(_lVolta)


/*/{Protheus.doc} ConfTpPU
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfTpPU()
	// Chamada desta função no X3_VLDUSER
	If !(GetMV("MV_PESBAL")) .and. M->_ZL_TIPO == "P" .and. (_cTiAcd == "B")
		_lVolta := .T.
		Alert("Tipo 'P'(Produção) não esta liberado, utilizar tipo 'U'(UnMov)")
		Return(.F.)
	EndIf
Return(.T.)


/*/{Protheus.doc} ConfTipo
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfTipo()
	If Empty(M->_ZL_TIPO)
		Alert("Informar o Tipo da Pesagem")
		Return(.F.)
	EndIf

	_lVolta := .F.
	For _nVezBox := 1 To Len(_aTpsBox)
		If _aTpsBox[_nVezBox,2] == M->_ZL_TIPO .And. !M->_ZL_TIPO $ "TF" // Troca de etiqueta não pode ser feita aqui
			_cTpsBox := Left(_aTpsBox[_nVezBox,3] + Space(15),15)
			_lVolta := .T.
			Exit
		EndIf
	Next

	If !(GetMV("MV_PESBAL")) .and. M->_ZL_TIPO == "P"
		_lVolta := .T.
		Alert("Tipo 'P'(Produção) não esta liberado, utilizar tipo 'U'(UnMov)")
		Return(.F.)
	EndIf

	If !_lVolta
		Alert("Informar o Tipo da Pesagem")
	ElseIf M->_ZL_TIPO == "R" // Se for retrabalho
		//	MsgAlert("As Pesagens de Retorno de Retrabalho Devem Ser Feitas como Produção!","Atencao!")
		//	_lVolta := .F.

		// Zera as variáveis para digitar novamente
		M->_ZL_NUMOP   := CriaVar("ZL_NUMOP")
		M->_ZL_PROD    := CriaVar("ZL_PRODUTO")
		M->_ZL_DESC    := CriaVar("ZL_DESC")
		M->_ZL_ZZEID   := CriaVar("ZL_ZZEID")
		M->_ZL_PEDIDO  := CriaVar("ZL_PEDIDO")
		M->_ZL_ITEMPV  := CriaVar("ZL_ITEMPV")
	ElseIf M->_ZL_TIPO # "R" // Se não for retrabalho
		// Zera as variáveis para digitar novamente
		//M->_ZL_BMMORI  := CriaVar("ZL_BMMORI")
		//M->_ZL_IBMMORI := CriaVar("ZL_IBMMORI")

		M->_ZL_ZZEID   := CriaVar("ZL_ZZEID")
		M->_ZL_PEDIDO  := CriaVar("ZL_PEDIDO")
		M->_ZL_ITEMPV  := CriaVar("ZL_ITEMPV")
	EndIf

	//@ 060,005 Say "        "       Size  30,10
	If M->_ZL_TIPO = "U"
		//@ 060,005 Say "UnMov:"       Size  30,10
		_cDescLt :=  "UnMov:"
	Else
		//@ 060,005 Say "Lote:"       Size  30,10
		_cDescLt :=  "Lote:"
	EndIf()

	o_ZL_LOTE:Refresh()
Return(_lVolta)


/*/{Protheus.doc} PegaPeso
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function PegaPeso()
	M->_ZL_PBRUT   := If(M->_ZL_TIPO=="D",M->_ZL_PBRUT,VejaPeso()) // Prod.acima de 1500Kg não pode pegar o peso da balanca
	M->_ZL_PESOEFE := M->_ZL_PBRUT - M->_ZL_TARA - M->_ZL_EMB
	If M->_ZL_PESPADR == 0
		M->_ZL_DESVIO := 0.00
	Else
		M->_ZL_DESVIO :=((M->_ZL_PESOEFE - M->_ZL_PESPADR) / M->_ZL_PESPADR) * 100
	EndIf
Return(.T.)


/*/{Protheus.doc} ConfBar
//TODO Confere Codigo de Barras.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfBar()
	Local _nTamLc

	If Empty(_cBarrar)
		Return(.T.)
	EndIf
	If Len(AllTrim(_cBarrar)) # 12
		Alert("Informar Corretamente o Código de Barras")
		_cBarrar := Space(13)
		o_cBarr:Refresh()
		Return(.F.)
	EndIf

	_cNewBar := Left(_cBarrar,11)
	_lNewBar := (Val(Right(_cNewBar,5)) > 9000) // Formato novo do cod de barras
	_nDigBb := If(_lNewBar,7,6)

	// Verificar se o 6 ou 7 Dígito é 4 -- não pode ter etiquetas de bobinas desse tipo
	If Substr(StrZero(Val(_cBarrar),12),_nDigBb,1) == "4"
		Alert("Etiqueta de BOBINA, Inválida")
		_cBarrar    := Space(13)
		o_cBarr:Refresh()
		Return(.F.)
	EndIf

	// Validar o Dígito
	_cBarrar := AllTrim(_cBarrar)

	//_My_cBarrar := "0"+Left(_cBarrar,11) // Tiro o dígito e coloco um zero antes
	_nMlt := .T.
	_MyDigit := 0
	For _nCtd := 1 to Len(_cBarrar)-1 // O digito não considero
		If _nMlt
			_MyDigit += (3 * Val(Substr(_cBarrar,_nCtd,1)))
		Else
			_MyDigit += (1 * Val(Substr(_cBarrar,_nCtd,1)))
		EndIf
		_nMlt := (!_nMlt)
	Next

	If (_MyDigit%10) == 0
		_MyDigit := 0
	Else
		_MyDigit := ((Int(_MyDigit / 10) + 1) * 10) - _MyDigit
	EndIf

	If Val(Right(_cBarrar,1)) # _MyDigit
		Alert("Informar Corretamente o Código de Barras")
		_cBarrar    := Space(13)
		o_cBarr:Refresh()
		Return(.F.)
	EndIf

	// Procurar o Produto
	DbSelectArea("SB1")
	SB1->(DbSetOrder(5)) // B1_FILIAL+B1_CODBAR

	If _lNewBar // Formato novo do cod de barras
		If Left(_cBarrar,1) == "9"
			_cCodEan := "789825925"+Substr(_cBarrar,2,3)
		Else
			_cCodEan := "78996747"+Left(_cBarrar,4)
		EndIf
	Else
		_cCodEan := "789825925"+Left(_cBarrar,3)
	EndIf

	DbSelectArea("SZJ")
	SZJ->(DbSetOrder(2)) // ZJ_FILIAL+ZJ_CODBAR
	If SZJ->(DbSeek(xFilial("SZJ")+_cCodEan,.F.))
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SZJ->ZJ_PRODUTO,.F.)

		// Deixo todos iguais com 14 digitos - zeros à esquerda
		_cBarrar := StrZero(Val(_cBarrar),12)
	Else
		If ! SB1->(DbSeek(xFilial("SB1")+_cCodEan,.F.))
			Alert("Código de Barras Inválido")
			_cBarrar    := Space(13)
			o_cBarr:Refresh()
			Return(.F.)
		EndIf
		// Deixo todos iguais com 14 digitos - zeros à esquerda
		_cBarrar := StrZero(Val(_cBarrar),12)

		Do While SB1->B1_FILIAL == xFilial("SB1") .And. Left(SB1->B1_CODBAR,12) == _cCodEan .And. SB1->(!Eof())
			If Substr(SB1->B1_COD,9,2) == Substr(_cBarrar,If(_lNewBar,5,4),2)
				Exit
			EndIf
			SB1->(DbSkip())
		EndDo

		If SB1->B1_FILIAL # xFilial("SB1") .Or. Left(SB1->B1_CODBAR,12) # _cCodEan .Or. SB1->(Eof())
			Alert("Código de Barras Inválido")
			_cBarrar    := Space(13)
			o_cBarr:Refresh()
			Return(.F.)
		EndIf
	EndIf

	If  SB1->B1_COD # M->_ZL_PROD
		Alert("Produto não Corresponde com o Produto da OP/Informado")
		_cBarrar    := Space(13)
		o_cBarr:Refresh()
		Return(.F.)
	EndIf

	If Substr(_cBarrar,If(_lNewBar,7,6),1) == "6"// Se for blister a metragem não pode ser diferente se 15 ou 10 metros
		If _lNewBar
			_nTamBli := Val(Substr(_cBarrar,8,4)) // Tamanho do blister
		Else
			_nTamBli := Val(Substr(_cBarrar,7,5)) // Tamanho do blister
		EndIf
		If !(u_cbcAcInf(Alltrim(SB1->B1_COD), ('L'+StrZero(_nTamBli, 5)),_nTamBli , 1, _nTamBli, .F., .F.,.T.)[1])
			Alert(AllTrim(Str(_nTamBli))+" metros: Tamanho do Lance Inválido para Blister")
			_cBarrar    := Space(13)
			o_cBarr:Refresh()
			Return(.F.)
		EndIf
	ElseIf Substr(_cBarrar,If(_lNewBar,7,6),1) == "5" // Se for Retalho, assumir 1 na quantidade e chamar o validador da quantidade

		// Verificar se tem cadastro para lance de 50 ou de 15 metros
		SZJ->(DbSetOrder(1)) // ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
		If SZJ->(DbSeek(xFilial("SZJ")+SB1->B1_COD,.F.))
			If _lNewBar
				_nTamRet := Val(Substr(_cBarrar,8,4)) // Tamanho do retalho
			Else
				_nTamRet := Val(Substr(_cBarrar,7,5)) // Tamanho do retalho
			EndIf
			_cAcnd   := "" // Tamanhos possíves de corte do retalho
			Do While SZJ->ZJ_FILIAL==xFilial("SZJ") .And. SZJ->ZJ_PRODUTO == SB1->B1_COD .And. SZJ->(!Eof())
				_nTamDeste := Val(Substr(SZJ->ZJ_LOCALIZ,2))
				If _nTamDeste <= _nTamRet // Dá pra cortar neste tamanho
					_cAcnd := _cAcnd + AllTrim(SZJ->ZJ_LOCALIZ) + " ou "
				EndIf
				SZJ->(DbSkip())
			EndDo
			If Len(_cAcnd) > 0
				_cAcnd := Left(_cAcnd,Len(_cAcnd)-4) + "."
				Alert("Enviar para corte em " + _cAcnd)
				_cBarrar    := Space(13)
				o_cBarr:Refresh()
				Return(.F.)
			EndIf
		EndIf
		_nQtdLc := 1
		u_ConfQuant()
		// Chamar o validador da quantidade
		_nQtdLc  := 0.00
		_cBarrar := Space(13)
		o_cBarr:Refresh()
		Return(.F.)
	EndIf

	If _nQtdUnMov > 0
		If _lNewBar
			_nTamLc := Val(Substr(_cBarrar,8,4)) // Tamanho do Lance
		Else
			_nTamLc := Val(Substr(_cBarrar,7,5)) // Tamanho do Lance
		EndIf
		If (_nQtdUnMov % _nTamLc) <> 0 // Divisão não exata - Acondicionamento incorreto
			Alert("Acondicionamento Inválido para essa Unimov")
			_cBarrar    := Space(13)
			o_cBarr:Refresh()
			Return(.F.)
		EndIf
		_nQtdLc :=  (_nQtdUnMov / _nTamLc)
		// Chamar o validador da quantidade
		u_ConfQuant()
		_nQtdLc  := 0.00
		_cBarrar := Space(13)
		_lSoUm      := .F. // Não permitir nova captura do cód de barras.
		o_cBarr:Refresh()
	EndIf
Return(.T.)


/*/{Protheus.doc} ConfQuant
//TODO Confere Quantidade.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ConfQuant()
	local aInfAcondi := {}
	If _nQtdLc < 1
		_cBarrar := Space(13)
		_nQtdLc := 0.00
		u_Refbal03()
		o_cBarr:SetFocus()
		Return(.T.)
	EndIf
	//
	_cNewBar := Left(_cBarrar,11)
	_lNewBar := (Val(Right(_cNewBar,5)) > 9000) // Formato novo do cod de barras

	/*/
	Verificar se está sendo informado o acondicionamento e a quantidade do retrabalho,
	juntamente com o acols já incluído.
	/*/

	If M->_ZL_TIPO == "R" // Retorno do retrabalho
		If _lNewBar
			M->_ZL_METROS := Val(Substr(_cBarrar,8,4))*_nQtdLc
			M->_ZL_ACOND  := Substr("RCMBTL",Val(Substr(_cBarrar,7,1)),1)
			M->_ZL_LANCE  := Val(Substr(_cBarrar,8,4))
		Else
			M->_ZL_METROS := Val(Substr(_cBarrar,7,5))*_nQtdLc
			M->_ZL_ACOND  := Substr("RCMBTL",Val(Substr(_cBarrar,6,1)),1)
			M->_ZL_LANCE  := Val(Substr(_cBarrar,7,5))
		EndIf

		_nTotSai   := 0 // Quantidade a devolver para o acondicionamento
		_nTotDev   := 0 // Quantidade já devolvida nesse acondicionamento
		_nTotSal   := 0 // Saldo a devolver do retrabalho
		_lTemLcs   := .F.

		// Verifico quanto já foi digitado nesta Pesagem
		For _MyN :=1 to Len(aCols)
			If !GDDeleted(_MyN)
				If GDFieldGet("ZL_ACOND",_MyN) == M->_ZL_ACOND .And.;
						GDFieldGet("ZL_LANCE",_MyN) == M->_ZL_LANCE
					M->_ZL_METROS += GDFieldGet("ZL_METROS",_MyN)
				EndIf
			EndIf
		Next

		DbSelectArea("ZZE")
		DbSetOrder(2) // ZZE_FILIAL+ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV
		DbSeek(xFilial("ZZE")+M->_ZL_ZZEID,.F.)
		/*/
		DbSeek(xFilial("ZZE")+M->_ZL_ZZEID+M->_ZL_PEDIDO+M->_ZL_ITEMPV,.F.)
		--Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->(!Eof()) .And. ;
			ZZE->(ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV) == M->_ZL_ZZEID+M->_ZL_PEDIDO+M->_ZL_ITEMPV
		/*/
		Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == M->_ZL_ZZEID .And. ZZE->(!Eof())
			_nTotSal := ZZE->ZZE_SALDO // Saldo a devolver do retrabalho
			If ZZE->(ZZE_PEDIDO+ZZE_ITEMPV) == M->_ZL_PEDIDO+M->_ZL_ITEMPV .And.;
					ZZE->ZZE_ACONDS == M->_ZL_ACOND .And. ZZE->ZZE_METRAS == M->_ZL_LANCE
				_nTotSai += ZZE->ZZE_TOTSA 	// Quantidade a devolver para o acondicionamento
				_nTotDev += ZZE->ZZE_DEVTOT	// Quantidade já devolvida nesse acondicionamento
				_lTemLcs   := .T.
			EndIf
			DbSkip()
		EndDo
		If _ZL_PEDIDO # "000001"
			If !_lTemLcs
				_cAccon := M->_ZL_ACOND + StrZero(M->_ZL_LANCE,5)
				_cBarrar := Space(13)
				_nQtdLc := 0.00
				u_Refbal03()
				o_cBarr:SetFocus()
				Alert("Não há Solicitação de Retrabalho para " + _cAccon)
				Return(.T.)
			ElseIf (M->_ZL_METROS+_nTotDev) > _nTotSai
				_cBarrar := Space(13)
				_nQtdLc := 0.00
				u_Refbal03()
				o_cBarr:SetFocus()
				Alert("Tentativa de Devolver Quantidade Maior que a Solicitada")
				Return(.T.)
			EndIf
		EndIf

		If M->_ZL_METROS > _nTotSal
			_cBarrar := Space(13)
			_nQtdLc := 0.00
			u_Refbal03()
			o_cBarr:SetFocus()
			Alert("Tentativa de Devolver Quantidade Maior que a Solicitada")
			Return(.T.)
		EndIf
	EndIf

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD

	If _ZL_TIPO == "U"
		_nQtdMtrs := (Val(Substr(_cBarrar,8,4))*_nQtdLc)
		_nQtdMtrs += _nQtUnMov
		For _nPPIMts := 1 To Len(aCols)
			If !GDDeleted(_nPPIMts) .And. GDFieldGet("ZL_UNMOV",_nPPIMts) == _nUnMov
				_nQtdMtrs += GDFieldGet("ZL_METROS",_nPPIMts)
			EndIf
		Next
		If _nQtdMtrs <> _nQtdPPi //Maior e ficou diferente para a quantidade ser exata da unmov - Juliana Leme 02/09/2016
			Alert("Quantidade Inválida" + Chr(13) +  Chr(13) + "Quantidade maior que a quantidade produzida nessa Unimov")
			Return(.F.)
		EndIf
	EndIf
	DbSeek(xFilial("SB1")+M->_ZL_PROD,.F.)
	If !(Len(aCols) == 1 .And. GDFieldGet("ZL_METROS",1) == 0)
		Aadd(aCols,Array(Len(aHeader)+1))
		For _ni:=1 to nUsado
			aCols[Len(acols),_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[Len(acols),nUsado+1]:=.F.
	EndIf
	_MyN := Len(aCols)
	If _lNewBar
		GDFieldPut("ZL_METROS" ,Val(Substr(_cBarrar,8,4))*_nQtdLc,_MyN)
		GDFieldPut("ZL_PESPADR",(Val(Substr(_cBarrar,8,4))*_nQtdLc)*SB1->B1_PESBRU,_MyN)
		//1-Rolo, 2-Carretel N8, 3-Carretel Madeira, 4-Bobina , 5-Retalho    , 6-Blister" // Pertence('RBCTML')

		GDFieldPut("ZL_ACOND",Substr("RCMBTL",Val(Substr(_cBarrar,7,1)),1),_MyN)
		GDFieldPut("ZL_LANCE",Val(Substr(_cBarrar,8,4)),_MyN)
	Else
		GDFieldPut("ZL_METROS" ,Val(Substr(_cBarrar,7,5))*_nQtdLc,_MyN)
		GDFieldPut("ZL_PESPADR",(Val(Substr(_cBarrar,7,5))*_nQtdLc)*SB1->B1_PESBRU,_MyN)
		//1-Rolo, 2-Carretel N8, 3-Carretel Madeira, 4-Bobina , 5-Retalho    , 6-Blister" // Pertence('RBCTML')

		GDFieldPut("ZL_ACOND",Substr("RCMBTL",Val(Substr(_cBarrar,6,1)),1),_MyN)
		GDFieldPut("ZL_LANCE",Val(Substr(_cBarrar,7,5)),_MyN)
	EndIf
	GDFieldPut("ZL_QTLANCE",_nQtdLc,_MyN)

	// Calcular o Peso da embalagem
	_nPesoEmb := 0.00

	//calculo do peso das embalagens
	// Atenção: Outros lugares também fazem o mesmo cálculo
	If _lNewBar
		_nMetros := Val(Substr(_cBarrar,8,4))
	Else
		_nMetros := Val(Substr(_cBarrar,7,5))
	EndIf
	IF Substr("RCMBTL",Val(Substr(_cBarrar,If(_lNewBar,7,6),1)),1) == "R" .And. _nMetros == 15
		// Se for rolo de 15 Encartelado
		_nRolCx := 0
		If Left(M->_ZL_PROD,3) == "115"  // Cabo Flexicom
			If Substr(M->_ZL_PROD,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 vão 10 rolos por caixa
				_nRolCx := 10
			ElseIf Substr(M->_ZL_PROD,4,2) $ "06/07" //Se for cabo flex 4 ou 6     vão 08 rolos por caixa
				_nRolCx := 8
			ElseIf Substr(M->_ZL_PROD,4,2) == "08" //Se for cabo flex 10         vão 06 rolos por caixa
				_nRolCx := 6
			EndIf
		ElseIf Left(M->_ZL_PROD,3) == "120"  .And. Substr(M->_ZL_PROD,4,2) $ "04/05"// Cordão Paralelo 1,5 ou 2,5
			_nRolCx := 8
		EndIf
		_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unitário do conjunto de ilhós em gramas
		_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unitário do saco plastico     em gramas
		_nCart    := (_nQtdLc*8.5232)/1000        // Peso unitário da cartela de papel  em gramas
		_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unitário da caixa de papelão  em kilos
		_nPesoEmb := (_nIlhos+_nSaco+_nCart+_nCaixa)
	ElseIf Substr("RCMBTL",Val(Substr(_cBarrar,If(_lNewBar,7,6),1)),1) == "L"
		aInfAcondi := u_cbcAcInf(Alltrim(M->_ZL_PROD), (Substr("RCMBTL",Val(Substr(_cBarrar,If(_lNewBar,7,6),1)),1) + StrZero(_nMetros, 5)), , _nQtdLc, , .T., .F.,.T.)
		if (aInfAcondi[1])
			_nPesoEmb := aInfAcondi[2,2]
		endif
	ElseIf Substr("RCMBTL",Val(Substr(_cBarrar,If(_lNewBar,7,6),1)),1) == "C" // Carretel N8
		_nPesoEmb := (_nQtdLc*2.00)
	ElseIf Substr("RCMBTL",Val(Substr(_cBarrar,If(_lNewBar,7,6),1)),1) == "M" // Carretel madeira
		_nPesoEmb := (_nQtdLc*1.45)
	EndIf

	GDFieldPut("ZL_EMB",_nPesoEmb,_MyN) //Calcular o peso da embalagem
	GDFieldPut("ZL_NUMOP" ,SubStr(_ZL_NUMOP,1,8),_MyN) //Nro. da OP

	// By Roberto 12/06/15
	If M->_ZL_TIPO == "U"
		GDFieldPut("ZL_UNMOV",_nUnMov,_MyN) //Nro. da Unmov
	EndIf

	// Somar peso da embalagem e peso padrão
	u_SomeAcols()

	_cBarrar := Space(13)
	_nQtdLc := 0.00
	u_Refbal03()
	o_cBarr:SetFocus()
Return(.T.)


/*/{Protheus.doc} CnfPdZZe
//TODO Confere Pedido com ZZE (Retrabalho).
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVar, , descricao
@type function
/*/
User Function CnfPdZZe(_nVar)   // 1-Digitou o Pedido  2-Digitou o Item do Pedido
	Local _Volta := .T.

	If Empty(M->_ZL_TIPO)
		Alert("Informar o Tipo da Pesagem")
		Return(.F.)
	EndIf
	DbSelectArea("ZZE")
	DbSetOrder(2) // ZZE_FILIAL+ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV
	If _ZL_PEDIDO == "000001" // Retornando para estoque
		_ZL_ITEMPV  := "99"
	ElseIf _ZL_ITEMPV == "99" .And. _nVar == 1 // Digitou o Pedido
		_ZL_ITEMPV  := "  "
	EndIf

	_nDvTot :=  0.00
	_nTtSA  :=  0.00

	If M->_ZL_PEDIDO == "000001" // Retornando para estoque
		M->_ZL_ITEMPV  := "99"
	EndIf
	_cChvZZE := M->_ZL_ZZEID+M->_ZL_PEDIDO+AllTrim(M->_ZL_ITEMPV)
	DbSeek(xFilial("ZZE")+_cChvZZE,.F.)
	Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ;
			Left(ZZE->ZZE_ID+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,Len(_cChvZZE)) == _cChvZZE .And. ZZE->(!Eof())
		If ZZE->ZZE_STATUS == '3' // EM RETRABALHO ..
			_nDvTot += ZZE->ZZE_DEVTOT
			_nTtSA  += ZZE->ZZE_TOTSA
		EndIf
		ZZE->(DbSkip())
	EndDo

	DbSeek(xFilial("ZZE")+_cChvZZE,.F.)

	If ZZE->(Eof()) .And. _ZL_PEDIDO # "000001"
		// Procuro Algo que exista. Só o ID ou o ID + Pedido
		// Item não... com certeza não tem
		DbSeek(xFilial("ZZE")+M->_ZL_ZZEID+If(_nVar==2,M->_ZL_PEDIDO,""),.F.)
		M->_ZL_PROD := Left(ZZE->ZZE_PRODUT,10)
		M->_ZL_DESC    := Posicione("SB1",1,xFilial("SB1")+M->_ZL_PROD,"B1_DESC")
		Alert("Pedido/Item não Pertence ao ID Informado")
		_Volta := .F.
	ElseIf ZZE->(!Eof()) .And. ZZE->ZZE_SITUAC == "1"
		Alert("Pesagem Inválida !!!" + chr(13) + chr(13) + ;
			"Pesagem já Encerrada." + chr(13) + chr(13) + ;
			"Comunique o PCP")
		_Volta := .F.
	ElseIf _nDvTot >= _nTtSA
		Alert("ID Retrabalho já Finalizado")
		_Volta := .F.
	Else
		M->_ZL_PROD := Padr(Left(ZZE->ZZE_PRODUT,10),TamSX3("B1_COD")[1])
		M->_ZL_DESC := Posicione("SB1",1,xFilial("SB1")+M->_ZL_PROD,"B1_DESC")
	EndIf
Return(_Volta)


/*/{Protheus.doc} SomeAcols
//TODO Soma o aCols.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function SomeAcols()
	M->_ZL_PESPADR := 0.00
	M->_ZL_EMB     := 0.00
	n:=1 //Len(aCols)
	For _MyN :=1 to Len(aCols)
		If !GDDeleted(_MyN)
			M->_ZL_PESPADR += GDFieldGet("ZL_PESPADR",_MyN)
			M->_ZL_EMB     += GDFieldGet("ZL_EMB",_MyN)
		EndIf
	Next
	u_PegaPeso()
Return(.T.)


/*/{Protheus.doc} IncRolo
//TODO Inclui Rolo.
@author juliana.leme
@since 07/06/2017
@version undefined

@type function
/*/
User Function IncRolo()

	nOpcE:=3
	nOpcG:=3
	inclui := .F.
	altera := .F.
	exclui := .F.
	aButtons := {}
	AAdd(aButtons, { "BALANCA" ,{|| u_SomeAcols()}, "Captura Peso"} )

	aAltEnchoice :={}

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SZL")
	SZL->(DbSetOrder(1))

	DbSelectArea("SZS")
	SZS->(DbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	DbSeek("SZL")
	aHeader:={}
	Do While !Eof().And.(x3_arquivo=="SZL")
		// By Roberto 12/06/15
		If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. AllTrim(x3_campo) $ "ZL_ACOND//ZL_LANCE//ZL_QTLANCE//ZL_EMB//ZL_PESPADR//ZL_METROS//ZL_UNMOV//ZL_NUMOP//"
			nUsado:=nUsado+1
			Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,".F.",;
				x3_usado, x3_tipo, x3_arquivo, x3_context } )
		Endif
		DbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := "Pesagem de Rolos/Carretéis"
	cAliasEnchoice := ""
	cAliasGetD     := "SZL"
	cLinOk         := "u_SomeAcols()" //"AllwaysTrue()"
	cTudOk         := "u_VejaPer()"   //"AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}
	_lRet:= .T.

	Do While _lRet
		_lNewBar := .F. // Formato novo do cod de barras
		// Alterar a variavel dDatabase porque está passando da meia noite e não estão saindo so sistema para atualizar
		dDataBase := Date()
		//M->_ZL_NUM     := CriaVar("ZL_NUM")
		M->_ZL_NUMOP   := CriaVar("ZL_NUMOP")
		M->_ZL_TIPO    := CriaVar("ZL_TIPO")
		M->_ZL_OPER    := CriaVar("ZL_OPER")
		M->_ZL_NOMOPER := CriaVar("ZL_NOMOPER")
		M->_ZL_DATA    := CriaVar("ZL_DATA")

		M->_ZL_ZZEID   := CriaVar("ZL_ZZEID")
		M->_ZL_PEDIDO  := CriaVar("ZL_PEDIDO")
		M->_ZL_ITEMPV  := CriaVar("ZL_ITEMPV")

		M->_ZL_PROD    := CriaVar("ZL_PRODUTO")
		M->_ZL_DESC    := CriaVar("ZL_DESC")
		M->_ZL_TARA    := CriaVar("ZL_TARA")
		M->_ZL_PBRUT   := CriaVar("ZL_PBRUT")
		M->_ZL_PESPADR := CriaVar("ZL_PESPADR")
		M->_ZL_EMB     := CriaVar("ZL_EMB")
		M->_ZL_PESOEFE := CriaVar("ZL_PESOEFE")
		M->_ZL_DESVIO  := CriaVar("ZL_DESVIO")
		M->_ZL_LOTE    := CriaVar("ZL_LOTE")
		_cBarrar    		:= Space(13)
		_nQtdLc     		:= 0

		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:=.F.

		_lRet:=u_Janbal03(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
		If _lRet
			M->_ZL_TIPO := If(M->_ZL_TIPO=="D","P",M->_ZL_TIPO)
			Processa( {|| GraveSZL() },"Gravando Pesagem...")
			M->_ZL_NUM := SZL->ZL_NUM
			//u_ImprBolet(2)
			U_ImprBol1(1) //Grafico
			//lFaz := .F.
		EndIf
	EndDo
Return(.T.)

/*/{Protheus.doc} Janbal03
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
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
User Function Janbal03(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
	Local aSize 		:= {}
	Local aPosObj 		:= {}
	Local aObjects 		:= {}
	Local aInfo 		:= {}
	Private _nQtdUnMov	:= 0
	Private _nUnMov		:= 0
	Private _aTpsBox 	:= RetSx3Box(Posicione('SX3',2,'ZL_TIPO','X3CBox()'),,,1)
	Private _cTpsBox 	:= Space(15)
	Private _ZL_OPUnMov := " "
	Private _nQtdUnMov	:= 0
	Private _lSoUm      := .T.

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

	// By Roberto 12/06/15
	_cDescLt := "Lote:"

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

	@ 035,005 Say "Operador:"																					Size  40,10
	@ 035,035 Get _ZL_OPER  			Picture "XXXXXX"	Valid u_ConfFun()     F3 "SZS"					Size  35,10
	@ 035,080 Get _ZL_NOMOPER								Valid .F.				When .F.					Size 110,10

	@ 035,220 Say "Data:"																						Size  30,10
	@ 035,240 Get _ZL_DATA									Valid .F.				When .F.					Size  40,10

	@ 035,290 Say "Tipo Pesagem:"																				Size  40,10
	@ 035,330 Get _ZL_TIPO			Picture "@! X"		Valid u_ConfTipo()									Size  05,10

	@ 035,350 Get _cTpsBox  		Picture "XXXXXXXXXXXXXXX"					When .F.					Size  40,10

	@ 050,005 Say "Nro.O.P.:"																					Size  40,10
	@ 050,035 Get _ZL_NUMOP    		Picture "@R XXXXXX-XX"	Valid u_ConfOP()		When M->_ZL_TIPO $ "PD"		Size  40,10

	@ 050,080 Say "ID Retr.:"																					Size  30,10
	@ 050,100 Get _ZL_ZZEID   		Picture "XXXXXX"		Valid u_ConfZZE(M->_ZL_ZZEID,M->_ZL_PROD) When M->_ZL_TIPO == "R" .And. Empty(M->_ZL_PROD)Size  25,10

	@ 050,130 Say "Num.Ped./Item :"																				Size  40,10
	@ 050,167 Get _ZL_PEDIDO  		Picture "XXXXXX"		Valid u_CnfPdZZe(1)		When M->_ZL_TIPO == "R" .And. !Empty(M->_ZL_ZZEID)Size  25,10
	@ 050,192 Say "/"
	@ 050,195 Get _ZL_ITEMPV  		Picture "XX"			When M->_ZL_TIPO == "R" .And. !Empty(M->_ZL_ZZEID) .And. _ZL_PEDIDO # "000001" Valid u_CnfPdZZe(2) Size  05,10

	@ 050,220 Say "Tara:"																						Size 30,10
	@ 050,240 Get _ZL_TARA			Picture "@E 9,999.99"	Valid u_PegaPeso()									Size 40,10
	@ 050,290 Say "Peso Bruto:"																					Size 40,10
	@ 050,350 Get _ZL_PBRUT    		Picture "@E 9,999.99" 	When M->_ZL_TIPO == "D"  Valid  M->_ZL_PBRUT > 1500 .And. u_PegaPeso() Size 40,10 Object o_ZL_PBRUT

	@ 065,005 Say "Produto.:"                                           						                  	Size  40,10
	@ 065,035 Get _ZL_PROD			Picture "@R XXX.XX.XX.X.XX" 	When .F.										Size   50,10
	@ 065,085 Get _ZL_DESC			Picture "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  When .F. 				Size  130,10

	@ 065,220 Say "Embal.:"                                         	                    Size 30,10
	@ 065,240 Get _ZL_EMB			Picture "@E 9,999.99"  When .F.							Size 40,10 Object o_ZL_EMB

	@ 065,290 Say "Peso Líquido:"															Size 40,10
	@ 065,350 Get _ZL_PESOEFE		Picture "@E 9,999.99"  When .F.							Size 40,10 Object o_ZL_PESOEFE

	@ 080,220 Say "Peso.:"																	Size 25,10
	@ 080,240 Get _ZL_PESPADR	Picture "@E 9,999.99"  When .F.								Size 40,10 Object o_ZL_PESPADR

	@ 080,290 Say "% Desvio:"                                   	                        Size 40,10
	@ 080,350 Get _ZL_DESVIO		Picture "@E  9999.99"  When .F.                         Size 40,10 Object o_ZL_DESVIO

	//CfUnMovPCF
	// By Juliana 12/06/15
	@ 080,005 Say "UnMov:"																		Size  40,10
	@ 080,035 Get _nUnMov		Picture "99999999999999"  When M->_ZL_TIPO == "U" .And. _nQtdUnMov == 0  Valid U_CfUnMovPCF(_nUnMov,.T.)  Size  50,10 Object o_UnMov

	@ 080,094 Say "Qtd.UnMov:"																	Size  30,10
	@ 080,130 Get _nQtdUnMov		Picture "@E 999,999.99"   When .F.						Size  70,10 Object o_QtdUnMov

	// By Roberto 12/06/15
	@ 095,005 Say _cDescLt																		Size  30,10 Object o_ZL_LOTE
	@ 095,035 Get _ZL_LOTE		Picture "XXXXXXXXXXXXXXX"    								Size  40,10

	@ 095,094 Say "Cód.Barras:"																	Size  40,10
	@ 095,130 Get _cBarrar		Picture "999999999999"    Valid u_ConfBar() When !Empty(M->_ZL_PROD) .And. _lSoUm  Size  50,10 Object o_cBarr  // _lSoUm - Aceitar somente 1 vez      := .T.

	@ 095,220 Say "Quant.:"																			Size  30,10
	@ 095,240 Get _nQtdLc		Picture "@E 999,999"      Valid _nQtdLc > 0 .And. u_ConfQuant()  ;
		When Empty(_nUnMov) .And. Substr(StrZero(Val(_cBarrar),12),If(_lNewBar,7,6),1)$"1236" Size  30,10

	oGetDados := MsGetDados():New(115,aPosObj[2,2],260,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_Refbal03()}

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

	lRet:=(nOpca==1)
Return(lRet)


/*/{Protheus.doc} Refbal03
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function Refbal03()
	o_ZL_PBRUT:Refresh()
	o_ZL_EMB:Refresh()
	o_ZL_PESOEFE:Refresh()
	o_ZL_PESPADR:Refresh()
	o_ZL_DESVIO:Refresh()
	o_cBarr:Refresh()
	o_UnMov:Refresh()
	o_QtdUnMov:Refresh()
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} GraveSZL
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function GraveSZL()
	dDataBase := Date()
	DbSelectArea("SZL")
	SZL->(DbSetOrder(1))


	ProcRegua(Len(aCols)*2)
	_nSomaPdr := 0.00
	For _MyN :=1 to Len(aCols)
		IncProc()
		If !GDDeleted(_MyN)
			_nSomaPdr += GDFieldGet("ZL_PESPADR",_MyN)
		EndIf
	Next

	_NumPes := "      "
	_cItem  := "000"
	For _MyN :=1 to Len(aCols)
		IncProc()
		If !GDDeleted(_MyN)
			If Empty(_NumPes)
				RecLock("SZL",.T.)
				SZL->ZL_FILIAL  := xFilial("SZL")
				MsUnLock()
				_nNumReg := SZL->(Recno())
				_NumPes := ProxPes(_nNumReg)

				DbSelectArea("SZL")
				SZL->(DbGoTo(_nNumReg))
				RecLock("SZL",.F.)
			Else
				RecLock("SZL",.T.)
				SZL->ZL_FILIAL	:= xFilial("SZL")
				SZL->ZL_NUM		:= _NumPes
			EndIf
			_cItem 				:= Soma1(_cItem)
			SZL->ZL_OPER		:= M->_ZL_OPER
			SZL->ZL_NOMOPER		:= M->_ZL_NOMOPER
			SZL->ZL_PBRUT   	:= M->_ZL_PBRUT
			SZL->ZL_TARA		:= M->_ZL_TARA
			SZL->ZL_TIPO		:= If(M->_ZL_TIPO=="D","P",M->_ZL_TIPO)
			SZL->ZL_DATA		:= dDataBase //M->_ZL_DATA
			SZL->ZL_PRODUTO		:= M->_ZL_PROD
			SZL->ZL_DESC		:= M->_ZL_DESC
			SZL->ZL_LOTE		:= M->_ZL_LOTE
			SZL->ZL_ITEM		:= _cItem
			SZL->ZL_ACOND		:= GDFieldGet("ZL_ACOND",_MyN)
			SZL->ZL_LANCE		:= GDFieldGet("ZL_LANCE",_MyN)
			SZL->ZL_QTLANCE		:= GDFieldGet("ZL_QTLANCE",_MyN)
			SZL->ZL_METROS		:= GDFieldGet("ZL_METROS",_MyN)
			SZL->ZL_EMB			:= GDFieldGet("ZL_EMB",_MyN)
			SZL->ZL_NUMOP		:= GDFieldGet("ZL_NUMOP",_MyN)
			SZL->ZL_UNMOV		:= GDFieldGet("ZL_UNMOV",_MyN)	//LEO-PASSEI POR AQUI
			SZL->ZL_QTUNMOV		:= GDFieldGet("ZL_QTUNMOV",_MyN)
			SZL->ZL_PESPADR		:= GDFieldGet("ZL_PESPADR",_MyN)

			aTam := TamSX3("ZL_PESOEFE")
			SZL->ZL_PESOEFE		:= Round((SZL->ZL_PESPADR / _nSomaPdr) * M->_ZL_PESOEFE,aTam[2])

			aTam := TamSX3("ZL_DESVIO")
			SZL->ZL_DESVIO		:= Round(((SZL->ZL_PESOEFE - SZL->ZL_PESPADR) / SZL->ZL_PESPADR) * 100,aTam[2])

			//If (SZL->ZL_PESOEFE < 18 .And. SZL->ZL_ACOND=="B") .Or. (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax) //.And. FWCodEmp()+FWCodFil() == "0101"
			If (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax) //.And. FWCodEmp()+FWCodFil() == "0101"
				SZL->ZL_STATUS	:= "Q"
			Else
				SZL->ZL_STATUS	:= "A"
			EndIf
			SZL->ZL_HORA			:= Left(Time(),Len(SZL->ZL_HORA))
			// Calcula o turno
			// 1ro. das 06:01 as 14:00
			// 2ndo das 14:01 as 22:00
			// 3ro  das 22:01 as 06:00
			_MyTime := Left(SZL->ZL_HORA,5)
			If _MyTime >= "06:01" .And. _MyTime <= "14:00"
				SZL->ZL_TURNO 	:= "1"
			ElseIf _MyTime >= "14:01" .And. _MyTime <= "22:00"
				SZL->ZL_TURNO 	:= "2"
			ElseIf _MyTime >= "22:01" .Or.  _MyTime <= "06:00"
				SZL->ZL_TURNO		:= "3"
			EndIf
			SZL->ZL_ZZEID 		:= M->_ZL_ZZEID
			SZL->ZL_PEDIDO		:= M->_ZL_PEDIDO
			SZL->ZL_ITEMPV		:= M->_ZL_ITEMPV
			MsUnLock()

			// Passei a gravação da tabela ZZE - Retrabalho para cá
			If SZL->ZL_TIPO == "R" // Retorno de retrabalho
				U_BAL03ZZE({SZL->ZL_ZZEID,SZL->ZL_QTLANCE,SZL->ZL_LANCE,SZL->ZL_ACOND,SZL->ZL_PEDIDO,SZL->ZL_ITEMPV,;
					SZL->ZL_PRODUTO},.T.,(SZL->ZL_DESVIO<_nDesMin .Or. SZL->ZL_DESVIO>_nDesMax),.T.) // BAIXAR RETRABALHO PROATIVA
				//SZL->ZL_PRODUTO},.T.,((SZL->ZL_PESOEFE < 18 .And. SZL->ZL_ACOND=="B") .Or. (SZL->ZL_DESVIO<_nDesMin .Or. SZL->ZL_DESVIO>_nDesMax)),.T.) // BAIXAR RETRABALHO PROATIVA
			EndIf

			If !Empty(SZL->ZL_UNMOV)
				// Flegar o SD3 da produção que já tem pesagem para essa produlção
				u_FlagSD3(SZL->ZL_UNMOV,.T.)
			EndIf
		EndIf
		//JULIANA
		If SZL->ZL_TIPO == "T"
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+M->_ZL_PEDIDO+M->_ZL_ITEMPV,.F.))

			dbSelectArea("SZ9")
			dbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO
			_LocPed := SC6->C6_ACONDIC + StrZero(SC6->C6_METRAGE,5)
			_LocPed := Padr(_LocPed,TamSX3("BE_LOCALIZ")[1])

			//If DbSeek(xFilial("SZ9")+SC6->C6_SEMANA+M->ZL_PRODUTO+SC6->C6_LOCAL+_LocPed+SC6->C6_NUM+SC6->C6_ITEM,.T.)
			// Deu error log no M->ZL_PRODUTO alterei para SZL->ZL_PRODUTO //By Roberto Oliveira 23/02/17
			If DbSeek(xFilial("SZ9")+SC6->C6_SEMANA+SZL->ZL_PRODUTO+SC6->C6_LOCAL+_LocPed+SC6->C6_NUM+SC6->C6_ITEM,.T.)
				If SZ9->Z9_ETIQIMP < SC6->C6_LANCES
					RecLock("SZ9",.F.)
					SZ9->Z9_ETIQIMP := SZ9->Z9_ETIQIMP+1
					// SZ9->Z9_IMPETIQ	:= "S"
					MsUnLock()
				Else
					Alert("Não existe Saldo para liberação da troca de etiquetas.")
					_lVolta := .F.
				EndIf
				If SZ9->Z9_ETIQIMP >= SC6->C6_LANCES .And. SZ9->Z9_IMPETIQ # "P"
					RecLock("SZ9",.F.)
					SZ9->Z9_IMPETIQ	:= "S"
					MsUnLock()
				EndIf
			EndIf
		EndIf
		IntegWMS()
	Next
Return(.T.)


/*/{Protheus.doc} VejaPer
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function VejaPer()
	_lVolta := .T.
	If _ZL_TIPO == "U"
		// Verificar se as unimovs lançadas estão dentro das quantidades
		_aUnMovs := {}
		For _nPPIMts := 1 To Len(aCols)
			If !GDDeleted(_nPPIMts)
				_nPsUMv := aScan(_aUnMovs, {|x|x[1] == GDFieldGet("ZL_UNMOV",_nPPIMts)})
				If _nPsUMv == 0
					AAdd(_aUnMovs,{GDFieldGet("ZL_UNMOV",_nPPIMts), 0.00})
					_nPsUMv := Len(_aUnMovs)
				EndIf
				_aUnMovs[_nPsUMv,2] += GDFieldGet("ZL_METROS",_nPPIMts)
			EndIf
		Next

		For _nPPIMts := 1 To Len(_aUnMovs)
			U_CfUnMovPCF(_aUnMovs[_nPPIMts,1],.F.)
			// _nQtdPPI	 -- Quantidade original da unimov
			// _nQtUnmov -- Quantidade já gravada no SZL dessa unimov
		Next
	EndIf

	If Empty(M->_ZL_LOTE) .And. M->_ZL_TIPO $ "PDU"
		Alert("Informar o Lote de Fabricacao")
		_lVolta := .F.
		//ElseIf Abs(M->_ZL_DESVIO) > 3
	ElseIf M->_ZL_DESVIO < _nDesMin .Or. M->_ZL_DESVIO > _nDesMax
		If !MsgBox("Desvio de " + AllTrim(Str(M->_ZL_DESVIO,7,2)) + "%,  fora do permitido - Entre " + Transform(_nDesMin,"@E 999") + " a " + Transform(_nDesMax,"@E 9,999.99") +"%","Confirma?","YesNo")
			_lVolta := .F.
		EndIf
	EndIf
	If _lVolta
		// Verificar se tem alguma linha cujo peso unitário seja maior que 60 quilos
		//	If X3USO(x3_usado) .And. cNivel>=x3_nivel .And. AllTrim(x3_campo) $ "ZL_ACOND//ZL_LANCE//ZL_QTLANCE//ZL_EMB//ZL_PESPADR//ZL_METROS"
		For _i := 1 To Len(aCols)
			If !GDDeleted(_i) .And. (GDFieldGet("ZL_PESPADR",_i) / GDFieldGet("ZL_QTLANCE",_i)) > 60
				_lVolta := .F.
				Alert("Não é possível incluir Rolos com peso superior a 60 quilos")
				Exit
			EndIf
		Next
	EndIf
Return(_lVolta)


/*/{Protheus.doc} ProxPes
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nNumReg, , descricao
@type function
/*/
Static Function ProxPes(_nNumReg)
	Local cLastNum := getLasNum()

	Do While .T.
		SZL->(DbSetOrder(1)) //Se não estiver nesta ordem pega nro errado

		If (Val(cLastNum) > 0)
			_cNumPes := StrZero(Val(cLastNum),Len(SZL->ZL_NUM))
		Else
			SZL->(DbSeek(Soma1(xFilial("SZL")),.T.))
			Do While SZL->ZL_FILIAL # xFilial("SZL") .And. SZL->(!Bof())
				DbSkip(-1)
			EndDo
			_cNumPes := StrZero(Val(SZL->ZL_NUM),Len(SZL->ZL_NUM))
		EndIf
		
		Do While DbSeek(xFilial("SZL")+_cNumPes,.F.)
			_cNumPes := StrZero(Val(SZL->ZL_NUM)+1,Len(SZL->ZL_NUM))
		EndDo

		SZL->(DbGoTo(_nNumReg))
		RecLock("SZL",.F.)
		SZL->ZL_NUM := _cNumPes
		MsUnLock()

		DbSelectArea("SZL")
		DbSetOrder(1)
		DbSeek(xFilial("SZL")+_cNumPes,.F.)
		Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM == _cNumPes .And. SZL->(!Eof())
			If SZL->(Recno()) # _nNumReg
				Exit
			EndIf
			SZL->(DbSkip())
		EndDo
		If SZL->ZL_FILIAL==xFilial("SZL") .And. SZL->ZL_NUM==_cNumPes .And. SZL->(Recno())#_nNumReg .And. SZL->(!Eof())
			// Achei outro cara igual
			// Busco novo número
			Loop
		Else
			Exit
		EndIf
	EndDo
Return(_cNumPes)


/*/{Protheus.doc} TrocaEtq
//TODO Troca Etiquetas.
@author juliana.leme
@since 07/06/2017
@version undefined

@type function
/*/
User Function TrocaEtq()
	Local aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
	If !(M->ZL_TIPO $ "STF")  // então é [P]rodução ou Pro[D]. +1500kg ou [R]etrabalho
		M->ZL_LOTE    := CriaVar("ZL_LOTE")
		M->ZL_TPBOB   := CriaVar("ZL_TPBOB")
		M->ZL_PRODUTO := CriaVar("ZL_PRODUTO")
		M->ZL_DESC    := CriaVar("ZL_DESC")
		M->ZL_METROS  := CriaVar("ZL_METROS")
		M->ZL_TARA    := CriaVar("ZL_TARA")
		M->ZL_PBRUT   := CriaVar("ZL_PBRUT")
	ElseIf  M->ZL_TIPO == "T"
		// verificar se a pesagem atual é de bobina
		If SZL->ZL_ACOND # "B"
			Alert("Pesagem Selecionada não se Refere a Bobina")
			Return(.F.)
		EndIf // If SZL->ZL_STATUS == "A" // Pesagem ainda não processada

		// Verificar se a Bobina atual não está Cancelada
		// Com o controle único no número das bobinas, verificar se a ultima etiqueta válida
		// é a que está em poder da filial.

		SZE->(DbSetOrder(1))
		SZE->(DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.))
		Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == SZL->ZL_NUMBOB .And. SZE->(!Eof())
			If SZE->ZE_SITUACA $ " 1" // bobina antiga ou nova com controle na filial corrente
				_nRegSZE := SZE->(Recno())
				Exit
			EndIf
			SZE->(DbSkip())
		EndDo

		If SZE->(Eof()) .Or. SZE->ZE_NUMBOB # SZL->ZL_NUMBOB
			Alert("Bobina não Encontrada no Cadastro")
			Return(.F.)
		ElseIf !SZE->ZE_SITUACA $ " 1" // bobina antiga ou nova sem o controle na filial corrente
			Alert("Bobina não Está Sob Controle Desta Unidade")
			Return(.F.)
		ElseIf SZE->ZE_SITUACA == " " .And.	SZE->ZE_STATUS == "C"// bobina antiga e está cancelada
			Alert("Bobina Já Cancelada")
			Return(.F.)
		ElseIf SZE->ZE_STATUS == "V"// bobina com reserva a confirmar
			Alert("Bobina com Reserva à Confirmar não Poderá ser Trocada a Etiqueta")
			Return(.F.)
		ElseIf SZE->ZE_SITUACA == "1" // bobina nova com controle na filial corrente
			// Procurar o SZL correspondente a essa bobina que deve ser o último SZL do arquivo
			_nBobAtu := SZL->ZL_NUMBOB
			SZL->(DbSetOrder(4)) // ZL_FILIAL+ZL_NUMBOB
			SZL->(DbSeek(xFilial("SZL") + _nBobAtu,.F.))
			_cNumPes := Space(Len(SZL->ZL_NUM))
			_nRegSZL := SZL->(Recno()) //Esta variável foi iniciada na função IncBobs()
			Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUMBOB == _nBobAtu .And. SZL->(!Eof())
				If SZL->ZL_NUM > _cNumPes
					_cNumPes := SZL->ZL_NUM
					_nRegSZL := SZL->(Recno())
				EndIf
				SZL->(DbSkip())
			EndDo
			SZL->(DbGoTo(_nRegSZL))
		EndIf
	ElseIf M->ZL_TIPO == "F" // Troca de filial
		// Abrir Pergunte para o código de barras
		_lCnfPerg := Pergunte("CDBAL03",.T.)
		If !_lCnfPerg
			Return(.F.)
		ElseIf !(Left(MV_PAR01,2) == "96" .Or. (Left(MV_PAR01,4) == "8000" .And. Substr(MV_PAR01,6,1) == "0")) // Bobina do EPA
			Alert("Dados Inválidos")
			Return(.F.)
		Else
			_cnBob := Substr(MV_PAR01,05,07)
			_cFilb := Substr(MV_PAR01,03,02)
			If _cFilb == "00" .Or. _cFilb == xFilial("SZE")
				Alert("Somente Bobinas de Outra Filial Pode Ser Utilizada")
				Return(.F.)
			EndIf
			SZE->(DbSetOrder(6)) // ZE_FILORIG+ZE_NUMBOB
			SZE->(DbSeek(_cFilb+_cnBob,.F.)) // Procuro na filial de origem
			// Guardo algumas informações para garantir que se trata da mesma bobina
			_cLt := SZE->ZE_LOTE
			_cPr := SZE->ZE_PRODUTO
			_cQt := SZE->ZE_QUANT
			_cTr := SZE->ZE_TARA
			_cPs := SZE->ZE_PESO
			If !Empty(SZE->ZE_NUMBOB)
				_cBobAnt := SZE->ZE_FILIAL+SZE->ZE_NUMBOB
				DbSelectArea("SZE")
				DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
				Do While DbSeek(_cBobAnt,.F.)
					If !Empty(SZE->ZE_BOBORIG)
						_cBobAnt := SZE->ZE_BOBORIG
					Else
						Exit
					EndIf
				EndDo
			Else
				_cBobAnt := "  "
			EndIf
			_nRegSZE := 0

			// Agora procuro essa bobina em todas as filiais pois ela pode estar em qualquer uma das filiais
			SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
			nRegSM0 := SM0->(Recno())
			cCodEmp := SM0->M0_CODIGO
			SM0->(DbSeek(cCodEmp,.F.))
			Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cCodEmp
				SZE->(DbSeek(FWCodFil()+_cnBob,.F.))
				Do While SZE->ZE_FILIAL == FWCodFil() .And. SZE->ZE_NUMBOB == _cnBob .And. SZE->(!Eof())
					If SZE->ZE_LOTE == _cLt .And. SZE->ZE_PRODUTO == _cPr .And. SZE->ZE_QUANT == _cQt .And.;
							SZE->ZE_TARA == _cTr .And. SZE->ZE_PESO    == _cPs
						// Trata-se da mesma Bobina
						If SZE->ZE_SITUACA $ " 1" // bobina antiga ou nova com controle na filial corrente
							_nRegSZE := SZE->(Recno())
							Exit
						EndIf
					EndIf
					SZE->(DbSkip())
				EndDo
				If _nRegSZE > 0
					Exit
				EndIf
				SM0->(DbSkip())
			EndDo
			// Volto o SIGAMAT onde estava
			SM0->(DbGoTo(nRegSM0))

			If _nRegSZE == 0
				Alert("Bobina não Encontrada no Cadastro")
				Return(.F.)
			ElseIf SZE->ZE_FILIAL == xFilial("SZE") // Bobina COM o controle na filial corrente
				Alert("Bobina Está Sob Controle Desta Unidade -> Use Troca de Etiqueta")
				Return(.F.)
			Else
				SZL->(DbSetOrder(4)) // ZL_FILIAL+ZL_NUMBOB
				// Localizar ultima a pesagem dessa bobina
				If !SZL->(DbSeek(SZE->ZE_FILIAL+_cnBob,.F.))
					// Aqui eu busco a filial do SZE e não xFilial("SZL") que é a de onde a bobina está.
					Alert("Pesagem Original não Localizada")
					Return(.F.)
				Else
					// Procurar o SZL correspondente a essa bobina que deve ser o último SZL do arquivo
					_cNumPes := Space(Len(SZL->ZL_NUM))
					_nRegSZL := SZL->(Recno()) //Esta variável foi iniciada na função IncBobs()
					Do While SZL->ZL_FILIAL == SZE->ZE_FILIAL .And. SZL->ZL_NUMBOB == _cnBob .And. SZL->(!Eof())
						// Aqui também eu use a filial do SZE

						If SZL->ZL_LOTE == _cLt .And. SZL->ZL_PRODUTO == _cPr .And. SZL->ZL_METROS == _cQt .And.;
								SZL->ZL_EMB  == _cTr .And. SZL->ZL_PBRUT   == _cPs
							If SZL->ZL_NUM > _cNumPes
								_cNumPes := SZL->ZL_NUM
								_nRegSZL := SZL->(Recno())
							EndIf
						EndIf
						SZL->(DbSkip())
					EndDo
					SZL->(DbGoTo(_nRegSZL))
				EndIf
			EndIf
		EndIf
	EndIf
	If M->ZL_TIPO $ "TF" // somente troca de etiqueta e troca de filial
		M->ZL_LOTE    := SZL->ZL_LOTE
		M->ZL_TPBOB   := SZL->ZL_TPBOB
		M->ZL_PRODUTO := SZL->ZL_PRODUTO
		M->ZL_DESC    := Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_DESC")
		M->ZL_METROS  := SZL->ZL_METROS
		M->ZL_TARA    := SZL->ZL_EMB
		M->ZL_PBRUT   := SZL->ZL_PBRUT
	EndIf
	U_CalcPeso()
Return(.T.)


/*/{Protheus.doc} INewEtBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVias, , descricao
@type function
/*/
User Function INewEtBob(_nVias)
	Local cPVCli, cNomeCli
	Local aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}

	If Empty(SZL->ZL_NUMBOB)
		Alert("Posicione em um Registro de Bobina")
		Return(.T.)
	EndIf

	// Posiciona Tabelas
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	SZE->(DbSeek(xFilial("SZE")+SZL->ZL_NUMBOB,.F.))

	If SZE->ZE_STATUS # "I"
		Alert("Somente é permitida e reimpressão de etiquetas recém criadas")
		Return(.T.)
	EndIf

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	DbSeek(xFilial("SC6")+SZL->ZL_PEDIDO+SZL->ZL_ITEMPV,.F.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	DbSeek(xFilial("SA1")+SZE->ZE_CLIENTE+SZE->ZE_LOJA,.F.)

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	DbSeek(xFilial("SB1")+SZL->ZL_PRODUTO,.F.)

	DbSelectArea("SZ1")
	SZ1->(DbSetOrder(1))
	SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))

	DbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))
	SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))

	DbSelectArea("SZ3")
	SZ3->(DbSetOrder(1))
	SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))

	// Copia o Logo para a impressora Zebra
	Alert("Definindo a Impressora")
	MSCBPRINTER("Z4M",cPorta,,80,.F.)
	Alert("Fim Definindo a Impressora")

	//MSCBLoadGraf("LOGO30A.GRF")

	MSCBWrite("^XA^LH8,16^PRC^FS")
	MSCBWrite("^FX ======================================================== ^FS")
	MSCBWrite("^FX =               *** ETIQUETA P/ BOBINAS ***            = ^FS")
	MSCBWrite("^FX =                                                      = ^FS")
	MSCBWrite("^FX =      Etiqueta desenvolvida por Valter Sanavio e      = ^FS")
	MSCBWrite("^FX =            Roberto Oliveira em 29/10/2008            = ^FS")
	MSCBWrite("^FX ======================================================== ^FS")
	MSCBWrite("^FO008,012^GB800,600,6^FS")
	MSCBWrite("^FX ==== LINHAS HORIZONTAIS =============================== ^FS")
	MSCBWrite("^FO008,092^GB800,001,4^FS")
	MSCBWrite("^FO008,212^GB800,001,4^FS")
	MSCBWrite("^FO008,284^GB800,001,4^FS")
	MSCBWrite("^FO008,356^GB800,001,4^FS")
	MSCBWrite("^FO008,428^GB664,001,4^FS")
	MSCBWrite("^FO008,500^GB664,001,4^FS")
	MSCBWrite("^FX ==== LINHAS VERTICAIS ================================ ^FS")
	MSCBWrite("^FO608,092^GB001,120,4^FS")
	MSCBWrite("^FO208,212^GB001,072,4^FS")
	MSCBWrite("^FO568,212^GB001,072,4^FS")
	MSCBWrite("^FO184,284^GB001,144,4^FS")
	MSCBWrite("^FO672,356^GB001,248,4^FS")
	MSCBWrite("^FO368,428^GB001,184,4^FS")
	MSCBWrite("^FO520,428^GB001,072,4^FS")
	MSCBWrite("^FX ===== LOGO COBRECOM ==================================== ^FS")
	//MSCBWrite("^FO024,014^XGE:LOGO30A.GRF^FS")
	MSCBWrite("^FO344,024^A0N,15,22^FDI.F.C. IND. COM. CONDUTORES ELETRICOS LTDA^FS")
	MSCBWrite("^FO344,040^A0N,15,22^FDAv. Primo Schincariol, 670-Jd. Oliveira-ITU/SP^FS")
	MSCBWrite("^FO344,056^A0N,15,22^FDFone: (11) 2118.3200  -  CEP 13312.250^FS")
	MSCBWrite("^FO344,072^A0N,15,22^FDCNPJ 02.544.042/0001-19   I.E.387.086.243.118^FS")
	MSCBWrite("^FO096,078^A0N,15,22^FDIndustria Brasileira^FS")
	MSCBWrite("^FX ===== 1a. LINHA DESCRICAO PRODUTO ====================== ^FS")
	MSCBWrite("^FO008,092^GB600,120,120^FS")
	MSCBWrite("^FO016,100^A0N,15,17^FR^FDPRODUTO^FS")
	If Left(SB1->B1_COD,3) == "164" // Cabos multiplexados não tem cor
		MSCBWrite("^FO024,120^A0N,45,40^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS")
	Else
		MSCBWrite("^FO024,120^A0N,50,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS")
	EndIf
	MSCBWrite("^FO024,184^A0N,20,20^FR^FDSECAO:^FS")
	MSCBWrite("^FO104,170^A0N,47,67^FR^FD" + Str(SZ1->Z1_VIAS,2) + "x" + AllTrim(SZ2->Z2_BITOLA) + "^FS")

	If Left(SB1->B1_COD,3) $ "162/163/164" // Cabos multiplexados não tem cor
		@ 0,0 PSAY "^FO472,184^A0N,25,25^FR^FDmm^FS"
		@ 0,0 PSAY "^FO514,176^A0N,20,20^FR^FD2^FS"
	Else
		@ 0,0 PSAY "^FO312,184^A0N,25,25^FR^FDmm^FS"
		@ 0,0 PSAY "^FO354,176^A0N,20,20^FR^FD2^FS"
		@ 0,0 PSAY "^FO378,176^A0N,35,35^FR^FD" + AllTrim(SZ3->Z3_DESC) + "^FS"
	EndIf
	MSCBWrite("^FX ===== DEMAIS CAMPOS DA ETIQUETA ========================= ^FS")
	MSCBWrite("^FO616,100^A0N,15,17^FDCOMPRIMENTO^FS")
	MSCBWrite("^FO624,132^A0N,75,65^FD" + AllTrim(Str(SZE->ZE_QUANT)) + "m^FS")
	MSCBWrite("^FO016,220^A0N,15,17^FDTENSAO ISOLAMENTO^FS")
	_cTensao := SZ1->Z1_DESC3
	If SZ2->Z2_COD <= "03" .And. !Empty(SZ1->Z1_DESC3A)
		_cTensao := SZ1->Z1_DESC3A
	EndIf
	MSCBWrite("^FO016,244^A0N,35,30^FD" + AllTrim(_cTensao) + "^FS")
	//MSCBWrite("^FO016,244^A0N,35,30^FD" + AllTrim(SZ1->Z1_DESC3) + "^FS")
	MSCBWrite("^FO216,220^A0N,15,17^FDCOMPOSICAO PRODUTO^FS")
	MSCBWrite("^FO216,244^A0N,35,30^FD " + AllTrim(SZ1->Z1_COMPOS) + " ^FS")
	MSCBWrite("^FO578,220^A0N,15,17^FDNORMA TECNICA^FS")
	MSCBWrite("^FO578,244^A0N,35,30^FD" + AllTrim(SB1->B1_NORMA) + "^FS")
	MSCBWrite("^FO016,292^A0N,15,17^FDN. PEDIDO^FS")
	// 21/08/15 - Jeferson Gardezani
	// Alteração: Impressão dos dados do cliente do pedido que originou a operação de triangulação (industrialização)
	// Código Anterior
	//MSCBWrite("^FO036,316^A0N,35,30^FD" + AllTrim(SZE->ZE_PEDIDO) + "^FS")
	// Código Novo

	aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
	aDadInd		:= u_InfTrian(xFilial("SZE"),SZE->ZE_PEDIDO,"CDBAL03")
	/*/
	Retorno da InfTrian
	[1]PEDIDO
	[2]A1_NOME
	[3]A1_NREDUZ
	[4]A1_MUN
	[5]A1_EST
	[6]A1_CGC
	[7]A1_TEL
	/*/
	If Len(aDadInd) = 0
		aDadInd		:= {{"","","","","","","","","","","","","","","","","",""}}
	EndIf

	If !Empty(aDadInd[1,1])
		MSCBWrite("^FO036,316^A0N,35,30^FD" + aDadInd[1,1] + "^FS")
	Else
		MSCBWrite("^FO036,316^A0N,35,30^FD" + AllTrim(SZE->ZE_PEDIDO) + "^FS")
	EndIf
	// Fim Código Novo

	MSCBWrite("^FO192,292^A0N,15,17^FDCLIENTE^FS")

	// 21/08/15 - Jeferson Gardezani
	// Alteração: Impressão dos dados do cliente do pedido que originou a operação de triangulação (industrialização)
	// Código Anterior
	/*
	// By Roberto Oliveira 12/01/15
	// Eliandro mandou etiqueta de bobina para estoque com o cliente "CLIENTE PADRÃO PARA ORÇAMENTO"
	// No caso de pedido 000001 o cliente deve aparecer  ESTOQUE, como está no SZE->ZE_NOMCLI
	//MSCBWrite("^FO192,316^A0N,35,30^FD" + AllTrim(SA1->A1_NOME) + "^FS")
	MSCBWrite("^FO192,316^A0N,35,30^FD" + AllTrim(SZE->ZE_NOMCLI) + "^FS")
	// Fim By Roberto Oliveira 12/01/15
	*/
	// Código Novo
	If !Empty(aDadInd[1,2])
		MSCBWrite("^FO192,316^A0N,35,30^FD" + Substr(AllTrim(aDadInd[1,2]),6,60) + "^FS")
	Else
		MSCBWrite("^FO192,316^A0N,35,30^FD" + AllTrim(SZE->ZE_NOMCLI) + "^FS")
	EndIf
	// Fim Código Novo

	MSCBWrite("^FO016,364^A0N,15,17^FDN. BOBINA^FS")
	MSCBWrite("^FO036,388^A0N,35,30^FD" + AllTrim(SZE->ZE_NUMBOB) + "^FS")
	MSCBWrite("^FO192,364^A0N,15,17^FDDESTINO^FS")
	MSCBWrite("^FO192,388^A0N,35,30^FD" + IIF(Empty(Alltrim(aDadInd[1,4])),AllTrim(SZE->ZE_DESTINO),Alltrim(aDadInd[1,4])+"-"+aDadInd[1,5]) + "^FS")
	MSCBWrite("^FO016,436^A0N,15,17^FDLOTE / DATA^FS")
	MSCBWrite("^FO016,462^A0N,35,30^FD" + AllTrim(SZE->ZE_LOTE) + "^FS")
	MSCBWrite("^FO176,462^A0N,35,30^FD/^FS")

	/*/ email do Alex de 09/12/14 - 10:12h
	Bom dia Roberto,
	Os códigos que deverão sair na etiqueta data de 28/11/14 são:
	132 - Cabo PP 2 Condutores 750 V
	133 - Cabo PP 3 Condutores 750 V
	134 - Cabo PP 4 Condutores 750 V
	120 - Cordão Paralelo 2 Condutores 300 V
	117 - Cabo Flex Plano 2 Condutores 300 V
	Assim que puder voltar ao normal eu aviso vocês.

	Atenção... este tem em dois lugares neste fonte
	/*/
	If Left(SB1->B1_COD,3) $ "132//133//134//120//117" .And. SZE->ZE_DATA >= Ctod("28/11/2014")
		_cDataB := "28/11/2014"
	Else
		// Forçar a data com o século
		_cDataB := DtoS(SZE->ZE_DATA)
		_cDataB := Right(_cDataB,2) + "/" + Substr(_cDataB,5,2) + "/" + Left(_cDataB,4)
	EndIf
	MSCBWrite("^FO192,462^A0N,35,30^FD" + _cDataB + "^FS")
	MSCBWrite("^FO376,436^A0N,15,17^FDTARA^FS")
	MSCBWrite("^FO396,462^A0N,35,30^FD" + Transform(SZE->ZE_TARA,"@E 999.99") + " kg^FS")
	MSCBWrite("^FO528,436^A0N,15,17^FDMASSA BRUTA^FS")
	MSCBWrite("^FO548,462^A0N,35,30^FD" + Transform(SZE->ZE_PESO,"@E 9999.99") + "kg^FS")
	MSCBWrite("^FO376,508^A0N,15,17^FDSITUACAO DE INSPECAO^FS")
	MSCBWrite("^FO464,544^A0N,45,40^FDAPROVADO^FS")
	MSCBWrite("^FX ====== QUADRADO APROVADO =============================== ^FS")
	MSCBWrite("^FO408,540^GB40,40,4^FS")
	MSCBWrite("^FO416,548^A0N,30,30^FDX^FS")
	MSCBWrite("^FX ====== CODIGO DE BARRAS ================================ ^FS")
	MSCBWrite("^FO056,508^BY3,,60^BEN,70,Y,N^FD" + Left(AllTrim(SB1->B1_CODBAR),12) + "^FS")
	//MSCBWrite("^FO702,376^BY2,,60^BUB,80,Y,N,N^FD" + "8" + StrZero(Val(SZE->ZE_NUMBOB),10) + "^FS")
	MSCBWrite("^FO702,376^BY2,,60^BUB,80,Y,N,N^FD" + "96" + SZE->ZE_FILORIG  + StrZero(Val(SZE->ZE_NUMBOB),7) + "^FS")
	MSCBWrite("^FO680,400^A0B,20,25^FD" + AllTrim(SB1->B1_COD) + "^FS")
	MSCBWrite("^FX ======================================================== ^FS")
	MSCBWrite("^FX =                   Fim da Etiqueta                    = ^FS")
	MSCBWrite("^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS")
	MSCBWrite("^FX ======================================================== ^FS")
	MSCBWrite("^PQ"+AllTrim(Str(_nVias))+"^FS")
	MSCBWrite("^MTT^FS")
	MSCBWrite("^MPE^FS")
	MSCBWrite("^JUS^FS")
	MSCBWrite("^XZ")
	MSCBCLOSEPRINTER()
	DbSelectArea("SZL")
Return()


/*/{Protheus.doc} fProxBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function fProxBob() // Função fora de uso
	// Modo antigo
	DbSelectArea("SZE")
	SZE->(DbSetOrder(1))

	/*/
	By Roberto Oliveira 08/09/2016
	Conforme orientação de Mauro e Rosevaldo, não existe obrigatoriedade de o número da bobina ser zerado a cada ano
	Estamos alterando para que haja somente uma sequencia dessa numeração entre as unidades e também não mais seja reiniciado a cada ano.
	/*/
	_cPrxBob := Right(Str(Year(Date()),4),2)
	If DbSeek(xFilial("SZE")+_cPrxBob,.F.) // Tenho um nro neste ano
		// Procuro o próximo
		DbSeek(xFilial("SZE")+Soma1(_cPrxBob),.T.)
		Do While SZE->ZE_FILIAL == xFilial("SZE") .And. Left(SZE->ZE_NUMBOB,2) > _cPrxBob .And. !Bof()
			DbSkip(-1)
		EndDo

		_cPrxBob := StrZero(Val(SZE->ZE_NUMBOB)+1,Len(SZE->ZE_NUMBOB))

		Do While DbSeek(xFilial("SZE")+_cPrxBob,.F.)
			_cPrxBob := StrZero(Val(SZE->ZE_NUMBOB)+1,Len(SZE->ZE_NUMBOB))
		EndDo
	Else
		//		_cPrxBob := Right(Str(Year(dDataBase),4),2) + "000001"
		_cPrxBob := Right(Str(Year(Date()),4),2) + "000001"
	EndIf

	If SX6->(Dbseek("  MV_PRXBOB",.F.)) // Este parâmetro tem que ser compartilhado, pois a numeração tem sequencia única.
		x6_PrBob := Left(SX6->X6_CONTEUD,Len(SZE->ZE_NUMBOB))
		If _cPrxBob > x6_PrBob
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD := _cPrxBob
			SX6->X6_CONTSPA := SX6->X6_CONTEUD
			SX6->X6_CONTENG := SX6->X6_CONTEUD
			MsUnLock()
		EndIf
		DbSelectArea("SZE")
	EndIf

Return(_cPrxBob)


/*/{Protheus.doc} fNextBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function fNextBob()
	Local cNextBob := ""
	Local cEmpAtu  := cNumEmp
	Local lAchou   := .F.
	Local nRegSM0  := 0
	nRegSM0 := SM0->(Recno())
	cCodEmp := SM0->M0_CODIGO

	DbSelectArea("SZE")
	SZE->(DbSetOrder(1))

	/*/
	Não mais é utilizado a numeração da bobina utilizando o ano como referência.
	Apresentamos a questão para Wellington, Mauro e Rosevaldo e todos informaram que não existe
	regra específica na ISO para cálculo desse número
	/*/
	DbSelectArea("SX6")
	DbSetOrder(1)
	If !Dbseek("  MV_PRXBOB",.F.)
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "MV_PRXBOB"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Numero da Ultima Bobina SZE"
		SX6->X6_DSCSPA  := "Numero da Ultima Bobina SZE"
		SX6->X6_DSCENG  := "Numero da Ultima Bobina SZE"
		//SX6->X6_CONTEUD := Substr(Dtos(dDataBase),3,2) + "00000"
		SX6->X6_CONTEUD := "0000000"
		SX6->X6_CONTSPA := SX6->X6_CONTEUD
		SX6->X6_CONTENG := SX6->X6_CONTEUD
		SX6->X6_PROPRI  := "U"
	Else
		Do While !RecLock("SX6",.F.)
		EndDo
		If AllTrim(SX6->X6_DESCRIC) # "Numero da Ultima Bobina SZE"
			SX6->X6_DESCRIC := "Numero da Ultima Bobina SZE"
			SX6->X6_DSCSPA  := "Numero da Ultima Bobina SZE"
			SX6->X6_DSCENG  := "Numero da Ultima Bobina SZE"
		EndIf
		/*/
		by Roberto Oliveira 09/09/16
		Não mais é utilizado o ano como referência ao número da bobina.
		Conversei com Wellington, Mauro e Rosevaldo e não existe regra definida na ISO para o sequenciamento
		da numeração das bobinas.
		If Left(SX6->X6_CONTEUD,2) # Substr(Dtos(dDataBase),3,2)
			SX6->X6_CONTEUD := Substr(Dtos(dDataBase),3,2) + "00000"
			SX6->X6_CONTSPA := SX6->X6_CONTEUD
			SX6->X6_CONTENG := SX6->X6_CONTEUD
		EndIf
		/*/
	EndIf

	cProxBob := Left(SX6->X6_CONTEUD,Len(SZE->ZE_NUMBOB)) // Pega o que está no parâmetro - Nro da última bobina criada.

	lAchou := .T. // Inicio como se o nro. existe
	Do While lAchou // Faça enquanto existir
		cProxBob := Soma1(cProxBob) // Soma 1 pelo menos uma vez.
		lAchou := .F. // Agora digo que não existe - Presumo que não existe
		SM0->(DbSeek(cCodEmp,.F.))
		Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cCodEmp .And. !lAchou
			lAchou := SZE->(DbSeek(FWCodFil()+cProxBob,.F.))
			SM0->(DbSkip())
		EndDo
	EndDo
	SM0->(DbGoTo(nRegSM0))

	SX6->X6_CONTEUD := cProxBob
	SX6->X6_CONTSPA := SX6->X6_CONTEUD
	SX6->X6_CONTENG := SX6->X6_CONTEUD
	SX6->(MsUnlock())

Return(cProxBob)

/*/{Protheus.doc} IncSuca
//TODO Descrição auto-gerada.
@author usuario
@since 13/01/2017
@version undefined

@type function
/*/
User Function IncSuca()
	Local lRet := .T.
	aButtons := {}
	AAdd(aButtons, { "BALANCA" ,{|| u_CalcPeso()}, "Captura Peso"} )
	dDataBase := Date()
	aCamposInc := {}
	AAdd(aCamposInc,"NOUSER") // Este "campo" indica para a AXINCLUI que não deve incluir campos do usuário, que no caso, são todos.
	AAdd(aCamposInc,Left("ZL_DATA"    + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_TIPO"    + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_OPER"    + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_NOMOPER" + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_PRODUTO" + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_DESC"    + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_TARA"    + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_PBRUT"   + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_PESOEFE" + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))
	AAdd(aCamposInc,Left("ZL_STATUS"  + Space(Len(SX3->X3_CAMPO)),Len(SX3->X3_CAMPO)))

	dbSelectArea("SZL")
	nOpca := AxInclui("SZL",0,3,aCamposInc,,,"u_VldPes()")

	If nOpca == 1
		If U_CBRetSldB2(SZL->ZL_PRODUTO,"91") >= SZL->ZL_PESOEFE
			dDataBase := Date()
			// Busca proximo nro da pesagem
			DbSelectArea("SZL")
			_nNumReg := SZL->(Recno())

			_cNumPes := ProxPes(_nNumReg) // Para achar o nro o proximo nro da pesagem.. ele desposiciona do SZL... por isoo a variável _nNumReg

			DbSelectArea("SZL")
			DbGoTo(_nNumReg)
			RecLock("SZL",.F.)
			If SZL->ZL_DATA # dDataBase
				SZL->ZL_DATA := dDataBase
			EndIf
			SZL->ZL_NUM     := _cNumPes
			SZL->ZL_HORA    := Left(Time(),Len(SZL->ZL_HORA))
			SZL->ZL_ACOND   := " "
			SZL->ZL_QTLANCE := 0
			// Calcula o turno
			// 1ro. das 06:01 as 14:00
			// 2ndo das 14:01 as 22:00
			// 3ro  das 22:01 as 06:00
			_MyTime := Left(SZL->ZL_HORA,5)
			If _MyTime >= "06:01" .And. _MyTime <= "14:00"
				SZL->ZL_TURNO := "1"
			ElseIf _MyTime >= "14:01" .And. _MyTime <= "22:00"
				SZL->ZL_TURNO := "2"
			ElseIf _MyTime >= "22:01" .Or.  _MyTime <= "06:00"
				SZL->ZL_TURNO := "3"
			EndIf
			MsUnLock()

			U_ImprBol1(1) //Grafico

			DbSelectArea("SZL")
			DbGoTo(_nNumReg)

			dDataBase := date()
			u_ProcBal03(SZL->ZL_NUM,SZL->ZL_NUM,"","")


			DbSelectArea("SZL")
			DbGoTo(_nNumReg)
			lRet := .T.
		Else
			//Exclui o Registro
			_nNumReg := SZL->(Recno())

			//Deleta o Registro
			DbSelectArea("SZL")
			DbGoTo(_nNumReg)
			SZL->(RecLock("SZL",.F.))
			SZL->(DbDelete())
			SZL->(MsUnLock())

			nQuantSuc := U_CBRetSldB2(SZL->ZL_PRODUTO,"91")
			Alert ("PESAGEM NÃO PROCESSADA."+;
				"Saldo Insuficiente." + CRLF  +;
				"Favor comunicar ao PCP! " + CRLF +;
				"Quantidade disponivel para pesagem: " + Transform(nQuantSuc,"@E 999,999.9999"))
			lRet := .F.
		EndIf
	EndIf
Return(lRet)


/*/{Protheus.doc} ValPRD
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ValPRD()
	/*/
	Devido a reformulação dos códigos, esta valição passa a ser
	verificada pelo grupo do produto SC01
	/*/
	If Posicione("SB1",1,xFilial("SB1")+M->ZL_PRODUTO,"B1_TIPO+B1_GRUPO") # "SCSC01"
		Alert("Somente usar Códigos de Produtos do Tipo SC e do Grupo SC01 - Sucata")
		Return(.F.)
	EndIf
Return(.T.)


/*/{Protheus.doc} VldPes
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function VldPes()
	Local _Volta := .T.
	If M->ZL_PESOEFE<=0
		Alert("Peso Inválido -> Corrija!")
		_Volta := .F.
	ElseIf M->ZL_TIPO =="R" .And. (Empty(M->ZL_ZZEID) .Or. Empty(M->ZL_PEDIDO) .Or. Empty(M->ZL_ITEMPV))
		Alert("Para retorno de retrabalho obrigatório informar:" + chr(13)   + chr(13) + ;
			"ID do Retrabalho" + chr(13) + ;
			"Número do Pedido de Venda" + chr(13) + ;
			"Item do Pedido de Vanda")
		_Volta := .F.
	EndIf
Return(_Volta)


/*/{Protheus.doc} WhenProd
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function WhenProd()

Return(M->ZL_TIPO=="S".Or.(!Empty(M->ZL_PEDIDO).And.!M->ZL_TIPO$"TFU"))
// Esta expressão não coube no campo X3_WHEN do campo ZL_PRODUTO


/*/{Protheus.doc} EtiHuawei
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVias, , descricao
@param _ZE_QUANT, , descricao
@param _cPrdHwy, , descricao
@param _nQtdEtq, , descricao
@param _cAcond, , descricao
@param _NumBob, , descricao
@param _dDBse, , descricao
@type function
/*/
Static Function EtiHuawei(_nVias,_ZE_QUANT,_cPrdHwy,_nQtdEtq,_cAcond,_NumBob,_dDBse)
	Local _nVias,_ZE_QUANT,_cPrdHwy,_nQtdEtq,_cAcond,_cSeq,_dDBse
	Default _dDBse  := dDatabase // Pra não correr o risco de fazer uma etiqueta no último segundo do dia
	Private wnrel   := "ETIQUETA"
	Private cString := "ETIQUETA"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}

	// Prepara a descrição
	_DescHw1 := Left(SA7->A7_DESCCLI+SA7->A7_DESC2+SA7->A7_DESC3,55)
	_DescHw2 := Substr(SA7->A7_DESCCLI+SA7->A7_DESC2+SA7->A7_DESC3,56,55)

	If !Empty(_NumBob)
		DbSelectArea("SZE")
		DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
		DbSeek(xFilial("SZE")+_NumBob,.F.)
	EndIf

	SetDefault(aReturn,cString)

	For _QtdVias := 1 to _nQtdEtq
		// Tenho que imprimir uma a uma por causa do serial number que não pode ser repetido.
		// Por isso, o comando ^PQ tem que ser um a um
		@ 0,0 PSAY "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
		@ 0,0 PSAY "^XA
		@ 0,0 PSAY "^MMT
		@ 0,0 PSAY "^PW1228
		@ 0,0 PSAY "^LL0945
		@ 0,0 PSAY "^LS0
		// @ 0,0 PSAY "^FO026,335^GB782,0,12^FS
		// @ 0,0 PSAY "^FO026,542^GB782,0,12^FS

		@ 0,0 PSAY "^FT045,077^A0N,40,38^FH\^FDPO.: " + AllTrim(SA7->A7_CODCLI) + "^FS
		// @ 0,0 PSAY "^BY2,3,59^FT69,156^BCN,,N,N^FD>:" + AllTrim(SA7->A7_CODCLI) + "^FS

		@ 0,0 PSAY "^FT480,076^A0N,40,38^FH\^FDQTD: " + AllTrim(Str(_ZE_QUANT)) + " M^FS"
		// @ 0,0 PSAY "^BY2,3,59^FT557,156^BCN,,N,N^FD>:"     + AllTrim(Str(_ZE_QUANT)) + "^FS"

		//@ 0,0 PSAY "^FT044,160^A0N,40,38^FH\^FDModel: " + _cPrdHwy + "^FS" // Código do produto no cliente
		//@ 0,0 PSAY "^FT035,220^A0N,30,29^FH\^FDDesc.:^FS"
		//@ 0,0 PSAY "^FT035,260^A0N,30,29^FH\^FD" + _DescHw1 + "^FS"
		// @ 0,0 PSAY "^FT124,265^A0N,17,19^FH\^FD" + _DescHw1 + "^FS" // Descrição 1 do cliente
		/*
		If !Empty(_DescHw2)
			@ 0,0 PSAY "^FT035,290^A0N,30,29^FH\^FD" + _DescHw2 + "^FS" // Descrição 2 do cliente
		EndIf
		*/
		// Devido a erro na quantidade da etiqueta da Huawei ir com 1,
		// pegar sempre a quantidade de _ZE_QUANT
		_zeQtd	:= StrZero(_ZE_QUANT,4)
		_cAno   := StrZero(Year(_dDBse),4)
		_nSeman := StrZero(u_SemDoAno(_dDBse),2)

		If !Empty(_NumBob)
			If Empty(SZE->ZE_IDCLIEN)
				_cSeq   := StrZero(ProxHuawei(),6)
				// Grava para reimpressão
				RecLock("SZE",.F.)
				SZE->ZE_IDCLIEN :=  Right(_cAno,2) + _nSeman +"Q"+ _zeQtd + "S" + _cSeq
				MsUnLock()
			Else
				_cAno   := SubStr(SZE->ZE_IDCLIEN,1,2)
				_nSeman := SubStr(SZE->ZE_IDCLIEN,3,2)
				_zeQtd	:= SubStr(SZE->ZE_IDCLIEN,6,4)
				_cSeq   := SubStr(SZE->ZE_IDCLIEN,11,6)
			EndIf
		Else
			_cSeq   := StrZero(ProxHuawei(),6)
		EndIf

		_cBarGde := "19" + AllTrim(SA7->A7_CODCLI) + "/Z001U8" + Right(_cAno,2) + _nSeman +"Q"+ _zeQtd + "S" + _cSeq

		// @ 0,0 PSAY "^FT048,450^A0N,40,38^FH\^FDS/N:^FS"
		@ 0,0 PSAY "^FT162,528^BQN,2,10 ^FH\^FDLA,"+ _cBarGde + "^FS"
		//@ 0,0 PSAY "^FT762,528^BQN,2,10 ^FH\^FDLA,"+ _cBarGde + "^FS"
		@ 0,0 PSAY "^FT45,590^A0N,40,38^FH\^FD"    + _cBarGde + "^FS"

		// Código Alterado
		// @ 0,0 PSAY "^BY2,3,105^FT50,513^BCN,,N,N^FD>:" + _cBarGde + "^FS"
		// @ 0,0 PSAY "^FT045,592^A0N,30,29^FH\^FDRemark:^FS"
		// Fim Alteração
		@ 0,0 PSAY "^PQ"+If(_cAcond$"BCM","3","1")+",0,1,Y^XZ" //Para Bobinas ou carretéis, emite 3 iguais.
	Next
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)


/*/{Protheus.doc} SemDoAno
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _dDBse, , descricao
@type function
/*/
User Function SemDoAno(_dDBse)
	// Inicio cálculo da semana
	// Conf. ISO8601 a 1ra semana é aquela que inclui a 1ra.quinta-feira
	// Conforme a mesma ISO, a semana começa na segunda-feira

	_nSeman := 0 // começo com zero para depois adicionar

	// Primeiro verifico se os últimos dias de dezembro não pertencem a 1a semana do ano seguinte
	If Month(_dDBse) == 12 .And. Day(_dDBse) >= 29
		// Estas datas podem pertencer a 1a semana do ano seguinte
		_cAnoSeg   := Right(Strzero(Year(_dDBse)+1,4),4)
		_dDtBs1 := Ctod("01/01/" + _cAnoSeg) // Primeiro dia do ano
		If DOW(_dDtBs1) == 5 // Se for quinta
			// Esse dia é da 1a semana do ano seguinte
			_nSeman := 1
		ElseIf DOW(_dDtBs1) == 4 .And. Day(_dDBse) >= 30 // Se for quarta
			// Esse dia é da 1a semana do ano seguinte
			_nSeman := 1
		ElseIf DOW(_dDtBs1) == 3 .And. Day(_dDBse) == 31 // Se for terça
			// Esse dia é da 1a semana do ano seguinte
			_nSeman := 1
		EndIf
	EndIf
	If _nSeman == 0 // Ainda não defini a semana
		// Verifico se os primeiros dias do mês de janeiro não pertence a última semana do ano anterior
		If Month(_dDBse) == 1 .And. Day(_dDBse) <= 3
			// Estas datas podem pertencer a última semana do ano anterior
			_cAno   := Right(Strzero(Year(_dDBse),4),4)
			_dDtBs1 := Ctod("01/01/" + _cAno) // Primeiro dia do ano
			If DOW(_dDtBs1) == 6 // Se for sexta
				// Esse dia é da última semana do ano anterior
				_nSeman := -1
			ElseIf DOW(_dDtBs1) == 7 .And. Day(_dDBse) <= 2 // Se for sábado
				// Esse dia é da última semana do ano anterior
				_nSeman := -1
			ElseIf DOW(_dDtBs1) == 1 .And. Day(_dDBse) == 1 // Se for domindo
				// Esse dia é da última semana do ano anterior
				_nSeman := -1
			EndIf
		EndIf
	EndIf

	// defini se devo contar a partir do ano corrente ou do ano anterior
	_cAno   := Right(Strzero(Year(_dDBse+_nSeman),4),4) // Somo porque _nSeman pode ser negadivo

	If _nSeman <= 0 // Ainda não defini a semana
		_dDtBs1 := Ctod("01/01/" + _cAno) // Primeiro dia do ano

		// Primeiro vamos achar a primeira quinta feira do ano
		Do While DOW(_dDtBs1) # 5
			_dDtBs1++
		EndDo

		// Estou na primeira quinta-feira do ano, então estou na semana 1
		_nSeman := 1

		// Agora vou até o dia de hoje somando 1 em _nSeman a cada segunda-feira encontrada.
		Do While _dDtBs1 <= _dDBse
			If DOW(_dDtBs1) == 2 // é segunda feira ?
				_nSeman++
			EndIf
			_dDtBs1++
		EndDo
	EndIf
Return(_nSeman)


/*/{Protheus.doc} LoadLogo
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function LoadLogo()
	Local cRet := ""
	cRet += "~DGLOGO30A,02574,039,000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000003FFC000000000000000000000000000000000000000000000000000"
	cRet += "00000000FFFFFFFFFFFFC003FF8000000000000000000000000000000000000000000000000000"
	cRet += "0000001FFFFFFFFFFFFF8003FF8000000000000000000000000000000000000000000000000000"
	cRet += "000000FFFFFFFFFFFFFF8F03FF8000000000000000000000000000000000000000000000000000"
	cRet += "000007FFFFFFFFFFFFFF8F33FF8000000000000000000000000000000000000000000000000000"
	cRet += "00001FFFFFFFFFFFFFFF8F03FF8000000000000000000000000000000000000000000000000000"
	cRet += "00003FFFFFFFFFFFFFFFC003FF8000000000000000000000000000000000000000000000000000"
	cRet += "00007FFF8000000000000003FF8000000000000000000000000000000000000000000000000000"
	cRet += "0001FFF80000000000000003FF8000000000000000000000000000000000000000000000000000"
	cRet += "0003FFC00000000000000003FF8000000000000000000000000000000000000000000000000000"
	cRet += "0007FF000000000000000003FF8000000000000000000000000000000000000000000000000000"
	cRet += "0007FE0003FFF00001FFF003FF81FF00FF01FC0FFF800003FFF00001FFE002FF80FF800FF80000"
	cRet += "000FF8001FFFFE0007FFFE03FF87FFC0FFE3FF3FFFF0001FFFFC000FFFFC03FF87FFE03FFE0000"
	cRet += "001FF0003FFFFF801FFFFF03FF9FFFE0FFE7FE3FFFFC007FFFFF001FFFFF03FF8FFFF07FFF0000"
	cRet += "003FE000FFFFFFC07FFFFFC3FFFFFFF0FFCFFE7FFFFF00FFFFFFC07FFFFFC3FF9FFFF8FFFF8000"
	cRet += "003FC001FFFFFFE0FFFFFFE3FFFFFFF8FFCFFE7FFFFF81FFFFFFE0FFFFFFE3FFBFFFF9FFFFC000"
	cRet += "007FC003FFFFFFF1FFFFFFF3FFFFFFFCFFFFFCFFFFFF83FFFFFFE1FFFFFFF3FFFFFFFFFFFFC000"
	cRet += "007F8003FFFFFFF9FFFFFFF9FFFFFFFE7FFFFCFF07FFC7FFFFFFF3FFFFFFF1FFFFFFFFFFFFE000"
	cRet += "007F0007FFF0FFF8FFF1FFF8FFFFFFFE7FFFF8FE01FFE7FFE1FFF9FFF1FFF9FFFFFFFFFFFFE000"
	cRet += "00FF0007FF803FFCFFC07FFCFFF83FFE7FFF19FC00FFE7FF807FF9FFC07FFCFFFCFFFFE7FFE000"
	cRet += "00FE000FFF001FFCFF803FFCFFF01FFF3FFC01F800FFE3FF003FFCFF803FFCFFF03FFF83FFE000"
	cRet += "00FE000FFF001F80FF001FFE7FE00FFF3FF803F8007FF3FE001F00FF001FFC7FE01FFF01FFE000"
	cRet += "00FC001FFE000000FF001FFE7FC00FFF3FF87FF0007FF3FE000001FE001FFE7FC01FFE00FFE000"
	cRet += "01FC001FFE00000FFE000FFE7FC007FF3FF07FF0007FF3FC00000FFE001FFE7FC01FFE00FFE000"
	cRet += "01FC001FFE00000FFE000FFE7FC007FF3FF07FFBFFFFF3FC00000FFE000FFE7FC01FFE00FFE000"
	cRet += "01FC001FFE00000FFE000FFE7F8007FF3FF07FFFFFFFF1FC00000FFE000FFE7FC01FFC00FFE000"
	cRet += "01FC001FFC00000FFE000FFE7F8007FF3FF07FFFFFFFF9FC00000FFE000FFE7FC01FFC00FFE000"
	cRet += "01FC001FFC00000FFE000FFE7F8007FF3FF07FFFFFFFF9FC00000FFE000FFE7FC01FFC00FFE000"
	cRet += "01FC001FFE00000FFE000FFE7FC007FF3FE07FFFFFFFF9FC00001FFE000FFE7FC01FFC00FFE000"
	cRet += "01FC001FFE00000BFE000FFE7FC007FF3FE07FF8000001FC000007FE001FFE7FC01FFC00FFE000"
	cRet += "01FC001FFE0000007E001FFE7FC00FFF3FE07FF0000001FC000000FE001FFE7FC01FFC00FFE000"
	cRet += "00FC000FFE000FF07F001FFE7FC00FFF3FE07FF800001FFE001FE0FF001FFC7FC01FFC00FFE000"
	cRet += "00FE000FFF001FFE7F001FFC7FE01FFE3FE03FF800000FFE001FFCFF003FFCFFC01FFC00FFE000"
	cRet += "00FE000FFF803FFCFF803FFCFFF01FFE7FE03FF8000003FF003FFCFF803FFCFFC01FFC00FFE000"
	cRet += "00FE0007FFC07FFCFFC07FF8FFFC7FFE7FE03FFC00FF83FF80FFF9FFC0FFF8FFC01FFC00FFE000"
	cRet += "007F0007FFFBFFF8FFFBFFF9FFFFFFFC7FE01FFE03FFE3FFF3FFF9FFFBFFF9FFC01FFC00FFE000"
	cRet += "007F0003FFFFFFF9FFFFFFF1FFFFFFFCFFE00FFFFFFFC7FFFFFFF1FFFFFFF3FFC01FFC00FFE000"
	cRet += "007F8001FFFFFFF0FFFFFFE3FFFFFFF8FFE00FFFFFFFC3FFFFFFE1FFFFFFE3FFC01FFC00FFE000"
	cRet += "003FC000FFFFFFE07FFFFFC3FFBFFFF8FFE007FFFFFF81FFFFFFC0FFFFFFC3FFC01FFC00FFE000"
	cRet += "003FC0007FFFFFC03FFFFF83FF9FFFF0FFE003FFFFFF00FFFFFF803FFFFF83FFC01FFC00FFE000"
	cRet += "001FE0003FFFFF000FFFFE03FF8FFFC0FFE000FFFFFC003FFFFF001FFFFE03FFC01FFC00FFE000"
	cRet += "000FF00007FFFC0003FFF803FF83FF80FFE0003FFFF0000FFFF80003FFF803FFC01FFE00FFF000"
	cRet += "000FFC00007FC000003F800000007C0000000001FE0000007F8000003F00000000000000000000"
	cRet += "0007FE000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "0003FF800000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "0001FFE00000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "0000FFFE0000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "00007FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000"
	cRet += "00001FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE000000"
	cRet += "00000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3C0000"
	cRet += "000003FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE39C000"
	cRet += "000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3C0000"
	cRet += "0000001FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"
	cRet += "000000000000000000000000000000000000000000000000000000000000000000000000000000"

Return cRet


/*/{Protheus.doc} LoadSelo
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function LoadSelo()
	Local cRet := ""
	cRet += "~DGREG,05016,038,FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFF00000000000000000000000000000000000000000000000000000000000000000003FFFC"
	cRet += "FFFC00000000000000000000000000000000000000000000000000000000000000000000FFFC"
	cRet += "FFF0000000000000000000000000000000000000000000000000000000000000000000003FFC"
	cRet += "FFE0000000000000000000000000000000000000000000000000000000000000000000001FFC"
	cRet += "FFC0000000000000000000000000000000000000000000000000000000000000000000000FFC"
	cRet += "FFC00000000000000000000000000000000000000000000000000000000000000000000007FC"
	cRet += "FF800000000000000000000000000000000000000000000000000000000000000000000007FC"
	cRet += "FF800000000000000000000000000000000000000000000000000000000000000000000003FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000003FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000180000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000FF8000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000003FFE000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000007FFE000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000007E3F000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000007C3F000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000007C0001F803E78787C3CE0FE07CF007E007E00000000000000000000000000000001FC"
	cRet += "FE000007F0007FC0FFF8787C3DE3FF87FFC1FFC1FFC0000000000000000000000000000001FC"
	cRet += "FE000007FF00FFE0FFF8787C3FE7EF87FFC3FFE3E7C0000000000000000000000000000001FC"
	cRet += "FE000003FFE1F1F1F0F8787C3FE7C787C7C3E3E3E3C0000000000000000000000000000001FC"
	cRet += "FE000000FFF1E1F1F0F8787C3F000787C3E7E3E003C0000000000000000000000000000001FC"
	cRet += "FE0000000FF1FFF3F0F8787C3E01FF87C3E7E000FFC0000000000000000000000000000001FC"
	cRet += "FE00000003F9FFF3F0F8787C3E07FF87C3E7E003FFC0000000000000000000000000000001FC"
	cRet += "FE00000FC1F9FFF3F0F8787C3C0FC787C3E7E007E3C0000000000000000000000000000001FC"
	cRet += "FE00000FC1F9E001F0F8787C3E0F8787C3E7E3E7C3C0000000000000000000000000000001FC"
	cRet += "FE000007E3F1E1F1F9F87C7C3E0F8787C3E3E3E7C7C0000000000000000000000000000001FC"
	cRet += "FE000007FFF1FBF0FFF87FFC3E0FFF87C3E3FFC7FFC0000000000000000000000000000001FC"
	cRet += "FE000003FFE0FFE07FF87FFC3E0FFF87C3E1FFC7FFC0000000000000000000000000000001FC"
	cRet += "FE000000FF003F8000F83F7C3E03F7C7C3E07F01F3C0000000000000000000000000000001FC"
	cRet += "FE0000000000000000F8000000000000000030000000000000000000000000000000000001FC"
	cRet += "FE00000000000001F0F800000000000000007E000000000000000000000000000000000001FC"
	cRet += "FE00000000000000FFF800000000000000000E000000000000000000000000000000000001FC"
	cRet += "FE000000000000007FE000000000000000008E000000000000000000000000000000000001FC"
	cRet += "FE000000000000000F000000000000000000FC000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF00001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001FFFF80000001FC"
	cRet += "FE0000000000000000000000000000000000000000000000000000000000017FFF80000001FC"
	cRet += "FE0000000000000000000000000000000000000000000000000000000000011FFF80000001FC"
	cRet += "FE0000000000000000000000000000000000000000000000000000000000010FFF80000001FC"
	cRet += "FE00000000000000000000000000000000000000000000000000000000000107FF80000001FC"
	cRet += "FE00000000000000000000000000000000000000000000000000000000000101FF80000001FC"
	cRet += "FE00000000000000000000000000000000000000000000000000000000000100FF80000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001003F80000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001001F80000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001000780000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001000380000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001000080000001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000000001000080000001FC"
	cRet += "FE000000000300000000000000000000000000000000000000000000000001000080000001FC"
	cRet += "FE000000000300000000000000000000000000000000000000000000000001000080000001FC"
	cRet += "FE000000000780000000000000000000000000000000000000000000000001C00080000001FC"
	cRet += "FE0000000007C0000000000000000000000000000000000000000000000001E00080000001FC"
	cRet += "FE000000000CC0000000000000000000000000000000000000000000000001F80080000001FC"
	cRet += "FE000000001C60000000000000000000000000000000000000000000000001FC0080000001FC"
	cRet += "FE000000001860000000000000000000000000000000000000000000000001FE0080000001FC"
	cRet += "FE000000003830000000000000000000000000000000000000000000000001FF8080000001FC"
	cRet += "FE000000003038000000000000000000000000000000000000000000000001FFC080000001FC"
	cRet += "FE000000006018000000000000000000000000000000000000000000000001FFF080000001FC"
	cRet += "FE00000000E01C000000000000000000000000000000000000000000000001FFFC80000001FC"
	cRet += "FE00000000C7FC000000000000000000000000000000000000000000000001FFFE80000001FC"
	cRet += "FE000000019F80000000000000000000000000000000000000000000000001FFFF80000001FC"
	cRet += "FE000000039800000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE0000000301FF000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE00000007FFFF800000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE00000007FE00000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000100000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000000000000000000000000000000000000000000000000000000001FFFFFFFFFF80001FC"
	cRet += "FE000001E0B002020000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FE000000AA1633360001F800000000000001C0001E003C0000000000000000000000000001FC"
	cRet += "FE000000A811B2820007FE00000000000001C0003C003C0000000000000000000000000001FC"
	cRet += "FE00000090008000000F9E00000000000001C0003000000000000000000000000000000001FC"
	cRet += "FE00000000000000000F0E00000000000001C0000000000000000000000000000000000001FC"
	cRet += "FE00000000000000001E001F877DF1DE1C71C7E0FC3FBC7F00000000FD8360CFDFF7E0F001FC"
	cRet += "FE000001FFFFFFFE001E003FC7FFF9FF1C71C7F1FF3FBC7F80000000FDC371DFDFF7F1F801FC"
	cRet += "FE00000000000000001E0078E79E79E71C71CE73CF3FBCE3C000000031E379FC0386330E01FC"
	cRet += "FE00000000000000001E0070E71E79C79C71CF83C73C3CE3C000000031F37BFC0386360601FC"
	cRet += "FE00000000000000001E0070E71E79C79C71C7F3C73C3DE3C000000031B36EFFC386E60601FC"
	cRet += "FE000000A8A10A40000F0E78E71E79C79C71C07BC73C3CE3C0000000319F64FC0386760601FC"
	cRet += "FE00000098840AC0000F9E79E71E79E71EF1CE79CF3C3CE3C0000000318F60DC0386370E01FC"
	cRet += "FE00000018E40B400007FC3FC71E79FF1FF1C7F0FE3C3C7F80000000FD8760FFC38631FC01FC"
	cRet += "FE00000098840BC00001F81F871E79DE0F71C7E07C3C3C3E00000000FD8760DFC38639F801FC"
	cRet += "FE0000006682644000000000000001C0000000000000000000000000000000000000000001FC"
	cRet += "FE0000000000000000000000000001C0000000000000000000000000000000000000000001FC"
	cRet += "FE0000000000000000000000000001C0000000000000000000000000000000000000000001FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000001FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000003FC"
	cRet += "FF000000000000000000000000000000000000000000000000000000000000000000000003FC"
	cRet += "FF800000000000000000000000000000000000000000000000000000000000000000000007FC"
	cRet += "FF800000000000000000000000000000000000000000000000000000000000000000000007FC"
	cRet += "FFC00000000000000000000000000000000000000000000000000000000000000000000007FC"
	cRet += "FFE0000000000000000000000000000000000000000000000000000000000000000000001FFC"
	cRet += "FFE0000000000000000000000000000000000000000000000000000000000000000000001FFC"
	cRet += "FFF8000000000000000000000000000000000000000000000000000000000000000000007FFC"
	cRet += "FFFE00000000000000000000000000000000000000000000000000000000000000000000FFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
	cRet += "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC"
Return cRet


/*/{Protheus.doc} LoadVolu
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
Static Function LoadVolu()
	Local cRet := ""

	cRet += "~DGCR1,02860,020,0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000400000000000000000000"
	cRet += "0000000000000000000E00000000000000000000"
	cRet += "0000000000000000000F00000000000000000000"
	cRet += "0000000000000000001F00000000000000000000"
	cRet += "0000000000000000001F80000000000000000000"
	cRet += "0000000000000000003F80000000000000000000"
	cRet += "0000000000000000003FC0000000000000000000"
	cRet += "0000000000000000007FC0000000000000000000"
	cRet += "000000000000000000FFE0000000000000000000"
	cRet += "000000000000000000FFF0000000000000000000"
	cRet += "000000000000000001FFF0000000000000000000"
	cRet += "000000000000000001FFF8000000000000000000"
	cRet += "000000000000000003FFF8000000000000000000"
	cRet += "000000000000000007FFFC000000000000000000"
	cRet += "000000000000000007FFFE000000000000000000"
	cRet += "00000000000000000FFFFE000000000000000000"
	cRet += "00000000000000000FFFFF000000000000000000"
	cRet += "00000000000000001FFFFF000000000000000000"
	cRet += "00000000000000001FFFFF800000000000000000"
	cRet += "00000000000000003FFFFF800000000000000000"
	cRet += "00000000000000007FF9FFC00000000000000000"
	cRet += "00000000000000007FF1FFE00000000000000000"
	cRet += "0000000000000000FFF0FFE00000000000000000"
	cRet += "0000000000000000FFE0FFF00000000000000000"
	cRet += "0000000000000001FFE07FF00000000000000000"
	cRet += "0000000000000001FFC07FF80000000000000000"
	cRet += "0000000000000003FF803FFC0000000000000000"
	cRet += "0000000000000007FF801FFC0000000000000000"
	cRet += "0000000000000007FF001FFE0000000000000000"
	cRet += "000000000000000FFF000FFE0000000000000000"
	cRet += "000000000000000FFE000FFF0000000000000000"
	cRet += "000000000000001FFC0007FF0000000000000000"
	cRet += "000000000000001FFC0007FF8000000000000000"
	cRet += "000000000000003FF80003FFC000000000000000"
	cRet += "000000000000007FF80001FFC000000000000000"
	cRet += "000000000000007FF00001FFE000000000000000"
	cRet += "00000000000000FFF00000FFE000000000000000"
	cRet += "00000000000000FFE00000FFF000000000000000"
	cRet += "00000000000001FFC000007FF800000000000000"
	cRet += "00000000000003FFC000007FF800000000000000"
	cRet += "00000000000003FF8000003FFC00000000000000"
	cRet += "00000000000007FF8000001FFC00000000000000"
	cRet += "00000000000007FF0000001FFE00000000000000"
	cRet += "0000000000000FFF0000000FFE00000000000000"
	cRet += "0000000000000FFE0000000FFF00000000000000"
	cRet += "0000000000001FFC00000007FF80000000000000"
	cRet += "0000000000003FFC00000003FF80000000000000"
	cRet += "0000000000003FF800000003FFC0000000000000"
	cRet += "0000000000007FF800000001FFC0000000000000"
	cRet += "0000000000007FF000000001FFE0000000000000"
	cRet += "000000000000FFE000000000FFE0000000000000"
	cRet += "000000000001FFE000000000FFF0000000000000"
	cRet += "000000000001FFC0000000007FF8000000000000"
	cRet += "000000000003FFC0000000007FF8000000000000"
	cRet += "000000000003FF800000007FFFFC000000000000"
	cRet += "000000000007FF8000001FFFFFFC000000000000"
	cRet += "000000000007FF000001FFFFFFFE000000000000"
	cRet += "00000000000FFE00001FFFFFFFFF000000000000"
	cRet += "00000000001FFE0007FFFFFFFFFF000000000000"
	cRet += "00000000001FFC01FFFFFFFFFFFF800000000000"
	cRet += "00000000003FFC01FFFFFFFFFFFF800000000000"
	cRet += "00000000003FF803FFFFFFFFFFFFC00000000000"
	cRet += "00000000007FF807FFFFFFFFFFFFC00000000000"
	cRet += "00000000007FF007FFFFFFFFFFFFE00000000000"
	cRet += "0000000000FFE00FFFFFFFC00000000000000000"
	cRet += "0000000001FFE00FFFFFF0000000000000000000"
	cRet += "0000000001FFC01FFFFE00000000000000000000"
	cRet += "0000000003FFC01FFFE000000000000000000000"
	cRet += "0000000003FF803FFC0000000000000000000000"
	cRet += "0000000007FF803C000000000000000000000000"
	cRet += "000000000FFF0000000000000000000000000000"
	cRet += "000000000FFE00000000000FFFFFC00000000000"
	cRet += "000000001FFE0000000007FFFFFFFF0000000000"
	cRet += "000000001FFC00000000FFFFFFFFFF8000000000"
	cRet += "000000003FFC0000001FFFFFFFFFFF8000000000"
	cRet += "000000003FF8000003FFFFFFFFFFFFC000000000"
	cRet += "000000007FF80003FFFFFFFFFFFFFFE000000000"
	cRet += "00000000FFFFFFFFFFFFFFFFFFFFFFE000000000"
	cRet += "00000000FFFFFFFFFFFFFFFFFFFFFFF000000000"
	cRet += "00000001FFFFFFFFFFFFFFFFFFFFFFF000000000"
	cRet += "00000001FFFFFFFFFFFFFFFFFFFFFFF800000000"
	cRet += "00000003FFFFFFFFFFFFFFE000003FFC00000000"
	cRet += "00000007FFFFFFFFFFFFF800000000FC00000000"
	cRet += "00000007FFFFFFFFFFFF00000000000400000000"
	cRet += "00000001FFFFFFFFFFE000000000000000000000"
	cRet += "000000000FFFFFFFFC0000000000000000000000"
	cRet += "00000000000FFFFE000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000003300000"
	cRet += "0000000000000000000000000000000004080000"
	cRet += "0000000000000000000000000000000008040000"
	cRet += "0000000000000000000000000000000011220000"
	cRet += "0000000000000000000000000000000010200000"
	cRet += "0000000000000000000000000000000001200000"
	cRet += "0000000000000000000000000000000001600000"
	cRet += "0000000000000000000000000000000001200000"
	cRet += "0000000000000000000000000000000011220000"
	cRet += "0000001000000000000000000000000000000000"
	cRet += "000003B000000000000000000000000008040000"
	cRet += "0000033000000000000000000000000002100000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0FFF18071C01C7F80C0000000000C00000000300"
	cRet += "1FFF3C071E03C7FE0C0000060000C00000000300"
	cRet += "1FFF3C070E0386070C0000060000C00000000300"
	cRet += "00E03C070E0386030C0000000000C00000000300"
	cRet += "00E03C070F0706030C0000000000C00000000300"
	cRet += "00E03C07070706030DF03F061BE0C1F82780FB00"
	cRet += "00E03C07070706060F3871861E70C31C3DC1CF00"
	cRet += "00E03C07078E07FC0E1860C61830C20C30638300"
	cRet += "00E03C07038E07FC0C18C0C61830C00C30630300"
	cRet += "00E03C07038E06060C18FFC61830C0FC20630300"
	cRet += "00E03C0701DC06060C18FFC61830C3FC20630300"
	cRet += "00E01C0701DC06030C18C0061830C60C20630300"
	cRet += "00E01C0F01F806030C18C0061830C60C20630300"
	cRet += "00E01E1E00F806030C1860C61830C60C20638700"
	cRet += "00E00FFE00F806030C1871861830C73C2061CF00"
	cRet += "00E007F800F006030C183F061830C3EC2060FB00"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80"
	cRet += "3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"
	cRet += "0000000000000000000000000000000000000000"

Return cRet


/*/{Protheus.doc} LoadGRF
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function LoadGRF()
	//Carrega Logotipos na abertura das telas
	//OBS: Leonardo vai tentar carregar conteúdo do GRF de um arquivo localizada no servidor.
	Private wnrel   := "LOGO"
	Private cString := "LOGO"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,"COM2","",1}

	SetDefault(aReturn,cString)

	@ 0,0 PSAY LoadLogo()	//Logotipo Cobrecom
	@ 0,0 PSAY LoadSelo()	//Selo TUV com Registro
	@ 0,0 PSAY LoadVolu()	//Selo TUV Voluntário

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return Nil


/*/{Protheus.doc} EtiAndra
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVias, , descricao
@type function
/*/
Static Function EtiAndra(_nVias)
	Private wnrel   := "ETIQUETA"
	Private cString := "ETIQUETA"
	//Private aReturn := {"Zebrado",1,"Administracao",1,3,"COM2","",1}
	Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}
	//Private cPorta  := "COM2:9600,E,8,1,P"

	SetDefault(aReturn,cString)

	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =               *** ETIQUETA P/ BOBINAS ***            = ^FS"
	@ 0,0 PSAY "^FX =                                                      = ^FS"
	@ 0,0 PSAY "^FX =      Etiqueta desenvolvida por Valter Sanavio e      = ^FS"
	@ 0,0 PSAY "^FX =            Roberto Oliveira em 29/10/2008            = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX ==== BORDAS EXTERNAS =================================== ^FS"
	@ 0,0 PSAY "^FO008,012^GB800,590,6^FS"
	@ 0,0 PSAY "^FX ==== LINHAS HORIZONTAIS ================================ ^FS"
	@ 0,0 PSAY "^FO008,092^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,212^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,276^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,340^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,404^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,468^GB800,001,4^FS"

	@ 0,0 PSAY "^FX ==== LINHAS VERTICAIS ================================== ^FS"
	@ 0,0 PSAY "^FO608,092^GB001,120,4^FS" // Produto  | Comprimento
	@ 0,0 PSAY "^FO404,276^GB001,064,4^FS" // Nro.Pedido Cobrecom  | Nro. Pedido Andra
	@ 0,0 PSAY "^FO272,340^GB001,064,4^FS" // Nro.Bobina  |  Tam. Bobina
	@ 0,0 PSAY "^FO536,340^GB001,064,4^FS" // Tam. Bobina  | NBR
	@ 0,0 PSAY "^FO272,404^GB001,064,4^FS" // Tara  | Peso Liquido
	@ 0,0 PSAY "^FO536,404^GB001,064,4^FS" // Peso Liquido |  Peso Bruto
	@ 0,0 PSAY "^FX ===== IDENTIFICAÇÃO DO CLIENTE ========================= ^FS"
	@ 0,0 PSAY "^FO016,020^A0N,16,20^FR^FDCLIENTE^FS"
	@ 0,0 PSAY "^FO016,044^A0N,50,40^FR^FD" + SA1->A1_NOME + "^FS"
	@ 0,0 PSAY "^FX ===== 1a. LINHA DESCRICAO PRODUTO ====================== ^FS"
	@ 0,0 PSAY "^FO016,100^A0N,16,20^FD^FDPR?ODUTO^FS"
	If Left(SB1->B1_COD,3) == "164" // Cabos multiplexados não tem cor
		@ 0,0 PSAY "^FO024,120^A0N,45,40^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
	Else
		@ 0,0 PSAY "^FO024,120^A0N,50,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
	EndIf
	@ 0,0 PSAY "^FO024,184^A0N,20,20^FD^FDSECAO:^FS"
	@ 0,0 PSAY "^FO104,170^A0N,47,67^FR^FD" + Str(SZ1->Z1_VIAS,2) + "x" + AllTrim(SZ2->Z2_BITOLA) + "^FS"
	If Left(SB1->B1_COD,3) $ "162/163/164" // Cabos multiplexados não tem cor
		@ 0,0 PSAY "^FO472,184^A0N,25,25^FR^FDmm^FS"
		@ 0,0 PSAY "^FO514,176^A0N,20,20^FR^FD2^FS"
	Else
		@ 0,0 PSAY "^FO312,184^A0N,25,25^FR^FDmm^FS"
		@ 0,0 PSAY "^FO354,176^A0N,20,20^FR^FD2^FS"
		@ 0,0 PSAY "^FO378,176^A0N,35,35^FR^FD" + AllTrim(SZ3->Z3_DESC) + "^FS"
	EndIf
	@ 0,0 PSAY "^FO616,100^A0N,15,17^FDCOMPRIMENTO^FS"
	@ 0,0 PSAY "^FO624,132^A0N,75,65^FD" + AllTrim(Str(SZE->ZE_QUANT)) + "m^FS"
	@ 0,0 PSAY "^FO016,220^A0N,16,20^FDIDENTIFICACAO DE VEIAS^FS"

	_cCores := ""
	If Left(SB1->B1_COD,5) $ "13201//13202"      // PP 2x0,50  2x0,75
		_cCores := "Marrom / Azul Claro"
	ElseIf Left(SB1->B1_cod,5) $ "13301//13302"  // PP 3x0,50  3x0,75
		_cCores := "Marrom / Azul Claro / Verde-Amarelo"
	ElseIf SB1->B1_ESPECIA == "01"
		If SZ1->Z1_VIAS == 2
			_cCores := "Preto / Azul Claro"
		ElseIf SZ1->Z1_VIAS == 4
			_cCores := "Preto / Azul Claro / Branco"
		ElseIf SZ1->Z1_VIAS == 4
			_cCores := "Preto / Azul Claro / Branco / Vermelho"
		EndIf
	Else
		DbSelectArea("SZ4")
		DbSetOrder(1) // Z4_FILIAL+Z4_COD
		DbSeek(xFilial("SZ4") + SB1->B1_ESPECIA,.F.)
		_cCores := AllTrim(SZ4->Z4_DETALHE)
	EndIf

	@ 0,0 PSAY "^FO016,244^A0N,35,30^FD" + _cCores + "^FS"
	@ 0,0 PSAY "^FO016,284^A0N,16,20^FDNRO.PEDIDO COBRECOM^FS"
	@ 0,0 PSAY "^FO016,308^A0N,35,30^FD" + SZE->ZE_PEDIDO + "-" + SZE->ZE_ITEM + "^FS"

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5") + SZE->ZE_PEDIDO,.F.)

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6") + SZE->ZE_PEDIDO + SZE->ZE_ITEM,.F.)

	_cPedCli := ""
	If !Empty(SC5->C5_PEDCLI) // By Roberto 17/07/14
		_cPedCli := SC5->C5_PEDCLI
	EndIf
	If !Empty(SC6->C6_PEDCLI)
		_cPedCli := SC6->C6_PEDCLI
		If !Empty(SC6->C6_ITPDCLI)
			_cPedCli := _cPedCli + "-" + SC6->C6_ITPDCLI //aPedCom
		EndIf
	EndIf
	_cTpAtu := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/",(((Val(AllTrim(SZE->ZE_TPBOB))-1) * 7) + 1),6))

	@ 0,0 PSAY "^FO412,284^A0N,16,20^FDNRO.PEDIDO CLIENTE^FS"
	@ 0,0 PSAY "^FO412,308^A0N,35,30^FD" + _cPedCli + "^FS"

	@ 0,0 PSAY "^FO016,348^A0N,16,20^FDNRO.BOBINA^FS"
	@ 0,0 PSAY "^FO016,372^A0N,35,30^FD" + SZE->ZE_NUMBOB + "^FS"

	@ 0,0 PSAY "^FO280,348^A0N,16,20^FDTAM. BOBINA^FS"
	@ 0,0 PSAY "^FO280,372^A0N,35,30^FD" + _cTpAtu + "^FS"

	@ 0,0 PSAY "^FO544,348^A0N,16,20^FDNORMA TECNICA^FS"
	@ 0,0 PSAY "^FO544,372^A0N,35,30^FD" + AllTrim(SB1->B1_NORMA) + "^FS"

	@ 0,0 PSAY "^FO016,412^A0N,16,20^FDTARA^FS"
	@ 0,0 PSAY "^FO016,436^A0N,35,30^FD" + AllTrim(Transform(SZE->ZE_TARA,"@E 9,999.99")) + " Kg^FS"

	@ 0,0 PSAY "^FO280,412^A0N,16,20^FDPESO LIQUIDO^FS"
	@ 0,0 PSAY "^FO280,436^A0N,35,30^FD" + AllTrim(Transform(SZE->ZE_PLIQ,"@E 9,999.99")) + " Kg^FS"

	@ 0,0 PSAY "^FO544,412^A0N,16,20^FDPESO BRUTO^FS"
	@ 0,0 PSAY "^FO544,436^A0N,35,30^FD" + AllTrim(Transform(SZE->ZE_PESO,"@E 9,999.99")) + " Kg^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =                   Fim da Etiqueta                    = ^FS"
	@ 0,0 PSAY "^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^PQ"+AllTrim(Str(_nVias))+",0,1,Y^XZ"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)

// Esta função deverá ser inteiramente excluída quando for alterado o SCHEDULE , pois está tratando o banco do PCF
// e a nova função deverá tratar diretamente o SD3 das produÇÕes geradas pela interface PCF -> PROTHEUS.
// Vide FUNÇÃO CfUnMov_PCF 	que já está tratando isso.
// Excluir a função CfUnMov e alterar o nome da função CfUnMov_PCF para CfUnMov.
//
/*/{Protheus.doc} CfUnMovPCF
//TODO Verificar UnMov e retornar os dados da mesma na base do PC-Factory.
@author juliana.leme
@since 15/06/2015
@version
@param _nUnMov, undefined, descricao
@param _lValQtd, undefined, descricao
@type function
/*/
User Function CfUnMovPCF(_nUnMov,_lValQtd)

	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetNewPar("ZZ_HNDPCF","MSSQL/PCFactory") //"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetNewPar("ZZ_SRVPPI", "192.168.3.4")		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI		:= GetNewPar("ZZ_PORTADB", "7890")	// Porta
	Private nHndPPI					//Handler do banco de dados de integração
	Private lMenu		:= .F.
	Private cQuery		:= ""
	Private _Filial
	Private _DtLancto 	:= "20150101"
	Public _nQtUnmov 	:= 0 // Qtde Soma ZL_METROS
	Public _nQtdPPI	 	:= 0 // Qtde UNMOV no PCF
	Default _lValQtd 	:= .T. // Efetua a validação das quantidades


	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)
	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Caso a conexão não seja realizada
	If nHndPPI < 0
		Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		Return(.T.)
	Endif

	//Abre a conexão com Protheus
	//TcSetConn(nHndERP)
	//Abre a conexão com a PPI
	//TcSetConn(nHndPPI)

	//Conecta com PPI
	TcSetConn(nHndPPI)

	cQuery := "SELECT  "
	cQuery += "REPLACE(b.Code, '-', '') Lote,  "
	cQuery += "SUBSTRING(b.auxcode2,3,11) OP,  "
	cQuery += "c.code Produto, "
	cQuery += "c.name Descr, "
	cQuery += "a.idmovun MovUn, "
	cQuery += "Convert(nvarchar,a.DtTimeStamp,112) DtLancto, "
	cQuery += "a.Movunqty Qtde  "
	cQuery += "FROM TBLMovUn a  "
	cQuery += "inner join TBLLot b on a.IDLot = b.IDLot "
	cQuery += "inner join tblproduct c on a.idproduct = c.idproduct "
	cQuery += "Where a.issueIdDocType <> 8 "	//Não pega UnMovs de MP
	cQuery += "and a.movunqty > 0" //Filtra UnMovs Zeradas
	cQuery += "and a.IdMovUn = "+ Alltrim(Str(_nUnMov))//Filtra UnMovs informada

	IncProc("Aguarde, Carregando Dados PPI")

	cQuery := ChangeQuery(cQuery)

	If Select("TRB1")>0
		DbSelectArea("TRB1")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "TRB1"

	DbSelectArea("TRB1")
	DbGotop()

	_cProdPPI   := TRB1->Produto
	_cOPPPI 	:= Alltrim(TRB1->OP)
	_cDescPPI	:= Alltrim(TRB1->Descr)
	_nQtdPPI	:= TRB1->Qtde
	_EofPPI	    := TRB1->(Eof())
	_DtLancto	:= TRB1->DtLancto

	DbCloseArea()
	TcUnLink(nHndPPI)
	TcSetConn(nHndERP)

	If !_EofPPI

		cQuery_1 := "SELECT ISNULL(SUM(ZL_METROS),0) QTUNMOV FROM "+RetSqlName("SZL")+" WHERE ZL_FILIAL = '"+xFilial("SZL")+;
			"' AND ZL_UNMOV = "+ IIf(_cTiAcd == "R",Alltrim(Str(M->_nUnMov)),Str(M->ZL_UNMOV)) +;
			" AND D_E_L_E_T_ = '' AND ZL_STATUS <> 'C'"
		cQuery_1 := ChangeQuery(cQuery_1)

		If Select("TRB2")>0
			DbSelectArea("TRB2")
			DbCloseArea()
		EndIf

		TCQUERY cQuery_1 NEW ALIAS "TRB2"
		DbSelectArea("TRB2")
		DbGotop()
		_nQtUnmov := TRB2->QTUNMOV
		DbCloseArea()

		If _nQtUnmov >= _nQtdPPI .and. ! Getmv("MV_LBPEBAL") // .F. Bloqueado e .T. Liberado a pesagem a maior
			Alert("UnMov ja utilizada totalmente!!! Não pode ser pesada novamente!")
			Return(.F.)
		ElseIf Posicione("SB1",1,xFilial("SB1")+_cProdPPI,"B1_TIPO") <> "PA"
			Alert("Produto UnMov não é PRODUTO ACABADO, Verificar!")
			Return(.F.)
		ElseIf _cTiAcd == "R"
			M->_ZL_NUMOP 	:= _cOPPPI
			M->_ZL_PROD		:= Padr(_cProdPPI,TamSX3("ZL_PRODUTO")[1])
			M->_ZL_DESC		:= _cDescPPI
			M->_nQtdUnMov	:= _nQtdPPI
		ElseIf  _cTiAcd == "B"
			M->ZL_NUMOP 		:= _cOPPPI
			If (Alltrim(_cProdPPI) == Alltrim(Posicione("SC6",1,xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,"C6_PRODUTO"))) .OR. M->ZL_PEDIDO == "000001"
				M->ZL_PRODUTO	:= Padr(_cProdPPI,TamSX3("ZL_PRODUTO")[1])
				M->ZL_DESC		:= _cDescPPI
				M->ZL_QTLANCE 	:= 1
				M->ZL_METROS 	:= _nQtdPPI
				M->ZL_QTUNMOV	:= _nQtdPPI
			Else
				Alert("Produto UnMov não corresponde ao produto do Pedido")
				Return(.F.)
			EndIf
		EndIf
	Else
		Alert("UnMov não existe")
		If _cTiAcd == "R"
			o_UnMov:SetFocus()
		EndIf
		Return(.F.)
	EndIf
Return(.T.)

/*/{Protheus.doc} CfUnMov
//TODO Verificar UnMov e retornar os dados da mesma na base do PC-Factory.
@author juliana.leme
@since 15/06/2015
@param _nUnMov, undefined, descricao
@param _lValQtd, undefined, descricao
@obs 06/01/2016 Roberto Obs:A partir de Janeiro 2016 as produções dos PA's realizadas no PCFactory também serão integradas
com o Protheus e portanto não mais serão produzidas pelo CDEST04X.
Então, a validação que estava sendo feita diretamente no BD do PCFactory, agora será feito na tabela SD3 com o campo D3_ZZUNMOV
ordem de indice do NickName D3_ZZPPI -> D3_FILIAL+D3_ZZUNMOV+D3_COD+D3_CF
@type function
/*/
User Function CfUnMov(_nUnMov,_lValQtd)
	Public _nQtUnmov := 0 // Qtde Soma ZL_METROS
	Public _nQtdPPI	 := 0 // Qtde UNMOV no PCF
	Default _lValQtd := .T. // Efetua a validação das quantidades

	_EofPPI 	:= .T.
	aTam 		:= TamSX3("D3_ZZUNMOV")
	_D3_UnMov 	:= _nUnMov //If(_cTiAcd == "R",M->_nUnMov,M->ZL_UNMOV)
	_D3_UnMov 	:= Str(_nUnMov,aTam[1]) //,aTam[2]

	DbSelectArea("SD3")
	DbOrderNickName("D3_ZZPPI") // D3_FILIAL+D3_ZZUNMOV+D3_COD+D3_CF
	DbSeek(xFilial("SD3") + _D3_UNMOV,.F.)
	Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_ZZUNMOV == Val(_D3_UnMov) .And. SD3->(!Eof())
		If SD3->D3_CF == "PR0" .And. SD3->D3_ESTORNO # "S" // É uma produção e não está estornada.
			_EofPPI	    := .F.
			_cProdPPI   := SD3->D3_COD
			_cOPPPI 	:= Left(SD3->D3_OP,8)
			_cDescPPI	:= Posicione("SB1",1,xFilial("SB1")+_cProdPPI,"B1_DESC")
			_nQtdPPI	:= SD3->D3_QUANT // quantidade original da unimov
			Exit
		EndIf
		SD3->(DbSkip())
	EndDo

	If !_EofPPI
		cQuery_1 := "SELECT ISNULL(SUM(ZL_METROS),0) QTUNMOV FROM "+RetSqlName("SZL")+" WHERE ZL_FILIAL = '"+xFilial("SZL")+;
			"' AND ZL_UNMOV = "+ IIf(_cTiAcd == "R",Alltrim(Str(M->_nUnMov)),Str(M->ZL_UNMOV)) +;
			" AND D_E_L_E_T_ = '' AND ZL_STATUS <> 'C'"
		cQuery_1 := ChangeQuery(cQuery_1)

		If Select("TRB2")>0
			DbSelectArea("TRB2")
			DbCloseArea()
		EndIf

		TCQUERY cQuery_1 NEW ALIAS "TRB2"
		DbSelectArea("TRB2")
		DbGotop()
		_nQtUnmov := TRB2->QTUNMOV // Quantidade já gravada no SZL dessa unimov
		DbCloseArea()

		If _lValQtd
			//Op Vazia não pode
			If Empty(Alltrim(_cOPPPI))
				Alert("UnMov não possui OP, Não pode ser utilizada!")
				If _cTiAcd == "R"
					o_UnMov:SetFocus()
				EndIf
				Return(.F.)
			EndIf
			//Valida Qtde pesada. Travada para que seja exatamente a mesma quantidade - Juliana Leme 02/09/2016
			If _nQtUnmov > _nQtdPPI .and. !Getmv("MV_LBPEBAL") // .F. Bloqueado e .T. Liberado a pesagem a maior
				Alert("UnMov ja realizada a pesagem total, Não pode ser pesada novamente!")
				If _cTiAcd == "R"
					o_UnMov:SetFocus()
				EndIf
				Return(.F.)
			ElseIf Posicione("SB1",1,xFilial("SB1")+_cProdPPI,"B1_TIPO") <> "PA"
				Alert("Produto UnMov não é PRODUTO ACABADO, Verificar!")
				Return(.F.)
			ElseIf _cTiAcd == "R"
				M->_ZL_NUMOP 	:= _cOPPPI
				M->_ZL_PROD		:= Padr(_cProdPPI,TamSX3("ZL_PRODUTO")[1])
				M->_ZL_DESC		:= _cDescPPI
				M->_nQtdUnMov	:= Max(_nQtdPPI - _nQtUnmov,0)
			ElseIf  _cTiAcd == "B"
				M->ZL_NUMOP 		:= _cOPPPI
				If (Alltrim(_cProdPPI) == Alltrim(Posicione("SC6",1,xFilial("SC6")+M->ZL_PEDIDO+M->ZL_ITEMPV,"C6_PRODUTO"))) .OR. M->ZL_PEDIDO == "000001"
					M->ZL_PRODUTO	:= Padr(_cProdPPI,TamSX3("ZL_PRODUTO")[1])
					M->ZL_DESC		:= _cDescPPI
					M->ZL_QTLANCE 	:= 1
					M->ZL_METROS 	:= _nQtdPPI
					M->ZL_QTUNMOV	:= Max(_nQtdPPI - _nQtUnmov,0)
				Else
					Alert("Produto UnMov não corresponde ao produto do Pedido")
					If _cTiAcd == "R"
						o_UnMov:SetFocus()
					EndIf
					Return(.F.)
				EndIf
			EndIf
		EndIf
	ElseIf _lValQtd
		//Temporario até a integração total da produção X PCF - Juliana Leme
		If !(U_CfUnMovPCF(_nUnMov,.T.))//Retirar após a integração total do sistema.
			Alert("Produção ainda não Integrada com o Protheus. Aguarde a integração ou entre em contato com o PCP ")
			If _cTiAcd == "R"
				o_UnMov:SetFocus()
			EndIf
			Return(.F.)
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} GrvDadSZL
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 03/09/2016
@version undefined
@param _lImprEtq, , descricao
@param _lNewNum, , descricao
@type function
/*/
User Function GrvDadSZL(_lImprEtq,_lNewNum,_cFilOriBb) // Imprime Etiquetas? , Dá novo número?, Filial de origem da bobina
	Local cStatus 		:= ""
	local lOpcTEtq 		:= GetNewPar('ZZ_OPCTETQ', .F.)

	If SZL->ZL_TIPO == "D" // Pesagem acima de 1500 Kg
		RecLock("SZL",.F.)
		SZL->ZL_TIPO := "P"   // trata-se de uma produção
		MsUnLock()
	EndIf

	_cEtiqNew := "      " // Vazio = Indica se dá um novo número na etiqueta
	_lDevVen  := .F. // Devolução de vendas ?
	If SZL->ZL_TIPO == "T" .Or. SZL->ZL_TIPO == "F" // Se for troca de etiqueta ou troca de filial
		// Posiciono o registro _nRegSZE  vindo da função TrocaEtq()
		SZE->(DbGoTo(_nRegSZE))

		If SZL->ZL_TIPO == "T" .And. SZE->ZE_STATUS == "F"// Se for troca de etiqueta de uma bobina faturada
			_lDevVen  := .T. // Trata-se de uma devolução de vendas
		EndIf

		RecLock("SZE",.F.)
		If !_lImprEtq
			_cEtiqNew := "      " // Vazio = Indica se dá um novo número na etiqueta
		ElseIf Empty(SZE->ZE_SITUACA) // SZE->ZE_SITUACA estiver vazio trata-se de etiqueta velha então dou novo número
			SZE->ZE_STATUS  := "C"
			_cEtiqNew := "      " // Vazio = Indica se dá um novo número na etiqueta
		Else
			_cEtiqNew := SZE->ZE_NUMBOB // Com um número = Utilizo o mesmo número na etiqueta
		EndIf
		If _lNewNum // Dá novo número
			_cEtiqNew := "      " // Vazio = Indica se dá um novo número na etiqueta
		Else
			_cEtiqNew := SZE->ZE_NUMBOB // Com um número = Utilizo o mesmo número na etiqueta
		EndIf

		SZE->ZE_SITUACA := "0" // Substituida
		MsUnLock()

		If SZL->ZL_TIPO == "T" .And. !_lDevVen	// Se for troca de etiqueta e Não é devolução de vendas.
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
		if !_lNewNum .and. SZE->ZE_STATUS == "C" .and. lOpcTEtq
			SZE->(RecLock("SZE",.F.))
				SZE->(DbDelete())
			SZE->(MsUnLock())
		endif
	EndIf

	If Empty(_cEtiqNew)// Vazio = Indica se dá um novo número na etiqueta
		// Em 02/09/2016 - Jeferson, Juliana e Roberto decidiram tratar o numero da bobina com uma sequencia por empresa
		// por isso estamos desabilitando a função fProxBob() e Habilitando a função fNextBob()
		// _cPrxBob := fProxBob() //Pega o numero da proxima bobina. Uma sequencia por filial
		_cPrxBob := fNextBob()//Pega o numero da proxima bobina. Uma sequencia para a empresa
	Else
		_cPrxBob := _cEtiqNew
	EndIf

	// Busca proximo nro da pesagem
	DbSelectArea("SZL")
	_nNumReg := SZL->(Recno())
	_cNumPes := ProxPes(_nNumReg) // Para achar o nro o proximo nro da pesagem.. ele desposiciona do SZL... por isoo a variável _nNumReg
	DbSelectArea("SZL")
	SZL->(DbGoTo(_nNumReg))
	RecLock("SZL",.F.)
	If SZL->ZL_DATA # dDataBase
		SZL->ZL_DATA := dDataBase
	EndIf
	SZL->ZL_NUM    := _cNumPes
	SZL->ZL_NUMBOB := _cPrxBob
	SZL->ZL_EMB    := SZL->ZL_TARA //  A TARA NA BOBINA É O PESO DA EMBALAGEM
	SZL->ZL_TARA   := 0.00
	If SZL->ZL_TIPO $ "TF" // Marcar a pesagem como já processada para não incluir no estoque
		SZL->ZL_STATUS := "P"
		//ElseIf (SZL->ZL_PESOEFE < 18 .And. SZL->ZL_ACOND=="B") .Or. (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax) //.And. FWCodEmp()+FWCodFil() == "0101"
	ElseIf (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax) //.And. FWCodEmp()+FWCodFil() == "0101"
		SZL->ZL_STATUS := "Q" // Vai para CQ fazer vistoria e não pode processar
	ElseIf !Empty(SZL->ZL_PEDIDO)
		_cCliLj := Posicione("SC5",1,xFilial("SC5")+SZL->ZL_PEDIDO,"C5_CLIENTE+C5_LOJACLI")
		If u_xIsInspe(Alltrim(SZL->ZL_PEDIDO))[1]
			SZL->ZL_STATUS := "Q" // Vai para CQ fazer vistoria e não pode processar
		EndIf
	EndIf
	SZL->ZL_HORA := Left(Time(),Len(SZL->ZL_HORA))
	// Calcula o turno
	// 1ro. das 06:01 as 14:00
	// 2ndo das 14:01 as 22:00
	// 3ro  das 22:01 as 06:00
	_MyTime := Left(SZL->ZL_HORA,5)
	If _MyTime >= "06:01" .And. _MyTime <= "14:00"
		SZL->ZL_TURNO := "1"
	ElseIf _MyTime >= "14:01" .And. _MyTime <= "22:00"
		SZL->ZL_TURNO := "2"
	ElseIf _MyTime >= "22:01" .Or.  _MyTime <= "06:00"
		SZL->ZL_TURNO := "3"
	EndIf

	MsUnLock()

	If !Empty(SZL->ZL_UNMOV)
		// Flegar o SD3 da produção que já tem pesagem para essa produlção
		u_FlagSD3(SZL->ZL_UNMOV,.T.)
	EndIf

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	DbSeek(xFilial("SC6")+SZL->ZL_PEDIDO+SZL->ZL_ITEMPV,.F.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	DbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,.F.)
	_lInsp := u_xIsInspe(Alltrim(SZL->ZL_PEDIDO))[1]

	RecLock("SZE",.T.)
	SZE->ZE_FILIAL  := xFilial("SZE")
	SZE->ZE_FILORIG := _cFilOriBb // FWCodFil()
	SZE->ZE_NUMBOB  := SZL->ZL_NUMBOB
	SZE->ZE_ZZPVORI := Left(SC6->C6_ZZPVORI,Len(SZE->ZE_ZZPVORI)) // SZE->ZE_ZZPVORI pode

	// Alteração em 01/03/13
	// As bobinas serão processadas da mesma forma nas duas filiais
	//	If FWCodEmp() + FWCodFil() == "0101"
	If !_lImprEtq .And. !SUPERGETMV("ZZ_EMPENT",, .F.)
		cStatus := "P"
	ElseIf !_lImprEtq .And. SUPERGETMV("ZZ_EMPENT",, .F.)
		cStatus := "E"
	Else
		cStatus := "I"
	EndIf
	SZE->ZE_STATUS  :=  cStatus // Quando for por Ret.Indl. vai direto para empenhada.

	// Em ITU -> Primeiro recebe o Status I para depois ser "recebida" e ficar com o status correto
	//	ElseIf FWCodEmp() + FWCodFil() == "0102" // 3L
	//		SZE->ZE_STATUS  := If(SZE->ZE_PEDIDO=="000001","T","P") // Em 3L  -> Recebe direto o status pra estoque ou a ampenhar
	//	EndIf
	SZE->ZE_CLIENTE := SC6->C6_CLI
	SZE->ZE_LOJA    := SC6->C6_LOJA
	SZE->ZE_NOMCLI  := If(SZL->ZL_PEDIDO=="000001","ESTOQUE",SA1->A1_NOME)
	SZE->ZE_PEDIDO  := SZL->ZL_PEDIDO
	SZE->ZE_ITEM    := SZL->ZL_ITEMPV
	SZE->ZE_DESTINO := If(SZL->ZL_PEDIDO=="000001","ESTOQUE",AllTrim(SA1->A1_MUN)+" - " + SA1->A1_EST)
	SZE->ZE_PRODUTO := SZL->ZL_PRODUTO
	SZE->ZE_DESCPRO := SZL->ZL_DESC
	SZE->ZE_QUANT   := SZL->ZL_METROS
	SZE->ZE_LOTE    := SZL->ZL_LOTE
	SZE->ZE_DATA    := SZL->ZL_DATA
	SZE->ZE_TPBOB   := SZL->ZL_TPBOB
	SZE->ZE_TARA    := SZL->ZL_EMB
	SZE->ZE_PESO    := SZL->ZL_PBRUT-SZL->ZL_TARA
	SZE->ZE_PLIQ    := SZL->ZL_PBRUT-SZL->ZL_TARA-SZL->ZL_EMB
	SZE->ZE_DESVIO  := SZL->ZL_DESVIO
	SZE->ZE_FUNC    := SZL->ZL_OPER
	SZE->ZE_NOME    := SZL->ZL_NOMOPER
	SZE->ZE_OP      := SZL->ZL_NUMOP
	SZE->ZE_DTPES   := Date()
	SZE->ZE_HRPES   := Left(TIME(),Len(SZE->ZE_HRPES))
	If SZL->ZL_TIPO $ "TFR"
		SZE->ZE_BOBORIG := _cBobAnt
	EndIf
	If SZL->ZL_TIPO $ "TF" // Marcar a pesagem como já processada para não incluir no estoque
		//Conforme solicitação Felipe 16/09/2016 - Juliana Leme
		If ! Empty(SZL->ZL_NUMBOB)
			If SZE->ZE_STATUS == "R" .OR. SZE->ZE_STATUS == "I"
				If SZE->ZE_PEDIDO == "000001"
					SZE->ZE_STATUS  := "T"
					SZE->ZE_DTREC   := Date()
					SZE->ZE_HRREC   := Left(TIME(),Len(SZE->ZE_HRREC))
				Else
					SZE->ZE_STATUS  := "P"
					SZE->ZE_DTREC   := Date()
					SZE->ZE_HRREC   := Left(TIME(),Len(SZE->ZE_HRREC))
				EndIf
			EndIf
		EndIf
	EndIf

	MsUnLock()

	DbSelectArea("SZ9")
	SZ9->(DbSetOrder(7)) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
	If DbSeek(xFilial("SZ9")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,.F.)
		RecLock("SZ9",.F.)
		SZ9->Z9_QTDETQ := SZ9->Z9_QTDETQ + 1
		SZ9->Z9_QTDMTS := SZ9->Z9_QTDMTS + SZE->ZE_QUANT
		MsUnLock()
	EndIf

	DbSelectArea("SZE")

	If _lImprEtq
		u_ImprEtBob(3,.T.) // u_ImprEtBob(3,.F.) // u_ImprEtBob(3,.T.) se alterar esta linha para .F., falar com Roberto/Juliana

		//If (SZL->ZL_PESOEFE < 18 .And. SZL->ZL_ACOND=="B") .Or. (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax .Or. _lInsp) //.And. FWCodEmp()+FWCodFil() == "0101"
		If (SZL->ZL_DESVIO < _nDesMin .Or. SZL->ZL_DESVIO > _nDesMax .Or. _lInsp) //.And. FWCodEmp()+FWCodFil() == "0101"
			// 24/01/2012 - Ivo e Crispilho pediram para não imprimir os boletins de bobinas pois não tem
			// funcionalidade porque a conferência é feita pelo coletor
			// Imprimir somente quando estiver fora do desvio aceitável
			// Válido somente para Itu

			If (SZL->ZL_ACOND=="R")
				u_ImprBolet(2,_lInsp)//2 vias
			Else
				u_ImprBolet(1,_lInsp)//1 via
			EndIf

			//u_ImprBolet(2,_lInsp)
			//ElseIf FWCodEmp()+FWCodFil() # "0101"
			//	u_ImprBolet(2,_lInsp)
		EndIf

		If SZL->ZL_TIPO == "R" // Retorno de retrabalho
			U_BAL03ZZE({SZL->ZL_ZZEID,SZL->ZL_QTLANCE,SZL->ZL_LANCE,SZL->ZL_ACOND,SZL->ZL_PEDIDO,SZL->ZL_ITEMPV,;
				SZL->ZL_PRODUTO},.T.,(SZL->ZL_DESVIO<_nDesMin .Or. SZL->ZL_DESVIO>_nDesMax),.T.) // BAIXAR RETRABALHO PROATIVA
			//SZL->ZL_PRODUTO},.T.,((SZL->ZL_PESOEFE < 18 .And. SZL->ZL_ACOND=="B") .Or.(SZL->ZL_DESVIO<_nDesMin .Or. SZL->ZL_DESVIO>_nDesMax)),.T.) // BAIXAR RETRABALHO PROATIVA
		EndIf
	Endif
	IntegWMS()
Return(.T.)

/*/{Protheus.doc} FlagSD3
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 03/09/2016
@version undefined
@param _UNMOV, , descricao
@param lFlag, logical, descricao
@type function
/*/
User Function FlagSD3(_UNMOV,lFlag)
	Local _UNMOV // Nro da Unimov
	Local lFlag  // Flegar o registro como com pesagem no SZL
	Local cNmSeq := "      " // Retornar o NumSeq do Movimento

	_aAreaAtu := GetArea()
	aTam := TamSX3("D3_ZZUNMOV")
	_D3_UNMOV := Str(_UNMOV,aTam[1]) //,aTam[2]
	DbSelectArea("SD3")
	_aAreaSD3 := GetArea()
	DbOrderNickName("D3_ZZPPI") // D3_FILIAL+D3_ZZUNMOV+D3_COD+D3_CF
	DbSeek(xFilial("SD3") + _D3_UNMOV,.F.)
	Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_ZZUNMOV == Val(_D3_UNMOV) .And. SD3->(!Eof())
		If SD3->D3_CF == "PR0" .And. SD3->D3_ESTORNO # "S" // É uma produção e não está estornada.
			If lFlag .And. SD3->D3_TEMPES # "S"
				RecLock("SD3",.F.)
				SD3->D3_TEMPES := "S"
				MsUnLock()
			EndIf
			cNmSeq := SD3->D3_NUMSEQ
		EndIf
		SD3->(DbSkip())
	EndDo
	RestArea(_aAreaSD3)
	RestArea(_aAreaAtu)
Return(cNmSeq)

/*/{Protheus.doc} EtiqAvul
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 03/09/2016
@version undefined
@param _nPar, , descricao
@type function
/*/
User Function EtiqAvul(_nPar)
	// 12/04/2016 Estou adaptando esta função para também imprimir também etiquetas
	// para a Huawei
	Local _nPar, _cTitulo
	local cCodLoja	:= ''

	_lResp := .F.
	aRet :={}
	aParamBox := {}

	If _nPar == 1 // Huawei                                      R
		_cTitulo := "Etiqueta Huawei Avulsa. "

		//If "ROBERTO" $ Upper(cUserName)
		_lVai := .F. // Usar os parâmetros novos
		//Else
		//	_lVai := .T. // Usar os parâmetros antigos
		//EndIf

		If _lVai
			aAdd(aParamBox,{1,"Cód.Produto: ",Padr(" ",TamSX3("B1_COD")[1]),,'EXISTCPO("SA7","01464204"+MV_PAR01)',"A7HUAW","",60,.T.})
			aAdd(aParamBox,{1,"Tam.Lance: "     ,0.000                         ,"@E 999,999.999","MV_PAR02 > 0"    ,"","",50,.T.})
			aAdd(aParamBox,{2,"Acondic.","Rolo",{"Rolo","Carretel N8","Carretel Madeira","Bobina","Blister"},50,"",.T.})
			//1-Rolo, 2-Carretel N8, 3-Carretel Madeira, 4-Bobina , 5-Retalho    , 6-Blister" // Pertence('RBCTML')
			aAdd(aParamBox,{1,"Data Prod.: "     ,dDatabase                     ,			,"!Empty(MV_PAR04)"	,""	,"",50,.T.})
			aAdd(aParamBox,{1,"Nro.Ped.Cliente: ",Padr(" ",20)					,			,''					,""	,"",50,.T.})
			aAdd(aParamBox,{1,"Quant.Lances: "	 ,0                             ,"@E 999"	,"MV_PAR06 > 0"		,""	,"",50,.T.})
			aAdd(aParamBox,{1,"Num Bobina: ",Padr(" ",7),,''  	       ,"","MV_PAR03=='Bobina'",50,MV_PAR03=='Bobina'}) //.T.})
		Else
			//1-Rolo, 2-Carretel N8, 3-Carretel Madeira, 4-Bobina , 5-Retalho    , 6-Blister" // Pertence('RBCTML')
			aAdd(aParamBox,{2,"Acondic. ","Rolo",{"Rolo","Carretel N8","Carretel Madeira","Bobina","Blister"},50,"u_ZereBob()",.T.})
			aAdd(aParamBox,{1,"Num Bobina: ",Padr(" ",7),,"u_AcheBob()",  ,"MV_PAR01=='Bobina'",50,MV_PAR03=='Bobina'})
			aAdd(aParamBox,{1,"Cód.Produto:",Padr(" ",TamSX3("B1_COD")[1]),,,"A7HUAW","MV_PAR01#'Bobina'",60,.T.})
			aAdd(aParamBox,{1,"Tam.Lance: ",0.000,"@E 999,999.999","MV_PAR04 > 0","","MV_PAR01#'Bobina'",50,.T.})
			aAdd(aParamBox,{1,"Data Prod.: ",dDatabase,,"!Empty(MV_PAR05)","","MV_PAR01#'Bobina'",50,.T.})
			aAdd(aParamBox,{1,"Nro.Ped.Cliente:",Padr(" ",20),        ,''            ,"","MV_PAR01#'Bobina'",50,.T.})
			aAdd(aParamBox,{1,"Quant.Lances:"   ,0           ,"@E 999","MV_PAR07 > 0","","MV_PAR01#'Bobina'",50,.T.})
		EndIf
	ElseIf _nPar == 2 // Elektro
		_cTitulo := "Etiqueta Elektro Avulsa. "
		cCodLoja := "01988351"
		aAdd(aParamBox,{1,"Cód.Produto: ",Padr(" ",TamSX3("B1_COD")[1]),,'EXISTCPO("SA7","01988351"+MV_PAR01)',"A7ELEK","",60,.T.})
		aAdd(aParamBox,{1,"Tam.Lance: "     ,0.000                         ,"@E 999,999.999","MV_PAR02 > 0"    ,"","",50,.T.})
		aAdd(aParamBox,{1,"Lote: "           ,Padr(" ",TamSX3("ZL_LOTE")[1]),                ,''                ,"","",50,.T.})
		aAdd(aParamBox,{1,"Data Prod.: "     ,dDatabase                     ,			,"!Empty(MV_PAR04)"	,""	,"",50,.T.})
		aAdd(aParamBox,{1,"Nro.Ped.Cliente: ",Padr(" ",20)					,			,''					,""	,"",50,.T.})
		aAdd(aParamBox,{1,"Quant.Lances: "	 ,0                             ,"@E 999"	,"MV_PAR06 > 0"		,""	,"",50,.T.})
	EndIf

	If ParamBox(aParamBox, _cTitulo, @aRet)
		If _nPar == 1 // Huawei
			If !_lVai // Os parâmetros foram invertidos e devem ser corrigidos
				_MV_PAR01 := aRet[03] // "Cód.Produto:"
				_MV_PAR02 := aRet[04] // "Tam.Lance: "
				_MV_PAR03 := aRet[01] // "Acondic. "
				_MV_PAR04 := aRet[05] // "Data Prod.: "
				_MV_PAR05 := aRet[06] // "Nro.Ped.Cliente:"
				_MV_PAR06 := aRet[07] // "Quant.Lances:"
				_MV_PAR07 := aRet[02] // "Num Bobina: "

				aRet[01] := _MV_PAR01
				aRet[02] := _MV_PAR02
				aRet[03] := _MV_PAR03
				aRet[04] := _MV_PAR04
				aRet[05] := _MV_PAR05
				aRet[06] := _MV_PAR06
				aRet[07] := _MV_PAR07
			EndIf
			if !empty(validSA7(aRet[05], aRet[01], @cCodLoja))
				If (aRet[03] $ "Carretel N8/Carretel Madeira/Bobina")
					If MsgBox("Para " + aRet[03] + ", serão emitidas " + ;
							Transform(aRet[06]*3,"@E 99,999") + " etiquetas, sendo 3 para cada Lance." + Chr(13) + Chr(13) + ; // aRet[06]
						"Colar as etiquetas com o mesmo número no mesmo lance!!","Confirma a Emissão das Etiquetas?","YesNo")
						aRet[03] := "B"
					Else
						aRet[03] := " "
					EndIf
				Else
					aRet[03] := "R"
				EndIf
			else
				Alert("Produto " + AllTrim(aRet[01]) +;
					" não Informado na Tabela Produto x Cliente." +;
					Chr(13) + Chr(13) + "Comunique a Engenharia!")
				aRet[03] := " "
			endif
		EndIf

		If !Empty(aRet[03])
			DbSelectArea("SA7")
			DbSetOrder(1)
			If DbSeek(xFilial("SA7") + cCodLoja + aRet[01],.F.)
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1") + SA7->(A7_PRODUTO),.F.)
				If _nPar==1 // Huawei
					EtiHuawei(1,aRet[02],SA7->A7_PRODUTO,aRet[06],aRet[03],aRet[07],aRet[04])
				Else // Elektro
					EtiElektro(aRet[06],aRet[02],aRet[03],aRet[04],aRet[05])
				EndIf
			EndIf
		EndIf
	EndIf
Return(.T.)

static function validSA7(cNumPed, cCodProd, cCodLoja)
	local aArea    	:= GetArea()
	local lOk 		:= .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cCodCli	:= ''

	default cNumPed := ''
	default cCodProd:= ''
	default cCodLoja:= ''

	if !empty(cCodProd) .and. !empty(cNumPed)
		oSql:newTable("SC5",;
			"C5_CLIENTE CLI, C5_LOJACLI LOJACLI",;
			"%SC5.XFILIAL% AND C5_NUM = '" + cNumPed + "'")
		if (oSql:hasRecords())
			cCodLoja := oSql:getValue("CLI") + oSql:getValue("LOJACLI")
			oSql:close()
			oSql:newTable("SA7",;
				"A7_CODCLI CODCLI",;
				"%SA7.XFILIAL% AND A7_CLIENTE + A7_LOJA = '" + cCodLoja + "' AND A7_PRODUTO = '" + cCodProd + "'")
			if(oSql:hasRecords())
				cCodCli := oSql:getValue("CODCLI")
			endif
		endif
		oSql:close()
	endif

	FreeObj(oSql)
	RestArea(aArea)
return(cCodCli)


/*/{Protheus.doc} EtiElektro
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _nVias, , descricao
@param _nQtdMt, , descricao
@param _cLote, , descricao
@param _dData, , descricao
@param _cPdCli, , descricao
@type function
/*/
Static Function EtiElektro(_nVias,_nQtdMt,_cLote,_dData,_cPdCli)
	Local _DescEk1 := Left(SA7->A7_DESCCLI+SA7->A7_DESC2+SA7->A7_DESC3,53)
	Local _DescEk2 := Substr(SA7->A7_DESCCLI+SA7->A7_DESC2+SA7->A7_DESC3,54,53)
	Local _cBarr
	Local _nQtdMt, _cLote, _dData,_cPdCli

	Private wnrel   := "ETIQUETA"
	Private cString := "ETIQUETA"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}

	Default _nQtdMt := SZE->ZE_QUANT
	Default _cLote  := SZE->ZE_LOTE
	Default _dData  := dDataBase
	Default _cPdCli := "#ACHAR" // Procurar no SC6 ou no SC5

	If _cPdCli == "#ACHAR"
		// Primeiro procurar no SC6
		_cPdCli := Posicione("SC6",1,xFilial("SC6")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,"C6_PEDCLI")
	EndIf
	If Empty(_cPdCli)
		// sE NÃO ACHOU, procurar no SC5
		_cPdCli := Posicione("SC5",1,xFilial("SC5")+SZE->ZE_PEDIDO,"C5_PEDCLI")
	EndIf

	_cPdCli := AllTrim(_cPdCli)

	_cBarr := StrTran(StrTran(Right(AllTrim(SA7->A7_CODCLI),5)+StrZero(_nQtdMt,10,3),".",""),",","")

	_DescEk1 := StrTran(_DescEk1,"^","") // caracter especial na zebra
	_DescEk2 := StrTran(_DescEk2,"^","") // caracter especial na zebra

	SetDefault(aReturn,cString)

	@ 0,0 PSAY "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"
	@ 0,0 PSAY "^XA"
	@ 0,0 PSAY "^MMT"
	@ 0,0 PSAY "^PW1228"
	@ 0,0 PSAY "^LL0945"
	@ 0,0 PSAY "^LS0"

	@ 0,0 PSAY "^FO050,020^XGELEKTR65.GRF^FS"
	@ 0,0 PSAY "^FO455,030^XGLOGO30A.GRF^FS"

	@ 0,0 PSAY "^FT055,177^A0N,28,28^FH\^FDCOD: " + AllTrim(SA7->A7_CODCLI) + "^FS"
	@ 0,0 PSAY "^FT055,225^A0N,28,28^FH\^FD" + _DescEk1 + "^FS"
	@ 0,0 PSAY "^FT055,253^A0N,28,28^FH\^FD" + _DescEk2 + "^FS"

	@ 0,0 PSAY "^FT055,301^A0N,28,28^FH\^FDQT:^FS"

	If Upper(SB1->B1_UM) == "MT"
		_cUm := "m"
	ElseIf Upper(SB1->B1_UM) == "KG"
		_cUm := "kg"
	Else
		_cUm := SB1->B1_UM
	EndIf
	@ 0,0 PSAY "^FT106,301^A0N,28,28^FH\^FD" + Transform(_nQtdMt,"@E 999,999.999") + " " + _cUm + "^FS"

	If !Empty(_cLote)
		//@ 0,0 PSAY "^FT350,301^A0N,28,28^FH\^FDLT: " + AllTrim(_cLote) + "^FS"
		@ 0,0 PSAY "^FT380,301^A0N,28,28^FH\^FDLote n / Serie n: " + AllTrim(_cLote) + "^FS"
	EndIf
	@ 0,0 PSAY "^FT055,349^A0N,28,28^FH\^FDDT:   " + ;
		StrZero(Day(_dData),2) + "." +;
		StrZero(Month(_dData),2) + "." +;
		StrZero(Year(_dData),4) + "^FS"

	@ 0,0 PSAY "^FT380,349^A0N,28,28^FH\^FDN.Pedido: " + _cPdCli + "^FS"

	//@ 0,0 PSAY "^BY4,3,178^FT183,537^BCN,,Y,N"
	@ 0,0 PSAY "^BY4,3,120^FT183,537^BCN,,Y,N"
	@ 0,0 PSAY "^FD>;" + _cBarr + "^FS"
	@ 0,0 PSAY "^PQ"+AllTrim(Str(_nVias))+",0,1,Y^XZ"

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)

/*/{Protheus.doc} NewSzj
//TODO Cria SZJ para todos os produtos+acondicionamento que não existir.
@author Roberto
@since 16/05/2016
@param _NewCod, undefined, descricao
@param _NewLclz, undefined, descricao
@type function
/*/
User Function NewSzj(_NewCod,_NewLclz)
	Local _NewCod,_NewLclz, _xCodBars

	_xCodBars := u_NextEan()
	DbSelectArea("SZJ")
	RecLock("SZJ",.T.)
	SZJ->ZJ_FILIAL  := xFilial("SZJ")
	SZJ->ZJ_PRODUTO := _NewCod
	SZJ->ZJ_LOCALIZ := _NewLclz
	SZJ->ZJ_CODBAR  := _xCodBars
	MsUnLock()

	// Enviar email para SGQ e TI informando o uso de mais um número.
	_aCab := {}
	Aadd(_aCab,"Código")
	Aadd(_aCab,"Descrição")
	Aadd(_aCab,"Acondic.")
	Aadd(_aCab,"Cód. GTIN")
	_aDet := {}
	Aadd(_aDet,{SZJ->ZJ_PRODUTO,Posicione("SB1",1,xFilial("SB1")+SZJ->ZJ_PRODUTO,"B1_DESC"),;
		SZJ->ZJ_LOCALIZ,SZJ->ZJ_CODBAR})

	u_envMail({"gtin@cobrecom.com.br"},;
		"Criação de Novo Gtin",;
		_aCab,;
		_aDet)

Return(_xCodBars)


/*/{Protheus.doc} ProxHuawei
//TODO Calcula e traz a proxima sequencian de Id para etiquetas da Huawei.
@author Roberto
@since 16/05/2016
@type function
/*/
Static Function ProxHuawei()
	Local _cSeqAtu := ""
	Local _cSeqPrx := ""
	// Retorna o próximo número sequencial das etiquetas esécíficas da Huawei
	// e incrementa 1, quando chegar em 999.999 volta para 000.001.
	DbSelectArea("SX6")
	If !Dbseek("  MV_XSEQHUA",.F.) // Sempre procura um parâmetro compartilhado.
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "MV_XSEQHUA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Controle Sequencial das Etiquetas Huawei"
		SX6->X6_DSCSPA  := SX6->X6_DESCRIC
		SX6->X6_DSCENG  := SX6->X6_DESCRIC
		SX6->X6_CONTEUD := "000001"
		SX6->X6_CONTSPA := SX6->X6_CONTEUD
		SX6->X6_CONTENG := SX6->X6_CONTEUD
		SX6->X6_PROPRI  := "U"
		MsUnLock()
	EndIf
	Do While !RecLock("SX6",.F.)
	EndDo
	_cSeqAtu := Val(AllTrim(SX6->X6_CONTEUD))
	_cSeqPrx := _cSeqAtu + 1
	If _cSeqPrx > 999999
		_cSeqPrx := 1
	EndIf
	_cSeqPrx := StrZero(_cSeqPrx,6)
	SX6->X6_CONTEUD := _cSeqPrx
	SX6->X6_CONTSPA := SX6->X6_CONTEUD
	SX6->X6_CONTENG := SX6->X6_CONTEUD
	SX6->(MsUnLock())
Return(_cSeqAtu) // Retorna uma variável numérica

/*/{Protheus.doc} GPixel
//TODO Converte Pixel em Milimetros.
@author juliana.leme
@since 03/09/2016
@version undefined
@param _nMm, numerico, converte milimetros em pixels
@type function
/*/
Static Function GPixel(_nMm)
	_nRet:=(_nMm/25.4)*300
Return(_nRet)


/*/{Protheus.doc} ZereBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function ZereBob()
	MV_PAR02 == Padr(" ",7)
	If MV_PAR01 == 'Bobina' // Escolheu bobina
		MV_PAR03 == Padr(" ",TamSX3("B1_COD")[1])
		MV_PAR04 == 0.000
		MV_PAR05 == dDatabase
		MV_PAR06 == Padr(" ",20)
	EndIf
Return(.T.)


/*/{Protheus.doc} AcheBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined

@type function
/*/
User Function AcheBob()
	DbSelectArea("SZE")
	DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
	If !DbSeek(xFilial("SZE") + MV_PAR02,.F.)
		Alert("Bobina não Localizada")
		Return(.F.)
	EndIf
	If !"HUAWEI" $ Upper(SZE->ZE_NOMCLI)
		Alert("Bobina não Pertence a Huawei")
		Return(.F.)
	EndIf

	DbSelectArea("SA7")
	DbSetOrder(1) //A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
	// Procurar no SA7 sempre os produtos cadastrados para o cliente 014642-04"
	_cPrdHwy := Left(Left(SZL->ZL_PRODUTO,10) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
	If !(DbSeek(xFilial("SA7")+SZE->ZE_CLIENTE+SZE->ZE_LOJA+SZE->ZE_PRODUTO,.F.))
		Alert("Produto " + AllTrim(SZE->ZE_PRODUTO) + " não Informado na Tabela Produto x Cliente." + Chr(13) + Chr(13) + ;
			"Comunique a Engenharia!")
		Return(.F.)
	EndIf
	MV_PAR03 := SZE->ZE_PRODUTO
	MV_PAR04 := SZE->ZE_QUANT
	MV_PAR05 := SZE->ZE_DATA
	MV_PAR06 := Padr(SZE->ZE_PEDIDO,20)
	MV_PAR07 := 1
Return(.T.)

/*/{Protheus.doc} EtiNumBob
//TODO Descrição auto-gerada.
@author Roberto Oliveira
@since 07/06/2017
@version undefined
@param _cNumBob, , descricao
@type function
/*/
Static Function EtiNumBob(_cNumBob)
	Private wnrel   := "ETIQUETA"
	Private cString := "ETIQUETA"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}

	SetDefault(aReturn,cString)

	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	@ 0,0 PSAY "^FO010,200^A0N,300,230^FD"+_cNumBob+"^FS"
	@ 0,0 PSAY "^PQ"+"2"+",0,1,Y^XZ" // 2 vias
	//@ 0,0 PSAY "^PQ"+AllTrim(Str(_nVias))+",0,1,Y^XZ"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)

static function IntegWMS(lManual)
	local oInt 		:= nil
	default lManual := .F.

	oInt := cbcExpIntegra():newcbcExpIntegra(lManual)
	oInt:addPesagem(SZL->ZL_NUM, SZL->(Recno()))
	if lManual
		if oInt:isOk()
			MsgInfo('Pesagem Integrada ao WMS', 'Integração')
		else
			MsgAlert('Erro ao Integrar: ' + oInt:getErrMsg(),'Error')
		endif
	endif
	FreeObj(oInt)
return(.T.)

Static Function getLasNum()
	Local aArea := GetArea()
	Local oSql  := LibSqlObj():newLibSqlObj()
	Local cDat  := SuperGetMv("ZZ_DDTNPES",,"20210201")
	Local cQry  := ''
	Local cNum  := '0'

    cQry := " SELECT "
    cQry += " MAX(SZL.ZL_NUM) AS [NUM] "
    cQry += " FROM " + retSqlName('SZL') + " SZL "
    cQry += " WHERE SZL.ZL_FILIAL = '" + xFilial('SZL') + "' "
    cQry += " AND SZL.ZL_DATA >= '" + cDat + "' "
    cQry += " AND SZL.D_E_L_E_T_ = '' "

	oSql:newAlias(cQry)
    If oSql:hasRecords()
		oSql:goTop()
        cNum := oSql:getValue("NUM")
    endif
    oSql:close()
    FreeObj(oSql)
	RestArea(aArea)
Return cNum
