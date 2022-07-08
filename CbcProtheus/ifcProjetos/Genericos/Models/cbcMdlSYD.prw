#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcSYDIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local oBrw		    := nil
	private oFont 	    := TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('SYD')
	oBrw:SetDescription('Cadastro NCM')
	oBrw:SetMenuDef("cbcMdlSYD")
	defLegenda(@oBrw, .F.)
    oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruSYD := FWFormStruct( 1, 'SYD' )
	local oModel
	oModel := MPFormModel():New('COMPSYD' )
	oModel:AddFields( 'SYDMASTER', /*cOwner*/, oStruSYD)
    oModel:SetPrimaryKey({'YD_FILIAL', 'YD_TEC', 'YD_EX_NCM', 'YD_EX_NBM', 'YD_DESTAQU', 'R_E_C_N_O_', 'D_E_L_E_T_'})
	oModel:SetDescription( 'Cadastro NCM' )
	oModel:GetModel( 'SYDMASTER' ):SetDescription( 'Cadastro NCM' )
return (oModel)

static function ViewDef()
	local oModel 		    := FWLoadModel( 'cbcMdlSYD' )
	local oStruSYD 	        := FWFormStruct( 2, 'SYD' )
	local oView		        := nil
	oView                   := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SYD', oStruSYD, 'SYDMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SYD', 'TELA' )
return (oView)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcMdlSYD' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
return(aRotina)


static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)
