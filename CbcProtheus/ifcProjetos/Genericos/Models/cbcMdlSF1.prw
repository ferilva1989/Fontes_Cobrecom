#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSF1Ini()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		    := nil
	private oFont 	    := TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SF1')
	oBrw:SetDescription('Documento de Entrada')
	oBrw:SetMenuDef("cbcMdlSF1")
	defLegenda(@oBrw, .F.)
    oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSF1 := FWFormStruct( 1, 'SF1' )
	local oModel
	oModel := MPFormModel():New('COMPSF1' )
	oModel:AddFields( 'SF1MASTER', /*cOwner*/, oStruSF1)
    oModel:SetPrimaryKey({'F1_FILIAL', 'F1_DOC', 'F1_SERIE', 'F1_FORNECE', 'F1_LOJA', 'F1_FORMUL', 'F1_TIPO'})
	oModel:SetDescription( 'Documento de Entrada' )
	oModel:GetModel( 'SF1MASTER' ):SetDescription( 'Documento de Entrada' )
return (oModel)

static function ViewDef()
	local oModel 		    := FWLoadModel( 'cbcMdlSF1' )
	local oStruSF1 	        := FWFormStruct( 2, 'SF1' )
	local oView		        := nil
	oView                   := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SF1', oStruSF1, 'SF1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SF1', 'TELA' )
return (oView)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcMdlSF1' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)


static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
