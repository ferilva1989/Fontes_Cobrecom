#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcNotificationService

Serviços referentes as Notificações do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcNotificationService from CbcService
	
	method newCbcNotificationService() constructor
	
	method create()
	method findByUser()
	method setDisplayed()
	method sendPendingEmails()
	method sendEmail() 
	method getNotDisplayedCount()
	
endClass


/*/{Protheus.doc} newCbcNotificationService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcNotificationService() class CbcNotificationService
return self


/*/{Protheus.doc} create

Cria Notificações para um Evento
	
@author victorhugo
@since 24/02/2016

@param oEvent, CbcEvent, Evento do Portal Cobrecom

@return String ID gerado para as Notificações
/*/
method create(oEvent) class CbcNotificationService
	
	local nI  			:= 0
	local cId			:= "" 
	local cToUser		:= "" 
	local aData 		:= {}
	local lSendEmail	:= .F.
	local aToUsers		:= oEvent:getNotifyUsers()
	local aSendEmail	:= oEvent:getEmailUsers()
	local oSql			:= LibSqlObj():newLibSqlObj()	
	
	if (Len(aToUsers) == 0)
		return "" 
	endIf
	
	clearIdsVetor(@aToUsers)
	clearIdsVetor(@aSendEmail)
	
	begin transaction
		
		for nI := 1 to Len(aToUsers)
			
			aData 		:= {}
			cToUser		:= aToUsers[nI]
			lSendEmail	:= (aScan(aSendEmail, cToUser) > 0)
			cId			:= GetSxeNum("ZP2", "ZP2_CODIGO")
			
			aAdd(aData, {"ZP2_FILIAL", xFilial("ZP2")})
			aAdd(aData, {"ZP2_CODIGO", cId})
			aAdd(aData, {"ZP2_EVENTO", oEvent:getId()})
			aAdd(aData, {"ZP2_USRORI", oEvent:getFromUser()})
			aAdd(aData, {"ZP2_USRDES", cToUser})
			aAdd(aData, {"ZP2_DATA", Date()})
			aAdd(aData, {"ZP2_HORA", Left(Time(), 5)})
			aAdd(aData, {"ZP2_MSG", oEvent:getMessage()})
			aAdd(aData, {"ZP2_EMAIL", if(lSendEmail, "S", "N")}) 
			
			if oSql:insert("ZP2", aData)
				ConfirmSx8()
			else
				RollBackSx8()
				DisarmTransaction()
				::cErrorMessage := "Falha na gravação das Notificações"
				return "" 
			endIf
			
		next nI
	
	end transaction

return cId

/**
 * Remove as Duplicidades do Vetor de Ids
 */
static function clearIdsVetor(aVetor)
	
	local nI	 := 0
	local aClear := {}
	
	for nI := 1 to Len(aVetor)
		if (aScan(aClear, aVetor[nI]) == 0)
			aAdd(aClear, aVetor[nI])
		endIf
	next nI
	
	aVetor := aClone(aClear)
	
return


