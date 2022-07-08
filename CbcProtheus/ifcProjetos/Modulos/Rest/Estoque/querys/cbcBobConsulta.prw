#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"

/*
GET:
http://192.168.1.220:7798/ws/BOBCONSULTA/?cEmp=01&cProduto=1140905401&cPedido=155026
*/
WSRESTFUL BOBCONSULTA DESCRIPTION "Cobrecom - BI - Integração - Consulta de Bobinas"
WSDATA cEmp			AS STRING
WSDATA cProduto		AS STRING
WSDATA cPedido		AS STRING

WSMETHOD GET DESCRIPTION "Consulta de Bobinas " WSSYNTAX "/BOBCONSULTA/{cEmp}&{cProduto}&{cPedido}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cOrdem   WSSERVICE BOBCONSULTA
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local cJson			:= ''
	local oJsonRes		:= nil
	local cQry			:= ''
	default ::cEmp 		:= ''
	default ::cProduto	:= ''
	default ::cPedido	:= ''

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')
	if !empty(cQry 	:= u_cbcQRYBob(::cEmp, ::cProduto, ::cPedido  ))
			oJsonRes 	:= u_cbcQRYexec(cQry)
	endif
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Bobinas'
	oRes:xRet				:= oJsonRes	
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