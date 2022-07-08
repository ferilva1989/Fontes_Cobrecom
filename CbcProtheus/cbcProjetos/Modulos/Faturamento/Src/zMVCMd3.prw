//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'XMLXFUN.ch'
#include 'fileio.ch'
//Constantes
#define TAMANHO_CAMPO 	01
#define DECIMAL_CAMPO 	02
#define TIPO_CAMPO	  	03
#define MAX_PERMITIDO	05
#define OPC_LISTAR	1
#define OPC_ADICIONAR 	2
#define OPC_DELETAR	3

static cTitulo := "Produtos x Lances por Acondicionamento"


/*/{Protheus.doc} zMVCMd3
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Inicializa o Browser e começa a rotina
/*/
User Function zMVCMd3()
	Local aArea   := GetArea()
	Local oBrowse
	//x31updtable("ZZZ")
	DbSelectArea('ZZZ')
	//Obter o arquivo de trabalho
	mkWorkTab()
	
	//Instanciando FWMBrowse - Somente com dicionario de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias(cArea)
	
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:DisableDetails()
	
	oBrowse:SetUseFilter( .T. )
	oBrowse:SetDBFFilter( .T. )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetFieldFilter(aFieFilter)
	
	//Legendas
	oBrowse:AddLegend( "TR_UPD == 'S'", "YELLOW", "Familia + Bitola com informações de Lances e Metragens" )
	oBrowse:AddLegend( "TR_UPD == 'N'", "RED",   "Familia + Bitola sem informação de Lances e Metragens" )
	
	oBrowse:SetColumns(MontaColunas("TR_DESCR"	,"Descrição"	,01,"@!",1,040,0))
	oBrowse:SetColumns(MontaColunas("FAMILIA"	,"Familia"		,02,"@!",0,010,0))
	oBrowse:SetColumns(MontaColunas("BITOLA"	,"Bitola"		,03,"@!",1,080,0))
	
	//oBrowse:SetOnlyFields({'B1_COD','B1_TIPO', 'B1_DESC'} )
	oBrowse:SetMenuDef("zMVCMd3")
	//oBrowse:SetFilterDefault("B1_TIPO == 'PA' .And. B1_MSBLQL != '1'")
	
	oBrowse:Activate()
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		(cArea)->(DbCloseArea())
		delTabTmp(cArea)
		dbClearAll()
	Endif
	
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Definições para de menu para o modelo MVC
/*/
Static Function MenuDef()
	Local aRot := {}
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCMd3' 	OPERATION MODEL_OPERATION_VIEW   	ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_MVCMd3Leg'     	OPERATION 6                     	ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Imp. Excel'  ACTION "u_prcExcl(1)" 		OPERATION 6                 		ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Exp. Excel'  ACTION "u_prcExcl(2)" 		OPERATION 6                 		ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCMd3' 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
Return aRot

/*/{Protheus.doc} ModelDef
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Função com as definições padrões da camada Model MVC
/*/
static function ModelDef()
	local oModel        	:= Nil
	local oStPai        	:= FWFormStruct(1, '')
	local oStMetragem  	    := FWFormStruct(1, 'ZZZ')
	local oStVarejo  		:= FWFormStruct(1, 'ZZZ')
	local oStCurva  		:= FWFormStruct(1, 'ZZZ')
	local aZZZMtr       	:= {}
	local aZZZVar			:= {}
	local aZZZCur			:= {}
	
	// Funçao que recebe o oStPai e devolve modificado para arquivo temporario
	ownModel(oStPai)
	
	// Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('ModMVCMd3')
	
	// Definir o TudoOk
	// 2 Parametro lAcumula .T. não substitui bloco anterior, apenas adiciona ao final
	// Definir PréValidação Modela
	// oModel:SetPre(bBloco, lAcumula)
	oModel:SetPost({|oModel| MVCMd3TOK(oModel)}, .F.)
	
	// Adicionar o que é campo e o que é grid
	oModel:AddFields('PAIMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZZZMETRAGE','PAIMASTER',oStMetragem)
	oModel:AddGrid('ZZZVAREJO' ,'PAIMASTER',oStVarejo)
	oModel:AddGrid('ZZZCURVA' ,'PAIMASTER',oStCurva)
	
	// Definido a propriedade inicializador padrão do MODEL
	oStMetragem:SetProperty( 'ZZZ_TIPO' , MODEL_FIELD_INIT,{||'MTR'})
	oStVarejo:SetProperty( 'ZZZ_TIPO' 	, MODEL_FIELD_INIT,{||'VAR'})
	oStCurva:SetProperty( 'ZZZ_TIPO' 	, MODEL_FIELD_INIT,{||'CUR'})
	oStCurva:SetProperty( 'ZZZ_ACOND' 	, MODEL_FIELD_OBRIGAT,.F.)
	oStCurva:SetProperty( 'ZZZ_VLRMTR' 	, MODEL_FIELD_OBRIGAT,.F.)
	
	// Modelo Master somente visualiar
	oModel:GetModel('PAIMASTER'):SetOnlyView(.T.)
	
	// Definir Validação de linha
	// Pre
	oModel:GetModel('ZZZMETRAGE'):SetlPre({|oModelGrid|MVCd3PrOK(oModelGrid,'METRAGE')})
	oModel:GetModel('ZZZVAREJO'):SetlPre({|oModelGrid|MVCd3PrOK(oModelGrid, 'VAREJO')})
	oModel:GetModel('ZZZCURVA'):SetlPre({|oModelGrid|MVCd3PrOK(oModelGrid, 'CURVA')})
	
	// Pos
	oModel:GetModel('ZZZMETRAGE'):SetlPost({|oModelGrid| MVCd3LOK(oModelGrid,'METRAGE')})
	oModel:GetModel('ZZZVAREJO'):SetlPost({|oModelGrid| MVCd3LOK(oModelGrid, 'VAREJO')})
	oModel:GetModel('ZZZCURVA'):SetlPost({|oModelGrid| MVCd3LOK(oModelGrid, 'CURVA')})
	
	
	// Fazendo o relacionamento Model Metragem
	aAdd(aZZZMtr, {'ZZZ_TIPO'		, 'Alltrim("MTR")' } )
	aAdd(aZZZMtr, {'ZZZ_PROD'		, 'FAMILIA'} )
	aAdd(aZZZMtr, {'ZZZ_BITOLA'	, 'BITOLA'} )
	
	// Fazendo o relacionamento Model Varejo
	aAdd(aZZZVar,  {'ZZZ_TIPO'		, 'Alltrim("VAR")'} )
	aAdd(aZZZVar,  {'ZZZ_PROD'		, 'FAMILIA'} )
	aAdd(aZZZVar,  {'ZZZ_BITOLA'	, 'BITOLA'} )
	
	// Fazendo o relacionamento Model Curva
	aAdd(aZZZCur,  {'ZZZ_TIPO'		, 'Alltrim("CUR")'} )
	aAdd(aZZZCur,  {'ZZZ_PROD'		, 'FAMILIA'} )
	aAdd(aZZZCur,  {'ZZZ_BITOLA'	, 'BITOLA'} )
	
	oModel:SetRelation('ZZZMETRAGE'	, aZZZMtr, ZZZ->(IndexKey(1)))
	oModel:SetRelation('ZZZVAREJO'	, aZZZVar, ZZZ->(IndexKey(1)))
	oModel:SetRelation('ZZZCURVA'	, aZZZCur, ZZZ->(IndexKey(1)))
	
	// Validação para não duplicar linha
	oModel:GetModel('ZZZMETRAGE'):SetUniqueLine({'ZZZ_FILIAL','ZZZ_TIPO','ZZZ_PROD','ZZZ_BITOLA', 'ZZZ_ACOND'})
	oModel:GetModel('ZZZVAREJO'):SetUniqueLine({'ZZZ_FILIAL','ZZZ_TIPO','ZZZ_PROD','ZZZ_BITOLA', 'ZZZ_ACOND'})
	oModel:GetModel('ZZZCURVA'):SetUniqueLine({'ZZZ_FILIAL','ZZZ_TIPO','ZZZ_PROD','ZZZ_CODPRO'})
	
	oModel:SetPrimaryKey({})
	
	// Preenchimento Aba Metragem é obrigatorio (Para salvar tem que ter dados)
	// Preenchimento Aba Varejo não obrigatorio (Pode salvar vazio)
	// Preenchimento Aba Curva não obrigatorio (Pode salvar vazio)
	oModel:getModel('ZZZMETRAGE'):SetOptional(.F.)
	oModel:getModel('ZZZVAREJO'):SetOptional(.T.)
	oModel:getModel('ZZZCURVA'):SetOptional(.T.)
	
	// Setando as descrições
	oModel:SetDescription("Complemento de Produtos")
	oModel:GetModel('PAIMASTER'):SetDescription('Familia Bitola')
	oModel:GetModel('ZZZMETRAGE'):SetDescription('Lances acondicionamentos')
	oModel:GetModel('ZZZVAREJO'):SetDescription('Varejo')
	oModel:GetModel('ZZZCURVA'):SetDescription('Produto Curva')
	
return(oModel)

/*/{Protheus.doc} ViewDef
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Definições padrões da View do modelo MVC
/*/
Static Function ViewDef()
	local oView     		:= Nil
	local oModel        	:= FWLoadModel('zMVCMd3')
	local oStPai        	:= FWFormStruct(2, '')
	local oStMetragem  	    := FWFormStruct(2, 'ZZZ')
	local oStVarejo  		:= FWFormStruct(2, 'ZZZ')
	local oStCurva  		:= FWFormStruct(2, 'ZZZ')
	
	//Funçao que recebe o oStPai e devolve modificado para arquivo temporario
	ownView(oStPai)
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Barra de progresso na carga do formulario
	oView:SetProgressBar(.T.)
	
	//Ocultar os campos apenas da VIEW
	oStMetragem:RemoveField('ZZZ_TIPO')
	oStMetragem:RemoveField('ZZZ_CODPRO')
	oStMetragem:RemoveField('ZZZ_JSFLD')
	oStVarejo:RemoveField('ZZZ_TIPO')
	oStVarejo:RemoveField('ZZZ_CODPRO')
	oStVarejo:RemoveField('ZZZ_JSFLD')
	oStCurva:RemoveField('ZZZ_TIPO')
	oStCurva:RemoveField('ZZZ_VLRMTR')
	oStCurva:RemoveField('ZZZ_ACOND')
	oStCurva:RemoveField('ZZZ_CODCOR')
	oStCurva:RemoveField('ZZZ_JSFLD')
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_PAI'				,oStPai		,'PAIMASTER')
	oView:AddGrid('VIEW_METRAGE'			,oStMetragem	,'ZZZMETRAGE')
	oView:AddGrid('VIEW_VAREJO'			,oStVarejo	,'ZZZVAREJO')
	oView:AddGrid('VIEW_CURVA'				,oStCurva	,'ZZZCURVA')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',20)
	//Criando Box principal dos detalhes
	oView:CreateHorizontalBox('DETAILS',80)
	
	//Adicionando o Folder
	oView:CreateFolder( 'FOLDER_DETAILS', 'DETAILS')
	
	//Adicionando as abas ao folder
	oView:AddSheet('FOLDER_DETAILS','SHEET_METRAGE','METRAGEM')
	oView:AddSheet('FOLDER_DETAILS','SHEET_VAREJO','VAREJO')
	oView:AddSheet('FOLDER_DETAILS','SHEET_CURVA','CURVA', {|| loadSheet()})
	
	
	//Adicionando os grids dentro das abas
	oView:CreateHorizontalBox( 'GRID_METRAGE'	, 100,,,'FOLDER_DETAILS', 'SHEET_METRAGE')
	oView:CreateHorizontalBox( 'GRID_VAREJO'		, 100,,,'FOLDER_DETAILS', 'SHEET_VAREJO')
	oView:CreateHorizontalBox( 'GRID_CURVA'		, 100,,,'FOLDER_DETAILS', 'SHEET_CURVA')
	
	//Amarrando a view com os folders
	oView:SetOwnerView('VIEW_PAI','CABEC')
	oView:SetOwnerView('VIEW_METRAGE','GRID_METRAGE')
	oView:SetOwnerView('VIEW_VAREJO', 'GRID_VAREJO')
	
	// Componentes tela produto curva
	oView:CreateVerticalBox( 'CURVA_MASTER_V', 50, 'GRID_CURVA',, 'FOLDER_DETAILS', 'SHEET_CURVA')
	oView:CreateVerticalBox( 'CURVA_DETAIL_V', 50, 'GRID_CURVA',, 'FOLDER_DETAILS', 'SHEET_CURVA')
	oView:CreateHorizontalBox( 'CURVA_MASTER_H', 100, 'CURVA_MASTER_V',, 'FOLDER_DETAILS', 'SHEET_CURVA')
	oView:CreateHorizontalBox( 'CURVA_DETAIL_H', 100, 'CURVA_DETAIL_V',, 'FOLDER_DETAILS', 'SHEET_CURVA')
	oView:SetOwnerView('VIEW_CURVA', 'CURVA_MASTER_H')
	
	// Componente personalizado produto curva
	oView:AddOtherObject("CURVA_LISTA", {|oPanel| CompVwCurva(oPanel)},{|oPanel| deactive(oPanel)} )
	oView:SetOwnerView("CURVA_LISTA",'CURVA_DETAIL_H')
	
	//Habilitando titulo
	oView:EnableTitleView('VIEW_PAI','PRODUTO')
	oView:EnableTitleView('VIEW_METRAGE','LANCE X ACONDICIONAMENTO')
	oView:EnableTitleView('VIEW_VAREJO','VAREJO')
	oView:EnableTitleView('VIEW_CURVA','CURVA')
	oView:EnableTitleView('CURVA_LISTA','ACOND.METRAGEM')
	
	//Botões personalizados
	oView:AddUserButton('ADD. COR'		, 'CLIPS', {|oView| u_ZZZCOR(oView)})
	oView:AddUserButton('REM. COR'		, 'CLIPS', {|oView| u_ZZZRECOR(oView)})
	
	//Definir alguns eventos, bloco de codigo ao mudar a linha do grid
	oView:SetViewProperty( 'VIEW_CURVA', 'CHANGELINE', {{ |oView, cViewID| ChangeLine(oView, cViewID) }} )
	
	//Fechamento da tela no OK
	oView:SetCloseOnOk({||.T.})
return(oView)


/*/{Protheus.doc} CompVwCurva
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Cria o componente visual "CURVA_LISTA", que permite
a manipulação do campo "ZZZ_JSFLD", que é uma string JSON, este componente
permite a interação com esta string em forma de Objeto, acessando desta forma
a propriedade aitens
/*/
static function CompVwCurva(oPanel)
	local cListCSS		:= ""
	local cButCSS			:= ""
	local cSayCSS			:= ""
	local oBtnList		:= nil
	local oBtnAdd			:= nil
	local oBtnRem			:= nil
	local oFont1 			:= nil
	local nLstBox 		:= 1
	static aItm			:= {}
	static oLstBox		:= nil
	static cSayDesc		:= ''
	static oSayDescProd	:= nil
	
	cListCSS += "QListView {show-decoration-selected: 1;}"
	cListCSS += "QListView::item:alternate{background: #EEEEEE;}"
	cListCSS += "QListView::item:hover{background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #FAFBFE, stop: 1 #DCDEF1);}"
	cButCSS += "QPushButton {border: 1px solid #8f8f91; border-radius: 6px;"
	cButCSS += "background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #f6f7fa, stop: 1 #dadbde);min-width: 80px;}"
	cButCSS += "QPushButton:pressed{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #c2c3c6, stop: 1 #d6d8db);}"
	cSayCSS += "QLabel{font-size: 24px;color: #FFFFFF;border: 2px solid #3E97EB;border-radius: 6px;"
	cSayCSS += " background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #3E97EB, stop: 1 #008080)}"
	
	oFont1 		:= TFont():New("Arial Narrow",,030,,.F.,,,,,.F.,.F.)
	oBtnList 	:= TButton():New( 20, 10, "Listar",oPanel ,{||click(OPC_LISTAR,oPanel)}, 36,13,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnAdd		:= TButton():New( 20, 55, "Add",oPanel ,{||click(OPC_ADICIONAR,oPanel)}, 36,13,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnRem		:= TButton():New( 20, 100, "Rem",oPanel ,{||click(OPC_DELETAR,oPanel)}, 36,13,,,.F.,.T.,.F.,,.F.,,,.F. )
	oLstBox 	 	:= TListBox():New(035,001,{|u|if(Pcount()>0,nLstBox:=u,nLstBox)},aItm, 227,160,{||},oPanel,,,,.T.,,,oFont1 )
	oSayDescProd	:= TSay():New(210,01,{||cSayDesc},oPanel,,oFont1,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oLstBox:GoTop()
	
	oLstBox:SetCss(cListCSS)
	oBtnRem:SetCss(cButCSS)
	oBtnList:SetCss(cButCSS)
	oBtnAdd:SetCss(cButCSS)
	oSayDescProd:SetCss(cSayCSS)
	
return(nil)


/*/{Protheus.doc} click
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Evento de click utilizado no componente "CURVA_LISTA"
responsavel pela manutenção (Listar, Adicionar e Deletar)
e sincronização do campo ZZZ_JSFLD e o array da lista deste componente.
/*/
static function click(cFrom, oPanel)
	local oModel 		:= FWModelActive()
	local aSaveLines	:= FWSaveRows()
	local oMdl		:= oModel:GetModel('ZZZCURVA')
	local oJS		:= cbcJsFld():newcbcJsFld()
	local lOk		:= .T.
	
	if cFrom == OPC_LISTAR
		oJS:objFromMemo(@aItm, oMdl)
	elseif cFrom == OPC_ADICIONAR
		if empty( oMdl:GetValue('ZZZ_CODPRO') )
			lOk := .F.
			Help( ,, 'ZZZ_CODPRO','Codigo do produto', 'Nenhum codigo produto informado!',1,0,,,,,,{'Informe codigo do produto'})
		else
			oJS:addMemo(@aItm, oMdl)
		endif
	elseif cFrom == OPC_DELETAR
		if empty(oLstBox:GetSelText())
			lOk := .F.
			Help( ,, 'Metragem e Acondicionamento','Vazio', 'Nenhum item informado para cancelamento!',1,0,,,,,,{'Informar item para deletar'})
		else
			oJS:remMemo(@aItm, oLstBox, oMdl)
		endif
	endif
	
	if lOk
		oLstBox:SetItems(aItm)
		descProd(oMdl:GetValue('ZZZ_CODPRO'))
		oPanel:Refresh()
	endif
	
	FreeObj(oJS)
	FwRestRows(aSaveLines)
	
return(nil)


/*/{Protheus.doc} ChangeLine
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Ocorre a cada mudança de linha na grid 'VIEW_CURVA'
possibilita a sincronização do array da lista do componente  "CURVA_LISTA"
com o campo ZZZ_JSFLD.
/*/
static function ChangeLine(oView, cViewID)
	local aSaveLines	:= FWSaveRows()
	local oMdl		:= oView:getModel('ZZZCURVA')
	local oJS		:= cbcJsFld():newcbcJsFld()
	local oComp		:= oView:aViews[5,3]
	
	oJS:objFromMemo(@aItm, oMdl)
	oLstBox:SetItems(aItm)
	descProd(oMdl:GetValue('ZZZ_CODPRO'))
	oComp:Refresh()
	FreeObj(oJS)
	
	FwRestRows(aSaveLines)
return(nil)


/*/{Protheus.doc} deactive
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Desativação do componente  "CURVA_LISTA"
limpar o array da lista deste componente.
/*/
static function deactive()
	aItm		:= {}
	oLstBox:SetItems(aItm)
	cSayDesc := ''
return(nil)


/*/{Protheus.doc} loadSheet
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Executado na ativação da aba 'SHEET_CURVA',
permite carregar o conteudo da lista do componente "CURVA_LISTA"
depois sua atualização ocorre pela mudanção de linha ChangeLine
/*/
static function loadSheet()
	local oView := FWViewActive()
	ChangeLine(oView, 'VIEW_CURVA')
return(nil)


/*/{Protheus.doc} descProd
(long_description)
@type function
@author bolognesi
@since 24/04/2018
@version 1.0
@description Utilizado para obter a partir do codigo
do produto sua descrição, utilizado para exivir tSay componente
"CURVA_LISTA"
/*/
static function descProd(cCod)
	local oSql 	:= nil
	local cDesc	:= ''
	
	oSql := LibSqlObj():newLibSqlObj()
	if ! empty( cDesc := oSql:getFieldValue("SB1", "B1_DESC","%SB1.XFILIAL% AND B1_COD ='" + cCod + "'") )
		cSayDesc := Alltrim(cDesc)
		oSayDescProd:CtrlRefresh()
	endif
	FreeObj(oSql)
return(nil)


/*/{Protheus.doc} mkWorkTab
@author bolognesi
@since 29/11/2016
@version undefined
@param cUpdArea, characters, define se deve criar uma nova area ou
atualizar uma existente o default é criar uma nova nova
@type function
@description Função que cria o arquivo temporario Juntando (Z1,Z2,B1,ZZ)
/*/
Static function mkWorkTab(cUpdArea)
	Local oSql 			:= SqlUtil():newSqlUtil()
	Local cIndice1
	Local cIndice2
	Local cIndice3
	Local aB1NomeX3		:= TamSx3('B1_NOME')
	Local aB1BitSX3		:= TamSx3('B1_BITOLA')
	Local aZ1DesSX3		:= TamSx3('Z1_DESC')
	Local aZ2DescSX3		:= TamSx3('Z2_DESC')
	Local oRt			:= Nil
	Local cQry			:= ""
	Private aCampos		:= {}
	Private aDados 		:= {}
	Private aValores 	:= {}
	Static  aFieFilter 	:= {}
	Static  aSeek		:= {}
	Static cArea		:= ''
	Static cArqTrb
	Default cUpdArea	:= ""
	
	If Empty(cUpdArea)
		cArea := GetNextAlias()
	Else
		cArea := cUpdArea
	Endif
	
	//Campos da tabela temporaria
	AAdd(aCampos,{"FAM_BITOLA"  , aB1NomeX3[TIPO_CAMPO] ,(aB1NomeX3[TAMANHO_CAMPO] + aB1BitSX3[TAMANHO_CAMPO]) 	,aB1NomeX3[DECIMAL_CAMPO]})
	AAdd(aCampos,{"FAMILIA" 	, aB1NomeX3[TIPO_CAMPO] , aB1NomeX3[TAMANHO_CAMPO] 								,aB1NomeX3[DECIMAL_CAMPO] })
	AAdd(aCampos,{"BITOLA" 		, aB1BitSX3[TIPO_CAMPO] , aB1BitSX3[TAMANHO_CAMPO] 								,aB1BitSX3[DECIMAL_CAMPO]})
	AAdd(aCampos,{"TR_DESCR"	, aZ1DesSX3[TIPO_CAMPO] , aZ1DesSX3[TAMANHO_CAMPO] + aZ2DescSX3[TAMANHO_CAMPO]  ,aZ1DesSX3[DECIMAL_CAMPO]})
	AAdd(aCampos,{"TR_UPD"		, "C" ,1  ,0})
	AAdd(aCampos,{"TR_FILIAL"	, "C" ,2  ,0})
	AAdd(aCampos,{"TR_POS"  	, "N" ,12 ,0})
	
	If (Select(cArea) <> 0)
		dbSelectArea(cArea)
		(cArea)->(dbCloseArea ())
	Endif
	
	//Cria tabela temporaria
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	//Definir indices da tabela
	cIndice1 := Alltrim(CriaTrab(,.F.))
	cIndice2 := cIndice1
	cIndice3 := cIndice1
	cIndice1 := Left(cIndice1,5)+Right(cIndice1,2)+"A"
	cIndice2 := Left(cIndice2,5)+Right(cIndice2,2)+"B"
	cIndice3 := Left(cIndice3,5)+Right(cIndice3,2)+"C"
	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf
	
	If File(cIndice2+OrdBagExt())
		FErase(cIndice2+OrdBagExt())
	EndIf
	
	If File(cIndice3+OrdBagExt())
		FErase(cIndice3+OrdBagExt())
	EndIf
	
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,cArea,Nil,.F.)
	
	//Criar indice
	IndRegua(cArea, cIndice1, "FAM_BITOLA"	,,, "Familia + Bitola...")
	IndRegua(cArea, cIndice2, "FAMILIA"		,,, "Familia...")
	IndRegua(cArea, cIndice3, "BITOLA"		,,, "Bitola...")
	dbClearIndex()
	dbSetIndex(cIndice1+OrdBagExt())
	dbSetIndex(cIndice2+OrdBagExt())
	dbSetIndex(cIndice3+OrdBagExt())
	
	/*
	popular a tabela
	*/
	cQry += " SELECT "
	cQry += " DISTINCT(SB1.B1_NOME + SB1.B1_BITOLA) AS FAM_BITOLA, "
	cQry += " SB1.B1_FILIAL AS TR_FILIAL, "
	cQry += " SB1.B1_NOME AS FAMILIA, "
	cQry += " SB1.B1_BITOLA AS BITOLA, "
	cQry += " Rtrim(Ltrim(SZ1.Z1_DESC)) + ' ' + Rtrim(Ltrim(SZ2.Z2_DESC)) AS TR_DESCR,"
	cQry += " CASE "
	cQry += " WHEN ZZZ.ZZZ_PROD IS NULL "
	cQry += " 	THEN 'N' "
	cQry += " ELSE 'S'	"
	cQry += " END AS TR_UPD "
	cQry += " FROM SB1010 SB1 "
	cQry += " INNER JOIN SZ1010 SZ1 "
	cQry += " ON SB1.B1_FILIAL = SZ1.Z1_FILIAL "
	cQry += " AND SB1.B1_NOME = SZ1.Z1_COD "
	cQry += " AND SB1.D_E_L_E_T_ = SZ1.D_E_L_E_T_ "
	cQry += " INNER JOIN SZ2010 SZ2 "
	cQry += " ON SB1.B1_FILIAL = SZ2.Z2_FILIAL "
	cQry += " AND SB1.B1_BITOLA = SZ2.Z2_COD "
	cQry += " AND SB1.D_E_L_E_T_ = SZ2.D_E_L_E_T_ "
	cQry += " LEFT JOIN ZZZ010 ZZZ "
	cQry += " ON SB1.B1_FILIAL	= ZZZ.ZZZ_FILIAL "
	cQry += " AND SB1.B1_NOME	= ZZZ.ZZZ_PROD "
	cQry += " AND SB1.B1_BITOLA	= ZZZ.ZZZ_BITOLA "
	cQry += " AND SB1.D_E_L_E_T_	= ZZZ.D_E_L_E_T_ "
	cQry += " WHERE "
	cQry += " SB1.B1_FILIAL = '' "
	cQry += " AND SB1.B1_BITOLA <> '' "
	cQry += " AND SB1.B1_NOME <> '' "
	cQry += " AND SB1.B1_TIPO = 'PA' "
	cQry += " AND SB1.B1_MSBLQL != '1' "
	cQry += " AND SB1.D_E_L_E_T_ <> '*' "
	if oSql:QryToDb( cQry ):lOk
		oRt := oSql:oRes
		For nX := 1 To oSql:nRegCount
			aadd(aValores, { oRt[nX]:FAM_BITOLA, oRt[nX]:FAMILIA, oRt[nX]:BITOLA, oRt[nX]:TR_DESCR, oRt[nX]:TR_UPD, oRt[nX]:TR_FILIAL } )
		Next nX
	Else
		MessageBox(oSql:cMsgErro)
	EndIf
	FreeObj(oSql)
	
	For nX:= 1 to len(aValores)
		If RecLock(cArea,.T.)
			(cArea)->FAM_BITOLA    	:= aValores[nX,1]
			(cArea)->FAMILIA 	  	:= aValores[nX,2]
			(cArea)->BITOLA  		:= aValores[nX,3]
			(cArea)->TR_DESCR 		:= aValores[nX,4]
			(cArea)->TR_UPD 		:= aValores[nX,5]
			(cArea)->TR_FILIAL 		:= aValores[nX,6]
			(cArea)->TR_POS   		:= nX
			(cArea)->(MsUnLock())
		Endif
	Next nX
	dbSelectArea(cArea)
	(cArea)->(DbGoTop())
	
	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd(aSeek,{"FAM_BITOLA"  , {{"","C",08,0, "Fam. + Bit."		,"@!"}}, 1, .T. } )
	Aadd(aSeek,{"FAMILIA"		, {{"","C",22,0, "Familia"			,"@!"}}, 2, .T. } )
	Aadd(aSeek,{"BITOLA" 		, {{"","C",52,0, "Bitola" 			,"@!"}}, 3, .T. } )
	
	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"FAM_BITOLA"	, "Fam. + Bit."		, "C", 08, 0,"@!"})
	Aadd(aFieFilter,{"FAMILIA"		, "Familia"			, "C", 22, 0,"@!"})
	Aadd(aFieFilter,{"BITOLA"		, "Bitola" 			, "C", 52, 0,"@!"})
	
