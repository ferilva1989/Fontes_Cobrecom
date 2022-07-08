#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcSemaCtr(lLck, cAtuFil, cFunc, nTenta, nConti, nMili, lAuto)
	local lRet 		:= .F.

	default cAtuFil 	:= ''
	default cFunc		:= ''
	default nConti 		:= 10
	default nTenta		:= 10
	default nMili		:= 6000
	default lAuto		:= .T.

	if !empty(cFunc)
		if !lAuto
			if lLck
				FWMsgRun(, { |oSay| lRet := LockFunc(cAtuFil, cFunc, nTenta, nConti, nMili, lAuto, oSay) },;
				 	"Rotina de Acesso Exclusivo!Aguarde...", "Tentando Acesso Exclusivo a Rotina...")
			 else
			 	FWMsgRun(, { |oSay| Leave1Code(cFunc+cAtuFil) },;
				 	"Rotina de Acesso Exclusivo!Aguarde...", "Liberando o Acesso Exclusivo a Rotina...")
			 endif
		 else
		 	if lLck
		 		lRet := LockFunc(cAtuFil, cFunc, nTenta, nConti, nMili, lAuto)
		 	else
		 		Leave1Code(cFunc+cAtuFil)
		 	endif
		 endif
	else
		MsgAlert("Rotina não informada para Controle!")
	endif
return(lRet)

static function LockFunc(cAtuFil, cFunc, nTenta, nConti, nMili, lAuto, oSay)
	local lLock		:= .T.
	local nX		:= 1
	local nY		:= 1
	
	while !MayIUseCode(cFunc+cAtuFil)
		if oSay <> nil
			oSay:SetText('Tentando Acesso Exclusivo a Rotina...Tentativa: ' + cValtoChar(nY)  + ' de ' + cValToChar(nTenta))
			ProcessMessage()
		endif
		Sleep(nMili)
		nX++
		//Continues Automáticos
		if nX >= nConti
			nX := 0
			nY++
			if !lAuto
				if !MsgYesNo( 'Rotina em uso, deseja prosseguir com tentativa de Acesso Exclusivo?', 'Rotina em uso' )
					lLock := .F.
					EXIT
				endif
			endif
		endif
		//Máximo de Tentativas		
		if nY >= nTenta
			lLock := .F.
			EXIT
		endif
	endDo

	if !lLock .and. !lAuto
		MsgAlert('Rotina não pôde ser iniciada em Modo Exclusivo')
	endif
return(lLock)

user function cbcLckKill(lRec)
	default lRec := .F.
	FreeUsedCode(lRec)
return(nil)