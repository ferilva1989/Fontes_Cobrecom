#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)

static newManut := GetNewPar('ZZ_TITMANT', .T.)

/*/{Protheus.doc} fIniManut
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description                                                                                                         

TABELA ZBA
INDICE 01 :NICKNAME(CH_UNICO)	- ZBA_FILIAL+ZBA_PREFIX+ZBA_NUM+ZBA_PARC+ZBA_TIPO+ZBA_CLI+ZBA_LOJA+ZBA_NROREL+ZBA_OPER
INDICE 02 :NICKNAME(OPER_REL) 	- ZBA_OPER+ZBA_NROREL
INDICE 03 :NICKNAME(RELAT )		- ZBA_NROREL 

/*/
user function fIniManut()
	local cFiltro		:= ""
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZBA')
	oBrw:SetDescription('Descontinuada!!!')
	
	cFiltro +=	"!Empty(ZBA_DTREL)"
	oBrw:SetFilterDefault( cFiltro )

	oBrw:SetMenuDef("MANUTENCAOTITULOS")
	oBrw:Activate()

return(nil)


static function MenuDef()
	Local aRotina := {}	
	ADD OPTION aRotina TITLE 'EXCLUIR' 		ACTION 'U_fDelRel()' 	OPERATION 5 	ACCESS 2
	if !newManut
		ADD OPTION aRotina TITLE 'INCLUIR' 		ACTION 'U_fManTit()' 	OPERATION 3 	ACCESS 0
		ADD OPTION aRotina TITLE 'IMPRIMIR' 	ACTION 'U_manutRel()' 	OPERATION 3 	ACCESS 0
		ADD OPTION aRotina TITLE 'SYNC'			ACTION 'u_cargaZBA()'	OPERATION 3	ACCESS 0
	endif
return(aRotina)


static function ModelDef()
	local oStruZBA := FWFormStruct( 1, 'ZBA' )
	local oModel
	oModel := MPFormModel():New('COMPZBA' )
	oModel:AddFields( 'ZBAMASTER', /*cOwner*/, oStruZBA)
	oModel:SetDescription( 'Manutenção de Titulos a Receber' )
	oModel:GetModel( 'ZBAMASTER' ):SetDescription( 'Manutenção de Titulos a Receber' )
return (oModel)


static function ViewDef()
	local oModel 		:= FWLoadModel( 'MANUTENCAOTITULOS' )
	local oStruZBA 	:= FWFormStruct( 2, 'ZBA' )
	local oView		:= nil
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZBA', oStruZBA, 'ZBAMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZBA', 'TELA' )
return (oView)


/*/{Protheus.doc} fManTit
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@description
Tela para seleção das operações
Operações definidas ( BAIXA E DEBITAR, DESCONTO, PROROGAÇÂO )
Dentro de baixar e debitar tem opção Baixar Debitar/Deposito
neste caso somente juros deve ser lançado no conta corrente 
/*/
user function fManTit()
	local aPergs 	:= {}
	local aRet 		:= {}

	if dDatabase != Date()
		MsgAlert("Data base alterada, somente permitidos lançamentos data atual", "[MANUT.TITULO]" )
		return(nil)
	endif
	aAdd(aPergs,{2,"Informe operação desejada",1,{"BAIXAR E DEBITAR","DESCONTO","PRORROGACAO"},120,"",.T.})

	if ParamBox(aPergs,"Manutenção de Borderos - Contas Receber",@aRet)
		if valType(aRet[1]) == "N"
			U_TelaManTit("BX")
		elseIf aRet[1] == "DESCONTO"
			U_TelaManTit("DESC")
		elseIf aRet[1] == "PRORROGACAO"
			U_TelaManTit("PRO")
		endIf
	endif

return(nil)


