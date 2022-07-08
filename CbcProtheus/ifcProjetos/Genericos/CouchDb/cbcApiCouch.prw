#include 'protheus.ch'

class cbcApiCouch 
	data lStatus
	data cMsgErr
	data cUrlCouch
	data cDb
	data aDbResul
	data aHeader
	data cUsr
	data cPass
	data aResult
	data nCount
	
	method newcbcApiCouch() constructor
	
	method isOk()
	method getErroMsg()
	method createDb()
	method readDb()
	method find()
	method removeDb()
	method delReg()	
	method getTotalRows() 
	method insertReg()
	method updateReg()
endclass


method newcbcApiCouch(cAddress, cPort, cUsr, cPass, cDb) class cbcApiCouch

	default cDb		:= ''
	::cUsr			:= Alltrim(cUsr)
	::cPass 		:= Alltrim(cPass)
	::aHeader		:= {}
	::cDb			:= if(empty(cDb),'cbc'+ Lower(Fwuuidv4()),cDb)
	::cUrlCouch 	:= 'http://' + cAddress + ':' + cPort + '/'
	::lStatus		:= .T.
	::cMsgErr		:= ''
	::aDbResul		:= {}
	::aResult		:= {}
	::nCount		:= 0
	aadd(::aHeader, 'Content-Type: application/json')
	aadd(::aHeader, "Authorization: Basic " + Encode64(::cUsr + ':' + ::cPass))
return(self)

method isOk() class cbcApiCouch
return(::lStatus)

method getErroMsg() class cbcApiCouch
return(::cMsgErr)

method createDb(cDbName) class cbcApiCouch
	local oRest		:= FWRest():New(::cUrlCouch)
	default cDbName := ::cDb
	oRest:SetPath(cDbName) 
	if !(::lStatus := oRest:Put(::aHeader))
		::cMsgErr := oRest:GetLastError()
	endif
	FreeObj(oRest)
return(self)


method readDb() class cbcApiCouch
	local oRest		:= FWRest():New(::cUrlCouch)
	local jDocs		:= JsonObject():new()
	local nX		:= 0
	local cId		:= ''
	::aDbResul		:= {}
	oRest:SetPath(::cDb+ '/_all_docs') 
	if (::lStatus := oRest:Get(::aHeader))
		jDocs:fromJSON(oRest:GetResult())
		for nX := 1 to len(jDocs['rows'])
			cId := jDocs['rows'][nX]['id']
			oRest:SetPath(::cDb+ '/' + cId) 
			if !(::lStatus := oRest:Get(::aHeader))
				::cMsgErr := oRest:GetLastError()
				exit
			else
				aadd(::aDbResul, oRest:GetResult())
			endif
		next nX
	else
		::cMsgErr := oRest:GetLastError()
	endif
	FreeObj(oRest)
return(self)

method find(oJson) class cbcApiCouch
	local oRest		:= FWRest():New(::cUrlCouch)
	local jDocs		:= JsonObject():new()
	local nX		:= 0
	local cId		:= ''
	local oBody		:= JsonObject():new()
	
	::aDbResul		:= {}
	oBody['selector']	:= oJson
	oBody['limit']		:= ::getTotalRows() 
	oRest:SetPath(::cDb+ '/_find')
	oRest:SetPostParams(oBody:toJson())	
	if (::lStatus := oRest:Post(::aHeader))
		jDocs:fromJSON(oRest:GetResult())
		for nX := 1 to len(jDocs['docs'])
			cId := jDocs['docs'][nX]['_id']
			oRest:SetPath(::cDb+ '/' + cId) 
			if !(::lStatus := oRest:Get(::aHeader))
				::cMsgErr := oRest:GetLastError()
				exit
			else
				aadd(::aDbResul, oRest:GetResult())
			endif
		next nX
	else
		::cMsgErr := oRest:GetLastError()
	endif
	FreeObj(oRest)
return(self)