/*/{Protheus.doc} findByUser

Coleta as Notificações de um Usuário
	
@author victorhugo
@since 24/02/2016

@param cToUser, String, ID do Usuário de Destino das Notificações
@param lDisplayed, Logico, Indica se retorna também as Notificações já visualizadas (por padrão assume .F.)
@param cLastId, String, ID do último Evento coletado (opcional)
@param nMaxRegs, Numerico, Número máximo de registros a serem considerados (opcional)
@param lSetDisplayed, Logico, Indica de deve definir as notificações retornadas como visualizadas (por padrão assume .F.)

@return Vetor Lista de Notificações (CbcNotification) 
/*/
method findByUser(cToUser, lDisplayed, cLastId, nMaxRegs, lSetDisplayed) class CbcNotificationService
	
	local cTop				:= "" 
	local cQuery  			:= "" 
	local aNotifications	:= {}
	local oNotification		:= nil
	local oSql	  			:= LibSqlObj():newLibSqlObj()
	default lDisplayed		:= .F.
	default cLastId			:= ""
	default nMaxRegs		:= 300	
	default lSetDisplayed	:= .F.
	
	if (nMaxRegs > 0)
		cTop := "TOP "+AllTrim(Str(nMaxRegs))
	endIf
	
	cQuery := " SELECT "+cTop
	cQuery += " 	ZP2_CODIGO ID, ZP2_EVENTO EVENT_CODE, X5_DESCRI EVENT_NAME, ZP2_USRORI FROM_USER, ZP2_USRDES TO_USER, "
	cQuery += " 	ZP2_DATA CREATE_DATE, ZP2_HORA CREATE_TIME, ZP2_DTVISU DISPLAY_DATE, ZP2_HRVISU DISPLAY_TIME, "
	cQuery += " 	CAST(CAST(ZP2_MSG AS VARBINARY(8000)) AS VARCHAR(8000)) MESSAGE, ZP2_EMAIL EMAIL, ZP2_DTMAIL EMAIL_DATE, "
	cQuery += " 	ZP2_HRMAIL EMAIL_TIME "
	cQuery += " FROM %ZP2.SQLNAME% "
	cQuery += "  	INNER JOIN %SX5.SQLNAME% ON "
	cQuery += " 		%SX5.XFILIAL% AND X5_TABELA = '_2' AND X5_CHAVE = ZP2_EVENTO AND %SX5.NOTDEL% "	
	cQuery += " WHERE %ZP2.XFILIAL% AND ZP2_USRDES = '"+cToUser+"' AND %ZP2.NOTDEL% "
	
	if !lDisplayed
		cQuery += " AND ZP2_DTVISU = ' ' "	
	endIf
	
	if !Empty(cLastId)
		cQuery += " AND ZP2_CODIGO < '"+cLastId+"' "
	endIf
	
	cQuery += " ORDER BY ZP2_CODIGO DESC "
	
	oSql:newAlias(cQuery)
	
	oSql:setField("CREATE_DATE", "D")
	oSql:setField("DISPLAY_DATE", "D")
	oSql:setField("EMAIL_DATE", "D")
	
	while oSql:notIsEof()
		
		oNotification := CbcNotification():newCbcNotification()
		oNotification:setId(oSql:getValue("ID"))
		oNotification:setEvent(oSql:getValue("EVENT_CODE"))
		oNotification:setEventName(oSql:getValue("Capital(EVENT_NAME)"))
		oNotification:setFromUser(oSql:getValue("FROM_USER"))
		oNotification:setToUser(oSql:getValue("TO_USER"))
		oNotification:setDate(oSql:getValue("CREATE_DATE"))
		oNotification:setTime(oSql:getValue("CREATE_TIME"))
		oNotification:setDateDisplay(oSql:getValue("DISPLAY_DATE"))
		oNotification:setTimeDisplay(oSql:getValue("DISPLAY_TIME"))
		oNotification:setMessage(oSql:getValue("AllTrim(MESSAGE)"))
		oNotification:setEmail(oSql:getValue("EMAIL == 'S'"))
		oNotification:setDateEmail(oSql:getValue("EMAIL_DATE"))
		oNotification:setTimeEmail(oSql:getValue("EMAIL_TIME"))		
		
		if lSetDisplayed
			::setDisplayed(oNotification:getId(), oNotification:getToUser())
		endIf
		
		aAdd(aNotifications, oNotification) 		 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aNotifications


/*/{Protheus.doc} setDisplayed

Define uma Notificação como visualizada
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Notificação
@param cToUser, String, ID do Usuário de Destino

@return Logico Indica se a Notificação foi definida como visualizada
/*/
method setDisplayed(cId, cToUser) class CbcNotificationService
	
	local lOk  	 := .F. 
	local oSql 	 := LibSqlObj():newLibSqlObj()
	local cWhere := "%ZP2.XFILIAL% AND ZP2_CODIGO = '"+cId+"' AND ZP2_USRDES = '"+cToUser+"'"	
	
	if oSql:exists("ZP2", cWhere)
		lOk := oSql:update("ZP2", "ZP2_DTVISU = '"+DtoS(Date())+"', ZP2_HRVISU = '"+Left(Time(), 5)+"'", cWhere)
	else
		::cErrorMessage := "Notificação não encontrada" 
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
method sendPendingEmails(cMsg, lProcBar) class CbcNotificationService
	
	local lOk		:= .F.
	local nRegs		:= 0
	local nSent		:= 0
	local cQuery 	:= ""
	local oSql   	:= LibSqlObj():newLibSqlObj()
	default lProcBar:= .F.
	
	cQuery := " SELECT ZP2_CODIGO ID, ZP2_USRDES TO_USER "
	cQuery += " FROM %ZP2.SQLNAME% "
	cQuery += " WHERE %ZP2.XFILIAL% AND ZP2_EMAIL = 'S' AND ZP2_DTVISU = ' ' AND ZP2_DTMAIL = ' ' AND %ZP2.NOTDEL% "
	
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

Envia a Notificação por E-mail
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID da Notificação
@param cToUser, String, ID do Usuário de Destino

