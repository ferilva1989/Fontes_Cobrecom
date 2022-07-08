#include 'Protheus.ch'
#include 'TopConn.ch'
#include 'RWMake.ch'
#xtranslate bSetGet(<uVar>) => {|u| If(PCount()== 0, <uVar>,<uVar> := u)}

User function CBCTraFil()	
	Local aHead1 		:= {}
	Local aSizeAuto 	:= MsAdvSize()
	private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	Private aCols1		:= {}
	Private dEmissao	:= dDataBase
	Private cPicture	:= PesqPict('SC6','C6_QTDVEN')
	Private bValProduto	:= {|| fValid('PRODUTO')}
	Private bValQuant	:= {|| fValid('QUANT')}
	Private bValAlmox	:= {|| fValid('ALMOX')}
	Private bValEnderec	:= {|| fValid('ENDEREC')}
	Private bValOper	:= {|| fValid('OPER')}
	Private bLinOk 		:= {|| fValid('LINHA')}
	Private bfDeleta	:= {|| fDeleta()}
	Private nPosProduto, nColDel, nPosDesc, nPosUnidade
	Private nPosQuant, nPosAlmox, nPosEnderec, nPosOper
	
	aHead1 := fHeader()
	nPosProduto	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'PRODUTO'})
	nPosDesc	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'DESC'})
	nPosUnidade	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'UNIDADE'})
	nPosQuant	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'QUANT'})
	nPosAlmox	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'ALMOX'})
	nPosEnderec	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'ENDEREC'})
	nPosOper	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'OPER'})
	
	If xFilial("SC6") == "02"
		_cCli := "002560"  // seleciono o cliente matriz
		_cLoj := "01"
	Else                   // estou na filial
		_cCli := "008918"  // seleciono o cliente filial
		_cLoj := "01"
	EndIf			
	_cNomeCli	:=	Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_NOME")
	_CCliLoj 	:= _cCli + "/" + _cLoj
	aCols1 		:= fCols()
	nColDel 	:= Len(aCols1[1])
	nOpc 		:= GD_INSERT + GD_UPDATE + GD_DELETE
	oDlgSep		:= MSDialog():New(aSizeAuto[7], 020, aSizeAuto[6]-20, aSizeAuto[5]-40,"Transferencia entre Filiais COBRECOM",,,.F.,,,,,,.T.,,,.T. )
	oSayEmiss	:= TSay():New( 10,10 ,{||"Emissão:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oGetEmiss	:= TGet():New( 10,42 ,bSetGet(dEmissao),oDlgSep,044,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,,.F.,.F.,,.F.,.F.,'','',,)
	oSayCli		:= TSay():New( 30,10 ,{||"Cliente:"} ,oDlgSep,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oGetCli		:= TGet():New( 30,42 ,bSetGet(_CCliLoj),oDlgSep,044,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,,.F.,.F.,,.F.,.F.,'','',,)
	oGetNome	:= TGet():New( 30,92 ,bSetGet(_cNomeCli),oDlgSep,194,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,'',,,.F.,.F.,,.F.,.F.,'','',,)
	oSayOper	:= TSay():New( 50,10 ,{||"Operações Fiscais Disponiveis: 09 - TRANSFERENCIA / 11 - INDUSTRIALIZAÇÃO "} ,oDlgSep,,oFont16N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,294,015)
	nBrwLarg	:= (oDlgSep:nClientWidth / 2) - 10
	nBrwAlt		:= (oDlgSep:nClientHeight / 2) -52 //* .20     
	oBrw1		:= MsNewGetDados():New( 72 , 10, nBrwAlt, nBrwLarg,nOpc,'Eval(bLinOk)','AllwaysTrue()','',{"PRODUTO","QUANT","ALMOX","ENDEREC","OPER"},0,99,'AllwaysTrue()',,'Eval(bfDeleta)',oDlgSep,aHead1,aCols1)
	oBtConf		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 075,"Confirmar",oDlgSep,{|| If(fValid("TODOS"),fGrava(),)},037,012,,,,.T.,,'',,,,.F. )
	oBtCanc		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 035,"Cancelar" ,oDlgSep,{|| RollBackSX8(),oDlgSep:End()} ,037,012,,,,.T.,,'',,,,.F. )	
	oGetEmiss:Disable()
	oGetCli:Disable()
	oGetNome:Disable()
	oDlgSep:Activate(,,,.T.)	
Return

Static Function fDeleta()
	oBrw1:aCols[oBrw1:nAt, nColDel] := !oBrw1:aCols[oBrw1:nAt, nColDel]
	oBrw1:Refresh()
Return()

Static Function fHeader()
	Local aAux := {}
	aAdd(aAux,{"Produto"	,"PRODUTO"	,"@!"		,TamSX3("C6_PRODUTO")[1],0						,'Eval(bValProduto)',''	,"C"	,"SB1"	,'' }) //
	aAdd(aAux,{"Descrição"	,"DESC"		,"@!"		,TamSX3("B1_DESC")[1]	,0						,'' 				,'' ,"C" 	,'' 	,'' })
	aAdd(aAux,{"UM"			,"UNIDADE"	,"@!"		,TamSX3("B1_UM")[1]		,0						,'' 				,''	,"C"	,'' 	,'' })
	aAdd(aAux,{"Quant"		,"QUANT"	,cPicture	,TamSX3("C6_QTDVEN")[1]	,TamSX3("C6_QTDVEN")[2] ,'Eval(bValQuant)'	,''	,"N"	,'' 	,'' })
	aAdd(aAux,{"Local"		,"ALMOX"	,"@!"		,TamSX3("C6_LOCAL")[1]	,0 						,'Eval(bValAlmox)'	,''	,"C"	,'' 	,'' })
	aAdd(aAux,{"Endereço"	,"ENDEREC"	,"@!"		,TamSX3("C6_LOCALIZ")[1],0 						,'Eval(bValEnderec)',''	,"C"	,"SBE"	,'' })//
	aAdd(aAux,{"Operacao"	,"OPER"		,"@!"		,TamSX3("C6_XOPER")[1]	,0 						,'Eval(bValOper)'	,''	,"C"	,'' 	,'' })
Return(aAux)
 

Static Function fCols()
	Local aAux := {}
	aAdd(aAux,{ Space(TamSX3("C6_PRODUTO")[1]),;
	Space(TamSX3("B1_DESC")[1]),;
	Space(TamSX3("B1_UM")[1]),;
	0,;
	Space(TamSX3("C6_LOCAL")[1]),;
	Space(TamSX3("C6_LOCALIZ")[1]),;
	Space(TamSX3("C6_XOPER")[1]),;
	.F.})
Return(aAux)

 
Static Function fValid(cCampo)
	Local lRet := .T.
	Local nY
	// Revalida todas as linhas
	If cCampo == "TODOS"
		For nY := 1 to Len(oBrw1:aCols)
			If !oBrw1:aCols[nY][nColDel]	
				If !fValCampo("PRODUTO",nY,.F.) .Or.;
					!fValCampo("QUANT",nY,.F.) .Or.;
					!fValCampo("ALMOX",nY,.F.) .Or.;
					!fValCampo("ENDEREC",nY,.F.) .Or.;
					!fValCampo("OPER",nY,.F.)
					Aviso("Atenção!","Problema encontrado na linha "+AllTrim(Str(nY))+".",{"OK"})
					Return .F.
				EndIf	
			EndIf
		Next nY
		// Valida a linha
	ElseIf cCampo == "LINHA"
		nY := oBrw1:nAt
		If !oBrw1:aCols[nY][nColDel]
			If !fValCampo("PRODUTO",nY,.F.) .Or.;
				!fValCampo("QUANT",nY,.F.) .Or.;
				!fValCampo("ALMOX",nY,.F.) .Or.;
				!fValCampo("ENDEREC",nY,.F.) .Or.;
				!fValCampo("OPER",nY,.F.)
				Return .F.
			EndIf
		EndIf
	Else
		lRet := fValCampo(cCampo,oBrw1:nAt,.T.)
	EndIf	
Return (lRet)

Static Function fValCampo(cCampo,nY,lDigitado)
	local cAlias
	local cLocal := ""
	
	If cCampo == "PRODUTO"	
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(xFilial("SB1")+If(lDigitado,M->PRODUTO,oBrw1:aCols[nY][nPosProduto]))) .Or. SB1->B1_MSBLQL == "1"
			Aviso("Atenção!","Produto inválido ou bloqueado!",{"OK"})
			Return(.F.)
		EndIf
		If Empty(If(lDigitado,M->PRODUTO,oBrw1:aCols[nY][nPosProduto]))
			Aviso("Atenção!","Preencha o código do produto.",{"OK"})
			Return(.F.)
		EndIf	
		If lDigitado
			If M->PRODUTO != oBrw1:aCols[nY][nPosProduto]
				oBrw1:aCols[nY][nPosDesc] 	:= SB1->B1_DESC
				oBrw1:aCols[nY][nPosUnidade]:= SB1->B1_UM
				oBrw1:aCols[nY][nPosQuant] 	:= 1
				oBrw1:aCols[nY][nPosAlmox] 	:= SB1->B1_LOCPAD
				oBrw1:aCols[nY][nPosEnderec]:= Space(TamSX3("C6_LOCALIZ")[1])
				oBrw1:aCols[nY][nPosOper]	:= Space(TamSX3("C6_XOPER")[1])
			EndIf
		EndIf
	Else
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+oBrw1:aCols[nY][nPosProduto]))
	EndIf	
	If cCampo == "QUANT"
		If If(lDigitado,M->QUANT,oBrw1:aCols[nY][nPosQuant]) <= 0
			Aviso("Atenção!","Preencha a quantidade a ser ajustada.",{"OK"})
			Return(.F.)
		EndIf
	EndIf	
	If cCampo == "ALMOX"
		If Empty(If(lDigitado,M->ALMOX,oBrw1:aCols[nY][nPosAlmox]))
			Aviso("Atenção!","Digite um local para a entrada.",{"OK"})
			Return(.F.)
		EndIf	
		cLocal := if(lDigitado,M->ALMOX,oBrw1:aCols[nY][nPosAlmox])	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+oBrw1:aCols[nY][nPosProduto]))		
		if !((cLocal == "99" .and. SB1->B1_TIPO # "PA") .Or. (cLocal == "01" .and. SB1->B1_TIPO == "PA"))
			Aviso("Atenção!","Digite um Armazém válido.",{"OK"})
			return(.F.)
		endif			
		SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL		
		If !SB2->(DbSeek(xFilial("SB2")+oBrw1:aCols[nY][nPosProduto]+If(lDigitado,M->ALMOX,oBrw1:aCols[nY][nPosAlmox])))
			Aviso("Atenção!","Este produto não possui controle de saldo cadastrado neste armazém. Corrija o armazém ou cadastre saldo inicial no estoque.",{"OK"})
			Return(.F.)
		EndIf		
	EndIf
	
	If cCampo == "ENDEREC"
		SBE->(DbSetOrder(1)) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		If SB1->B1_LOCALIZ == "S" .And. Empty(If(lDigitado,M->ENDEREC,oBrw1:aCols[nY][nPosEnderec]))
			Aviso("Atenção!","É obrigatória a digitação do endereço pois o produto controla endereçamento.",{"OK"})
			Return(.F.)
		ElseIf SB1->B1_LOCALIZ != "S" .And. !Empty(If(lDigitado,M->ENDEREC,oBrw1:aCols[nY][nPosEnderec]))
			Aviso("Atenção!","Não é permitido a digitação do endereço pois o produto não controla endereçamento.",{"OK"})
			Return(.F.)
		ElseIf SB1->B1_LOCALIZ == "S" .And. !Empty(If(lDigitado,M->ENDEREC,oBrw1:aCols[nY][nPosEnderec])) .And. !SBE->(DbSeek(xFilial("SBE")+oBrw1:aCols[nY][nPosAlmox]+If(lDigitado,M->ENDEREC,oBrw1:aCols[nY][nPosEnderec])))
			Aviso("Atenção!","O endereço digitado não existe. Verifique a digitação e o armazém.",{"OK"})
			Return(.F.)
		ElseIf SB1->B1_LOCALIZ == "S" 
			_nMetr := Val(RIGHT(Alltrim(If(lDigitado,M->ENDEREC,oBrw1:aCols[nY][nPosEnderec])),5))
			_nLanc := oBrw1:aCols[nY][nPosQuant]
			_nLanc := _nLanc /_nMetr
			If !(_nLanc - int(_nLanc) == 0)
				Aviso("Atenção!","Lance não compativel com a quantidade e acondicionamento.",{"OK"})
				Return(.F.)
			EndIf
		EndIf
	EndIf
	If cCampo == "OPER"
		If Empty(IIf(lDigitado,M->OPER,oBrw1:aCols[nY][nPosOper]))
			Aviso("Atenção!","Preencha a Operacao Fiscal(09-Transferencia/11-Industrializ)",{"OK"})
			Return(.F.)
		ElseIf ! (IIf(lDigitado,M->OPER,oBrw1:aCols[nY][nPosOper])) $ "09//11"
			Aviso("Atenção!","Preencha a Corretamente a Operacao Fiscal(09-Transferencia/11-Industrializ)",{"OK"})
			Return(.F.)		
		EndIf
	EndIf	
Return(.T.)

 
Static Function fGrava()
	Local _aParams := {}
	Processa({|| _aParams := U_fCbTrFil(oBrw1:aCols)}, "")
	If _aParams[1]
		MsgBox("Pedido Criado com Sucesso. Pedido Numero : "+_aParams[2],"Realizado", "INFO")	
	Else
		MsgBox("Pedido NÃO concluido, favor verificar!", "Atenção !!!", "INFO")
	EndIf
	oDlgSep:End()
Return
 

/*/{Protheus.doc} fCbTrFil
//TODO Cria PV de Transferencia conforme array
			1 - Produto, 2 - Descricao, 3 - UM. 4 - Quantidade
			5 - Local, 6 - Localiz, 7 - Operacao
@author juliana.leme
@since 02/08/2018
@version 1.0
@param aItens, array, descricao
@type function
/*/
User Function fCbTrFil(aItens)
	Local nX, nY
	Local cC5Num		:= ""
	Local aUsuarios 	:= ALLUSERS()
	Local aRet			:= {.T.,""}
	Local bErro
	Local aItensPv		:= {}
	Local aCabPv		:= {}
	Local _nCusto		:= 0
	Local _cItem 		:= StrZero(0,TamSX3("C6_ITEM")[1])
	Local lRet 			:= .T.
	Local _cCli			:= ""
	Local _cLoj			:= ""
	Local _cNomeCli		:= ""
	Local _CCliLoj		:= ""
	Local _cTabPrc		:= ""
	Local _cTpOper		:= ""
	Local _cTes			:= ""
	Local _Localiz		:= ""
	Local _nMetr		:= 0
	Local _nLanc		:= 0
	Local cUsuario	
	Private	lMsErroAuto	:= .F.
	Private nOper 		:= 3

	nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})	
	If nX > 0
		cUsuario := aUsuarios[nX][1][2]
	EndIf	
	If cFilAnt == "02" // cNumEmp == "0101"   // estou na matriz // By Roberto Oliveira 23/03/17 - Usar xFilial("SC6") - Se o Usuário tiver acesso a todas as filiais, vem errado
		_cCli := "002560"  // seleciono o cliente matriz
		_cLoj := "01"
	Else                   // estou na filial
		_cCli := "008918"  // seleciono o cliente filial
		_cLoj := "01"
	EndIf	
	_cNomeCli	:=	Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_NOME")
	_CCliLoj := _cCli + "/" + _cLoj
	BEGIN TRANSACTION			
		_cTabPrc	:=	Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_TABELA")
		cC5Num		:= GetSX8Num("SC5", "C5_NUM")			
		aCabPv := {{"C5_NUM"		,cC5Num		,nil},;
					{"C5_TIPO"		,"N"		,nil},;
					{"C5_CLIENTE"	,_cCli		,nil},;
					{"C5_LOJACLI"	,_cLoj		,nil},;
					{"C5_CLIENT"	,_cCli		,nil},;
					{"C5_LOJAENT"	,_cLoj		,nil},;
					{"C5_ENTREG"	,dDataBase+10,nil},;
					{"C5_TRANSP"	,""			,nil},;
					{"C5_TABELA"	,_cTabPrc	,nil},;
					{"C5_TIPOCLI"	,"R"		,nil},;
					{"C5_CONDPAG"	,"263"		,nil},;
					{"C5_PEDCLI"	,""			,nil},;
					{"C5_OBS"		,"TRANSFERENCIA DE MATERIAIS NAO COBRAR",nil},;
					{"C5_DESCESP"	,0			,nil},;
					{"C5_DESCEQT"	,0			,nil},;
					{"C5_VEND1"		,"010"		,nil},;
					{"C5_EMISSAO"	,dDatabase	,nil},;
					{"C5_COTACAO"	,""			,nil},;
					{"C5_PARC1"		,0			,nil},;
					{"C5_MOEDA"		,1			,nil},;
					{"C5_TPFRETE"	,"C"		,nil},;
					{"C5_LIBEROK"	,"S"		,nil},;
					{"C5_TXMOEDA"	,1			,nil},;
					{"C5_TIPLIB"	,"2"		,nil},;
					{"C5_TPCARGA"	,"2"		,nil},;
					{"C5_USERINC"	,Left(cUserName,Len(SC5->C5_USERINC)),nil},;
					{"C5_DTINC"		,dDatabase	,nil},;
					{"C5_DTFAT"		,dDatabase	,nil},;
					{"C5_CLIOK"		,"S"		,nil},;
					{"C5_XOPER"		,_cTpOper	,nil},;
					{"C5_GERAWMS"	,"1"		,nil}}
		For nY := 1 to Len(aItens)		
			_cItem 		:= Soma1(_cItem)
			_nCusto 	:= Posicione("SB1",1,xFilial("SB1")+aItens[nY][1],"B1_CUSTD")
			_Localiz	:= Posicione("SB1",1,xFilial("SB1")+aItens[nY][1],"B1_LOCALIZ")
			_nCusto 	:= Max(0.01,_nCusto)
			_cTpOper 	:= aItens[nY][7]
			_cTes 		:= U_CDTesInt(_cTpOper)						
			If _Localiz == "S"
				_nMetr := Val(RIGHT(Alltrim(aItens[nY][6]),5))
				_nLanc := aItens[nY][4]/_nMetr
			Else
				_nMetr := 0
				_nLanc := 0
			EndIf 					
			aAdd(aItensPv,{{"C6_NUM"		,"      "		,Nil},;
							{"C6_ITEM"		,_cItem			,Nil},;
							{"C6_PRODUTO"	,aItens[nY][1]	,Nil},;
							{"C6_QTDVEN"	,aItens[nY][4]	,Nil},;
							{"C6_PRCVEN"	,_nCusto		,Nil},;
							{"C6_ACONDIC"	,aItens[nY][6]	,Nil},;
							{"C6_QTDLIB"	,aItens[nY][4]	,Nil},;
							{"C6_LOCAL"		,aItens[nY][5]	,Nil},;
							{"C6_ENTREG"	,dDataBase + 10 ,Nil},;
							{"C6_TES"		,_cTes			,Nil},; 
							{"C6_LANCES"	,_nLanc			,Nil},;
							{"C6_METRAGE"	,_nMetr			,Nil},;
							{"C6_XOPER"		,_cTpOper		,Nil}})
		Next					
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItensPv,nOper)			
		If lMsErroAuto
			MostraErro()
			lRet := .F.
			cC5Num := ""
			RollBackSX8()
			DisarmTransaction()
		Else
			ConfirmSX8()
			lRet := .T.
		EndIf
		aRet := {lRet,cC5Num}
	END TRANSACTION	
Return (aRet)

/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 26/04/2018
@description Realiza os tratamentos de erros da classe
/*/
static function HandleEr(oErr, oSelf)
	local cMsg	:= "[CbcTransFil - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	// oSelf:libLock()
	ConOut(cMsg)
	oSelf:setProgMsg(cMsg)
	oSelf:cRunMsg := cMsg
	BREAK
return(nil)