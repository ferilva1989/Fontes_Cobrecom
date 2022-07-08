#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadOrcPort"
#define MVC_MODEL_ID      "mOrcPort"
#define MVC_VIEW_ID       "vOrcPort"
#define MVC_TITLE         "Orçamentos do Portal Cobrecom"


/*/{Protheus.doc} CadOrcPort

Orçamentos do Portal Cobrecom
    
@author victorhugo
@since 23/05/2016
/*/
user function CadOrcPort()
	
	local oBrowse 		 := FwMbrowse():new()
	local oService     	 := CbcQuotationService():newCbcQuotationService()
	local oAcl		:= cbcAcl():newcbcAcl()
	private bPrint		 := {|| createPdf() }
	private bTecApproval := {|| tecnicalApproval() }
	private bToOrder	 := {|| budtgetToOrder() }
	private bCancLote	 := {|| u_cbcOrcCancel()}
	private bCalcImp	 := {|| u_PedCalcImp('Portal', ZP5->(Recno()))}
    
    if !oAcl:aclValid('CadOrcPort')
    	Alert( oAcl:getAlert() )
    else
	    oBrowse:setAlias("ZP5") 
	    oBrowse:setDescription(MVC_TITLE)
	    
	    addBrowseLegends(@oBrowse)    
	    
	    if oService:isTecnicalApprover()
	    	SET FILTER TO ZP5->(ZP5_STATUS == QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL .or. ZP5_APROVA == __cUserId)
	    endIf	
	         
	    oBrowse:activate()
	endif
	FreeObj(oAcl)
return

/**
 * Adiciona as Legendas do browse
 */
static function addBrowseLegends(oBrowse)
	
	local nI	   		:= 0
	local cStatus  		:= ""
	local cColor   		:= ""
	local cDescription	:= ""
	local oService 		:= CbcQuotationService():newCbcQuotationService()
	local aStatus  		:= {QUOTATION_STATUS_UNDER_MAINTENANCE, QUOTATION_STATUS_WAITING_APPROVAL, QUOTATION_STATUS_APPROVINGLY, ;
					   		QUOTATION_STATUS_WAITING_CONFIRM, QUOTATION_STATUS_CONFIRMED, QUOTATION_STATUS_NOT_APPROVED, ;
					   		QUOTATION_STATUS_CANCELED, QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL, QUOTATION_STATUS_WAITING_PROCESSING, ;
					   		QUOTATION_STATUS_PROCESSING, QUOTATION_STATUS_ERROR_PROCESSING, QUOTATION_STATUS_TECNICAL_REJECT }		
	
	for nI := 1 to Len(aStatus)	
		cStatus      := aStatus[nI]
		cColor       := oService:getColorStatus(cStatus)
		cDescription := oService:getDescStatus(cStatus)
		oBrowse:addLegend("ZP5_STATUS == '"+cStatus+"'", cColor, cDescription)
	next nI	
    
	
return

/**
 * Opções do browse
 */
static function menuDef()
    
    local aOpcoes      := {}
    local cViewId      := "viewDef."+MVC_MAIN_ID
    local cPrint	   := "Eval(bPrint)"
    local cTecApproval := "Eval(bTecApproval)"
    local cToOrder	   := "Eval(bToOrder)"
    local cCancLote	   := "Eval(bCancLote)"
	local cCalcImp	   := "Eval(bCalcImp)"
    local oService     := CbcQuotationService():newCbcQuotationService()
    
    ADD OPTION aOpcoes TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 1 ACCESS 0
    
    if oService:isTecnicalApprover()
    	ADD OPTION aOpcoes TITLE "Aprov. Técnica" ACTION cTecApproval OPERATION 2 ACCESS 0
    else
    	ADD OPTION aOpcoes TITLE "Canc.Lote" ACTION cCancLote OPERATION 2 ACCESS 0
    	ADD OPTION aOpcoes TITLE "Visualizar" ACTION cViewId  OPERATION 2 ACCESS 0
    	ADD OPTION aOpcoes TITLE "Imprimir" ACTION cPrint OPERATION 8 ACCESS 0
		ADD OPTION aOpcoes TITLE "Calc. Imposto" ACTION cCalcImp OPERATION 2 ACCESS 0
    endIf	
    
    if FwIsAdmin()
    	ADD OPTION aOpcoes TITLE "Trans. Pedido" ACTION cToOrder OPERATION 2 ACCESS 0
    endif
    
return aOpcoes

/**
 * Modelagem
 */
