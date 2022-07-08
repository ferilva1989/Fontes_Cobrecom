#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#include "tbiconn.ch"

user function zCbSepar()
	local oBrw 	:= nil 	
	local aOnlFld	:= {}
	local cFiltro	:= ''

	aadd(aOnlFld, 'C5_FILIAL')
	aadd(aOnlFld, 'C5_NUM')
	aadd(aOnlFld, 'C5_CLIENTE')
	aadd(aOnlFld, 'C5_LOJACLI')
	aadd(aOnlFld, 'C5_FILIAL')
	aadd(aOnlFld, 'C5_EMISSAO')
	aadd(aOnlFld, 'C5_ENTREG')
	aadd(aOnlFld, 'C5_DTFAT')
	aadd(aOnlFld, 'C5_TPFRETE')
	aadd(aOnlFld, 'C5_OBS')
	aadd(aOnlFld, 'C5_ENDENT1')
	aadd(aOnlFld, 'C5_ENDENT2')
	oBrw := FWmBrowse():New()
	oBrw:SetDescription('Expedição Pedidos')
	oBrw:SetAlias('SC5')
	oBrw:SetMenuDef('cbcSeparacao')
	// oBrw:SetDoubleClick({||FWMsgRun(,{|oSay|dblClickBrw(cAls)},"Atualizando","Atualizando...")})
	// oBrw:SetChange({||FWMsgRun(,{|oSay|chnBrw(cAls)},"Atualizando","Atualizando...")})
	oBrw:DisableDetails()
	if !empty(aOnlFld)
		oBrw:SetOnlyFields(aOnlFld)
	endif
	
	cFiltro	+= " C5_TIPO == 'N' "
	oBrw:SetFilterDefault( cFiltro )
	oBrw:AddLegend("C5_TIPO=='N'","GREEN" 	,"Normal")
	oBrw:Activate()
	
return(nil)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSeparacao' 	OPERATION MODEL_OPERATION_VIEW   	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Fardos/Volumes'  ACTION "u_cdest08()" 		OPERATION 6  ACCESS 0 //OPERATION X
return(aRotina)


