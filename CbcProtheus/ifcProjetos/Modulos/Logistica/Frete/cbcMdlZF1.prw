#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZF1Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZF1')
	oBrw:SetDescription('Calculo de Fretes')
	oBrw:SetMenuDef("cbcMdlZF1")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZF1	:= FWFormStruct( 1, 'ZF1' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPZF1')
	oModel:AddFields('ZF1MASTER', /*cOwner*/, oStruZF1)
	oModel:SetPrimaryKey({'ZF1_FILIAL', 'ZF1_TRANSP', 'ZF1_ROTA'})
	oModel:SetDescription('Calculo de Fretes')
	oModel:GetModel('ZF1MASTER'):SetDescription('Calculo de Fretes')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcMdlZF1' )
	local oStruZF1 	:= FWFormStruct( 2, 'ZF1' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_ZF1', oStruZF1, 'ZF1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZF1', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcMdlZF1' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
