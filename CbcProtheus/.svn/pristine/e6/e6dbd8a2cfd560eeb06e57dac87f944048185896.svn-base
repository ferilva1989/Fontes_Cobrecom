#include 'protheus.ch'

/*/{Protheus.doc} cbcRestAPI
@author bolognesi
@since 21/12/2017
@version 1.0
@type class
@description 
Classe generica para comunicação com API(rest), Utilizando FWRest
(get,post,put,delete)
Herança classe nativa FWRest(), com os metodos
:New(<cHost>)
:SetPath(<cPath>)
:Get(<aHeadStr>)
:GetResult()
:GetLastError()
:Post(<aHeadStr>)
:SetPostParams(<cParams>)
:Put(<aHeadStr>,<CPAYLOAD>)
:Delete(<aHeadStr>,<CPAYLOAD>)
/*/
class cbcRestAPI FROM FWRest

	data cURL
	data cPath
	data aHeader
	data aResp
	
	method newcbcRestAPI() constructor

	method getURL()
	method setURL()
	method getURLPath()
	method setURLPath()

	method getHeader()
	method setHeader()

	method getResp()
	method setResp()

	method sendGet()
	method sendPost()
	method sendPut()
	method sendDelete()

endclass


method newcbcRestAPI() class cbcRestAPI
	::setHeader()
return ( self )


method getURL()class cbcRestAPI
return ( ::cURL )


method setURL(cUrl)class cbcRestAPI
	::cURL := cUrl
	::new(cUrl)
return ( self )


method getURLPath()class cbcRestAPI
return ( ::cPath )


method setURLPath(cPath)class cbcRestAPI
	::setPath(cPath)
return ( self )


method getHeader()class cbcRestAPI
return ( ::aHeader )


method setHeader(cHdr, lClear)class cbcRestAPI
	default lClear 	:= .F.
	default cHdr	:= ''

	if lClear .Or. empty(cHdr)
		::aHeader := {}
	endif

	if !empty(cHdr)
		aadd(::aHeader, cHdr )
	endif

return ( self )


method getResp(nOpc) class cbcRestAPI
local xRet := ''
default nOpc := 0
if Empty(nOpc)
	return( ::aResp )
else
	if !empty(::aResp)
		if Len(::aResp) >= nOpc
			xRet := ::aResp[nOpc]
		endif
	endif
endif
return(xRet)


method setResp(lOk) class cbcRestAPI
	local oJson 	:= nil
	local cResult	:= ::GetResult()
	default lOk 	:= .T.
	::aResp 		:= {}
	if empty(cResult)
		cResult := "{}"
	endif
	FWJsonDeserialize( cResult, @oJson )
	aadd(::aResp, lOk )
	aadd(::aResp, ::GetLastError())
	aadd(::aResp, oJson )
	aadd(::aResp, cResult )
return( self )


method sendGet(cParams)  class cbcRestAPI
// TODO acrescentar parametro de url
return ( self )


method sendPost(cParams)  class cbcRestAPI
	::SetPostParams(cParams)
	::setResp( ::Post( ::getHeader() ))
	::SetPostParams('')
return ( self )


method sendPut(cParams)  class cbcRestAPI
	// TODO acrescentar parametro de url
	::setResp( ::Put( ::getHeader(), cParams ) )
return ( self )


method sendDelete(cParams)  class cbcRestAPI
	// TODO acrescentar parametro de url
	::setResp( ::Delete( ::getHeader(), cParams ) )
return ( self )