/*/{Protheus.doc} TelaManTit
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description 
PARAMTEROS PARA MONTAR TELAS DIFERENTES ( BX, DESC, PRO)
/*/
user Function TelaManTit(cTipo)
	local aSize 		:={}
	local aObjects 	:={}
	local aInfo		:={}
	local aPosObj		:={}
	local cPerg		:= "RELINI"
	static oDlg		:= nil

	aSize := MsAdvSize(.T.)
	
	CriaSX1(cPerg, "INI")
	Pergunte(cPerg, .T.)

	AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
	AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5 , 5 , 5 , 5 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. , .F. )

	oDlg := MSDialog():New(aSize[7],aSize[1],aSize[6],aSize[5],"Manutencao Titulos Financeiro Receber",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	if cTipo == "BX"
		fNewGet()
		oDlg:bInit := {||  EnchoiceBar(oDlg,{|| fProcessa() },{|| oDlg:End() },,)}
	elseIf cTipo == "DESC"
		fNewGetDes()
		oDlg:bInit := {||  EnchoiceBar(oDlg,{|| fProcDes() },{|| oDlg:End() },,)}
	elseIf cTipo == "PRO"
		fNewGetPro()
		oDlg:bInit := {||  EnchoiceBar(oDlg,{|| fProcPro() },{|| oDlg:End() },,)}
	endIf

	oDlg:Activate()

return(nil)

	
/*/{Protheus.doc} fNewGet
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@description 
/*/
static Function fNewGet()
	local nX				:= 0
	local aHeaderEx 		:= {}
	local aColsEx			:= {}
	local aFieldFill 		:= {}
	local aAlterFields 	:= {"OPERACAO","DTBX","VALOR","MOTBAIXA","BANCO","HISTBX"}
	local aSize 			:= {}
	local aPosObj 		:= {}
	local aObjects 		:= {}
	local aInfo 			:= {}
	local aBuscaX3		:= {}
	local nUsado			:= 0
	local aMotBx			:= {}
	static oMSNewGe1		:= nil
	static aColsAux 		:= {}

	aHeaderMs 	:= {}
	nUsado		:= 0

	aSize := MsAdvSize(.T.)
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aPosObj := MsObjSize( aInfo, aObjects )

	criaTrbSe1()

	DbSelectArea("TRBSE1")
	TRBSE1->(DbGoTop())

	if TRBSE1->(EOF())
		MsgAlert("Nenhum titulo encontrado para os filtros selecionados", '[MANUT.TITULO]')
		TRBSE1->(dbCloseArea())
		FErase( "TRBSE1" + GetDbExtension())
		oDlg:End()
		return(nil)
	endif
	
	// TODO INIdoFunction função ajusta SX5 TABELA ZY
	DbSelectArea("SX5")
	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
	SX5->(DbSetOrder(1))
	if Len((aMotBx := lerMotBx())) < 1
		MsgAlert("Arquivo SYSTEM\SIGAADV.MOT, não encontrado ou TOTVS mudou, verifique!", '[MANUT.TITULO]')
		oDlg:End()
		return (nil)
	endIf
	if SX5->(DbSeek(xFilial("SX5") + "ZY" ,.F.))
		while Alltrim(SX5->X5_TABELA) == "ZY" .AND. SX5->(!EOF())
			SX5->(RecLock("SX5",.F.))
			SX5->(DbDelete())
			SX5->(MsUnLock())
			SX5->(dbskip())
		enddo
	endif
	for _nX := 1 To Len(aMotBx)
		SX5->(RecLock("SX5",.T.))
		SX5->(X5_FILIAL)	:= xFilial("SX5")
		SX5->(X5_TABELA)	:= "ZY"
		SX5->(X5_CHAVE)   := aMotBx[_nX][1]
		SX5->(X5_DESCRI)	:= aMotBx[_nX][2]
		SX5->(X5_DESCSPA)	:= aMotBx[_nX][2]
		SX5->(X5_DESCENG)	:= aMotBx[_nX][2]
		SX5->(MsUnLock())
	next
	// TODO ENDdoFunction

	
	// TODO INIdoFunction Função obtem aHeaderMS
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	// Cliente
	if SX3->(DbSeek("E1_CLIENTE"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	// Nome do cliente
	if SX3->(DbSeek("E1_NOMCLI"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Emissão do titutlo
	if SX3->(DbSeek("E1_EMISSAO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	Aadd(aHeaderMs,{"Duplicata","DUPLICATA","@!" ,(TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]),0,".F.","","C","","R",} )

	// Saldo do titulo
	if SX3->(DbSeek("E1_SALDO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Vencimento real
	if SX3->(DbSeek("E1_VENCTO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Operação edit F3 tabela SX5-ZZ
	aadd(aHeaderMs,{"Operacao"	, "OPERACAO"	,"@!",03,0, .F. ,"","C","ZZ","R",} )

	// Data da baixa
	aadd(aHeaderMs,{"Dia Rec."	, "DTBX"	, "@!",8,0, .F. ,"","D","","R", } )

	// Valor da baixa
	if SX3->(DbSeek("E1_VALOR"))
		Aadd(aHeaderMs, {"Valor Pago","VALOR",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	// Motivo baixa tabela SZ5-ZY
	aadd(aHeaderMs,{"Mot. Baixa", "MOTBAIXA"	,"@!",10, 0, .F. ,"","C","ZY","R",} )

	// Banco recebimento
	aadd(aHeaderMs,{"Banco", "BANCO" ,"@!" ,TamSX3("A6_COD")[1] ,0, .F. ,"","C","A64","R",} )

	// Agencia recebimento
	aadd(aHeaderMs,{"Agencia", "AGENCIA","@!",TamSX3("A6_AGENCIA")[1]	,0, .F. ,"","C","","R",} )

	// Conta recebimento
	aadd(aHeaderMs,{"Conta", "CONTA" ,"@!"	,TamSX3("A6_NUMCON")[1] ,0, .F. ,"","C","","R",} )

	// Historico
	aadd(aHeaderMs,{"Hist. Observacoes"	, "HISTBX"	, "@!"	,TamSX3("E1_ZZHISBX")[1]	,0, .F. ,"","C","","R", } )
	
	// TODO ENDdoFunction

	nUsado := Len(aHeaderMs)

	
	while !TRBSE1->(Eof())
		// Mais um pelo deletado
		AADD(aColsEx,Array(nUsado+1))
		// Array auxiliar
		AADD(aColsAux,Array(6))
		_nPsCols := Len(aColsEx)

		// Conteudo
		aColsEx[_nPsCols,01]	:=	Alltrim(TRBSE1->CLIENTE)
		aColsEx[_nPsCols,02]	:=	Alltrim(TRBSE1->NOMCLI)
		aColsEx[_nPsCols,03]	:=	TRBSE1->EMISSAO
		aColsEx[_nPsCols,04]	:= 	Alltrim(TRBSE1->DUPLICATA)
		aColsEx[_nPsCols,05]	:=	TRBSE1->SALDO
		aColsEx[_nPsCols,06]	:=	TRBSE1->VENCTO
		aColsEx[_nPsCols,07] 	:=  Space(3) // Operação edit F3
		aColsEx[_nPsCols,08] 	:=  DDATABASE
		aColsEx[_nPsCols,09] 	:=	TRBSE1->VLRBX
		aColsEx[_nPsCols,10]	:=	Space(10) // Motivo baixa F3
		aColsEx[_nPsCols,11]	:=	IIF(!Empty(TRBSE1->BANCO)	,TRBSE1->BANCO	,Space(TamSX3("A6_COD")[1]))
		aColsEx[_nPsCols,12]	:=	IIF(!Empty(TRBSE1->AGENCIA),TRBSE1->AGENCIA	,Space(TamSX3("A6_AGENCIA")[1]))
		aColsEx[_nPsCols,13]	:=	IIF(!Empty(TRBSE1->CONTA)	,TRBSE1->CONTA	,Space(TamSX3("A6_NUMCON")[1]))
		aColsEx[_nPsCols,14]	:=  Space(TamSX3("E1_HIST")[1])
		aColsEx[_nPsCols,15]	:= .F. // deletado
		// Auxiliar
		aColsAux[_nPsCols,01]	:= TRBSE1->CHAVE
		aColsAux[_nPsCols,02]	:= TRBSE1->PREFIXO
		aColsAux[_nPsCols,03]	:= TRBSE1->NUMERO
		aColsAux[_nPsCols,04]	:= TRBSE1->PARCELA
		aColsAux[_nPsCols,05]	:= TRBSE1->TIPO
		aColsAux[_nPsCols,06]	:= TRBSE1->RCNO
		TRBSE1->(DbSkip())
	enddo

	TRBSE1->(dbCloseArea())
	FErase( "TRBSE1" + GetDbExtension())

	oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 		;
		GD_INSERT+GD_DELETE+GD_UPDATE, "U_LinBxDbOk()", "AllwaysTrue", "+Field1+Field2", 	;
		aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, @aHeaderMs, @aColsEx)

return(nil)

	
/*/{Protheus.doc} LinBxDbOk
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@description Validação linhaOk para Baixa e debita
/*/
user function LinBxDbOk()
	local nLinha 		:= oMSNewGe1:nAt
	local lProt 		:= .F.
	local dDataFin	:= GetNewPar('MV_DATAFIN', date() )

	// Linha vazia
	if !Empty(oMSNewGe1:aCols[nLinha][07])
		// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
		SX5->(DbSetOrder(1))
		SX5->(DbSeek(xFilial("SX5")+"ZZ",.F.))

		while SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "ZZ" .And. SX5->(!EOF())

			if	AllTrim(SX5->(X5_CHAVE)) == AllTrim(oMSNewGe1:aCols[nLinha][07])

				lProt := Alltrim(SX5->X5_DESCRI) == "BAIXAR E DEBITAR PROTESTO"

				// Historico
				if Empty(AllTrim(oMSNewGe1:aCols[nLinha][14]))
					MessageBox("Por Favor, informe um Historico!", "Aviso", 48)
					return(.F.)
				// Valor baixa
				elseIf Empty(oMSNewGe1:aCols[nLinha][09])
					MessageBox("Por Favor, informe o valor do pagamento!", "Aviso", 48)
					return(.F.)
				// Pagou mais que saldo
				elseIf oMSNewGe1:aCols[nLinha][09] > oMSNewGe1:aCols[nLinha][05] .AND. !lProt
					
					if !ApMsgNoYes("O valor de baixa é maior que o valor do titulo,   "	+	CRLF +;
							"deseja baixar mesmo assim?                       " + 	CRLF +;
							"Lembrando que a diferenca a maior sera lançado no" +	CRLF +;
							"Conta-Corrente", "Confirmacao")
						return(.F.)
					endif

				// Data da baixa 
				elseIf Empty(oMSNewGe1:aCols[nLinha][08]) .AND. !lProt
					MessageBox("Por Favor, informe a data do pagamento!", "Aviso", 48)
					return(.F.)
				
				// Motivo baixa
				elseIf Empty(oMSNewGe1:aCols[nLinha][10]) .AND. !lProt
					MessageBox("Por Favor, informe o motivo para Baixa", "Aviso", 48)
					return(.F.)
				
				// Parametro ddatafin
				elseIf  oMSNewGe1:aCols[nLinha][08] < dDataFin .AND. !lProt
					MessageBox("Data baixa não pode ser menor que MV_DATAFIN " + cValToChar(dDataFin), "Aviso", 48)
					return(.F.)
				endIf

				return (.T.)

			endIf
			SX5->(DbSkip())
		enddo

		MessageBox("Operacao " + AllTrim(oMSNewGe1:aCols[nLinha][07]) + " nao cadastrada, verifique a linha " + cValToChar(nLinha),;
			"AVISO", 48 )

		oMSNewGe1:GoTo(nLinha)
		Return .F.
	endif
return (.T.)


/*/{Protheus.doc} fProcessa
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description
INICIA-SE O PROCESSAMENTO DOS TITULOS SELECIONADOS
DEVE-SE REALIZAR LANÇAMENTO NO CT2(CONTA-CORRENTE)
DEVE-SE REALIZAR A BAIXA DOS TITULOS QUANDO INFORMADO BANCO
DEVE-SE GERAR O RELATORIO DE BIAXA E DEBITA
aCampos[nX,01]	:=	CLIENTE
aCampos[nX,02]	:=	NOME CLIENTE
aCampos[nX,03]	:=	EMISSÃO TITULO
aCampos[nX,04]	:=	NRO. DUPLICATA
aCampos[nX,05]	:=	SALDO TITULO
aCampos[nX,06]	:=	VENC. REAL
aCampos[nX,07]	:= 	OPERAÇÂO (EDIT)
aCampos[nX,08]	:=	DATA DA BAIXA (EDIT)
aCampos[nX,09]	:=  VALOR DA BAIXA (EDIT)
aCampos[nX,10]	:=	MOTIVO BAIXA (EDIT F3)
aCampos[nX,11]	:=	BANCO BAIXA (EDIT F3)
aCampos[nX,12]	:=	AGENCIA BAIXA (EDIT F3)
aCampos[nX,13]	:=	CONTA BAIXA (EDIT F3)
aCampos[nX,14]	:=	HISTORICO (EDIT)
aCampos[nX,15]	:=	DELETADO
aColsAux[nX,01]	:= CHAVE
aColsAux[nX,02]	:= PREFIXO
aColsAux[nX,03]	:= NUMERO
aColsAux[nX,04]	:= PARCELA
aColsAux[nX,05]	:= TIPO
aColsAux[nX,06]	:= RECNO
/*/
static function fProcessa()
	local cRetorno 		:= ""
	local nLinha			:= 1
	local nBordero 		:= ""
	local nTotalDB 		:= 0
	local nTotalCR		:= 0
	local lGeraCt2		:= .F.
	local aItens			:={}
	local nAcresc			:= 0
	local nVlBaixa		:= 0
	local cOpera			:= ''
	local cEmail			:= 'ctasreceber@cobrecom.com.br'
	local lTemUm			:= .F.
	local lProtesto		:= .F.
	local nProt 			:= 0
	local nOutro			:= 0
	local aAreaE1			:= {}
	local aAreaX5			:= {}
	local lCLVLDB			:= .F.
	local lCLVLCR			:= .F.
	local dDataFin		:= GetNewPar('MV_DATAFIN', date() )

	//Variaveis necessarias para FA060Trans, que realiza as transferencias
	Private E1_SALDO
	Private nPrazoMed		:= 0
	Private nTaxaDesc		:= 0
	Private dDataMov		:= dDataBase
	Private nValdesc 		:= 0
	Private nMoedaBco		:= 1
	
	DbSelectArea("ZBA")
	//ZBA_NROREL
	DBOrderNickName("RELAT")
	
	// Numero sequencial para relatorio
	RollBackSx8()
	nBordero	:= GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	Do While ZBA->(DbSeek(xFilial("ZBA")+nBordero,.F.))
		nBordero := GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	EndDo

	aCampos := aClone(oMSNewGe1:ACOLS)

	DbSelectArea("SE1")
	// E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSetOrder(1))
	DbSelectArea("SX5")
	// X5_FILIAL+X5_TABELA+X5_CHAVE_
	SX5->(DbSetOrder(1))

	// Verificar protesto, quando protesto não pode nenhuma outra
	for nY := 1 to Len(aCampos)
		if !Empty(aCampos[nY][07])
			if SX5->( DbSeek(xFilial("SX5")+"ZZ"+AllTrim(aCampos[nY,07]),.F.)  )
				if Alltrim(SX5->X5_DESCRI) == "BAIXAR E DEBITAR PROTESTO"
					nProt  += 1
					lProtesto := .T.
				else
					nOutro += 1
				endif
			endIf
		endif
	next nY

	// Não pode ter duas operações
	if nProt > 0 .AND. nOutro > 0
		MessageBox("Relatorios Baixa e Debita com Protesto não pode ter outras operações, somente protesto!", "Aviso", 48)
		return(nil)
	endif

	//TODO -  Validações RY mudar DRY - Utilizando função linBxDbOk() 
	for nY := 1 to Len(aCampos)
		// somente campos com operação
		if !Empty(aCampos[nY][07])
			if SX5->( DbSeek(xFilial("SX5")+"ZZ"+AllTrim(aCampos[nY,07]),.F.)  )
				// Historico
				if Empty(AllTrim(aCampos[nY,14]))
					MessageBox("Por Favor, informe um Historico!", "Aviso", 48)
					return nil
				// Valor pago
				elseIf Empty(aCampos[nY,09])
					MessageBox("Por Favor, informe o valor do pagamento!", "Aviso", 48)
					return(nil)
				// Pago maior que o saldo
				elseIf aCampos[nY,09] > aCampos[nY,05]
					if !ApMsgNoYes("O valor de baixa é maior que o valor do titulo,   "	+	CRLF +;
							"deseja baixar mesmo assim?                       " + 	CRLF +;
							"Lembrando que a diferenca a maior sera lançado no" +	CRLF +;
							"Conta-Corrente", "Confirmacao")
						return(nil)
					endIf
				// Data da baixa vazia
				elseIf Empty(aCampos[nY,08])
					MessageBox("Por Favor, informe o data do pagamento!", "Aviso", 48)
					return (nil)
				// Parametro DDATAFIN
				elseIf  aCampos[nY,08] < dDataFin .AND.  !lProtesto
					MessageBox("Data baixa não pode ser menor que MV_DATAFIN " + cValToChar(dDataFin), "Aviso", 48)
					return (nil)
				elseIf Empty(aCampos[nY,10]) .AND.  !lProtesto
					MessageBox("Por Favor, informe o motivo para Baixa", "Aviso", 48)
					return nil
				elseIf !Empty(aCampos[nY,11]) .AND. lProtesto
					MessageBox("Por Favor,para protesto não informar o banco", "Aviso", 48)
					return nil
				endIf
			else
				MessageBox("Operacao nao cadastrada", "Aviso", 48)
				return (nil)
			endIf
		endIf
	next nY
	//TODO - FIM Validações RY mudar DRY - Utilizando função linBxDbOk() 
	
	for nX := 1 to Len(aCampos)
		if !Empty(aCampos[nX][07])
			//Tem titulo para gerar relatorio?
			lTemUm 	:=.T.
			// Operação tem Debitar gera Conta Corrente
			cOpera := Posicione("SX5",1,xFilial("SX5")+"ZZ"+aCampos[nX,07],"X5_DESCRI" )

			if "DEBITAR" $ cOpera .OR. "SUBSTITUIR" $ cOpera
				SE1->( dbgoto( aColsAux[nX,06] ) )
				
				// Somente se tiver banco e não for protesto
				if !Empty(aCampos[nX,11]) .AND. !lProtesto
					if "DEBITAR" $ cOpera
						/*
							"00"=Nenhum Erro
							"01"=Erro Compensação
							"02"=Usuario não selecionou NCC
							"03"=Não tem titulos NCC para cliente
							"04"=NCC Operação invalida
						*/
						aRet := compNCC(aColsAux,aCampos[nX,05],'BX',nBordero)

						if aRet[1][1] == "02" .And. !MsgYesNo("[AVISO] - Nenhum titulo NCC foi selecionado para compensação - deseja continuar?","AVISO")
							aRet := compNCC(aColsAux,aCampos[nX,05],'BX',nBordero)
						endif

						if	aRet[1][1] == "01" .Or. aRet[1][1] == "04"
							if aRet[1][1] == "01"
								cErro :="Erro ao compensar o titulo Nro: " + cValtoChar(Alltrim(SE1->(E1_NUM+E1_PARCELA))) + " Cliente: " + cValToChar(Alltrim(E1_NOMCLI))
							elseif aRet[1][1] == "04"
								cErro :="Erro o valor do titulo NCC selecionado para compensação, é menor que o valor do titulo a ser compensado, neste caso utilizar relatorio Desconto"
							endif
							
							u_envmail({cEmail}, "[Erro] - Compensar titulo para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcessa()","MANUTENCAOTITULOS.PRW",cErro}} )
							MsgAlert(cErro, '[MANUT.TITULO]')
							return (nil)
						endif

						if	aRet[1][1] == '06'
							cErro :="[ERRO] - Query que atualiza o campo E5->HISTOR, executado logo depois da compensação automatica"
							u_envmail({cEmail}, "[Erro] - Atualizar campo E5->HISTOR para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcessa()","MANUTENCAOTITULOS.PRW",cErro}} )
							MsgAlert(cErro, '[MANUT.TITULO]')
							Return (nil)
						endif

						if aRet[1][1] = "00" .And. aRet[1][2] > 0
							//Valor da baixa sempre valor titulo
							aCampos[nX][09] :=	aCampos[nX][05]
						endif
					endIf

					Begin Transaction

						reclock("SE1", .F.)
						SE1->E1_ZZHISTF	:= SE1->(E1_PORTADO + E1_NUMBCO) //
						SE1->(msunlock())

						// O processo de compensar já realiza a baixa do titulo
						// Valor selecionado para baixa é maior que o titulo (Ocasiona Acrescimento Titulo)
						if aCampos[nX][09] > aCampos[nX][05]
						
							nAcresc 	:= ( aCampos[nX][09] - aCampos[nX][05] )
							nVlBaixa	:= aCampos[nX][09]
						
							//TODO CHANGE - Não pode gravar nada SE1
							reclock("SE1", .F.)
							SE1->E1_SDACRES := nAcresc
							SE1->( msunlock() )
						else
							nAcresc 	:= 0
							nVlBaixa	:= aCampos[nX][09]
						endIf

						// Somente se não realizou processo de compensar NCC
						if aRet[1][2] == 0
							
							// Motivo da baixa deve ser 'DEV' e antes de baixar tem que tranferir para carteira
							aAreaX5 := SX5->(GetArea())
							aAreaE1 := SE1->(GetArea())
							FA060Trans("SE1",aColsAux[nX,06],2)
							RestArea(aAreaE1)
							RestArea(aAreaX5)

							// Rotina Baixa
							if fBxTitulo(aColsAux[nX][02],aColsAux[nX][03],aColsAux[nX][04],aColsAux[nX][05],;
									aCampos[nX][11], aCampos[nX][12], aCampos[nX][13], aCampos[nX][08],nVlBaixa,aCampos[nX][10],nAcresc,nBordero )

								MsgAlert('[ERRO] - TITULO NÂO FOI BAIXADO CORRETAMENTE', '[MANUT.TITULO]')
								DisarmTransaction()
								return(nil)
							endif
						endif
						
					end Transaction

				// Protesto não baixa somente muda carteira
				else
					// Tela padrão para tranferencia
					aAreaX5 := SX5->(GetArea())
					aAreaE1 := SE1->(GetArea())
					FA060Trans("SE1",aColsAux[nX,06],2)
					RestArea(aAreaE1)
					RestArea(aAreaX5)

					// Validar se usuario realmente mudou para protesto SE1->E1_SITUACA := "F"   
					if Alltrim(SE1->(E1_SITUACA)) != "F"
						MessageBox("Titulo não tranferido para Situação de Protesto","Aviso",48)
						return (nil)
					endif
				
				endif

				lGeraCt2 	:= .T.
				lCLVLCR		:= .T.
				reclock("SE1", .F.)
				SE1->E1_ZZBC2 	:= "NNN"
				SE1->E1_ZZBXDB 	:= nBordero
				SE1->E1_ZZDTREL 	:= dDataBase
				SE1->E1_ZZHISBX	:= aCampos[nX,14]
				SE1->E1_ZZOPER	:= cOpera
				nTotalCR += aCampos[nX][09] // Incrementa valor do campo utilizado na baixa
				SE1->(msunlock())
				nLinha ++

			else
				/*
					OPERAÇÔES QUE SOMENTE GERAM A C/C (CASO SEJA MAIOR LANÇAR C/C SOMENTE A DIFERENÇA OU SEJA (DEBITO CC)
					BAIXAR COM CHEQUE
					BAIXAR E NAO DEBITAR
					BAIXAR DEP. NAO AUTORIZADO
					BAIXAR DEPOSITO
				*/
				SE1->( dbgoto( aColsAux[nX,06] ) )

				if !Empty(aCampos[nX,11])

					/*
						"00"=Nenhum Erro
						"01"=Erro Compensação
						"02"=Usuario não selecionou NCC
						"03"=Não tem titulos NCC para cliente
						"04"=NCC Operação invalida
					*/
					aRet := compNCC(aColsAux,aCampos[nX,05],'BX',nBordero)
					
					if aRet[1][1] == "02" .And. !MsgYesNo("[AVISO] - Nenhum titulo NCC foi selecionado para compensação - deseja continuar?","AVISO")
						aRet := compNCC(aColsAux,aCampos[nX,05],'BX',nBordero)
					endif

					if	aRet[1][1] == "01" .Or. aRet[1][1] == "04"
						if aRet[1][1] == "01"
							cErro :="Erro ao compensar o titulo Nro: " + cValtoChar(Alltrim(SE1->(E1_NUM+E1_PARCELA))) + " Cliente: " + cValToChar(Alltrim(E1_NOMCLI))
						elseif aRet[1][1] == "04"
							cErro :="Erro o valor do titulo NCC selecionado para compensação, é menor que o valor do titulo a ser compensado, neste caso utilizar relatorio Desconto"
						endif
						u_envmail({cEmail}, "[Erro] - Compensar titulo para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcDes()","MANUTENCAOTITULOS.PRW",cErro}} )
						MsgAlert(cErro, '[MANUT.TITULO]')
						return (nil)
					endif

					if	aRet[1][1] == '06'
						cErro :="[ERRO] - Query que atualiza o campo E5->HISTOR, executado logo depois da compensação automatica"
						u_envmail({cEmail}, "[Erro] - Atualizar campo E5->HISTOR para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcessa()","MANUTENCAOTITULOS.PRW",cErro}} )
						MsgAlert(cErro, '[MANUT.TITULO]')
						return (nil)
					endif

					if aRet[1][1] = "00" .And. aRet[1][2] > 0
						// Valor da baixa passa a ser o valor do titulo
						aCampos[nX][09] :=	aCampos[nX][05]
					endif
					reclock("SE1", .F.)
					SE1->E1_ZZHISTF	:= SE1->(E1_PORTADO + E1_NUMBCO)
					SE1->(msunlock())

					// Selecionado para baixa maior que titulo ocasiona acrescimo
					if aCampos[nX][09] > aCampos[nX][05]
						nAcresc 	:= ( aCampos[nX][09] - aCampos[nX][05] )
						nVlBaixa	:= aCampos[nX][09]
						reclock("SE1", .F.)
						SE1->E1_SDACRES := nAcresc
						SE1->(msunlock())
					else
						nAcresc 	:= 0
						nVlBaixa	:= aCampos[nX][09]
					endif
					
					if (aRet[1][1] = "03" .Or. aRet[1][1] = "02") .And. aRet[1][2] == 0
						if fBxTitulo(aColsAux[nX][02],aColsAux[nX][03],aColsAux[nX][04],aColsAux[nX][05],;
								aCampos[nX][11], aCampos[nX][12], aCampos[nX][13], aCampos[nX][08], nVlBaixa,aCampos[nX][10],nAcresc,nBordero )

							MsgAlert('TITULO NÂO FOI BAIXADO CORRETAMENTE', '[MANUT.TITULO]')
							DisarmTransaction()
							return(nil)
						endif
					endif
				endif

				reclock("SE1", .F.)
				SE1->E1_ZZBC2 	:= "NNN"
				SE1->E1_ZZBXDB 	:= nBordero
				SE1->E1_ZZDTREL	:= dDataBase
				SE1->E1_ZZHISBX	:= aCampos[nX,14]
				SE1->E1_ZZOPER	:= Posicione("SX5",1,xFilial("SX5")+"ZZ"+aCampos[nX,07],"X5_DESCRI" )

				// Somente gera C/C quando baixa maior que titulo
				if aCampos[nX][09] > aCampos[nX][05]
					lGeraCt2 	:= .T.
					lCLVLDB		:= .T.
					// Incrementa valor do campo utilizado no valor da baixa (Somente Diferença)
					nTotalDB +=  ( aCampos[nX][09] - aCampos[nX][05] )
				endif
				SE1->(msunlock())
				nLinha ++
			
			endif
		endif
	next nX

	if lGeraCt2
		Begin Transaction
			// Lancamento debito
			if lCLVLDB
				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")   		, NIL},;
					{'CT2_LINHA'	 	, StrZero(nLinha,3) 					, NIL},;
					{'CT2_MOEDLC'  	,'01'   								, NIL},;
					{'CT2_DC'   	  	,'3'   								, NIL},;
					{'CT2_DEBITO'  	,'DEB' 								, NIL},;
					{'CT2_CREDIT'  	,'CRE' 								, NIL},;
					{'CT2_VALOR'  	, nTotalDB  							, NIL},;
					{'CT2_ORIGEM' 	,'CTBBXDEBITA'						, NIL},;
					{'CT2_HP'   		,''   								, NIL},;
					{'CT2_EMPORI'   	,'01'   								, NIL},;
					{'CT2_FILORI'   	,XFilial("SE1")   					, NIL},;
					{'CT2_TPSALD'   	,'6'   								, NIL},;
					{'CT2_CLVLDB'   	,'1101'   							, NIL},;
					{'CT2_HIST'   	,'RELAT.DUPLICATAS. NRO. ' + nBordero	, NIL} } )
				nLinha++
			endif

			// Lancamento credito
			if lCLVLCR
				//Adiciona os itens no array para lançaamento
				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")   		, NIL},;
					{'CT2_LINHA'		, StrZero(nLinha,3) 					, NIL},;
					{'CT2_MOEDLC'  	,'01'   								, NIL},;
					{'CT2_DC'   		,'3'   								, NIL},;
					{'CT2_DEBITO'  	,'DEB' 								, NIL},;
					{'CT2_CREDIT'  	,'CRE' 								, NIL},;
					{'CT2_VALOR'  	, nTotalCR  							, NIL},;
					{'CT2_ORIGEM' 	,'CTBBXDEBITA'						, NIL},;
					{'CT2_HP'   		,''   								, NIL},;
					{'CT2_EMPORI'   	,'01'   								, NIL},;
					{'CT2_FILORI'   	,XFilial("SE1")   					, NIL},;
					{'CT2_TPSALD'   	,'6'   								, NIL},;
					{'CT2_CLVLCR'   	,'1101'   							, NIL},;
					{'CT2_HIST'   	,'RELAT.DUPLICATAS. NRO. ' + nBordero	, NIL} } )
			endif
			
			// Lançamento no CT2
			if !lmtoCT2(nBordero,Date(),aItens )
				DisarmTransaction()
				ApMsgInfo( "[ERRO] - Transaçao nao efetuada, lmtoCT2(), fonte MANUTENCAOTITULOS.PRW"  )
				Return nil
			endif

		end Transaction

	endif

	if lTemUm
		ApMsgInfo( 'Relatorio de duplicatas Nro. ' + nBordero + ' gerado'  )
		ConfirmSX8()
		u_cargaZBA("",nBordero,lGeraCt2)
		if lProtesto
			u_manutRel(.F.,nBordero,"PROT")
		else
			u_manutRel(.F.,nBordero,"BXDB")
		endif
		oDlg:End()
	else
		ApMsgInfo( "[ERRO]-Nenhum titulo selecionado"  )
	endif

