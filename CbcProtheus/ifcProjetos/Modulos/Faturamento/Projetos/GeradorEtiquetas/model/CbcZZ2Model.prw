#include 'protheus.ch'
#include 'FWMVCDef.ch'

#define MVC_MAIN_ID       "CbcZZ2Model"
#define MVC_MODEL_ID     "mZZ2Mod"

/*/{Protheus.doc} ViewDef
//TODO ViewDef da model ZZ2.
@author juliana.leme
@since 21/09/2018
@version 1.0
@type function
/*/
Static function ViewDef()
	Local oModel 		:= FwLoadModel(MVC_MAIN_ID)//FWLoadModel( 'CbcZZ2Model' )
	Local oStruZZ2 	:= FWFormStruct( 2, 'ZZ2' )
	Local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZZ2', oStruZZ2, 'ZZ2MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZZ2', 'TELA' )
Return (oView)


/*/{Protheus.doc} ModelDef
//TODO ModelDef da ZZ2.
@author juliana.leme
@since 21/09/2018
@version 1.0
@type function
/*/
Static function ModelDef()
	local oStruZZ2 		:= FWFormStruct( 1, 'ZZ2' )
	local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 			:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    
	oModel:AddFields( 'ZZ2MASTER', /*cOwner*/, oStruZZ2)
	oModel:SetPrimaryKey( {'ZZ2_FILIAL', 'ZZ2_TIPO', 'ZZ2_RECDOC', 'ZZ2_NOME'} )
	oModel:SetDescription( 'Etiqueta Cobrecom' )
	oModel:GetModel( 'ZZ2MASTER' ):SetDescription( 'Etiqueta Cobrecom' )
Return (oModel)


/*/{Protheus.doc} BrowseDef
//TODO BrowseDef da ZZ2.
@author juliana.leme
@since 21/09/2018
@version 1.0

@type function
/*/
Static function BrowseDef()
	Local cFiltro		:= ""
	Local oBrw		:= nil
	Private oFont 	:= TFont():New( "Arial", , -12, .T.)
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZZ2')
	oBrw:SetDescription('Etiqueta Cobrecom')
	oBrw:SetFilterDefault( cFiltro )
	oBrw:SetMenuDef("CbcZZ2Model")
	oBrw:Activate()
	oBrw:Refresh()
Return(oBrw)


/*/{Protheus.doc} MenuDef
//TODO MenuDef da ZZ2a.
@author juliana.leme
@since 21/09/2018
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cViewId 	  := "viewDef."+MVC_MAIN_ID
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION  "PesqBrw" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION cViewId OPERATION MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION cViewId OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION cViewId OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 //OPERATION 5
Return(aRotina)

/*/{Protheus.doc} validModel
//TODO Validação do Model.
@author juliana.leme
@since 07/01/2019
@version 1.0
@param oActiveModel, object, descricao
@param aDadF2, array, descricao
@type function
/*/
static function validModel(oActiveModel,aDadF2)	   	 	        
    local lOk 	:= .T.

return lOk

/*/{Protheus.doc} cbcZZ2Brw
//TODO Browser da ZZ2 para inclusão, alteração e exclusão..
@author juliana.leme
@since 21/09/2018
@version 1.0
@type function
/*/
user function cbcZZ2Brw()
	BrowseDef()
return(nil)
