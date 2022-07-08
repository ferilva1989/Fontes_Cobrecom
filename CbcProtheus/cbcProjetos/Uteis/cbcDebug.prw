#include 'protheus.ch'
#include 'parmtype.ch'

User Function ESPNOME //SIGAESP
Return ("Debug")

user Function SIGAESP()
	local cMsg	:= 'Executar: '
	local bErro	:= nil
	local lLoop	:= .T.
	static cVar		:= ''
	
	oApp:oMainWnd:CTRLREFRESH()
	
	If oApp:cModName == "SIGAESP1"
		While lLoop
			U_CSFATUR()
			lLoop := MsgYesNo( "Continuar com o Faturamento? ", 'Faturamento' )
		EndDo
	Else
		while lLoop
			if !empty(cVar := FwInputBox(cMsg, cVar))
				bErro := ErrorBlock({|oErr| HandleEr(oErr, cVar)})
				BEGIN SEQUENCE
	
					if exist(@cVar)
						&cVar
					else
						xMagHelpFis(cVar,'Função não existe repositorio!','Verificar')
					endif
	
				RECOVER
				END SEQUENCE
				ErrorBlock(bErro)
	
				if ( lLoop := MsgYesNo( "Continuar execução? ", 'Debug' ) )
					cVar := ''
				endif
	
			else
				lLoop := !MsgYesNo( "Finalizar rotina? ", 'Debug' )
			endif
		enddo
	EndIf
	oApp:oMainWnd:END()
Return


static function exist(cFun)
	local lRet			:= .F.
	local cPrefix			:= 'U_'
	local aChFunc			:= {}
	local cParam			:= ''
	default cFun			:= ''

	if ! empty(cFun)
		cFun := StrTran(StrTran(Upper(cFun), 'U_', ''), ')', '')
		if (U_contaChar(cFun, '(')) == 1
			if !empty(aChFunc := strtokArr(cFun, '('))
				cFun := Alltrim(aChFunc[1])
				if len(aChFunc) == 2
					cParam	:= StrTran(Alltrim(aChFunc[2]), ')', '')
				endif
			else
				cFun := StrTran(cFun, ')', '')
			endif
		endif
		
		if !(lRet := ExistFunc( cPrefix + cFun ) )
			cPrefix := ''
			(lRet := ExistFunc(cFun))
		endif
		cFun := cPrefix + cFun + '(' + cParam + ')'
	endif

return(lRet)

Static function HandleEr(oErr, cVar)
	xMagHelpFis(cVar,'[' +oErr:Description + ']' + chr(10) + chr(13) + oErr:ERRORSTACK,'')
	BREAK
return