static function ModelDef()
	local oStruSC5 		:= FWFormStruct( 1, 'SC5', {|campo| filterMod(campo, 'PEDIDO')})
	local oStruSC6 		:= FWFormStruct( 1, 'SC6', {|campo| filterMod(campo, 'ITENS')})
	local oStruSC9 		:= FWFormStruct( 1, 'SC9', {|campo| filterMod(campo, 'LIB')})
	local oStruSZN 		:= FWFormStruct( 1, 'SZN', {|campo| filterMod(campo, 'VOLUMES')})
	local oStruSDC 		:= FWFormStruct( 1, 'SDC', {|campo| filterMod(campo, 'EMPENHO')})
	local oStruSZE 		:= FWFormStruct( 1, 'SZE', {|campo| filterMod(campo, 'BOBINAS')})
	local oStruZZO 		:= FWFormStruct( 1, 'ZZO', {|campo| filterMod(campo, 'VOLUME_OS')})
	local oStruZZR 		:= FWFormStruct( 1, 'ZZR', {|campo| filterMod(campo, 'LOG_OS')})
	local aRelPedItm		:= {}
	local aRelPedLib		:= {}
	local aRelPedVol		:= {}
	local aRelItmEmp		:= {}
	local aRelItmSld		:= {}
	local aRelPedZZo		:= {}
	local aRelPedZZr		:= {}
	local aRelPedBob		:= {}
	
	oModel := MPFormModel():New('Controle de Expedição')
	oModel:SetOnDemand(.T.)
	
	oModel:AddFields('SC5_PEDIDO_MASTER',/*cOwner*/,oStruSC5)
	oModel:AddGrid('SC6_PEDIDO_GRID'	,'SC5_PEDIDO_MASTER'	,oStruSC6)
	oModel:AddGrid('SC9_PEDIDO_LIB'		,'SC6_PEDIDO_GRID'	,oStruSC9)
	oModel:AddGrid('SZN_PEDIDO_VOL'		,'SC5_PEDIDO_MASTER'	,oStruSZN)
	oModel:AddGrid('SDC_ITEM_EMP'		,'SC5_PEDIDO_MASTER'	,oStruSDC)
	oModel:AddGrid('SZE_ITEM_BOB'		,'SC5_PEDIDO_MASTER'	,oStruSZE)
	oModel:AddGrid('ZZO_PED_VOL'		,'SC5_PEDIDO_MASTER'	,oStruZZO)
	oModel:AddGrid('ZZR_LOG_OS'		,'SC5_PEDIDO_MASTER'	,oStruZZR)
	
	// Somente visualização
	oModel:GetModel('SC5_PEDIDO_MASTER'):SetOnlyView(.T.)
	oModel:GetModel('SC6_PEDIDO_GRID'):SetOnlyView(.T.)
	oModel:GetModel('SC9_PEDIDO_LIB'):SetOnlyView(.T.)
	oModel:GetModel('SDC_ITEM_EMP'):SetOnlyView(.T.)
	oModel:GetModel('SZE_ITEM_BOB'):SetOnlyView(.T.)
	
	// Não são obrigatorios
	oModel:GetModel('SC6_PEDIDO_GRID'):SetOptional(.T.)
	oModel:GetModel('SC9_PEDIDO_LIB'):SetOptional(.T.)
	oModel:GetModel('SDC_ITEM_EMP'):SetOptional(.T.)
	oModel:GetModel('SZE_ITEM_BOB'):SetOptional(.T.)
	
	// Relacionamento Pedido Master com Pedido Grid
	aAdd(aRelPedItm,  { 'C6_FILIAL'			, 'C5_FILIAL'} )
	aAdd(aRelPedItm,  { 'C6_NUM'			, 'C5_NUM'} )
	oModel:SetRelation('SC6_PEDIDO_GRID'	, aRelPedItm, SC6->(IndexKey(1)))
	
	// Relacionamento Pedido Master com Liberações
	aAdd(aRelPedLib,  {'C9_FILIAL'			, 'C6_FILIAL'} )
	aAdd(aRelPedLib,  {'C9_PEDIDO'			, 'C5_NUM'} )
	aAdd(aRelPedLib,  {'C9_ITEM'			, 'C6_ITEM'} )
	oModel:SetRelation('SC9_PEDIDO_LIB'		, aRelPedLib, SC9->(IndexKey(1)))
	
	// Relacionamento Pedido Master com Volumes
	aAdd(aRelPedVol,  {'ZN_FILIAL'		, 'C5_FILIAL'} )
	aAdd(aRelPedVol,  {'ZN_PEDIDO'		, 'C5_NUM'} )
	oModel:SetRelation('SZN_PEDIDO_VOL'	, aRelPedVol, SZN->(IndexKey(2)))
	
	// Relacionamento Pedido Master com Empenhos
	aAdd(aRelItmEmp,  {'DC_FILIAL'		, 'C5_FILIAL'} )
	aAdd(aRelItmEmp,  {'DC_PEDIDO'		, 'C5_NUM'} )
	oModel:SetRelation('SDC_ITEM_EMP'	, aRelItmEmp, SDC->(IndexKey(4)))
	
	// Relacionamento Pedido Master com Bobinas
	aAdd(aRelPedBob,  {'ZE_FILIAL'		, 'C5_FILIAL'} )
	aAdd(aRelPedBob,  {'ZE_PEDIDO'		, 'C5_NUM'} )
	oModel:SetRelation('SZE_ITEM_BOB'	, aRelPedBob, SZE->(IndexKey(2)))
	
	// Relacionamento Produto Master com Volumes OS
	aAdd(aRelPedZZo,  {'ZZO_FILIAL'		, 'C5_FILIAL'} )
	aAdd(aRelPedZZo,  {'ZZO_PEDIDO'		, 'C5_NUM'} )
	oModel:SetRelation('ZZO_PED_VOL'	, aRelPedZZo, ZZO->(IndexKey(1)))
	
	// Relacionamento Produto Master com Logs OS
	aAdd(aRelPedZZr,  {'ZZR_FILIAL'		, 'C5_FILIAL'} )
	aAdd(aRelPedZZr,  {'ZZR_PEDIDO'		, 'C5_NUM'} )
	oModel:SetRelation('ZZR_LOG_OS'		, aRelPedZZr, ZZR->(IndexKey(1)))
	
	oModel:SetPrimaryKey({})
	
	// Definindo a descrição dos models
	oModel:GetModel('SC5_PEDIDO_MASTER'):SetDescription('Pedidos')
	oModel:GetModel('SC6_PEDIDO_GRID'):SetDescription('Itens')
	oModel:GetModel('SC9_PEDIDO_LIB'):SetDescription('Liberados')
	oModel:GetModel('SZN_PEDIDO_VOL'):SetDescription('Volumes')
	oModel:GetModel('SDC_ITEM_EMP'):SetDescription('Empenhos')
	oModel:GetModel('SZE_ITEM_BOB'):SetDescription('Bobinas')
	oModel:GetModel('ZZO_PED_VOL'):SetDescription('Volumes OS')
	oModel:GetModel('ZZR_LOG_OS'):SetDescription('Log OS')
	
return(oModel)


