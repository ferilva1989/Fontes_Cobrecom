#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadMsgPort"
#define MVC_MODEL_ID      "mMsgPort"
#define MVC_VIEW_ID       "vMsgPort"
#define MVC_TITLE         "Mensagens do Portal Cobrecom"

#define STATUS_ARQUIVADA			"01"
#define STATUS_VISUALIZADA			"02"
#define STATUS_ENVIADA_POR_EMAIL	"03"
#define STATUS_NAO_VISUALIZADA		"04"
#define STATUS_TODAS				"99"


/*/{Protheus.doc} CadMsgPortal

Cadastro de Mensagens do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
@history 10/02/2017,LEO,Restrição de acesso apenas para usuario administrador
/*/
user function CadMsgPort()
	
	local oBrowse  		:= FwMbrowse():new()
	local oAcl			:= cbcAcl():newcbcAcl()
	private bSendEmail	:= {|| sendEmail() }
	private bExcluir	:= {|| excluir() }
    
    if !oAcl:aclValid('CadMsgPort')
    
    	alert( oAcl:getAlert() )
    	
    else
    
	    oBrowse:setAlias("ZP3") 
	    oBrowse:setDescription(MVC_TITLE)
	    
	    oBrowse:addLegend("Empty(ZP3_DTVISU) .and. Empty(ZP3_DTMAIL)", "RED", "Não visualizada")
	    oBrowse:addLegend("!Empty(ZP3_DTVISU)", "GREEN", "Visualizada")
	    oBrowse:addLegend("!Empty(ZP3_DTMAIL)", "YELLOW", "Enviada por E-mail")
	    oBrowse:addLegend("ZP3_ARQ == 'S'", "WHITE", "Arquivada")  
	    
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
    local oZP3   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZP3")   
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZP3", nil, oZP3)
    oModel:getModel("ZP3"):setDescription(MVC_TITLE)     
    oModel:setPrimaryKey({"ZP3_FILIAL","ZP3_CODIGO"})

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
    local oZP3   := FwFormStruct(MVC_VIEW_STRUCT, "ZP3")
    
    oView:setModel(oModel)
    oView:addField("ZP3", oZP3, "ZP3")    

return oView

/**
 * Envio das Notificações por E-mail
 */
static function sendEmail()	
	
	local cMsg 	    := ""
	local lOk		:= .F.
	local lProcBar  := .T. 
	local oService	:= CbcMessageService():newCbcMessageService()
	
	if !MsgBox("Confirma envio das mensagens pendentes por e-mail ?", "Atenção", "YESNO")
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
 * Remove Mensagens
 */
static function excluir()
	
	local oParam	:= nil
	local oParamBox := LibParamBoxObj():newLibParamBoxObj("ExcMsgPort", "Excluir Mensagens")
	
	oParam := LibParamObj():newLibParamObj("dataDe", "get", "Data Inicial", "D", 60) 
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := LibParamObj():newLibParamObj("dataAte", "get", "Data Final", "D", 60) 
	oParam:setRequired(.T.)
	oParamBox:addParam(oParam)
	
	oParam := LibParamObj():newLibParamObj("status", "combo", "Status", "C", 60)
	oParam:setRequired(.T.)
	oParam:setValues({"01=Arquivada","02=Visualizada","03=Enviada por e-mail","04=Não Visualizada","99=Todas"})    
	oParamBox:addParam(oParam)
	
	if oParamBox:show()
		MsAguarde({|| procExclusao(oParamBox) }, "Aguarde", "Excluindo Mensagens ...")			
	endIf
	
return

/**
 * Processa a Exclusão das Mensagens
 */
static function procExclusao(oParamBox)
	
	local lClear   := .T.
	local oSql	   := LibSqlObj():newLibSqlObj()
	local dDataDe  := oParamBox:getValue("dataDe")
	local dDataAte := oParamBox:getValue("dataAte")
	local cStatus  := oParamBox:getValue("status")
	local cWhere   := " %ZP3.XFILIAL% AND ZP3_DATA BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' "
	
	if (cStatus == STATUS_ARQUIVADA)
		cWhere += " AND ZP3_ARQ = 'S' "
	elseIf (cStatus == STATUS_VISUALIZADA)
		cWhere += " AND ZP3_DTVISU != ' ' "
	elseIf (cStatus == STATUS_ENVIADA_POR_EMAIL)
		cWhere += " AND ZP3_DTMAIL != ' ' "
	elseIf (cStatus == STATUS_NAO_VISUALIZADA)
		cWhere += " AND ZP3_DTVISU = ' ' AND ZP3_DTMAIL = ' ' "
	endIf

	if !oSql:delete("ZP3", cWhere, lClear)
		Alert(oSql:getLastError())
	endIf
	
return