return(nil)


static function fNewGetDes()
	local nX				:= 0
	local aHeaderEx 		:= {}
	local aColsEx			:= {}
	local aFieldFill 		:= {}
	local aAlterFields 	:= {"VLRDESC","HISTBX"}
	local aSize 			:= {}
	local aPosObj 		:= {}
	local aObjects 		:= {}
	local aInfo 			:= {}
	local aBuscaX3		:= {}
	local nUsado			:= 0
	local aMotBx			:= {}
	static oMSNewGe1		:= nil
	static aColsAux 		:= {}

	aHeaderMs 	:= {}
	nUsado		:= 0

	aSize := MsAdvSize(.T.)
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aPosObj := MsObjSize( aInfo, aObjects )

	criaTrbSe1()

	DbSelectArea("TRBSE1")
	TRBSE1->(DbGoTop())

	if TRBSE1->(EOF())
		MsgAlert( 'Nenhum titulo encontrado para os filtros selecionados', '[MANUT.TITULO]' )
		TRBSE1->(dbCloseArea())
		FErase( "TRBSE1" + GetDbExtension())
		oDlg:End()
		return (nil)
	endif

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))


	// Cliente
	if SX3->(DbSeek("E1_CLIENTE"))
		aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Nome Cliente
	if SX3->(DbSeek("E1_NOMCLI"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Emissão titulo
	if SX3->(DbSeek("E1_EMISSAO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Numero duplicata
	aadd(aHeaderMs,{"Duplicata","DUPLICATA","@!" ,(TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]),0,".F.","","C","","R",} )

	// Saldo Titulo
	if SX3->(DbSeek("E1_SALDO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Vencimento real
	if SX3->(DbSeek("E1_VENCTO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Operação
	aadd(aHeaderMs,{"Operacao"	, "OPERACAO"	,"@!" ,03 ,0, .F. ,"","C","","R",} )

	// Valor desconto
	if SX3->(DbSeek("E1_VALOR"))
		Aadd(aHeaderMs, {"Vlr Desconto","VLRDESC",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Historico
	Aadd(aHeaderMs,{"Hist. Observacoes"	, "HISTBX", "@!",TamSX3("E1_ZZHISBX")[1]	,0, .F. ,"","C","","R", } )
	nUsado :=Len(aHeaderMs)

	while !TRBSE1->(Eof())

		aadd(aColsEx,Array(nUsado+1))
		aadd(aColsAux,Array(6))
		_nPsCols := Len(aColsEx)

		aColsEx[_nPsCols,01]	:=	Alltrim(TRBSE1->CLIENTE)
		aColsEx[_nPsCols,02]	:=	Alltrim(TRBSE1->NOMCLI)
		aColsEx[_nPsCols,03]	:=	TRBSE1->EMISSAO
		aColsEx[_nPsCols,04]	:= 	Alltrim(TRBSE1->DUPLICATA)
		aColsEx[_nPsCols,05]	:=	TRBSE1->SALDO
		aColsEx[_nPsCols,06]	:=	TRBSE1->VENCTO
		aColsEx[_nPsCols,07] 	:=  "DESCONTO"
		aColsEx[_nPsCols,08] 	:=	0
		aColsEx[_nPsCols,09] 	:=	Space(TamSX3("E1_HIST")[1])
		aColsEx[_nPsCols,10]	:=	.F.

		aColsAux[_nPsCols,01]	:= TRBSE1->CHAVE
		aColsAux[_nPsCols,02]	:= TRBSE1->PREFIXO
		aColsAux[_nPsCols,03]	:= TRBSE1->NUMERO
		aColsAux[_nPsCols,04]	:= TRBSE1->PARCELA
		aColsAux[_nPsCols,05]	:= TRBSE1->TIPO
		aColsAux[_nPsCols,06]	:= TRBSE1->RCNO

		TRBSE1->(DbSkip())

	enddo

	TRBSE1->(dbCloseArea())
	FErase( "TRBSE1" + GetDbExtension())

	oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 		;
		GD_INSERT+GD_DELETE+GD_UPDATE, "U_LinDescOk()", "AllwaysTrue", "+Field1+Field2", 	;
		aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, @aHeaderMs, @aColsEx)
	
return (nil)


user function LinDescOk()
	local nLinha 	:= oMSNewGe1:nAt

	if   !Empty(oMSNewGe1:aCols[nLinha][08]) .AND. oMSNewGe1:aCols[nLinha][08] > oMSNewGe1:aCols[nLinha][05]
		MessageBox("Desconto maior que o titulo...Dificil", "Aviso", 48)
		oMSNewGe1:GoTo(nLinha)
		return (.F.)
	endif
return(.T.)


/*/{Protheus.doc} fProcDes
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description 
aCampos[nX,01]	:=CLIENTE
aCampos[nX,02]	:=NOME CLIENTE
aCampos[nX,03]	:=EMISSÃO TITULO
aCampos[nX,04]	:=NRO. DUPLICATA
aCampos[nX,05]	:=SALDO TITULO
aCampos[nX,06]	:=VENC. REAL
aCampos[nX,07]	:=OPERAÇÂO
aCampos[nX,08]	:=VALOR DESCONTO (EDIT)
aCampos[nX,09]	:=HISTORICO (EDIT)
aCampos[nX,10]	:=DELETADO
aColsAux[nX,01]	:= CHAVE
aColsAux[nX,02]	:= PREFIXO
aColsAux[nX,03]	:= NUMERO
aColsAux[nX,04]	:= PARCELA
aColsAux[nX,05]	:= TIPO
aColsAux[nX,06]	:= RECNO
/*/
static function fProcDes()

	local cRetorno 		:= ""
	local nLinha			:=	1
	local nBordero 		:= ""
	local nTotalBord 		:= 0
	local lTudoOk			:= .F.
	local aItens			:= {}
	local cSe1Hist		:= ""
	local cEmail			:= "ctasreceber@cobrecom.com.br"
	local aBox			:={}
	local aRet			:={}
	local lBxDb			:= .T.

	DbSelectArea("ZBA")
	DBOrderNickName("RELAT")
	
	//TODO INICIO DRY
	RollBackSx8()
	nBordero				:= GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	while ZBA->(DbSeek(xFilial("ZBA")+nBordero,.F.))
		nBordero := GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	enddo
	//TODO FIM DRY

	aadd(aBox,{3,"DEBITAR CONTA CORRENTE?",1,{"SIM","NÃO"},50,"",.T.})
	if ParamBox(aBox,"DEFINIÇÔES DE CONTA-CORRENTE...", @aRet)
		if aRet[1] == 2
			lBxDb := .F.
		endif
	endif

	/*
		INICIA-SE O PROCESSAMENTO DOS TITULOS SELECIONADOS
		DEVE-SE ALTERAR O CAMPO SE1->E1_DECRES DE ACORDO COM O DESCONTO INFORMADO
		DEVE-SE GERAR O RELATORIO DE DESCONTO
	*/
	aCampos := aClone(oMSNewGe1:ACOLS)
	DbSelectArea("SE1")
	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSetOrder(1))

	for nX := 1 to Len(aCampos)
		//Verifica se tem valor desconto e tem historico
		if !Empty(aCampos[nX][08]) .AND. !Empty(aCampos[nX][09])
			SE1->( dbgoto( aColsAux[nX,06] ) )

			cSe1Hist := xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA +;
				SE1->E1_ZZBOR1
			/*
				"00"=Nenhum Erro
				"01"=Erro Compensação
				"02"=Usuario não selecionou NCC
				"03"=Não tem titulos NCC para cliente
				"04"=NCC Operação invalida
			*/
			aRet := compNCC(aColsAux,aCampos[nX,05],'DESC')
			if aRet[1][1] == "02" .And. !MsgYesNo("[AVISO] - Nenhum titulo NCC foi selecionado para compensação - deseja continuar?","AVISO")
				aRet := compNCC(aColsAux,aCampos[nX,05],'DESC')
			endif

			if	aRet[1][1] == "01" .Or. aRet[1][1] == "04"
				if aRet[1][1] == "01"
					cErro :="Erro ao compensar o titulo Nro: " + cValtoChar(Alltrim(SE1->(E1_NUM+E1_PARCELA))) + " Cliente: " + cValToChar(Alltrim(E1_NOMCLI))
				elseif aRet[1][1] == "04"
					cErro :="Erro o valor do titulo NCC selecionado para compensação, é maior ou igual ao valor do titulo a ser compensado, neste caso utilizar relatorio Baixa"
				endif
				u_envmail({cEmail}, "[Erro] - Compensar titulo para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcDes()","MANUTENCAOTITULOS.PRW",cErro}} )
				Alert(cErro)
				return (nil)
			endif

			if	aRet[1][1] == '06'
				cErro :="[ERRO] - Query que atualiza o campo E5->HISTOR, executado logo depois da compensação automatica"
				u_envmail({cEmail}, "[Erro] - Atualizar campo E5->HISTOR para relatorio  Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Manut.Titulos",cValToChar(ProcLine(0)),"fProcDes()","MANUTENCAOTITULOS.PRW",cErro}} )
				MsgAlert(cErro, '[MANUT.TITULO]')
				return (nil)
			endif


			Begin Transaction
				reclock("SE1", .F.)
				if aRet[1][1] # "00"  .Or. aRet[1][2] == 0
					SE1->(E1_SDDECRE)		:=	SE1->(E1_SDDECRE) + aCampos[nX,08]
					SE1->(E1_DECRESC) 	:= 	aCampos[nX,08]
				else
					aCampos[nX,08] 		:= aRet[1][2]
					SE1->(E1_DECRESC) 	:= aCampos[nX,08]
				endif

				// Debitar conta corrente
				if lBxDb
					SE1->E1_ZZOPER	:= 	aCampos[nX,07]
				else
					SE1->E1_ZZOPER	:= 	"DESC. NÃO DEBITAR"
				endIf
				SE1->E1_ZZBXDB 	:= 	nBordero
				SE1->E1_ZZDTREL	:=  dDataBase
				SE1->E1_ZZHISBX	:= 	aCampos[nX,09]
				SE1->(msunlock())
			End Transaction

			aadd(aItens,{ {'CT2_FILIAL'  	,XFilial("SE1")   					,NIL},;
				{'CT2_LINHA'  			,StrZero(nLinha,3)					, NIL},;
				{'CT2_MOEDLC'  			,'01'   								, NIL},;
				{'CT2_DC'   				,'3'   								, NIL},;
				{'CT2_DEBITO'  			,'DEB' 								, NIL},;
				{'CT2_CREDIT'  			,'CRE' 								, NIL},;
				{'CT2_VALOR'  			, aCampos[nX,08]  					, NIL},;
				{'CT2_ORIGEM' 			,'RELDPL'							, NIL},;
				{'CT2_HP'   				,''   								, NIL},;
				{'CT2_EMPORI'   			,'01'   								, NIL},;
				{'CT2_FILORI'   			,XFilial("SE1")   					, NIL},;
				{'CT2_TPSALD'   			,'6'   								, NIL},;
				{'CT2_CLVLCR'   			,'1101'   							, NIL},;
				{'CT2_HIST'   			,'RELAT.DUPLICATAS. NRO. ' + nBordero	, NIL} } )

			lTudoOk := .T.
			nLinha ++
		endif

	next nX

	if lTudoOk
		// Conta corrente somente se for debitar
		if lBxDb
			if !lmtoCT2(nBordero,Date(),aItens )
				DisarmTransaction()
				return (nil)
			endIf
		endIF

		ApMsgInfo( 'Relatorio. Desconto Nro. ' + nBordero + ' gerado'  )
		ConfirmSX8()
		u_cargaZBA("",nBordero,lBxDb)
		u_manutRel(.F.,nBordero, "DESC")
		oDlg:End()
	else
		MsgAlert("Nenhum desconto informado, ou desconto sem historico verifique", '[MANUT.TITULO]')
		RolbackSx8()
	endif

return (nil)


/*/{Protheus.doc} compNCC
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description
aInf[nX,01]	:= CHAVE
aInf[nX,02]	:= PREFIXO
aInf[nX,03]	:= NUMERO
aInf[nX,04]	:= PARCELA
aInf[nX,05]	:= TIPO
aInf[nX,06]	:= RECNO

"00"=Nenhum Erro
"01"=Erro Compensação
"02"=Usuario não selecionou NCC
"03"=Não tem titulos NCC para cliente
"04"=NCC Operação invalida
"06"=Erro atualizar E5_HISTOR 
/*/
static function compNCC(aInf, nVlrTit, cOrigem, nBordero)

	local _stru			:= {}
	local aCpoBro 		:= {}
	local oDlgLocal		:= nil
	local aArea			:= GetArea()
	local aSE1			:= SE1->(GetArea())
	local cArq			:= ""
	local cChave			:= ""
	local dEmissao		:= CToD("")
	local cRet			:= "00"
	local aRet			:= {}
	local cPicture		:= ""
	local cqry			:= ""
	local cFil			:= ""
	local lLoja			:= .F.
	local cBkName			:= ""
	aCores 				:= {}
	private lInverte 		:= .F.
	private cMark   		:= GetMark()
	private oMark			:= nil
	private nRecn			:= 0
	private nValNCC		:= 0
	private oFnt1			:= nil
	default nBordero		:= ""
	
	lLoja := MsgYesNo("Utilizar filtro (Loja+Emissao)?","Filtro Especifico/Generico")
	if lLoja
		cChave 		:= SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA)
		dEmissao		:= SE1->(E1_EMISSAO)
	else
		cChave		:= SE1->(E1_FILIAL +E1_CLIENTE)
	endif

	cPicture	:= SE1->("CLIENTE: " + Alltrim(E1_NOMCLI) + "  TITULO: " 		+  Alltrim(E1_NUM);
		+ "  PARC.: " + Alltrim(E1_PARCELA) + "  TIPO: " 				+  Alltrim(E1_TIPO) )  	+ '  VALOR: ' + ;
		Transform((SE1->( (E1_SALDO - E1_SDDECRE) + E1_SDACRES )) , "@E 9999,999,999.99" )

	AADD(_stru,{"OK"     		,"C"   								,2							,0						})
	AADD(_stru,{"FILIAL"    	,cValToChar(TamSX3("E1_FILIAL")[3])	,TamSX3("E1_FILIAL")[1]	,TamSX3("E1_FILIAL")[2]	})
	AADD(_stru,{"PREFIXO"   	,cValToChar(TamSX3("E1_PREFIXO")[3]),TamSX3("E1_PREFIXO")[1]	,TamSX3("E1_PREFIXO")[2]})
	AADD(_stru,{"NUMERO"   	,cValToChar(TamSX3("E1_NUM")[3])	,TamSX3("E1_NUM")[1]		,TamSX3("E1_NUM")[2]	})
	AADD(_stru,{"PARCELA"		,cValToChar(TamSX3("E1_PARCELA")[3]),TamSX3("E1_PARCELA")[1]	,TamSX3("E1_PARCELA")[2]})
	AADD(_stru,{"TIPO"    		,cValToChar(TamSX3("E1_TIPO")[3])	,TamSX3("E1_TIPO")[1]		,TamSX3("E1_TIPO")[2]	})
	AADD(_stru,{"LOJA" 		,cValToChar(TamSX3("E1_LOJA")[3])	,TamSX3("E1_LOJA")[1]		,TamSX3("E1_LOJA")[2]	})
	AADD(_stru,{"SALDO" 		,cValToChar(TamSX3("E1_SALDO")[3])	,TamSX3("E1_SALDO")[1]		,TamSX3("E1_SALDO")[2]	})
	AADD(_stru,{"RECN" 		,"N"								,7		,0	})

	if Select("TNCC") > 0
		DbSelectArea("TNCC")
		TNCC->(dbclosearea())
		FErase( "TNCC" + GetDbExtension())
	endif
	cArq:= Criatrab(_stru,.T.)
	DbUsearea(.t.,,carq,"TNCC")

	DbSelectArea("TNCC")
	DbSelectArea("SE1")
	// E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE1->(DbSetOrder(2))

	if SE1->(DbSeek( cChave, .T.))
		if lLoja
			cFil 	:= 'SE1->(E1_FILIAL + E1_CLIENTE + E1_LOJA)'
		else
			cFil		:= 'SE1->(E1_FILIAL + E1_CLIENTE)'
		endif
	endif

	while  SE1->(!Eof()) .And. &cFil == cChave
		if SE1->(E1_TIPO) $ 'NCC' .And. SE1->(E1_SALDO) > 0 .And. SE1->(E1_EMISSAO) >= dEmissao
			RecLock("TNCC",.T.)
			TNCC->(FILIAL)    	:=  	SE1->(E1_FILIAL)
			TNCC->(PREFIXO)   	:=  	SE1->(E1_PREFIXO)
			TNCC->(NUMERO)    	:=  	SE1->(E1_NUM)
			TNCC->(PARCELA)		:=  	SE1->(E1_PARCELA)
			TNCC->(TIPO)	  		:=  	SE1->(E1_TIPO)
			TNCC->(LOJA)  		:=  	SE1->(E1_LOJA)
			TNCC->(SALDO)			:= 	SE1->(E1_SALDO)
			TNCC->(RECN)			:= 	SE1->(Recno())
			MsunLock()
		endif
		SE1->(DbSkip())
	enddo
	TNCC->(DbGoTop())

	// Somente se tem titulos de NCC para este cliente
	if TNCC->(!Eof())
		aCpoBro	:= {{ "OK"			,, ""           	,"@!"},;
			{ "FILIAL"	,, "Filial" ,PesqPict("SE1", "E1_FILIAL"	)},;
			{ "PREFIXO"	,, "Prefixo",PesqPict("SE1", "E1_PREFIXO")},;
			{ "NUMERO"	,, "Numero" ,PesqPict("SE1", "E1_NUM")},;
			{ "PARCELA"	,, "Parcela",PesqPict("SE1", "E1_PARCELA")},;
			{ "TIPO"		,, "Tipo"   ,PesqPict("SE1", "E1_TIPO")},;
			{ "LOJA"		,, "Loja"   ,PesqPict("SE1", "E1_LOJA")},;
			{ "SALDO"	,, "Saldo"  ,PesqPict("SE1", "E1_SALDO")}}

		DEFINE FONT oFnt1 NAME "Lucida Console" BOLD SIZE 0,12
		DEFINE MSDIALOG oDlg1 TITLE "Compensação de NCC/TITULOS" From 9,0 To 315,800 PIXEL
		@004, 010 SAY cPicture  SIZE 360, 040 OF oDlg1 PIXEL FONT oFnt1 COLOR CLR_BLACK
		
		DbSelectArea("TNCC")
		TNCC->(DbGotop())
		oMark := MsSelect():New("TNCC","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,400},,,,,aCores)
		oMark:bMark := {| | Marcou()}
		ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End()},{|| oDlg1:End()})
		if nRecn > 0
			if (cOrigem $ 'DESC' .And. nValNCC >= nVlrTit) .Or. (cOrigem $ 'BX' .And. nValNCC < nVlrTit)
				cRet := "04"
			else
				PERGUNTE("AFI340",.F.)
				lContabiliza:= MV_PAR11 == 1
				lAglutina   := MV_PAR08 == 1
				lDigita   	:= MV_PAR09 == 1
				//Realiza a compensação	
				_aRecTit := { aInf[nX,06] }
				_aRecNCC := { nRecn }
				
				cBkName := FunName()
				SetFunName('fIniManu')
				if !MaIntBxCR(3,_aRecTit,,_aRecNCC,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,dDatabase )
					Help("XAFCMPAD",1,"HELP","XAFCMPAD","Não foi possível a compensação"+CRLF+" do titulo de NCC",1,0)
					cRet := "01"
				endif
				SetFunName(cBkName)
				
				/*
					SE5 vem posicionado no ultimo SE5 realizado Baixa NCC, procurar os documentos onde o E5_DOCUMENT referenciem ele.
					Fazer somente quando for baixa e não teve erro na compensação (A queary deste relatorio busca informações no SC5 E5_HISTOR nesta chave
				*/
				//TODO WARNING MIGRAR PARA FAMILIA FK ??
				if cOrigem $ 'BX' .And. cRet # "01"
					cqry	+= " UPDATE "+ retsqlname("SE5") + " SET E5_HISTOR = '" +  nBordero +  "' "
					cqry	+= " WHERE SUBSTRING(E5_DOCUMEN,1,18) IN ( '" + SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) + "') "
					cqry	+= " AND E5_CLIFOR = '" +  SE5->(E5_CLIFOR) + "' "
					cqry	+= " AND E5_LOJA = '" + SE5->(E5_LOJA) + "' "
					cqry	+= " AND E5_TIPODOC = 'CP'"
					cqry	+= " AND D_E_L_E_T_ = '' "
					if (TCSQLexec(cqry) < 0)
						MsgStop("LOG SQL: " + TCSQLError())
						cRet := "06"
					endif
					cqry	:=""
				endif
			endif
		else
			cRet := "02"
		endif
	else
		// Quando não tem NCC
		cRet := "03"
	endif

	if Select("TNCC") > 0
		DbSelectArea("TNCC")
		TNCC->(dbclosearea())
		FErase( "TNCC" + GetDbExtension())
	endIf)

	RestArea(aSE1)
	RestArea(aArea)
	SE1->( dbgoto( aInf[nX,06] ) )
	Aadd(aRet,{cRet,nValNCC,nRecn})
