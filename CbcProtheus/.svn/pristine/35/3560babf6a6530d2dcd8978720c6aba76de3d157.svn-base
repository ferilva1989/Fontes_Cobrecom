#include 'totvs.ch'
#include 'fileio.ch'

#define DB_PATH				GetNewPar('ZZ_CTEPATH','\config_cte_xml\')
#define DB_FILE				GetNewPar('ZZ_CTEFILE','cteXml.json')
#define XML_SAVE_PATH			GetNewPar('ZZ_CTESAVE','\config_cte_xml\xml\')
#define XML_SAVE_PATH_EVENTO	GetNewPar('ZZ_CTEEVEN','\config_cte_xml\eventos\')
#define VER_CTE				GetNewPar('ZZ_VERCTE','1.00')
#define AMB_CTE				GetNewPar('ZZ_AMBCTE','1')
 
class cbcCteConfig
	data cNSUAtual
	data cNSUMax
	data lLastSts
	data cLastStsMsg
	data cXmlSavePath
	data cSaveEvt
	data cBranch
	data cVerCte
	data cAmbCte
	
	method newcbcCteConfig() constructor
	method loadFrmJson()
	method saveToJson()
	method isExclusive()
	method release()
endclass


method newcbcCteConfig(cBranch) class cbcCteConfig
	default cBranch := FwFilial()
	::cBranch := cBranch
	if ::isExclusive()
		chkDir(self)
		::loadFrmJson()
	endif
return(self)


method loadFrmJson() class cbcCteConfig
	local oRet := nil
	if FWJsonDeserialize(JsonFrmFile(::cBranch), @oRet   )
		doCopy(oRet, @self)
	endIf
return(self)


method saveToJson() class cbcCteConfig
	saveArq(FWJsonSerialize(self,.F.,.T. ),::cBranch)
return(self)


method isExclusive() class cbcCteConfig
return(MayIUseCode( (::cBranch + 'cbcCteConfig') , UsrRetName()))


method release() class cbcCteConfig
	Leave1Code((::cBranch + 'cbcCteConfig') , UsrRetName())
return(self)


static function saveArq(cJson, cBranch)
	local nHandle		:= 0
	local lRet 		:= .T.
	local cFile		:= (DB_PATH + cBranch + DB_FILE)
	default cJson 	:= ''
	default cBranch	:= FwFilial()
	
	if !Empty(cJson)
		if FILE(cFile)
			lRet := (FERASE(cFile) == 0)
		endif
		if ! lRet
			conout("Erro ao deletar arquivo - ferror " + Str(Ferror()))
		else
			nHandle := FCREATE(Alltrim(cFile))
			if nHandle = -1
				conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
				lRet := .F.
			else
				FWrite(nHandle,cJson)
				FClose(nHandle)
			endIf
		endif
	endif
return(lRet)


static function doCopy(oRet, oSelf)
	oSelf:cNSUAtual 		:= oRet:cNSUAtual
	oSelf:cNSUMax			:= oRet:cNSUMax
	oSelf:lLastSts		:= oRet:lLastSts
	oSelf:cLastStsMsg		:= oRet:cLastStsMsg
	oSelf:cXmlSavePath	:= oRet:cXmlSavePath
	oSelf:cSaveEvt		:= oRet:cSaveEvt
	oSelf:cVerCte			:= oRet:cVerCte
	oSelf:cAmbCte			:= oRet:cAmbCte
return(nil)


static function JsonFrmFile(cBranch)
	local oFile 		:= Nil
	local cConteudo 	:= ""
	local cJsonFile	:= ""
	default cBranch	:= FwFilial()
	
	cJsonFile := (DB_PATH + cBranch + DB_FILE)
	oFile := FWFileReader():new(cJsonFile)
	if (oFile:Open())
		cConteudo := oFile:fullread()
		oFile:close()
	endif
	FreeObj(oFile)
return(cConteudo)


static function chkDir(oSelf)
	local cFile		:= (DB_PATH + oSelf:cBranch + DB_FILE) 
	Make(DB_PATH)
	Make(XML_SAVE_PATH)
	Make(XML_SAVE_PATH_EVENTO)
	if !FILE(cFile)
		oSelf:cNSUAtual 		:= '000000000000000'
		oSelf:cNSUMax			:= '000000000000002'
		oSelf:lLastSts		:= .T.
		oSelf:cLastStsMsg		:= '[Processo Iniciado]'
		oSelf:cXmlSavePath	:= XML_SAVE_PATH
		oSelf:cSaveEvt		:= XML_SAVE_PATH_EVENTO
		oSelf:cVerCte 		:= VER_CTE
		oSelf:cAmbCte 		:= AMB_CTE
		oSelf:saveToJson()
	endif
return(nil)


static function Make(cPath)
	if ! ExistDir( cPath )
		if (MakeDir( cPath )) != 0
			//Erro cValToChar( FError() )
		endif
	endif
return(nil)
