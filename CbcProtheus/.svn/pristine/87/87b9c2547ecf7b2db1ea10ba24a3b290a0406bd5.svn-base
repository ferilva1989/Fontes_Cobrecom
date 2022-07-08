#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSUSIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SUS')
	oBrw:SetDescription('Suspects')
	oBrw:SetMenuDef("cbcSUSModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSUS	:= FWFormStruct( 1, 'SUS' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPSUS')
	oModel:AddFields('SUSMASTER', /*cOwner*/, oStruSUS)
	oModel:SetPrimaryKey({'US_FILIAL', 'US_COD', 'US_LOJA', 'US_CGC'})
	oModel:SetDescription('Suspects')
	oModel:GetModel('SUSMASTER'):SetDescription('Suspects')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSUSModel' )
	local oStruSUS 	:= FWFormStruct( 2, 'SUS' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SUS', oStruSUS, 'SUSMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SUS', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSUSModel' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
