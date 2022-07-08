#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadAprPort"
#define MVC_MODEL_ID      "mAprPort"
#define MVC_VIEW_ID       "vAprPort"
#define MVC_TITLE         "Cadastro de Aprovadores do Portal Cobrecom"


/*/{Protheus.doc} CadAprPort

Cadastro de Aprovadores do Portal Cobrecom
    
@author victorhugo
@since 21/07/2016
@history 10/02/2017,LEO,Restrição de acesso apenas para usuario administrador
/*/
user function CadAprPort()
	
	local oBrowse  	:= FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
	private oUtils 	:= LibUtilsObj():newLibUtilsObj()
  
    if !oAcl:aclValid('CadAprPort')
    	Alert(oAcl:getAlert() )
    else
	    oBrowse:setAlias("ZPB") 
	    oBrowse:setDescription(MVC_TITLE)    
	    oBrowse:activate()
	endif
	freeObj(oAcl)
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
    ADD OPTION aOpcoes TITLE "Copiar"     	ACTION cViewId   	OPERATION 9 ACCESS 0
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
    
    local aRelation     := {}
    local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    local oZPB   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPB")
    local oZPI   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPI")   
    
    aAdd(aRelation, {"ZPI_FILIAL","ZPB_FILIAL"})
    aAdd(aRelation, {"ZPI_CODUSR","ZPB_CODUSR"})
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZPB", nil, oZPB)
    oModel:getModel("ZPB"):setDescription(MVC_TITLE)     
    
    oModel:addGrid("ZPI", "ZPB", oZPI)
    oModel:getModel("ZPI"):setDescription("Faixas de Descontos")
    oModel:setRelation("ZPI", aRelation, ZPI->(IndexKey(1)))
    
    oModel:setPrimaryKey({"ZPB_FILIAL","ZPB_CODUSR"})

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZPB   := FwFormStruct(MVC_VIEW_STRUCT, "ZPB")
    local oZPI   := FwFormStruct(MVC_VIEW_STRUCT, "ZPI")
    
    oView:setModel(oModel)
    oView:addField("ZPB", oZPB, "ZPB")    
    oView:addGrid("ZPI", oZPI, "ZPI")
    
    oView:createHorizontalBox("box_top", 30)
    oView:createHorizontalBox("box_bottom", 70)
    
    oView:createFolder("folder", "box_bottom")
    oView:addSheet("folder", "sheet01", "Faixas de Descontos") 
    oView:createHorizontalBox("boxFolderSheet01", 100, , , "folder","sheet01")
    
    oView:setOwnerView("ZPB", "box_top")
    oView:setOwnerView("ZPI", "boxFolderSheet01")

return oView

/**
 * Validação do Model
 */
static function validModel(oActiveModel)
     	   	 	        
    local lOk 	:= .T.
    local nOper := oActiveModel:getOperation()    
    
return lOk
