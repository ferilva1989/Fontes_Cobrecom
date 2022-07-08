#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#include 'cbcManutTit.ch'

static clear 		:= .F.
static oBrw		:= nil
static newManut 	:= GetNewPar('ZZ_TITMANT', .T.)


/*/{Protheus.doc} zOpTiMan
@type function
@author bolognesi
@since 16/07/2018
@Description Função pricipal, que inicia os modelos de dados
e suas opções.,
/*/
user function zOpTiMan()
	local oExecView 	:= nil
	local oMdl		:= nil
	local oView		:= nil
	private lAltera	:= .F.
	
	if newManut
		DbSelectArea('SA1')
		oMdl 		:= ModelDef()
		oView		:= ViewDef(oMdl)
		
		oExecView 	:= FWViewExec():New()
		oExecView:setTitle('Manutenção Titulos Cliente')
		oExecView:setOperation(MODEL_OPERATION_VIEW)
		oExecView:setCloseOnOK( { ||.T. } )
		oExecView:setOK( { ||.T. } )
		oExecView:setModel(oMdl)
		oExecView:setView(oView)
		oExecView:openView(.T.)
		
		FreeObj(oMdl)
		FreeObj(oView)
		FreeObj(oExecView)
	endif
return(nil)


/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Definição do modelos de dados
/*/
static function ModelDef()
	local oStrSA1 		:= FWFormStruct( 1, 'SA1', {|campo| filterMod(campo, 'CLIENTE')} )
	local aRelCliTit	:= {}
	local oStrSE1 		:= FWFormStruct( 1, 'SE1', {|campo| filterMod(campo, 'TITULO')} )
	local aRelTit		:= {}
	local oStruZBA 		:= FWFormStruct( 1, 'ZBA', {|campo| filterMod(campo, 'RELAT')} )
	local aRelNcc		:= {}
	local oStrSE1NCC	:= FWFormStruct( 1, 'SE1' , {|campo| filterMod(campo, 'TITULO')} )
	local oModel		:= nil
	local aSx3			:= TamSx3('E1_SALDO')
	Local oStatic    	:= IfcXFun():newIfcXFun()
	
	oModel := MPFormModel():New('MANUTTITULO')
	oModel:SetOnDemand(.T.)
	
	// oStru, cNome, cTitulo, cTipo, nTam, nDec
	addMdlFld(oStrSE1, 'SALDO', 'Saldo Titulo', 'N', aSx3[1], aSx3[2])
	oStrSE1:SetProperty('SALDO', MODEL_FIELD_INIT, {|oModel| oStatic:sP(1):callStatic('cbcClientTitManut', 'initSaldo', oModel)})
	
	addMdlFld(oStrSE1NCC, 'SALDO', 'Saldo Titulo', 'N', aSx3[1], aSx3[2])
	oStrSE1NCC:SetProperty('SALDO', MODEL_FIELD_INIT, {|oModel| oStatic:sP(1):callStatic('cbcClientTitManut', 'initSaldo', oModel)})
	
	oModel:AddFields('SA1_CLIENTE_MASTER'	,/*cOwner*/,oStrSA1)
	oModel:AddGrid('SE1_TITULOS_GRID'		,'SA1_CLIENTE_MASTER',oStrSE1)
	oModel:AddGrid('SE1_NCC_GRID'			,'SA1_CLIENTE_MASTER',oStrSE1NCC)
	oModel:AddGrid('ZBA_MOVIMENTO_GRID'		,'SA1_CLIENTE_MASTER',oStruZBA)
	
	// Campos totais
	oModel:AddCalc( 'SE1_TITULO_CALCULO', 'SA1_CLIENTE_MASTER',;
		'SE1_TITULOS_GRID', 'E1_SALDO', 'TOTAL_TITULO', 'SUM', { | oFW | .T. },,'Saldo' )
	
	oModel:AddCalc( 'SE1_NCC_CALCULO', 'SA1_CLIENTE_MASTER',;
		'SE1_NCC_GRID', 'E1_SALDO', 'TOTAL_NCC', 'SUM', { | oFW | .T. },,'Saldo' )
	
	// Todos são somente visualização
	oModel:GetModel('SA1_CLIENTE_MASTER'):SetOnlyView(.T.)
	oModel:GetModel('SE1_TITULOS_GRID'):SetOnlyView(.T.)
	oModel:GetModel('SE1_NCC_GRID'):SetOnlyView(.T.)
	oModel:GetModel('ZBA_MOVIMENTO_GRID'):SetOnlyView(.T.)
	
	oModel:GetModel('SE1_TITULOS_GRID'):lForceLoad	:= .T.
	
	// Models que não são obrigatorios
	oModel:GetModel('SE1_TITULOS_GRID'):SetOptional(.T.)
	oModel:GetModel('SE1_NCC_GRID'):SetOptional(.T.)
	oModel:GetModel('ZBA_MOVIMENTO_GRID'):SetOptional(.T.)
	
	// Pre
	oModel:GetModel('ZBA_MOVIMENTO_GRID'):SetlPre({|oModelGrid|MVCd3PrOK(oModelGrid,'ZBA_MOVIMENTO_GRID')})
	
	// Pos
	oModel:GetModel('ZBA_MOVIMENTO_GRID'):SetlPost({|oModelGrid| MVCd3LOK(oModelGrid,'ZBA_MOVIMENTO_GRID')})
	
	// Relacionamento Titulo com Cliente
	aAdd(aRelCliTit,  { 'E1_CLIENTE'			, 'A1_COD'} )
	aAdd(aRelCliTit,  { 'E1_LOJA'				, 'A1_LOJA'} )
	oModel:SetRelation('SE1_TITULOS_GRID'		, aRelCliTit, SE1->(IndexKey(1)))
	oModel:GetModel('SE1_TITULOS_GRID' ):SetLoadFilter({ ;
		{'E1_TIPO', "'NCC'", MVC_LOADFILTER_NOT_EQUAL },;
		{'E1_ZZBC2', "{'000','NNN'}", MVC_LOADFILTER_IS_CONTAINED},;
		{'E1_SALDO', "0", MVC_LOADFILTER_GREATER}})
	
	// Relacionamento Relatorios com Titulos
	aAdd(aRelTit,  {'ZBA_CLI'			, 'A1_COD'} )
	aAdd(aRelTit,  {'ZBA_LOJA'			, 'A1_LOJA'} )
	oModel:SetRelation('ZBA_MOVIMENTO_GRID'	, aRelTit, ZBA->(IndexKey(1)))
	oModel:GetModel('ZBA_MOVIMENTO_GRID' ):SetLoadFilter({ ;
		{'ZBA_NROREL', "''", MVC_LOADFILTER_NOT_EQUAL}})
	
	// Relacionamento Cliente com Titulos NCC
	aAdd(aRelNcc,  {'E1_CLIENTE'		, 'A1_COD'} )
	oModel:SetRelation('SE1_NCC_GRID'	, aRelNcc, SE1->(IndexKey(1)))
	oModel:GetModel('SE1_NCC_GRID' ):SetLoadFilter({ ;
		{'E1_TIPO', "'NCC'" },;
		{'E1_SALDO', "0", MVC_LOADFILTER_GREATER} } )
	
	oModel:SetPrimaryKey({})
	
	// Definindo a descrição dos models
	oModel:GetModel('SA1_CLIENTE_MASTER'):SetDescription( 'Cliente' )
	oModel:GetModel('SE1_TITULOS_GRID'):SetDescription( 'Titulos' )
	oModel:GetModel('ZBA_MOVIMENTO_GRID'):SetDescription( 'Relatorios' )
	oModel:GetModel('SE1_NCC_GRID'):SetDescription( 'Titulos NCC' )
	