method removeDb(cDbName) class cbcApiCouch
	local oRest		:= FWRest():New(::cUrlCouch)
	default cDbName := ::cDb
	oRest:SetPath(cDbName) 
	if !(::lStatus := oRest:Delete(::aHeader))
		::cMsgErr := oRest:GetLastError()
	endif
	FreeObj(oRest)
return(self)


method delReg(cId, cRev, cDbName) class cbcApiCouch
	local oRest		:= nil 
	default cDbName := ::cDb
	default cId		:= ''
	default cRev	:= ''
	if !empty(cId) .and. !empty(cRev)
		oRest := FWRest():New(::cUrlCouch)
		oRest:SetPath(cDbName + '/'+ cId + '?rev=' + cRev) 
		if !(::lStatus := oRest:Delete(::aHeader))
			::cMsgErr := oRest:GetLastError()
		endif
		FreeObj(oRest)
	endif
return(self)

method getTotalRows() class cbcApiCouch
	local nRows := 0
	local oRest		:= FWRest():New(::cUrlCouch)
	local jDocs		:= JsonObject():new()
	
	::aDbResul		:= {}
	oRest:SetPath(::cDb+ '/_all_docs') 
	if (::lStatus := oRest:Get(::aHeader))
		jDocs:fromJSON(oRest:GetResult())
		nRows := jDocs['total_rows'] 
	endif
	FreeObj(jDocs)
	FreeObj(oRest)
return(nRows)


method insertReg(oDoc) class cbcApiCouch
	local oRest		:= FWRest():New(::cUrlCouch)
	local oBody		:= JsonObject():new()
	
	oBody  := oDoc
	oRest:SetPath(::cDb)
	oRest:SetPostParams(oBody:toJson())	
	if !(::lStatus := oRest:Post(::aHeader))
		::cMsgErr  := oRest:GetLastError()
	endif
	FreeObj(oRest)
return(self)


method updateReg(oDocUpd) class cbcApiCouch
	local oRest		as object
	local oBody		as object
	local oFind		as object
	local oReg		as object
	local cRev		as character
	default cDbName := ::cDb
	
	oRest		 := FWRest():New(::cUrlCouch)
	oFind		 := JsonObject():new()
	oBody		 := JsonObject():new()
	oReg 		 := JsonObject():new()
	oFind['_id'] := oDocUpd['_id']
	
	::find(oFind)
	
	if !empty(::aDbResul) && !empty(oDocUpd['_id']))
		oReg:fromJson(::aDbResul[1])
		cRev			:= oReg['_rev']
		oDocUpd['_rev'] := cRev
		oBody		 	:= oDocUpd
		oRest:SetPath(::cDb + '/' + oDocUpd['_id']) 
		if !(::lStatus := oRest:Put(::aHeader, oBody:toJson()))
			::cMsgErr := oRest:GetLastError()
		endif
	endif
	FreeObj(oRest)
return(self)


static function errHandle(oErr, oSelf)
	oSelf:lStatus	:= .F.
	oSelf:cMsgErr 	:= "[cbcApiCouch - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description
	BREAK
return(nil)


/* TEST ZONE */

/*

	local nX		:= 0
	local aReg		:= {}
	local cId		:= ''
	local cRev		:= ''
	local jTmpRes	:=  nil
	local nLimit	:= GetNewPar('ZZ_COUDTMO', 60)
	::aResult := {}
	::nCount++
	if ::readDb():lStatus
		for nX := 1 to len(::aDbResul)
			jTmpRes := JsonObject():new()
			jTmpRes:fromJson(::aDbResul[nX])
			cId  := jTmpRes['_id']
			cRev := jTmpRes['_rev']
			aadd(::aResult, jTmpRes['data'])
			::delReg(cId, cRev)
		next nX
	endif
	if !empty(::aResult) .or. (::nCount > nLimit)
		oModal:OOWNER:END()
	endif

*/

