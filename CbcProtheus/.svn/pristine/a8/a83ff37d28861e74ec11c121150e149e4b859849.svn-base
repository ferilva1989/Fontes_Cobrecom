#include 'protheus.ch'
#include 'parmtype.ch'
#include 'shell.ch'

#define SRV_RESTART 1
#define SRV_START 2
#define SRV_STOP 3

user function runSrvPShell(cPath, cPsFile, lNoMsg)
	local cWaitRunCmd	:= ""
	local lRet			:= .T.
	local cMsgRet		:= ''
	
	default cPath		:= GetNewPar('ZZ_PSHELL', '\\SERVERAPP\Condusul\PS1\')
	default cPsFile		:= ""
	default lNoMsg		:= .F.
	
	if !empty(cPsFile) .and. !empty(cPath)
		if !(SubStr( cPath , -1 ) == "\" )
			cPath += "\"
		endif		
		cWaitRunCmd	:= 'PowerShell -NonInteractive -WindowStyle Hidden -noprofile -executionpolicy bypass -file "' + cPath + cPsFile + '"'
		FWMsgRun(, { || lRet := WaitRunSrv(@cWaitRunCmd, .T. , @cPath) }, "Iniciando PowerShell", "Processando...")
		if lRet
			cMsgRet := 'Script processado com sucesso!'
		else
			cMsgRet := 'Não foi possível executar o Script!'
		endif
	else
		lRet := .F.
		cMsgRet := 'Nome do Arquivo e Pasta devem ser informados!'
	endif
	
	if !empty(cMsgRet) .and. !lNoMsg
		if lRet
			MsgInfo(cMsgRet,'Executado com Sucesso')
		else	
			MsgAlert(cMsgRet,'Erro PowerShell')
		endif
	endif
return({lRet, cMsgRet})

user function cbcSvrShell(nMode, cSrvName, lNoMsg)
	local cPsScript	:= ''	
	local cPath		:= GetNewPar('ZZ_PSHELL', '\\SERVERAPP\Condusul\PS1\')
	local cNewPsFile:= ''
	local nSeq		:= 0
	local cFileName	:= ''
	local aRet		:= {.F.,'Erro Servico nao informado!'}
	default lNoMsg	:= .F.
	default nMode	:= SRV_RESTART

	if !empty(cSrvName)
		cFileName := 'cbcSrv' + cSrvName
		if nMode == SRV_START
			cPsScript := svrStart(cSrvName)
		elseif nMode == SRV_STOP
			cPsScript := svrStop(cSrvName)
		else
			cPsScript := srvRestart(cSrvName)
		endif			
		if !(SubStr( cPath , -1 ) == "\" )
			cPath += "\"
		endif		
		cNewPsFile			:= Lower( cPath + cFileName + '.ps1')
		While File( cNewPsFile )
			nSeq++
			cFileName := cValToChar(nSeq)
			cNewPsFile		:= Lower( cPath + cFileName + '.ps1')
		EndDo
		cFileName := Lower(cFileName + '.ps1')
		if!(MemoWrite( cNewPsFile , cPsScript ))
			aRet[2] := 'Erro ao Criar Arquivo de Script!'
		endif	
		if ( File( cNewPsFile ) )	
			aRet := U_runSrvPShell(cPath, cFileName, lNoMsg)
			fErase( cNewPsFile )
		else
			aRet[2] := 'Arquivo de Script nao encontrado!'
		endif
	endif
return(aRet)

static function srvRestart(cSrvName)			
	local cPsScript := ''

	cPsScript := '$NameProcess = "' + cSrvName + '"' + CRLF		
	cPsScript += 'if ( get-service | where { $_.name -eq $NameProcess} )' + CRLF
	cPsScript += '{' + CRLF	
	cPsScript += '	if ( get-service | where { $_.status -eq "running" -and $_.name -eq $NameProcess} )' + CRLF	
	cPsScript += '	{' + CRLF	
	cPsScript += '		invoke-expression -command ' + '"' + "taskkill -f -fi 'SERVICES eq $NameProcess' /t" + '"' + CRLF
	cPsScript += '	}'  + CRLF		
	cPsScript += '	start-sleep -seconds 10' + CRLF
	cPsScript += '	while ( get-service | where { $_.status -eq "stopped" -and $_.name -eq $NameProcess } )' + CRLF
	cPsScript += '	{' + CRLF
	cPsScript += '		start-service $NameProcess' + CRLF
	cPsScript += '	}' + CRLF
	cPsScript += '}' + CRLF
return(cPsScript)


static function svrStop(cSrvName)
	local cPsScript := ''
			
	cPsScript := '$NameProcess = "' + cSrvName + '"' + CRLF		
	cPsScript += 'if ( get-service | where { $_.name -eq $NameProcess} )' + CRLF
	cPsScript += '{' + CRLF	
	cPsScript += '	if ( get-service | where { $_.status -eq "running" -and $_.name -eq $NameProcess} )' + CRLF	
	cPsScript += '	{' + CRLF	
	cPsScript += '		invoke-expression -command ' + '"' + "taskkill -f -fi 'SERVICES eq $NameProcess' /t" + '"' + CRLF
	cPsScript += '	}'  + CRLF		
	cPsScript += '	start-sleep -seconds 03' + CRLF
	cPsScript += '	if ( get-service | where { $_.status -eq "stopped" -and $_.name -eq $NameProcess } )' + CRLF
	cPsScript += '	{' + CRLF
	cPsScript += '		set-service $NameProcess -startuptype Manual' + CRLF
	cPsScript += '	}' + CRLF
	cPsScript += '}' + CRLF
return(cPsScript)

static function svrStart(cSrvName)
	local cPsScript	:= ''	
	
	cFileName := 'rst' + cSrvName		
	cPsScript := '$NameProcess = "' + cSrvName + '"' + CRLF		
	cPsScript += 'if ( get-service | where { $_.name -eq $NameProcess} )' + CRLF
	cPsScript += '{' + CRLF	
	cPsScript += '	if ( get-service | where { $_.status -eq "stopped" -and $_.name -eq $NameProcess} )' + CRLF	
	cPsScript += '	{' + CRLF	
	cPsScript += '		start-service $NameProcess' + CRLF
	cPsScript += '	}'  + CRLF		
	cPsScript += '	start-sleep -seconds 03' + CRLF
	cPsScript += '	if ( get-service | where { $_.status -eq "running" -and $_.name -eq $NameProcess } )' + CRLF
	cPsScript += '	{' + CRLF
	cPsScript += '		set-service $NameProcess -startuptype Automatic' + CRLF
	cPsScript += '	}' + CRLF
	cPsScript += '}' + CRLF
return(cPsScript)

static function rmtSrvPortal(lStart)
	local nBalances		:= GetNewPar('ZZ_NBALPOR', 3)
	local cMsgConfirm 	:= ''
	local aRet			:= {.T.,''}
	default lStart		:= .T.

	if lStart
		cMsgConfirm := 'Confirma a Inicialização dos Serviços do Portal?'
	else
		cMsgConfirm := 'Confirma a Parada dos Serviços do Portal?'
	endif
	if msgYesNo(cMsgConfirm,'Confirmação')
		FwMsgRun(NIL, {|oSay| aRet := execSrvPortal(lStart, nBalances, oSay)}, "Processando", "Executando comandos...")
		if aRet[1]
			MsgInfo(aRet[2],'Executado com Sucesso')
		else	
			MsgAlert(aRet[2],'Erro PowerShell')
		endif
	endif
return(nil)

static function execSrvPortal(lStart, nBalances, oSay)
	local nX	:= 0
	local aRet 	:= {.F.,'Error'}
	oSay:SetText("Procesando " + StrZero(1, 2) + " de " + StrZero((nBalances) + 1, 2))
	aRet := u_cbcSvrShell(iif(lStart, SRV_START, SRV_STOP),;
									'Totvs_Protheus_12_CbcPortal', .T.)	
	if aRet[1]	
		for nX := 1 to nBalances
			oSay:SetText("Procesando " + StrZero(nX + 1, 2) + " de " + StrZero((nBalances) + 1, 2))
			aRet := u_cbcSvrShell(iif(lStart, SRV_START, SRV_STOP),;
										'Totvs_Protheus_12_CbcPortal_BL' + StrZero(nX, 2),.T.)
			if !aRet[1]
				EXIT
			endif
		next nX
	endif
return(aRet)

//STOP Portal
user function rmtStpPortal()
	rmtSrvPortal(.F.)
return(nil)

//START Portal
user function rmtStrPortal()
	rmtSrvPortal(.T.)
return(nil)

//RESTART TSS
user function remoteTssRst()
	if msgYesNo('Confirma a Reinicialização do TSS?','Confirmação')
		u_cbcSvrShell(SRV_RESTART,'TSS-Appserver12')
	endif
return(nil)

//RESTART Schedule
user function remoteSchRst()
	if msgYesNo('Confirma a Reinicialização do Schedule?','Confirmação')
		u_cbcSvrShell(SRV_RESTART,'Totvs_Protheus_12_sch')
	endif
return(nil)

//TESTE ZONE
user function tcbcShellTst()
	if msgYesNo('Confirma Parada do DEV?','Confirmação')
		u_cbcSvrShell(SRV_STOP,'Totvs_Protheus_12_Schedule_Genericos')
	endif
	if msgYesNo('Confirma Inicializacao do DEV?','Confirmação')
		u_cbcSvrShell(SRV_START,'Totvs_Protheus_12_Schedule_Genericos')
	endif
	if msgYesNo('Confirma Reinicializacao do DEV?','Confirmação')
		u_cbcSvrShell(SRV_RESTART,'Totvs_Protheus_12_Schedule_Genericos')
	endif
return(nil)