static function modelDef()
    
    local bValidModel := {|oModel| validModel(oModel)}
    local oModel      := MpFormModel():new(MVC_MODEL_ID, bValidModel, bValidModel)
    local oZP5        := FwFormStruct(MVC_MODEL_STRUCT, "ZP5")
    local oZP6        := FwFormStruct(MVC_MODEL_STRUCT, "ZP6")
    local aRelation   := {}
    
    aAdd(aRelation, {"ZP6_FILIAL","ZP5_FILIAL"})
    aAdd(aRelation, {"ZP6_NUM","ZP5_NUM"})
    
    oModel:setDescription(MVC_TITLE)
    oModel:addFields("ZP5", nil, oZP5)
    oModel:getModel("ZP5"):setDescription("Dados do Orçamento") 
    
    oModel:addGrid("ZP6", "ZP5", oZP6)
    oModel:getModel("ZP6"):setDescription("Itens do Orçamento")
    oModel:setRelation("ZP6", aRelation, ZP6->(IndexKey(1)))
    
    oModel:setPrimaryKey({"ZP5_FILIAL","ZP5_NUM"})

return oModel

/**
 * Interface Visual
 */
static function viewDef()

    local oView  := FwFormView():new()
    local oModel := FwLoadModel(MVC_MAIN_ID)
    local oZP5   := FwFormStruct(MVC_VIEW_STRUCT, "ZP5")
    local oZP6   := FwFormStruct(MVC_VIEW_STRUCT, "ZP6")
    
    oView:setModel(oModel)
    oView:addField("ZP5", oZP5, "ZP5")
    oView:addGrid("ZP6", oZP6, "ZP6")
    
    oView:createHorizontalBox("box_top", 35)
    oView:createHorizontalBox("box_bottom", 65)
    
    oView:createFolder("folder", "box_bottom")
    oView:addSheet("folder", "sheet01", "Itens") 
    oView:createHorizontalBox("boxFolderSheet01", 100, , , "folder","sheet01")
    
    oView:setOwnerView("ZP5", "box_top")
    oView:setOwnerView("ZP6", "boxFolderSheet01")

return oView

/**
 * Validação do Model
 */
static function validModel(oModel)
    
    local lOk := .T.        
    
return lOk

/**
 * Geração de PDF do Orçamento posicionado
 */
static function createPdf()
	
	local lShow		    := .T.
	local cPdf			:= ""	
	local cFolder		:= "C:\"
	local cQuotationId	:= ZP5->ZP5_NUM
	local oService	 	:= CbcQuotationService():newCbcQuotationService()
	local oQuotation 	:= oService:getById(cQuotationId)
	local oReport	 	:= CbcQuotationReport():newCbcQuotationReport(oQuotation, cFolder, lShow)
	
	if oReport:setup("PDF do Orçamento "+cQuotationId)
						
		MsAguarde({|| cPdf := oReport:run() }, "Aguarde", "Gerando PDF ...")
		
		if !Empty(cPdf)		
			MsgBox("Arquivo "+cPdf+" gerado com sucesso!", "Aviso", "INFO")	
		endIf	
		
		oReport:clear()
		
	endIf
	
return

/*/{Protheus.doc} budtgetToOrder
@author bolognesi
@since 12/06/2017
@version undefined
@type function
@description Realizar o processamento individual do orçamento
submetendo-o a rotina que transforma em pedido.
/*/
static function budtgetToOrder()
	if MsgNoYes('Confirma o inicio do processo de geração de pedido para orçamento ' + Alltrim(ZP5->(ZP5_NUM)) + '?')
		U_manBtoOr( ZP5->(ZP5_NUM) )
	endif
return(nil)

