#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcMessageService

Serviços referentes as Mensagens do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcMessageService from CbcService
	
	method newCbcMessageService() constructor
	
	method create()
	method findByUser()
	method findByQuotation()
	method setDisplayed()
	method sendPendingEmails()
	method sendEmail() 
	method getNotDisplayedCount()
	method delete()
	method archive()
	
endClass


/*/{Protheus.doc} newCbcMessageService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcMessageService() class CbcMessageService
return self


/*/{Protheus.doc} create

Criação de Mensagens
	
@author victorhugo
@since 24/02/2016

@param cFromUser, String, ID do Usuário de Origem
@param aToUsers, String, IDs dos Usuários de Destino
@param aToGroups, String, IDs dos Grupos de Usuários de Destino
@param cSubject, String, Assunto da Mensagem
@param cText, String, Texto da Mensagem
@param cQuotationId, String, Id do Orçamento (opcional)

@return Logico Indica se a Mensagem foi enviada com sucesso
/*/
method create(cFromUser, aToUsers, aToGroups, cSubject, cText, cQuotationId) class CbcMessageService
	 
	local nI		:= 0  
	local lOk		:= .T.	
	local cCodFil	:= "" 
	local cId		:= ""
	local cToUser	:= ""
	local aData 	:= {}
	local aUsers	:= getUsersIds(aToUsers, aToGroups)
	local oSql		:= LibSqlObj():newLibSqlObj()	
	
	if Empty(cSubject)
		cSubject := "(sem assunto)"
	endIf	
	
	if !validCreate(@self, cFromUser, aUsers, cSubject, cText, cQuotationId)
		return .F. 
	endIf
	
	if !Empty(cQuotationId)
		checkQuotationUsers(cFromUser, cQuotationId, @aUsers)
	endIf
	
	begin transaction
			
	for nI := 1 to Len(aUsers)
				
		cToUser := aUsers[nI]
		cCodFil := xFilial("ZP3")
		cId		:= GetSxeNum("ZP3", "ZP3_CODIGO")
			
		aAdd(aData, {"ZP3_FILIAL", cCodFil})
		aAdd(aData, {"ZP3_CODIGO", cId})
		aAdd(aData, {"ZP3_USRORI", cFromUser})
		aAdd(aData, {"ZP3_USRDES", cToUser})
		aAdd(aData, {"ZP3_DATA", Date()})
		aAdd(aData, {"ZP3_HORA", Left(Time(), 5)})
		aAdd(aData, {"ZP3_ASSUNT", cSubject})
		aAdd(aData, {"ZP3_MSG", cText})
		aAdd(aData, {"ZP3_ARQ", "N"})
		aAdd(aData, {"ZP3_NUMORC", cQuotationId}) 
		
		if oSql:insert("ZP3", aData)
			ConfirmSx8()
		else
			lOk := .F.
			::cErrorMessage := "Falha na gravação da Mensagem"
			RollBackSx8()
			DisarmTransaction()
			exit 
		endIf
		
	next nI	
	
	end transaction
			
return lOk

/**
 * Coleta os IDs dos Usuários para criação da mensagem
 */
static function getUsersIds(aToUsers, aToGroups)
	
	local nI	 	  := 0
	local cUserId	  := ""
	local cQuery	  := ""
	local cInGroups   := ""
	local aUsers 	  := {}
	local oSql	 	  := LibSqlObj():newLibSqlObj()
	default aToUsers  := {}
	default aToGroups := {}
	
	for nI := 1 to Len(aToGroups)
		cInGroups += if(Empty(cInGroups), "", ",") 
		cInGroups += aToGroups[nI]
	next nI
	
	if !Empty(cInGroups)
		
		cQuery := " SELECT ZP1_CODIGO USER_ID FROM %ZP1.SQLNAME% "
		cQuery += " WHERE %ZP1.XFILIAL% AND ZP1_GRUPO IN ( "+cInGroups+" ) AND %ZP1.NOTDEL% "
		
		oSql:newAlias(cQuery)
		
		while oSql:notIsEof()
			
			cUserId := oSql:getValue("USER_ID")
			
			if (aScan(aUsers, cUserId) == 0)
				aAdd(aUsers, cUserId)
			endIf
			
			oSql:skip()
		endDo
		
		oSql:close()
		
	endIf
	
	for nI := 1 to Len(aToUsers)
		
		cUserId := aToUsers[nI]
			
		if (aScan(aUsers, cUserId) == 0)
			aAdd(aUsers, cUserId)
		endIf
		
	next nI
	
return aUsers

/**
 * Valida a criação de uma mensagem
 */
