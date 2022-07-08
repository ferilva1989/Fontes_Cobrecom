#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSM4Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro		:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SM4')
	oBrw:SetDescription('Formulas')
	oBrw:SetMenuDef("cbcSM4Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSM4 := FWFormStruct( 1, 'SM4' )
	local oModel
	oModel := MPFormModel():New('COMPSM4' )
	oModel:AddFields( 'SM4MASTER', /*cOwner*/, oStruSM4)
	oModel:SetPrimaryKey({'M4_FILIAL', 'M4_CODIGO'})
	oModel:SetDescription( 'Formulas' )
	oModel:GetModel( 'SM4MASTER' ):SetDescription( 'Formulas' )
return (oModel)

static function ViewDef()
	local oModel 		:= FWLoadModel( 'cbcSM4Model' )
	local oStruSM4 	:= FWFormStruct( 2, 'SM4' )
	local oView		:= nil
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SM4', oStruSC5, 'SM4MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SM4', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcSM4Model' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)