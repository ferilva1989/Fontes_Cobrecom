#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadCondPgt"
#define MVC_MODEL_ID      "mCondPgt"
#define MVC_VIEW_ID       "vCondPgt"
#define MVC_TITLE         "Cadastro de Condições de Pagamentos dos Orçamentos"


/*/{Protheus.doc} CadCondPgt

Cadastro de Condições de Pagamentos dos Orçamentos
    
@author victorhugo
@since 21/07/2016
/*/
user function CadCondPgt()
	
	local oBrowse  	:= FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
	private oUtils 	:= LibUtilsObj():newLibUtilsObj()
    
     if !oAcl:aclValid('CadCondPgt')
    	Alert( oAcl:getAlert() )
    else
	    oBrowse:setAlias("ZPD") 
	    oBrowse:setDescription(MVC_TITLE)    
	    oBrowse:activate()
	endif
	
	FreeObj(oAcl)
return

/**
 * Opções do browse
 */
static function menuDef()
    
    local aOpcoes 	  := {}
    local cViewId 	  := "viewDef."+MVC_MAIN_ID
    
    ADD OPTION aOpcoes TITLE "Pesquisar"   	ACTION "PesqBrw" 	OPERATION 1 ACCESS 0
    ADD OPTION aOpcoes TITLE "Visualizar"  	ACTION cViewId   	OPERATION 2 ACCESS 0
    ADD OPTION aOpcoes TITLE "Incluir"     	ACTION cViewId   	OPERATION 3 ACCESS 0
    ADD OPTION aOpcoes TITLE "Alterar"     	ACTION cViewId   	OPERATION 4 ACCESS 0
    ADD OPTION aOpcoes TITLE "Excluir"     	ACTION cViewId   	OPERATION 5 ACCESS 0
    ADD OPTION aOpcoes TITLE "Imprimir"   	ACTION cViewId   	OPERATION 8 ACCESS 0
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
    
    local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    local oZPD   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPD")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZPD", nil, oZPD)
    oModel:getModel("ZPD"):setDescription(MVC_TITLE) 
    oModel:setPrimaryKey({"ZPD_FILIAL","ZPD_VLRMIN"})    

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZPD   := FwFormStruct(MVC_VIEW_STRUCT, "ZPD")
    
    oView:setModel(oModel)
    oView:addField("ZPD", oZPD, "ZPD")    

return oView

/**
 * Validação do Model
 */
static function validModel(oActiveModel)
     	   	 	        
    local lOk 	:= .T.
    local nOper := oActiveModel:getOperation()    
    
return lOk
