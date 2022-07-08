#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function cbcSB7Model()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro	:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SB7')
	oBrw:SetDescription('Processamento de Inventário')
	oBrw:SetMenuDef("cbcSB7Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSB7 	:= FWFormStruct( 1, 'SB7' )
	local oModel	:= nil
	
	oModel := MPFormModel():New('SB7MODEL' )
	oModel:AddFields( 'SB7MASTER', /*cOwner*/, oStruSB7)
	oModel:SetPrimaryKey({'B7_FILIAL', 'B7_DATA', 'B7_COD', 'B7_LOCAL', 'B7_LOCALIZ'})
	oModel:SetDescription( 'Processamento de Inventário' )
	oModel:GetModel( 'SB7MASTER' ):SetDescription( 'Processamento de Inventário' )
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSB7Model' )
	local oStruSB7 	:= FWFormStruct( 2, 'SB7' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SB7', oStruSB7, 'SB7MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SB7', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcSC5Model' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
