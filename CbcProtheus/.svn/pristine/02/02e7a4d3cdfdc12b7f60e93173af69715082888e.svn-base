#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"
/*
PUT:
http://192.168.1.220:7738/ws/BICALCRG/?cOrigem=faturamento&cAno=2019&cMes=02
GET:
http://192.168.1.210:8098/ws/BICALCRG/?cTipo=numero&cEmp=01&cPedido=020045&cOrigem=pedido
cTipo (item=retorna totais por item), (total=retorna o total)
cOrigem ( pedido/portal)
POST:
http://192.168.1.210:8098/ws/BICALCRG
{
"mes": "2",
"ano": "2019",
"array": [ 
["-5", "0"],
["0", "2"],
["2","50"]
]
}
*/
WSRESTFUL BICALCRG DESCRIPTION "Cobrecom - BI - Integração - Calculos de RG"
WSDATA cTipo		AS STRING
WSDATA cAno			AS STRING
WSDATA cMes			AS STRING
WSDATA cEmp			AS STRING
WSDATA cPedido		AS STRING
WSDATA cOrigem		AS STRING
WSMETHOD GET DESCRIPTION "Obter informações do RG mediante parametros" WSSYNTAX "/BICALCRG/{cTipo}&{cEmp}&{cPedido}&{cOrigem}"
WSMETHOD PUT DESCRIPTION "Obter informações do RG mediante parametros" WSSYNTAX "/BICALCRG/{cOrigem}&{cAno}&{cMes}"
WSMETHOD POST DESCRIPTION "Obter faixas de RG" WSSYNTAX "/BICALCRG"
END WSRESTFUL


WSMETHOD POST WSSERVICE BICALCRG
	local oReq		:= nil
	local lPost		:= .T.
	local oRes		:= cbcBIResp():newcbcBIResp()
	local oJson 	:= JsonObject():new()
	local oJsonRes	:= nil
	local aFaixa	:= {}
	local cQry		:= ''
	local cMes		:= nil
	local cAno		:= nil
	::SetContentType("application/json")

	if empty(oJson:fromJSON(::GetContent()))
		// aFaixa := { {'-5', '0'}, {'0', '2'}, {'2', '3'} }
		if !empty(aFaixa := oJson:GetJsonObject('array'))
			if empty((cMes := oJson:GetJsonText('mes'))) .or. empty((cAno := oJson:GetJsonText('ano') ))
				cMes 	:= nil
				cAno	:= nil
			endif
			if !empty(cQry 	:= u_cbcQRYfaixaRg(aFaixa, cMes, cAno))
				oJsonRes 				:= u_cbcQRYexec(cQry)
				oRes:sucesso 			:= .T.
				oRes:msg				:= 'Consulta Realizada'
				oRes:xRet				:= oJsonRes	
				::SetStatus(200)
				::SetResponse(oRes:toJson())
			else	
				throwErr(@oRes, self, 'Erro Query', 404 )
				lPost := .F.
			endif
		else
			throwErr(@oRes, self, 'Erro Objeto', 404 )
		endif
	else
		throwErr(@oRes, self, 'Erro Json recebido', 404 )
		lPost := .F.
	endif
return lPost


WSMETHOD GET WSRECEIVE cTipo, cEmp, cPedido, cOrigem   WSSERVICE BICALCRG
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local oFil			:= cbcFiliais():newcbcFiliais()
	local cQry			:= ''
	local cJson			:= ''
	local oJsonRes		:= nil
	local oJsonCli		:= nil
	local aFaixa		:= {}
	default ::cTipo 	:= 'total' 
	default ::cEmp 		:= '01'
	default ::cPedido 	:= ''
	default ::cOrigem 	:= 'portal' 

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	/*
	::aURLParms		
	::SetResponse(oRes:toJson())
	SetRestFault(406,E406)
	*/
	if ::cOrigem == 'pedido'
		if !empty(cQry 	:= u_cbcQRYped(::cPedido, ::cEmp, ::cTipo  ))
			oJsonRes 	:= u_cbcQRYexec(cQry)
		endif
	elseif ::cOrigem == 'portal'
		if !empty(cQry 	:= u_cbcQRYportal(::cPedido, ::cEmp, ::cTipo  ))
			oJsonRes 	:= u_cbcQRYexec(cQry)
		endif
	endif
	oJsonCli := frmtCli(::cOrigem, ::cPedido, ::cEmp)
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta realizada ' + ::cPedido
	oRes:xRet				:= {oJsonRes, oJsonCli}	
	::SetStatus(200)
	::SetResponse(oRes:toJson())

	FreeObj(oRes)
	FreeObj(oFil)
	FreeObj(oJsonRes)
return(lGet)


WSMETHOD PUT WSRECEIVE cOrigem, cAno, cMes   WSSERVICE BICALCRG
	local lPut			:= .T.
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

	cQry := u_cbcQRYcustVend(::cOrigem, ::cAno, ::cMes)
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


static function frmtCli(cOrigem, cPedido, cEmp)
	local oJsonCli	:= nil
	local cQry		:= ''
	local cCnpjRoot	:= ''
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	cQry := u_cbcQRYcnpjCli(cOrigem,cEmp, cPedido )
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		cCnpjRoot := oSql:getValue('RAIZ')
	endif
	oSql:close()
	FreeObj(oSql)
	if !empty(cCnpjRoot)
		cQry		:= u_cbcQRYcliente(cCnpjRoot)
		oJsonCli 	:= u_cbcQRYexec(cQry)
	endif
return(oJsonCli)


static function throwErr(oRes, oSelf, cMsg, nErr)
	oRes:sucesso  	:= .F.
	oRes:msg		:= cMsg
	oRes:xRet		:= ''
	oSelf:SetStatus(nErr)
	oSelf:SetResponse(oRes:toJson())
return(nil)