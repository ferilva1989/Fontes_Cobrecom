#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSC6Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro	:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SC6')
	oBrw:SetDescription('Itens Pedidos de Venda')
	oBrw:SetMenuDef("cbcSC6Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSC6 := FWFormStruct( 1, 'SC6' )
	local oModel
	
	oModel := MPFormModel():New('SC6MODEL' )
	oModel:AddFields( 'SC6MASTER', /*cOwner*/, oStruSC6)
	oModel:SetPrimaryKey({'C6_FILIAL', 'C6_NUM', 'C6_ITEM'})
	oModel:SetDescription( 'Itens Pedidos de Venda' )
	oModel:GetModel( 'SC6MASTER' ):SetDescription( 'Itens Pedidos de Venda' )
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSC6Model' )
	local oStruSC6 	:= FWFormStruct( 2, 'SC6' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SC6', oStruSC6, 'SC6MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SC6', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcSC5Model' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
