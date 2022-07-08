#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
GET:
http://192.168.1.220:7798/ws/ESAEPAEST/?cTipo=ESA
*/
WSRESTFUL ESAEPAEST DESCRIPTION "Cobrecom - BI - Integração - Estoque Esa Epa"
WSDATA cTipo		AS STRING

WSMETHOD GET DESCRIPTION "Exibição dos resumos de estoque" WSSYNTAX "/ESAEPAEST/{cTipo}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cTipo   WSSERVICE ESAEPAEST
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local cQry			:= ''
	local cJson			:= ''
	local oJsonRes		:= nil
	local oJsonCli		:= nil
	local aFaixa		:= {}
	default ::cTipo 	:= ''

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	if !empty(cQry 		:= u_cbcEsaEpaQry(::cTipo))
			oJsonRes 	:= u_cbcQRYexec(cQry)
	endif

	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada '
	oRes:xRet				:= {oJsonRes}	
	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
	FreeObj(oJsonRes)
return(lGet)


static function throwErr(oRes, oSelf, cMsg, nErr)
	oRes:sucesso  	:= .F.
	oRes:msg		:= cMsg
	oRes:xRet		:= ''
	oSelf:SetStatus(nErr)
	oSelf:SetResponse(oRes:toJson())
return(nil)