/**
 * Aprovação Técnica dos Orçamentos
*/
static function tecnicalApproval()
	
	local oDlg 	 		:= nil
	local oGrid	 		:= nil
	local oSayId		:= nil
	local oSayOwner		:= nil
	local oSayCustomer	:= nil
	local oSayCity		:= nil
	local oGetId		:= nil
	local oGetOwner		:= nil
	local oGetCustomer	:= nil
	local oGetCity		:= nil
	local oSrvQuotation := CbcQuotationService():newCbcQuotationService()
	local oSrvCustomer  := CbcCustomerService():newCbcCustomerService()
	local oQuotation	:= oSrvQuotation:getById(ZP5->ZP5_NUM)
	local oCustomer		:= oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer())
	local cCity			:= AllTrim(oCustomer:getCity()) + " / " + oCustomer:getState()
	local cStatus		:= oQuotation:getStatus()
		
	DEFINE MSDIALOG oDlg TITLE "Aprovação Técnica de Orçamento" FROM 001,001 TO 360,800 PIXEL OF oMainWnd								
		
		@ 007,005 SAY oSayId PROMPT "Orçamento" SIZE 050,007 OF oDlg PIXEL
		@ 005,035 MSGET oGetId VAR oQuotation:getId() WHEN .F. SIZE 030,010 PIXEL OF oDlg		
		
		@ 007,085 SAY oSayOwner PROMPT "Status" SIZE 050,007 OF oDlg PIXEL
		@ 005,105 MSGET oGetOwner VAR oSrvQuotation:getDescStatus(cStatus) WHEN .F. SIZE 120,010 PIXEL OF oDlg
		
		@ 007,232 SAY oSayOwner PROMPT "Reponsável" SIZE 050,007 OF oDlg PIXEL
		@ 005,265 MSGET oGetOwner VAR oQuotation:getNameUser() WHEN .F. SIZE 130,010 PIXEL OF oDlg
		
		@ 025,005 SAY oSayCustomer PROMPT "Cliente" SIZE 050,007 OF oDlg PIXEL
		@ 023,035 MSGET oGetCustomer VAR oCustomer:getName() WHEN .F. SIZE 190,010 PIXEL OF oDlg
		
		@ 025,238 SAY oSayCity PROMPT "Municipio" SIZE 050,07 OF oDlg PIXEL
		@ 023,265 MSGET oGetCity VAR cCity WHEN .F. SIZE 130,010 PIXEL OF oDlg
		
		createAppGrid(@oGrid, oDlg, oQuotation)	
		
		@ 160,5 BUTTON "Detalhes" SIZE 35,12 ACTION {|| showTecAppDetails(oQuotation) } PIXEL OF oDlg
		
		if (cStatus == QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL)			
			@ 160,280 BUTTON "Sair" SIZE 35,12 ACTION {|| oDlg:end() } PIXEL OF oDlg
			@ 160,320 BUTTON "Rejeitar" SIZE 35,12 ACTION {|| tecReject(oDlg) } PIXEL OF oDlg
			@ 160,360 BUTTON "Aprovar" SIZE 35,12 ACTION {|| tecApproval(oDlg) } PIXEL OF oDlg			
		else			
			@ 160,360 BUTTON "Sair" SIZE 35,12 ACTION {|| oDlg:end() } PIXEL OF oDlg			
		endIf
		
							
	ACTIVATE MSDIALOG oDlg CENTERED	

return

/**
 * Criação do grid da tela de Aprovação Técnica
 */
static function createAppGrid(oGrid, oDlg, oQuotation)
	
	local nI		:= 0
	local nCol		:= 5
	local nRow		:= 45
	local nWidth	:= 395
	local nHeight	:= 150	
	local oItem		:= nil
	local oSql		:= LibSqlObj():newLibSqlObj()
	local oGrid		:= LibGridObj():newLibGridObj(nCol, nRow, nWidth, nHeight, oDlg)
	local aItems	:= oQuotation:getItems() 			
	
	oGrid:setReadOnly(.T.)	
	oGrid:clear()			
	
	oGrid:addColumn("ZP6_ITEM")
	oGrid:addColumn("ZP6_DESCRI"):setSize(60)
	oGrid:addColumn("ZP6_QUANT")
	oGrid:addColumn("ZP6_QTDESP"):setTitle("Qtd. Esp.")
	oGrid:addColumn("ZP6_ESPECI"):setSize(50)
	oGrid:addColumn(LibColumnObj():newLibColumnObj("colors", "Cores", "C", 120)) 
	
	for nI := 1 to Len(aItems)
		
		oItem := aItems[nI]
		
		oGrid:newLine()
		oGrid:setValue("ZP6_ITEM", oItem:getItem())
		oGrid:setValue("ZP6_DESCRI", oItem:getDescription())
		oGrid:setValue("ZP6_QUANT", oItem:getQuantity())
		oGrid:setValue("ZP6_QTDESP", if (oItem:isSpecificPackageAmount(), "S", "N"))
		oGrid:setValue("ZP6_ESPECI", oSql:getFieldValue("SZ4", "Z4_DESC", "%SZ4.XFILIAL% AND Z4_COD = '" + oItem:getSpecialty() + "'"))
		oGrid:setValue("colors", getColors(oItem))
		
	next nI
	
	oGrid:create()
	
return

/**
 * Coleta a Descrição das Cores do Item
 */
static function getColors(oItem)
	
	local nI	  := 0
	local oColor  := nil
	local cColors := ""
	local aColors := oItem:getColors()
	
	for nI := 1 to Len(aColors)
		
		oColor := aColors[nI]
		
		if (nI > 1)
			cColors += ", "
		endIf
		
		cColors += AllTrim(oColor:getColorName())+": "
		cColors += AllTrim(Transform(oColor:getTotal(), "@E 999,999,999"))
		
	next nI
	