static function validCreate(oSelf, cFromUser, aUsers, cSubject, cText, cQuotationId)
	
	local lOk   	:= .F.
	local oFromUser := nil
	local oSrvUser	:= CbcUserService():newCbcUserService()
	local oUtils	:= LibUtilsObj():newLibUtilsObj()
	local oSql		:= LibSqlObj():newLibSqlObj()
	
	begin sequence
		
		if Empty(cFromUser)
			oSelf:cErrorMessage := "Usuário de origem não informado"
			break
		endIf
		
		oFromUser := oSrvUser:findById(cFromUser)
		if oUtils:isNull(oFromUser)
			oSelf:cErrorMessage := "Usuário de origem inválido"
			break
		endIf
		
		if (Empty(cQuotationId) .and. Len(aUsers) == 0)
			oSelf:cErrorMessage := "Nenhum usuário encontrado para envio da mensagem"
			break
		endIf	
		
		if (!Empty(cQuotationId) .and. !oSql:exists("ZP5", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'"))
			oSelf:cErrorMessage := "Orçamento inválido"
			break
		endIf
		
		if Empty(cText)
			oSelf:cErrorMessage := "Texto não informado"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
return lOk

/**
 * Verifica os Usuários para Envio da Mensagem de Orçamentos
 */
static function checkQuotationUsers(cFromUser, cQuotationId, aUsers)
	
	local cOwner 	:= ""
	local cApprover	:= ""
	local oSql 	 	:= LibSqlObj():newLibSqlObj()
	
	oSql:newTable("ZP5", "ZP5_RESPON [OWNER], ZP5_APROVA [APPROVER]", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")
	
	cOwner    := oSql:getValue("OWNER")
	cApprover := oSql:getValue("APPROVER")
	
	oSql:close()
	
	if (cFromUser != cOwner)
		aAdd(aUsers, cOwner)
	endIf
		
	if (!Empty(cApprover) .and. cFromUser != cApprover)
		aAdd(aUsers, cApprover)
	endIf
	
	if Empty(aUsers)
		aAdd(aUsers, "")
	endIf
	
return


/*/{Protheus.doc} findByUser

Coleta as Mensagens de um Usuário
	
@author victorhugo
@since 24/02/2016

@param cToUser, String, ID do Usuário de Destino das Mensagens
@param lDisplayed, Logico, Indica se retorna também as Notificações já visualizadas (por padrão assume .F.)
@param cFromUser, String, ID do Usuário de Origem das Mensagens (opcional)
@param cLastId, String, ID da última Mensagem coletada (opcional)
@param nMaxRegs, Numerico, Número máximo de registros a serem considerados (opcional)
@param lSetDisplayed, Logico, Indica de deve definir as mensagens retornadas como visualizadas (por padrão assume .F.)

@return Vetor Lista de Mensagens (CbcMessage) 
/*/
method findByUser(cToUser, lDisplayed, cFromUser, cLastId, nMaxRegs, lSetDisplayed) class CbcMessageService
	
	local cTop				:= "" 
	local cQuery  			:= "" 
	local aMessages			:= {}
	local oMessage			:= nil
	local oSql	  			:= LibSqlObj():newLibSqlObj()
	default lDisplayed		:= .F.
	default cFromUser		:= ""
	default cLastId			:= ""
	default nMaxRegs		:= 5	
	default lSetDisplayed	:= .F.
	
	if (nMaxRegs > 0)
		cTop := "TOP "+AllTrim(Str(nMaxRegs))
	endIf
	
	cQuery := " SELECT "+cTop
	cQuery += getSqlFields()
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" FROM_USER ON "
	cQuery += " 		FROM_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND FROM_USER.ZP1_CODIGO = ZP3_USRORI AND FROM_USER.D_E_L_E_T_ = ' ' "
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" TO_USER ON "
	cQuery += " 		TO_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND TO_USER.ZP1_CODIGO = ZP3_USRDES AND TO_USER.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_USRDES = '"+cToUser+"' AND ZP3_ARQ != 'S' AND %ZP3.NOTDEL% "
	
	if !lDisplayed
		cQuery += " AND ZP3_DTVISU = ' ' "	
	endIf
	
	if !Empty(cLastId)
		cQuery += " AND ZP3_CODIGO < '"+cLastId+"' "
	endIf
	
	if !Empty(cFromUser)
		cQuery += " AND ZP3_USRORI = '"+cFromUser+"' "
	endIf
	
	cQuery += " ORDER BY ZP3_CODIGO DESC "
 	
	oSql:newAlias(cQuery)
	
	oSql:setField("CREATE_DATE", "D")
	oSql:setField("DISPLAY_DATE", "D")
	oSql:setField("EMAIL_DATE", "D")
	
	while oSql:notIsEof()
		
		oMessage := loadFromSql(oSql)		
		
		if lSetDisplayed
			::setDisplayed(oMessage:getId(), oMessage:getToUser())
		endIf
		
		aAdd(aMessages, oMessage) 		 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aMessages


/*/{Protheus.doc} findByQuotation

Coleta as Mensagens de um Orçamento
	
@author victorhugo
@since 24/02/2016

@param cQuotationId, String, ID do Orçamento

@return Vetor Lista de Mensagens (CbcMessage) 
/*/
method findByQuotation(cQuotationId) class CbcMessageService
	
	local nScan		:= 0
	local cQuery  	:= "" 
	local aMessages	:= {}
	local oMessage	:= nil
	local oSql	  	:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT "
	cQuery += getSqlFields()
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" FROM_USER ON "
	cQuery += " 		FROM_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND FROM_USER.ZP1_CODIGO = ZP3_USRORI AND FROM_USER.D_E_L_E_T_ = ' ' "
	cQuery += " 	LEFT JOIN "+RetSqlName("ZP1")+" TO_USER ON "
	cQuery += " 		TO_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND TO_USER.ZP1_CODIGO = ZP3_USRDES AND TO_USER.D_E_L_E_T_ = ' ' "	
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_NUMORC = '"+cQuotationId+"' AND %ZP3.NOTDEL% "
	
	cQuery += " ORDER BY ZP3_CODIGO DESC "
 	
	oSql:newAlias(cQuery)
	
	oSql:setField("CREATE_DATE", "D")
	oSql:setField("DISPLAY_DATE", "D")
	oSql:setField("EMAIL_DATE", "D")
	
	while oSql:notIsEof()
		
		oMessage := loadFromSql(oSql)		
		nScan	 := aScan(aMessages, {|oFoundMsg| oFoundMsg:getFromUser() == oMessage:getFromUser() .and. ;
						oFoundMsg:getDate() == oMessage:getDate() .and. oFoundMsg:getSubject() == oMessage:getSubject() .and. ;
						oFoundMsg:getText() == oMessage:getText() })	
		
		if (nScan == 0)
			aAdd(aMessages, oMessage)
		endIf 		 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aMessages

/**
 * Retorna os campos para consulta SQL das Mensagens
 */
static function getSqlFields()
	
	local cFields := ""
	
	cFields += " ZP3_CODIGO ID, ZP3_USRORI FROM_USER, ZP3_USRDES TO_USER, ZP3_DATA CREATE_DATE, ZP3_HORA CREATE_TIME, ZP3_ASSUNT SUBJECT, "
	cFields += " ZP3_DTVISU DISPLAY_DATE, ZP3_HRVISU DISPLAY_TIME, ZP3_DTMAIL EMAIL_DATE, ZP3_HRMAIL EMAIL_TIME, "
	cFields += " CAST(CAST(ZP3_MSG AS VARBINARY(8000)) AS VARCHAR(8000)) TEXT, ZP3_ARQ FILED, ZP3_NUMORC QUOTATION_ID, "
	cFields += " FROM_USER.ZP1_NOME FROM_USER_NAME, TO_USER.ZP1_NOME TO_USER_NAME "
	
return cFields

/**
 * Carrega a Mensagem a partir do objeto SQL
 */
static function loadFromSql(oSql)
	
	local oMessage := CbcMessage():newCbcMessage()
	
	oMessage:setId(oSql:getValue("ID"))
	oMessage:setFromUser(oSql:getValue("FROM_USER"))
	oMessage:setNameFromUser(oSql:getValue("AllTrim(Capital(FROM_USER_NAME))"))
	oMessage:setToUser(oSql:getValue("TO_USER"))
	oMessage:setNameToUser(oSql:getValue("AllTrim(Capital(TO_USER_NAME))"))
	oMessage:setDate(oSql:getValue("CREATE_DATE"))
	oMessage:setTime(oSql:getValue("CREATE_TIME"))
	oMessage:setSubject(oSql:getValue("AllTrim(SUBJECT)"))
	oMessage:setDateDisplay(oSql:getValue("DISPLAY_DATE"))
	oMessage:setTimeDisplay(oSql:getValue("DISPLAY_TIME"))
	oMessage:setText(oSql:getValue("AllTrim(TEXT)"))
	oMessage:setDateEmail(oSql:getValue("EMAIL_DATE"))
	oMessage:setTimeEmail(oSql:getValue("EMAIL_TIME"))
	oMessage:setFiled(oSql:getValue("FILED == 'S'"))
	oMessage:setQuotationId(oSql:getValue("QUOTATION_ID"))
	
return oMessage


/*/{Protheus.doc} setDisplayed

Define uma Mensagem como visualizada
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Mensagem
@param cToUser, String, ID do Usuário de Destino

@return Logico Indica se a Mensagem foi definida como visualizada
/*/
method setDisplayed(cId, cToUser) class CbcMessageService
	
	local lOk  	 := .F. 
	local oSql 	 := LibSqlObj():newLibSqlObj()
	local cWhere := "%ZP3.XFILIAL% AND ZP3_CODIGO = '"+cId+"' AND ZP3_USRDES = '"+cToUser+"'"	
	
	if oSql:exists("ZP3", cWhere)
		lOk := oSql:update("ZP3", "ZP3_DTVISU = '"+DtoS(Date())+"', ZP3_HRVISU = '"+Left(Time(), 5)+"'", cWhere)
	else
		::cErrorMessage := "Mensagem não encontrada" 
	endIf
	
return lOk


/*/{Protheus.doc} sendPendingEmails

Envia todos os e-mails pendentes
	
@author victorhugo
@since 18/03/2016

@param cMsg, String, Variável para atribuição da mensagem referente ao Processamento
@param lProcBar, Logico, Indica se deve incrementar a regua de processamento (se não informado assume .F.)

@return Logico Indica se ao menos um e-mail foi enviado
/*/
method sendPendingEmails(cMsg, lProcBar) class CbcMessageService
	
	local lOk		:= .F.
	local nRegs		:= 0
	local nSent		:= 0
	local cQuery 	:= ""
	local oSql   	:= LibSqlObj():newLibSqlObj()
	default lProcBar:= .F.
	
	cQuery := " SELECT ZP3_CODIGO ID, ZP3_USRDES TO_USER "
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_DTVISU = ' ' AND ZP3_DTMAIL = ' ' AND ZP3_USRDES != ' ' AND %ZP3.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	nRegs := oSql:count()
	
	if lProcBar
		ProcRegua(nRegs)
	endIf	 
	
	oSql:goTop()
	while oSql:notIsEof()
		
		if lProcBar
			IncProc()
		endIf	
		
		if ::sendEmail(oSql:getValue("ID"), oSql:getValue("TO_USER"))
			nSent++
		endIf
		
		oSql:skip()
	endDo
		
	oSql:close() 
	
	if (nRegs > 0)
		lOk  := (nSent > 0) 
		cMsg := "Processadas: "+AllTrim(Str(nRegs))+CRLF+"Enviadas: "+AllTrim(Str(nSent)) 
	else
		cMsg := "Nenhum registro encontrado"
	endIf 

return lOk


/*/{Protheus.doc} sendEmail

Envia a Mensagem por E-mail
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Mensagem
@param cToUser, String, ID do Usuário de Destino

@return Logico Indica se o e-mail foi enviado
/*/
method sendEmail(cId, cToUser) class CbcMessageService
	
	local lOk  	 := .F.
	local cQuery := "" 
	local oSql 	 := LibSqlObj():newLibSqlObj()

	cQuery := " SELECT FROM_USER.ZP1_NOME FROM_NAME, FROM_USER.ZP1_EMAIL FROM_EMAIL, " 
	cQuery += "		   TO_USER.ZP1_NOME TO_NAME, TO_USER.ZP1_EMAIL TO_EMAIL, "
	cQuery += "		   ZP3_ASSUNT SUBJECT, ZP3_DATA CREATE_DATE, ZP3_HORA CREATE_TIME, "
	cQuery += " 	   CAST(CAST(ZP3_MSG AS VARBINARY(8000)) AS VARCHAR(8000)) [TEXT] "
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" FROM_USER ON "
	cQuery += " 		FROM_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND FROM_USER.ZP1_CODIGO = ZP3_USRORI AND FROM_USER.D_E_L_E_T_ = ' ' " 
	cQuery += " 	INNER JOIN "+RetSqlName("ZP1")+" TO_USER ON "
	cQuery += " 		TO_USER.ZP1_FILIAL = '"+xFilial("ZP1")+"' AND TO_USER.ZP1_CODIGO = ZP3_USRDES AND TO_USER.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_CODIGO = '"+cId+"' AND ZP3_USRDES = '"+cToUser+"' AND %ZP3.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	oSql:setField("CREATE_DATE", "D") 
	
	if sendEmail(@self, oSql)
		lOk := .T.
		oSql:update("ZP3", "ZP3_DTMAIL = '"+DtoS(Date())+"', ZP3_HRMAIL = '"+Left(Time(), 5)+"'", "%ZP3.XFILIAL% AND ZP3_CODIGO = '"+cId+"' AND ZP3_USRDES = '"+cToUser+"'")
	else
		ConOut("Falha ao Enviar Mensagem por E-mail: "+::cErrorMessage)
	endIf 
	
	oSql:close()
		
return lOk

/**
 * Envia a Mensagem por E-mail
 */
static function sendEmail(oSelf, oSql)
	
	local lOk 			:= .F.
	local oMail 		:= LibMailObj():newLibMailObj()
	local cBody			:= "" 
	local cHtml 		:= MESSAGE_EMAIL_HTML	
	local cTo			:= oSql:getValue("AllTrim(TO_EMAIL)")
	local cFrom			:= oSql:getValue("AllTrim(Capital(FROM_NAME))") 
	local cMessage		:= oSql:getValue("AllTrim(TEXT)") 
	local cUserName 	:= oSql:getValue("Capital(AllTrim(TO_NAME))")
	local cDateTime 	:= oSql:getValue("DtoC(CREATE_DATE)+' - '+CREATE_TIME")
	local cSubject		:= oSql:getValue("AllTrim(SUBJECT)")
	
	if !oSql:hasRecords()
		oSelf:cErrorMessage := "Mensagem não encontrada"
		return .F.
	endIf
	
	if Empty(cTo)
		oSelf:cErrorMessage := "E-mail não definido para o Usuário "+cUserName
		return .F.
	endIf
	
	if oMail:setHtmlLayout(cHtml)
		oMail:setHtmlValue("userName", cUserName)
		oMail:setHtmlValue("fromUser", cFrom)
		oMail:setHtmlValue("dateTime", cDateTime)
		oMail:setHtmlValue("subject", cSubject)
		oMail:setHtmlValue("text", StrTran(cMessage, CRLF, "<br/>"))
	else	
		oSelf:cErrorMessage := "Arquivo "+cHtml+" não encontrado"
		return .F. 
	endIf
	
	if oMail:send(cTo, "Portal Cobrecom - "+cSubject, cBody)
		lOk := .T.		
	else
		oSelf:cErrorMessage := oMail:getError()
		return .F.
	endIf
	
return lOk


/*/{Protheus.doc} getNotDisplayedCount

Coleta a quantidade de Mensagens não visualizadas de um usuário	
	
@author victorhugo
@since 04/05/2016

@param cUserId, String, ID do Usuário de Destino das Mensagens
@param cFromUser, String, ID do Usuário Remetente (opcional)

@return Numerico Quantidade de Mensagens não visualizadas
/*/
method getNotDisplayedCount(cUserId, cFromUser) class CbcMessageService
	
	local nRegs		:= 0
	local cQuery 	:= ""
	local oSql   	:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT COUNT(*) REGS "
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_DTVISU = ' ' AND ZP3_USRDES = '"+cUserId+"' AND %ZP3.NOTDEL% "
	
	if !Empty(cFromUser)
		cQuery += " AND ZP3_USRORI = '"+cFromUser+"' "
	endIf
	
	oSql:newAlias(cQuery)
	
	nRegs := oSql:getValue("REGS")
	
	oSql:close()

return nRegs


/*/{Protheus.doc} delete

Remove uma Mensagem
	
@author victorhugo
@since 16/05/2016

@param cId, String, ID da Mensagem

@return Logico Indica se a mensagem foi excluida
/*/
method delete(cId) class CbcMessageService
	
	local lOk	 := .F.
	local cWhere := ""
	local oSql   := LibSqlObj():newLibSqlObj()

	cWhere := "%ZP3.XFILIAL% AND ZP3_CODIGO = '"+cId+"'"
	
	if oSql:exists("ZP3", cWhere)
		lOk := .T.
		oSql:delete("ZP3", cWhere)
	else
		::cErrorMessage := "Mensagem não encontrada"
	endIf

return lOk


/*/{Protheus.doc} archive

Arquiva uma Mensagem
	
@author victorhugo
@since 16/05/2016

@param cId, String, ID da Mensagem

@return Logico Indica se a mensagem foi arquivada
/*/
method archive(cId) class CbcMessageService
	
	local lOk	 := .F.
	local cWhere := ""
	local oSql   := LibSqlObj():newLibSqlObj()

	cWhere := "%ZP3.XFILIAL% AND ZP3_CODIGO = '"+cId+"'"
	
	if oSql:exists("ZP3", cWhere)
		lOk := .T.
		oSql:update("ZP3", "ZP3_ARQ = 'S'", cWhere)
	else
		::cErrorMessage := "Mensagem não encontrada"
	endIf

return lOk
