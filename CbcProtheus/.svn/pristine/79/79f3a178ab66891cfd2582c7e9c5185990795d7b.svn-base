#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSF2Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		    := nil
	private oFont 	    := TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SF2')
	oBrw:SetDescription('Documento de Saida')
	oBrw:SetMenuDef("cbcMdlSF2")
	defLegenda(@oBrw, .F.)
    oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSF2 := FWFormStruct( 1, 'SF2' )
	local oModel
	oModel := MPFormModel():New('COMPSF2' )
	oModel:AddFields( 'SF2MASTER', /*cOwner*/, oStruSF2)
    oModel:SetPrimaryKey({'F2_FILIAL', 'F2_DOC', 'F2_SERIE', 'F2_CLIENTE', 'F2_LOJA', 'F2_FORMUL', 'F2_TIPO'})
	oModel:SetDescription( 'Documento de Saida' )
	oModel:GetModel( 'SF2MASTER' ):SetDescription( 'Documento de Saida' )
return (oModel)

static function ViewDef()
	local oModel 		    := FWLoadModel( 'cbcMdlSF2' )
	local oStruSF2 	        := FWFormStruct( 2, 'SF2' )
	local oView		        := nil
	oView                   := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SF2', oStruSF2, 'SF2MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SF2', 'TELA' )
return (oView)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcMdlSF2' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)


static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)