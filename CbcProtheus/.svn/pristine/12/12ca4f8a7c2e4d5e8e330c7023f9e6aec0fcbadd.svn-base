#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
GET:
http://192.168.1.220:7798/ws/BIWAP/?cOrigem=faturamento&cAno=2019&cMes=02
PUT:
http://192.168.1.220:7798/ws/BIWAP/?cFato=FATURAMENTO&cAno=2019&cMes=02
*/

WSRESTFUL BIWAP DESCRIPTION "Cobrecom - BI - Integração - WAP"
WSDATA cAno			AS STRING
WSDATA cMes			AS STRING
WSDATA cOrigem		AS STRING
WSDATA cFato		AS STRING
WSMETHOD GET DESCRIPTION "Obter informações gerenciais" WSSYNTAX "/BIWAP/{cOrigem}&{cAno}&{cMes}"
WSMETHOD PUT DESCRIPTION "Obter informações gerenciais" WSSYNTAX "/BIWAP/{cFato}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cOrigem, cAno, cMes   WSSERVICE BIWAP
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local oFil			:= cbcFiliais():newcbcFiliais()
	local cQry			:= ''
	local oJsonRes		:= nil
	default ::cMes 		:= ''
	default ::cAno 		:= ''
	default ::cOrigem 	:= 'faturamento' 

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	cQry := u_cbcQRYWap(::cOrigem, ::cAno, ::cMes)
	oJsonRes 				:= u_cbcQRYexec(cQry)	
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada '
	oRes:xRet				:= oJsonRes	
	::SetStatus(200)
	::SetResponse(oRes:toJson())

	FreeObj(oRes)
	FreeObj(oFil)
	FreeObj(oJsonRes)
return(lGet)


WSMETHOD PUT WSRECEIVE cFato, cAno, cMes   WSSERVICE BIWAP
	local lPut			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local oFil			:= cbcFiliais():newcbcFiliais()
	local cQry			:= ''
	local oJsonRes		:= nil
	default ::cFato 	:= 'FATURADO' 

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	cQry := u_cbcQRYEstPed(::cFato)
	oJsonRes 				:= u_cbcQRYexec(cQry)	
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada '
	oRes:xRet				:= oJsonRes	
	::SetStatus(200)
	::SetResponse(oRes:toJson())

	FreeObj(oRes)
	FreeObj(oFil)
	FreeObj(oJsonRes)
return(lPut)


static function throwErr(oRes, oSelf, cMsg, nErr)
	oRes:sucesso  	:= .F.
	oRes:msg		:= cMsg
	oRes:xRet		:= ''
	oSelf:SetStatus(nErr)
	oSelf:SetResponse(oRes:toJson())
return(nil)