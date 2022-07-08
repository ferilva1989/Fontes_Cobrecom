#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadVlrMin"
#define MVC_MODEL_ID      "mVlrMin"
#define MVC_VIEW_ID       "vVlrMin"
#define MVC_TITLE         "Cadastro de Valores Mínimos dos Orçamentos"


/*/{Protheus.doc} CadVlrMin

Cadastro de Valores Mínimos dos Orçamentos
    
@author victorhugo
@since 21/07/2016
/*/
user function CadVlrMin()
	
	local oBrowse  	:= FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
	private oUtils 	:= LibUtilsObj():newLibUtilsObj()
    
    if !oAcl:aclValid('CadVlrMin')
    	Alert(oAcl:getAlert())
    else
	    oBrowse:setAlias("ZPC") 
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
    local oZPC   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPC")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZPC", nil, oZPC)
    oModel:getModel("ZPC"):setDescription(MVC_TITLE)    
    oModel:setPrimaryKey({"ZPC_FILIAL","ZPC_FRETE","ZPC_VLRMIN"}) 

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZPC   := FwFormStruct(MVC_VIEW_STRUCT, "ZPC")
    
    oView:setModel(oModel)
    oView:addField("ZPC", oZPC, "ZPC")    

return oView

/**
 * Validação do Model
 */
static function validModel(oActiveModel)
     	   	 	        
    local lOk 	:= .T.
    local nOper := oActiveModel:getOperation()    
    
return lOk