return(aRet)


static function Marcou()
	recLock("TNCC",.F.)
	if Marked("OK")
		TNCC->OK := cMark
		nRecn 	:= TNCC->(RECN)
		nValNCC 	:= TNCC->(SALDO)
		oMark:oBrowse:Refresh()
		oDlg1:End()
	else
		TNCC->OK := ""
	endif
	TNCC->(MSUNLOCK())
return (nil)
	
	
Static Function fNewGetPro()
	local nX
	local aHeaderEx 		:= {}
	local aColsEx			:= {}
	local aFieldFill 		:= {}
	local aAlterFields 	:= {"NEWVCTO","HISTBX"}
	local aSize 			:= {}
	local aPosObj 		:= {}
	local aObjects 		:= {}
	local aInfo 			:= {}
	local aBuscaX3		:= {}
	local nUsado			:= 0
	local aMotBx			:= {}
	static oMSNewGe1		:= nil
	static aColsAux 		:= {}

	aHeaderMs 	:= {}
	nUsado		:= 0

	aSize := MsAdvSize(.T.)
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aPosObj := MsObjSize( aInfo, aObjects )

	criaTrbSe1()

	DbSelectArea("TRBSE1")
	TRBSE1->(DbGoTop())

	if TRBSE1->(EOF())
		Alert("Nenhum titulo encontrado para os filtros selecionados")
		TRBSE1->(dbCloseArea())
		FErase( "TRBSE1" + GetDbExtension())
		oDlg:End()
		return (nil)
	endif

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	// Cliente
	if SX3->(DbSeek("E1_CLIENTE"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Nome do cliente
	if SX3->(DbSeek("E1_NOMCLI"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	// Emissão do titulo
	if SX3->(DbSeek("E1_EMISSAO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	// Numero da duplicata ( E1_NUM + E1_PARCELA )
	Aadd(aHeaderMs,{"Duplicata","DUPLICATA","@!" ,(TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]),0,".F.","","C","","R",} )

	// Saldo do titulo
	if SX3->(DbSeek("E1_SALDO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endIf

	// Vencimento
	if SX3->(DbSeek("E1_VENCTO"))
		Aadd(aHeaderMs, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Operação
	Aadd(aHeaderMs,{"Operacao"	, "OPERACAO"	,"@!",03	,0, .F. ,"","C","","R",} )

	// Novo vencimento
	if SX3->(DbSeek("E1_VENCTO"))
		Aadd(aHeaderMs, {"Novo Vcto","NEWVCTO",SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,})
	endif

	// Historico
	Aadd(aHeaderMs,{"Hist. Observacoes"	, "HISTBX"		, "@!"	,TamSX3("E1_ZZHISBX")[1]	,0, .F. ,"","C","","R", } )
	nUsado :=Len(aHeaderMs)

	while !TRBSE1->(Eof())

		AADD(aColsEx,Array(nUsado+1))
		AADD(aColsAux,Array(6))
		_nPsCols := Len(aColsEx)
		aColsEx[_nPsCols,01]	:=	Alltrim(TRBSE1->CLIENTE)
		aColsEx[_nPsCols,02]	:=	Alltrim(TRBSE1->NOMCLI)
		aColsEx[_nPsCols,03]	:=	TRBSE1->EMISSAO
		aColsEx[_nPsCols,04]	:= 	Alltrim(TRBSE1->DUPLICATA)
		aColsEx[_nPsCols,05]	:=	TRBSE1->SALDO
		aColsEx[_nPsCols,06]	:=	TRBSE1->VENCTO
		aColsEx[_nPsCols,07] 	:=  "PRORROGACAO"
		aColsEx[_nPsCols,08] 	:=	TRBSE1->VENCTO
		aColsEx[_nPsCols,09] 	:=	Space(TamSX3("E1_HIST")[1])
		aColsEx[_nPsCols,10]	:=	.F.
		aColsAux[_nPsCols,01]	:= TRBSE1->CHAVE
		aColsAux[_nPsCols,02]	:= TRBSE1->PREFIXO
		aColsAux[_nPsCols,03]	:= TRBSE1->NUMERO
		aColsAux[_nPsCols,04]	:= TRBSE1->PARCELA
		aColsAux[_nPsCols,05]	:= TRBSE1->TIPO
		aColsAux[_nPsCols,06]	:= TRBSE1->RCNO
		TRBSE1->(DbSkip())
	enddo

	TRBSE1->(dbCloseArea())
	FErase( "TRBSE1" + GetDbExtension())
	oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], 		;
		GD_INSERT+GD_DELETE+GD_UPDATE, "U_LinProOk()", "AllwaysTrue", "+Field1+Field2", 	;
		aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, @aHeaderMs, @aColsEx)

return (nil)


User Function LinProOk()
	local nLinha 	:= oMSNewGe1:nAt
	if !Empty(oMSNewGe1:aCols[nLinha][08]) .AND. oMSNewGe1:aCols[nLinha][08] < oMSNewGe1:aCols[nLinha][06]
		MessageBox("Não pode prorrogar com data menor que a data de vencimento real...Desta forma não seria uma prorrogação", "Aviso", 48)
		oMSNewGe1:GoTo(nLinha)
		Return (.F.)
	endif
Return (.T.)


/*/{Protheus.doc} fProcPro
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description
INICIA-SE O PROCESSAMENTO DOS TITULOS SELECIONADOS
DEVE-SE ALTERAR O CAMPO SE1->E1_DECRES DE ACORDO COM O DESCONTO INFORMADO
DEVE-SE GERAR O RELATORIO DE DESCONTO
aCampos[nX,01]	:=	CLIENTE
aCampos[nX,02]	:=	NOME CLIENTE
aCampos[nX,03]	:=	EMISSÃO TITULO
aCampos[nX,04]	:=	NRO. DUPLICATA
aCampos[nX,05]	:=	SALDO TITULO
aCampos[nX,06]	:=	VENC. REAL
aCampos[nX,07]	:= 	OPERAÇÂO
aCampos[nX,08]	:=	NOVO VENCIMENTO (EDIT)
aCampos[nX,09]	:=  HISTORICO (EDIT)
aCampos[nX,10]	:=	DELETADO
aColsAux[nX,01]	:= CHAVE
aColsAux[nX,02]	:= PREFIXO
aColsAux[nX,03]	:= NUMERO
aColsAux[nX,04]	:= PARCELA
aColsAux[nX,05]	:= TIPO
aColsAux[nX,06]	:= RECNO
/*/
static function fProcPro()
	local cRetorno 		:= ""
	local nLinha			:=	1
	local nBordero 		:= ""
	local nTotalBord 		:= 0
	local lTudoOk			:= .F.
	local aItens			:= {}
	local cSe1Hist		:= ""

	DbSelectArea("ZBA")
	DBOrderNickName("RELAT")

	RollBackSx8()
	nBordero				:= GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	while ZBA->(DbSeek(xFilial("ZBA")+nBordero,.F.))
		nBordero := GetSXENum("SE1","E1_ZZBXDB","01SE1010")
	enddo

	aCampos := aClone(oMSNewGe1:ACOLS)
	DbSelectArea("SE1")
	
	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSetOrder(1))
	
	for nX := 1 to Len(aCampos)
		//Vencimento e historico (sendo historico o campo utilizado como mark)
		If !Empty(aCampos[nX][08]) .AND. !Empty(aCampos[nX][09])
			SE1->( dbgoto( aColsAux[nX,06] ) )
			Begin Transaction

				reclock("SE1", .F.)

				/*
					Quando for primeiro relatorio de prorrogação, guardar a data original no E1_VENCORI
					Do segundo relatorio em diante, manter sempre a data original do titulo. 
				*/
				if Alltrim(SE1->(E1_ZZOPER)) # "PRORROGACAO"
					SE1->(E1_VENCORI)	:= SE1->(E1_VENCTO)
				endIf

				SE1->(E1_VENCTO)	:= aCampos[nX,08]
				SE1->(E1_VENCREA)	:= aCampos[nX,08]
				SE1->(E1_ZZOPER)	:= aCampos[nX,07]
				SE1->(E1_ZZBXDB) 	:= nBordero
				SE1->(E1_ZZDTREL) := dDataBase
				SE1->(E1_ZZHISBX)	:= aCampos[nX,09]
				SE1->(msunlock())
			End Transaction
			lTudoOk := .T.
		EndIf
	Next nX

	if lTudoOk
		ApMsgInfo( 'Relatorio. Prorrogacao Nro. ' + nBordero + ' gerado'  )
		ConfirmSX8()
		u_cargaZBA("",nBordero,.F.)
		u_manutRel(.F.,nBordero, "PRO")
		oDlg:End()
	else
		MsgAlert("Nenhum novo vencimento definido, ou definido sem historico", "[MANUT.TITULO]")
	endif

return (nil)

Static Function criaTrbSe1()
	local cSQL  :=""
	
	if Select("TRBSE1") > 0
		DbSelectArea("TRBSE1")
		TRBSDB->(dbclosearea())
		FErase( "TRBSE1" + GetDbExtension())
	endIf
	/*
		MV_PAR01 = FORNECEDOR
		MV_PAR02 = Nro TITULO
		MV_PAR03 = Emissão DE
		MV_PAR04 = Emissão ATÈ
		MV_PAR05 = Venicmento DE
		MV_PAR06 = Vencimento ATÈ
	*/
	// Cliente
	if !Empty(mv_par01)
		cSQL += "AND SE1.E1_CLIENTE = '" + Alltrim(mv_par01) + "'"
	endif

	// Titulo
	if !Empty(mv_par02)
		cSQL += "AND SE1.E1_NUM = '" + Alltrim(mv_par02) + "'"
	endif

	// Emissão
	if !Empty(mv_par03) .AND. !Empty(mv_par04)
		cSQL += " AND ( SE1.E1_EMISSAO >=  '" + DtoS(mv_par03) + "'  AND  SE1.E1_EMISSAO <= '" + DtoS(mv_par04) + "' ) "
	endif

	// Vencimento
	if !Empty(mv_par05) .AND. !Empty(mv_par06)
		cSQL += " AND ( SE1.E1_VENCTO >=  '" + DtoS(mv_par05) + "'  AND  SE1.E1_VENCTO <= '" + DtoS(mv_par06) + "' ) "
	endif
	
	// somente os titulos que jà foram tranferidos(bordero sp),ou cancelamento baixa e debita nnn
	cSQL += " AND (E1_ZZBC2 = '000' OR E1_ZZBC2 = 'NNN')"
	
	// não esteja baixado e descontos concedidos não ultrapassem valor do titulo
	cSQL += " AND E1_SALDO > 0 AND E1_SDDECRE <= E1_VALOR   "
	cSQL := "%"+cSQL+"%"

	//TODO obter saldo do titulo considerando a tabela ZBA de Descontos
	BeginSQL Alias "TRBSE1"

		column EMISSAO 	as Date
		column VENCTO 	as Date
		column DTBX		as Date

		SELECT SE1.E1_FILIAL + SE1.E1_PREFIXO + SE1.E1_NUM + SE1.E1_PARCELA + SE1.E1_TIPO	AS CHAVE,
		SE1.E1_PREFIXO																AS PREFIXO,
		SE1.E1_NUM																	AS NUMERO,
		SE1.E1_PARCELA																AS PARCELA,
		SE1.E1_TIPO																	AS TIPO,
		SE1.E1_CLIENTE																AS CLIENTE,
		SE1.E1_PORTADO																AS BANCO,
		SE1.E1_AGEDEP																	AS AGENCIA,
		SE1.E1_CONTA																	AS CONTA,
		SE1.E1_NOMCLI																	AS NOMCLI,
		SE1.E1_EMISSAO																AS EMISSAO,
		SE1.E1_NUM + SE1.E1_PARCELA													AS DUPLICATA,
		((SE1.E1_SALDO + SE1.E1_SDACRES) - SE1.E1_SDDECRE) 								AS SALDO,
		SE1.E1_VENCTO																	AS VENCTO,
		SE1.E1_VENCTO																	AS DTBX,
		((SE1.E1_SALDO + SE1.E1_SDACRES) - SE1.E1_SDDECRE) 								AS VLRBX,
		SE1.R_E_C_N_O_ 																AS RCNO

		FROM %Table:SE1% SE1
		WHERE SE1.E1_FILIAL = %xFilial:SE1% AND SE1.%NotDel% %exp:cSQL%
		ORDER BY %Order:SE1,1%
	EndSql

return(nil)


/*/{Protheus.doc} lerMotBx
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@description
Ler os motivos de baixa que estão no arquivo sigaadv.mot
Devolve array com os motivos de baixa 
/*/
Static Function lerMotBx()
	local aCampos		:= {}
	local cArqTmp		:= ""
	local cFile		:= "SIGAADV.MOT"
	local aRetorno 	:= {}

	aCampos :={  	{"SIGLA"		,"C"		,03,0},;
		{"DESCR"		,"C"		,10,0},;
		{"CARTEIRA"	,"C"		,01,0},;
		{"MOVBANC"	,"C"		,01,0},;
		{"COMIS"		,"C"		,01,0},;
		{"CHEQUE"	,"C"		,01,0} }

	cArqTmp := CriaTrab( aCampos , .T.)
	dbUseArea(.T.,,cArqTmp, "cArqTmp", if(.F. .OR. .F., !.F.,NIL))
	dbSelectArea( "cArqTmp" )
	APPEND FROM &cFile SDF
	dbGoTop()
	While !cArqTmp->(EOF())
		AADD(aRetorno, {Alltrim(cArqTmp->SIGLA),Alltrim(cArqTmp->DESCR) }  )
		cArqTmp->(DbSkip())
	EndDo
	FCLOSE(cFile)
	cArqTmp->(DbCloseArea())

Return (aRetorno)


static function lmtoCT2(cNroBord,dDtBor,aItens)
	Local cArea			:= GetArea()
	Local lRet			:= .T.
	local oExec			:= nil
	local aRet			:= {}

	aCab := { 	{'DDATALANC' 	,dDtBor 	,NIL},;
		{'CLOTE' 		,"028850" 	,NIL},;
		{'CSUBLOTE' 	,'001' 			,NIL},;
		{'CDOC' 		, cNroBord 		,NIL},;
		{'CPADRAO' 	,'' 				,NIL},;
		{'NTOTINF' 	,0 				,NIL},;
		{'NTOTINFLOT' ,0 				,NIL} }

	oExec := cbcExecAuto():newcbcExecAuto(aItens,aCab)
	oExec:exAuto('CTBA102',3)
	aRet := oExec:getRet()
	if !aRet[1]
		Help("XAFCMPAD",1,"HELP","XAFCMPAD",'ERRO: ' + aRet[2],1,0)
		lRet	:= .F.
	endif
	FreeObj(oExec)
	RestArea(cArea)
Return(lRet)


/*/{Protheus.doc} exCT2
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
/*/
static function exCT2(cMov)
	local aCab  		:= {}
	local aItens 		:= {}
	local cSe1Hist	:= ''
	// se1 vem posicionado pelo recno do registro
	cSe1Hist := xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA +;
		SE1->E1_ZZBOR1

	// Verifica o tipo do movimento (Desconto ou Acrescimo)
	if cMov == "DEC"
		// Excluir lançamento no CT2 caso exista
		
		DbSelectarea("CT2")
		// CT2_FILIAL+CT2_ORIGEM
		DbOrderNickName("CT2ORIGEM")
		
		// //Procura pelos registro relacionados aos relatorios de duplicatas(alteraçôes em titulos)
		if CT2->(DbSeek(xFilial("CT2") + "RELDPL" ,.F.) )
			while CT2->(!eof()).AND. Alltrim(CT2->CT2_ORIGEM) == "RELDPL"
				aItens 	:= {} //Zera os arrays a cada lançamento..precausão
				aCab	:= {}
				// Mudar aqui mudar fonte PE_FINA040 função FA040ALT
				if Alltrim(CT2->CT2_HIST) == Alltrim('RELAT.DUPLICATAS. NRO. ' + Alltrim(SE1->(E1_ZZBXDB)))
					
					aCab := { 	{'DDATALANC' 	,CT2->(CT2_DATA)		,NIL},;
						{'CLOTE' 		,"018850" 				,NIL},;
						{'CSUBLOTE' 		,'001' 					,NIL},;
						{'CDOC' 			,CT2->(CT2_DOC)			,NIL},;
						{'CPADRAO' 		,'' 						,NIL},;
						{'NTOTINF' 		,0 						,NIL},;
						{'NTOTINFLOT' 	,0 						,NIL} }

					aAdd(aItens,{ 	{'CT2_FILIAL' 	,XFilial("SE1")   						, NIL},;
						{'CT2_LINHA'  	,'001'												, NIL},;
						{'CT2_MOEDLC'  	,'01'   												, NIL},;
						{'CT2_DC'   		,'3'   												, NIL},;
						{'CT2_DEBITO'  	,'DEB' 												, NIL},;
						{'CT2_CREDIT'  	,'CRE' 												, NIL},;
						{'CT2_VALOR'  	, SE1->E1_DECRESC  									, NIL},;
						{'CT2_ORIGEM' 	,'RELDPL'											, NIL},;
						{'CT2_HP'   		,''   												, NIL},;
						{'CT2_EMPORI'   	,'01'   												, NIL},;
						{'CT2_FILORI'   	,XFilial("SE1")   									, NIL},;
						{'CT2_TPSALD'   	,'6'   												, NIL},;
						{'CT2_CLVLCR'   	,'1101'   											, NIL},;
						{'CT2_HIST'   	,'RELAT.DUPLICATAS. NRO. ' + Alltrim(SE1->(E1_ZZBXDB))	, NIL} } )

					//Efetivar a exclusão
					excluirCt2(aCab,aItens)
				endif
				CT2->(dbskip())
			enddo
		endif
	endif
return (nil)


/*/{Protheus.doc} excluirCt2
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
/*/
static function excluirCt2(aCab,aItens)
	Local lRet			:= .T.
	local oExec 		:= Nil
	local aRet			:= {}
	oExec := cbcExecAuto():newcbcExecAuto(aItens, aCab)
	oExec:exAuto('CTBA102',5)
	aRet := oExec:getRet()
	if !aRet[1]
		Help("XAFCMPAD",1,"HELP","XAFCMPAD",'ERRO: ' + aRet[2],1,0)
	endif
	FreeObj(oExec)
return(lRet)



/*/{Protheus.doc} fBxTitulo
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description função para realizar as baixas automaticas dos titulos selecionados
/*/
Static Function fBxTitulo(cPrefixo,cNum,cParcela,cTipo, cBanco, cAgencia, cConta, dDtBaixa, nValor,cMotBx,nAcresc,nBordero)
	
	local aSE1Area	:= SE1->(GetArea())
	local aBaixa 		:= {}
	local lErro 		:= .F.
	local oExec 		:= nil
	local aRet		:= {}
	local dBkData		:= dDataBase
	
	aBaixa :=	{	{"E1_PREFIXO"  	,cPrefixo      			,Nil    	},;
		{"E1_NUM"      	,cNum            		,Nil    	},;
		{"E1_PARCELA"  	,cParcela			,Nil    	},;
		{"E1_TIPO"     	,cTipo           		,Nil    	},;
		{"E1_CLIENTE"   	,'022250'           	,Nil    	},;
		{"E1_NOMCLI"    	,''           		,Nil    	},;
		{"E1_NATUREZ"   	,'D0111'           	,Nil    	},;
		{"AUTMOTBX"    	,Alltrim(cMotBx)       ,Nil    	},;
		{"AUTBANCO"    	,cBanco           	,Nil    	},;
		{"AUTAGENCIA"  	,cAgencia         	,Nil    	},;
		{"AUTCONTA"    	,cConta     			,Nil    	},;
		{"AUTDTBAIXA"  	,dDtBaixa         	,Nil    	},;
		{"AUTDTCREDITO"	,dDtBaixa         	,Nil    	},;
		{"AUTHIST"     	,cValToChar(nBordero)	,Nil    	},;
		{"AUTACRESC"    ,nAcresc				,Nil		},;
		{"AUTJUROS"    	,0                	,Nil	,	.T.},;
		{"AUTVALREC"   	,nValor           	,Nil    	}}
	
	dDataBase := dDtBaixa

	oExec := cbcExecAuto():newcbcExecAuto(aBaixa)
	oExec:exAuto('Fina070',3)

	aRet := oExec:getRet()
	if !aRet[1]
		Help("XAFCMPAD",1,"HELP","XAFCMPAD",'ERRO: ' + aRet[2],1,0)
		lErro := .T.
	endif
	FreeObj(oExec)
	dDataBase := dBkData
	RestArea(aSE1Area)
return (lErro)


/*/{Protheus.doc} manutRel
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description RELATORIOS U_manutRel(.F.,"002332", "DESC")
/*/
user function manutRel(lAuto,cNroDoc, cOper)
	local oReport		:= nil
	local cPerg 		:= "RELBX"
	local oFonteRel 	:= TFont():New( "Arial", , 07, .T.)
	local aTRB 		:= {}
	default lAuto 	:= .T.
	default cNroDoc 	:= ""

	if lAuto
		CriaSX1(cPerg,"REL")
		Pergunte(cPerg, .T.)
		if  mv_Par02 == 1
			oReport := ReportDef("BXDB")
		elseif mv_Par02 == 2
			oReport := ReportDef("DESC")
		elseif mv_Par02 == 3
			oReport := ReportDef("PRO")
		elseif mv_Par02 == 4
			oReport := ReportDef("PROT")
		elseif mv_Par02 == 5
			oReport := ReportDef("SUB")
		endif
	else
		mv_Par01 := cNroDoc
		oReport := ReportDef(cOper)
	endif

	//Configurações do relatorio
	oReport:OFONTBODY 	:= oFonteRel 	// Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 06 		// Tamanho da Fonte
	oReport:NLINEHEIGHT 	:= 40 		// Altura da linha
	oReport:LBOLD			:= .T.		// Pedido Rafael para Letras Negritos no relatorio
	oReport:SetLandScape()				// Orientação da paginas
	oReport:SetTotalInLine(.F.)
	oReport:PrintDialog() 				//Tela para configuração de impressão
return (nil)


Static Function ReportDef(cOper)
	local oReport
	local oSection1
	local oSection2
	local cCabec		:= ""

	oReport := TReport():New("Contas a receber","Relatorio - N.  " + AllTrim(mv_Par01) ,"RELFIN",{|oReport| PrintReport(oReport,cOper)},"RELSFIN")
	// dois layouts diferentes de relatorios (baixar e substituir é muito diferente dos outros)
	if cOper == 'SUB'
		//Defini as sessões que teremos no relatorio
		oSection1 := TRSection():New(oReport,"Titulo Baixado" ,"ZBA")
		oSection2 := TRSection():New(oReport,"Substituir Por" ,"ZBA")
		oSection3 := TRSection():New(oReport,"TEXTO" ,"ZBA")

		//Celulas (Titulo baixado)
		TRCell():New(oSection1,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection1,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection1,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection1,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection1,"ZBA_VALOR"			,"ZBA","VALOR")
		TRCell():New(oSection1,"ZBA_VENCTO"			,"ZBA","VENCIMENTO")
		TRCell():New(oSection1,"ZBA_OPER"			,"ZBA","OPERACAO")
		TRCell():New(oSection1,"ZBA_HISTOP"			,"ZBA","HISTORICO")
		//Celulas (Titulo novo)
		TRCell():New(oSection2,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection2,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection2,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection2,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection2,"ZBA_VALOR"			,"ZBA","VALOR")
		TRCell():New(oSection2,"ZBA_VENCTO"			,"ZBA","VENCIMENTO")
		TRCell():New(oSection2,"ZBA_OPER"			,"ZBA","OPERACAO")
		//Celulas (Campos assinatura)
		//Tipo de dados para a Sessão criada com os parametros sem dicioanario
		TRCell():New(oSection3,"TEXTO" 				,"" ,"" ,"@!"/*Picture*/,190/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"",.T.,"")

		//Operações e totalizadores
		TRFunction():New(oSection1:Cell("ZBA_VALOR"),NIL,"SUM"	,NIL,"                       Total Baixado......."	,NIL,NIL,.F.,.T.,.F.)
		TRFunction():New(oSection2:Cell("ZBA_VALOR"),NIL,"SUM"	,NIL,"                       Total Novo.........."	,NIL,NIL,.F.,.T.,.F.)

	else
		//Defini as sessões que teremos no relatorio
		oSection1 := TRSection():New(oReport,"Baixa Debita" ,"ZBA")
		oSection2 := TRSection():New(oReport,"De" 			,"ZBA")

		//Celulas
		TRCell():New(oSection1,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection1,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection1,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection1,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection1,"ZBA_VALOR"			,"ZBA","VALOR")

		if cOper == "PRO"
			TRCell():New(oSection1,"ZBA_VENORI"		,"ZBA","VENCIMENTO")
		else
			TRCell():New(oSection1,"ZBA_VENCTO"		,"ZBA","VENCIMENTO")
		endIf

		TRCell():New(oSection1,"ZBA_OPER"		,"ZBA","OPERACAO")

		if cOper == "BXDB"
			TRCell():New(oSection1,"E5_DATA"		,"SE5","DIA.REC.")
			TRCell():New(oSection1,"E5_VALOR"		,"SE5","VLR.BAIXA")
		elseif cOper == "DESC"
			TRCell():New(oSection1,"ZBA_DESCON"		,"ZBA","VALOR")
		elseif	cOper == "PRO"

			TRCell():New(oSection1,"ZBA_VENCTO"		,"ZBA","Venc.Real")
		endif

		TRCell():New(oSection1,"ZBA_HISTOP"			,"ZBA","HISTORICO")

		if cOper == "BXDB"
			TRFunction():New(oSection1:Cell("E5_VALOR"),NIL,"SUM"	,NIL," Total Relatorio......."	,NIL,NIL,.F.,.T.,.F.)
		elseif cOper == "PROT"
			TRFunction():New(oSection1:Cell("ZBA_VALOR"),NIL,"SUM",NIL," Total Relatorio......."	,NIL,NIL,.F.,.T.,.F.)
		elseif cOper == "DESC"
			TRFunction():New(oSection1:Cell("ZBA_DESCON"),NIL,"SUM"	,NIL,"  Total Descontos......."	,NIL,NIL,.F.,.T.,.F.)
		endif

		// Tipo de dados para a Sessão criada com os parametros sem dicioanario
		TRCell():New(oSection2,"De" 				,"" ,"" ,"@!"/*Picture*/,190/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"",.T.,"")
	endif
return (oReport)


Static Function PrintReport(oReport,cOper)
	local oSection1 	:= oReport:Section(1)
	local oSection2 	:= oReport:Section(2)
	local oSection3	:= oReport:Section(3)
	local cCabec		:= ""
	local cSQL		:= ""
	local cSQL1		:= ""

	// etrutura do baixar e substituir é muito diferente (feito isaladamente)
	if cOper == "SUB"

		// where dos titulos antigos
		cSQL += "AND ZBA.ZBA_OPER = 'BAIXAR' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		cSQL += "AND ZBA.ZBA_BAIXA <> '' "
		cSQL := "%"+cSQL+"%"

		// where dos titulos novos
		cSQL1 += "AND ZBA.ZBA_OPER = 'SUBSTITUIR' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		cSQL1 += "AND ZBA.ZBA_BAIXA = '' "
		cSQL1 := "%"+cSQL1+"%"

		// query dos titulos antigos
		oSection1:BeginQuery()
		BeginSql alias "ANTIGO"

			SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
			ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP
			FROM %table:ZBA% ZBA
			WHERE ZBA.%NotDel%  %Exp:cSQL%
			ORDER BY ZBA.ZBA_VENCTO
		EndSql
		oSection1:EndQuery()
		oSection1:Print()
		oSection1:Finish()

		// query dos titulos novos
		oSection2:BeginQuery()
		BeginSql alias "NOVO"
			SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
			ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP

			FROM %table:ZBA% ZBA

			WHERE ZBA.%NotDel%  %Exp:cSQL1%
			ORDER BY ZBA.ZBA_VENCTO
		EndSql
		oSection2:EndQuery()
		oSection2:Print()
		oSection2:Finish()

		cCabec += CRLF+CRLF
		cCabec += CRLF+CRLF
		cCabec += "   _____________________             ______________________________________                   ___________________________________" 							+ CRLF
		cCabec += "         "+Alltrim(Upper(cUserName))+    "                      RAFAEL V. RUAS / GUSTAVO V. RUAS                          (CONFERIDO)-Andrei S.M. dos Anjos" 	+ CRLF
		cCabec += "  DEPTO.CONTAS A RECEBER                           DIRETORIA                                           Contas a Receber"										+ CRLF

		oSection3:Init()

		oSection3:ACELL[1]:UVALUE := cCabec
		oSection3:ACELL[1]:LBOLD := .T.
		oSection3:ACELL[1]:LCELLBREAK := .T.

		oSection3:PrintLine()
		oSection3:Finish()
	else
		
		if cOper == "BXDB"
			cSQL += " AND SE5.E5_TIPODOC IN ('BA','VL','CP') AND ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
		elseif cOper == "PROT"
			cSQL += "AND ZBA.ZBA_OPER ='BAIXAR E DEBITAR PROTESTO'  AND ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
			cSQL += "AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
		elseif cOper == "DESC"
			cSQL += "AND (ZBA.ZBA_OPER = 'DESCONTO' OR ZBA.ZBA_OPER = 'DESC. NÃO DEBITAR') AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
		elseif cOper == "PRO"
			cSQL += "AND ZBA.ZBA_OPER = 'PRORROGACAO' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
		endif

		cSQL := "%"+cSQL+"%"
		oSection1:BeginQuery()

		if cOper == "BXDB"
			BeginSql alias "QRYBXDBT"

				// quando mudar esta query mudar a do vvista.prw tambem
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER , SE5.E5_DATA, SE5.E5_VALOR AS E5_VALOR, ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				INNER JOIN %table:SE5% SE5

				ON	ZBA.ZBA_FILIAL	= SE5.E5_FILIAL		AND
				ZBA.ZBA_PREFIX		= SE5.E5_PREFIXO	AND
				ZBA.ZBA_NUM			= SE5.E5_NUMERO		AND
				ZBA.ZBA_PARC			= SE5.E5_PARCELA	AND
				ZBA.ZBA_TIPO			= SE5.E5_TIPO		AND
				ZBA.ZBA_CLI			= SE5.E5_CLIFOR		AND
				ZBA.ZBA_LOJA			= SE5.E5_LOJA	    AND
				ZBA.ZBA_NROREL		= SE5.E5_HISTOR

				WHERE ZBA.%NotDel% AND SE5.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO

			EndSql

		elseif cOper == "PROT"
			BeginSql alias "QRYPROT"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC,
				((ZBA.ZBA_SALDO + ZBA.ZBA_SDACRE) - ZBA.ZBA_SLDESC) AS ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql

		elseif cOper == "DESC"
			BeginSql alias "QRYDESC"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_DESCON, ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql

		elseif cOper == "PRO"
			BeginSql alias "QRYPRO"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENORI, ZBA.ZBA_OPER ,ZBA.ZBA_VENCTO, ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql
		endif

		oSection1:EndQuery()
		oSection1:Print()
		oSection1:Finish()

		cCabec += CRLF+CRLF
		cCabec += CRLF+CRLF
		cCabec += "   _____________________             ______________________________________                   ___________________________________" 							+ CRLF
		cCabec += "         "+Alltrim(Upper(cUserName))+    "                      RAFAEL V. RUAS / GUSTAVO V. RUAS                          (CONFERIDO)-Andrei S.M. dos Anjos" 	+ CRLF
		cCabec += "  DEPTO.CONTAS A RECEBER                           DIRETORIA                                           Contas a Receber"										+ CRLF

		oSection2:Init()

		oSection2:ACELL[1]:UVALUE 		:= cCabec
		oSection2:ACELL[1]:LBOLD 		:= .T.
		oSection2:ACELL[1]:LCELLBREAK 	:= .T.
		oSection2:PrintLine()
		oSection2:Finish()

	endif
	
return(nil)


Static Function CriaSX1(cPerg,cTipo)
	Local aHelp :={}

	if cTipo == "REL"

		AAdd(aHelp, { {"Informe o numero relatorio"}, {""},{""} }  )
		PutSX1(cPerg,"01","Numero do Relatorio Baixa Debita   ?","","","mv_ch1","C",09,00,00,"G","","","","","mv_Par01","","","","",;
			"","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

		AAdd(aHelp, { {"Informe o tipo do relatorio"}, {""},{""} }  )
		PutSX1(cPerg,"02","Tipo de relatorio   ?","","","mv_ch2","C",12,00,01,"C","","","","","mv_Par02","Baixar e Debitar","","",;
			"","Desconto","","","Prorrogacao","","","Protesto","","","Bx.Substituir","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

	elseif cTipo == "INI"

		AAdd(aHelp, { {"Filtrar por cliente"}, {""},{""} }  )
		PutSX1(cPerg,"01","Cliente   ?","","","mv_ch1","C",09,00,00,"G","","SA1CLI","","","mv_Par01","","","","",;
			"","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

		AAdd(aHelp, { {"Filtrar pelo numero do titulo"}, {""},{""} }  )
		PutSX1(cPerg,"02","Numero do titulo   ?","","","mv_ch2","C",TAMSX3("E1_NUM")[1],00,00,"G","","","","","mv_Par02","","","","",;
			"","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

		AAdd(aHelp, { {"Filtrar emissão de:"}, {""},{""} }  )
		PutSX1(cPerg,"03","Emissão de:   ?","","","mv_ch3","D",TamSX3("E1_EMISSAO")[1],00,00,"G","","","","","mv_Par03","","","","",;
			"","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

		AAdd(aHelp, { {"Filtrar pelo emissão até"}, {""},{""} }  )
		PutSX1(cPerg,"04","Emissão até:   ?","","","mv_ch4","D",TamSX3("E1_EMISSAO")[1],00,00,"G","","","","","mv_Par04","","","","",;
			"","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

		AAdd(aHelp, { {"Filtrar pelo vencimento de:"}, {""},{""} }  )
		PutSX1(cPerg,"05","Vencimento de:   ?","","","mv_ch5","D",TamSX3("E1_VENCTO")[1],00,00,"G","","","","","mv_Par05","","","","",;
			"","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")

		AAdd(aHelp, { {"Filtrar pelo vencimento até"}, {""},{""} }  )
		PutSX1(cPerg,"06","Vencimento até:   ?","","","mv_ch6","D",TamSX3("E1_VENCTO")[1],00,00,"G","","","","","mv_Par06","","","","",;
			"","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
	endif
return (Nil)



/*/{Protheus.doc} cargaZBA
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
@description 
u_cargaZBA("",000671)
Função utilizada para importar todos os registros do SE1 que originaram relatorios de manutenção
todos deveram ser migrados para a tabela ZBA010

TABELA ZBA
INDICE 01 :NICKNAME(CH_UNICO)	- ZBA_FILIAL+ZBA_PREFIX+ZBA_NUM+ZBA_PARC+ZBA_TIPO+ZBA_CLI+ZBA_LOJA+ZBA_NROREL+ZBA_OPER
INDICE 02 :NICKNAME(OPER_REL) 	- ZBA_OPER+ZBA_NROREL
INDICE 03 :NICKNAME(RELAT )		- ZBA_NROREL

CAMPOS:
X3_CAMPO	X3_TIPO	X3_TAMANHO	X3_DECIMAL
ZBA_FILIAL	C	2
ZBA_PREFIX	C	3
ZBA_NUM		C	9
ZBA_PARC	C	3
ZBA_TIPO	C	3
ZBA_CLI		C	6
ZBA_LOJA	C	2
ZBA_NOMCLI	C	20
ZBA_NROREL	C	6
ZBA_OPER	C	30
ZBA_HISTOP	C	70
ZBA_DTREL	D	8
ZBA_HISTF	C	40
ZBA_SDACRE	N	17	2
ZBA_DESCON	N	17	2
ZBA_SLDESC	N	17	2
ZBA_VALOR	N	17	2
ZBA_SALDO	N	17	2
ZBA_EMISS	D	8
ZBA_VENORI	D	8
ZBA_VENCTO	D	8
ZBA_VENCRE	D	8
ZBA_BAIXA	D	8
/*/
user function cargaZBA(cOper,cNroRel,lCt2)

	local cSQL  		:= ""
	local lRet		:= .T.
	local lAchou		:= .F.
	default cOper 	:= ""
	default cNroRel	:= ""
	default lCt2		:= .F.

	if Select("TRBZBA") > 0
		DbSelectArea("TRBZBA")
		TRBZBA->(dbclosearea())
		FErase( "TRBZBA" + GetDbExtension())
	endif

	cSQL += " AND SE1.E1_ZZBXDB <> ''"

	if !Empty(cOper)
		cSQL += " AND SE1.E1_ZZOPER IN ('" + cOper + " ')"
	elseif !Empty(cNroRel)
		cSQL += " AND SE1.E1_ZZBXDB IN ('" + cNroRel + " ')"
	endif
	cSQL := "%"+cSQL+"%"

	BeginSQL Alias "TRBZBA"
		column 	E1_ZZDTREL 	as Date
		column	E1_EMISSAO 	as Date
		column	E1_VENCORI 	as Date
		column	E1_VENCTO	as Date
		column	E1_VENCREA	as Date
		column   E1_BAIXA		as Date

		SELECT
		SE1.E1_FILIAL,
		SE1.E1_PREFIXO,
		SE1.E1_NUM,
		SE1.E1_PARCELA,
		SE1.E1_TIPO,
		SE1.E1_CLIENTE,
		SE1.E1_LOJA,
		SE1.E1_NOMCLI,
		SE1.E1_ZZBXDB,
		SE1.E1_ZZOPER,
		SE1.E1_ZZHISBX,
		SE1.E1_ZZDTREL,
		SE1.E1_ZZHISTF,
		SE1.E1_SDACRES,
		SE1.E1_DECRESC,
		SE1.E1_SDDECRE,
		SE1.E1_VALOR,
		SE1.E1_SALDO,
		SE1.E1_EMISSAO,
		SE1.E1_VENCORI,
		SE1.E1_VENCTO,
		SE1.E1_BAIXA,
		SE1.E1_VENCREA

		FROM %Table:SE1% SE1
		
		WHERE SE1.E1_FILIAL = %xFilial:SE1% %exp:cSQL% AND SE1.%NotDel%
		ORDER BY SE1.E1_ZZBXDB
	EndSql

	DbSelectArea("TRBZBA")
	TRBZBA->(DbGoTop())

	if TRBZBA->(EOF())
		lRet	:= .F.
		TRBZBA->(dbCloseArea())
		FErase( "TRBZBA" + GetDbExtension())
	else
		dbselectarea("ZBA")
		//ZBA_FILIAL+ZBA_PREFIX+ZBA_NUM+ZBA_PARC+ZBA_TIPO+ZBA_CLI+ZBA_LOJA+ZBA_NROREL+ZBA_OPER
		ZBA->(DbSetOrder(1))
		DbSelectArea("TRBZBA")
		TRBZBA->(DbGoTop())

		While !TRBZBA->(EOF())
			lAchou := !ZBA->(DbSeek(xFilial("SE1") + TRBZBA->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+E1_ZZBXDB+E1_ZZOPER),.F.) )
			reclock("ZBA", lAchou)
			ZBA->(ZBA_FILIAL)	:=	 	TRBZBA->(E1_FILIAL)
			ZBA->(ZBA_PREFIX)	:=		TRBZBA->(E1_PREFIXO)
			ZBA->(ZBA_NUM)	:=		TRBZBA->(E1_NUM)
			ZBA->(ZBA_PARC)	:=		TRBZBA->(E1_PARCELA)
			ZBA->(ZBA_TIPO)	:=		TRBZBA->(E1_TIPO)
			ZBA->(ZBA_CLI)	:=		TRBZBA->(E1_CLIENTE)
			ZBA->(ZBA_LOJA)	:=		TRBZBA->(E1_LOJA)
			ZBA->(ZBA_NOMCLI)	:= 		TRBZBA->(E1_NOMCLI)
			ZBA->(ZBA_NROREL)	:= 		TRBZBA->(E1_ZZBXDB)
			ZBA->(ZBA_OPER)	:= 		TRBZBA->(E1_ZZOPER)
			ZBA->(ZBA_HISTOP)	:= 		TRBZBA->(E1_ZZHISBX)
			ZBA->(ZBA_DTREL)	:=		TRBZBA->(E1_ZZDTREL)
			ZBA->(ZBA_HISTF)	:= 		TRBZBA->(E1_ZZHISTF)
			ZBA->(ZBA_SDACRE)	:= 		TRBZBA->(E1_SDACRES)
			ZBA->(ZBA_DESCON)	:= 		TRBZBA->(E1_DECRESC)
			ZBA->(ZBA_SLDESC)	:= 		TRBZBA->(E1_SDDECRE)
			ZBA->(ZBA_VALOR)	:=		TRBZBA->(E1_VALOR)
			ZBA->(ZBA_SALDO)	:=		TRBZBA->(E1_SALDO)
			ZBA->(ZBA_EMISS)	:= 		TRBZBA->(E1_EMISSAO)
			ZBA->(ZBA_VENORI)	:=		TRBZBA->(E1_VENCORI)
			ZBA->(ZBA_VENCTO)	:= 		TRBZBA->(E1_VENCTO)
			ZBA->(ZBA_BAIXA)	:= 		TRBZBA->(E1_BAIXA)
			ZBA->(ZBA_VENCRE)	:= 		TRBZBA->(E1_VENCREA)
			ZBA->(msunlock())
			TRBZBA->(DbSkip())
		enddo
	endif
	MessageBox("[Aviso] Sincronizado SE1xZBA!", "Aviso", 48)

return (lRet)


User Function fDelRel()
	local cArea		:= GetArea()
	local cAreaSE1	:= SE1->(GetArea())
	local cAreaZBA	:= ZBA->(GetArea())
	local aPergs 		:= {}
	local aRet 		:= {}
	local aCab		:= {}
	local aItens		:= {}
	local cEmail		:= "ctasreceber@cobrecom.com.br"
	local cEmailOk	:= "ctasreceber@cobrecom.com.br"
	local cRetorno	:= ""
	local lRet		:= .T.
	local cSQL		:= ""
	local oExec		:= Nil
	local aExecRet	:= {}

	DbSelectArea("ZBA")
	ZBA->(DbOrderNickName("RELAT"))
	DbSelectArea("SE1")
	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbSetOrder(1))
	DbSelectArea("SE5")
	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	SE5->(DbSetOrder(7))
	aAdd(aPergs,{01,"Cancelar Relatorio",space(6),"","","","",50,.T.} )
	if ParamBox(aPergs,"Informe Nro. Relatorio para cancelamento...",@aRet)
		
		//Validações quanto aos relatorios de baixa
		if ZBA->(DbSeek(xFilial("ZBA") + aRet[1],.F.))

			While ZBA->(ZBA_NROREL) == aRet[1] .And. ZBA->(!Eof())
				If SE1->(DbSeek(xFilial("SE1") +ZBA->(ZBA_PREFIX + ZBA_NUM + ZBA_PARC + ZBA_TIPO ),.F.))
					//O Campo E1_SITUACA = F define que titulo foi protestado					
					if  Alltrim(ZBA->(ZBA_OPER)) == "BAIXAR E DEBITAR PROTESTO" .And. SE1->(E1_SITUACA) $ 'F'
						MessageBox("[Aviso] - Para cancelar o relatorio Nro. " +Alltrim(ZBA->(ZBA_NROREL)) +;
							" é necessario transferir os titulos da carteira F(Protesto) para outra ", "Aviso", 48)
						Return
						//E1_BAIXA ( Vazio = Não baixado ou cancelado )
						//E1_SALDO ( Igual 0 foi baixado completo )
					elseIf "DESC. NÃO DEBITAR" $ ZBA->(ZBA_OPER) .Or. "DESCONTO" $ ZBA->(ZBA_OPER)
						oSql 		:= LibSqlObj():newLibSqlObj()
						oSql:newTable("SE5", "E5_NUMERO+E5_PARCELA+E5_CLIFOR+E5_LOJA ID ",;
							"%SE5.XFILIAL% AND E5_DOCUMEN IN ("+;
							"'" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_LOJA   ) + "' )" + ;
							" AND E5_TIPODOC IN ('CP','BA') ")
						if oSql:hasRecords()
							cMsg := "[Aviso] - Para cancelar o relatorio Nro. " + Alltrim(ZBA->(ZBA_NROREL)) +;
								" é necessario cancelar as compensações dos titulos: " + CRLF
							while oSql:notIsEof()
								cMsg += Alltrim( oSql:getValue("ID") + CRLF )
								oSql:skip()
							enddo
							MessageBox(cMsg, "Aviso", 48)
							return(nil)
						endif
						oSql:close()
						FreeObj(oSql)
					elseif "BAIXAR" $ ZBA->(ZBA_OPER)

						if !Empty(SE1->(E1_BAIXA))
							MessageBox("[Aviso] - Para cancelar o relatorio Nro. " +Alltrim(ZBA->(ZBA_NROREL)) +;
								" é necessario cancelar a baixa dos titulos deste relatorio ", "Aviso", 48)
							Return Nil
						endif
						if SE5->(DbSeek(xFilial("SE5") +SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA   ),.F.))
							while SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA);
									== SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA   ) .And. !Eof()
								if SE5->(E5_TIPODOC) $ 'BA//VL//CP//' .And. Alltrim(SE5->(E5_HISTOR)) $ Alltrim(ZBA->(ZBA_NROREL))
									MessageBox("[Aviso] - Para cancelar o relatorio Nro. " +Alltrim(ZBA->(ZBA_NROREL)) +;
										" é necessario cancelar a baixa/compensações (não estornar) dos titulos deste relatorio - [SE5] ", "Aviso", 48)
									return(Nil)
								endif
								SE5->(DbSkip())
							enddo
						endif
					endif
				endif
				ZBA->(DbSkip())
			enddo
		else
			MessageBox("[Aviso] - O relatorio Nro. " +Alltrim(aRet[1]) +;
				" não foi encontrado, favor verificar! ", "Aviso", 48)
			Return Nil
		endif

		if Select( "DELCT2") > 0
			DELCT2->(dbcloseArea())
			FErase( "DELCT2" + GetDbExtension())
		endif

		cSQL += " AND ZBA.ZBA_NROREL = '" + aRet[1] + "'"
		cSQL += " AND CT2.CT2_TPSALD = '6'  "
		cSQL += " AND CT2.CT2_LOTE = '028850'  "
		cSQL := "%"+cSQL+"%"

		BeginSQL Alias "DELCT2"
			column CT2_DATA 	as Date
			SELECT	DISTINCT(CT2.CT2_DOC),
			ZBA.ZBA_OPER,
			CT2.CT2_DATA,
			CT2.CT2_HIST,
			CT2.CT2_VALOR,
			CT2.CT2_CLVLDB,
			CT2.CT2_CLVLCR

			FROM %Table:ZBA% ZBA
			INNER JOIN %Table:CT2% CT2  ON ZBA.ZBA_NROREL = CT2_DOC
			AND ZBA.D_E_L_E_T_ = CT2.D_E_L_E_T_
			WHERE ZBA.ZBA_FILIAL = %xFilial:ZBA%
			%exp:cSQL%
			AND ZBA.%NotDel%
		EndSql

		DELCT2->(DbGoTop())

		BeginTran()
			if DELCT2->(!EOF())
				aCab := 	{ 	{'DDATALANC' 	,dDataBase 								,NIL},;
					{'CLOTE' 		,"028850" 									,NIL},;
					{'CSUBLOTE' 	,'002' 											,NIL},;
					{'CDOC' 		, aRet[1] 										,NIL},;
					{'CPADRAO' 		,'' 											,NIL},;
					{'NTOTINF' 		,0 											,NIL},;
					{'NTOTINFLOT' 	,0 											,NIL} }

				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")   				, NIL},;
					{'CT2_LINHA'		, 01 										, NIL},;
					{'CT2_MOEDLC'  	,'01'   										, NIL},;
					{'CT2_DC'   		,'3'   										, NIL},;
					{'CT2_DEBITO'  	,'DEB' 										, NIL},;
					{'CT2_CREDIT'  	,'CRE' 										, NIL},;
					{'CT2_VALOR'  	, DELCT2->(CT2_VALOR)  						, NIL},;
					{'CT2_ORIGEM' 	,'CANCEL.RELAT'								, NIL},;
					{'CT2_HP'   		,''   										, NIL},;
					{'CT2_EMPORI'   	,'01'   										, NIL},;
					{'CT2_FILORI'   	,XFilial("SE1")   							, NIL},;
					{'CT2_TPSALD'   	,'6'   										, NIL},;
					{'CT2_CLVLDB'   	,DELCT2->(CT2_CLVLCR)   						, NIL},;
					{'CT2_CLVLCR'   	,DELCT2->(CT2_CLVLDB)   						, NIL},;
					{'CT2_HIST'   	,'CANCELADO RELAT. NRO. ' + aRet[1]				, NIL} } )

				oExec := cbcExecAuto():newcbcExecAuto(aItens,aCab)
				oExec:exAuto('CTBA102',3)

				aExecRet := oExec:getRet()
				if !aExecRet[1]
					u_envmail({cEmail}, "[Erro] - MSExecAuto - Deletar relotorio " + aRet[1] + " Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Ctba102",cValToChar(ProcLine(0)),"fDelRel()","MANUTENCAOTITULOS.PRW",aExecRet[2]}} )
					lRet := .F.
				endif
				FreeObj(oExec)
			endif

		// desfazer alteraçâo no se1
			if ZBA->(DbSeek(xFilial("ZBA") + aRet[1] ,.F.)) .And. lRet
				While ZBA->(ZBA_NROREL) == aRet[1] .And. ZBA->(!Eof())

					if SE1->( DbSeek(xFilial("SE1") + ZBA->(ZBA_PREFIX + ZBA_NUM + ZBA_PARC + ZBA_TIPO ),.F.))
						if exOper(ZBA->(ZBA_OPER),aRet[1], ZBA->(Recno()) )
							reclock("ZBA", .F.)
							ZBA->(DbDelete())
							ZBA->(msunlock())
						else
							DisarmTransaction()
							lRet := .F.
							u_envmail({cEmail}, "[Erro] - Cancelar Operação Rel. -  " + aRet[1] + " Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Cancelar",cValToChar(ProcLine(0)),"fDelRel()","MANUTENCAOTITULOS.PRW","Erro ao cancelar operação"}} )
							Exit
						endif

					// Não achou titulo ZBA no SE1 - Integridade Todos devem existir
					else
						DisarmTransaction()
						lRet := .F.
						u_envmail({cEmail}, "[Erro] - Integridade ZBAxSE1 Rel. -  " + aRet[1] + " Fin-Receber", {"Rotina","Linha","Função","Fonte","Obs"},{{"Cancelar",cValToChar(ProcLine(0)),"fDelRel()","MANUTENCAOTITULOS.PRW","DbSeek não achou SE1, do ZBA"}} )
						Exit
					endif
					ZBA->(DbSkip())
				EndDo
			endif

			if lRet
			EndTran()
			MsUnlockAll()
	
			cRetorno += "Relatorio manutenção de titulos Nro. " + aRet[1] + CRLF
			cRetorno += "Emitido em: " + cValToChar(DELCT2->(CT2_DATA)) + CRLF + CRLF
			cRetorno += "Foi excluido pelo usuário: " + Alltrim(Upper(cUserName)) + CRLF
			cRetorno += "Em: " + cValToChar(Date()) + CRLF + CRLF
			u_envmail({cEmailOk}, "[Sucesso] - Relatorio Nro. - " + aRet[1] + " cancelado,(Fin-Receber)", {"Rotina","Linha","Função","Fonte","Obs"},{{"Concluido",cValToChar(ProcLine(0)),"fDelRel()","MANUTENCAOTITULOS.PRW",cRetorno}} )
	
			MessageBox("[Sucesso] - O relatorio Nro. " +Alltrim(aRet[1]) +;
				" foi excluido corretamente! ", "Aviso", 48)
		endif
	endif

	RestArea(cAreaZBA)
	RestArea(cAreaSE1)
	RestArea(cArea)

