#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
GET:
http://192.168.1.210:8098/ws/BIRESEMP
*/
WSRESTFUL BIRESEMP DESCRIPTION "Cobrecom - BI - Integração - Resumo Empenho Estoque"
WSMETHOD GET DESCRIPTION "Obter os resumos de empenho de materiais" WSSYNTAX "/BIRESEMP"
END WSRESTFUL

WSMETHOD GET  WSSERVICE BIRESEMP
	local lGet			:= .T.
	local oRes			:= cbcBIResp():newcbcBIResp()
	local oJsonRes		:= nil
	
	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	oJsonRes 	:= u_cbcQRYexec(u_cbcQRYemp())
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada '
	oRes:xRet				:= oJsonRes	
	::SetStatus(200)
	::SetResponse(oRes:toJson())

	FreeObj(oRes)
	FreeObj(oJsonRes)
return(lGet)