return (nil)

/*/{Protheus.doc} MontaColunas
@author bolognesi
@since 29/11/2016
@version undefined
@param cCampo, characters, descricao
@param cTitulo, characters, descricao
@param nArrData, numeric, descricao
@param cPicture, characters, descricao
@param nAlign, numeric, descricao
@param nSize, numeric, descricao
@param nDecimal, numeric, descricao
@type function
/*/
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}

/*/{Protheus.doc} ownView
@author bolognesi
@since 29/11/2016
@version 1.0
@param oFormStruct, object, descricao
@type function
@description Função que recebe o formStruc da view e realiza alterações para
exibir dados de um arquivo temporario.
/*/
Static Function ownView(oFormStruct)
	Local aField		:= {}
	Default oFormStruct	:= Nil
	
	If oFormStruct != Nil
		AAdd(aField,{"TR_DESCR"	,"01", "Descr."	, "Descr. Produto", 	Nil, "GET", "@!", Nil, ""		, .F., "1", "", {},0,"",.F.,"", .F., Nil, .T., nil, nil } )
		AAdd(aField,{"FAMILIA"	,"02", "Familia", "Familia do Produto", Nil, "GET", "@!", Nil, /*F3*/ 	, .F., "1", "", {},0,"",.F.,"", .F., Nil, .T., nil, nil } )
		AAdd(aField,{"BITOLA"	,"03", "Bitola"	, "Bitola do Produto", 	Nil, "GET", "@!", Nil, ""		, .F., "1", "", {},0,"",.F.,"", .F., Nil, .T., nil, nil } )
		
		oFormStruct:AFIELDS 	:=  aField
		oFormStruct:AFOLDERS 	:= {}
	EndIf
