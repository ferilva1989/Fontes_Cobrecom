#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadCfgEvt"
#define MVC_MODEL_ID      "mCfgEvt"
#define MVC_VIEW_ID       "vCfgEvt"
#define MVC_TITLE         "Configurações de Eventos do Portal Cobrecom"


/*/{Protheus.doc} CadCfgEvt

Cadastro de Configurações de Eventos do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
@history 10/02/2017,LEO,Restrição de acesso apenas para usuario administrador
/*/
user function CadCfgEvt()
	
	local oBrowse := FwMbrowse():new()
	local oAcl		:= cbcAcl():newcbcAcl()
    
     if !oAcl:aclValid('CadCfgEvt')
    	Alert(oAcl:getAlert())
    else
	    oBrowse:setAlias("ZP7") 
	    oBrowse:setDescription(MVC_TITLE)     
	    oBrowse:activate()
	endif
	FreeObj(oAcl)
return

/**
 * Opções do browse
 */
static function menuDef()
    
    local aOpcoes    := {}
    local cViewId    := "viewDef."+MVC_MAIN_ID
    
    ADD OPTION aOpcoes TITLE "Pesquisar"   		ACTION "PesqBrw"   	OPERATION 1 ACCESS 0
    ADD OPTION aOpcoes TITLE "Visualizar"  		ACTION cViewId   	OPERATION 2 ACCESS 0
    ADD OPTION aOpcoes TITLE "Incluir"     		ACTION cViewId   	OPERATION 3 ACCESS 0
    ADD OPTION aOpcoes TITLE "Alterar"     		ACTION cViewId   	OPERATION 4 ACCESS 0
    ADD OPTION aOpcoes TITLE "Excluir"     		ACTION cViewId   	OPERATION 5 ACCESS 0
    ADD OPTION aOpcoes TITLE "Imprimir"    		ACTION cViewId   	OPERATION 8 ACCESS 0
    ADD OPTION aOpcoes TITLE "Copiar"      		ACTION cViewId   	OPERATION 9 ACCESS 0
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
    
    local bValidModel := {|oModel| validModel(oModel)}
    local oModel      := MpFormModel():new(MVC_MODEL_ID, bValidModel, bValidModel)
    local oZP7        := FwFormStruct(MVC_MODEL_STRUCT, "ZP7")
    local oZP8        := FwFormStruct(MVC_MODEL_STRUCT, "ZP8")
    local aRelation   := {}
    
    aAdd(aRelation, {"ZP8_FILIAL","ZP7_FILIAL"})
    aAdd(aRelation, {"ZP8_EVENTO","ZP7_EVENTO"})
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZP7", nil, oZP7)
    oModel:getModel("ZP7"):setDescription("Dados do Evento") 
    
    oModel:addGrid("ZP8", "ZP7", oZP8)
    oModel:getModel("ZP8"):setDescription("Notificação de Usuários")
    oModel:setRelation("ZP8", aRelation, ZP8->(IndexKey(1)))
    
    oModel:setPrimaryKey({"ZP7_FILIAL","ZP7_EVENTO"})

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZP7   := FwFormStruct(MVC_VIEW_STRUCT, "ZP7")
    local oZP8   := FwFormStruct(MVC_VIEW_STRUCT, "ZP8")
    
    oView:setModel(oModel)
    oView:addField("ZP7", oZP7, "ZP7")
    oView:addGrid("ZP8", oZP8, "ZP8")
    
    oView:createHorizontalBox("box_top", 30)
    oView:createHorizontalBox("box_bottom", 70)
    
    oView:createFolder("folder", "box_bottom")
    oView:addSheet("folder", "sheet01", "Notificação de Usuários") 
    oView:createHorizontalBox("boxFolderSheet01", 100, , , "folder","sheet01")
    
    oView:setOwnerView("ZP7", "box_top")
    oView:setOwnerView("ZP8", "boxFolderSheet01")

return oView

/**
 * Validação do Model
 */
static function validModel(oModel)
    
    local lOk := .T. 
    
    //TODO Validar grupos duplicados ...         
    
return lOk