static Function ViewDef(oMdl)
	
	local oStruSC5 		:= FWFormStruct( 2, 'SC5', {|campo| filterView(campo, 'PEDIDO')})
	local oStruSC6 		:= FWFormStruct( 2, 'SC6', {|campo| filterView(campo, 'ITENS')})
	local oStruSC9 		:= FWFormStruct( 2, 'SC9', {|campo| filterView(campo, 'LIB')})
	local oStruSZN 		:= FWFormStruct( 2, 'SZN', {|campo| filterView(campo, 'VOLUMES')})
	local oStruSDC 		:= FWFormStruct( 2, 'SDC', {|campo| filterView(campo, 'EMPENHO')})
	local oStruSZE 		:= FWFormStruct( 2, 'SZE', {|campo| filterView(campo, 'BOBINAS')})
	local oStruZZO 		:= FWFormStruct( 2, 'ZZO', {|campo| filterView(campo, 'VOLUME_OS')})
	local oStruZZR 		:= FWFormStruct( 2, 'ZZR', {|campo| filterView(campo, 'LOG_OS')})
	local aName			:= {}
	local nX				:= 0
	default oMdl        	:= FWLoadModel('cbcSeparacao')
	
	oView := FWFormView():New()
	oView:SetModel(FWLoadModel('cbcSeparacao'))
	oView:SetProgressBar(.T.)
	
	oView:AddField('PEDIDO_MASTER'	,oStruSC5	,'SC5_PEDIDO_MASTER')
	oView:AddGrid('PEDIDO_GRID'	,oStruSC6	,'SC6_PEDIDO_GRID')
	oView:AddGrid('LIBER_SC9_GRID'	,oStruSC9	,'SC9_PEDIDO_LIB')
	oView:AddGrid('VOL_SZN_GRID'	,oStruSZN	,'SZN_PEDIDO_VOL')
	oView:AddGrid('EMP_SDC_GRID'	,oStruSDC	,'SDC_ITEM_EMP')
	oView:AddGrid('BOB_SZE_GRID'	,oStruSZE	,'SZE_ITEM_BOB')
	oView:AddGrid('VOL_ZZO_GRID'	,oStruZZO	,'ZZO_PED_VOL')
	oView:AddGrid('LOG_ZZR_GRID'	,oStruZZR	,'ZZR_LOG_OS')
	
	// Pedido parte de cima
	oView:CreateHorizontalBox('HB_PEDIDO_MASTER',30)
	oView:SetOwnerView('PEDIDO_MASTER','HB_PEDIDO_MASTER')
	
	// Folder parte de baixo
	oView:CreateHorizontalBox('HB_CONTAINER_VERTICAL',70)
	oView:CreateFolder('MAIN_FOLDER', 'HB_CONTAINER_VERTICAL')
	
	oView:AddSheet('MAIN_FOLDER','SHEET_ITNS','Itens/Liber.')
	oView:CreateHorizontalBox( 'BOX_ITEM_LIB', 100,,,'MAIN_FOLDER', 'SHEET_ITNS')
	oView:CreateVerticalBox( 'ITEM_PED_V', 50, 'BOX_ITEM_LIB',, 'MAIN_FOLDER', 'SHEET_ITNS')
	oView:CreateVerticalBox( 'LIBER_ITEM_V', 50, 'BOX_ITEM_LIB',, 'MAIN_FOLDER', 'SHEET_ITNS')
	oView:SetOwnerView('PEDIDO_GRID','ITEM_PED_V')
	oView:SetOwnerView('LIBER_SC9_GRID','LIBER_ITEM_V')
	oView:EnableTitleView('PEDIDO_GRID','Itens Pedido')
	oView:EnableTitleView('LIBER_SC9_GRID','Liber.Itens')
	
	aadd(aName,{'VOL_SZN_GRID','Vol.SZN'})
	aadd(aName,{'EMP_SDC_GRID','Empenhos'})
	aadd(aName,{'BOB_SZE_GRID','Bobinas'})
	aadd(aName,{'VOL_ZZO_GRID','Vol.ZZO'})
	aadd(aName,{'LOG_ZZR_GRID','Log.ZZR'})
	for nX := 1 to Len(aName)
		makeFolder(@oView,aName[nX,1],aName[nX,2])
	next nX
	
	// Opções disponibilizadas
	oView:AddUserButton('Rel.Fardos'	, 'CLIPS', {|oView| U_CDEST08g()})
	oView:SetCloseOnOk({||.T.})
	
return(oView)


static function makeFolder(oView,cSheet,cDescr)
	local cSheetID 	:= 'SHEET_' + cSheet
	local cSheetName	:= 'GRID_' + cSheet
	oView:AddSheet('MAIN_FOLDER',cSheetID,cDescr)
	oView:CreateHorizontalBox( cSheetName, 100,,,'MAIN_FOLDER', cSheetID)
	oView:SetOwnerView(cSheet,cSheetName)
	oView:EnableTitleView(cSheet,cDescr)
	// oView:SetViewProperty(cSheet, "GRIDSEEK", {.T.})
return(nil)


static function filterMod(campo, cFrom)
	local lRet		:= .T.
	local aNotShow	:= {}
	
	if cFrom == 'ITENS'
		aadd(aNotShow,'C6_INFAD')
		aadd(aNotShow,'C6_CODINF')
	endif
	
	lRet := !(Ascan(aNotShow, {|a| Alltrim(a) == Alltrim(campo) }) > 0)
	
return(lRet)


static function filterView(campo, cFrom)
	local lRet		:= .T.
	local aNotShow	:= {}
	
	if cFrom == 'ITENS'
		aadd(aNotShow,'C6_INFAD')
		aadd(aNotShow,'C6_CODINF')
	endif
	
	lRet := !(Ascan(aNotShow, {|a| Alltrim(a) == Alltrim(campo) }) > 0)
	
return(lRet)
