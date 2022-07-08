#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadNotPort"
#define MVC_MODEL_ID      "mNotPort"
#define MVC_VIEW_ID       "vNotPort"
#define MVC_TITLE         "Notificações do Portal Cobrecom"

#define STATUS_VISUALIZADA			"01"
#define STATUS_ENVIADA_POR_EMAIL	"02"
#define STATUS_NAO_VISUALIZADA		"03"
#define STATUS_TODAS				"99"


/*/{Protheus.doc} CadNotPortal

Cadastro de Notificações do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
@history 10/02/2017,LEO,Restrição de acesso apenas para usuario administrador
/*/
user function CadNotPort()
	
	local oBrowse  		:= FwMbrowse():new()
	local oAcl			:= cbcAcl():newcbcAcl()
	private bSendEmail	:= {|| sendEmail() }
	private bExcluir	:= {|| excluir() }
    
     if !oAcl:aclValid('CadNotPort')
    
    	Alert(oAcl:getAlert())
    	
    else
    
	    oBrowse:setAlias("ZP2") 
	    oBrowse:setDescription(MVC_TITLE)
	    
	    oBrowse:addLegend("Empty(ZP2_DTVISU) .and. Empty(ZP2_DTMAIL)", "RED", "Não visualizada")
	    oBrowse:addLegend("!Empty(ZP2_DTVISU)", "GREEN", "Visualizada")
	    oBrowse:addLegend("!Empty(ZP2_DTMAIL)", "YELLOW", "Enviada por E-mail")  
	    
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
    local cSendEmail  := "Eval(bSendEmail)"
    local cExcluir	  := "Eval(bExcluir)"
    
    ADD OPTION aOpcoes TITLE "Pesquisar"   		ACTION "PesqBrw" 	OPERATION 1 ACCESS 0
    ADD OPTION aOpcoes TITLE "Visualizar"  		ACTION cViewId   	OPERATION 2 ACCESS 0
    ADD OPTION aOpcoes TITLE "Imprimir"   		ACTION cViewId   	OPERATION 8 ACCESS 0
    ADD OPTION aOpcoes TITLE "Enviar E-mail"  	ACTION cSendEmail   OPERATION 2 ACCESS 0
    ADD OPTION aOpcoes TITLE "Excluir"  		ACTION cExcluir   	OPERATION 2 ACCESS 0
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
        
    local bValidModel 	:= {|oModel| validModel(oModel)}    
    local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
    local oZP2   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZP2")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZP2", nil, oZP2)
    oModel:getModel("ZP2"):setDescription(MVC_TITLE)     
    oModel:setPrimaryKey({"ZP2_FILIAL","ZP2_CODIGO"})

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
    local oZP2   := FwFormStruct(MVC_VIEW_STRUCT, "ZP2")
    
    oView:setModel(oModel)
    oView:addField("ZP2", oZP2, "ZP2")    

return oView

/**
 * Envio das Notificações por E-mail
 */
static function sendEmail()	
	
	local cMsg 	    := ""
	local lOk		:= .F.
	local lProcBar  := .T. 
	local oService	:= CbcNotificationService():newCbcNotificationService()
	
	if !MsgBox("Confirma envio das notificações pendentes por e-mail ?", "Atenção", "YESNO")
		return
	endIf
	
	Processa({|| lOk := oService:sendPendingEmails(@cMsg, lProcBar) }, "Aguarde", "Processando ...")
	
	if lOk
		MsgBox(cMsg, "Concluído", "INFO")
	else
		MsgBox(cMsg, "Atenção", "ALERT")
	endIf
	
return

/**
 * Remove Notificações
 */
static function excluir()
	
	local oParam	:= nil
	local oParamBox := LibParamBoxObj():newLibParamBoxObj("ExcNotPort", "Excluir Notificações")
	
	oParam := LibParamObj():newLibParamObj("dataDe", "get", "Data Inicial", "D", 60) 
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := LibParamObj():newLibParamObj("dataAte", "get", "Data Final", "D", 60) 
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := LibParamObj():newLibParamObj("status", "combo", "Status", "C", 60)
	oParam:setRequired(.T.)
	oParam:setValues({"01=Visualizada","02=Enviada por e-mail","03=Não Visualizada","99=Todas"})    
	oParamBox:addParam(oParam)
	
	if oParamBox:show()
		MsAguarde({|| procExclusao(oParamBox) }, "Aguarde", "Excluindo Notificações ...")			
	endIf
	
return

/**
 * Processa a Exclusão das Notificações
 */
static function procExclusao(oParamBox)
	
	local lClear   := .T.
	local oSql	   := LibSqlObj():newLibSqlObj()
	local dDataDe  := oParamBox:getValue("dataDe")
	local dDataAte := oParamBox:getValue("dataAte")
	local cStatus  := oParamBox:getValue("status")
	local cWhere   := " %ZP2.XFILIAL% AND ZP2_DATA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	
	if (cStatus == STATUS_VISUALIZADA)
		cWhere += " AND ZP2_DTVISU != ' ' "
	elseIf (cStatus == STATUS_ENVIADA_POR_EMAIL)
		cWhere += " AND ZP2_DTMAIL != ' ' "
	elseIf (cStatus == STATUS_NAO_VISUALIZADA)
		cWhere += " AND ZP2_DTVISU = ' ' AND ZP2_DTMAIL = ' ' "
	endIf

	if !oSql:delete("ZP2", cWhere, lClear)
		Alert(oSql:getLastError())
	endIf
	
return
