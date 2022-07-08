#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZZ9Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)

	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZ9')
	oBrw:SetDescription('Ordem de Carga')
	oBrw:SetMenuDef("cbcZZ9Model")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZZ9	:= FWFormStruct( 1, 'ZZ9' )
	local oModel	:= nil

	oModel := MPFormModel():New('COMPZZ9')
	oModel:AddFields('ZZ9MASTER', /*cOwner*/, oStruZZ9)
	oModel:SetPrimaryKey({'ZZ9_FILIAL', 'ZZ9_ORDCAR', 'ZZ9_ORDSEP'})
	oModel:SetDescription('Ordem de Carga')
	oModel:GetModel('ZZ9MASTER'):SetDescription('Ordem de Carga')
return (oModel)

static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcZZ9Model' )
	local oStruZZ9 	:= FWFormStruct( 2, 'ZZ9' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZZ9', oStruZZ9, 'ZZ9MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZZ9', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.cbcZZ9Model' OPERATION MODEL_OPERATION_VIEW ACCESS 0
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