return(oModel)


/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Visualização para os modelos de dados
/*/
static Function ViewDef(oMdl)
	local oView			:= nil
	local oTotal 			:= nil
	local oTotNCC			:= nil
	local oStrSA1  		:= FWFormStruct(2, 'SA1' , {|campo| filterView(campo, 'CLIENTE')})
	local oStrSE1  		:= FWFormStruct(2, 'SE1' , {|campo| filterView(campo, 'TITULO')} )
	local oStrSE1NCC  	:= FWFormStruct(2, 'SE1' , {|campo| filterView(campo, 'TITULO')})
	local oStruZBA 		:= FWFormStruct(2, 'ZBA' , {|campo| filterView(campo, 'RELAT')})
	default oMdl        	:= FWLoadModel('cbcClientTitManut')
	
	oTotal := FWCalcStruct( oMdl:GetModel( 'SE1_TITULO_CALCULO') )
	oTotNCC := FWCalcStruct( oMdl:GetModel( 'SE1_NCC_CALCULO') )
	
	oView := FWFormView():New()
	oView:SetModel(oMdl)
	oView:SetProgressBar(.T.)
	
	addViewFld(oStrSE1, 'SALDO', '5', 'Saldo Titulo', 'N', PesqPict('SE1','E1_SALDO'))
	addViewFld(oStrSE1NCC, 'SALDO', '5', 'Saldo Titulo', 'N', PesqPict('SE1','E1_SALDO'))
	
	oView:AddField('CLIENTE_MASTER'	,oStrSA1			,'SA1_CLIENTE_MASTER')
	oView:AddField('TITULO_TOTAL'	,oTotal			,'SE1_TITULO_CALCULO' )
	oView:AddGrid('TITULO_GRID'	,oStrSE1			,'SE1_TITULOS_GRID')
	oView:AddField('NCC_TOTAL'		,oTotNCC			,'SE1_NCC_CALCULO' )
	oView:AddGrid('MOVIMENTO_GRID'	,oStruZBA		,'ZBA_MOVIMENTO_GRID')
	oView:AddGrid('NCC_GRID'		,oStrSE1NCC 		,'SE1_NCC_GRID')
	
	// Parte de cima com browser e informações sobre clientes
	oView:CreateHorizontalBox('HB_TITULO_MASTER',39)
	oView:CreateVerticalBox( 'BRW_GRID_V'	, 50, 'HB_TITULO_MASTER',,,)
	oView:CreateVerticalBox( 'MASTER_GRID_V'	, 50, 'HB_TITULO_MASTER',,,)
	oView:SetOwnerView('CLIENTE_MASTER','MASTER_GRID_V')
	oView:AddOtherObject("BROWSER", {|oPanel| browser(oPanel)},{|oPanel| .T.} )
	oView:SetOwnerView("BROWSER",'BRW_GRID_V')
	oView:EnableTitleView('BROWSER','Clientes')
	
	// Divisão central
	oView:CreateHorizontalBox('HB_CONTAINER_VERTICAL',49)
	
	// Nova divisão na parte da direita
	oView:CreateVerticalBox('TITULO_GRID_V'		, 50, 'HB_CONTAINER_VERTICAL',,,)
	oView:CreateHorizontalBox('TITULO_GRID_H'	, 100, 'TITULO_GRID_V',,,)
	
	// Atribui a visualização dos titulos (Esquerda)
	oView:SetOwnerView('TITULO_GRID','TITULO_GRID_H')
	
	// Adiciona a diretira a visualização de relatorios e de titulos de NCC
	oView:CreateVerticalBox( 'MOVIMENTO_GRID_V'	, 50, 'HB_CONTAINER_VERTICAL',,,)
	oView:CreateFolder( 'FOLDER_DETAILS', 'MOVIMENTO_GRID_V')
	oView:AddSheet('FOLDER_DETAILS','SHEET_RELATORIO','Relatorio')
	oView:AddSheet('FOLDER_DETAILS','SHEET_NCC','Titulos NCC')
	oView:CreateHorizontalBox( 'GRID_MOVIMENTO'	, 100,,,'FOLDER_DETAILS', 'SHEET_RELATORIO')
	oView:CreateHorizontalBox( 'GRID_NCC'		, 100,,,'FOLDER_DETAILS', 'SHEET_NCC')
	oView:SetOwnerView('MOVIMENTO_GRID','GRID_MOVIMENTO')
	oView:SetOwnerView('NCC_GRID','GRID_NCC')
	
	// Posicionamento dos totais
	oView:CreateHorizontalBox('HB_TOTAIS',10)
	oView:CreateVerticalBox( 'SOMA_TIT_GRID_V'	,50, 'HB_TOTAIS',,,)
	oView:CreateVerticalBox( 'SOMA_NCC_GRID_V'	,50, 'HB_TOTAIS',,,)
	oView:SetOwnerView('TITULO_TOTAL','SOMA_TIT_GRID_V')
	oView:SetOwnerView('NCC_TOTAL','SOMA_NCC_GRID_V')
	
	oView:EnableTitleView('CLIENTE_MASTER','Detalhe Cliente')
	oView:EnableTitleView('TITULO_GRID','Titulo a Receber')
	oView:EnableTitleView('TITULO_TOTAL','Titulos')
	oView:EnableTitleView('NCC_TOTAL','Titulos NCC')
	
	oView:SetViewProperty('TITULO_GRID', "GRIDSEEK", {.T.})
	oView:SetViewProperty('NCC_GRID', "GRIDSEEK", {.T.})
	oView:SetViewProperty('MOVIMENTO_GRID', "GRIDSEEK", {.T.})
	
	oView:SetViewProperty("TITULO_GRID"	, "SETCSS", defCss() )
	oView:SetViewProperty("NCC_GRID"	, "SETCSS", defCss() )
	
	oView:SetViewProperty("MOVIMENTO_GRID", "GRIDDOUBLECLICK", {{|oFrm,cFld,nLin,nLinMdl| dblClkRela(oFrm,cFld,nLin,nLinMdl)}})
	oView:SetViewProperty("TITULO_GRID", "GRIDDOUBLECLICK", {{|oFrm,cFld,nLin,nLinMdl| dblClkTit(oFrm,cFld,nLin,nLinMdl)}})
	
	// Opções disponibilizadas
	oView:AddUserButton('Pos.Cliente'		, 'CLIPS', {|oView| doTheMenu("Pos") 	})
	oView:AddUserButton('Baixar'			, 'CLIPS', {|oView| doTheMenu("Bx") 	})
	oView:AddUserButton('Desconto'			, 'CLIPS', {|oView| doTheMenu("Desc")	})
	oView:AddUserButton('Prorrogar'			, 'CLIPS', {|oView| doTheMenu("Prorr")	})
	oView:AddUserButton('Comp.NCC'			, 'CLIPS', {|oView| doTheMenu("Ncc")	})
	oView:AddUserButton('Transf.'			, 'CLIPS', {|oView| doTheMenu("Transf")	})
	oView:AddUserButton('Gerar Relatorio'	, 'CLIPS', {|oView| doTheMenu("Relat")	})
	oView:AddUserButton('Anot.Incluir'		, 'CLIPS', {|oView| doTheMenu("AnotI")	})
	oView:AddUserButton('Anot.Visualiza'	, 'CLIPS', {|oView| doTheMenu("AnotV")	})
	oView:AddUserButton('Relat. Gerados'	, 'CLIPS', {|oView| doTheMenu("GerR")	})
	
	oView:SetCloseOnOk({||.T.})
return(oView)


/*/{Protheus.doc} defCss
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Definições para aplicação de estilo CSS
/*/
static function defCss()
	local cCSS := ''
	cCSS += 'QTableView{selection-background-color: #1C9DBD;}'
return({cCSS})


/*/{Protheus.doc} browser
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Montagem do browser de clientes acima
/*/
static function browser(oPanel)
	oBrw := FWMBrowse():New()
	oBrw:SetFilial({FwFilial()})
	oBrw:SetAlias('SA1')
	oBrw:SetOnlyFields({'A1_COD' , 'A1_LOJA', 'A1_NOME', 'A1_CGC'})
	oBrw:DisableDetails(.T.)
	oBrw:SetUseCaseFilter(.T.)
	oBrw:SetDoubleClick({||FWMsgRun(,{|oSay| reloadBrw()},"Atualizando","Atualizando...")})
	oBrw:SetChange ({||FWMsgRun(,{|oSay| clearBrw()},"Atualizando","Atualizando...")})
	oBrw:SetWalkThru(.F.)
	oBrw:SetMenuDef('')
	oBrw:Activate(oPanel)
return(nil)


/*/{Protheus.doc} doTheMenu
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Direciona as opções de menu para respectivas funções
/*/
static function doTheMenu(cFrom)
	local aOpc		:= {}
	local nPos		:= 0
	local oView		:= FWViewActive()
	local oMdl		:= nil
	private cCmd		:= ''
	private oCtrl 	:= cbcTitManut():newcbcTitManut()
	default cFrom		:= ''
	
	if !empty(cFrom)
		aadd( aOpc, {'Pos'	, 'verCli()'							,'Posição Cliente'		, .F.,.F.})
		aadd( aOpc, {'Bx'		, 'oCtrl:proxyOper("baixar",oView)'		,'Baixar'				, .T.,.T.})
		aadd( aOpc, {'Desc'	, 'oCtrl:proxyOper("desconto",oView)'	,'Desconto'				, .T.,.T.})
		aadd( aOpc, {'Prorr'	, 'oCtrl:proxyOper("prorrogar",oView)'	,'Prorrogação'			, .T.,.T.})
		aadd( aOpc, {'Ncc'	, 'oCtrl:proxyOper("NCC",oView)'		,'Comp.NCC'				, .T.,.T.})
		aadd( aOpc, {'Transf'	, 'oCtrl:proxyOper("TRANS",oView)'		,'Transferencia'			, .T.,.T.})
		aadd( aOpc, {'Relat'	, 'oCtrl:goRelat(oView)'				,'Relatorios'				, .F.,.T.})
		aadd( aOpc, {'AnotI'	, 'CRMA090(3,"SA1")'					,'Incluir Anotação'		, .F.,.F.})
		aadd( aOpc, {'AnotV'	, 'CRMA090(,"SA1")'					,'Visualizar Anotações'	, .F.,.F.})
		aadd( aOpc, {'GerR'	, 'FwLoadBrw("cbcZBAModel")'			,'Relatorios Gerados'		, .F.,.T.})
		
		if ( nPos := aScan(aOpc, {|aOpc| Alltrim(aOpc[1]) == Alltrim(cFrom) }) ) > 0
			cCmd := aOpc[nPos,2]
			FWMsgRun(, {|oSay| &cCmd }, "Processando", "Processando a rotina... " + aOpc[nPos,3])
			
			if aOpc[nPos,5]
				reloadMdl(oView:getModel())
				oView:Refresh()
			endif
			
			if !oCtrl:lOk
				Help( ,, 'Help','Erro', oCtrl:cMsgErr, 1, 0 )
			else
				if aOpc[nPos,4]
					MessageBox('Operação ' + aOpc[nPos,3] +' Concluida', 'Sucesso', 0 )
				endif
			endif
		endif
	endif
	FreeObj(oCtrl)
return(nil)



/*/{Protheus.doc} clearBrw
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Utilizado para limpar as informações quando
muda o registro do browser do cliente, evitando que browser
do cliente permanece selecionado e os outros elementos não correspondam
com a seleção.
/*/
static function clearBrw()
	local aArea := SA1->(GetArea())
	if clear
		SA1->(DbGoTop())
		reloadBrw()
		clear := .F.
		oBrw:SetFocus()
	endif
	RestArea(aArea)
return(nil)


/*/{Protheus.doc} reloadBrw
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Realiza o reload do modelo e reload
da view, para correta visualização.
/*/
static function reloadBrw()
	local oView		:= FWViewActive()
	local oMdl		:= oView:getModel("SA1_CLIENTE_MASTER")
	reloadMdl(oMdl)
	oBrw:SetFocus()
	oView:Refresh()
	clear := .T.
return(nil)


/*/{Protheus.doc} reloadMdl
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Recarrega o modelo de dados.
/*/
static function reloadMdl(oMdl)
	local aSave := FWSaveRows()
	oMdl:DeActivate()
	oMdl:Activate()
	FWRestRows(aSave)
return(nil)


/*/{Protheus.doc} dblClkRela
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Abre a janela modal para exibir o modelo cbcZBAModel
com as informações do relatorio
/*/
static function dblClkRela(oFrm,cFld,nLin,nLinMdl)
	local aArea 	:= ZBA->(GetArea())
	local nRecZba	:= 0
	if nLinMdl > 0
		if  (nRecZba := oFrm:getModel():GetDataId(nLinMdl)) > 0
			ZBA->(DbGoTo(nRecZba))
			FWExecModalView('Relatorios','cbcZBAModel', MODEL_OPERATION_VIEW, {||.T.}, {||.T.}, 600, 600)
		endif
	endif
	RestArea(aArea)
return(nil)


/*/{Protheus.doc} dblClkTit
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Abre para um SE1 posicionado a opção
de situação do titulo.
/*/
static function dblClkTit(oFrm,cFld,nLin,nLinMdl)
	local aArea 	:= SE1->(GetArea())
	local nRecSe1	:= 0
	if nLinMdl > 0
		if  (nRecSe1 := oFrm:getModel():GetDataId(nLinMdl)) > 0
			SE1->(DbGoTo(nRecSe1))
			Fc040Con()
		endif
	endif
	RestArea(aArea)
return(nil)


/*/{Protheus.doc} verCli
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description abre para o cliente a opção de consultar sua posição
/*/
static function verCli()
	private aRotina	:=  FWLoadMenuDef('MATA103')
	// FWExecModalView('Relatorios','CRMA980', MODEL_OPERATION_VIEW, {||.T.}, {||.T.}, 600, 600)
	A450F4CON()
return(nil)


/*/{Protheus.doc} initSaldo
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description obtem o saldo de um titulo SE1, utilizando função
padrão.
/*/
static function initSaldo(oMdl)
	local nSaldo	:= 0
	nSaldo := SALDOTIT( SE1->(E1_PREFIXO), SE1->(E1_NUM), SE1->(E1_PARCELA), SE1->(E1_TIPO),SE1->(E1_NATUREZ),;
		'R', SE1->(E1_CLIENTE), 1, Date(), Date(), SE1->(E1_LOJA), XFilial('SE1'), 0, 1 )
return(nSaldo)


/*/{Protheus.doc} MVCd3PrOK
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Realiza a validação de confirmação
/*/
static function MVCd3PrOK(oModel,cSubModel)
	local lRet	:= .T.
	local oModel 		:= FWModelActive()
	local oMdlDef		:= nil
	local aSaveLines		:= FWSaveRows()
	FwRestRows(aSaveLines)
return(lRet)


/*/{Protheus.doc} MVCd3LOK
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Realiza as validações de linha
/*/
static function MVCd3LOK(oModel,cSubModel)
	local aSaveLines	:= FWSaveRows()
	local oModel 		:= FWModelActive()
	local lRet		:= .T.
	FwRestRows(aSaveLines)
return(lRet)


/*/{Protheus.doc} filterMod
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Aplica o filtro na carga do modelo, carrega somente estes campos, lembre-se que se precisar
exibir(view) os campos eles devem ser adicionados na função filterView()
/*/
static function filterMod(campo, cFrom)
	local aOkFields	:= {}
	local lOk		:= .F.
	if cFrom == 'CLIENTE'
		aOkFields := {'A1_FILIAL','A1_COD','A1_LOJA', 'A1_NOME', 'A1_MUN', 'A1_EST',;
			'A1_LC', 'A1_MCOMPRA', 'A1_MSALDO', 'A1_SALDUP', 'A1_MAIDUPL','A1_EMAIL', 'A1_EMAILFI' }
		
	elseif cFrom == 'RELAT'
		aOkFields := {'ZBA_FILIAL', 'ZBA_CLI', 'ZBA_LOJA', 'ZBA_NUM','ZBA_PARC',;
			'ZBA_NROREL', 'ZBA_OPER', 'ZBA_HISTOP', 'ZBA_DTREL', 'ZBA_VALOR','ZBA_VLROPE','ZBA_VENCTO',;
			'ZBA_VENCRE','ZBA_VLRCC' }
		
	elseif cFrom == 'TITULO'
		aOkFields := {'E1_FILIAL','E1_PREFIXO','E1_NUM', 'E1_PARCELA','E1_TIPO', 'E1_CLIENTE', 'E1_LOJA',;
			'E1_NOMCLI','E1_TIPO','E1_EMISSAO', 'E1_VENCREA', 'E1_VALOR', 'E1_ZZBC2', 'E1_NATUREZ',;
			'E1_SDACRES','E1_SDDECRE', 'E1_MOEDA',' E1_SALDO', 'E1_PORTADO', 'E1_NUMBCO', 'E1_VENCORI',;
			'E1_VENCTO', 'E1_BAIXA','E1_ACRESC','E1_DECRESC', 'E1_FILORIG'}
	endif
	lOk := Ascan(aOkFields, {|a| Alltrim(a) == Alltrim(campo) }) > 0
return(lOk)


/*/{Protheus.doc} filterView
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Realiza o filtro na view para os campos desejados, para utilizar aqui deve-se verificar se o campo
aparece na função filterMod
/*/
static function filterView(campo, cFrom)
	local aOkFields	:= {}
	local lOk		:= .F.
	if cFrom == 'CLIENTE'
		aOkFields := {'A1_COD','A1_LOJA', 'A1_NOME','A1_MUN', 'A1_EST',;
			'A1_LC', 'A1_MCOMPRA', 'A1_MSALDO', 'A1_SALDUP', 'A1_MAIDUPL','A1_EMAIL', 'A1_EMAILFI' }
	elseif cFrom == 'RELAT'
		aOkFields := {'ZBA_FILIAL','ZBA_NROREL', 'ZBA_OPER','ZBA_NUM', 'ZBA_PARC','ZBA_HISTOP',;
		 	'ZBA_DTREL', 'ZBA_VALOR', 'ZBA_VLROPE', 'ZBA_VENCTO','ZBA_VENCRE','ZBA_VLRCC' }
	elseif cFrom == 'TITULO'
		aOkFields := {'E1_FILIAL','E1_NUM', 'E1_PARCELA', 'E1_TIPO','E1_EMISSAO', 'E1_VENCREA',;
			'E1_VALOR', 'E1_SALDO','E1_ACRESC','E1_DECRESC', 'E1_SDACRES'}
	endif
	lOk := Ascan(aOkFields, {|a| Alltrim(a) == Alltrim(campo) }) > 0
return(lOk)


/*/{Protheus.doc} addMdlFld
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Adiciona estrutura de modelo para campos que não são provenientes SX3 ( Conjunto com addViewFld() )
/*/
static function addMdlFld(oStru, cNome, cTitulo, cTipo, nTam, nDec)
	default nDec := 0
	/* addMdlFld(oStruZBA, 'MOTBAIXA', 'Mot. Baixa', 'C', 10) */
	// FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')"), ; // [07] B Code-block de validação do campo
	// FwBuildFeature( STRUCT_FEATURE_INIPAD, "'2'" ) , 		; // [11] B Code-block de inicializacao do campo
	oStru:AddField( 										; // Ord. Tipo Desc.
	AllTrim( cTitulo ) , 									; // [01] C Titulo do campo
	AllTrim( cTitulo ) , 									; // [02] C ToolTip do campo
	cNome , 												; // [03] C identificador (ID) do Field
	cTipo , 												; // [04] C Tipo do campo
	nTam , 												; // [05] N Tamanho do campo
	nDec , 												; // [06] N Decimal do campo
	nil,													; // [07] B Code-block de validação do campo
	NIL , 												; // [08] B Code-block de validação When do campo
	/*{'1=Sim','2=Não'}*/ , 								; // [09] A Lista de valores permitido do campo
	NIL , 												; // [10] L Indica se o campo tem preenchimento obrigatório
	nil,													; // [11] B Code-block de inicializacao do campo
	NIL , 												; // [12] L Indica se trata de um campo chave
	NIL , 												; // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. ) 												// [14] L Indica se o campo é virtual
return(nil)


/*/{Protheus.doc} addViewFld
@type function
@author bolognesi
@since 16/07/2018
@version 1.0
@description Adiciona estrutura de visualização para campos que não são provenientes SX3 ( Conjunto com addMdlFld() )
/*/
static function addViewFld(oStru, cNome, cOrdem, cTitulo, cTipo, cPicture, cF3 )
	default cF3	:= ''
	/*addViewFld(oStruZBA, 'MOTBAIXA', '3', 'Mot. Baixa', 'C', '@!', 'ZY' ) */
	oStru:AddField(;
		cNome , ; 							// [01] C Nome do Campo
	cOrdem , ; 							// [02] C Ordem
	AllTrim( cTitulo ) , ; 				// [03] C Titulo do campo
	AllTrim( cTitulo ) , ; 				// [04] C Descrição do campo
	{ cTitulo } , ; 						// [05] A Array com Help
	cTipo , ; 							// [06] C Tipo do campo
	cPicture , ; 							// [07] C Picture
	NIL , ; 								// [08] B Bloco de Picture Var
	cF3 , ; 								// [09] C Consulta F3
	.T. , ; 								// [10] L Indica se o campo é editável
	NIL , ; 								// [11] C Pasta do campo
	NIL , ; 								// [12] C Agrupamento do campo
	/*{'1=Sim','2=Não'}*/ , ; 				// [13] A Lista de valores permitido do campo (Combo)
	NIL , ; 								// [14] N Tamanho Máximo da maior opção do combo
	NIL , ; 								// [15] C Inicializador de Browse
	.T. , ; 								// [16] L Indica se o campo é virtual
	NIL ) 								// [17] C Picture Variável
return(nil)
