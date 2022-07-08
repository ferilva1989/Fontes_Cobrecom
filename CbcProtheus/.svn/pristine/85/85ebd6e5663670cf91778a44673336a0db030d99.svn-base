#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSZGIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SZG')
	oBrw:SetDescription('Contagens Inventário')
	oBrw:SetMenuDef("cbcSZGModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSZG	:= FWFormStruct( 1, 'SZG' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPSZG')
	oModel:AddFields('SZGMASTER', /*cOwner*/, oStruSZG)
	oModel:SetPrimaryKey({'R_E_C_N_O_'})
	oModel:SetDescription('Contagens Inventário')
	oModel:GetModel('SZGMASTER'):SetDescription('Contagens Inventário')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSZGModel' )
	local oStruSZG 	:= FWFormStruct( 2, 'SZG' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SZG', oStruSZG, 'SZGMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SZG', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSZGModel' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
