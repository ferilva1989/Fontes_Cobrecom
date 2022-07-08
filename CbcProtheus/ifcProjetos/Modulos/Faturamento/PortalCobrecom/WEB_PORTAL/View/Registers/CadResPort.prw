#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadResPort"
#define MVC_MODEL_ID      "mResPort"
#define MVC_VIEW_ID       "vResPort"
#define MVC_TITLE         "Reservas de Produtos do Portal Cobrecom"


/*/{Protheus.doc} CadResPort

Reservas de Produtos do Portal Cobrecom
    
@author victorhugo
@since 29/02/2016
/*/
user function CadResPort()
	
	local oBrowse := FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
    
    if !oAcl:aclValid('CadResPort')
    	Alert(oAcl:getAlert())
    else
	    oBrowse:setAlias("ZP4") 
	    oBrowse:setDescription(MVC_TITLE)
	    
	    oBrowse:addLegend("ZP4_STATUS == '"+RESERVE_STATUS_WAITING+"'", "YELLOW", "Pendente")
	    oBrowse:addLegend("ZP4_STATUS == '"+RESERVE_STATUS_CONFIRMED+"'", "GREEN", "Confirmada")
	    oBrowse:addLegend("ZP4_STATUS == '"+RESERVE_STATUS_EXPIRED+"'", "WHITE", "Expirada")
	    oBrowse:addLegend("ZP4_STATUS == '"+RESERVE_STATUS_CANCELED+"'", "RED", "Cancelada") 
	    
	    oBrowse:activate()
	endif
	
	FreeObj(oAcl)
return

/**
 * Opções do browse
 */
static function menuDef()
    
    local aOpcoes := {}
    local cViewId := "viewDef."+MVC_MAIN_ID
    
    ADD OPTION aOpcoes TITLE "Pesquisar"   		ACTION "PesqBrw" 	OPERATION 1 ACCESS 0
    ADD OPTION aOpcoes TITLE "Visualizar"  		ACTION cViewId   	OPERATION 2 ACCESS 0
    ADD OPTION aOpcoes TITLE "Imprimir"   		ACTION cViewId   	OPERATION 8 ACCESS 0
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
        
    local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    local oZP4   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZP4")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZP4", nil, oZP4)
    oModel:getModel("ZP4"):setDescription(MVC_TITLE)     
    oModel:setPrimaryKey({"ZP4_FILIAL","ZP4_CODIGO"})

return oModel

/**
 * Validação do Model
 */
static function validModel(oActiveModel)
     	   	 	        
    local lOk 	:= .T.
    local nOper := oActiveModel:getOperation()    
    
return lOk

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZP4   := FwFormStruct(MVC_VIEW_STRUCT, "ZP4")
    
    oView:setModel(oModel)
    oView:addField("ZP4", oZP4, "ZP4")    

return oView

