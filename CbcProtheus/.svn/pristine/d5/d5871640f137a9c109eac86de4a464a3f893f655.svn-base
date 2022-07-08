#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZZ7Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZ7')
	oBrw:SetDescription('Rotas X CEP')
	oBrw:SetMenuDef("cbcZZ7Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZZ7	:= FWFormStruct( 1, 'ZZ7' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPZZ7')
	oModel:AddFields('ZZ7MASTER', /*cOwner*/, oStruZZ7)
	oModel:SetPrimaryKey({'ZZ7_FILIAL', 'ZZ7_CEP'})
	oModel:SetDescription('Rotas X CEP')
	oModel:GetModel('ZZ7MASTER'):SetDescription('Rotas X CEP')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcZZ7Model' )
	local oStruZZ7 	:= FWFormStruct( 2, 'ZZ7' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZZ7', oStruZZ7, 'ZZ7MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZZ7', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcZZ7Model' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