return (lRet)


/*/{Protheus.doc} exOper
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
/*/
static function exOper(cOper,cNroRel, nRecno)
	local cArea			:= GetArea()
	local cAreaSE1		:= SE1->(GetArea())
	local cAreaZBA		:= ZBA->(GetArea())
	local lRet 			:= .T.
	local nRcnOp		:= 0
	local nRcnGr        := 0
	
	// Vem posicionado nos Registros ZBA e SE1 corretos
	nRcnOp 	:= maior(ZBA->(ZBA_DTREL),cOper,'OPER')
	nRcnGr	:= maior(ZBA->(ZBA_DTREL),cOper,'GERAL')

	if "DESCONTO" $ cOper .or. "DESC. NÃO DEBITAR" $ cOper
		reclock("SE1", .F. )
		// Excluir movimentações no titulo referente ao desconto
		if !empty(SE1->(E1_SDDECRE))
			SE1->(E1_SDDECRE) := (SE1->(E1_SDDECRE) - ZBA->(ZBA_DESCON) )
		endif
		// Quando relatorio a excluir é o ultimo feito ( Tem que voltar informações SE1 para ultimo imediatamente anterior ) 
		if Alltrim( SE1->(E1_ZZBXDB) ) == Alltrim(ZBA->ZBA_NROREL)

			// Posicionar ultimo da operação DESCONTO
			if nRcnOp > 0
				ZBA->(DbGoto(nRcnOp) )
				SE1->(E1_DECRESC) 		:= ZBA->(ZBA_DESCON)
			endif

			// Atualizar dados no titulo referenciando ultimo relatorio feito
			if nRcnGr > 0
				ZBA->(DbGoto(nRcnGr))
				SE1->(E1_ZZBXDB)		:= ZBA->(ZBA_NROREL)
				SE1->(E1_ZZOPER)		:= ZBA->(ZBA_OPER)
				SE1->(E1_ZZDTREL)		:= ZBA->(ZBA_DTREL)
				SE1->(E1_ZZHISBX)		:= ZBA->(ZBA_HISTOP)
			else
				SE1->(E1_ZZBXDB)		:= ""
				SE1->(E1_ZZOPER)		:= ""
				SE1->(E1_ZZDTREL)		:= CtoD("")
				SE1->(E1_ZZHISBX)		:= ""
			endif
		else
			SE1->(E1_DECRESC) 		:= SE1->(E1_SDDECRE)
		endif
		SE1->(msunlock())

	elseif "PRORROGACAO" $ cOper

		reclock("SE1", .F.)
		If Alltrim( SE1->(E1_ZZBXDB) ) == Alltrim(ZBA->ZBA_NROREL)
			// Existe relatorio anterior com a mesma operação.
			if nRcnOp > 0
				ZBA->(DbGoto(nRcnOp) )
				SE1->(E1_VENCTO)	:= ZBA->(ZBA_VENCTO)
				SE1->(E1_VENCREA)	:= ZBA->(ZBA_VENCRE)
			endif
			if nRcnGr > 0
				ZBA->(DbGoto(nRcnGr))
				SE1->(E1_VENCTO)		:= ZBA->(ZBA_VENCTO)
				SE1->(E1_VENCREA)		:= ZBA->(ZBA_VENCRE)
				SE1->(E1_ZZOPER)		:= ZBA->(ZBA_OPER)
				SE1->(E1_ZZBXDB) 		:= ZBA->(ZBA_NROREL)
				SE1->(E1_ZZDTREL) 		:= ZBA->(ZBA_DTREL)
				SE1->(E1_ZZHISBX)		:= ZBA->(ZBA_HISTOP)
			else
				SE1->(E1_VENCTO)		:= SE1->(E1_VENCORI)
				SE1->(E1_VENCREA)      := SE1->(E1_VENCORI)
				SE1->(E1_ZZBXDB)		:= ""
				SE1->(E1_ZZOPER)		:= ""
				SE1->(E1_ZZDTREL)		:= CtoD("")
				SE1->(E1_ZZHISBX)		:= ""
			endif
		endif
		
		SE1->(msunlock())

	elseif "SUBSTITUIR" $ cOper

	elseif "BAIXAR" $ cOper

		reclock("SE1", .F.)
		// Verificar se é o ultimo relatorio (sempre é o ultimo) alerta no If
		if Alltrim( SE1->(E1_ZZBXDB) ) == Alltrim(ZBA->ZBA_NROREL)
			// Tem um relatorio anterior? (volta as informações para ele)
			if nRcnGr > 0
				ZBA->(DbGoto(nRcnGr))
				SE1->(E1_VENCTO)		:= ZBA->(ZBA_VENCTO)
				SE1->(E1_VENCREA)		:= ZBA->(ZBA_VENCRE)
				SE1->(E1_ZZOPER)		:= ZBA->(ZBA_OPER)
				SE1->(E1_ZZBXDB) 		:= ZBA->(ZBA_NROREL)
				SE1->(E1_ZZDTREL) 	:= ZBA->(ZBA_DTREL)
				SE1->(E1_ZZHISBX)		:= ZBA->(ZBA_HISTOP)
				SE1->(E1_SDACRES)		:= ZBA->(ZBA_SDACRE)
				SE1->(E1_DECRESC)		:= ZBA->(ZBA_DESCON)
				SE1->(E1_SDDECRES)	:= ZBA->(ZBA_SLDESC)
				SE1->(E1_VALOR)		:= ZBA->(ZBA_VALOR)
				SE1->(E1_SALDO)		:= ZBA->(ZBA_SALDO)
			else
				SE1->(E1_ZZBXDB)		:= ""
				SE1->(E1_ZZOPER)		:= ""
				SE1->(E1_ZZDTREL)		:= CToD("")
				SE1->(E1_ZZHISBX)		:= ""
				SE1->(E1_SDACRES)		:= 0
				SE1->(E1_DECRESC)		:= 0
				SE1->(E1_SDDECRES)		:= 0
			endif
		endif
	else
		Alert("Operação selecionada: " + cOper + " do relatorio Nro.: " + cNroRel + " não encontrada")
		lRet := .F.
	endif

	ZBA->(DbGoTo(nRecno))
	RestArea(cAreaZBA)
	RestArea(cAreaSE1)
	RestArea(cArea)
	
