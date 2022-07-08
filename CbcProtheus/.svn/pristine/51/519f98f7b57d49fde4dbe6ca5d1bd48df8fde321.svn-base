#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSFMIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SFM')
	oBrw:SetDescription('Tes Inteligente')
	oBrw:SetMenuDef("cbcSFMModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSFM	:= FWFormStruct( 1, 'SFM' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPSFM')
	oModel:AddFields('SFMMASTER', /*cOwner*/, oStruSFM)
	oModel:SetPrimaryKey({'FM_FILIAL', 'FM_TIPO', 'FM_TE', 'FM_TS'})
	oModel:SetDescription('Tes Inteligente')
	oModel:GetModel('SFMMASTER'):SetDescription('Tes Inteligente')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcSFMModel' )
	local oStruSFM 	:= FWFormStruct( 2, 'SFM' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SFM', oStruSFM, 'SFMMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SFM', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSFMModel' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
