#include 'protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcGenSts()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro	:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZ9')
	oBrw:SetDescription('Controle generico de Status') 
	// cFiltro +=	"!Empty(ZBA_DTREL)"
	// oBrw:SetFilterDefault( cFiltro )
	oBrw:SetMenuDef("cbcMdlGenStatus")
	// defLegenda(@oBrw, .F.)
	oBrw:Activate()
	oBrw:Refresh()
return(oBrw)


static function ModelDef()
	local oStruZZ9 	:= FWFormStruct( 1, 'ZZ9' )
	local oModel	:= nil
	oModel := MPFormModel():New('GENSTATUS' )
	oModel:AddFields('ZZ9MASTER',,oStruZZ9)
	oModel:SetPrimaryKey({'ZZ9_FILIAL', 'ZZ9_ALSMST', 'ZZ9_RECMST', 'ZZ9_ALSDET', 'ZZ9_RECDET'})
	oModel:SetDescription('Controle generico de status')
	oModel:GetModel('ZZ9MASTER'):SetDescription('Controle generico')
return (oModel)


static function ViewDef()
	local oModel 	:= FWLoadModel( 'cbcMdlGenStatus' )
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
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcMdlGenStatus'  OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)