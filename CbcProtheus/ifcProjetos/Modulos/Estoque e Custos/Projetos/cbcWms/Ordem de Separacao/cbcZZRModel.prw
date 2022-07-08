#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZZRIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZR')
	oBrw:SetDescription('Ordem de Separacao')
	oBrw:SetMenuDef("cbcZZRModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZZR	:= FWFormStruct( 1, 'ZZR' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPZZR')
	oModel:AddFields('ZZRMASTER', /*cOwner*/, oStruZZR)
	oModel:SetPrimaryKey({'R_E_C_N_O_'})
	oModel:SetDescription('Ordem de Separacao')
	oModel:GetModel('ZZRMASTER'):SetDescription('Ordem de Separacao')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcZZRModel' )
	local oStruZZR 	:= FWFormStruct( 2, 'ZZR' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZZR', oStruZZR, 'ZZRMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZZR', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcZZRModel' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