Return (oFormStruct)

/*/{Protheus.doc} ownModel
@author bolognesi
@since 29/11/2016
@version 1.0
@param oFormStruct, object, descricao
@type function
@description Função que recebe FormStruct do Model, padrão e modifica com informações
de uma tabela temporaria
/*/
Static Function ownModel(oFormStruct)
	Local aField		:= {}
	Local aIndex		:= {}
	Local aTable		:= {}
	Local aRet			:= {}
	Default oFormStruct	:= Nil
	
	If oFormStruct != Nil
		AAdd(aField,{"FAM_BITOLA", 'Familia + Bitola', "FAM_BITOLA", "C", 6, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,''} )
		AAdd(aField,{"FAMILIA"	 , 'Familia', "FAMILIA", "C", 6, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,.F.,'' } )
		AAdd(aField,{"BITOLA"	 , 'Bitola', "BITOLA", "C", 6, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,.F.,'' } )
		AAdd(aField,{"TR_DESCR"	 , 'Descrição', "TR_DESCR", "C", 40, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,.F.,'' } )
		AAdd(aField,{"TR_POS"	 , 'Posição', "TR_POS", "N", 12, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,.F.,'' } )
		AAdd(aField,{"TR_UPD"	 , 'Atualizado', "TR_UPD", "C", 12, 0, {||.T.}, Nil,{},.F.,Nil,.F.,.F.,.F.,'' } )
		
		AAdd(aIndex,  {1, "1", "FAM_BITOLA", "Chave " , "  ", "  ", .T. } )
		AAdd(aIndex,  {2, "2", "FAMILIA", "Familia " , "  ", "  ", .T. } )
		AAdd(aIndex,  {3, "3", "BITOLA" , "Bitola " , "  ", "  ", .T. } )
		
		aTable := {cArea, {"FAM_BITOLA"}, "Chave", Nil}
		
		oFormStruct:AFIELDS 	:= aField
		oFormStruct:AINDEX 		:= aIndex
		oFormStruct:ATABLE 		:= aTable
		oFormStruct:ATRIGGERS 	:= {} //Zerar Gatilhos
	EndIf
return (oFormStruct)

/*/{Protheus.doc} prcExcl
@author bolognesi
@since 01/12/2016
@version 1.0
@type function
@description Função intermediaria, para chamar as funções exibindo as barras de progresso.
/*/
User Function prcExcl(nWho)
	Local oProcess := Nil
	Default nWho := 0
	If nWho == 1
		oProcess := MsNewProcess():New({||U_MvcExExc(@oProcess)} , 'Atualizando os registros', 'Lendo os dados Excel...' , .F.  )
	ElseIf nWho == 2
		oProcess := MsNewProcess():New({||U_MvcImExc(@oProcess)} , 'Procurando os registros', 'Exportando dados para o Excel...' , .F.  )
	EndIf
	If nWho > 0
		oProcess:Activate()
	EndIf
