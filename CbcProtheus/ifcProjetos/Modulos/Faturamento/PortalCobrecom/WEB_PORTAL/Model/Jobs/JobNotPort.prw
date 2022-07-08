#include "totvs.ch"
#include "rwmake.ch"

#define COMPANY_CODE	"01"
#define BRANCH_CODE		"01"


/*/{Protheus.doc} JobNotPort

Job das Notificações do Portal Cobrecom
    
@author victorhugo
@since 18/03/2016
/*/
user function JobNotPort()
	
	local cMsg		:= "" 	
	local oEnv 		:= LibEnvironmentObj():newLibEnvironmentObj()
	local oService	:= CbcNotificationService():newCbcNotificationService()
	
	oEnv:setCompany(COMPANY_CODE)  
	oEnv:setBranch(BRANCH_CODE) 
	oEnv:load()
	
	showConsoleMsg("Iniciando envio das Notificações pendentes por e-mail ...")
	
	oService:sendPendingEmails(@cMsg)
	
	showConsoleMsg(cMsg)	
	showConsoleMsg("Processamento concluído!")
	
return

/**
 * Exibe as mensagens no console
 */
static function showConsoleMsg(cMsg)
	
	ConOut("[JobNotPort - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
	
return