return cColors

/**
 * Exibe os Detalhes da Aprovação Técnica
 */
static function showTecAppDetails(oQuotation)
	
	local nI	   := 0
	local cDetails := ""
	local aRules   := {}
	local oService := CbcQuotationService():newCbcQuotationService()
	
	oService:checkRules(@oQuotation)
	
	aRules := oQuotation:getRules()
	
	for nI := 1 to Len(aRules)
		if (aRules[nI]:getType() == QUOTATION_PACKAGING_RULES)
			cDetails := aRules[nI]:getComments()
			exit
		endIf
	next nI
	
	cDetails := StrTran(cDetails, "<br/>", CRLF)
	cDetails := StrTran(cDetails, "<hr/>", CRLF+CRLF)
	cDetails := StrTran(cDetails, "<b>", "")
	cDetails := StrTran(cDetails, "</b>", "")
	
	Aviso("Aprovação Técnica", cDetails, {"Ok"}, 3, "Detalhes") 
	
return

/**
 * Rejeição Técnica do Orçamento
 */
static function tecReject(oDlg)
	
	local lOk			:= .F.
	local lApproved 	:= .F.
	local cReason		:= ""
	local cComments		:= ""
	local cQuotationId	:= ZP5->ZP5_NUM
	local oParam 		:= nil	
	local oService  	:= CbcQuotationService():newCbcQuotationService()
	local oParamBox 	:= LibParamBoxObj():newLibParamBoxObj("RejOrcPort")
	local aCombo		:= getRejectReasonsCombo()
	
	oParamBox:setTitle("Rejeição Técnica de Orçamentos")
	oParamBox:setValidation({|| vldTecRejection(oParamBox) })
	oParamBox:setCanSave(.F.)
	oParamBox:setUserSave(.F.)
	
	oParam := LibParamObj():newLibParamObj("reason", "combo", "Motivo", "C", 120)
	oParam:setRequired(.T.)
	oParam:setValues(aCombo)    
	oParamBox:addParam(oParam)
	
	oParam := LibParamObj():newLibParamObj("comments", "get", "Observações", "C", 120, Len(ZP5->ZP5_OBAPTE))
	oParamBox:addParam(oParam)
	
	if oParamBox:show()
		
		cReason   := oParamBox:getValue("reason")
		cComments := oParamBox:getValue("comments")
		
		if oService:tecnicalApproval(__cUserId, cQuotationId, lApproved, cComments, cReason)
			MsgBox("Orçamento rejeitado", "Aviso", "INFO")
			oDlg:end()
		else
			MsgBox(oService:getErrorMessage(), "Atenção", "ALERT")	
		endIf
		
	endIf
	
return

/**
 * Validação da Rejeição Técnica
 */
static function vldTecRejection(oParamBox)
	
	local cQuotationId	:= ZP5->ZP5_NUM
	local cReason   	:= MV_PAR01
	local cComments 	:= MV_PAR02
	
	if (cReason == "99") .and. Empty(cComments)
		MsgBox("Informe alguma observação sobre a rejeição", "Atenção", "ALERT")
		return .F.
	endIf
	
return ApMsgYesNo("Confirma rejeição técnica do Orçamento " + cQuotationId + "  ?")

/**
 * Carrega o Array com os Motivos de Rejeição Técnica
 */
static function getRejectReasonsCombo()
	
	local aCombo := {}
	local oSql	 := LibSqlObj():newLibSqlObj()
	
	oSql:newTable("SX5", "X5_CHAVE [ID], X5_DESCRI [VALUE]", "%SX5.XFILIAL% AND X5_TABELA = '_4'")
	
	while oSql:notIsEof()
		
		aAdd(aCombo, oSql:getValue("AllTrim(ID)") + "=" + oSql:getValue("AllTrim(VALUE)"))
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aCombo

/**
 * Aprovação Técnica do Orçamento
 */
static function tecApproval(oDlg)
	
	local lApproved 	:= .T.
	local cQuotationId	:= ZP5->ZP5_NUM
	local oService  	:= CbcQuotationService():newCbcQuotationService()
	
	if !MsgBox("Confirma aprovação do Orçamento " + AllTrim(cQuotationId) + " ?", "Aprovação Técnica", "YESNO")
		return
	endIf
	
	if oService:tecnicalApproval(__cUserId, cQuotationId, lApproved)
		MsgBox("Orçamento aprovado", "Aviso", "INFO")
		oDlg:end()
	else
		MsgBox(oService:getErrorMessage(), "Atenção", "ALERT")	
	endIf
	
return

