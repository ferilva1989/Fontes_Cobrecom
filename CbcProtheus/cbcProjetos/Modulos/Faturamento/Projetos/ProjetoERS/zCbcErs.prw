#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} zCbcErs
@author bolognesi
@since 21/12/2017
@version 1.0
@type function
@description Centraliza toda a execução do CBCERS
Utiliza o controller (cbcERSController) para criar um  objeto populado
service (cbcErsService) para realizar a comunição com API.
/*/
user function zCbcErs(aDadFim, cInJson) // U_zCbcErs('', cInJson)
	local oController 	:= nil
	local oService		:= nil
	local lJson			:= .T.
	local cJson			:= ''
	local aRet			:= {.T., ''}
	local bErro			:= nil
	default cInJson		:= ''
	default aDadFim		:= {}
	
	if GetNewPar('XX_ERSON', .T.) .or. ( ! empty(cInJson) )
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
		BEGIN SEQUENCE
			oController 	:= cbcControllerERS():newcbcControllerERS()
			oService 	:= cbcServiceERS():newcbcServiceERS()
			if empty(cInJson)
				cJson 	:= oController:createFromArr(aDadFim, lJson)
				if !oService:vldModel( oController ):isOk()
					aRet[1] := .F.
					aRet[2] := oService:getResultMsg()
				elseif !oService:login():isOk()
					aRet[1] := .F.
					aRet[2] := oService:getResultMsg()
				else
					if !oService:insert( cJson ):isOk()
						aRet[1] := .F.
						aRet[2] := oService:getResultMsg()
					endif
				endif
			else
				cJson 	:= cInJson
				if !oService:login():isOk()
					aRet[1] := .F.
					aRet[2] := oService:getResultMsg()
				else
					if !oService:insert( cJson ):isOk()
						aRet[1] := .F.
						aRet[2] := oService:getResultMsg()
					endif
				endif
			endif
			
		END SEQUENCE
		ErrorBlock(bErro)
		
		FreeObj( oController )
		FreeObj( oService )
	endif
return ( aRet )


static function HandleEr(oErr, aRet)
	aRet := {.F., oErr:Description }
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	BREAK
return ( nil )


static function ConsoleLog(cMsg)
	ConOut("[CBCERS] - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return ( nil )