return (lRet)


/*/{Protheus.doc} maior
(long_description)
@type function
@author bolognesi
@since 16/03/2018
@version 1.0
/*/
static function maior(dDtRel,cOper, cTipo)
	local aArea		:= GetArea()
	local cQuery 		:= ""
	local nRet		:=0

	if Select("LAST") > 0
		DbSelectArea("LAST")
		LAST->(dbclosearea())
		FErase( "LAST" + GetDbExtension())
	endif

	cQuery +=  " SELECT TOP(1) 			"
	cQuery +=  " R_E_C_N_O_ AS RCN    	"
	cQuery +=  " FROM "+RetSqlName("ZBA")
	cQuery +=   " WHERE ZBA_FILIAL IN ('" + xFilial("ZBA") 	+ "')"
	cQuery +=   " AND ZBA_PREFIX = '" +ZBA->(ZBA_PREFIX)   	+"'"
	cQuery +=   " AND ZBA_NUM	 = '" +ZBA->(ZBA_NUM)   	+"'"
	cQuery +=   " AND ZBA_PARC	 = '" +ZBA->(ZBA_PARC)   	+"'"
	cQuery +=   " AND ZBA_TIPO	 = '" +ZBA->(ZBA_TIPO)  	+"'"
	cQuery +=   " AND ZBA_CLI	 = '" +ZBA->(ZBA_CLI)   	+"'"
	cQuery +=   " AND ZBA_LOJA	 = '" +ZBA->(ZBA_LOJA)   	+"'"
	cQuery +=   " AND ZBA_NROREL <> ''

	if cTipo == "OPER"
		cQuery +=   " AND ZBA_OPER =  '" + cOper +"'"
	endif

	cQuery +=   " AND (ZBA_DTREL <> '' AND ZBA_DTREL < '" + DToS(dDtRel) +"')"
	cQuery +=   " AND D_E_L_E_T_ <> '*' "
	cQuery +=   " ORDER BY ZBA_DTREL DESC"
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),  'LAST', .F., .T.)
	LAST->(DbGoTop())
	if LAST->(!EOF())
		nRet := LAST->(RCN)
	endif
	LAST->(dbCloseArea())
	FErase( "LAST" + GetDbExtension())
	RestArea(aArea)
return (nRet)
