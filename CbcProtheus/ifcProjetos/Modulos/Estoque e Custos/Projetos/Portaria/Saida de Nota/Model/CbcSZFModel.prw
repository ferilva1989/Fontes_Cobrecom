#include 'protheus.ch'
#Include 'FWMVCDef.ch'

#define MVC_MAIN_ID       "CbcSZFModel"
#define MVC_MODEL_ID     "mSZFMod"

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function ViewDef()
	Local oModel 		:= FwLoadModel(MVC_MAIN_ID)//FWLoadModel( 'cbcSZFModel' )
	Local oStruSZF 	:= FWFormStruct( 2, 'SZF' )
	Local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SZF', oStruSZF, 'SZFMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SZF', 'TELA' )
Return (oView)


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static function ModelDef()
	local oStruSZF 		:= FWFormStruct( 1, 'SZF' )
	local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 			:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    
	oModel:AddFields( 'SZFMASTER', /*cOwner*/, oStruSZF)
	oModel:SetPrimaryKey( {'SZF_FILIAL', 'SZF_SERIE', 'SZF_NOTA', 'SZF_CDROMA'} )
	oModel:SetDescription( 'Informações Cargas' )
	oModel:GetModel( 'SZFMASTER' ):SetDescription( 'Informações Cargas' )
Return (oModel)


/*/{Protheus.doc} BrowseDef
//TODO Descrição auto-gerada.
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
	oBrw:SetAlias('SZF')
	oBrw:SetDescription('Informações Cargas')
	oBrw:SetFilterDefault( cFiltro )
	oBrw:SetMenuDef("cbcSZFModel")
	oBrw:Activate()
	oBrw:Refresh()
Return(oBrw)



/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
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


/**
 * Validação do Model
 */
static function validModel(oActiveModel,aDadF2)	   	 	        
    local lOk 	:= .T.

return lOk

/*/{Protheus.doc} cbcSZFBrw
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2018
@version 1.0

@type function
/*/
user function cbcSZFBrw()
	BrowseDef()
return(nil)
