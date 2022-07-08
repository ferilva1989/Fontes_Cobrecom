#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
GET:
http://192.168.1.220:8098/ws/ESTPEDINFO/?cEmp=01&cAno=2019&cMes=03
*/
WSRESTFUL ESTPEDINFO DESCRIPTION "Cobrecom - BI - Integração - Apresentação de Estoque"
WSDATA cEmp			AS STRING
WSDATA cAno			AS STRING
WSDATA cMes			AS STRING

WSMETHOD GET DESCRIPTION "Exibição dos resumos de estoque" WSSYNTAX "/ESTPEDINFO/{cEmp}&{cAno}&{cMes}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cEmp, cAno, cMes   WSSERVICE ESTPEDINFO
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local cQry			:= ''
	local cJson			:= ''
	local oJsonRes		:= nil
	local oJsonCli		:= nil
	local aFaixa		:= {}
	default ::cEmp 		:= ''
	default ::cAno 		:= ''
	default ::cMes 		:= '' 

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	if !empty(cQry 	:= u_cbcQRYEstPed())
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