Return(Nil)

/*/{Protheus.doc} MvcExExc
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Função utilizada para importar os dados de uma planilha XML previamente
exportada pelo sistema, esta função processa a planilha e atualiza a base de dados
/*/
User Function MvcExExc(oProcess)
	local oXml		:= Nil
	local cXmlErr	:= ""
	local cXmlWrn	:= ""
	local lCompact	:= .T.
	local aPrmBox	:= {}
	local aRet 		:= {}
	local aVer		:= {}
	local cNewName	:= ""
	local cPathS	:= '\portalXML\'
	local cFile		:= ""
	local nX		:= 0
	local nY		:= 0
	local aLinhas	:= {}
	local aLinha	:= {}
	local nPos		:= 0
	local lOk		:= .T.
	local aMsg		:= {}
	local aHdrDef	:= {}
	local bErro		:= Nil
	local aAux		:= {}
	local aCposDet	:= {}
	local nProg1	:= 0
	local cFamilia	:=""
	local cBitola	:=""
	local cAcond	:=""
	local cMetragens:=""
	local cCor		:=""
	local cTpReg	:=""
	local cUpd		:=""
	local aTable	:= {}
	local cDescr	:= ""
	
	If !ExistDir(cPathS)
		MakeDir(cPathS)
	EndIf
	
	aAdd(aPrmBox,{6,"Planilha Excel:",Space(50),"","","",50,.T.	,"Planilhas xml (*.xml) |*.xml",'\' })
	If ParamBox(aPrmBox ,"Importar Configuração Excel ",@aRet)
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @lOk, @aMsg)})
		BEGIN SEQUENCE
			aVer := StrTokArr(aRet[1],'\')
			cNewName := cPathS + aVer[Len(aVer)]
			FErase(cNewName)
			
			If !CpyT2S(aRet[1], cPathS , lCompact)
				lOk := .F.
				aMsg := {'[ERRO] - ' + 'Não foi possivel enviar arquivo XML para o servidor','Verifique o arquivo'}
			Else
				oXml := XmlParserFile(cNewName, ' ', @cXmlErr, @cXmlWrn)
				
				If ! Empty(cXmlErr)
					lOk := .F.
					aMsg := {'[ERRO] - ' + cXmlErr,''}
				Else
					If !AttIsMemberOf(oXml,'_WORKBOOK')
						lOk := .F.
					Else
						If !AttIsMemberOf(oXml:_WORKBOOK,'_WORKSHEET')
							lOk := .F.
						Else
							if len(aTable := oXml:_WORKBOOK:_WORKSHEET) <> 3
								lOk := .F.
							else
								for nY := 1 to len(aTable)
									If !AttIsMemberOf(aTable[nY],'_TABLE')
										lOk := .F.
									Endif
								next nX
							endif
						EndIf
					EndIf
					If !lOk
						aMsg := {'[ERRO] - Estrutura do arquivo XML inválida!','Utilize apenas arquivos exportados pelo sistema'}
					Else
						//Documento não foi gerado pelo Sistema
						If oXml:_WORKBOOK:_DocumentProperties:_Author:TEXT != "Microsiga Protheus"
							lOk := .F.
							aMsg := {'[ERRO] - Arquivo selecionado, não foi gerado pelo sistema!','Utilize apenas arquivos exportados pelo sistema'}
						Else
							for nY := 1 to len(aTable)
								if !lOk
									exit
								elseif aTable[nY]:_SS_NAME:TEXT == "01-Acond.Metragem"
									cTpReg := 'MTR'
								elseif aTable[nY]:_SS_NAME:TEXT == "02-Varejo"
									cTpReg := 'VAR'
								else
									loop
								endif
								aHdrDef := {'Familia' , 'Bitola' ,'Descricao', 'Acondionamento' ,  'Metragem', 'Cores' }
								aLinhas := aTable[nY]:_TABLE:_ROW
								
								//Verificação de Cabeçalho
								If AttIsMemberOf(aLinhas[2],'_CELL')
									aLinha := aLinhas[2]:_CELL
									For nX := 1 To Len(aLinha)
										nPos := AScan(aHdrDef,aLinha[nX]:_DATA:TEXT)
										If nPos > 0
											ADel(aHdrDef, nPos)
											ASize(aHdrDef, (Len(aHdrDef) - 1)  )
										Else
											//Algum item cabeçalho não existe
											lOk	:= .F.
											aMsg := {'[ERRO] - Arquivo selecionado com estrutura inválida!','Utilize apenas arquivos exportados pelo sistema'}
											Exit
										EndIf
										
									Next nX
								EndIf
								//Continua somente se aHdrDef Vazio
								If Empty(aHdrDef) .And. lOk
									
									For nX := 3 To Len(aLinhas)
										If AttIsMemberOf(aLinhas[nX],'_CELL')
											nProg1 ++
										EndIf
									Next nX
									oProcess:SetRegua1(nProg1)
									
									//Conteudo de cada Linha
									For nX := 3 To Len(aLinhas)
										If AttIsMemberOf(aLinhas[nX],'_CELL')
											aLinha := aLinhas[nX]:_CELL
											aAux := {}
											oProcess:IncRegua1("Lendo a linha: " + cValToChar(nX) )
											
											cFamilia	:= AlltoChar(aLinha[1]:_DATA:TEXT)
											cBitola		:= AlltoChar(aLinha[2]:_DATA:TEXT)
											cDescr		:= Upper(AlltoChar(aLinha[3]:_DATA:TEXT))
											cAcond		:= Upper(AlltoChar(aLinha[4]:_DATA:TEXT))
											cMetragens	:= AlltoChar(aLinha[5]:_DATA:TEXT)
											cCor		:= AlltoChar(aLinha[6]:_DATA:TEXT)
											
											AAdd(aAux,{'ZZZ_FILIAL'	, xFilial('ZZZ') } ) //Filial
											AAdd(aAux,{'ZZZ_TIPO'	, cTpReg } ) 		 //TipoRegistro
											AAdd(aAux,{'ZZZ_PROD'	, cFamilia } ) 		 //Familia
											AAdd(aAux,{'ZZZ_BITOLA'	, cBitola } )		//Bitola
											AAdd(aAux,{'DESCRICAO'	, cDescr} )			//Descricao
											AAdd(aAux,{'ZZZ_ACOND'	, cAcond} )			//Acondicionamento
											AAdd(aAux,{'ZZZ_VLRMTR'	, cMetragens} )		//Metragens
											AAdd(aAux,{'ZZZ_CODCOR'	, cCor} )			//Cores
											AAdd(aAux,{'ZZZ_UPD'	,'E'} )				//Forma de Atualização
											AAdd(aCposDet,{ (cFamilia + cBitola ), aAux, cAcond})
										EndIf
									next nX
								Else
									lOk	:= .F.
									aMsg := {'[ERRO] - Estrutura do cabeçalho está inválida!','Utilize apenas arquivos exportados pelo sistema'}
								EndIf
							next nY
							//Enviar para rotina de inclusão
							If !Empty(aCposDet)
								If execMD3(aCposDet, @oProcess)
									u_autoAlert('Processo Terminado!!',,'Box',,64)
								EndIF
							EndIf
						EndIf
					EndIf
				EndIf
				FErase(cNewName) //Apagar arquivo no server ou logar por segurança?
			EndIf
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	EndIf
	
	If !lOk
		Help(,,'Help',, aMsg[1],1,0)
	EndIf
	
Return (Nil)

/*/{Protheus.doc} MvcImExc
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Função utilizada para gerar um arquivo XML, que pode ser aberto no Excel
com informações da tabela ZZZ (Acond X Lances), este arquivo deve ser atualizado e
importado para a rotina atualizar os dados.
/*/
User Function MvcImExc(oProcess)
	local oExcel 	:= FwMsExcel():New()
	local oExl		:= nil
	local oSql 		:= nil
	local cPath		:= ""
	local aPrmBox	:= {}
	local aRet 		:= {}
	local cQry		:= ""
	local lOnlNew	:= .F.
	local oRt		:= nil
	local cDe		:= ""
	local cAte		:= ""
	local aTmpArq	:= {}
	local aSubModel	:= {"Acond.Metragem","Varejo"}
	local nX		:= 0
	local nY		:= 0
	local nZ		:= 0
	local lOk		:= .T.
	local aTabCor	:= {}
	local lVarej	:= .F.
	
	aAdd(aPrmBox,{3,"Somente Registros Novos",'Sim',{"Sim","Não"},50,"",.T.})
	aAdd(aPrmBox,{6,"Gerar Excel Em :"	,Space(50),"","","",50,.T.	,"Planilhas xml (*.xml) |*.xml",'\',GETF_RETDIRECTORY + GETF_LOCALHARD })
	aAdd(aPrmBox,{1,"Nome Arquivo"  	,Space(20),"","","","",50,.T.})
	aAdd(aPrmBox,{1,"Fam. + Bit. De:"  	,Space(5),"","","","",40,.F.})
	aAdd(aPrmBox,{1,"Fam. + Bit. Até:"  ,Space(5),"","","","",40,.T.})
	
	If ParamBox(aPrmBox ,"Exportar Configuração Excel ",@aRet/*, {||vldParam(aRet) }*/ )
		
		If U_contaChar(aRet[3], '.') > 0
			aTmpArq := StrToKArr(Alltrim(aRet[3]), '.')
			aRet[3] := aTmpArq[1]
		EndIf
		cPath:= Alltrim(aRet[2]) +  Alltrim(aRet[3]) + ".xml"
		lOnlNew := aRet[1] == 1
		cDe 	:= aRet[4]
		cAte 	:= aRet[5]
		
		FErase(cPath)
		
		for nX := 1 to len(aSubModel)
			cQry := ""
			
			oExcel:AddworkSheet(aSubModel[nX])
			oExcel:AddTable (aSubModel[nX],aSubModel[nX])
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Familia",1,1)
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Bitola",2,2)
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Descricao",3,1)
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Acondionamento",3,1)
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Metragem",1,1)
			oExcel:AddColumn(aSubModel[nX],aSubModel[nX],"Cores",3,1)
			
			cQry += " SELECT "
			cQry += " DISTINCT(SB1.B1_NOME + SB1.B1_BITOLA) AS FAM_BITOLA,"
			cQry += " SB1.B1_NOME  AS FAMILIA,"
			cQry += " SB1.B1_BITOLA AS BITOLA,"
			cQry += " Rtrim(Ltrim(SZ1.Z1_DESC)) + ' ' + Rtrim(Ltrim(SZ2.Z2_DESC)) AS DESCR,"
			cQry += "  CASE
			cQry += "  WHEN ZZZ.ZZZ_ACOND IS NULL "
			cQry += "  THEN '' "
			cQry += "  ELSE ZZZ.ZZZ_ACOND "
			cQry += "  END  AS ACOND, "
			cQry += "  CASE "
			cQry += "  WHEN ZZZ.ZZZ_VLRMTR IS NULL "
			cQry += "  THEN '' "
			cQry += "  ELSE ZZZ.ZZZ_VLRMTR "
			cQry += "  END  AS MTRG, "
			cQry += "  CASE "
			cQry += "  WHEN ZZZ.ZZZ_CODCOR IS NULL "
			cQry += "  THEN '' "
			cQry += "  ELSE ZZZ.ZZZ_CODCOR "
			cQry += "  END  AS CORES "
			cQry += " FROM SB1010 SB1  "
			cQry += " INNER JOIN SZ1010 SZ1 "
			cQry += " ON SB1.B1_FILIAL = SZ1.Z1_FILIAL "
			cQry += " AND SB1.B1_NOME = SZ1.Z1_COD "
			cQry += " AND SB1.D_E_L_E_T_ = SZ1.D_E_L_E_T_ "
			cQry += " INNER JOIN SZ2010 SZ2 "
			cQry += " ON SB1.B1_FILIAL = SZ2.Z2_FILIAL "
			cQry += " AND SB1.B1_BITOLA = SZ2.Z2_COD "
			cQry += " AND SB1.D_E_L_E_T_ = SZ2.D_E_L_E_T_ "
			
			cQry += " LEFT JOIN ZZZ010 ZZZ"
			cQry += " ON SB1.B1_FILIAL	= ZZZ.ZZZ_FILIAL"
			
			if aSubModel[nX] == "Acond.Metragem"
				cQry += " AND 'MTR'	= ZZZ.ZZZ_TIPO "
			elseif aSubModel[nX] == "Varejo"
				cQry += " AND 'VAR'	= ZZZ.ZZZ_TIPO "
			endif
			
			cQry += " AND SB1.B1_NOME	 = ZZZ.ZZZ_PROD  "
			cQry += " AND SB1.B1_BITOLA	 = ZZZ.ZZZ_BITOLA "
			cQry += " AND SB1.D_E_L_E_T_ = ZZZ.D_E_L_E_T_"
			
			cQry += " WHERE  "
			cQry += " SB1.B1_FILIAL = ''"
			cQry += " AND SB1.B1_BITOLA <> ''"
			cQry += " AND (SB1.B1_NOME + SB1.B1_BITOLA) BETWEEN '" +  cDe +"' AND '" + cAte + "'"
			cQry += " AND SB1.B1_NOME <> ''  "
			cQry += " AND SB1.B1_TIPO = 'PA'  "
			cQry += " AND SB1.B1_MSBLQL != '1' "
			
			if lOnlNew
				cQry += " AND ZZZ.ZZZ_PROD IS NULL  "
			else
				cQry += " AND NOT(ZZZ.ZZZ_PROD IS NULL)  "
			endIF
			
			cQry += " AND SB1.D_E_L_E_T_ <> '*' "
			cQry += " ORDER BY SB1.B1_NOME + SB1.B1_BITOLA ASC
			
			oSql := SqlUtil():newSqlUtil()
			
			If oSql:QryToDb( cQry ):lOk
				oRt := oSql:oRes
				oProcess:SetRegua1(oSql:nRegCount)
				For nY := 1 To oSql:nRegCount
					oProcess:IncRegua1("Gravando os dados: " + aSubModel[nX] )
					oExcel:AddRow(aSubModel[nX],aSubModel[nX],{oRt[nY]:FAMILIA,oRt[nY]:BITOLA,oRt[nY]:DESCR,oRt[nY]:ACOND,oRt[nY]:MTRG,oRt[nY]:CORES})
				Next nY
				lVarej := .T.
			else
				lOk := .F.
				Help(,,'Help',, oSql:cMsgErro,1,0)
			endif
			FreeObj(oSql)
		next nX
		if lOk .Or. lVarej
			oProcess:IncRegua1("Obtendo Tabela de cores.: " )
			if !Empty(aTabCor := retCor())
				oExcel:AddworkSheet('CODIGO_CORES')
				oExcel:AddTable ('CODIGO_CORES','CODIGO_CORES')
				oExcel:AddColumn('CODIGO_CORES','CODIGO_CORES',"Codigo",1,1)
				oExcel:AddColumn('CODIGO_CORES','CODIGO_CORES',"Cor",2,2)
				oExcel:AddColumn('CODIGO_CORES','CODIGO_CORES',"Portal",2,2)
				for nZ := 1 to len(aTabCor)
					oExcel:AddRow('CODIGO_CORES','CODIGO_CORES',aTabCor[nZ])
				next nZ
			endif
			
			oProcess:IncRegua1("Abrindo Excel.: " )
			oExcel:Activate()
			oExcel:GetXMLFile(cPath)
			oExl := MSExcel():New()
			oExl:WorkBooks:Open(cPath)
			SysRefresh()
			oExl:SetVisible(.T.)
			SysRefresh()
			oExl:= oExl:Destroy()
		endif
	EndIf
	FreeObj(oExcel)
return(nil)

/*/{Protheus.doc} MVCMd3Leg
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Utilizado para mostrar as legendas do modelo
/*/
User Function MVCMd3Leg()
	Local aLegenda := {}
	AAdd(aLegenda, {"BR_AMARELO", "Familia + Bitola com informações de Lances e Metragens"})
	AAdd(aLegenda, {"BR_VERMELHO", "Familia + Bitola sem informação de Lances e Metragens"})
	BrWLegenda("Lances x Metragem", "Status", aLegenda)
return

/*/{Protheus.doc} MVCd3PrOK
@author bolognesi
@since 29/11/2016
@version 1.0
@param oModelGrid, object, Objeto que representa a grid de dados
@type function
@description Utilizado na pré-validação da linha
/*/
Static Function MVCd3PrOK(oModelGrid, cSubModel)
	Local lRet 			:= .T.
	Local oModel 		:= oModelGrid:GetModel()
	Local nOperation 	:= oModel:getOperation() //cAcao = DELETE / MODEL_OPERATION_UPDATE
return (lRet)

/*/{Protheus.doc} MVCd3LOK
@author bolognesi
@since 29/11/2016
@version 1.0
@param oModelGrid, object, Objeto que representa a grid de dados
@type function
@description Utilizado na Pós-Validação da linha, como um linhaOk.
/*/
Static Function MVCd3LOK(oModelGrid,cSubModel)
	local lRet 			:= .F.
	local aRet			:= {}
	local oModel 			:= FWModelActive()
	local oModelZZZ 		:= nil
	local aSaveLines		:= FWSaveRows()
	local cMtrg			:= ''
	local cFamilia		:= ''
	local cBitola			:= ''
	local cCor			:= ''
	local cCodProd		:= ''
	local cModel			:= ''
	
	if Alltrim(cSubModel) == 'METRAGE'
		oModelZZZ := oModel:GetModel('ZZZMETRAGE')
		cModel := 'ZZZMETRAGE'
	elseif  Alltrim(cSubModel) == 'VAREJO'
		oModelZZZ := oModel:GetModel('ZZZVAREJO')
		cModel := 'ZZZVAREJO'
	elseif  Alltrim(cSubModel) == 'CURVA'
		oModelZZZ := oModel:GetModel('ZZZCURVA')
		cModel := 'ZZZCURVA'
	endif
	
	if cModel == 'ZZZCURVA'
		cFamilia	:= oModelZZZ:GetValue('ZZZ_PROD')
		cBitola	:= oModelZZZ:GetValue('ZZZ_BITOLA')
		cCodProd	:= oModelZZZ:GetValue('ZZZ_CODPRO')
		if !(lRet :=  substr(cCodProd, 1, len((cFamilia + cBitola))) == (cFamilia + cBitola))
			oModel:SetErrorMessage(cModel,"Codigo do Produto",  cModel , "Codigo do Produto", ,;
				'Codigo Produto foi digitado e está inválido!',;
				'Utilize F3', , )
		endif
	else
		If !Empty(oModelZZZ:GetValue('ZZZ_VLRMTR'))
			
			cMtrg	:= oModelZZZ:GetValue('ZZZ_VLRMTR')
			cFamilia:= oModelZZZ:GetValue('ZZZ_PROD')
			cBitola	:= oModelZZZ:GetValue('ZZZ_BITOLA')
			cCor	:= oModelZZZ:GetValue('ZZZ_CODCOR')
			
			if !(aRet := vldProd(oModelZZZ))[1]
				oModel:SetErrorMessage(cModel,"Metragem",cModel , "Metragem", , aRet[3],aRet[4], , )
				oModelZZZ:SetValue('ZZZ_CODCOR', "")
			else
				aRet := U_okDotSlh(cMtrg, cFamilia,cBitola,cSubModel)
				If aRet[1]
					lRet := .T.
					oModelZZZ:SetValue('ZZZ_VLRMTR', aRet[2])
				Else
					oModel:SetErrorMessage(cModel,"Metragem",  cModel , "Metragem", , aRet[3],aRet[4], , )
					oModelZZZ:SetValue('ZZZ_VLRMTR', "")
				EndIf
			endif
		EndIF
	endif
	FwRestRows(aSaveLines)
return (lRet)

/*/{Protheus.doc} okDotSlh
@author bolognesi
@since 29/11/2016
@version 1.0
@param cCont, characters, Conteudo que deve ser validado
@type function
@description Função utilizada para validar um conteudo verificando se a string
esta separada por ponto e virgula.
@example U_okDotSlh('2500')  .T.
U_okDotSlh('dumb')   .F.
U_okDotSlh('2500;')  .T.
U_okDotSlh('dumb')   .F.
U_okDotSlh(';')		 .F.
U_okDotSlh('1500;235005;dump') .F.
U_okDotSlh('100505000400') .F.
U_okDotSlh(';56233;55')  .F.
U_okDotSlh(';5623;55') .T.
U_okDotSlh('1000;55-100 20,1500') .T.
U_okDotSlh('1000-55-100-20-1500') .T.
U_okDotSlh('1000-50-100-50-1000') .F.
U_okDotSlh('1500(;788c3;9877f')   .F.
/*/
User Function okDotSlh(cCont, cFamilia, cBitola, cSubModel)
	local aRet 			:= {.T., '', '',''}
	local nDotSlsh		:= 0
	local aCont			:= {}
	local nX			:= 0
	local nY			:= 0
	local aErrHlp		:= {"",""}
	local cContOk		:= ""
	local cCaract		:= ""
	default cCont		:= ""
	default cFamilia	:= "ERRO"
	default cBitola 	:= ""
	default cSubModel	:= ""
	
	If Empty(cCont)
		aRet := {.F., '', '[ERRO]- Não existe conteudo para definir as metragens!', 'Informe o conteudo'}
	Else
		//Arrumar String
		cCont := Alltrim(cCont)
		cCont := StrTran(cCont,',',';')
		cCont := StrTran(cCont,'-',';')
		cCont := StrTran(cCont,' ',';')
		
		//Somente deve conter numeros e o separador
		For nY := 1 To Len(cCont)
			cCaract := Substr(cCont,nY,1)
			If cCaract != ";"
				If !IsDigit(cCaract)
					aRet := {.F., '', "[ "+ cFamilia +"-"+ cBitola + "] - Existem caracteres que não representam valores numericos";
						,"Para representar metragens utilize apenas numeros! Ex: 100;200;4000" }
					exit
				endIf
			EndIf
		Next nY
		
		If aRet[1]
			
			//Contar quantos ponto e virgula tem
			nDotSlsh 	:= U_contaChar(cCont, ';')
			
			//Tem somente um valor
			If nDotSlsh == 0
				//Verifiar se é numero, e tamanho maximo ok
				If ! hlpMtrg(cCont, .F.,{}, @aErrHlp, cFamilia, cBitola, cSubModel )
					aRet := {.F., '', aErrHlp[1], aErrHlp[2] }
				Else
					cContOk	+= cCont
				EndIf
				//Existe separador, provavel tenha mais de um valor
			Else
				//Obter cada um deles
				aCont := StrTokArr(cCont,';',.T.)
				//Acontece em casos que tem somente ;
					If Empty(aCont)
				aRet := {.F., '', "[ "+ cFamilia +"-"+ cBitola + "]- Não existe conteudo para definir as metragens!",;
					"Informe um conteudo para metragem!"}
			Else
				//Verificar individual
				For nX := 1 To Len(aCont)
					If hlpMtrg(aCont[nX], .T., aCont, @aErrHlp, cFamilia, cBitola, cSubModel )
						if aCont[nX] == '0'
							cContOk := '0'
							exit
						else
							If nX != Len(aCont)
								aCont[nX] += ';'
							EndIF
							cContOk	+= aCont[nX]
						endif
					Else
						aRet := {.F., '', aErrHlp[1],aErrHlp[2]}
						exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf
EndIF
If aRet[1]
	aRet := {.T., cContOk, '', ''}
EndIF
return (aRet)

/*/{Protheus.doc} hlpMtrg
@author bolognesi
@since 29/11/2016
@version 1.0
@param cCont, characters, Conteudo que deve ser validado
@param lVerRepet, logical, Logico que indica se deve ou não verificar repetição de cCont no array Base
@param aBase, array, Array base com os dados, esse array que esta em loop na chamada
@param aErrHlp, array, Variavel de referencia que recebe os resultados da função
@type function
@description Funçao com validações complementares, que auxiliam a função okDotSlh()
/*/
static function hlpMtrg(cCont, lVerRepet, aBase, aErrHlp, cFamilia, cBitola, cSubModel)
	local lRet			:= .T.
	local nX			:= 0
	local nOco			:= 0
	default aErrHlp 	:= {"",""}
	default cFamilia	:= "ERRO"
	default cBitola 	:= ""
	default cSubModel	:= ""
	
	//Verifica se tem o numero repetido
	If lVerRepet
		For nX := 1 To Len(aBase)
			If aBase[nX] == cCont
				nOco ++
			EndIF
		Next nX
		If nOco > 1
			lRet := .F.
			
			aErrHlp[1] 	:= "[ "+ cFamilia +"-"+ cBitola + " ] - O Conteudo " + cCont + " esta sendo repetido " + cValToChar(nOco) +;
				" vezes, e isso não é permitido!"
			
			aErrHlp[2]	:= "Retire os valores que estão repetidos!"
		EndIF
	EndIf
	
	If lRet
		//Verificar se é um numero
		If Val(cCont) == 0
			if Alltrim(cSubModel) == 'VAREJO'
				lRet := .F.
			else
				if !MsgNoYes('[AVISO] - Valor Definido na metragem é 0, Deseja Continuar?')
					lRet := .F.
				endif
			endif
			if !lRet
				aErrHlp[1] := "[ "+ cFamilia +"-"+ cBitola + "] - O Conteudo" + cCont + " não é do tipo numerico ou não maior que zero, obrigatorio para informar metragem!"
				aErrHlp[2] := "Utilize apenas numeros maiores que zero para definir as metragens"
			endif
		Else
			//Verifica tamanho maximo para numero(99999)
			If len(cCont) > MAX_PERMITIDO
				lRet := .F.
				aErrHlp[1] := "[ "+ cFamilia +"-"+ cBitola + "] - No Conteudo " + cCont + " existe " + cValToChar(len(cCont)) + " digitos, sendo permitido apenas " +;
					cValToChar(MAX_PERMITIDO) + " digitos!"
				aErrHlp[2] := "Utilize valores no maximo até " + Replicate('9', MAX_PERMITIDO) + "para cada valor separado por ;"
			EndIf
		EndIf
	EndIf
return(lRet)

/*/{Protheus.doc} MVCMd3TOK
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description Função para validação final no modelo de dados, funciona como o tudoOk()
/*/
Static Function MVCMd3TOK()
	local lRet 			:= .T.
	local oModel 		:= FWModelActive()
	local oView			:= FwViewActive()
	local oModelMTR 	:= oModel:GetModel('ZZZMETRAGE')
	local oModelVAR		:= oModel:GetModel('ZZZVAREJO')
	local aSaveLines	:= FWSaveRows()
	local nX			:= 0
	/*
	//oModelMTR:Length( .T. ) ==Quantidade linhas não deletadas
	for nX := 1 To oModelMTR:Length()
		//IsInserted()  IsUpdated()
		oModelMTR:isDeleted(nX)
		oModelMTR:GoLine(nX)
		//Obter Valores
		//Alert(oModelMTR:GetValue('ZZZ_BITOLA'))
		//Definir Valores
		//oModelMTR:SetValue('CAMPO', 'VALOR', 'nLINHA')
		//oModelMTR:SetErrorMessage("ZZZMETRAGE","Metragem","ZZZMETRAGE" , "Metragem", , 'HELP01','HELP02', , )
	next nX
	for nX := 1 To oModelVAR:Length()
		oModelVAR:isDeleted(nX)
		oModelVAR:GoLine(nX)
	next nX
	*/
	//Atualizar o status no modelo
	oModel:GetModel('PAIMASTER'):SetValue('TR_UPD', 'S')
	
	//Atualizar o status no arquivo temporario
	RecLock((cArea), .F.)
	(cArea)->(TR_UPD) := 'S'
	MsUnlock()
	
	//Atualiza a view
	//oView:Refresh()
	
	FwRestRows(aSaveLines)
return(lRet)

/*/{Protheus.doc} execMD3
@author bolognesi
@since 29/11/2016
@version 1.0
@type function
@description função de chamada para execauto deste MVC
/*/
Static Function execMD3(aCpos,oProcess)
	local lRet 			:= .T.
	local aCposCab 		:= {}
	local aCposDet		:= {}
	local aAux			:= {}
	local cAux			:= ""
	local nX			:= 0
	local nY			:= 0
	local nPos			:= 0
	local cChave		:= ""
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	
	//Ordernar os dados
	ASort(aCpos,,,{|x,y|  x[1] <   y[1] })
	oProcess:SetRegua2(Len(aCpos))
	BEGIN TRANSACTION
		for nX := 1 To Len(aCpos)
			oProcess:IncRegua2("Atualizando os produtos na base..." )
			//Primeiro
			if Empty(aCposDet)
				AAdd(aCposDet, aCpos[nX][2])
				//Adicionar enquanto igual
			elseIf cAux ==  aCpos[nX][1]
				AAdd(aCposDet, aCpos[nX][2])
				//Não é igual
			else
				if ! prepAuto(aCposDet, cAux)
					lRet := .F.
					disarmtransaction()
					exit
				endIf
				aCposDet :={}
				aadd(aCposDet, aCpos[nX][2])
			endIf
			cAux :=  aCpos[nX][1]
			//Para envio do ultimo
			if nX == Len(aCpos)
				if ! prepAuto(aCposDet, cAux)
					lRet := .F.
					disarmtransaction()
				endIf
			endIF
		next nX
	END TRANSACTION
	
	if !lRet
		showErro()
	else
		mkWorkTab(cArea)
		SysRefresh()
	endIf
return (lRet)

/*/{Protheus.doc} prepAuto
@author bolognesi
@since 29/11/2016
@version 1.0
@param aCpos, array, Campos para operação
@type function
@description Monta os itens master e detail, define operação
executa rotina automatica.
/*/
Static Function prepAuto(aCpos, cChave)
	local aCposCab			:= {}
	local nOper				:= 0
	local lRet				:= .T.
	local lExist			:= .F.
	local cChvHdr			:= ""
	local oArea 			:= SigaArea():newSigaArea()
	local nTamFil			:= TamSx3('ZZZ_FILIAL')[1]
	local nZZProd			:= TamSx3('ZZZ_PROD')[1]
	local nZZBit			:= TamSx3('ZZZ_BITOLA')[1]
	local nZZTipo			:= TamSx3('ZZZ_TIPO')[1]
	
	//Verificar se já existe
	oArea:saveArea( {'ZZZ'} )
	cChvHdr:= Padr(cChave, (nZZProd + nZZBit) )
	cChave := xFilial('ZZZ') + Padr('MTR' + cChave , (nTamFil + nZZTipo + nZZProd + nZZBit) )
	lExist := !Empty(Posicione("ZZZ",1, cChave ,"ZZZ_PROD" ))
	oArea:backArea()
	FreeObj(oArea)
	
	//Montar Header
	AAdd(aCposCab,{"FAM_BITOLA" ,cChvHdr})
	AAdd(aCposCab,{"FAMILIA" 	,aCpos[1][3][2]})
	AAdd(aCposCab,{"BITOLA" 	,aCpos[1][4][2]})
	AAdd(aCposCab,{"TR_DESCR"	,aCpos[1][5][2]})
	AAdd(aCposCab,{"TR_UPD"		,'S'})
	AAdd(aCposCab,{"TR_FILIAL"	,xFilial('ZZZ')})
	
	//Se existe deleta antes de incluir
	If lExist
		If ! u_zMD3Auto('', 'ZZZ', aCposCab, aCpos, MODEL_OPERATION_DELETE, cChvHdr )
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		If ! u_zMD3Auto('', 'ZZZ', aCposCab, aCpos, MODEL_OPERATION_INSERT)
			lRet := .F.
		EndIf
	EndIf
	
Return(lRet)

/*/{Protheus.doc} zMD3Auto
@author bolognesi
@since 29/11/2016
@version 1.0
@param cMaster, characters, Alias da Tebela master Ex:(SC5 + MASTER)
@param cDetail, characters, Alias da Tebela detail Ex:(SC6 + DETAILS)
@param aCpoMaster, array, Campos que devem ser utilizado na model Master
@param aCpoDetail, array, Campos que devem ser utilizado na model Details
@type function
@description Função para Rotinaas automaticas neste modelo MVC
/*/
User Function zMD3Auto(cMaster, cDetail, aCpoMaster, aCpoDetail, nOper, cChave)
	local oModel 	:= nil
	local oAux		:= nil
	local oAuxPai	:= nil
	local oAuxMtr	:= nil
	local oAuxVar	:= nil
	local oStructPai:= nil
	local oStructMtr:= nil
	local oStructVar:= nil
	local nI		:= 0
	local nJ		:= 0
	local lRet		:= .T.
	local aAux		:= {}
	local aAuxPai	:= {}
	local aAuxMtr	:= {}
	local aAuxVar	:= {}
	local nPos		:= 0
	local lAux		:= .T.
	local nItErro	:= 0
	local aErro		:= {}
	local cSubModel	:= ''
	local nLinMtr	:= 0
	local nLinVar	:= 0
	local nLin		:= 0
	
	default nOper	:= 3
	
	DbSelectArea(cDetail)
	DbSetOrder(2)
	
	DbSelectArea(cArea)
	DbSetOrder(1)
	
	//Obter o modelo de dados
	oModel := FWLoadModel('zMVCMd3M')
	
	If nOper == MODEL_OPERATION_DELETE
		If (cArea)->(MsSeek(cChave,.T.))
			oModel:SetOperation(nOper)
			oModel:Activate()
			oModel:CommitData()
		Else
			lRet := .F.
			AutoGrLog("Registro não encontrado:" 				+ ' [ ' + AllToChar(cChave) + ' ]')
		EndIf
	Else
		//3=Inclusão 4=Alteração 5=Exclusão
		oModel:SetOperation(nOper)
		
		//Ativar o modelo
		oModel:Activate()
		
		//Dados Cabeçalho
		oAuxPai 	:= oModel:GetModel('PAIMASTER')
		//Estrutura de dados e campos
		oStructPai := oAuxPai:GetStruct()
		aAuxPai	:= oStructPai:GetFields()
		for nI := 1 To Len(aCpoMaster)
			if (nPos := aScan(aAuxPai,{|x| Alltrim(x[3]) == Alltrim(aCpoMaster[nI][1] ) })) > 0
				if !( lAux := oModel:SetValue('PAIMASTER', aCpoMaster[nI][1], aCpoMaster[nI][2]))
					lRet := .F.
					exit
				endIf
			endIf
		next nI
		
		//Dados dos itens
		if lRet
			oAuxMtr 	:= oModel:getModel('ZZZMETRAGE')
			oStructMtr	:= oAuxMtr:GetStruct()
			aAuxMtr		:= oStructMtr:GetFields()
			
			oAuxVar		:= oModel:getModel('ZZZVAREJO')
			oStructVar	:= oAuxVar:GetStruct()
			aAuxVar		:= oStructVar:GetFields()
			
			nItErro := 0
			for nI := 1 To Len(aCpoDetail)
				
				if aCpoDetail[nI,2,2] == 'MTR'
					cSubModel := 'ZZZMETRAGE'
					nLin 	:= (++nLinMtr)
					aAux	:= aAuxMtr
					oAux	:= oAuxMtr
				elseif aCpoDetail[nI,2,2] == 'VAR'
					cSubModel := 'ZZZVAREJO'
					nLin 	:= (++nLinVar)
					aAux	:= aAuxVar
					oAux	:= oAuxVar
				endif
				
				If nLin > 1
					if ( nItErro := oAux:AddLine() ) <> nLin
						lRet := .F.
						exit
					endif
				endif
				for nJ := 1 To Len(aCpoDetail[nI])
					if ( nPos := aScan(aAux, {|x| Alltrim(x[3]) == Alltrim(aCpoDetail[nI][nJ][1]) })) > 0
						if !( lAux := oModel:SetValue(cSubModel, aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2]))
							lRet := .F.
							nItErro := nI
							Exit
						endIf
					endIf
				next nJ
				if !lRet
					Exit
				endIf
			next nI
		endIf
		
		If lRet
			//Validar os dados
			If (lRet := oModel:VldData())
				oModel:CommitData()
			EndIf
		EndIf
		
		If !lRet
			aErro := oModel:GetErrorMessage()
			AutoGrLog("Mensagem do Erro:" 				+ ' [ ' + AllToChar(aErro[6]) + ' ]')
			AutoGrLog("Mensagem da Solução:" 			+ ' [ ' + AllToChar(aErro[7]) + ' ]')
			AutoGrLog("Valor Atribuido:" 				+ ' [ ' + AllToChar(aErro[8]) + ' ]')
			AutoGrLog("Valor Anterior:" 				+ ' [ ' + AllToChar(aErro[9]) + ' ]')
			
			If nItErro > 0
				AutoGrLog( "Erro no item:    " + ' [ ' + Alltrim(AllToChar(nItErro)) + ' ]' )
			EndIf
		EndIf
	EndIf
	oModel:DeActivate()
	
return (lRet)

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 29/11/2016
@version 1.0
@param oErr, object, Objeto contendo informações sobre o erro
@param lOk, logical, Variavel de referencia informa o erro ( .F. )
@param aMsg, array, Variavel de referencia informa a mensagem do erro
@type function
@description Função para tratamento personalizado de erro
/*/
Static function HandleEr(oErr, lOk, aMsg)
	lOk := .F.
	aMsg := { '[' + oErr:Description + ']', oErr:ERRORSTACK }
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	BREAK
return

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 29/11/2016
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Utilizado para logar as mensagens de erro no console
/*/
static function ConsoleLog(cMsg)
	ConOut("[Cadastro_Acond_Mtr_Lances - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return

/*/{Protheus.doc} showErro
@author bolognesi
@since 01/12/2016
@version 1.0
@type function
@description Esta função serve para mostrar a tela de erro da rotina automática.
/*/
Static Function showErro()
	Local nX		:= 0
	Local cMsg		:= ""
	Local aErro		:= {}
	
	DisarmTransaction()
	aErro := GetAutoGrLog()
	For nX := 1 To Len(aErro)
		cMsg +=  aErro[nX] + IIF(nX == Len(aErro),'',Chr(13))
	Next nX
	mkWorkTab(cArea)
	SysRefresh()
	If !Empty(cMsg)
		u_autoAlert(cMsg,,'Box',,16)
	EndIF
return (nil)

Static Function vldParam(aRet)
	Local	lRet := .T.
	/*
	If !Empty(aRet[6]) .And. aRet[1] == 1
		lRet := .F.
		U_AutoAlert('[ERRO] - Novos registros não podem receber filtro de acondicionamento!' )
	EndIf
	*/
Return lRet



// Filtro utilizado na consulta padrão "ZCODPAD", utilizada no campo ZZZ_CODPRO
user function ZZZFILTER()
	local cFiltro := ''
	local cProd	:= Alltrim(FWFldGet("ZZZ_PROD"))
	local cBit	:= Alltrim(FWFldGet("ZZZ_BITOLA"))
	
	cFiltro += "@#"
	cFiltro += " SB1->("
	cFiltro += "Alltrim(B1_NOME) == '" + cProd + "' "
	cFiltro += " .AND. "
	cFiltro += "Alltrim(B1_BITOLA) == '" + cBit + "' "
	cFiltro += " .AND. "
	cFiltro += " !('I' $ B1_COD ) "
	cFiltro += ")"
	cFiltro +="@#"
	
return(cFiltro)


/*/{Protheus.doc} ZZZCOR
@author bolognesi
@since 20/01/2017
@version 1.0
@param oView, object, objeto view para
definir o conteudo do campo ZZZ_CODCOR
@type function
@description função para preencher o campo de cor
do grid, ela exibe a consulta padrão SZ3COR, para
o usuario selecionar a cor desejada e obtem o retorno
inserindo-o no campo ZZZ_CODCOR, formatando com ponto
e virgula.
Junto foi criada a consulta especifica "ESPCOR" que chama
esta função tambem, caso necessario utilizar pelo F3.
Decidi deixar o campo somente visual e o preenche-lo atraves de uma chamada
a este função pelo ações relacionadas da view.
/*/
User function ZZZCOR(oView)
	local oModelZZZ := nil
	local cAtual	:= ""
	local aAtual	:= {}
	local cNovo		:= ""
	local nX		:= 0
	local nPos		:= 0
	local aRet		:= {}
	local cCor		:= ''
	
	if !empty(oModelZZZ := getActFolder(oView))
		if ! oModelZZZ:isDeleted()
			//Exibir a consulta padrão do SZ3COR
			if Conpad1(,,,"SZ3COR")
				cCor := Alltrim(SZ3->(Z3_COD))
				if !(aRet := vldProd(oModelZZZ,cCor))[1]
					Help( ,, 'ZZZ_CODCOR','Cores', aRet[3],1,0,,,,,,{aRet[4]})
				else
					//Obter o conteudo atual do grid
					cAtual := oModelZZZ:GetValue('ZZZ_CODCOR')
					//Definir se é primeira inclusão ou esta adicionando
					if !empty(cAtual)
						//Conteudo atual não é vazio
						//Obtem do conteudo um array com as cores
						aAtual := StrToKArr(cAtual,';')
						//Procurar a cor selecionada pára adição no array (Evitar duplicidade)
						nPos := AScan(aAtual,{|a| Alltrim(a) == cCor} )
						
						//Somente adicionar se não encontrar
						if nPos == 0
							//Adicionar o valor selecionado ao array existente (para poder ordenar)
							aadd(aAtual, cCor  )
							//Ordenar o array antes de voltar para string
							ASort(aAtual,,,{|x,y| x < y})
							//Passar o conteudo do array para string separada ponto e virgula
							for nX := 1 to len(aAtual)
								cNovo += Alltrim(aAtual[nX])
								if nX != len(aAtual)
									cNovo += ';'
								endif
							next nX
							//Adicionar o novo valor ao campo na grid
							oModelZZZ:SetValue( 'ZZZ_CODCOR', Alltrim(cNovo)  )
						endif
					else
						//Atual vazio, primeira inclusão, adiciona apenas o valor selecionado
						oModelZZZ:SetValue( 'ZZZ_CODCOR', cCor  )
					endif
				endif
			endif
		endif
	endif
return(nil)

/*/{Protheus.doc} ZZZRECOR
@author bolognesi
@since 23/01/2017
@version 1.0
@param oView, object, objeto view
@type function
@description Função para visualizar e remover as cores
do grid, realizando os tratamentos necessarios
/*/
User function ZZZRECOR(oView)
	local oModelZZZ := nil
	local cAtual	:= ""
	local aAtual	:= {}
	local cNovo		:= ""
	local cSrch		:= ""
	local nX		:= 0
	local nPos		:= 0
	local aPergs 	:= {}
	local aRet		:= {}
	local aCor		:= {}
	
	if !empty(oModelZZZ := getActFolder(oView))
		//Realizar o processo somente em linha não deletada
		if ! oModelZZZ:isDeleted()
			//Obter os dados atuais do campo
			cAtual := oModelZZZ:GetValue('ZZZ_CODCOR')
			//Somente inicia o proesso de excluir se tiver conteudo
			if !empty(cAtual)
				//Passa conteudo da string para o Array
				aAtual := StrToKArr(cAtual,';')
				
				if len(aAtual) > 0
					//Antes de chamar o parambox, criar array com os nomes das cores
					for nX := 1 to len(aAtual)
						aadd(aCor,  Alltrim(aAtual[nX]) + '-' + Alltrim( Posicione("SZ3",1,xFilial("SZ3") + padr(aAtual[nX], TamSx3("Z3_DESC")[1]) ,"Z3_DESC") ) )
					next nX
					//Exibir as cores para consulta ou seleção de exclusão
					aAdd(aPergs,{2,"Excluir Cor: ","",aCor,120,"",.F.})
					//Exibir o parambox
					if ParamBox(aPergs ,"Excuir ",@aRet)
						//Ultima confirmação antes do processo de exclusão
						if MsgNoYes('Confirma exclusão da cor: ' + aRet[1])
							//Obtem o codigo da cor
							cSrch := SubStr(aRet[1],1,2)
							//Verifica se a cor selecionada existe no array
							nPos := AScan(aAtual,{|a| Alltrim(a) == Alltrim(cSrch)} )
							if nPos > 0
								//Deletar o elemento do array
								ADel(aAtual, nPos)
								//Redimensionar o array
								ASize(aAtual, (Len(aAtual) - 1)  )
								//Se ainda sobrou conteudo
								if len(aAtual) > 0
									//Ordenar o conteudo restante
									ASort(aAtual,,,{|x,y| x < y })
									//Passar de array para string
									for nX := 1 to len(aAtual)
										cNovo += Alltrim(aAtual[nX])
										if nX != Len(aAtual)
											cNovo += ";"
										endif
									next nX
								else
									//Exclui todos os elementos
									cNovo := ""
								endif
							endif
							//Atrinuir o novo valor ao campo
							oModelZZZ:SetValue( 'ZZZ_CODCOR', Alltrim(cNovo)  )
						endif
					endif
				endif
			endif
		endif
	endif
return(nil)

/*/{Protheus.doc} getActFolder
@author bolognesi
@since 29/06/2017
@version 1.0
@param oView, object, Objeto VIEW
@type function
@description Identificar atraves do oView, qual o folder ativo, e atraves deset folder
ativo obter o submodel em questão.
/*/
static function getActFolder(oView)
	local oModel 	:= FWModelActive()
	local oModelZZZ := nil
	local cFolder	:= oView:GETFOLDERACTIVE('FOLDER_DETAILS',2)[2]
	if !empty(cFolder)
		if Alltrim(cFolder) == 'METRAGEM'
			oModelZZZ := oModel:GetModel('ZZZMETRAGE')
		elseif Alltrim(cFolder) == 'VAREJO'
			oModelZZZ := oModel:GetModel('ZZZVAREJO')
		elseif Alltrim(cFolder) == 'CURVA'
			oModelZZZ := oModel:GetModel('ZZZCURVA')
		endif
	endif
return(oModelZZZ)

/*/{Protheus.doc} retCor
@author bolognesi
@since 29/06/2017
@version 1.0
@type function
@description Obter array com todas as cores da tabela SZ3
/*/
static function retCor(cCod)
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aRet		:= {}
	local cQry		:= ''
	default cCod	:= ''
	
	cQry += " SELECT SZ3.Z3_COD AS COD, SZ3.Z3_DESC AS NOME, SZ3.Z3_XPORTAL AS PORTAL "
	cQry += " FROM %SZ3.SQLNAME% "
	
	if empty(cCod)
		cQry += " WHERE  SZ3.Z3_DESC <> '' AND %SZ3.NOTDEL% "
	else
		cQry += " WHERE  SZ3.Z3_DESC <> '' AND SZ3.Z3_COD = '" + cCod + "' AND %SZ3.NOTDEL% "
	endif
	
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aCor := {oSql:getValue("AllTrim(COD)"),oSql:getValue("AllTrim(NOME)"),oSql:getValue("AllTrim(PORTAL)")}
			aadd(aRet,aCor)
			oSql:skip()
		enddo
		oSql:close()
		FreeObj(oSql)
	endif
return(aRet)

/*/{Protheus.doc} ExistPrd
@author bolognesi
@since 25/07/2017
@version 1.0
@param cCod, characters, Familia Bitola e Cor
@type function
@description Verifica se uma Familia Bitola e Cor existe
no cadastro de produtos e não esta bloqueada B1_MSBLQL
/*/
static function ExistPrd(cCod)
	local oSql 		:= nil
	local lRet		:= .F.
	local cQry		:= ''
	default cCod	:= ''
	if !empty(cCod)
		oSql := LibSqlObj():newLibSqlObj()
		
		cQry += " SELECT B1_COD AS COD "
		cQry += " FROM %SB1.SQLNAME% "
		cQry += " WHERE %SB1.XFILIAL% "
		cQry += " AND B1_COD LIKE '" + cCod + "%' "
		cQry += " AND B1_MSBLQL	<> '1' "
		cQry += " AND %SB1.NOTDEL% "
		
		oSql:newAlias(cQry)
		lRet := oSql:hasRecords()
		oSql:close()
		FreeObj(oSql)
	endif
return(lRet)

/*/{Protheus.doc} vldProd
@author bolognesi
@since 25/07/2017
@version 1.0
@param oMdlZZZ, object, Modelo de dados utilizado
@type function
/*/
static function vldProd(oMdlZZZ,cCodCor)
	local aRet 		:= {.T., '', '',''}
	local cFamilia	:= ''
	local cBitola	:= ''
	local cCor		:= ''
	local cNomeCor	:= ''
	local nX		:= 0
	local aCor		:= {}
	local nNomeCor	:= 2
	default oMdlZZZ := nil
	default cCodCor := ''
	
	if !empty(oMdlZZZ)
		cFamilia:= Alltrim(oMdlZZZ:GetValue('ZZZ_PROD'))
		cBitola	:= Alltrim(oMdlZZZ:GetValue('ZZZ_BITOLA'))
		if !empty(cCodCor)
			cCor := Alltrim(cCodCor)
		else
			cCor	:= Alltrim(oMdlZZZ:GetValue('ZZZ_CODCOR'))
			cCor 	:= Alltrim(StrTran(StrTran(StrTran(cCor,' ',';'),'-',';'),',',';'))
		endif
		
		aCor := StrTokArr(cCor,';',.T.)
		for nX := 1 to len(aCor)
			if empty(cNomeCor := retCor(aCor[nX]))
				aRet := {.F., '', 'Codigo de Cor: ' + aCor[nX] + ' não existente'   ,'utilize um codigo existente'}
				exit
			elseif !ExistPrd(cFamilia + cBitola + aCor[nX])
				aRet := {.F., '', 'Para Familia: ' + cFamilia + ' Bitola: ' + cBitola +;
					' não existe a cor: ' + Alltrim(cNomeCor[1,nNomeCor]) + ' cadastrada ou esta bloqueada. '   ,'Informe o responsavel pelo cadastro de produtos!'}
				exit
			endif
		next nX
	endif
return (aRet)


User Function zzzXLSX(cChave, cAcond) //U_zzzXLSX('1150401401' , 'R00100;M01400')
	//INTEGRAÇÃO EXCEL (Utilizado na carga inicial)
	//NO EXCEL UTILIZAR " =Siga("U_zzzXLSX";ARRUMAR(A2);ARRUMAR(I2)) "
	local cRetorno 		:= ""
	local oSql 			:= Nil
	local oRet			:= Nil
	local nX			:= 0
	local nY			:= 0
	local aAcondMtr		:= {}
	local inAcond		:= ''
	local cLastAcond	:= ''
	local cVlrMtr		:= ''
	local aCorAnt		:= {}
	local nPos			:= 0
	local cCorLoop		:= ''
	
	default cChave 		:= ""
	default cAcond 		:= ""
	
	dbSelectArea('ZZZ')
	
	if ValType(cChave) == 'N'
		cChave := cValToChar(cChave)
	endIF
	
	if Empty(cChave) .Or. Empty(cAcond)
		cRetorno := "Erro - Todos os parametros são obrigatorios"
	else
		aAcondMtr := StrToKArr( Alltrim(cAcond) ,';' )
		for nX := 1 to Len(aAcondMtr)
			inAcond += " '" + Left(aAcondMtr[nX],1) + "' "
			if nX < Len(aAcondMtr)
				inAcond += ','
			endif
		next nX
		
		oSql 	:= SqlUtil():newSqlUtil()
		oSql:addFromTab('ZZZ')
		oSql:addCampos({'ZZZ.R_E_C_N_O_','ZZZ_ACOND', 'ZZZ_VLRMTR', 'ZZZ_CODCOR'})
		oSql:addWhere("ZZZ_FILIAL = '' ")
		oSql:addWhere("ZZZ_TIPO = 'VAR' ")
		oSql:addWhere("ZZZ_PROD = '" + SubStr(Alltrim(cChave),1,3)  +"' ")
		oSql:addWhere("ZZZ_BITOLA = '" + SubStr(Alltrim(cChave),4,2)  +"' ")
		oSql:addWhere("ZZZ_ACOND IN ( " + inAcond  + ' )' )
		
		if oSql:QrySelect():lOk
			cRetorno += 'Excluindo registros ' + chr(13)
			oRet := oSql:oRes
			for nX := 1 To Len(oRet)
				AAdd(aCorAnt, { oRet[nX]:ZZZ_ACOND, StrToKArr(oRet[nX]:ZZZ_CODCOR,';') } )
				ZZZ->( DbGoTo(oRet[nX]:R_E_C_N_O_) )
				RecLock("ZZZ",.F.)
				ZZZ->(DbDelete())
				MsUnLock()
			next Nx
		endIf
		
		cRetorno += 'Adicionando registro ' + 'Produto ' + SubStr(Alltrim(cChave),1,3) +;
			'Bitola ' + SubStr(Alltrim(cChave),4,2) +;
			'Produto ' + SubStr(Alltrim(cChave),1,3) +  chr(13)
		
		dbSelectArea('ZZZ')
		ASort(aAcondMtr,,,{|x,y| x < y})
		for nY := 1 to Len(aAcondMtr)
			if Left(aAcondMtr[nY],1) <> cLastAcond
				cLastAcond := Left(aAcondMtr[nY],1)
				reclock('ZZZ', .T.)
				ZZZ->(ZZZ_PROD) 	:= SubStr(Alltrim(cChave),1,3)
				ZZZ->(ZZZ_BITOLA)	:= SubStr(Alltrim(cChave),4,2)
				ZZZ->(ZZZ_ACOND) 	:= Left(aAcondMtr[nY],1)
				
				for nX := 1 to Len(aAcondMtr)
					cVlrMtr := ''
					if( Left(aAcondMtr[nY],1) == Left(aAcondMtr[nX],1) )
						cVlrMtr	+=  CValToChar(Val(Right(aAcondMtr[nX],(Len(aAcondMtr[nX]) -1))))
						if nX < Len(aAcondMtr) .And. Left(aAcondMtr[nY],1) == Left(aAcondMtr[nX + 1],1)
							cVlrMtr	+= ';'
						endif
						ZZZ->(ZZZ_VLRMTR)	:= cVlrMtr
					endif
				next Nx
				
				if (nPos := AScan(aCorAnt,{|a| a[1] == Left(aAcondMtr[nY],1) })) >0
					if !( AScan(aCorAnt[nPos][2], {|a| a == SubStr(Alltrim(cChave),6,2)}) > 0 )
						AAdd(aCorAnt[nPos][2], SubStr(Alltrim(cChave),6,2) )
						ASort(aCorAnt[nPos][2],,,{|x,y| x < y})
					endif
					cCorLoop := ''
					for nX := 1 To len(aCorAnt[nPos][2])
						cCorLoop += aCorAnt[nPos][2][nX]
						if nX < len(aCorAnt[nPos][2])
							cCorLoop += ';'
						endif
					next nX
				else
					cCorLoop := SubStr(Alltrim(cChave),6,2)
				endif
				
				ZZZ->(ZZZ_CODCOR)	:= cCorLoop
				ZZZ->(ZZZ_TIPO) 	:= 'VAR'
				ZZZ->(MsUnlock())
			endif
		next nY
		FreeObj(oSql)
	endIF
return cRetorno