@return Logico Indica se o e-mail foi enviado
/*/
method sendEmail(cId, cToUser) class CbcNotificationService
	
	local lOk  	 := .F.
	local cQuery := "" 
	local oSql 	 := LibSqlObj():newLibSqlObj()

	cQuery := " SELECT ZP1_NOME USER_NAME, ZP1_EMAIL USER_EMAIL, ZP2_DATA CREATE_DATE, ZP2_HORA CREATE_TIME, X5_DESCRI EVENT_NAME, "
	cQuery += " 	   CAST(CAST(ZP2_MSG AS VARBINARY(8000)) AS VARCHAR(8000)) MESSAGE "
	cQuery += " FROM %ZP2.SQLNAME% "
	cQuery += " 	INNER JOIN %ZP1.SQLNAME% ON "
	cQuery += " 		%ZP1.XFILIAL% AND ZP1_CODIGO = ZP2_USRDES AND %ZP1.NOTDEL% "
	cQuery += "  	INNER JOIN %SX5.SQLNAME% ON "
	cQuery += " 		%SX5.XFILIAL% AND X5_TABELA = '_2' AND X5_CHAVE = ZP2_EVENTO AND %SX5.NOTDEL% "
	cQuery += " WHERE %ZP2.XFILIAL% AND ZP2_CODIGO = '"+cId+"' AND ZP2_USRDES = '"+cToUser+"' AND %ZP2.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	oSql:setField("CREATE_DATE", "D") 
	
	if sendEmail(@self, oSql)
		lOk := .T.
		oSql:update("ZP2", "ZP2_DTMAIL = '"+DtoS(Date())+"', ZP2_HRMAIL = '"+Left(Time(), 5)+"'", "%ZP2.XFILIAL% AND ZP2_CODIGO = '"+cId+"' AND ZP2_USRDES = '"+cToUser+"'")
	else
		if Empty(oSql:getValue("USER_EMAIL"))
			oSql:update("ZP2", "ZP2_EMAIL = 'N'", "%ZP2.XFILIAL% AND ZP2_CODIGO = '"+cId+"' AND ZP2_USRDES = '"+cToUser+"'")
		endIf
		ConOut("Falha ao Enviar Notificação por E-mail: "+::cErrorMessage)
	endIf 
	
	oSql:close()
		
return lOk

/**
 * Envia a Notificação por E-mail
 */
static function sendEmail(oSelf, oSql)
	
	local lOk 			:= .F.
	local oMail 		:= LibMailObj():newLibMailObj()
	local oNotif		:= CbcNotification():newCbcNotification()
	local cBody			:= "" 
	local cHtml 		:= NOTIFICATION_EMAIL_HTML	
	local cTo	   		:= oSql:getValue("USER_EMAIL")
	local cMessage		:= oSql:getValue("MESSAGE") 
	local cUserName 	:= oSql:getValue("Capital(AllTrim(USER_NAME))")
	local cDateTime 	:= oSql:getValue("DtoC(CREATE_DATE)+' - '+CREATE_TIME")
	local cEventName	:= oSql:getValue("Capital(AllTrim(EVENT_NAME))")
	local cSubject		:= "Portal Cobrecom - "+cEventName
	
	if !oSql:hasRecords()
		oSelf:cErrorMessage := "Notificação não encontrada"
		return .F.
	endIf
	
	if Empty(cTo)
		oSelf:cErrorMessage := "E-mail não definido para o Usuário "+cUserName
		return .F.
	endIf
	
	oNotif:setMessage(cMessage)
	
	if oMail:setHtmlLayout(cHtml)
		oMail:setHtmlValue("userName", cUserName)
		oMail:setHtmlValue("dateTime", cDateTime)
		oMail:setHtmlValue("eventName", cEventName)
		oMail:setHtmlValue("message", oNotif:getHtmlMessage()) 
	else	
		oSelf:cErrorMessage := "Arquivo "+cHtml+" não encontrado"
		return .F. 
	endIf
	
	if oMail:send(cTo, cSubject, cBody)
		lOk := .T.		
	else
		oSelf:cErrorMessage := oMail:getError()
		return .F.
	endIf
	
return lOk


/*/{Protheus.doc} getNotDisplayedCount

Coleta a quantidade de Notificações não visualizadas de um usuário	
	
@author victorhugo
@since 04/05/2016

@param cUserId, String, ID do Usuário de Destino das Notificações
/*/
method getNotDisplayedCount(cUserId) class CbcNotificationService
	
	local nRegs		:= 0
	local cQuery 	:= ""
	local oSql   	:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT COUNT(*) REGS "
	cQuery += " FROM %ZP2.SQLNAME% "
	cQuery += " WHERE %ZP2.XFILIAL% AND ZP2_DTVISU = ' ' AND ZP2_USRDES = '"+cUserId+"' AND %ZP2.NOTDEL% "
	
	oSql:newAlias(cQuery)
	
	nRegs := oSql:getValue("REGS")
	
	oSql:close()

return nRegs

