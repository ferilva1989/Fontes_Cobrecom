#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSC5Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro		:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SC5')
	oBrw:SetDescription('Pedidos de Venda')
	oBrw:SetMenuDef("cbcSC5Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSC5 := FWFormStruct( 1, 'SC5' )
	local oModel
	oModel := MPFormModel():New('COMPSC5' )
	oModel:AddFields( 'SC5MASTER', /*cOwner*/, oStruSC5)
	oModel:SetPrimaryKey({'C5_FILIAL', 'C5_NUM'})
	oModel:SetDescription( 'Pedidos de Venda' )
	oModel:GetModel( 'SC5MASTER' ):SetDescription( 'Pedidos de Venda' )
return (oModel)

static function ViewDef()
	local oModel 		:= FWLoadModel( 'cbcSC5Model' )
	local oStruSC5 	:= FWFormStruct( 2, 'SC5' )
	local oView		:= nil
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SC5', oStruSC5, 'SC5MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SC5', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcSC5Model' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)