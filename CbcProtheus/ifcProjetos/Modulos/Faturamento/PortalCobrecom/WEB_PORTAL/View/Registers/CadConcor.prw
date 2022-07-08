#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadConcor"
#define MVC_MODEL_ID      "mConcor"
#define MVC_VIEW_ID       "vConcor"
#define MVC_TITLE         "Cadastro de Concorrentes Cobrecom"


/*/{Protheus.doc} CadConcor

Cadastro de Concorrentes Cobrecom
    
@author victorhugo
@since 21/07/2016
/*/
user function CadConcor()
	
	local oBrowse  	:= FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
	private oUtils 	:= LibUtilsObj():newLibUtilsObj()
    
    if !oAcl:aclValid('CadConcor')
    	Alert( oAcl:getAlert() )
    else
	    oBrowse:setAlias("ZPF") 
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
    local oZPF   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPF")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZPF", nil, oZPF)
    oModel:getModel("ZPF"):setDescription(MVC_TITLE) 
    oModel:setPrimaryKey({"ZPF_FILIAL","ZPF_CODIGO"})    

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZPF   := FwFormStruct(MVC_VIEW_STRUCT, "ZPF")
    
    oView:setModel(oModel)
    oView:addField("ZPF", oZPF, "ZPF")    

return oView

/**
 * Validação do Model
 */
static function validModel(oActiveModel)
     	   	 	        
    local lOk 	:= .T.
    local nOper := oActiveModel:getOperation()    
    
return lOk
