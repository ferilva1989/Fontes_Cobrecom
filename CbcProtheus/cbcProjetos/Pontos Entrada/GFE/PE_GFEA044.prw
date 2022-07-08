#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} GFEA044
@type function
@author bolognesi
@since 12/07/2018
@description Ponto de entrada das rotinas GFEA044, função
apenas recepciona a chamada, identifica o momento e models
realizando a chamada as funções de negocio, contidas na pasta GFEA044
/*/
user function GFEA044
	local lRet		:= .T.
	local aParam 		:= PARAMIXB
	local aArea 		:= getArea()
	local bErro		:= nil
	
	bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		
		if aParam[2] == "FORMPOS"
			
			if  aParam[3] == "GFEA044_GW8"
				lRet := u_cbcGFEpb(aParam[1])
			endif
		
		endif
		
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	
	restArea(aArea)
return(lRet)


/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 12/07/2018
@description função para tratamento de erros
/*/
static function HandleEr(oErr)
	local cMsg	:= "[GFE-GFEA044 - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	logOcorren(cMsg)
	ConOut(cMsg)
	BREAK
return(nil)
