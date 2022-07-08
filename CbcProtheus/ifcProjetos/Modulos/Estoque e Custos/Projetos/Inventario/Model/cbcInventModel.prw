#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function cbcMainInvent()
	local oBrowse := nil
	
	DbSelectArea('ZZB')
	ZZB->(DbSetOrder(1))
	DbSelectArea('ZZC')
	ZZC->(DbSetOrder(1))
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZZB')
	oBrowse:SetDescription('Inventário')
	oBrowse:SetTemporary(.F.)
	oBrowse:SetLocate()
	oBrowse:SetMenuDef('cbcInventModel')
	
	oBrowse:Activate()
	
return(nil)


static function ModelDef()
	local oModel		:= nil 
	local oStrZZB 		:= FWFormStruct( 1, 'ZZB')
	local oStrZZC 		:= FWFormStruct( 1, 'ZZC')
	local aRelInv		:= {}

	oModel := MPFormModel():New('INVENTMODEL')
	
	oModel:AddFields('ZZB_MASTER',,oStrZZB)
	oModel:AddGrid('ZZC_GRID','ZZB_MASTER',oStrZZC)

	aAdd(aRelInv,  { 'ZZC_FILIAL', 'ZZB_FILIAL'} )
	aAdd(aRelInv,  { 'ZZC_ID', 'ZZB_ID'} )	
	oModel:SetRelation('ZZC_GRID', aRelInv, ZZC->(IndexKey(1)))
	
	oModel:SetPrimaryKey({})
	
	oModel:GetModel('ZZB_MASTER'):SetDescription( 'Inventário' )
	oModel:GetModel('ZZC_GRID'):SetDescription( 'Itens' )
return(oModel)


static Function ViewDef(oMdl)
	local oView			:= nil
	local oTotal 		:= nil
	local oTotNCC		:= nil
	local oStrZZB 		:= FWFormStruct( 2, 'ZZB')
	local oStrZZC 		:= FWFormStruct( 2, 'ZZC')
	
	oView := FWFormView():New()
	oView:SetModel(FWLoadModel('cbcInventModel'))
	oView:SetProgressBar(.T.)
	
	oView:AddField('ZZB_VIEW_MASTER',oStrZZB	,'ZZB_MASTER' )
	oView:AddGrid('ZZC_VIEW_GRID'	,oStrZZC	,'ZZC_GRID')
	// Cabeçalho
	oView:CreateHorizontalBox('HB_ZZB_MASTER',20)
	oView:SetOwnerView('ZZB_VIEW_MASTER','HB_ZZB_MASTER')
	// Itens
	oView:CreateHorizontalBox('HB_ZZC_GRID',80)
	oView:SetOwnerView('ZZC_VIEW_GRID','HB_ZZC_GRID')
	
	oView:SetViewProperty('ZZC_VIEW_GRID', "GRIDSEEK", {.T.})
	// oView:SetViewProperty("ZZC_VIEW_GRID"	, "SETCSS", defCss() )
	oView:AddUserButton('Etiqueta.Contagem'		, 'CLIPS', {|oView| Alert('Imprimir') 	})
return(oView)


Static Function MenuDef()
	Local aRot := {}
	//Adicionando opções
	ADD OPTION aRot TITLE 'Incluir'  			ACTION "u_cbcInventWizard('INCLUIR')" 			OPERATION MODEL_OPERATION_INSERT     ACCESS 0
	// ADD OPTION aRot TITLE 'Editar'  			ACTION "u_cbcInventWizard('ATUALIZAR')" 		OPERATION MODEL_OPERATION_UPDATE     ACCESS 0
	// ADD OPTION aRot TITLE 'Excluir'  		ACTION "VIEWDEF.cbcInventModel" 				OPERATION MODEL_OPERATION_DELETE     ACCESS 0
	ADD OPTION aRot TITLE 'Etiqueta.Contagem'   ACTION "StaticCall(cbcInventModel,printLbl)" 	OPERATION MODEL_OPERATION_INSERT     ACCESS 0
	ADD OPTION aRot TITLE 'Visualizar' 			ACTION 'VIEWDEF.cbcInventModel' 				OPERATION MODEL_OPERATION_VIEW   	 ACCESS 0
	ADD OPTION aRot TITLE 'Contagens Txt'		ACTION 'StaticCall(cbcInventModel,exportTxt)'   OPERATION MODEL_OPERATION_UPDATE     ACCESS 0
	ADD OPTION aRot TITLE 'Concluir'			ACTION 'StaticCall(cbcInventModel,concluir)' 	OPERATION MODEL_OPERATION_UPDATE     ACCESS 0
	
	// CloseBrowse()	
Return aRot


static function printLbl()
	U_CbcInvEt(ZZB->(ZZB_ID), ZZB->(ZZB_DTINIC) )
return(nil)


Static Function exportTxt()
	Local oExpTxt   as object
	
	If !Empty(ZZB->(ZZB_ID))
		oExpTxt	:= ctrlInvColetas():newctrlInvColetas(ZZB->(ZZB_ID))
		oExpTxt:importColetas(.F.)
		oExpTxt:toTxt()
	Else
		msgAlert('Erro no Posicionamento da Tabela ','Erro')
	EndIf
return (nil)


Static Function incluir(cId, cFi, Ddtini, dDtfim, cEtapa) 
	Local oSrvCouch as object
	Local oDoc		as object
	
	oSrvCouch := cbcSyncCouchInv():newcbcSyncCouchInv()
	oDoc	  := JsonObject():new()
	If !Empty(cId) && !Empty(cFi) && !Empty(Ddtini) && !Empty(cEtapa)
		oDoc['_id']		:= cId
		oDoc['filial']  := cFi
		oDoc['dtini']	:= DTOS(Ddtini)
		oDoc['dtfim']	:= IIF(Empty(dDtfim), '', DTOS(dDtfim))
		oDoc['etapa']	:= cEtapa
		oSrvCouch:saveDataInv(oDoc)
	Else
		msgAlert('Informações Faltando' + cId + ' ' + cFi + ' ' + Ddtini + ' ' + cEtapa,'Erro')
	EndIf
	
	FreeObj(oSrvCouch)
	FreeObj(oDoc)
Return (nil)


Static Function concluir() 
	Local oSrvCouch as object
	Local oDoc		as object
	
	oSrvCouch := cbcSyncCouchInv():newcbcSyncCouchInv()
	oDoc	  := JsonObject():new()
	
	If !Empty(ZZB->(ZZB_ID)) && !Empty(ZZB->(ZZB_FILIAL)) && !Empty(ZZB->(ZZB_DTINIC)) && !Empty(ZZB->(ZZB_DTFINA))
		Begin Transaction
			ZZB->(ZZB_ETAPA) := 'F'
			oDoc['_id']		:= ZZB->(ZZB_ID)
			oDoc['filial']  := ZZB->(ZZB_FILIAL)
			oDoc['dtini']	:= DTOS(ZZB->(ZZB_DTINIC))
			oDoc['dtfim']	:= DTOS(ZZB->(ZZB_DTFINA))
			oDoc['etapa']	:= ZZB->(ZZB_ETAPA)
			oSrvCouch:updDataInv(oDoc)
		End Transaction
	Else
		msgAlert('Erro no Posicionamento da Tabela ','Erro')
	EndIf
	
	FreeObj(oSrvCouch)
	FreeObj(oDoc)
Return (nil)