#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZZ8Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZ8')
	oBrw:SetDescription('Pesagem de Sucata')
	oBrw:SetMenuDef("cbcZZ8Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZZ8	:= FWFormStruct( 1, 'ZZ8' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPZZ8')
	oModel:AddFields('ZZ8MASTER', /*cOwner*/, oStruZZ8)
	oModel:SetPrimaryKey({'ZZ8_FILIAL', 'ZZ8_IDMOV'})
	oModel:SetDescription('Pesagem de Sucata')
	oModel:GetModel('ZZ8MASTER'):SetDescription('Pesagem de Sucata')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcZZ8Model' )
	local oStruZZ8 	:= FWFormStruct( 2, 'ZZ8' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZZ8', oStruZZ8, 'ZZ8MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZZ8', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcZZ8Model' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
