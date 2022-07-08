#include 'protheus.ch'

static URL_API 		:= GetNewPar('XX_ETQAPI', "http://192.168.1.220:3415")
static LIST_VAR 	:= "/listvar/"
static WRITE_DEV	:= "/"
static LIST_PRINT	:= "/listDevice"


class cbcEtqCtrl
	data oJsData
	data aLstPrinter
	data oSelPrinter
	data lOk
	method newcbcEtqCtrl() constructor 
	method layoutData() 
	method defVar()
	method defVarEx()
	method print()
	method getPrinters()
	method defPrinter()
endclass


method newcbcEtqCtrl() class cbcEtqCtrl
	::getPrinters()
	::lOk	:= .T.
return(self)


method layoutData(cLayout) class cbcEtqCtrl
	local lRet			:= .T.
	Local oRestClient	:= nil
	local cUrlApi		:= ''
	default cLayout 	:= ''
	::lOk := .T.
	if !empty(cLayout)
		oRestClient := FWRest():New(URL_API)
		oRestClient:setPath(LIST_VAR + cLayout)
		if (lRet := oRestClient:Get())
			::oJsData := JsonObject():new()
			::oJsData:fromJson(oRestClient:GetResult())
		else
			::lOk := .F.
			conout(oRestClient:GetLastError())
		endif
		FreeObj(oRestClient)
	endif
return(lRet)


method getPrinters() class cbcEtqCtrl
	local oRestClient	:= nil
	local nX			:= 0
	local oPrinter		:= nil
	::lOk	:= .T.
	::aLstPrinter		:= {}
	oRestClient := FWRest():New(URL_API)
	oRestClient:setPath(LIST_PRINT)
	if (lRet := oRestClient:Get())
		oPrinter  := JsonObject():new()
		oPrinter:fromJson(oRestClient:GetResult())
		for nX := 1 to len(oPrinter:getJsonObject('printer'))
			aadd(::aLstPrinter, { oPrinter:getJsonObject('printer')[nX]:GetJsonText('name'),;
			oPrinter:getJsonObject('printer')[nX]})
		next nX
	else
		::lOk := .F.
		conout(oRestClient:GetLastError())
	endif
	FreeObj(oRestClient)
return(self)


method defPrinter(cName) class cbcEtqCtrl
	local oPrinter	:= nil
	local nPos		:= 0
	default cName 	:= selectPrint(::aLstPrinter)
	::lOk := .F.
	if  ( nPos := AScan(::aLstPrinter,{|print| print[1] == cName} ) ) > 0
		::oSelPrinter := ::aLstPrinter[nPos][2]
		::lOk := .T.
	endif 
return(self)


method defVar(cVar, xValue) class cbcEtqCtrl
	default cVar := ''
	default xValue := ''
	if !empty(cVar) .and. !empty(xValue)
		::oJsData:GetJsonObject('ObjPrint'):GetJsonObject('data')[cVar] := xValue
	endif
return(self)


method defVarEx() class cbcEtqCtrl
	local cMcr		:= ''
	local nX		:= 0
	local oJS		:= nil
	local aProps	:= {}
	FWJsonDeserialize(::oJsData:GetJsonObject('ObjPrint'):GetJsonObject('data'):toJson(), @oJS)
	aProps := ClassDataArr(oJS)
	for nX := 1 to len(aProps)
		cMcr := aProps[nX,1] + '()'
		::oJsData:GetJsonObject('ObjPrint'):GetJsonObject('data')[lower(aProps[nX,1])] :=  &cMcr
	next nX
return(self)


method print(nQtd) class cbcEtqCtrl
	local oRestClient 	:= nil
	local aHead			:= {}
	local nX			:= 0
	default nQtd		:= 1
	if ::lOk
		::oJsData:GetJsonObject('ObjPrint')['printerDef'] := ::oSelPrinter
		oRestClient := FWRest():New(URL_API)
		oRestClient:setPath(WRITE_DEV)
		oRestClient:SetPostParams(::oJsData:toJson())
		aadd(aHead, 'Content-Type: application/json')

		for nX := 1 to nQtd
			if !(lRet := oRestClient:Post(aHead))
				conout(oRestClient:GetLastError())
				exit
			endif
		next nX

		FreeObj(oRestClient)
	endif
return(self)


static function selectPrint(aList)
	local nX		:= 0
	local aOpc		:= {}
	local aRet		:= {}
	local aParamBox	:= {}
	local cName	:= ''
	for nX := 1 to len(aList)
		aadd(aOpc, aList[nX,1])
	next nX
	if !empty(aOpc)
		aAdd( aParamBox ,{3,"Impressora",1, aOpc, 250,'.T.',.T.}) 
		if ParamBox(aParamBox,'Impressora',@aRet)
			cName := aOpc[aRet[1]]
		endif
	endif
return(cName)


/* TEST ZONE */
user function zxEtqCtrl()
	local oEtq	:= nil

	oEtq := cbcEtqCtrl():newcbcEtqCtrl()
	oEtq:defPrinter()	
	if oEtq:layoutData('alfaV3.zpl')
		oEtq:defVar('NOME', 'Leo' )
		oEtq:defVar('EMPRESA', 'IFC' )
		oEtq:defVar('CRACHA', '000049' )
		oEtq:print(3)
	endif

	if oEtq:layoutData('alfaV4.zpl')
		oEtq:defVarEx()
		oEtq:print(3)
	endif

	FreeObj(oEtq)
return(nil)