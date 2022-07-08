#include 'totvs.ch'
#include 'fileio.ch'

#define 	LOK 1
#define	CERRMSG 2
#define	ORESP 3
#define	CRESP 4

static lDPBZIP 	:=  GetNewPar('XX_DPBZIP'		, .T.)
static cDPBKEY 	:=  GetNewPar('XX_DPBKEY'		, 'QRFoz0hQZYAAAAAAAAAAEXa0gIjC_t4a7WZmJM3Cm-cQu8-b-6bt9S0En0FDHPwA')
static cDPBAPI 	:=  GetNewPar('XX_DPBAPI'		, 'https://content.dropboxapi.com')
static cDPBUPLOAD :=  GetNewPar('XX_DPBUPLD'		, '/2/files/upload')

static cDPBFOLDER :=  GetNewPar('XX_DPBFLDR'		, '/2/files/create_folder_v2')
/*
{
    "path": "/Homework/math",
    "autorename": false
}

https://api.dropboxapi.com/2/files/get_temporary_link
https://api.dropboxapi.com/2/files/list_folder
https://content.dropboxapi.com/2/files/download
*/


// A single request should not upload more than 150 MB.
class cbcUploadFile
	
	data cFile
	data cFileName
	data cUploadFile

	method newcbcUploadFile() constructor
	method chooseFile()
	method readFile()
	method sendAPI()

endclass


method newcbcUploadFile() class cbcUploadFile

return(self)

method sendAPI() class cbcUploadFile
	local oApi	:= nil
	if ! empty(::cUploadFile) .and. ! empty(::cFileName)
		prepHeader(@oApi, 'UPLOAD', Self)
		oApi:sendPost( ::cUploadFile )
		
		if ! oApi:getResp( LOK )
			MsgAlert( oApi:getResp( CERRMSG ),'ERRO')
		elseIf !AttIsMemberOff( oApi:getResp(ORESP) , 'ID' )
			MsgAlert( 'API não retornou ID','ERRO')
		else
			MsgAlert('ID: ' + oApi:getResp(ORESP):ID + ' REV: ' + oApi:getResp(ORESP):REV ,'Sucesso')
		endif
		FreeObj(oApi)
	endif
return(self)


method readFile() class cbcUploadFile
	local oFile	:= nil
	::cUploadFile := ''
	if !empty(::cFile)
		
		oFile := FWFileReader():New(::cFile)
		if !(oFile:Open())
			MsgAlert('Arquivo não aberto', 'ERRO')
		else
			while (oFile:hasLine())
				::cUploadFile += oFile:GetLine()
			end
			::cUploadFile := gzip(::cUploadFile)
			oFile:Close()
		endif
		FreeObj(oFile)
		
	endif
return(self)


method chooseFile(cExt) class cbcUploadFile
	local oParam 		:= nil
	local oParamBox	:= nil
	local aParams		:= {}
	local nI			:= 0
	default cExt		:= 'pdf'
	
	cExt := StrTran(cExt, '.', '')
	::cFile	:= ''
	oParamBox := LibParamBoxObj():newLibParamBoxObj("FileUpload")
	oParamBox:setTitle("Upload de Arquivos")
	oParamBox:setValidation({|| ApMsgYesNo("Confirma parâmetros ?")})
	
	oParam := LibParamObj():newLibParamObj("Upload", "file", "Upload", "C", 80)
	oParam:setFileStartDirectory("C:\")
	oParam:setFileTypes("Arquivos Upload |*." + cExt)
	oParam:setFileParams(GETF_LOCALHARD)
	oParamBox:addParam(oParam)

	if oParamBox:show()
		aParams	:= oParamBox:getParams()
		for nI := 1 to Len(aParams)
			::cFile	:=  oParamBox:getValue(aParams[nI]:getId())
			::cFileName := Lower(RetFileName(::cFile) + '.' + cExt)
		next nI
	endIf
	
	FreeObj(oParam)
	FreeObj(oParamBox)
return(self)


static function prepHeader(oApi, cOper, oSelf)
	oApi := cbcRestAPI():newcbcRestAPI()
	if cOper == 'UPLOAD'
		oApi:New(cDPBAPI)
		oApi:setHeader('Authorization: Bearer ' + cDPBKEY , .T.)
		oApi:setHeader('Dropbox-API-Arg: {"path":"/' + oSelf:cFileName + '","mode": "add","autorename": true,"mute": false}', .F.)
		oApi:setHeader('Content-Type: text/plain; charset=dropbox-cors-hack', .F.)
		oApi:setURLPath( cDPBUPLOAD, .F. )
	endif
return(nil)


static function gzip(cUncomp)
local xStr		:= ''
local cComp 		:= ''
local nLenComp 	:= 0
default cUncomp	:= ''

if lDPBZIP
	if ! empty(cUncomp)
		 cUncomp := Encode64(cUncomp,'',.T.,.F.)
		 if GzStrComp( cUncomp, @cComp, @nLenComp )
		 	xStr := cComp
		 endif
	endif
else
	return(cUncomp)
endif

return(xStr)


/* TEST ZONE */
user function zupldFile()
	local oUpl	:= nil

	oUpl := cbcUploadFile():newcbcUploadFile()
	
	oUpl:chooseFile('pdf')
	// MsgAlert(oUpl:cFile, 'Arquivo')
	
	oUpl:readFile()
	// MsgAlert(oUpl:cUploadFile, 'Arquivo')
	
	oUpl:sendAPI()
	
	
	FreeObj(oUpl)
return(nil)
