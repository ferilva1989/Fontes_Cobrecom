#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
GET:
http://192.168.1.220:7798/ws/GROUPCLI/?cRaizCnpj=numero
*/
WSRESTFUL GROUPCLI DESCRIPTION "Cobrecom - BI - Integração - Analise Cliente por Raiz CNPJ"
WSDATA cRaizCnpj		AS STRING
WSMETHOD GET DESCRIPTION "Obter informações do RG mediante parametros" WSSYNTAX "/GROUPCLI/{cRaizCnpj}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cRaizCnpj   WSSERVICE GROUPCLI
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local cQry			:= ''
	local oJsonCli		:= nil
	default ::cRaizCnpj := '' 
	
	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	if !empty(::cRaizCnpj)
		cQry		:= u_cbcQRYcliente(::cRaizCnpj)
		oJsonCli 	:= u_cbcQRYexec(cQry)
	endif	
	
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada CNPJ ' + ::cRaizCnpj
	oRes:xRet				:= oJsonCli	
	::SetStatus(200)
	::SetResponse(oRes:toJson())

	FreeObj(oRes)
return(lGet)
