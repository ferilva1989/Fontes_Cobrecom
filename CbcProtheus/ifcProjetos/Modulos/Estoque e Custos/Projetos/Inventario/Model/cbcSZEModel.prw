#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSZEIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SZE')
	oBrw:SetDescription('Controle Bobinas')
	oBrw:SetMenuDef("cbcSZEModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSZE	:= FWFormStruct( 1, 'SZE' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPSZE')
	oModel:AddFields('SZEMASTER', /*cOwner*/, oStruSZE)
	oModel:SetPrimaryKey({'R_E_C_N_O_'})
	oModel:SetDescription('Controle Bobinas')
	oModel:GetModel('SZEMASTER'):SetDescription('Controle Bobinas')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSZEModel' )
	local oStruSZE 	:= FWFormStruct( 2, 'SZE' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SZE', oStruSZE, 'SZEMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SZE', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSZEModel' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
